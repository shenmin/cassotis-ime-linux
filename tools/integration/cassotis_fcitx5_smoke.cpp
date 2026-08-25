#include "fcitx5_testfrontend_public.h"

#include <array>
#include <cstdlib>
#include <iostream>
#include <string>
#include <utility>
#include <vector>

#include <glib.h>

#include <fcitx-utils/capabilityflags.h>
#include <fcitx-utils/eventdispatcher.h>
#include <fcitx-utils/key.h>
#include <fcitx/action.h>
#include <fcitx/addonmanager.h>
#include <fcitx/candidatelist.h>
#include <fcitx/inputcontext.h>
#include <fcitx/inputmethodgroup.h>
#include <fcitx/inputmethodmanager.h>
#include <fcitx/inputpanel.h>
#include <fcitx/instance.h>
#include <fcitx/userinterfacemanager.h>

namespace {

constexpr const char *kInputMethod = "cassotis";

bool validUuid(const fcitx::ICUUID &uuid) {
    return uuid != fcitx::ICUUID{};
}

class SmokeRunner final {
public:
    explicit SmokeRunner(fcitx::Instance &instance) : instance_(instance) {}

    bool run() {
        if (!prepareInputMethod()) {
            return false;
        }
        const auto standardFlags = fcitx::CapabilityFlags{
            fcitx::CapabilityFlag::Preedit,
            fcitx::CapabilityFlag::SurroundingText,
        };
        const fcitx::ICUUID main = createContext("cassotis-fcitx5-smoke",
                                                 standardFlags);
        if (!validUuid(main) || !verifyCandidateAndCommit(main) ||
            !verifyPagingClick(main) || !verifyCompletion(main) ||
            !verifyNavigationAndEditing(main) ||
            !verifyContextIsolation(main, standardFlags) ||
            !verifyModeShortcuts(main) || !verifyPinyinSchemes(main) ||
            !verifyFuzzyActions(main) || !verifySensitiveContext() ||
            !verifyUserCandidateDeletion(main)) {
            destroyContexts();
            return false;
        }
        destroyContexts();
        std::cout << "fcitx5_native_smoke=ok\n";
        return true;
    }

private:
    bool require(bool condition, const std::string &message) {
        if (!condition) {
            std::cerr << "Cassotis Fcitx 5 smoke failure: " << message
                      << '\n';
        }
        return condition;
    }

    bool prepareInputMethod() {
        frontend_ = instance_.addonManager().addon("testfrontend", true);
        if (!require(frontend_ != nullptr,
                     "Fcitx testfrontend addon was not loaded")) {
            return false;
        }
        if (!require(instance_.addonManager().addon("cassotis", true) !=
                         nullptr,
                     "Cassotis addon was not loaded")) {
            return false;
        }
        fcitx::InputMethodGroup group("CassotisSmoke");
        group.setDefaultLayout("us");
        group.inputMethodList().emplace_back(kInputMethod);
        group.setDefaultInputMethod(kInputMethod);
        instance_.inputMethodManager().addEmptyGroup(group.name());
        instance_.inputMethodManager().setGroup(std::move(group));
        instance_.inputMethodManager().setCurrentGroup("CassotisSmoke");
        return true;
    }

    fcitx::ICUUID createContext(const std::string &program,
                               fcitx::CapabilityFlags flags) {
        const auto uuid = frontend_->call<fcitx::ITestFrontend::createInputContext>(
            program);
        auto *context = instance_.inputContextManager().findByUUID(uuid);
        if (!context) {
            require(false, "test input context was not created");
            return {};
        }
        context->setCapabilityFlags(flags);
        if (flags.test(fcitx::CapabilityFlag::SurroundingText)) {
            context->surroundingText().setText("", 0, 0);
            context->updateSurroundingText();
        }
        context->focusIn();
        instance_.setCurrentInputMethod(context, kInputMethod, true);
        contexts_.push_back(uuid);
        return uuid;
    }

    fcitx::InputContext *context(const fcitx::ICUUID &uuid) {
        return instance_.inputContextManager().findByUUID(uuid);
    }

