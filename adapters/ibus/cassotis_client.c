#include "cassotis_client.h"

#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <sys/un.h>
#include <sys/wait.h>
#include <unistd.h>

#define CASSOTIS_SEND_TIMEOUT_MS 150
/* The release gate permits a bounded 3-second worst-case engine query.  The
 * transport timeout must exceed that budget or a valid long-sentence result
 * is misclassified as a dead engine under load. */
#define CASSOTIS_RECEIVE_TIMEOUT_MS 3500
#define CASSOTIS_START_TIMEOUT_MS 30000
#define CASSOTIS_START_RETRY_US 25000

G_DEFINE_QUARK(cassotis-client-error-quark, cassotis_client_error)

static void close_socket(CassotisClient *client)
{
    if (client->socket_fd >= 0) {
        close(client->socket_fd);
        client->socket_fd = -1;
    }
}

static gboolean socket_is_alive(gint descriptor)
{
    guint8 value;
    ssize_t count;

    count = recv(descriptor, &value, sizeof(value),
                 MSG_PEEK | MSG_DONTWAIT);
    if (count > 0)
        return TRUE;
    if (count == 0)
        return FALSE;
    return errno == EAGAIN || errno == EWOULDBLOCK || errno == EINTR;
}

static gboolean set_errno_error(GError **error, const gchar *operation)
{
    g_set_error(error, cassotis_client_error_quark(), errno,
                "%s failed: %s", operation, g_strerror(errno));
    return FALSE;
}

static gboolean connect_socket(CassotisClient *client)
{
    struct sockaddr_un address;
    struct timeval receive_timeout;
    struct timeval send_timeout;
    gint descriptor;
    gsize path_length = strlen(client->socket_path);

    if (path_length >= sizeof(address.sun_path))
        return FALSE;
    descriptor = socket(AF_UNIX, SOCK_STREAM, 0);
    if (descriptor < 0)
        return FALSE;
    fcntl(descriptor, F_SETFD, FD_CLOEXEC);
    receive_timeout.tv_sec = CASSOTIS_RECEIVE_TIMEOUT_MS / 1000;
    receive_timeout.tv_usec =
        (CASSOTIS_RECEIVE_TIMEOUT_MS % 1000) * 1000;
    send_timeout.tv_sec = CASSOTIS_SEND_TIMEOUT_MS / 1000;
    send_timeout.tv_usec = (CASSOTIS_SEND_TIMEOUT_MS % 1000) * 1000;
    setsockopt(descriptor, SOL_SOCKET, SO_RCVTIMEO, &receive_timeout,
               sizeof(receive_timeout));
    setsockopt(descriptor, SOL_SOCKET, SO_SNDTIMEO, &send_timeout,
               sizeof(send_timeout));

    memset(&address, 0, sizeof(address));
    address.sun_family = AF_UNIX;
    memcpy(address.sun_path, client->socket_path, path_length + 1);
    if (connect(descriptor, (struct sockaddr *)&address, sizeof(address)) < 0) {
        close(descriptor);
        return FALSE;
    }
    client->socket_fd = descriptor;
    ++client->connection_generation;
    if (client->connection_generation == 0)
        ++client->connection_generation;
    return TRUE;
}

static void child_exited(GPid pid, gint status, gpointer user_data)
{
    CassotisClient *client = user_data;

    (void)status;
    if (client->spawned_pid == pid) {
        client->spawned_pid = 0;
        client->child_watch_id = 0;
    }
    g_spawn_close_pid(pid);
}

static gboolean spawn_engine(CassotisClient *client, GError **error)
{
    gchar *arguments[] = {client->engine_path, (gchar *)"--serve",
                          (gchar *)"--socket", client->socket_path, NULL};
    GPid child_pid = 0;
    GSpawnFlags flags = G_SPAWN_STDOUT_TO_DEV_NULL |
                        G_SPAWN_STDERR_TO_DEV_NULL;

    if (client->track_spawned_child)
        flags |= G_SPAWN_DO_NOT_REAP_CHILD;
    if (!g_spawn_async(NULL, arguments, NULL,
                       flags, NULL, NULL,
                       client->track_spawned_child ? &child_pid : NULL,
                       error))
        return FALSE;
    if (client->track_spawned_child) {
        client->spawned_pid = child_pid;
        client->child_watch_id = g_child_watch_add(child_pid, child_exited,
                                                    client);
    }
    return TRUE;
}

