#ifndef CASSOTIS_CLIENT_H
#define CASSOTIS_CLIENT_H

#include "cassotis_protocol.h"

#include <glib.h>

G_BEGIN_DECLS

typedef struct {
    gint socket_fd;
    guint64 next_request_id;
    guint64 connection_generation;
    gchar *socket_path;
    gchar *engine_path;
    GPid spawned_pid;
    guint child_watch_id;
    gboolean allow_spawn;
    gboolean track_spawned_child;
    gboolean terminate_spawned_on_clear;
} CassotisClient;

GQuark cassotis_client_error_quark(void);

void cassotis_client_init(CassotisClient *client,
                          const gchar *socket_path,
                          const gchar *engine_path);
void cassotis_client_disconnect(CassotisClient *client);
gboolean cassotis_client_prepare(CassotisClient *client, GError **error);
guint64 cassotis_client_connection_generation(const CassotisClient *client);
void cassotis_client_clear(CassotisClient *client);
void cassotis_client_set_terminate_spawned_on_clear(CassotisClient *client,
                                                    gboolean enabled);
void cassotis_client_set_allow_spawn(CassotisClient *client,
                                     gboolean enabled);
void cassotis_client_set_track_spawned_child(CassotisClient *client,
                                             gboolean enabled);
gboolean cassotis_client_stop_spawned_engine(CassotisClient *client,
                                             GError **error);

gboolean cassotis_client_create_context(CassotisClient *client,
                                        guint64 context_id,
                                        GError **error);
gboolean cassotis_client_destroy_context(CassotisClient *client,
                                         guint64 context_id,
                                         guint64 generation_id,
                                         GError **error);
gboolean cassotis_client_reset_context(CassotisClient *client,
                                       guint64 context_id,
                                       guint64 generation_id,
                                       GError **error);
gboolean cassotis_client_set_active(CassotisClient *client,
                                    guint64 context_id,
                                    guint64 generation_id,
                                    gboolean active,
                                    GError **error);
gboolean cassotis_client_set_surrounding(CassotisClient *client,
                                         guint64 context_id,
                                         guint64 generation_id,
                                         const gchar *text,
                                         gint32 cursor_offset,
                                         GError **error);
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
                                     GError **error);
gboolean cassotis_client_get_state(CassotisClient *client,
                                   CassotisEngineState *state,
                                   GError **error);
gboolean cassotis_client_set_state(CassotisClient *client,
                                   const CassotisEngineState *state,
                                   GError **error);
gboolean cassotis_client_clear_user_dictionary(CassotisClient *client,
                                               GError **error);
gboolean cassotis_client_ping(CassotisClient *client, GError **error);
gboolean cassotis_client_shutdown(CassotisClient *client, GError **error);

G_END_DECLS

#endif
