//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <awesome_notifications/awesome_notifications_plugin.h>
#include <dart_discord_rpc/dart_discord_rpc_plugin.h>
#include <file_selector_linux/file_selector_plugin.h>
#include <flutter_platform_alert/flutter_platform_alert_plugin.h>
#include <url_launcher_linux/url_launcher_plugin.h>
#include <window_plus/window_plus_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) awesome_notifications_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "AwesomeNotificationsPlugin");
  awesome_notifications_plugin_register_with_registrar(awesome_notifications_registrar);
  g_autoptr(FlPluginRegistrar) dart_discord_rpc_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "DartDiscordRpcPlugin");
  dart_discord_rpc_plugin_register_with_registrar(dart_discord_rpc_registrar);
  g_autoptr(FlPluginRegistrar) file_selector_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FileSelectorPlugin");
  file_selector_plugin_register_with_registrar(file_selector_linux_registrar);
  g_autoptr(FlPluginRegistrar) flutter_platform_alert_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FlutterPlatformAlertPlugin");
  flutter_platform_alert_plugin_register_with_registrar(flutter_platform_alert_registrar);
  g_autoptr(FlPluginRegistrar) url_launcher_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "UrlLauncherPlugin");
  url_launcher_plugin_register_with_registrar(url_launcher_linux_registrar);
  g_autoptr(FlPluginRegistrar) window_plus_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "WindowPlusPlugin");
  window_plus_plugin_register_with_registrar(window_plus_registrar);
}
