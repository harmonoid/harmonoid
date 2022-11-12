// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
//
// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>. All
// rights reserved.
//
// Use of this source code is governed by the End-User License Agreement for
// Harmonoid that can be found in the EULA.txt file.
//
#include "my_application.h"

int main(int argc, char** argv) {
  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
