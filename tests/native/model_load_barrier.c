#define _GNU_SOURCE
#include <dlfcn.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

/* Test-only interposer. Hold the real ORT initialization, not a mock engine. */
const void *OrtGetApiBase(void)
{
    typedef const void *(*GetApiBase)(void);
    const char *directory = getenv("CASSOTIS_TEST_MODEL_BARRIER");
    char entered[4096];
    char release[4096];
    GetApiBase real_function;
    void *module;

    if (directory != NULL && directory[0] != '\0') {
        if (snprintf(entered, sizeof(entered), "%s/entered", directory) >=
                (int)sizeof(entered) ||
            snprintf(release, sizeof(release), "%s/release", directory) >=
                (int)sizeof(release))
            _exit(90);
        int descriptor = open(entered, O_WRONLY | O_CREAT | O_CLOEXEC, 0600);
        if (descriptor < 0)
            _exit(91);
        close(descriptor);
        const struct timespec pause = {0, 1000000};
        struct timespec started;
        clock_gettime(CLOCK_MONOTONIC, &started);
        while (access(release, F_OK) != 0) {
            struct timespec now;
            clock_gettime(CLOCK_MONOTONIC, &now);
            if (now.tv_sec - started.tv_sec > 60)
                _exit(92);
            nanosleep(&pause, NULL);
        }
    }

    /* ORT is a dependency of a locally dlopened bridge, so RTLD_NEXT alone
       need not see it in the preload object's lookup scope. */
    module = dlopen("libonnxruntime.so.1", RTLD_NOW | RTLD_NOLOAD);
    if (module == NULL)
        _exit(93);
    real_function = (GetApiBase)dlsym(module, "OrtGetApiBase");
    if (real_function == NULL || real_function == OrtGetApiBase)
        _exit(94);
    const void *result = real_function();
    dlclose(module);
    return result;
}
