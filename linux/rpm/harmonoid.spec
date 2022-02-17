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
FILES_HERE

%changelog
# let's skip this for now
