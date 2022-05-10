/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for
/// Harmonoid that can be found in the EULA.txt file.
///

#pragma once

#include "argument_vector_handler.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

namespace {

class ArgumentVectorHandlerPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  ArgumentVectorHandlerPlugin(flutter::PluginRegistrarWindows* registrar);

  virtual ~ArgumentVectorHandlerPlugin();

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  std::string GetErrorString(std::string method_name);

  flutter::PluginRegistrarWindows* registrar_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
};

void ArgumentVectorHandlerPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<ArgumentVectorHandlerPlugin>(registrar);
  registrar->AddPlugin(std::move(plugin));
}

ArgumentVectorHandlerPlugin::ArgumentVectorHandlerPlugin(
    flutter::PluginRegistrarWindows* registrar)
    : registrar_(registrar) {
  channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      registrar_->messenger(),
      "com.alexmercerind.harmonoid/argument_vector_handler",
      &flutter::StandardMethodCodec::GetInstance());
  channel_->SetMethodCallHandler([this](const auto& call, auto result) {
    HandleMethodCall(call, std::move(result));
  });
  registrar_->RegisterTopLevelWindowProcDelegate([=](HWND hwnd, UINT message,
                                                     WPARAM wparam,
                                                     LPARAM lparam)
                                                     -> std::optional<HRESULT> {
    {
      switch (message) {
        case WM_COPYDATA: {
          channel_->InvokeMethod(
              std::string(),
              std::make_unique<flutter::EncodableValue>(
                  flutter::EncodableValue(std::string(static_cast<char*>(
                      reinterpret_cast<COPYDATASTRUCT*>(lparam)->lpData)))));
        }
        default:
          break;
      }
      return std::nullopt;
    }
  });
}

ArgumentVectorHandlerPlugin::~ArgumentVectorHandlerPlugin() {}

void ArgumentVectorHandlerPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  result->NotImplemented();
}
}  // namespace

void ArgumentVectorHandlerPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  ArgumentVectorHandlerPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
