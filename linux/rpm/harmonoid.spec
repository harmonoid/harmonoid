Name:       harmonoid
Version:    0.3.4
Release:    1
Summary:    Plays & manages your music library. Looks beautiful & juicy.
License:    EULA
Requires:   mpv, mpv-libs-devel
AutoReqProv: no

%define __os_install_post %{nil}

%description
Plays & manages your music library. Looks beautiful & juicy.

%prep
# no source

%build
# no source

%install
export DONT_STRIP=1
mkdir -p %{buildroot}
cp -rf linux/debian/usr/ %{buildroot}

%files
FILES_HERE

%changelog
# no changelog
