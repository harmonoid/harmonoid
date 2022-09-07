/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

import 'dart:io';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import 'package:flutter/foundation.dart';

class WindowsInfo {
  static WindowsInfo instance = WindowsInfo._();

  OSVERSIONINFOEX? data;

  late bool isWindows10OrGreater;

  WindowsInfo._() {
    if (Platform.isWindows) {
      try {
        final pointer = calloc<OSVERSIONINFOEX>();
        pointer.ref
          ..dwOSVersionInfoSize = sizeOf<OSVERSIONINFOEX>()
          ..dwBuildNumber = 0
          ..dwMajorVersion = 0
          ..dwMinorVersion = 0
          ..dwPlatformId = 0
          ..szCSDVersion = ''
          ..wServicePackMajor = 0
          ..wServicePackMinor = 0
          ..wSuiteMask = 0
          ..wProductType = 0
          ..wReserved = 0;
        final rtlGetVersion = DynamicLibrary.open('ntdll.dll').lookupFunction<
            Void Function(Pointer<OSVERSIONINFOEX>),
            void Function(Pointer<OSVERSIONINFOEX>)>('RtlGetVersion');
        rtlGetVersion(pointer);
        data = pointer.ref;
        isWindows10OrGreater = pointer.ref.dwBuildNumber >= 10240;
      } catch (exception, stacktrace) {
        debugPrint(exception.toString());
        debugPrint(stacktrace.toString());
        isWindows10OrGreater = false;
      }
    } else {
      isWindows10OrGreater = false;
    }
  }
}
