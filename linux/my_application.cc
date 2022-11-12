// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
//
// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>. All
// rights reserved.
//
// Use of this source code is governed by the End-User License Agreement for
// Harmonoid that can be found in the EULA.txt file.
//
#include "my_application.h"

#include <flutter_linux/flutter_linux.h>

#include <locale>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include "flutter/generated_plugin_registrant.h"
#include "window_plus/window_plus_plugin.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// Creates a new MyApplication instance, a new window is created with a new
// Flutter engine & Dart entry point. The entry point arguments are taken from
// MyApplication::dart_entrypoint_arguments & passed to the Dart entry point.
//
// Does nothing if a window already exists.
static void my_application_window_new(GApplication* application) {
  std::setlocale(LC_NUMERIC, "C");
  MyApplication* self = MY_APPLICATION(application);
  // Check for an existing window. If one exists, present it and return.
  GList* windows = gtk_application_get_windows(GTK_APPLICATION(application));
  if (self && windows) {
    // Forward the argument vector to the existing window / process.
    window_plus_plugin_handle_single_instance(self->dart_entrypoint_arguments);
    gtk_window_present(GTK_WINDOW(windows->data));
    return;
  }
  // Create a new GtkWindow, Flutter engine & execute the Dart entry point.
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));
  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "Harmonoid");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, "Harmonoid");
  }

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(
      project, self->dart_entrypoint_arguments);
  FlView* view = fl_view_new(project);
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));
  gtk_widget_realize(GTK_WIDGET(view));
  gtk_widget_realize(GTK_WIDGET(window));
  fl_register_plugins(FL_PLUGIN_REGISTRY(view));
}

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  // MyApplication::dart_entrypoint_arguments handling.
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  self->dart_entrypoint_arguments = NULL;
  if (!g_application_get_is_registered(application)) {
    g_autoptr(GError) error = nullptr;
    if (!g_application_register(application, nullptr, &error)) {
      g_warning("Failed to register: %s", error->message);
    }
  }
  my_application_window_new(application);
}

// Implements GApplication::open.
static void my_application_open(GApplication* application, GFile** files,
                                gint n_files, const gchar* hint) {
  MyApplication* self = MY_APPLICATION(application);
  // MyApplication::dart_entrypoint_arguments handling.
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  self->dart_entrypoint_arguments = g_new0(gchar*, n_files + 1);
  for (int i = 0; i < n_files; i++) {
    self->dart_entrypoint_arguments[i] = g_file_get_path(files[i]);
  }
  // For safety.
  self->dart_entrypoint_arguments[n_files] = NULL;
  if (!g_application_get_is_registered(application)) {
    g_autoptr(GError) error = nullptr;
    if (!g_application_register(application, nullptr, &error)) {
      g_warning("Failed to register: %s", error->message);
    }
  }
  my_application_window_new(application);
}

// Implements GApplication::command_line.
static gboolean my_application_command_line(
    GApplication* application, GApplicationCommandLine* command_line) {
  MyApplication* self = MY_APPLICATION(application);
  // MyApplication::dart_entrypoint_arguments handling.
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  // Strip out the first argument as it is the binary name.
  gchar** arguments =
      g_application_command_line_get_arguments(command_line, nullptr) + 1;
  self->dart_entrypoint_arguments = g_strdupv(arguments);
  if (!g_application_get_is_registered(application)) {
    g_autoptr(GError) error = nullptr;
    if (!g_application_register(application, nullptr, &error)) {
      g_warning("Failed to register: %s", error->message);
    }
  }
  my_application_window_new(application);
  return FALSE;
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->open = my_application_open;
  G_APPLICATION_CLASS(klass)->command_line = my_application_command_line;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  return MY_APPLICATION(g_object_new(
      my_application_get_type(), "application-id", APPLICATION_ID, "flags",
      G_APPLICATION_HANDLES_COMMAND_LINE | G_APPLICATION_HANDLES_OPEN,
      nullptr));
}
