<h1 align="center"><a href="https://github.com/alexmercerind/harmonoid">Harmonoid</a></h1>
<h4 align="center">Elegant music app to play & manage music library (+ YouTube Music support)</h4>
<h3 align="center"><a href="https://github.com/harmonoid/harmonoid#download-1">Download [Windows & Linux]</a></h3>

Become a [supporter](#support) or [donate](#support)?

Join our [Discord server](https://discord.gg/2Rc3edFWd8)?

New Windows & Linux version is [live](https://github.com/harmonoid/harmonoid/releases/latest) 🎉. We are still working on Android refactor...

![](https://github.com/harmonoid/harmonoid/blob/assets/151304862-f4d336c6-4559-477b-b82e-a876f78f5eec.webp?raw=true)
![](https://github.com/harmonoid/harmonoid/blob/assets/151304870-6d1d18db-7120-43bd-87fa-9fa369244bfd.webp?raw=true)
![](https://github.com/harmonoid/harmonoid/blob/assets/151304875-dc120964-3b98-4460-beaf-d28c75b45109.webp?raw=true)
![](https://github.com/harmonoid/harmonoid/blob/assets/151304879-cdb10677-30c5-45bb-9e67-f520297280da.webp?raw=true)

## Motion

![](https://user-images.githubusercontent.com/28951144/151239401-be199319-0a22-4139-8bef-fe1edac2d576.gif)

## Download

### Windows

- <a href="https://github.com/harmonoid/harmonoid/releases/latest/download/harmonoid-windows-setup.exe">Setup</a>
- <a href="https://github.com/harmonoid/harmonoid/releases/latest/download/harmonoid-windows-exe.zip">Portable</a>
- winget install harmonoid

On Windows, [setup](https://github.com/harmonoid/harmonoid/releases/latest/download/harmonoid-windows-setup.exe) is recommended as it automatically links with files & file explorer context menus.

### Linux

- [.deb package](https://github.com/harmonoid/harmonoid/releases/latest/download/harmonoid-linux-x86_64.deb)
- [.rpm package](https://github.com/harmonoid/harmonoid/releases/latest/download/harmonoid-linux-x86_64.rpm)
- [AppImage](https://github.com/harmonoid/harmonoid/releases/latest/download/harmonoid-linux-x86_64.AppImage)
- [Raw Executable](https://github.com/harmonoid/harmonoid/releases/latest/download/harmonoid-linux-x86_64.tar.gz)
- flatpak install flathub io.github.harmonoid.harmonoid

On Debian or Ubuntu based distros, you need to install `mpv` & `libmpv-dev` to be able to install & run the app.

```bash
sudo apt install mpv libmpv-dev
sudo dpkg -i harmonoid-linux-x86_64.deb
```

Similar instructions can be followed on your favorite distro.

Big thanks to [@prateekmedia](https://github.com/prateekmedia) for setting up Linux packages & stuff.

### Android

- Coming Soon 😣.

## Features

- Powerful music library management based on metadata tags. Indexes music into group of albums & artists.
- Capable of indexing 20 files/second (on Windows) & saves cache for future app start-ups.
- Cross-platform (currently aiming Windows, Linux & Android).
- MPV based music playback for strong format support (on Linux & Windows) using `dart:ffi`.
- Taskbar & System Media Transport Controls for Windows.
- Small installer (< 25 MB) & low RAM usage (< 120 MB).
- Lyrics for all your music.
- Very strictly follows [Material Design](https://material.io/) guidelines for UI & animations.
- Ability to create persistent or "Now playing" playlists.
- Context menu integrations & file associations (exclusive to setup version).
- Discord RPC integration.
- Portable (if you wish).
- Does not use [electron.js](https://www.electronjs.org/).
- D-Bus MPRIS controls for Linux.

Upcoming features

- Mini-window mode [exclusive to [supporters](#support)].
- Minimization to system tray [exclusive to [supporters](#support)].
- Music visualizations [exclusive to [supporters](#support)].
- Tag editor [exclusive to [supporters](#support)].
- Time-synced lyrics [exclusive to [supporters](#support)].
- Importing playlists from YouTube & Spotify using Web API.
- Equalizer.
- Improvising YouTube support to be close to official web-client.
- Last.fm scrobbling.
- Plugin API.
- Windows 11 `IExplorerCommand` integration.
- Publishing to Microsoft Store & other places.
- Support for remaining macOS & iOS platforms.
- YOU Tell 😄

We are working hard to bring this new update to all platforms soon.

**NOTE:** Project is NEVER going to offer feature for downloading music from YouTube.

## Support

[PayPal](https://paypal.me/alexmercerind) • Please mention your email in the notes, so that you can get updates & stuff mailed!

Please note that above are the download links for free version of the app. You may donate/buy at [PayPal](https://paypal.me/alexmercerind) to:

- [5$] Get lifetime access to more awesome exclusive features like visuals, tag-editor & time-synced lyrics etc. (once available, but you can definitely speed us up!)
- [25$] Get lifetime license to [private](https://github.com/harmonoid/harmonoid/tree/master/external) Harmonoid plugin/libraries & use them in any commercial project for media playback, MPRIS integration, media parsing or whatever you find useful. 100% of Harmonoid's source code. Learn more [here](https://github.com/harmonoid/harmonoid-API-samples). Currently these plugins include:

<table>
   <tr>
     <td><a href='https://github.com/alexmercerind/libmpv.dart'>libmpv.dart</a></td>
     <td>Dart bindings to MPV media player's C API.</td>
     <td><a href='https://github.com/harmonoid/Harmonoid-API-Samples/tree/master/libmpv.dart'>API Examples</a></td>
   </tr>
  <tr>
     <td><a href='https://github.com/alexmercerind/mpris_service.dart'>mpris_service.dart</a></td>
     <td>Integrate D-Bus MPRIS controls in your Dart/Flutter app.</td>
     <td><a href='https://github.com/harmonoid/Harmonoid-API-Samples/tree/master/mpris_service.dart'>API Examples</a></td>
   </tr>
  <tr>
     <td><a href='https://github.com/alexmercerind/smtc-win32/tree/master/bindings/system_media_transport_controls.dart'>smtc.dart</a></td>
     <td>Modern UWP System Media Transport Controls for Dart/Flutter.</td>
     <td><a href='https://github.com/harmonoid/Harmonoid-API-Samples/tree/master/system_media_transport_controls.dart'>API Examples</a></td>
   </tr>
</table>

Appreciate your love & support for the project if you consider buying/donating.

## License

Source code and official releases/binaries are distributed under our [End-User License Agreement for Harmonoid (EULA)](./EULA.txt). Please check that there are modules/libraries in the source code that are proprietary to Harmonoid & present in the [external](./external) directory (at the time of commiting this file).

## Acknowlegements

- Harmonoid is (for the most part) written in Dart programming language using [Flutter SDK](https://github.com/flutter/flutter). Refrences to all the other external "plugins" & "packages" used at the time of building application can be found [here](./pubspec.yaml).

- Harmonoid uses a modified version of [libmpv](https://github.com/mpv-player/mpv/tree/master/libmpv) for media playback capabilities on desktop. The compilation setup & other information can be found [here](https://github.com/alexmercerind/harmonoid-custom-codec). The application bundles a minimal & LGPL compilant version of [mpv](https://github.com/mpv-player/mpv) shared library (`mpv-2.dll`). Users are free to update/change to their own preferred libmpv by replacing the `mpv-2.dll` file present in Harmonoid's application directory.

- [End-User License Agreement for Harmonoid (EULA)](./EULA.txt) is a slightly modified version of [End-User License Agreement for Aseprite (EULA)](https://github.com/aseprite/aseprite/blob/main/EULA.txt).

## Bonus

Well you've scrolled this down... How about seeing more stuff.

<img src='https://github.com/harmonoid/harmonoid/blob/assets/linux_full/4.jpeg?raw=true'></img>
<img src='https://github.com/harmonoid/harmonoid/blob/assets/windows_full/2.png?raw=true'></img>
<img src='https://github.com/harmonoid/harmonoid/blob/assets/windows_full/3.png?raw=true'></img>
<img src='https://github.com/harmonoid/harmonoid/blob/assets/windows_full/4.png?raw=true'></img>
<img src='https://github.com/harmonoid/harmonoid/blob/assets/windows_full/5.png?raw=true'></img>
<img src='https://github.com/harmonoid/harmonoid/blob/assets/linux_full/0.jpeg?raw=true'></img>
<img src='https://github.com/harmonoid/harmonoid/blob/assets/linux_full/1.jpeg?raw=true'></img>

## Contributors

<ul>
  <li>
    <img src='https://avatars.githubusercontent.com/u/28951144?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/alexmercerind'>Hitesh Kumar Saini</a></strong>
    <ul>
      <li>Lead developer. Deals with playback & indexing of music. Writes UI, state management & lifecycle code. Maintains native C++ plugins.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/64320078?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/raitonoberu'>Denis</a></strong>
    <ul>
      <li>Windows installer & major bug fixes. Russian translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/52399966?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/mytja'>mytja</a></strong>
    <ul>
      <li>WinGet package. Backward compatiblity checks. Bug reports. CI. Slovenian translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/41370460?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/prateekmedia'>Prateek SU</a></strong>
    <ul>
      <li>AppImage & Flatpak installers. Bug reports. Hindi translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://drive.google.com/uc?id=1eI-dHiALVQM123_HnQIcYe9HtbX0uS_W' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://www.instagram.com/shinybluebelll'>Bluebell</a></strong>
    <ul>
      <li>Artwork & iconography used in the application.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/45696119?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/bdlukaa'>Bruno D'Luka</a></strong>
    <ul>
      <li>User interface & design. Portuguese translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/43904633?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/gaetan1903'>Gaetan Jonathan BAKARY</a></strong>
    <ul>
      <li>Linux related bug-fixes. French translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/12989935?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/RedyAu'>Fodor Benedek</a></strong>
    <ul>
      <li>Hungarian translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/31634638?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/arafatamim'>Tamim Arafat</a></strong>
    <ul>
      <li>User interface & design. Bug reports.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/10137?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='mailto:max.haureus@gmail.com'>Max Haureus</a></strong>
    <ul>
      <li>Swedish translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/16196003?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/kebabinjeneus'>Lars</a></strong>
    <ul>
      <li>Dutch translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/47820557?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/MickLesk'>CanbiZ</a></strong>
    <ul>
      <li>German translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/8049534?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/ilopX'>ilopX</a></strong>
    <ul>
      <li>Testing & bug reports.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/56985621?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/7HAVEN'>Ankit Rana</a></strong>
    <ul>
      <li>Testing & bug reports.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/75587960?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/LeonHoog'>Leon</a></strong>
    <ul>
      <li>User interface fixes, app persistence improvements. Dutch translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/2262007?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/stonega'>stonegate</a></strong>
    <ul>
      <li>Mandarin translation & bug reports.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/66313777?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/HiSubway'>さぶうぇい</a></strong>
    <ul>
      <li>Japanese translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/66092540?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/TuranBerlin'>Yusuf Kamil Turan</a></strong>
    <ul>
      <li>Turkish translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/29723448?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/yulog'>yulog</a></strong>
    <ul>
      <li>Update Japanese translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/25613162?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/ejacquemoud'>ejacquemoud</a></strong>
    <ul>
      <li>Update French translation.</li>
    </ul>
  </li>
  <li>
    <img src='https://avatars.githubusercontent.com/u/11423362?s=80&v=4' height='28' width='28'></img>&nbsp;&nbsp;<strong><a href='https://github.com/maisondasilva'>Maison</a></strong>
    <ul>
      <li>Update Portuguese translation.</li>
    </ul>
  </li>
</ul>
