/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for
/// Harmonoid that can be found in the EULA.txt file.
///

#include "include/override_window_destroy/override_window_destroy_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>
#include <iostream>

#define OVERRIDE_WINDOW_DESTROY_PLUGIN(obj)                              \
  (G_TYPE_CHECK_INSTANCE_CAST((obj),                                     \
                              override_window_destroy_plugin_get_type(), \
                              OverrideWindowDestroyPlugin))

struct _OverrideWindowDestroyPlugin {
  GObject parent_instance;
  FlPluginRegistrar* registrar;
  FlMethodChannel* channel;
  gboolean is_delete_event_detected = FALSE;
};

G_DEFINE_TYPE(OverrideWindowDestroyPlugin, override_window_destroy_plugin,
              g_object_get_type())

static inline GtkWindow* get_window(OverrideWindowDestroyPlugin* self) {
  FlView* view = fl_plugin_registrar_get_view(self->registrar);
  if (view == nullptr) return nullptr;
  return GTK_WINDOW(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

static gboolean delete_event_callback(GtkWidget* widget, GdkEvent* event,
                                      gpointer data) {
  fl_method_channel_invoke_method(((OverrideWindowDestroyPlugin*)data)->channel,
                                  "destroy_window", fl_value_new_null(),
                                  nullptr, nullptr, nullptr);
  ((OverrideWindowDestroyPlugin*)data)->is_delete_event_detected = TRUE;
  return !((OverrideWindowDestroyPlugin*)data)->is_delete_event_detected;
}

static void override_window_destroy_plugin_handle_method_call(
    OverrideWindowDestroyPlugin* self, FlMethodCall* method_call) {
  gtk_window_close(get_window(self));
  fl_method_call_respond(
      method_call,
      FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_null())),
      nullptr);
}

static void override_window_destroy_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(override_window_destroy_plugin_parent_class)->dispose(object);
}

static void override_window_destroy_plugin_class_init(
    OverrideWindowDestroyPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = override_window_destroy_plugin_dispose;
}

static void override_window_destroy_plugin_init(
    OverrideWindowDestroyPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  OverrideWindowDestroyPlugin* plugin =
      OVERRIDE_WINDOW_DESTROY_PLUGIN(user_data);
  override_window_destroy_plugin_handle_method_call(plugin, method_call);
}

void override_window_destroy_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  OverrideWindowDestroyPlugin* plugin = OVERRIDE_WINDOW_DESTROY_PLUGIN(
      g_object_new(override_window_destroy_plugin_get_type(), nullptr));
  plugin->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  plugin->channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "override_window_destroy", FL_METHOD_CODEC(codec));
  g_signal_connect(get_window(plugin), "delete-event",
                   G_CALLBACK(delete_event_callback), plugin);
  fl_method_channel_set_method_call_handler(
      plugin->channel, method_call_cb, g_object_ref(plugin), g_object_unref);
  g_object_unref(plugin);
}