    bool send(const fcitx::ICUUID &uuid, const fcitx::Key &key) {
        return frontend_->call<fcitx::ITestFrontend::sendKeyEvent>(uuid, key,
                                                                   false);
    }

    bool type(const fcitx::ICUUID &uuid, const std::string &text) {
        for (const char value : text) {
            if (!send(uuid, fcitx::Key(std::string(1, value)))) {
                return require(false, "key was not handled while typing " +
                                          text);
            }
        }
        return true;
    }

    std::string preedit(const fcitx::ICUUID &uuid) {
        auto *inputContext = context(uuid);
        return inputContext
                   ? inputContext->inputPanel().clientPreedit().toString()
                   : std::string{};
    }

    std::shared_ptr<fcitx::CandidateList>
    candidates(const fcitx::ICUUID &uuid) {
        auto *inputContext = context(uuid);
        return inputContext ? inputContext->inputPanel().candidateList()
                            : nullptr;
    }

    std::string firstCandidate(const fcitx::ICUUID &uuid) {
        auto list = candidates(uuid);
        return list && list->size() > 0
                   ? list->candidate(0).text().toString()
                   : std::string{};
    }

    int findCandidate(const fcitx::ICUUID &uuid, const std::string &text) {
        auto list = candidates(uuid);
        if (!list) {
            return -1;
        }
        for (int index = 0; index < list->size(); ++index) {
            if (list->candidate(index).text().toString() == text) {
                return index;
            }
        }
        return -1;
    }

    fcitx::Action *action(const std::string &name) {
        return instance_.userInterfaceManager().lookupAction(name);
    }

    bool activateAction(const fcitx::ICUUID &uuid,
                        const std::string &name) {
        auto *item = action(name);
        if (!require(item != nullptr, "missing action " + name)) {
            return false;
        }
        item->activate(context(uuid));
        return true;
    }

    bool expectActionText(const fcitx::ICUUID &uuid,
                          const std::string &name,
                          const std::string &expected) {
        auto *item = action(name);
        return require(item != nullptr &&
                           item->shortText(context(uuid)) == expected,
                       "action " + name + " did not display " + expected);
    }

    void reset(const fcitx::ICUUID &uuid) {
        if (auto *inputContext = context(uuid)) {
            inputContext->reset();
        }
    }

    void expectCommit(const std::string &text) {
        frontend_->call<fcitx::ITestFrontend::pushCommitExpectation>(text);
    }

    bool verifyCandidateAndCommit(const fcitx::ICUUID &uuid) {
        if (!type(uuid, "nihao")) {
            return false;
        }
        auto list = candidates(uuid);
        if (!require(list && list->size() > 0,
                     "nihao did not publish candidates") ||
            !require(list->candidate(0).text().toString() == "你好",
                     "nihao did not rank 你好 first")) {
            return false;
        }
        expectCommit("你好");
        if (!require(send(uuid, fcitx::Key("space")),
                     "space did not select the first candidate")) {
            return false;
        }
        return require(preedit(uuid).empty(),
                       "composition remained after candidate commit");
    }

    bool verifyPagingClick(const fcitx::ICUUID &uuid) {
        reset(uuid);
        if (!type(uuid, "shi")) {
            return false;
        }
        auto firstPage = candidates(uuid);
        if (!require(firstPage && firstPage->size() > 0,
                     "shi did not publish the first page")) {
            return false;
        }
        const std::string first = firstPage->candidate(0).text().toString();
        auto *firstBulkCursor = firstPage->toBulkCursor();
        if (!require(firstBulkCursor != nullptr,
                     "candidate list did not expose a bulk cursor")) {
            return false;
        }
        const int firstCursor = firstBulkCursor->globalCursorIndex();
        if (!require(send(uuid, fcitx::Key("Down")),
                     "Down was not handled") ||
            !require(candidates(uuid)->toBulkCursor()->globalCursorIndex() !=
                         firstCursor,
                     "Down did not move the selected candidate") ||
            !require(send(uuid, fcitx::Key("Up")),
                     "Up was not handled") ||
            !require(candidates(uuid)->toBulkCursor()->globalCursorIndex() ==
                         firstCursor,
                     "Up did not restore the selected candidate")) {
            return false;
        }
        if (!require(send(uuid, fcitx::Key("Page_Down")),
                     "PageDown was not handled")) {
            return false;
        }
        auto secondPage = candidates(uuid);
        if (!require(secondPage && secondPage->size() > 0,
                     "PageDown did not publish a populated page")) {
            return false;
        }
        const std::string selected =
            secondPage->candidate(0).text().toString();
        if (!require(selected != first,
                     "PageDown did not change the visible page")) {
            return false;
        }
        expectCommit(selected);
        secondPage->candidate(0).select(context(uuid));
        return require(preedit(uuid).empty(),
                       "clicking a second-page candidate did not commit it");
    }

