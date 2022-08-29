/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for
/// Harmonoid that can be found in the EULA.txt file.
///
#include "my_application.h"

#include <iostream>
#include <locale>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif
#include <flutter_linux/flutter_linux.h>

#include "argument_vector_handler.h"
#include "flutter/generated_plugin_registrant.h"
#include "window_utils.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

static void my_application_window_new(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));
  // Note that |gtk_widget_set_opacity| & |gtk_widget_set_sensitive| works after
  // |gtk_widget_show| call, thus present down below this imperative code.
  // Apparently, they are not supported by all window managers aswell, so that's
  // handled too. In that case, only |gtk_window_iconify| is relied upon.

  // Use a header bar when running in GNOME as this is the common style used by
  // applications and is the setup most users will be using (e.g. Ubuntu
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
  GdkRectangle workarea = {0};
  GdkDisplay* default_display = gdk_display_get_default();
  GdkMonitor* primary_monitor =
      gdk_display_get_primary_monitor(default_display);
  gdk_monitor_get_workarea(primary_monitor, &workarea);
  gboolean is_full_hd_display = workarea.width > 1366 && workarea.height > 768;
  gint base_width = is_full_hd_display ? 1280 : 1024,
       base_height = is_full_hd_display ? 720 : 640;
  // Configure default & minimum window dimensions etc.
  gtk_window_set_default_size(window, base_width, base_height);
  GdkGeometry geometry;
  geometry.min_width = 960;
  geometry.min_height = 640;
  geometry.base_width = base_width;
  geometry.base_height = base_height;
  gtk_window_set_geometry_hints(
      window, GTK_WIDGET(window), &geometry,
      static_cast<GdkWindowHints>(GDK_HINT_MIN_SIZE | GDK_HINT_BASE_SIZE));
  g_autoptr(GtkCssProvider) style = gtk_css_provider_new();
  gtk_css_provider_load_from_data(GTK_CSS_PROVIDER(style),
                                  "window { background:none; }", -1, nullptr);
  gtk_style_context_add_provider_for_screen(
      screen, GTK_STYLE_PROVIDER(style),
      GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(
      project, self->dart_entrypoint_arguments);
  FlView* view = fl_view_new(project);
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));
  gtk_widget_realize(GTK_WIDGET(view));
  gtk_widget_realize(GTK_WIDGET(window));
  auto registry = FL_PLUGIN_REGISTRY(view);
  fl_register_plugins(registry);
  window_utils_plugin_register_with_registrar(
      fl_plugin_registry_get_registrar_for_plugin(registry,
                                                  "WindowUtilsPlugin"));
  argument_vector_handler_plugin_register_with_registrar(
      fl_plugin_registry_get_registrar_for_plugin(
          registry, "ArgumentVectorHandlerPlugin"));
  std::setlocale(LC_NUMERIC, "C");
}

static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GList* list;
  list = gtk_application_get_windows(GTK_APPLICATION(self));
  if (list) {
    gtk_window_present(GTK_WINDOW(list->data));
  } else {
    my_application_window_new(application);
  }
}

static void my_application_open(GApplication* application, GFile** files,
                                gint n_files, const gchar* hint) {
  MyApplication* self = MY_APPLICATION(application);
  GList* list;
  if (self->dart_entrypoint_arguments) {
    g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  }
  self->dart_entrypoint_arguments = g_new(gchar*, n_files + 1);
  for (int32_t i = 0; i < n_files; i++) {
    self->dart_entrypoint_arguments[i] = g_strdup(g_file_get_path(files[i]));
  }
  self->dart_entrypoint_arguments[n_files] = nullptr;
  list = gtk_application_get_windows(GTK_APPLICATION(self));
  if (list) {
    gtk_window_present(GTK_WINDOW(list->data));
    std::cout << g_argument_vector_handler_plugin << std::endl;
    fl_method_channel_invoke_method(
        g_argument_vector_handler_plugin->channel, "",
        fl_value_new_string(self->dart_entrypoint_arguments[0]), nullptr,
        nullptr, nullptr);
  } else {
    my_application_window_new(application);
  }
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
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID, "flags",
                                     G_APPLICATION_HANDLES_OPEN, nullptr));
}
