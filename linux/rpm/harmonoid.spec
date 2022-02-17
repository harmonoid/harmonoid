Name:       harmonoid
Version:    0.2.0-1
Release:    1
Summary:    Elegant music app to play local music & YouTube music.
License:    EULA
Requires:   mpv, mpv-libs-devel

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
FILES_HERE

%changelog
# let's skip this for now