    bool verifyCompletion(const fcitx::ICUUID &uuid) {
        reset(uuid);
        if (!type(uuid, "pianruo")) {
            return false;
        }
        auto *inputContext = context(uuid);
        const std::string auxiliary =
            inputContext->inputPanel().auxDown().toString();
        const std::string arrow = "⇥";
        const auto position = auxiliary.find(arrow);
        if (!require(position != std::string::npos &&
                         position + arrow.size() < auxiliary.size(),
                     "pianruo did not publish one-key completion")) {
            return false;
        }
        const std::string completion =
            auxiliary.substr(position + arrow.size());
        expectCommit(completion);
        return require(send(uuid, fcitx::Key("Tab")),
                       "Tab did not accept one-key completion");
    }

    bool verifyNavigationAndEditing(const fcitx::ICUUID &uuid) {
        reset(uuid);
        if (!type(uuid, "nih") ||
            !require(send(uuid, fcitx::Key("BackSpace")),
                     "Backspace was not handled") ||
            !require(preedit(uuid) == "ni",
                     "Backspace did not restore ni") ||
            !require(!send(uuid, fcitx::Key("Tab")),
                     "Tab without completion was consumed") ||
            !require(preedit(uuid) == "ni",
                     "unhandled Tab changed composition") ||
            !require(send(uuid, fcitx::Key("Escape")),
                     "Escape was not handled") ||
            !require(context(uuid)->inputPanel().empty(),
                     "Escape left composition UI visible")) {
            return false;
        }

        if (!type(uuid, "ni")) {
            return false;
        }
        expectCommit("ni");
        return require(send(uuid, fcitx::Key("Return")),
                       "Enter did not commit raw pinyin") &&
               require(preedit(uuid).empty(),
                       "raw pinyin commit left composition visible");
    }

    bool verifyContextIsolation(const fcitx::ICUUID &main,
                                fcitx::CapabilityFlags flags) {
        reset(main);
        if (!type(main, "ni")) {
            return false;
        }
        const fcitx::ICUUID secondary =
            createContext("cassotis-fcitx5-secondary", flags);
        if (!validUuid(secondary) || !type(secondary, "wo") ||
            !require(preedit(secondary) == "wo",
                     "secondary context composition is incorrect")) {
            return false;
        }
        if (!send(main, fcitx::Key("h"))) {
            return require(false, "primary context did not resume");
        }
        const bool isolated = require(
            preedit(main) == "nih",
            "primary context composition was overwritten by another context");
        reset(main);
        reset(secondary);
        return isolated;
    }