gboolean cassotis_client_stop_spawned_engine(CassotisClient *client,
                                             GError **error)
{
    gint status;

    close_socket(client);
    if (client->spawned_pid <= 0)
        return TRUE;
    if (client->child_watch_id != 0) {
        g_source_remove(client->child_watch_id);
        client->child_watch_id = 0;
    }
    if (kill(client->spawned_pid, SIGTERM) < 0 && errno != ESRCH)
        return set_errno_error(error, "terminate cassotis-engine");
    while (waitpid(client->spawned_pid, &status, 0) < 0) {
        if (errno == EINTR)
            continue;
        if (errno != ECHILD)
            return set_errno_error(error, "wait for cassotis-engine");
        break;
    }
    g_spawn_close_pid(client->spawned_pid);
    client->spawned_pid = 0;
    return TRUE;
}

static gboolean ensure_connected(CassotisClient *client, GError **error)
{
    gint64 start_deadline;
    GError *spawn_error = NULL;
    if (client->socket_fd >= 0) {
        if (socket_is_alive(client->socket_fd))
            return TRUE;
        close_socket(client);
    }
    if (connect_socket(client))
        return TRUE;
    if (!client->allow_spawn) {
        g_set_error(error, cassotis_client_error_quark(), 1,
                    "engine is not listening on %s", client->socket_path);
        return FALSE;
    }
    if (!spawn_engine(client, &spawn_error)) {
        g_propagate_prefixed_error(error, spawn_error,
                                   "unable to start cassotis-engine: ");
        return FALSE;
    }
    start_deadline = g_get_monotonic_time() +
                     (gint64)CASSOTIS_START_TIMEOUT_MS * 1000;
    do {
        g_usleep(CASSOTIS_START_RETRY_US);
        if (connect_socket(client))
            return TRUE;
    } while (g_get_monotonic_time() < start_deadline);
    g_set_error(error, cassotis_client_error_quark(), 1,
                "unable to connect to %s within %u ms after starting engine",
                client->socket_path, CASSOTIS_START_TIMEOUT_MS);
    return FALSE;
}

static gboolean write_all(gint descriptor, const guint8 *data, gsize length,
                          GError **error)
{
    gsize offset = 0;
    while (offset < length) {
        ssize_t count = send(descriptor, data + offset, length - offset,
                             MSG_NOSIGNAL);
        if (count < 0) {
            if (errno == EINTR)
                continue;
            return set_errno_error(error, "send");
        }
        if (count == 0) {
            g_set_error_literal(error, cassotis_client_error_quark(), 1,
                                "engine connection closed while sending");
            return FALSE;
        }
        offset += (gsize)count;
    }
    return TRUE;
}

static gboolean read_all(gint descriptor, guint8 *data, gsize length,
                         GError **error)
{
    gsize offset = 0;
    while (offset < length) {
        ssize_t count = recv(descriptor, data + offset, length - offset, 0);
        if (count < 0) {
            if (errno == EINTR)
                continue;
            return set_errno_error(error, "recv");
        }
        if (count == 0) {
            g_set_error_literal(error, cassotis_client_error_quark(), 1,
                                "engine connection closed while receiving");
            return FALSE;
        }
        offset += (gsize)count;
    }
    return TRUE;
}

static gboolean exchange(CassotisClient *client,
                         GByteArray *request,
                         CassotisMessageType expected_type,
                         guint64 expected_request_id,
                         guint64 expected_context_id,
                         guint64 expected_generation_id,
                         GByteArray **response_payload,
                         GError **error)
{
    guint8 header_data[CASSOTIS_IPC_HEADER_SIZE];
    CassotisFrameHeader header;
    GByteArray *payload = NULL;
    guint32 remote_error_code;
    gchar *remote_error_text = NULL;
    GError *local_error = NULL;

    *response_payload = NULL;
    if (!ensure_connected(client, error)) {
        g_byte_array_unref(request);
        return FALSE;
    }
    if (!write_all(client->socket_fd, request->data, request->len,
                   &local_error))
        goto fail;
    g_byte_array_unref(request);
    request = NULL;
    if (!read_all(client->socket_fd, header_data, sizeof(header_data),
                  &local_error) ||
        !cassotis_protocol_parse_header(header_data, sizeof(header_data),
                                        &header, &local_error))
        goto fail;
    payload = g_byte_array_sized_new(header.payload_length);
    g_byte_array_set_size(payload, header.payload_length);
    if (header.payload_length > 0 &&
        !read_all(client->socket_fd, payload->data, payload->len,
                  &local_error))
        goto fail;
    if ((header.flags & CASSOTIS_IPC_FLAG_RESPONSE) == 0 ||
        header.request_id != expected_request_id ||
        header.context_id != expected_context_id ||
        header.generation_id != expected_generation_id) {
        g_set_error_literal(&local_error, cassotis_client_error_quark(), 1,
                            "engine returned a mismatched IPC response");
        goto fail;
    }
    if ((header.flags & CASSOTIS_IPC_FLAG_ERROR) != 0 ||
        header.message_type == CASSOTIS_MESSAGE_ERROR) {
        if (cassotis_protocol_decode_error(payload->data, payload->len,
                                           &remote_error_code,
                                           &remote_error_text, &local_error)) {
            g_set_error(&local_error, cassotis_client_error_quark(),
                        (gint)remote_error_code, "engine error: %s",
                        remote_error_text);
            g_free(remote_error_text);
        }
        goto fail;
    }
    if (header.message_type != expected_type) {
        g_set_error(&local_error, cassotis_client_error_quark(), 1,
                    "unexpected engine response type %u", header.message_type);
        goto fail;
    }
    *response_payload = payload;
    return TRUE;

fail:
    if (request != NULL)
        g_byte_array_unref(request);
    if (payload != NULL)
        g_byte_array_unref(payload);
    close_socket(client);
    g_propagate_error(error, local_error);
    return FALSE;
}

