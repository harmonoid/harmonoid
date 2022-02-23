/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright (C) 2022 The Harmonoid Authors (see AUTHORS.md for details).
/// Copyright (C) 2021-2022 Hitesh Kumar Saini <saini123hitesh@gmail.com>.
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU Affero General Public License as
/// published by the Free Software Foundation, either version 3 of the
/// License, or (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU Affero General Public License for more details.
///
/// You should have received a copy of the GNU Affero General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
