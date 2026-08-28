#include "cassotis_client.h"
#include "cassotis_candidate_layout.h"
#include "cassotis_shortcut_match.h"

#include <algorithm>
#include <array>
#include <cstdint>
#include <cstring>
#include <cstdlib>
#include <memory>
#include <string>
#include <utility>
#include <vector>

#include <fcitx-utils/capabilityflags.h>
#include <fcitx-utils/event.h>
#include <fcitx-utils/key.h>
#include <fcitx-utils/keysym.h>
#include <fcitx-utils/log.h>
#include <fcitx-config/configuration.h>
#include <fcitx/action.h>
#include <fcitx/addonfactory.h>
#include <fcitx/addonmanager.h>
#include <fcitx/candidatelist.h>
#include <fcitx/event.h>
#include <fcitx/inputcontext.h>
#include <fcitx/inputcontextmanager.h>
#include <fcitx/inputcontextproperty.h>
#include <fcitx/inputmethodengine.h>
#include <fcitx/inputpanel.h>
#include <fcitx/instance.h>
#include <fcitx/menu.h>
#include <fcitx/statusarea.h>
#include <fcitx/userinterfacemanager.h>

namespace {

constexpr std::size_t kDefaultPageSize = 9;
constexpr glong kSurroundingRadius = 2048;
constexpr std::size_t kSchemeCount = 7;
constexpr std::size_t kFuzzyRuleCount = CASSOTIS_FUZZY_RULE_COUNT;
constexpr std::uint64_t kStatePollIntervalUsec = 500000;
constexpr std::uint64_t kResultPollIntervalUsec = 25000;
constexpr unsigned int kResultPollMaxAttempts = 120;
constexpr guint32 kDefaultFuzzyRules =
    CASSOTIS_FUZZY_Z_ZH | CASSOTIS_FUZZY_C_CH |
    CASSOTIS_FUZZY_S_SH | CASSOTIS_FUZZY_L_N |
    CASSOTIS_FUZZY_AN_ANG | CASSOTIS_FUZZY_EN_ENG |
    CASSOTIS_FUZZY_IN_ING;

const std::array<const char *, kSchemeCount> kSchemeSymbols = {
    "拼", "微", "鹤", "自", "搜", "紫", "加",
};

const std::array<const char *, kSchemeCount> kSchemeNames = {
    "全拼",       "微软双拼", "小鹤双拼", "自然码双拼",
    "搜狗双拼",   "紫光双拼", "拼音加加双拼",
};

const std::array<const char *, kFuzzyRuleCount> kFuzzyRuleNames = {
    "z / zh", "c / ch", "s / sh", "l / n", "f / h", "r / l",
    "an / ang", "en / eng", "in / ing", "ian / iang", "uan / uang",
};

const fcitx::KeyList kSelectionKeys = {
    fcitx::Key(FcitxKey_1), fcitx::Key(FcitxKey_2),
    fcitx::Key(FcitxKey_3), fcitx::Key(FcitxKey_4),
    fcitx::Key(FcitxKey_5), fcitx::Key(FcitxKey_6),
    fcitx::Key(FcitxKey_7), fcitx::Key(FcitxKey_8),
    fcitx::Key(FcitxKey_9),
};

fcitx::Text candidateDisplayText(const char *text, const char *comment) {
    std::string displayText = text ? text : "";
#ifndef CASSOTIS_FCITX_HAS_CANDIDATE_COMMENT
    if (comment && *comment) {
        displayText += "  ";
        displayText += comment;
    }
#else
    (void)comment;
#endif
    return fcitx::Text(std::move(displayText));
}

bool statesEqual(const CassotisEngineState &left,
                 const CassotisEngineState &right) {
    return left.input_mode == right.input_mode &&
           left.dictionary_variant == right.dictionary_variant &&
           left.pinyin_scheme == right.pinyin_scheme &&
           left.fuzzy_pinyin_enabled == right.fuzzy_pinyin_enabled &&
           left.fuzzy_pinyin_rules == right.fuzzy_pinyin_rules &&
           left.full_width_mode == right.full_width_mode &&
           left.punctuation_full_width == right.punctuation_full_width &&
           left.candidate_page_size == right.candidate_page_size &&
           left.candidate_page_key_scheme ==
               right.candidate_page_key_scheme &&
           left.one_key_completion_key == right.one_key_completion_key &&
           left.debug_mode == right.debug_mode &&
           std::memcmp(&left.shortcuts, &right.shortcuts,
                       sizeof(left.shortcuts)) == 0;
}

std::size_t effectivePageSize(const CassotisEngineState &state) {
    return state.candidate_page_size >= 3U &&
                   state.candidate_page_size <= 9U
               ? state.candidate_page_size
               : kDefaultPageSize;
}

void logClientError(const char *operation, GError *error) {
    FCITX_WARN() << "Cassotis " << operation << ": "
                 << (error ? error->message : "unknown error");
    g_clear_error(&error);
}

std::string environmentOrDefault(const char *name,
                                 const std::string &fallback) {
    const char *value = g_getenv(name);
    return value && *value ? value : fallback;
}

std::string defaultSocketPath() {
    const char *runtime = g_get_user_runtime_dir();
    gchar *path = g_build_filename(runtime, "cassotis-ime", "engine.sock",
                                   nullptr);
    std::string result(path);
    g_free(path);
    return result;
}

std::string defaultEnginePath() {
    gchar *userPath = g_build_filename(g_get_home_dir(), ".local", "libexec",
                                       "cassotis-ime", "cassotis-engine",
                                       nullptr);
    if (g_file_test(userPath, G_FILE_TEST_IS_EXECUTABLE)) {
        std::string result(userPath);
        g_free(userPath);
        return result;
    }
    g_free(userPath);
    return "/usr/libexec/cassotis-ime/cassotis-engine";
}

std::string defaultSettingsPath() {
    gchar *userPath = g_build_filename(g_get_home_dir(), ".local", "libexec",
                                       "cassotis-ime", "cassotis-settings",
                                       nullptr);
    if (g_file_test(userPath, G_FILE_TEST_IS_EXECUTABLE)) {
        std::string result(userPath);
        g_free(userPath);
        return result;
    }
    g_free(userPath);
    return "/usr/libexec/cassotis-ime/cassotis-settings";
}

class CassotisSettingsConfig final : public fcitx::Configuration {
public:
    explicit CassotisSettingsConfig(const std::string &settingsPath)
        : settings(this, "Settings", "Open Cassotis IME settings",
                   settingsPath) {}