static gboolean empty_request(CassotisClient *client,
                              CassotisMessageType message_type,
                              guint64 context_id,
                              guint64 generation_id,
                              GError **error)
{
    guint64 request_id = client->next_request_id++;
    GByteArray *request = cassotis_protocol_build_empty_request(
        message_type, request_id, context_id, generation_id);
    GByteArray *response = NULL;
    gboolean success = exchange(client, request, message_type, request_id,
                                context_id, generation_id, &response, error);
    if (response != NULL)
        g_byte_array_unref(response);
    return success;
}

void cassotis_client_init(CassotisClient *client,
                          const gchar *socket_path,
                          const gchar *engine_path)
{
    memset(client, 0, sizeof(*client));
    client->socket_fd = -1;
    client->next_request_id = 1;
    client->connection_generation = 0;
    client->socket_path = g_strdup(socket_path);
    client->engine_path = g_strdup(engine_path);
    client->spawned_pid = 0;
    client->child_watch_id = 0;
    client->allow_spawn = TRUE;
    client->track_spawned_child = TRUE;
    client->terminate_spawned_on_clear = FALSE;
}

void cassotis_client_clear(CassotisClient *client)
{
    close_socket(client);
    if (client->terminate_spawned_on_clear)
        cassotis_client_stop_spawned_engine(client, NULL);
    g_clear_pointer(&client->socket_path, g_free);
    g_clear_pointer(&client->engine_path, g_free);
}

void cassotis_client_disconnect(CassotisClient *client)
{
    close_socket(client);
}

gboolean cassotis_client_prepare(CassotisClient *client, GError **error)
{
    return ensure_connected(client, error);
}

guint64 cassotis_client_connection_generation(const CassotisClient *client)
{
    return client->connection_generation;
}

void cassotis_client_set_terminate_spawned_on_clear(CassotisClient *client,
                                                    gboolean enabled)
{
    client->terminate_spawned_on_clear = enabled;
}

void cassotis_client_set_allow_spawn(CassotisClient *client,
                                     gboolean enabled)
{
    client->allow_spawn = enabled;
}

void cassotis_client_set_track_spawned_child(CassotisClient *client,
                                             gboolean enabled)
{
    client->track_spawned_child = enabled;
}

gboolean cassotis_client_create_context(CassotisClient *client,
                                        guint64 context_id,
                                        GError **error)
{
    return empty_request(client, CASSOTIS_MESSAGE_CREATE_CONTEXT, context_id,
                         0, error);
}

gboolean cassotis_client_destroy_context(CassotisClient *client,
                                         guint64 context_id,
                                         guint64 generation_id,
                                         GError **error)
{
    return empty_request(client, CASSOTIS_MESSAGE_DESTROY_CONTEXT, context_id,
                         generation_id, error);
}

gboolean cassotis_client_reset_context(CassotisClient *client,
                                       guint64 context_id,
                                       guint64 generation_id,
                                       GError **error)
{
    return empty_request(client, CASSOTIS_MESSAGE_RESET_CONTEXT, context_id,
                         generation_id, error);
}

gboolean cassotis_client_set_active(CassotisClient *client,
                                    guint64 context_id,
                                    guint64 generation_id,
                                    gboolean active,
                                    GError **error)
{
    guint64 request_id = client->next_request_id++;
    GByteArray *request = cassotis_protocol_build_set_active_request(
        request_id, context_id, generation_id, active);
    GByteArray *response = NULL;
    gboolean success = exchange(client, request, CASSOTIS_MESSAGE_SET_ACTIVE,
                                request_id, context_id, generation_id,
                                &response, error);
    if (response != NULL)
        g_byte_array_unref(response);
    return success;
}

