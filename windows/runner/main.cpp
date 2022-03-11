#include <Windows.h>
#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>

#include <thread>

#include <bitsdojo_window_windows/bitsdojo_window_plugin.h>

#include "flutter_window.h"
#include "utils.h"

auto bdw = bitsdojo_window_configure(BDW_CUSTOM_FRAME | BDW_HIDE_ON_STARTUP);

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t* command_line, _In_ int show_command) {
  HWND hwnd = ::FindWindow(L"FLUTTER_RUNNER_WIN32_WINDOW", L"Harmonoid");
  if (hwnd != NULL) {
    ::ShowWindow(hwnd, SW_NORMAL);
    ::SetForegroundWindow(hwnd);
    std::vector<std::string> command_line_arguments = GetCommandLineArguments();
    if (!command_line_arguments.empty()) {
      // TODO: Only sends first argument currently.
      COPYDATASTRUCT cds;
      cds.dwData = 1;
      cds.cbData =
          static_cast<DWORD>(command_line_arguments.front().size() + 1);
      cds.lpData = reinterpret_cast<void*>(
          const_cast<char*>(command_line_arguments.front().c_str()));
      ::SendMessageW(hwnd, WM_COPYDATA, NULL, (LPARAM)&cds);
    }
    std::this_thread::sleep_for(std::chrono::seconds(10));
    return EXIT_FAILURE;
  }
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
  flutter::DartProject project(L"data");
  std::vector<std::string> command_line_arguments = GetCommandLineArguments();
  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));
  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.CreateAndShow(L"Harmonoid", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);
  MSG msg;
  while (GetMessage(&msg, nullptr, 0, 0)) {
    TranslateMessage(&msg);
    DispatchMessage(&msg);
  }
  ::CoUninitialize();
  return EXIT_SUCCESS;
}
