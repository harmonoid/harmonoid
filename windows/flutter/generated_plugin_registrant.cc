//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <awesome_notifications/awesome_notifications_plugin_c_api.h>
#include <dart_discord_rpc/dart_discord_rpc_plugin.h>
#include <flutter_platform_alert/flutter_platform_alert_plugin.h>
#include <url_launcher_windows/url_launcher_windows.h>
#include <window_plus/window_plus_plugin_c_api.h>
#include <windows_taskbar/windows_taskbar_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  AwesomeNotificationsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AwesomeNotificationsPluginCApi"));
  DartDiscordRpcPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DartDiscordRpcPlugin"));
  FlutterPlatformAlertPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterPlatformAlertPlugin"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
  WindowPlusPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowPlusPluginCApi"));
  WindowsTaskbarPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowsTaskbarPlugin"));
}
