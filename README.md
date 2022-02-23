# [Harmonoid](https://github.com/harmonoid/harmonoid)

**Elegant music app to play & manage music library**

- [Download](#download)
- [Discord](https://discord.gg/2Rc3edFWd8)
- [Features](#features)
- [Limitations](#limitations)
- [Contributing](#contributing)
- [License](#license)
- [Guide](#guide)
- [Authors](#authors)

![](https://github.com/harmonoid/harmonoid/blob/assets/151304862-f4d336c6-4559-477b-b82e-a876f78f5eec.webp?raw=true)
![](https://github.com/harmonoid/harmonoid/blob/assets/151304870-6d1d18db-7120-43bd-87fa-9fa369244bfd.webp?raw=true)
![](https://github.com/harmonoid/harmonoid/blob/assets/151304875-dc120964-3b98-4460-beaf-d28c75b45109.webp?raw=true)
![](https://github.com/harmonoid/harmonoid/blob/assets/151304879-cdb10677-30c5-45bb-9e67-f520297280da.webp?raw=true)

## Motion

![](https://user-images.githubusercontent.com/28951144/151239401-be199319-0a22-4139-8bef-fe1edac2d576.gif)

## Download

See [limitations](#limitations) first.

### Windows

- <a href="https://github.com/harmonoid/harmonoid/releases/latest/download/harmonoid-windows-setup.exe">Setup</a>
- <a href="https://github.com/harmonoid/harmonoid/releases/latest/download/harmonoid-windows-exe.zip">Portable</a>
- winget install harmonoid

On Windows, [setup](https://github.com/harmonoid/harmonoid/releases/latest/download/harmonoid-windows-setup.exe) is recommended as it automatically links with files & file explorer context menus.

### Linux

- [.deb](https://github.com/harmonoid/harmonoid/releases/latest/download/harmonoid-linux-x86_64.deb)
- [.rpm](https://github.com/harmonoid/harmonoid/releases/latest/download/harmonoid-linux-x86_64.rpm)
- [.tar.gz](https://github.com/harmonoid/harmonoid/releases/latest/download/harmonoid-linux-x86_64.tar.gz)

On Debian or Ubuntu based distros, you need to install `mpv` & `libmpv-dev` to be able to install & run the app.

```bash
sudo apt install mpv libmpv-dev
sudo dpkg -i harmonoid-linux-x86_64.deb
```

Similar instructions can be followed on your favorite distro.

### Android

- Coming Soon 😣.

## Features

#### Current features

- Powerful music library management based on metadata tags. Indexes music into group of albums & artists.
- Capable of indexing 20 files/second (on Windows) & saves cache for future app start-ups.
- Cross-platform (currently aiming Windows, Linux & Android).
- mpv based music playback for strong format support (on Linux & Windows) using `dart:ffi`.
- Taskbar & System Media Transport Controls for Windows.
- Small installer (< 25 MB) & ~~low RAM usage (< 120 MB)~~ (see [limitations](#limitations)).
- Lyrics for all your music.
- Very strictly follows [Material Design](https://material.io/) guidelines for UI & animations.
- Ability to create persistent or "Now playing" playlists.
- Context menu integrations & file associations (exclusive to setup version).
- Discord RPC integration.
- Portable (if you wish).
- Does not use [electron.js](https://www.electronjs.org/).
- D-Bus MPRIS controls for Linux.

#### Upcoming features

- Mini-window mode.
- Minimization to system tray.
- Music visualizations.
- Tag editor.
- Time-synced lyrics.
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

## Limitations

A lot of time has went into making this project possible using [Flutter](https://github.com/flutter/flutter) & nearly everything has been written from ground-up (from low-level C/C++ plugins to UI & business-logic in Flutter/Dart).

[Flutter](https://github.com/flutter/flutter) is quite new at the time for desktop & every new (even basic) functionality in the app is a research itself.

Nothing at the time is very stable & every new feature is a new discovery. Just have fun, learn & share your knowledge!

Few issues regarding memory usage alone can be:

- https://github.com/flutter/flutter/issues/73402
- https://github.com/flutter/flutter/issues/90547
- https://github.com/flutter/flutter/issues/92318
- https://github.com/flutter/flutter/issues/95092

In most cases as of now [Windows & Linux], memory usage will be really low at fresh start of the application & will continue to rise (although slowly) overtime with no specific reason.

## Contributing

You can contribute to the project by adding any of the features mentioned in the [upcoming features](#upcoming-features) or [fixing bugs](https://github.com/harmonoid/harmonoid/issues). If you're still confused then you can join our [Discord](https://discord.gg/2Rc3edFWd8) to find a direction.

## License

Source code and official releases/binaries are distributed under our [GNU Affero General Public License](./LICENSE). Please check that there are modules/libraries in the source code that are under separate licenses & present in the [external](./external) directory.

Copyright (C) 2022 [The Harmonoid Authors](./AUTHORS.md).

Copyright (C) 2021-2022 [Hitesh Kumar Saini](https://github.com/alexmercerind).

## Guide

### Keyboard shortcuts

- <kbd>Space</kbd>: Play or pause.
- <kbd>Alt</kbd> + <kbd>N</kbd>: Next song.
- <kbd>Alt</kbd> + <kbd>B</kbd>: Previous song.
- <kbd>Alt</kbd> + <kbd>M</kbd>: mute or un-mute.
- <kbd>Alt</kbd> + <kbd>V</kbd>: Volume increase.
- <kbd>Alt</kbd> + <kbd>C</kbd>: Volume decrease.
- <kbd>Alt</kbd> + <kbd>X</kbd>: Seek forwards.
- <kbd>Alt</kbd> + <kbd>Z</kbd>: Seek backwards.

### Indexing your music

To show your local music inside Harmonoid, you can go to the settings & click "ADD NEW FOLDER". This will show a new window, where you can select a folder where all your music is stored. After selecting the folder, your music collection inside the application will start building.

Your music will be categorized into albums, artists etc. & you'll be able to freely browse music album-wise or artist-wise etc. while being able to sort it alphabetically or year-wise etc.

Next time when you start the app, your music collection will be retrieved from the cache.

To remove a folder from your music collection, just click on "REMOVE" next to the folder you might wanna remove.

As of now, you can still browse/play your music while it is being indexed.

### Managing playback queue

By default, the app will attempt to play the song that you click on, while adding songs after it to the queue. To add more songs to the queue, simply right click on the new song & click "Add to now playing".

You can also configure to automatically play other songs from your collection when the queue is finished.

### Creating a playlist

To create a new playlist, you need to go the the "PLAYLISTS" tab & click "CREATE NEW PLAYLIST". This will ask you a name for your new shiny playlist. After its creation, you can click on your favorite song to add it to the required playlist. This can help you greatly organize your music collection.

You can add both local music & music from YouTube Music to these playlists.

### Playing songs from YouTube Music

Currently, YouTube Music support is very basic but it works _well_ in terms of performance & timing. Right now, you can:

- Play.
- Search.
- Get recommendations.
- Get suggestions.
- Add to playlist.

We intend to improve in future & you can contribute to this. Downloading is never going to be a feature inside the application.

### Viewing a YouTube Music song on website

If you're playing a song from YouTube Music & want to hear it on website instead, you can simply go to the "Now Playing Screen" by an arrow in the bottom-right corner of the application. Hovering over the album art, you'll see an icon hinting to open the song in your web-browser. Click on it & you're on YouTube Music website.

### Playing from file explorer

You can play music directly from file explorer if you installed Harmonoid using the setup installer or from Microsoft Store.

You can also right click a folder to "Add to Harmonoid's Playlist".

### Troubleshoot

If you encounter some problem like you're unable to start the app or see an error screen, you can try to delete the `.Harmonoid` folder in your home directory.
WARNING: This will also delete your music indexing cache & playlists. Best decision can be to report us at our Discord.

## Authors

See [AUTHORS.md](./AUTHORS.md) to get list of awesome people are working (or worked) on this app.

## Bonus

Well you've scrolled this down... How about seeing more ✨ _colorful_ ✨ stuff.

<img src='https://github.com/harmonoid/harmonoid/blob/assets/linux_full/4.jpeg?raw=true'></img>
<img src='https://github.com/harmonoid/harmonoid/blob/assets/windows_full/2.png?raw=true'></img>
<img src='https://github.com/harmonoid/harmonoid/blob/assets/windows_full/3.png?raw=true'></img>
<img src='https://github.com/harmonoid/harmonoid/blob/assets/windows_full/4.png?raw=true'></img>
<img src='https://github.com/harmonoid/harmonoid/blob/assets/windows_full/5.png?raw=true'></img>
<img src='https://github.com/harmonoid/harmonoid/blob/assets/linux_full/0.jpeg?raw=true'></img>
<img src='https://github.com/harmonoid/harmonoid/blob/assets/linux_full/1.jpeg?raw=true'></img>
