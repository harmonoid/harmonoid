/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for
/// Harmonoid that can be found in the EULA.txt file.
///

#ifndef WINDOW_UTILS_H_
#define WINDOW_UTILS_H_

#include <flutter_linux/flutter_linux.h>

struct _WindowUtilsPlugin {
  GObject parent_instance;
  FlPluginRegistrar* registrar;
  FlMethodChannel* channel;
};

typedef struct _WindowUtilsPlugin WindowUtilsPlugin;
typedef struct {
  GObjectClass parent_class;
} WindowUtilsPluginClass;

GType window_utils_plugin_get_type();

#define WINDOW_UTILS_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), window_utils_plugin_get_type(), \
                              WindowUtilsPlugin))

G_DEFINE_TYPE(WindowUtilsPlugin, window_utils_plugin, g_object_get_type())

static void window_utils_plugin_handle_method_call(WindowUtilsPlugin* self,
                                                   FlMethodCall* method_call) {
  const gchar* method_name = fl_method_call_get_name(method_call);
  g_autoptr(FlMethodResponse) response = nullptr;
  if (strcmp(method_name, "notify_run_app") == 0) {
    GtkWidget* view = GTK_WIDGET(fl_plugin_registrar_get_view(self->registrar));
    GtkWidget* window = gtk_widget_get_toplevel(view);
    gtk_widget_show(view);
    gtk_widget_show(window);
    response =
        FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_null()));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }
  fl_method_call_respond(method_call, response, nullptr);
}

static void window_utils_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(window_utils_plugin_parent_class)->dispose(object);
}

static void window_utils_plugin_class_init(WindowUtilsPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = window_utils_plugin_dispose;
}

static void window_utils_plugin_init(WindowUtilsPlugin* self) {}

static void window_utils_callback(FlMethodChannel* channel,
                                  FlMethodCall* method_call,
                                  gpointer user_data) {
  WindowUtilsPlugin* plugin = WINDOW_UTILS_PLUGIN(user_data);
  window_utils_plugin_handle_method_call(plugin, method_call);
}

void window_utils_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  WindowUtilsPlugin* plugin = WINDOW_UTILS_PLUGIN(
      g_object_new(window_utils_plugin_get_type(), nullptr));
  plugin->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  plugin->channel = fl_method_channel_new(
      fl_plugin_registrar_get_messenger(registrar),
      "com.alexmercerind.harmonoid/window_utils", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      plugin->channel, window_utils_callback, g_object_ref(plugin),
      g_object_unref);
  g_object_unref(plugin);
}

#endif  // WINDOW_UTILS_PLUGIN_H_
