/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for
/// Harmonoid that can be found in the EULA.txt file.
///

#ifndef FLUTTER_PLUGIN_OVERRIDE_WINDOW_DESTROY_PLUGIN_H_
#define FLUTTER_PLUGIN_OVERRIDE_WINDOW_DESTROY_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#define FLUTTER_PLUGIN_EXPORT
#endif

typedef struct _OverrideWindowDestroyPlugin OverrideWindowDestroyPlugin;
typedef struct {
  GObjectClass parent_class;
} OverrideWindowDestroyPluginClass;

FLUTTER_PLUGIN_EXPORT GType override_window_destroy_plugin_get_type();

FLUTTER_PLUGIN_EXPORT void
override_window_destroy_plugin_register_with_registrar(
    FlPluginRegistrar* registrar);

G_END_DECLS

#endif  // FLUTTER_PLUGIN_OVERRIDE_WINDOW_DESTROY_PLUGIN_H_
