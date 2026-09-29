#pragma once

#include <cerrno>
#include <cstdint>
#include <cstring>
#include <fcntl.h>
#include <map>
#include <memory>
#include <mutex>
#include <string>
#include <sys/mman.h>
#include <sys/stat.h>
#include <tuple>
#include <unistd.h>

// Immutable indexes are shared by inference sessions in the same process.
// Identify the opened inode, not its pathname: upgrades replace the inode while
// existing sessions must continue to see their original index until destroyed.
class ReadOnlyMappedFile {
    struct Mapping {
        int file{-1};
        const uint8_t* data{};
        size_t size{};
        ~Mapping() {
            if (data) munmap(const_cast<uint8_t*>(data), size);
            if (file >= 0) close(file);
        }
    };
    using Key = std::tuple<dev_t, ino_t, off_t, time_t, long, time_t, long>;
    struct Pool {
        std::mutex mutex;
        std::map<Key, std::weak_ptr<Mapping>> files;
    };
    static Pool& SharedPool() {
        static Pool pool;
        return pool;
    }
    std::shared_ptr<Mapping> mapping_;

public:
    bool Open(const char* path, std::string& error) {
        Close();
        auto fresh = std::make_shared<Mapping>();
        fresh->file = open(path, O_RDONLY | O_CLOEXEC);
        if (fresh->file < 0) {
            error = "cannot open local-completion index: " + std::string(std::strerror(errno));
            return false;
        }
        struct stat metadata {};
        if (fstat(fresh->file, &metadata) != 0 || !S_ISREG(metadata.st_mode) ||
            metadata.st_size <= 0) {
            error = "cannot read local-completion index size";
            return false;
        }
        const Key key{metadata.st_dev, metadata.st_ino, metadata.st_size,
            metadata.st_mtim.tv_sec, metadata.st_mtim.tv_nsec,
            metadata.st_ctim.tv_sec, metadata.st_ctim.tv_nsec};
        auto& pool = SharedPool();
        const std::lock_guard<std::mutex> guard(pool.mutex);
        for (auto it = pool.files.begin(); it != pool.files.end();) {
            if (it->second.expired()) it = pool.files.erase(it);
            else ++it;
        }
        const auto found = pool.files.find(key);
        if (found != pool.files.end()) {
            mapping_ = found->second.lock();
            if (mapping_) return true;
        }
        fresh->size = static_cast<size_t>(metadata.st_size);
        void* address = mmap(nullptr, fresh->size, PROT_READ, MAP_PRIVATE, fresh->file, 0);
        if (address == MAP_FAILED) {
            error = "cannot map local-completion index: " + std::string(std::strerror(errno));
            return false;
        }
        fresh->data = static_cast<const uint8_t*>(address);
        pool.files[key] = fresh;
        mapping_ = std::move(fresh);
        return true;
    }

    void Close() { mapping_.reset(); }
    const uint8_t* data() const { return mapping_ ? mapping_->data : nullptr; }
    size_t size() const { return mapping_ ? mapping_->size : 0; }

    void FinishValidation() const {
        if (!mapping_) return;
        // Validation scans the complete index, while queries need sparse pages.
        // Drop only these read-only page-table entries, not the mapping, its
        // inode or the OS file cache. Existing readers retain identical bytes,
        // including across atomic replacement/unlink. Advice failure is benign.
        auto* address = const_cast<uint8_t*>(mapping_->data);
        madvise(address, mapping_->size, MADV_RANDOM);
        madvise(address, mapping_->size, MADV_DONTNEED);
    }

    static void ReleaseIdlePages() {
        auto& pool = SharedPool();
        const std::unique_lock<std::mutex> guard(pool.mutex, std::try_to_lock);
        if (!guard.owns_lock()) return;
        for (const auto& [key, weak] : pool.files) {
            if (auto mapping = weak.lock()) {
                madvise(const_cast<uint8_t*>(mapping->data), mapping->size,
                    MADV_DONTNEED);
            }
        }
    }
};
