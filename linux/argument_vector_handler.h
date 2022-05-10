/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for
/// Harmonoid that can be found in the EULA.txt file.
///

#ifndef ARGUMENT_VECTOR_HANDLER_H_
#define ARGUMENT_VECTOR_HANDLER_H_

#include <flutter_linux/flutter_linux.h>

struct _ArgumentVectorHandlerPlugin {
  GObject parent_instance;
  FlPluginRegistrar* registrar;
  FlMethodChannel* channel;
};

typedef struct _ArgumentVectorHandlerPlugin ArgumentVectorHandlerPlugin;
typedef struct {
  GObjectClass parent_class;
} ArgumentVectorHandlerPluginClass;

GType argument_vector_handler_plugin_get_type();

static ArgumentVectorHandlerPlugin* g_argument_vector_handler_plugin;

#define ARGUMENT_VECTOR_HANDLER_PLUGIN(obj)                              \
  (G_TYPE_CHECK_INSTANCE_CAST((obj),                                     \
                              argument_vector_handler_plugin_get_type(), \
                              ArgumentVectorHandlerPlugin))

G_DEFINE_TYPE(ArgumentVectorHandlerPlugin, argument_vector_handler_plugin,
              g_object_get_type())

static void argument_vector_handler_plugin_handle_method_call(
    ArgumentVectorHandlerPlugin* self, FlMethodCall* method_call) {
  fl_method_call_respond(
      method_call,
      FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_null())),
      nullptr);
}

static void argument_vector_handler_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(argument_vector_handler_plugin_parent_class)->dispose(object);
}

static void argument_vector_handler_plugin_class_init(
    ArgumentVectorHandlerPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = argument_vector_handler_plugin_dispose;
}

static void argument_vector_handler_plugin_init(
    ArgumentVectorHandlerPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  ArgumentVectorHandlerPlugin* plugin =
      ARGUMENT_VECTOR_HANDLER_PLUGIN(user_data);
  argument_vector_handler_plugin_handle_method_call(plugin, method_call);
}

void argument_vector_handler_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  g_argument_vector_handler_plugin = ARGUMENT_VECTOR_HANDLER_PLUGIN(
      g_object_new(argument_vector_handler_plugin_get_type(), nullptr));
  g_argument_vector_handler_plugin->registrar =
      FL_PLUGIN_REGISTRAR(g_object_ref(registrar));
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_argument_vector_handler_plugin->channel = fl_method_channel_new(
      fl_plugin_registrar_get_messenger(registrar),
      "com.alexmercerind.harmonoid/argument_vector_handler",
      FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      g_argument_vector_handler_plugin->channel, method_call_cb,
      g_object_ref(g_argument_vector_handler_plugin), g_object_unref);
  g_object_unref(g_argument_vector_handler_plugin);
}

#endif  // ARGUMENT_VECTOR_HANDLER_PLUGIN_H_
