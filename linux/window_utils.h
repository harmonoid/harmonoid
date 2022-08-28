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

GtkWidget* get_window(WindowUtilsPlugin* self) {
  FlView* view = fl_plugin_registrar_get_view(self->registrar);
  if (view == nullptr) return nullptr;

  return gtk_widget_get_toplevel(GTK_WIDGET(view));
}

GType window_utils_plugin_get_type();

#define WINDOW_UTILS_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), window_utils_plugin_get_type(), \
                              WindowUtilsPlugin))

G_DEFINE_TYPE(WindowUtilsPlugin, window_utils_plugin, g_object_get_type())

static void window_utils_plugin_handle_method_call(WindowUtilsPlugin* self,
                                                   FlMethodCall* method_call) {
  const gchar* method_name = fl_method_call_get_name(method_call);
  g_autoptr(FlMethodResponse) response = nullptr;
  GtkWidget* window = get_window(self);
  if (strcmp(method_name, "notify_first_frame_rasterized") == 0) {
    if (gdk_screen_is_composited(gtk_widget_get_screen(window))) {
      gtk_window_deiconify(GTK_WINDOW(window));
      gtk_widget_hide(window);
      gtk_widget_set_opacity(window, 1.0);
      gtk_widget_set_sensitive(window, true);
      gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_NONE);
      gtk_widget_show(window);
      gtk_widget_grab_focus(window);
    }
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