    const char *typeName() const override {
        return "CassotisSettingsConfig";
    }

    fcitx::ExternalOption settings;
};

gint32 utf16Length(const char *start, const char *end) {
    gint32 length = 0;
    const char *cursor = start;
    while (cursor < end && *cursor) {
        const gunichar value = g_utf8_get_char(cursor);
        length += value > 0xffffU ? 2 : 1;
        cursor = g_utf8_next_char(cursor);
    }
    return length;
}

class CassotisFcitxEngine;

class CassotisClientOwner final {
public:
    ~CassotisClientOwner() {
        if (initialized_) {
            cassotis_client_clear(&client_);
        }
    }

    CassotisClient *get() { return &client_; }

    void initialize(const std::string &socketPath,
                    const std::string &enginePath) {
        cassotis_client_init(&client_, socketPath.c_str(),
                             enginePath.c_str());
        initialized_ = true;
    }

private:
    CassotisClient client_{};
    bool initialized_ = false;
};

class CassotisFcitxState : public fcitx::InputContextProperty {
public:
    CassotisFcitxState(CassotisFcitxEngine *engine,
                       fcitx::InputContext *inputContext,
                       guint64 contextId);
    ~CassotisFcitxState() override;

    bool processKey(CassotisSpecialKey specialKey, guint32 modifiers,
                    guint32 scanCode, bool isRelease, bool isRepeat,
                    const std::string &text);
    void selectCandidate(std::size_t globalIndex);
    void acceptCompletion();
    void activate();
    void deactivate();
    void reset();
    void refreshSurrounding();
    void clearUI();
    void handleSensitiveContext();
    void pollAsyncResult();
    int pageIndex() const { return pageIndex_; }

private:
    friend class CassotisFcitxEngine;

    bool ensureContext();
    bool synchronizeContext();
    void markContextLost();
    void renderResult(CassotisEngineResult *result);
    void cacheSurrounding(const std::string &text, unsigned int cursor);

    CassotisFcitxEngine *engine_;
    fcitx::InputContext *inputContext_;
    guint64 contextId_;
    guint64 generationId_ = 0;
    guint64 clientGeneration_ = 0;
    bool contextCreated_ = false;
    bool contextActive_ = false;
    bool desiredActive_ = false;
    bool hasSurrounding_ = false;
    bool surroundingDirty_ = false;
    std::string surroundingText_;
    gint32 surroundingCursor_ = 0;
    int pageIndex_ = 0;
    bool resultPollPending_ = false;
    unsigned int resultPollAttempts_ = 0;
};

class CassotisCandidateWord final : public fcitx::CandidateWord {
public:
    CassotisCandidateWord(CassotisFcitxEngine *engine,
                          std::size_t globalIndex, const char *text,
                          const char *comment);

    void select(fcitx::InputContext *inputContext) const override;

private:
    CassotisFcitxEngine *engine_;
    std::size_t globalIndex_;
};

class CassotisCompletionWord final : public fcitx::CandidateWord {
public:
    CassotisCompletionWord(CassotisFcitxEngine *engine, const char *text);

    void select(fcitx::InputContext *inputContext) const override;

private:
    CassotisFcitxEngine *engine_;
};

class CassotisFcitxEngine final : public fcitx::InputMethodEngineV2 {
public:
    explicit CassotisFcitxEngine(fcitx::Instance *instance);
    ~CassotisFcitxEngine() override;

    void activate(const fcitx::InputMethodEntry &entry,
                  fcitx::InputContextEvent &event) override;
    void deactivate(const fcitx::InputMethodEntry &entry,
                    fcitx::InputContextEvent &event) override;
    void reset(const fcitx::InputMethodEntry &entry,
               fcitx::InputContextEvent &event) override;
    void keyEvent(const fcitx::InputMethodEntry &entry,
                  fcitx::KeyEvent &keyEvent) override;
    const fcitx::Configuration *getConfig() const override {
        return &settingsConfig_;
    }

    CassotisClient *client() { return clientOwner_.get(); }
    auto *factory() { return &factory_; }
    guint64 allocateContextId() { return nextContextId_++; }
    void refreshState(fcitx::InputContext *inputContext);
    void updateStatus(fcitx::InputContext *inputContext);
    bool setState(const CassotisEngineState &state,
                  fcitx::InputContext *inputContext);

private:
    friend class CassotisCandidateWord;
    friend class CassotisFcitxState;

    static CassotisSpecialKey translateSpecialKey(fcitx::KeySym keySym);
    static guint32 translateModifiers(fcitx::KeyStates states);
    static bool isSensitive(fcitx::InputContext *inputContext);
    CassotisFcitxState *stateFor(fcitx::InputContext *inputContext);
    void initializeActions();
    void initializeStatePolling();
    void initializeResultPolling();
    void launchSettings();

    fcitx::Instance *instance_;
    std::string socketPath_;
    std::string enginePath_;
    std::string settingsPath_;
    CassotisSettingsConfig settingsConfig_;
    // Declared before the property factory so it is destroyed after every
    // per-context state has released its engine context.
    CassotisClientOwner clientOwner_;
    guint64 nextContextId_ = 1;
    fcitx::FactoryFor<CassotisFcitxState> factory_;
    CassotisEngineState state_{};
    bool stateValid_ = false;