gboolean cassotis_client_set_surrounding(CassotisClient *client,
                                         guint64 context_id,
                                         guint64 generation_id,
                                         const gchar *text,
                                         gint32 cursor_offset,
                                         GError **error)
{
    guint64 request_id = client->next_request_id++;
    GByteArray *request = cassotis_protocol_build_set_surrounding_request(
        request_id, context_id, generation_id, cursor_offset, text);
    GByteArray *response = NULL;
    gboolean success;
    if (request == NULL) {
        g_set_error_literal(error, cassotis_client_error_quark(), 1,
                            "invalid surrounding-text request");
        return FALSE;
    }
    success = exchange(client, request, CASSOTIS_MESSAGE_SET_SURROUNDING,
                       request_id, context_id, generation_id, &response,
                       error);
    if (response != NULL)
        g_byte_array_unref(response);
    return success;
}

gboolean cassotis_client_process_key(CassotisClient *client,
                                     guint64 context_id,
                                     guint64 generation_id,
                                     CassotisSpecialKey special_key,
                                     guint32 modifiers,
                                     guint32 scan_code,
                                     gboolean is_release,
                                     gboolean is_repeat,
                                     guint64 timestamp_ms,
                                     const gchar *text,
                                     CassotisEngineResult *result,
                                     GError **error)
{
    guint64 request_id = client->next_request_id++;
    GByteArray *request = cassotis_protocol_build_process_key_request(
        request_id, context_id, generation_id, special_key, modifiers,
        scan_code, is_release, is_repeat, timestamp_ms, text);
    GByteArray *response = NULL;
    if (!exchange(client, request, CASSOTIS_MESSAGE_ENGINE_RESULT, request_id,
                  context_id, generation_id, &response, error))
        return FALSE;
    if (!cassotis_protocol_decode_engine_result(response->data, response->len,
                                                result, error)) {
        g_byte_array_unref(response);
        close_socket(client);
        return FALSE;
    }
    g_byte_array_unref(response);
    return TRUE;
}

gboolean cassotis_client_get_state(CassotisClient *client,
                                   CassotisEngineState *state,
                                   GError **error)
{
    guint64 request_id = client->next_request_id++;
    GByteArray *request = cassotis_protocol_build_empty_request(
        CASSOTIS_MESSAGE_GET_STATE, request_id, 0, 0);
    GByteArray *response = NULL;
    if (!exchange(client, request, CASSOTIS_MESSAGE_GET_STATE, request_id,
                  0, 0, &response, error))
        return FALSE;
    if (!cassotis_protocol_decode_engine_state(response->data, response->len,
                                               state, error)) {
        g_byte_array_unref(response);
        close_socket(client);
        return FALSE;
    }
    g_byte_array_unref(response);
    return TRUE;
}

gboolean cassotis_client_set_state(CassotisClient *client,
                                   const CassotisEngineState *state,
                                   GError **error)
{
    guint64 request_id = client->next_request_id++;
    GByteArray *request = cassotis_protocol_build_set_state_request(
        request_id, state);
    GByteArray *response = NULL;
    gboolean success;
    if (request == NULL) {
        g_set_error_literal(error, cassotis_client_error_quark(), 1,
                            "invalid engine-state request");
        return FALSE;
    }
    success = exchange(client, request, CASSOTIS_MESSAGE_SET_STATE,
                       request_id, 0, 0, &response, error);
    if (response != NULL)
        g_byte_array_unref(response);
    return success;
}

gboolean cassotis_client_ping(CassotisClient *client, GError **error)
{
    guint64 request_id = client->next_request_id++;
    GByteArray *request = cassotis_protocol_build_empty_request(
        CASSOTIS_MESSAGE_PING, request_id, 0, 0);
    GByteArray *response = NULL;
    gboolean success = exchange(client, request, CASSOTIS_MESSAGE_PONG,
                                request_id, 0, 0, &response, error);
    if (response != NULL)
        g_byte_array_unref(response);
    return success;
}

gboolean cassotis_client_clear_user_dictionary(CassotisClient *client,
                                               GError **error)
{
    return empty_request(client, CASSOTIS_MESSAGE_CLEAR_USER_DICTIONARY,
                         0, 0, error);
}

gboolean cassotis_client_shutdown(CassotisClient *client, GError **error)
{
    return empty_request(client, CASSOTIS_MESSAGE_SHUTDOWN, 0, 0, error);
}
