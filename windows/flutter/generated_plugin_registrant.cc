//
//  Generated file. Do not edit.
//

#include "generated_plugin_registrant.h"

#include <bitsdojo_window_windows/bitsdojo_window_plugin.h>
#include <flutter_acrylic/flutter_acrylic_plugin.h>
#include <flutter_media_metadata/flutter_media_metadata_plugin.h>
#include <url_launcher_windows/url_launcher_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  BitsdojoWindowPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("BitsdojoWindowPlugin"));
  FlutterAcrylicPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterAcrylicPlugin"));
  FlutterMediaMetadataPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterMediaMetadataPlugin"));
  UrlLauncherPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherPlugin"));
}