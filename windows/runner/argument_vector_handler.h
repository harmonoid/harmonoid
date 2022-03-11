/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for
/// Harmonoid that can be found in the EULA.txt file.
///

#ifndef FLUTTER_PLUGIN_ARGUMENT_VECTOR_HANDLER_PLUGIN_H_
#define FLUTTER_PLUGIN_ARGUMENT_VECTOR_HANDLER_PLUGIN_H_

#include <flutter_plugin_registrar.h>

#if defined(__cplusplus)
extern "C" {
#endif

void ArgumentVectorHandlerPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar);

#if defined(__cplusplus)
}  // extern "C"
#endif

#endif  // FLUTTER_PLUGIN_ARGUMENT_VECTOR_HANDLER_PLUGIN_H_
