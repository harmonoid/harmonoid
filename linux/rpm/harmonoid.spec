Name:       harmonoid
Version:    0.1.9-1 
Release:    1
Summary:    Elegant music app to play local music & YouTube music.
License:    GPL-3.0

%description
Elegant music app to play local music & YouTube music.
Distributes music into albums & artists.
Has playlists & lyrics.

%prep
# we have no source, so nothing here

%build
# already build using ci, so nothing here

%install
mkdir -p %{buildroot}
cp -rf linux/debian/usr/ %{buildroot}

%files
/usr/bin/data/flutter_assets/AssetManifest.json
/usr/bin/data/flutter_assets/FontManifest.json
/usr/bin/data/flutter_assets/NOTICES.Z
/usr/bin/data/flutter_assets/assets/images/about_header.jpg
/usr/bin/data/flutter_assets/assets/images/default_album_art.jpg
/usr/bin/data/flutter_assets/fonts/MaterialIcons-Regular.otf
/usr/bin/data/flutter_assets/fonts/Roboto/Roboto-Black.ttf
/usr/bin/data/flutter_assets/fonts/Roboto/Roboto-Bold.ttf
/usr/bin/data/flutter_assets/fonts/Roboto/Roboto-Light.ttf
/usr/bin/data/flutter_assets/fonts/Roboto/Roboto-Medium.ttf
/usr/bin/data/flutter_assets/fonts/Roboto/Roboto-Regular.ttf
/usr/bin/data/flutter_assets/fonts/Roboto/Roboto-Thin.ttf
/usr/bin/data/flutter_assets/packages/fluentui_system_icons/fonts/FluentSystemIcons-Filled.ttf
/usr/bin/data/flutter_assets/packages/fluentui_system_icons/fonts/FluentSystemIcons-Regular.ttf
/usr/bin/data/flutter_assets/version.json
/usr/bin/data/icudtl.dat
/usr/bin/harmonoid
/usr/bin/lib/libapp.so
/usr/bin/lib/libbitsdojo_window_linux_plugin.so
/usr/bin/lib/libdart_discord_rpc_plugin.so
/usr/bin/lib/libdiscord-rpc.so
/usr/bin/lib/libfile_selector_linux_plugin.so
/usr/bin/lib/libflutter_acrylic_plugin.so
/usr/bin/lib/libflutter_linux_gtk.so
/usr/bin/lib/libflutter_media_metadata_plugin.so
/usr/bin/lib/liblibwinmedia_plugin.so
/usr/bin/lib/liburl_launcher_linux_plugin.so
/usr/bin/lib/libwinmedia.so
/usr/share/applications/harmonoid.desktop
/usr/share/icons/hicolor/128x128/apps/harmonoid.png
/usr/share/icons/hicolor/256x256/apps/harmonoid.png
/usr/share/metainfo/harmonoid.appdata.xml

%changelog
# let's skip this for now
