Name:       harmonoid
Version:    0.3.1
Release:    1
Summary:    Plays & manages your music library. Looks beautiful & juicy.
License:    EULA
Requires:   mpv, mpv-libs-devel
AutoReqProv: no

%description
Plays & manages your music library. Looks beautiful & juicy.

%prep
# no source

%build
# no source

%install
mkdir -p %{buildroot}
cp -rf linux/debian/usr/ %{buildroot}

%files
FILES_HERE

%changelog
# no changelog
