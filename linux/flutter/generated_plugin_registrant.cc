//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <bitsdojo_window_linux/bitsdojo_window_plugin.h>
#include <dart_discord_rpc/dart_discord_rpc_plugin.h>
#include <file_selector_linux/file_selector_plugin.h>
#include <flutter_acrylic/flutter_acrylic_plugin.h>
#include <flutter_media_metadata/flutter_media_metadata_plugin.h>
#include <libwinmedia/libwinmedia_plugin.h>
#include <url_launcher_linux/url_launcher_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) bitsdojo_window_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "BitsdojoWindowPlugin");
  bitsdojo_window_plugin_register_with_registrar(bitsdojo_window_linux_registrar);
  g_autoptr(FlPluginRegistrar) dart_discord_rpc_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "DartDiscordRpcPlugin");
  dart_discord_rpc_plugin_register_with_registrar(dart_discord_rpc_registrar);
  g_autoptr(FlPluginRegistrar) file_selector_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FileSelectorPlugin");
  file_selector_plugin_register_with_registrar(file_selector_linux_registrar);
  g_autoptr(FlPluginRegistrar) flutter_acrylic_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FlutterAcrylicPlugin");
  flutter_acrylic_plugin_register_with_registrar(flutter_acrylic_registrar);
  g_autoptr(FlPluginRegistrar) flutter_media_metadata_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FlutterMediaMetadataPlugin");
  flutter_media_metadata_plugin_register_with_registrar(flutter_media_metadata_registrar);
  g_autoptr(FlPluginRegistrar) libwinmedia_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "LibwinmediaPlugin");
  libwinmedia_plugin_register_with_registrar(libwinmedia_registrar);
  g_autoptr(FlPluginRegistrar) url_launcher_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "UrlLauncherPlugin");
  url_launcher_plugin_register_with_registrar(url_launcher_linux_registrar);
}