    fcitx::SimpleAction inputModeAction_;
    fcitx::SimpleAction punctuationAction_;
    fcitx::SimpleAction widthAction_;
    fcitx::SimpleAction schemeAction_;
    fcitx::SimpleAction fuzzyAction_;
    fcitx::SimpleAction fuzzyEnabledAction_;
    fcitx::SimpleAction settingsAction_;
    fcitx::Menu schemeMenu_;
    fcitx::Menu fuzzyMenu_;
    std::array<fcitx::SimpleAction, kSchemeCount> schemeActions_;
    std::array<fcitx::SimpleAction, kFuzzyRuleCount> fuzzyRuleActions_;
    std::unique_ptr<fcitx::EventSourceTime> statePollEvent_;
    std::unique_ptr<fcitx::EventSourceTime> resultPollEvent_;
};

CassotisFcitxState::CassotisFcitxState(
    CassotisFcitxEngine *engine, fcitx::InputContext *inputContext,
    guint64 contextId)
    : engine_(engine), inputContext_(inputContext), contextId_(contextId) {}

CassotisFcitxState::~CassotisFcitxState() {
    if (!contextCreated_ ||
        clientGeneration_ !=
            cassotis_client_connection_generation(engine_->client())) {
        return;
    }
    GError *error = nullptr;
    ++generationId_;
    if (!cassotis_client_destroy_context(engine_->client(), contextId_,
                                         generationId_, &error)) {
        logClientError("destroy context failed", error);
    }
}

void CassotisFcitxState::markContextLost() {
    contextCreated_ = false;
    contextActive_ = false;
    surroundingDirty_ = hasSurrounding_;
    resultPollPending_ = false;
    resultPollAttempts_ = 0;
}

bool CassotisFcitxState::ensureContext() {
    GError *error = nullptr;
    if (!cassotis_client_prepare(engine_->client(), &error)) {
        markContextLost();
        logClientError("connect to engine failed", error);
        return false;
    }
    const guint64 observedGeneration =
        cassotis_client_connection_generation(engine_->client());
    if (clientGeneration_ != observedGeneration) {
        markContextLost();
        clientGeneration_ = observedGeneration;
    }
    if (contextCreated_) {
        return true;
    }
    if (!cassotis_client_create_context(engine_->client(), contextId_,
                                        &error)) {
        logClientError("create context failed", error);
        return false;
    }
    clientGeneration_ =
        cassotis_client_connection_generation(engine_->client());
    contextCreated_ = true;
    contextActive_ = false;
    surroundingDirty_ = hasSurrounding_;
    return true;
}

bool CassotisFcitxState::synchronizeContext() {
    GError *error = nullptr;
    if (!ensureContext()) {
        return false;
    }
    if (surroundingDirty_) {
        ++generationId_;
        if (!cassotis_client_set_surrounding(
                engine_->client(), contextId_, generationId_,
                surroundingText_.c_str(), surroundingCursor_, &error)) {
            markContextLost();
            logClientError("set surrounding text failed", error);
            return false;
        }
        surroundingDirty_ = false;
    }
    if (contextActive_ != desiredActive_) {
        ++generationId_;
        if (!cassotis_client_set_active(engine_->client(), contextId_,
                                        generationId_, desiredActive_,
                                        &error)) {
            markContextLost();
            logClientError("set active state failed", error);
            return false;
        }
        contextActive_ = desiredActive_;
    }
    return true;
}

void CassotisFcitxState::cacheSurrounding(const std::string &source,
                                         unsigned int cursorOffset) {
    const char *value = source.c_str();
    if (!g_utf8_validate(value, -1, nullptr)) {
        value = "";
    }
    const glong characterCount = g_utf8_strlen(value, -1);
    glong cursor = static_cast<glong>(cursorOffset);
    if (cursor > characterCount) {
        cursor = characterCount;
    }
    const glong startIndex =
        cursor > kSurroundingRadius ? cursor - kSurroundingRadius : 0;
    const glong endIndex =
        std::min(characterCount, cursor + kSurroundingRadius);
    const char *start = g_utf8_offset_to_pointer(value, startIndex);
    const char *cursorPointer = g_utf8_offset_to_pointer(value, cursor);
    const char *end = g_utf8_offset_to_pointer(value, endIndex);
    const std::string cropped(start, static_cast<std::size_t>(end - start));
    const gint32 utf16Cursor = utf16Length(start, cursorPointer);

    if (!hasSurrounding_ || surroundingText_ != cropped ||
        surroundingCursor_ != utf16Cursor) {
        surroundingText_ = cropped;
        surroundingCursor_ = utf16Cursor;
        hasSurrounding_ = true;
        surroundingDirty_ = true;
    }
}

void CassotisFcitxState::refreshSurrounding() {
    const auto &surrounding = inputContext_->surroundingText();
    if (!surrounding.isValid()) {
        return;
    }
    cacheSurrounding(surrounding.text(), surrounding.cursor());
}

void CassotisFcitxState::clearUI() {
    inputContext_->inputPanel().reset();
    inputContext_->updatePreedit();
    inputContext_->updateUserInterface(
        fcitx::UserInterfaceComponent::InputPanel, true);
    pageIndex_ = 0;
    resultPollPending_ = false;
    resultPollAttempts_ = 0;
}

void CassotisFcitxState::activate() {
    desiredActive_ = !CassotisFcitxEngine::isSensitive(inputContext_);
    refreshSurrounding();
    synchronizeContext();
    if (!desiredActive_) {
        clearUI();
    }
}

void CassotisFcitxState::deactivate() {
    desiredActive_ = false;
    synchronizeContext();
    clearUI();
}

void CassotisFcitxState::handleSensitiveContext() {
    if (!desiredActive_ && !contextActive_) {
        clearUI();
        return;
    }
    desiredActive_ = false;
    reset();
    synchronizeContext();
}

void CassotisFcitxState::reset() {
    if (ensureContext()) {
        GError *error = nullptr;
        ++generationId_;
        if (!cassotis_client_reset_context(engine_->client(), contextId_,
                                           generationId_, &error)) {
            markContextLost();
            logClientError("reset context failed", error);
        }
    }
    clearUI();
}

void CassotisFcitxState::renderResult(CassotisEngineResult *result) {
    auto &panel = inputContext_->inputPanel();
    const auto pageSize = effectivePageSize(engine_->state_);
    const bool hasCompletion =
        result->completion_text && *result->completion_text;
    panel.reset();

    if (result->commit_text && *result->commit_text) {
        inputContext_->commitString(result->commit_text);
    }
    if (result->preedit_text && *result->preedit_text) {
        fcitx::Text preedit(result->preedit_text);
        preedit.setCursor(static_cast<int>(strlen(result->preedit_text)));
        if (inputContext_->capabilityFlags().test(
                fcitx::CapabilityFlag::Preedit)) {
            panel.setClientPreedit(preedit);
        } else {
            panel.setPreedit(preedit);
        }
    }
    if (result->candidate_count > 0 || hasCompletion) {
        auto candidates = std::make_unique<fcitx::CommonCandidateList>();
        if (hasCompletion) {
            std::vector<std::string> labels;
            labels.reserve(result->candidate_count + 1U);
            for (guint32 index = 0; index < result->candidate_count; ++index) {
                labels.emplace_back(std::to_string(index + 1U));
            }
            labels.emplace_back(
                engine_->state_.one_key_completion_key ==
                        CASSOTIS_COMPLETION_BACKTICK
                    ? "`"
                    : "Tab");
            candidates->setPageSize(
                static_cast<int>(result->candidate_count + 1U));
            candidates->setLabels(labels);
        } else {
            candidates->setPageSize(static_cast<int>(pageSize));
            candidates->setSelectionKey(kSelectionKeys);
        }
        candidates->setLayoutHint(
            cassotis_candidate_panel_requires_vertical(result)
                ? fcitx::CandidateLayoutHint::Vertical
                : fcitx::CandidateLayoutHint::Horizontal);
        for (guint32 index = 0; index < result->candidate_count; ++index) {
            const auto &candidate = result->candidates[index];
            std::string comment = candidate.comment ? candidate.comment : "";
            if (engine_->state_.debug_mode &&
                candidate.has_dictionary_weight) {
                if (!comment.empty()) {
                    comment += "  ";
                }
                comment += std::to_string(candidate.dictionary_weight);
            }
            candidates->insert(
                static_cast<int>(index),
                std::make_unique<CassotisCandidateWord>(
                    engine_, index, candidate.text, comment.c_str()));
        }
        if (hasCompletion) {
            candidates->insert(
                static_cast<int>(result->candidate_count),
                std::make_unique<CassotisCompletionWord>(
                    engine_, result->completion_text));
        }
        if (result->selected_index >= 0 &&
            static_cast<guint32>(result->selected_index) <
                result->candidate_count) {
            candidates->setGlobalCursorIndex(result->selected_index);
        }
        panel.setCandidateList(std::move(candidates));
    }
    pageIndex_ = result->page_index;
    inputContext_->updatePreedit();
    inputContext_->updateUserInterface(
        fcitx::UserInterfaceComponent::InputPanel, true);
}

bool CassotisFcitxState::processKey(CassotisSpecialKey specialKey,
                                   guint32 modifiers, guint32 scanCode,
                                   bool isRelease, bool isRepeat,
                                   const std::string &text) {
    CassotisEngineResult result{};
    result.selected_index = -1;
    for (int attempt = 0; attempt < 2; ++attempt) {
        refreshSurrounding();
        if (!synchronizeContext()) {
            return false;
        }
        GError *error = nullptr;
        ++generationId_;
        if (!cassotis_client_process_key(
                engine_->client(), contextId_, generationId_, specialKey,
                modifiers, scanCode, isRelease, isRepeat,
                static_cast<guint64>(g_get_monotonic_time() / 1000),
                text.c_str(), &result, &error)) {
            markContextLost();
            clearUI();
            logClientError("process key failed", error);
            return false;
        }
        if (result.error_code == 1 && attempt == 0) {
            cassotis_engine_result_clear(&result);
            result = CassotisEngineResult{};
            result.selected_index = -1;
            markContextLost();
            continue;
        }
        break;
    }
    if (result.error_code != 0) {
        FCITX_WARN() << "Cassotis engine result error " << result.error_code
                     << ": "
                     << (result.error_text ? result.error_text : "");
    }
    const bool handled = result.handled;
    if (handled) {
        renderResult(&result);
    }
    resultPollPending_ = result.async_pending;
    resultPollAttempts_ = 0;
    cassotis_engine_result_clear(&result);
    return handled;
}

void CassotisFcitxState::pollAsyncResult() {
    if (!resultPollPending_) {
        return;
    }
    if (!desiredActive_ || !contextCreated_ ||
        resultPollAttempts_ >= kResultPollMaxAttempts) {
        resultPollPending_ = false;
        resultPollAttempts_ = 0;
        return;
    }
    ++resultPollAttempts_;
    CassotisEngineResult result{};
    result.selected_index = -1;
    GError *error = nullptr;
    if (!cassotis_client_poll_result(engine_->client(), contextId_,
                                     generationId_, &result, &error)) {
        resultPollPending_ = false;
        markContextLost();
        clearUI();
        logClientError("poll result failed", error);
        return;
    }
    if (result.error_code != 0) {
        FCITX_WARN() << "Cassotis async result error " << result.error_code
                     << ": "
                     << (result.error_text ? result.error_text : "");
    }
    if (result.handled) {
        renderResult(&result);
        resultPollPending_ = false;
        resultPollAttempts_ = 0;
    }
    cassotis_engine_result_clear(&result);
}

void CassotisFcitxState::selectCandidate(std::size_t globalIndex) {
    if (globalIndex >= effectivePageSize(engine_->state_)) {
        return;
    }
    const char selection = static_cast<char>('1' + globalIndex);
    processKey(CASSOTIS_KEY_NONE, 0, 0, false, false,
               std::string(1, selection));
}

void CassotisFcitxState::acceptCompletion() {
    if (engine_->state_.one_key_completion_key ==
        CASSOTIS_COMPLETION_BACKTICK) {
        processKey(CASSOTIS_KEY_NONE, 0, 0, false, false, "`");
        return;
    }
    processKey(CASSOTIS_KEY_TAB, 0, 0, false, false, "");
}

CassotisCandidateWord::CassotisCandidateWord(
    CassotisFcitxEngine *engine, std::size_t globalIndex, const char *text,
    const char *comment)
    : fcitx::CandidateWord(candidateDisplayText(text, comment)), engine_(engine),
      globalIndex_(globalIndex) {
#ifdef CASSOTIS_FCITX_HAS_CANDIDATE_COMMENT
    if (comment && *comment) {
        setComment(fcitx::Text(comment));
    }
#endif
}

void CassotisCandidateWord::select(
    fcitx::InputContext *inputContext) const {
    if (auto *state = inputContext->propertyFor(engine_->factory())) {
        state->selectCandidate(globalIndex_);
    }
}

CassotisCompletionWord::CassotisCompletionWord(
    CassotisFcitxEngine *engine, const char *text)
    : fcitx::CandidateWord(
          fcitx::Text(std::string("\xE2\x87\xA5") + (text ? text : ""))),
      engine_(engine) {}

void CassotisCompletionWord::select(
    fcitx::InputContext *inputContext) const {
    if (auto *state = inputContext->propertyFor(engine_->factory())) {
        state->acceptCompletion();
    }
}

CassotisFcitxEngine::CassotisFcitxEngine(fcitx::Instance *instance)
    : instance_(instance),
      socketPath_(environmentOrDefault("CASSOTIS_ENGINE_SOCKET",
                                       defaultSocketPath())),
      enginePath_(environmentOrDefault("CASSOTIS_ENGINE_PATH",
                                       defaultEnginePath())),
      settingsPath_(environmentOrDefault("CASSOTIS_SETTINGS_PATH",
                                         defaultSettingsPath())),
      settingsConfig_(settingsPath_),
      factory_([this](fcitx::InputContext &inputContext) {
          return new CassotisFcitxState(this, &inputContext,
                                        allocateContextId());
      }) {
    clientOwner_.initialize(socketPath_, enginePath_);
    // Fcitx owns a non-GLib event loop. Let GLib double-fork the service so no
    // child watch is required and no unreaped child can accumulate.
    cassotis_client_set_track_spawned_child(client(), FALSE);
    instance_->inputContextManager().registerProperty("cassotisState",
                                                      &factory_);
    initializeActions();
    initializeStatePolling();
    initializeResultPolling();
}

CassotisFcitxEngine::~CassotisFcitxEngine() = default;

CassotisFcitxState *CassotisFcitxEngine::stateFor(
    fcitx::InputContext *inputContext) {
    return inputContext->propertyFor(&factory_);
}

bool CassotisFcitxEngine::isSensitive(
    fcitx::InputContext *inputContext) {
    const auto flags = inputContext->capabilityFlags();
    return flags.testAny(fcitx::CapabilityFlag::PasswordOrSensitive) ||
           flags.test(fcitx::CapabilityFlag::Disable);
}

CassotisSpecialKey CassotisFcitxEngine::translateSpecialKey(
    fcitx::KeySym keySym) {
    const guint32 keyValue = static_cast<guint32>(keySym);
    if (keyValue >= FcitxKey_F1 && keyValue <= FcitxKey_F24) {
        return static_cast<CassotisSpecialKey>(
            CASSOTIS_KEY_F1 + keyValue - FcitxKey_F1);
    }

    switch (keySym) {
    case FcitxKey_BackSpace:
        return CASSOTIS_KEY_BACKSPACE;
    case FcitxKey_Delete:
    case FcitxKey_KP_Delete:
        return CASSOTIS_KEY_DELETE;
    case FcitxKey_Return:
    case FcitxKey_KP_Enter:
        return CASSOTIS_KEY_ENTER;
    case FcitxKey_Escape:
        return CASSOTIS_KEY_ESCAPE;
    case FcitxKey_space:
    case FcitxKey_KP_Space:
        return CASSOTIS_KEY_SPACE;
    case FcitxKey_Tab:
    case FcitxKey_ISO_Left_Tab:
        return CASSOTIS_KEY_TAB;
    case FcitxKey_Left:
    case FcitxKey_KP_Left:
        return CASSOTIS_KEY_LEFT;
    case FcitxKey_Right:
    case FcitxKey_KP_Right:
        return CASSOTIS_KEY_RIGHT;
    case FcitxKey_Up:
    case FcitxKey_KP_Up:
        return CASSOTIS_KEY_UP;
    case FcitxKey_Down:
    case FcitxKey_KP_Down:
        return CASSOTIS_KEY_DOWN;
    case FcitxKey_Home:
    case FcitxKey_KP_Home:
        return CASSOTIS_KEY_HOME;
    case FcitxKey_End:
    case FcitxKey_KP_End:
        return CASSOTIS_KEY_END;
    case FcitxKey_Page_Up:
    case FcitxKey_KP_Page_Up:
        return CASSOTIS_KEY_PAGE_UP;
    case FcitxKey_Page_Down:
    case FcitxKey_KP_Page_Down:
        return CASSOTIS_KEY_PAGE_DOWN;
    case FcitxKey_KP_Multiply:
        return CASSOTIS_KEY_NUMPAD_MULTIPLY;
    case FcitxKey_KP_Add:
        return CASSOTIS_KEY_NUMPAD_ADD;
    case FcitxKey_KP_Subtract:
        return CASSOTIS_KEY_NUMPAD_SUBTRACT;
    case FcitxKey_KP_Decimal:
        return CASSOTIS_KEY_NUMPAD_DECIMAL;
    case FcitxKey_KP_Divide:
        return CASSOTIS_KEY_NUMPAD_DIVIDE;
    case FcitxKey_Shift_L:
    case FcitxKey_Shift_R:
        return CASSOTIS_KEY_SHIFT;
    case FcitxKey_Control_L:
    case FcitxKey_Control_R:
        return CASSOTIS_KEY_CONTROL;
    case FcitxKey_Alt_L:
    case FcitxKey_Alt_R:
        return CASSOTIS_KEY_ALT;
    case FcitxKey_Super_L:
    case FcitxKey_Super_R:
        return CASSOTIS_KEY_SUPER;
    default:
        return CASSOTIS_KEY_NONE;
    }
}

guint32 CassotisFcitxEngine::translateModifiers(fcitx::KeyStates states) {
    guint32 result = 0;
    if (states.test(fcitx::KeyState::Shift)) {
        result |= CASSOTIS_MODIFIER_SHIFT;
    }
    if (states.test(fcitx::KeyState::Ctrl)) {
        result |= CASSOTIS_MODIFIER_CONTROL;
    }
    if (states.test(fcitx::KeyState::Alt)) {
        result |= CASSOTIS_MODIFIER_ALT;
    }
    if (states.testAny(fcitx::KeyStates{fcitx::KeyState::Super,
                                        fcitx::KeyState::Super2})) {
        result |= CASSOTIS_MODIFIER_SUPER;
    }
    if (states.test(fcitx::KeyState::CapsLock)) {
        result |= CASSOTIS_MODIFIER_CAPS_LOCK;
    }
    if (states.test(fcitx::KeyState::NumLock)) {
        result |= CASSOTIS_MODIFIER_NUM_LOCK;
    }
    return result;
}

void CassotisFcitxEngine::activate(const fcitx::InputMethodEntry &entry,
                                  fcitx::InputContextEvent &event) {
    (void)entry;
    auto *inputContext = event.inputContext();
    auto *state = stateFor(inputContext);
    state->activate();
    refreshState(inputContext);
    inputContext->statusArea().addAction(fcitx::StatusGroup::InputMethod,
                                         &inputModeAction_);
    inputContext->statusArea().addAction(fcitx::StatusGroup::InputMethod,
                                         &punctuationAction_);
    inputContext->statusArea().addAction(fcitx::StatusGroup::InputMethod,
                                         &widthAction_);
    inputContext->statusArea().addAction(fcitx::StatusGroup::InputMethod,
                                         &schemeAction_);
    inputContext->statusArea().addAction(fcitx::StatusGroup::InputMethod,
                                         &fuzzyAction_);
    inputContext->statusArea().addAction(fcitx::StatusGroup::InputMethod,
                                         &settingsAction_);
    updateStatus(inputContext);
}

void CassotisFcitxEngine::deactivate(const fcitx::InputMethodEntry &entry,
                                    fcitx::InputContextEvent &event) {
    (void)entry;
    stateFor(event.inputContext())->deactivate();
}

void CassotisFcitxEngine::reset(const fcitx::InputMethodEntry &entry,
                               fcitx::InputContextEvent &event) {
    (void)entry;
    stateFor(event.inputContext())->reset();
}

void CassotisFcitxEngine::keyEvent(const fcitx::InputMethodEntry &entry,
                                  fcitx::KeyEvent &keyEvent) {
    (void)entry;
    auto *inputContext = keyEvent.inputContext();
    auto *state = stateFor(inputContext);
    if (isSensitive(inputContext)) {
        state->handleSensitiveContext();
        return;
    }

    const fcitx::Key originalKey = keyEvent.origKey();
    const fcitx::Key normalizedKey = keyEvent.key();
    guint32 modifiers = translateModifiers(originalKey.states());
    const bool isRepeat =
        originalKey.states().test(fcitx::KeyState::Repeat);
    const bool isRelease = keyEvent.isRelease();
    bool handled = false;
    bool stateMayHaveChanged = false;

    if (normalizedKey.sym() == FcitxKey_Shift_L ||
        normalizedKey.sym() == FcitxKey_Shift_R) {
        modifiers |= CASSOTIS_MODIFIER_SHIFT;
    } else if (normalizedKey.sym() == FcitxKey_Control_L ||
               normalizedKey.sym() == FcitxKey_Control_R) {
        modifiers |= CASSOTIS_MODIFIER_CONTROL;
    } else if (normalizedKey.sym() == FcitxKey_Alt_L ||
               normalizedKey.sym() == FcitxKey_Alt_R) {
        modifiers |= CASSOTIS_MODIFIER_ALT;
    } else if (normalizedKey.sym() == FcitxKey_Super_L ||
               normalizedKey.sym() == FcitxKey_Super_R) {
        modifiers |= CASSOTIS_MODIFIER_SUPER;
    }
    if (isRelease) {
        if (normalizedKey.sym() != FcitxKey_Shift_L &&
            normalizedKey.sym() != FcitxKey_Shift_R) {
            return;
        }
        handled = state->processKey(CASSOTIS_KEY_SHIFT, modifiers,
                                    keyEvent.rawKey().code(), true, false, "");
        if (handled) {
            refreshState(inputContext);
        }
        // Shift key-down is passed through, so its release must also reach the
        // application even when Cassotis handles the mode toggle internally.
        return;
    }
    if (!stateValid_) {
        refreshState(inputContext);
    }
    if (stateValid_ && cassotis_shortcut_matches_keysym(
                           &state_.shortcuts.open_settings,
                           static_cast<guint32>(normalizedKey.sym()),
                           modifiers)) {
        launchSettings();
        keyEvent.filterAndAccept();
        return;
    }

    if (normalizedKey.sym() == FcitxKey_Shift_L ||
        normalizedKey.sym() == FcitxKey_Shift_R) {
        handled = state->processKey(CASSOTIS_KEY_SHIFT, modifiers,
                                    keyEvent.rawKey().code(), false, isRepeat,
                                    "");
        stateMayHaveChanged = handled;
    } else {
        const CassotisSpecialKey specialKey =
            translateSpecialKey(normalizedKey.sym());
        if (specialKey != CASSOTIS_KEY_NONE) {
            handled = state->processKey(specialKey, modifiers,
                                        keyEvent.rawKey().code(), false,
                                        isRepeat, "");
            stateMayHaveChanged =
                handled && specialKey == CASSOTIS_KEY_SPACE &&
                (modifiers & (CASSOTIS_MODIFIER_SHIFT |
                              CASSOTIS_MODIFIER_CONTROL |
                              CASSOTIS_MODIFIER_ALT |
                              CASSOTIS_MODIFIER_SUPER)) ==
                    CASSOTIS_MODIFIER_SHIFT;
        } else {
            const std::string text =
                fcitx::Key::keySymToUTF8(originalKey.sym());
            if (text.size() == 1 && static_cast<unsigned char>(text[0]) >= 0x21U &&
                static_cast<unsigned char>(text[0]) <= 0x7eU) {
                handled = state->processKey(CASSOTIS_KEY_NONE, modifiers,
                                            keyEvent.rawKey().code(),
                                            false, isRepeat, text);
                stateMayHaveChanged =
                    handled && text == "." &&
                    (modifiers & (CASSOTIS_MODIFIER_SHIFT |
                                  CASSOTIS_MODIFIER_CONTROL |
                                  CASSOTIS_MODIFIER_ALT |
                                  CASSOTIS_MODIFIER_SUPER)) ==
                        CASSOTIS_MODIFIER_CONTROL;
            }
        }
    }
    if (stateMayHaveChanged) {
        refreshState(inputContext);
    }
    if (handled) {
        keyEvent.filterAndAccept();
    }
}

void CassotisFcitxEngine::refreshState(
    fcitx::InputContext *inputContext) {
    CassotisEngineState observed{};
    GError *error = nullptr;
    if (!cassotis_client_get_state(client(), &observed, &error)) {
        stateValid_ = false;
        logClientError("get engine state failed", error);
        return;
    }
    const bool changed = !stateValid_ || !statesEqual(state_, observed);
    state_ = observed;
    stateValid_ = true;
    if (changed && inputContext) {
        updateStatus(inputContext);
    }
}

bool CassotisFcitxEngine::setState(const CassotisEngineState &state,
                                  fcitx::InputContext *inputContext) {
    GError *error = nullptr;
    if (!cassotis_client_set_state(client(), &state, &error)) {
        stateValid_ = false;
        logClientError("set engine state failed", error);
        return false;
    }
    state_ = state;
    stateValid_ = true;
    if (inputContext) {
        stateFor(inputContext)->clearUI();
        updateStatus(inputContext);
    }
    return true;
}

void CassotisFcitxEngine::updateStatus(
    fcitx::InputContext *inputContext) {
    if (!stateValid_) {
        return;
    }
    inputModeAction_.setShortText(
        state_.input_mode == CASSOTIS_INPUT_CHINESE ? "中" : "英");
    inputModeAction_.setLongText(
        state_.input_mode == CASSOTIS_INPUT_CHINESE ? "中文输入" : "英文输入");
    punctuationAction_.setShortText(
        state_.punctuation_full_width ? "。" : ".");
    punctuationAction_.setLongText(
        state_.punctuation_full_width ? "中文标点" : "英文标点");
    widthAction_.setShortText(state_.full_width_mode ? "全" : "半");
    widthAction_.setLongText(state_.full_width_mode ? "全角字符" : "半角字符");
    const std::size_t scheme =
        static_cast<std::size_t>(state_.pinyin_scheme);
    if (scheme < kSchemeCount) {
        schemeAction_.setShortText(kSchemeSymbols[scheme]);
        schemeAction_.setLongText(kSchemeNames[scheme]);
    }
    for (std::size_t index = 0; index < kSchemeCount; ++index) {
        schemeActions_[index].setChecked(index == scheme);
    }
    fuzzyAction_.setShortText(state_.fuzzy_pinyin_enabled ? "模" : "准");
    fuzzyAction_.setLongText(state_.fuzzy_pinyin_enabled
                                 ? "模糊音已启用"
                                 : "精确拼音");
    fuzzyEnabledAction_.setChecked(state_.fuzzy_pinyin_enabled);
    for (std::size_t index = 0; index < kFuzzyRuleCount; ++index) {
        fuzzyRuleActions_[index].setChecked(
            (state_.fuzzy_pinyin_rules & (1U << index)) != 0);
    }
    for (fcitx::Action *action :
         {static_cast<fcitx::Action *>(&inputModeAction_),
          static_cast<fcitx::Action *>(&punctuationAction_),
          static_cast<fcitx::Action *>(&widthAction_),
          static_cast<fcitx::Action *>(&schemeAction_),
          static_cast<fcitx::Action *>(&fuzzyAction_)}) {
        action->update(inputContext);
    }
    inputContext->updateUserInterface(
        fcitx::UserInterfaceComponent::StatusArea, true);
}

void CassotisFcitxEngine::launchSettings() {
    gchar *arguments[] = {const_cast<gchar *>(settingsPath_.c_str()), nullptr};
    GError *error = nullptr;
    const auto flags = static_cast<GSpawnFlags>(
        G_SPAWN_STDOUT_TO_DEV_NULL | G_SPAWN_STDERR_TO_DEV_NULL);
    if (!g_spawn_async(nullptr, arguments, nullptr, flags,
                       nullptr, nullptr, nullptr, &error)) {
        logClientError("launch settings failed", error);
    }
}

void CassotisFcitxEngine::initializeActions() {
    inputModeAction_.connect<fcitx::SimpleAction::Activated>(
        [this](fcitx::InputContext *inputContext) {
            refreshState(inputContext);
            if (!stateValid_) {
                return;
            }
            auto changed = state_;
            changed.input_mode =
                changed.input_mode == CASSOTIS_INPUT_CHINESE
                    ? CASSOTIS_INPUT_ENGLISH
                    : CASSOTIS_INPUT_CHINESE;
            setState(changed, inputContext);
        });
    punctuationAction_.connect<fcitx::SimpleAction::Activated>(
        [this](fcitx::InputContext *inputContext) {
            refreshState(inputContext);
            if (!stateValid_) {
                return;
            }
            auto changed = state_;
            changed.punctuation_full_width =
                !changed.punctuation_full_width;
            setState(changed, inputContext);
        });
    widthAction_.connect<fcitx::SimpleAction::Activated>(
        [this](fcitx::InputContext *inputContext) {
            refreshState(inputContext);
            if (!stateValid_) {
                return;
            }
            auto changed = state_;
            changed.full_width_mode = !changed.full_width_mode;
            setState(changed, inputContext);
        });
    settingsAction_.setShortText("设置");
    settingsAction_.setLongText("言泉输入法设置");
    settingsAction_.setIcon("preferences-system");
    settingsAction_.connect<fcitx::SimpleAction::Activated>(
        [this](fcitx::InputContext *) { launchSettings(); });

    schemeAction_.setMenu(&schemeMenu_);
    for (std::size_t index = 0; index < kSchemeCount; ++index) {
        auto &action = schemeActions_[index];
        action.setShortText(kSchemeNames[index]);
        action.setLongText(kSchemeNames[index]);
        action.setCheckable(true);
        action.connect<fcitx::SimpleAction::Activated>(
            [this, index](fcitx::InputContext *inputContext) {
                refreshState(inputContext);
                if (!stateValid_) {
                    return;
                }
                auto changed = state_;
                changed.pinyin_scheme =
                    static_cast<CassotisPinyinScheme>(index);
                setState(changed, inputContext);
            });
        schemeMenu_.addAction(&action);
    }

    fuzzyAction_.setMenu(&fuzzyMenu_);
    fuzzyEnabledAction_.setShortText("启用模糊音");
    fuzzyEnabledAction_.setLongText("启用受控模糊音精确召回");
    fuzzyEnabledAction_.setCheckable(true);
    fuzzyEnabledAction_.connect<fcitx::SimpleAction::Activated>(
        [this](fcitx::InputContext *inputContext) {
            refreshState(inputContext);
            if (!stateValid_) {
                return;
            }
            auto changed = state_;
            changed.fuzzy_pinyin_enabled = !changed.fuzzy_pinyin_enabled;
            if (changed.fuzzy_pinyin_enabled &&
                changed.fuzzy_pinyin_rules == 0) {
                changed.fuzzy_pinyin_rules = kDefaultFuzzyRules;
            }
            setState(changed, inputContext);
        });
    fuzzyMenu_.addAction(&fuzzyEnabledAction_);
    for (std::size_t index = 0; index < kFuzzyRuleCount; ++index) {
        auto &action = fuzzyRuleActions_[index];
        action.setShortText(kFuzzyRuleNames[index]);
        action.setLongText(kFuzzyRuleNames[index]);
        action.setCheckable(true);
        action.connect<fcitx::SimpleAction::Activated>(
            [this, index](fcitx::InputContext *inputContext) {
                refreshState(inputContext);
                if (!stateValid_) {
                    return;
                }
                auto changed = state_;
                changed.fuzzy_pinyin_rules ^= 1U << index;
                setState(changed, inputContext);
            });
        fuzzyMenu_.addAction(&action);
    }

    auto &uiManager = instance_->userInterfaceManager();
    uiManager.registerAction("cassotis-input-mode", &inputModeAction_);
    uiManager.registerAction("cassotis-punctuation", &punctuationAction_);
    uiManager.registerAction("cassotis-width", &widthAction_);
    uiManager.registerAction("cassotis-pinyin-scheme", &schemeAction_);
    uiManager.registerAction("cassotis-fuzzy-pinyin", &fuzzyAction_);
    uiManager.registerAction("cassotis-fuzzy-enabled",
                             &fuzzyEnabledAction_);
    uiManager.registerAction("cassotis-settings", &settingsAction_);
    for (std::size_t index = 0; index < kSchemeCount; ++index) {
        uiManager.registerAction(
            std::string("cassotis-pinyin-scheme-") +
                std::to_string(index),
            &schemeActions_[index]);
    }
    for (std::size_t index = 0; index < kFuzzyRuleCount; ++index) {
        uiManager.registerAction(
            std::string("cassotis-fuzzy-rule-") + std::to_string(index),
            &fuzzyRuleActions_[index]);
    }
}

void CassotisFcitxEngine::initializeStatePolling() {
    statePollEvent_ = instance_->eventLoop().addTimeEvent(
        CLOCK_MONOTONIC,
        fcitx::now(CLOCK_MONOTONIC) + kStatePollIntervalUsec, 0,
        [this](fcitx::EventSourceTime *event, std::uint64_t) {
            auto *inputContext = instance_->mostRecentInputContext();
            if (inputContext && inputContext->hasFocus() &&
                instance_->inputMethod(inputContext) == "cassotis") {
                refreshState(inputContext);
            }
            event->setNextInterval(kStatePollIntervalUsec);
            return true;
        });
}

void CassotisFcitxEngine::initializeResultPolling() {
    resultPollEvent_ = instance_->eventLoop().addTimeEvent(
        CLOCK_MONOTONIC,
        fcitx::now(CLOCK_MONOTONIC) + kResultPollIntervalUsec, 0,
        [this](fcitx::EventSourceTime *event, std::uint64_t) {
            auto *inputContext = instance_->mostRecentInputContext();
            if (inputContext && inputContext->hasFocus() &&
                instance_->inputMethod(inputContext) == "cassotis") {
                stateFor(inputContext)->pollAsyncResult();
            }
            event->setNextInterval(kResultPollIntervalUsec);
            return true;
        });
}

class CassotisFcitxEngineFactory final : public fcitx::AddonFactory {
public:
    fcitx::AddonInstance *create(fcitx::AddonManager *manager) override {
        return new CassotisFcitxEngine(manager->instance());
    }
};

} // namespace

#ifdef FCITX_ADDON_FACTORY_V2
FCITX_ADDON_FACTORY_V2(cassotis, CassotisFcitxEngineFactory);
#else
FCITX_ADDON_FACTORY(CassotisFcitxEngineFactory);
#endif
