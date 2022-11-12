// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
//
// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>. All
// rights reserved.
//
// Use of this source code is governed by the End-User License Agreement for
// Harmonoid that can be found in the EULA.txt file.
//
#ifndef FLUTTER_MY_APPLICATION_H_
#define FLUTTER_MY_APPLICATION_H_

#include <gtk/gtk.h>

G_DECLARE_FINAL_TYPE(MyApplication, my_application, MY, APPLICATION,
                     GtkApplication)

MyApplication* my_application_new();

#endif