    bool verifyModeShortcuts(const fcitx::ICUUID &uuid) {
        reset(uuid);
        if (!expectActionText(uuid, "cassotis-input-mode", "中") ||
            !expectActionText(uuid, "cassotis-punctuation", "。") ||
            !expectActionText(uuid, "cassotis-width", "半")) {
            return false;
        }

        expectCommit("。");
        if (!require(send(uuid, fcitx::Key(FcitxKey_period)),
                     "Chinese punctuation did not consume period") ||
            !require(send(uuid, fcitx::Key(FcitxKey_period,
                                           fcitx::KeyState::Ctrl)),
                     "Ctrl+period did not toggle punctuation") ||
            !expectActionText(uuid, "cassotis-punctuation", ".") ||
            !require(!send(uuid, fcitx::Key(FcitxKey_period)),
                     "English punctuation consumed period") ||
            !require(send(uuid, fcitx::Key(FcitxKey_period,
                                           fcitx::KeyState::Ctrl)),
                     "Ctrl+period did not restore punctuation") ||
            !expectActionText(uuid, "cassotis-punctuation", "。")) {
            return false;
        }

        if (!require(send(uuid, fcitx::Key(FcitxKey_space,
                                           fcitx::KeyState::Shift)),
                     "Shift+Space did not enable full-width mode") ||
            !expectActionText(uuid, "cassotis-width", "全")) {
            return false;
        }
        if (!require(send(uuid, fcitx::Key("Shift_L")),
                     "Shift did not enter English mode for the width test") ||
            !expectActionText(uuid, "cassotis-input-mode", "英")) {
            return false;
        }
        expectCommit("　");
        if (!require(send(uuid, fcitx::Key(FcitxKey_space)),
                     "full-width space was not handled")) {
            return false;
        }
        if (!require(send(uuid, fcitx::Key("Shift_L")),
                     "Shift did not leave English mode after the width test") ||
            !expectActionText(uuid, "cassotis-input-mode", "中") ||
            !require(send(uuid, fcitx::Key(FcitxKey_space,
                                           fcitx::KeyState::Shift)),
                     "Shift+Space did not restore half-width mode") ||
            !expectActionText(uuid, "cassotis-width", "半")) {
            return false;
        }

        if (!require(send(uuid, fcitx::Key("Shift_L")),
                     "Shift did not switch to English mode")) {
            return false;
        }
        if (!expectActionText(uuid, "cassotis-input-mode", "英")) {
            return false;
        }
        if (!require(!send(uuid, fcitx::Key("n")),
                     "English mode consumed a Latin key")) {
            return false;
        }
        if (!require(send(uuid, fcitx::Key("Shift_L")),
                     "Shift did not switch back to Chinese mode") ||
            !require(send(uuid, fcitx::Key("n")),
                     "Chinese mode did not resume key handling")) {
            return false;
        }
        if (!expectActionText(uuid, "cassotis-input-mode", "中")) {
            return false;
        }
        reset(uuid);
        return true;
    }

    bool verifyPinyinSchemes(const fcitx::ICUUID &uuid) {
        static const std::array<const char *, 7> codes = {
            "nihao", "nihk", "nihc", "nihk", "nihk", "nihq", "nihd",
        };
        static const std::array<const char *, 7> symbols = {
            "拼", "微", "鹤", "自", "搜", "紫", "加",
        };
        for (std::size_t index = 0; index < codes.size(); ++index) {
            reset(uuid);
            const std::string actionName =
                "cassotis-pinyin-scheme-" + std::to_string(index);
            if (!activateAction(uuid, actionName) ||
                !expectActionText(uuid, "cassotis-pinyin-scheme",
                                  symbols[index]) ||
                !require(action(actionName)->isChecked(context(uuid)),
                         "selected pinyin scheme was not checked") ||
                !type(uuid, codes[index]) ||
                !require(firstCandidate(uuid) == "你好",
                         "pinyin scheme did not decode nihao")) {
                return false;
            }
        }
        reset(uuid);
        return activateAction(uuid, "cassotis-pinyin-scheme-0") &&
               expectActionText(uuid, "cassotis-pinyin-scheme", "拼");
    }

    bool verifyFuzzyActions(const fcitx::ICUUID &uuid) {
        if (!expectActionText(uuid, "cassotis-fuzzy-pinyin", "准") ||
            !activateAction(uuid, "cassotis-fuzzy-enabled") ||
            !expectActionText(uuid, "cassotis-fuzzy-pinyin", "模") ||
            !require(action("cassotis-fuzzy-enabled")
                         ->isChecked(context(uuid)),
                     "fuzzy-pinyin enable action was not checked") ||
            !require(action("cassotis-fuzzy-rule-0")
                         ->isChecked(context(uuid)),
                     "default fuzzy-pinyin rules were not enabled") ||
            !activateAction(uuid, "cassotis-fuzzy-rule-0") ||
            !require(!action("cassotis-fuzzy-rule-0")
                          ->isChecked(context(uuid)),
                     "fuzzy-pinyin rule action did not toggle") ||
            !activateAction(uuid, "cassotis-fuzzy-rule-0") ||
            !activateAction(uuid, "cassotis-fuzzy-enabled") ||
            !expectActionText(uuid, "cassotis-fuzzy-pinyin", "准")) {
            return false;
        }
        return true;
    }

    bool verifySensitiveContext() {
        const fcitx::ICUUID password = createContext(
            "cassotis-fcitx5-password",
            fcitx::CapabilityFlags{
                fcitx::CapabilityFlag::PasswordOrSensitive});
        if (!validUuid(password)) {
            return false;
        }
        if (!require(!send(password, fcitx::Key("n")),
                     "password context consumed a Latin key")) {
            return false;
        }
        auto *inputContext = context(password);
        return require(inputContext->inputPanel().empty(),
                       "password context exposed composition UI");
    }

    bool stopEngine() {
        const char *controlPath = std::getenv("CASSOTIS_CONTROL_PATH");
        if (!require(controlPath && *controlPath,
                     "CASSOTIS_CONTROL_PATH is not set")) {
            return false;
        }
        gchar *arguments[] = {const_cast<gchar *>(controlPath),
                              const_cast<gchar *>("shutdown"), nullptr};
        GError *error = nullptr;
        gint status = 0;
        const auto flags = static_cast<GSpawnFlags>(
            G_SPAWN_STDOUT_TO_DEV_NULL | G_SPAWN_STDERR_TO_DEV_NULL);
        const gboolean spawned = g_spawn_sync(
            nullptr, arguments, nullptr, flags, nullptr, nullptr, nullptr,
            nullptr, &status, &error);
        const bool success = spawned &&
                             g_spawn_check_wait_status(status, &error);
        if (!success) {
            require(false, std::string("unable to stop engine: ") +
                               (error ? error->message : "unknown error"));
        }
        g_clear_error(&error);
        return success;
    }

    bool verifyUserCandidateDeletion(const fcitx::ICUUID &uuid) {
        static const std::string input = "gengfu";
        static const std::string userWord = "更父";

        reset(uuid);
        if (!type(uuid, input) ||
            !require(firstCandidate(uuid) == userWord,
                     "seeded user candidate was not ranked first")) {
            return false;
        }

        reset(uuid);
        if (!stopEngine()) {
            return false;
        }
        g_usleep(50000);
        if (!type(uuid, input) ||
            !require(firstCandidate(uuid) == userWord,
                     "user candidate did not survive engine restart")) {
            return false;
        }
        if (!require(send(uuid, fcitx::Key(FcitxKey_Delete,
                                           fcitx::KeyState::Ctrl)),
                     "Ctrl+Delete did not remove the user candidate")) {
            return false;
        }

        reset(uuid);
        if (!stopEngine()) {
            return false;
        }
        g_usleep(50000);
        if (!type(uuid, input)) {
            return false;
        }
        const bool deleted =
            require(findCandidate(uuid, userWord) < 0,
                    "deleted user candidate survived engine restart") &&
            require(!send(uuid, fcitx::Key(FcitxKey_Delete,
                                           fcitx::KeyState::Ctrl)),
                    "non-user candidate remained deletable");
        reset(uuid);
        return deleted;
    }

    void destroyContexts() {
        for (const auto &uuid : contexts_) {
            frontend_->call<fcitx::ITestFrontend::destroyInputContext>(uuid);
        }
        contexts_.clear();
    }

    fcitx::Instance &instance_;
    fcitx::AddonInstance *frontend_ = nullptr;
    std::vector<fcitx::ICUUID> contexts_;
};

} // namespace

int main() {
    char arg0[] = "cassotis-fcitx5-smoke";
    char arg1[] = "--disable=all";
    char arg2[] = "--enable=cassotis,testfrontend";
    char arg3[] = "--verbose=default=3";
    char *arguments[] = {arg0, arg1, arg2, arg3};
    fcitx::Instance instance(4, arguments);
    instance.addonManager().registerDefaultLoader(nullptr);

    int result = 1;
    fcitx::EventDispatcher dispatcher;
    dispatcher.attach(&instance.eventLoop());
    dispatcher.schedule([&instance, &result]() {
        SmokeRunner runner(instance);
        result = runner.run() ? 0 : 1;
        instance.exit();
    });
    instance.exec();
    return result;
}
