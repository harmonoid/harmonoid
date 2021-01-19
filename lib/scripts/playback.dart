import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import 'package:harmonoid/main.dart';
import 'package:harmonoid/scripts/collection.dart';


class Playback {
  static Future<void> play({int index, List<Track> tracks}) async {
    await AudioService.start(
      backgroundTaskEntrypoint: backgroundTaskEntryPoint,
      androidNotificationChannelName: 'Harmonoid',
      androidNotificationColor: 0xFFFFFFFF,
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidStopForegroundOnPause: true,
      androidNotificationChannelDescription: 'Harmonoid' 
    );
    List<MediaItem> queue = new List<MediaItem>();
    for (Track track in tracks) {
      queue.add(
        MediaItem(
          id: track.filePath,
          title: track.trackName,
          album: track.albumName,
          artist: track.trackArtistNames.join(', '),
          artUri: 'file://${collection.getAlbumArt(track.albumArtId).path}',
          extras: track.toMap(),
        ),
      );
    }
    AudioService.updateQueue(queue);
    AudioService.playFromMediaId(queue[index].id);
  }
}


class BackgroundTask extends BackgroundAudioTask {
  AudioPlayer _audioPlayer;
  List<MediaItem> _audioPlayerQueue = new List<MediaItem>();
  List<int> _albumTrackNumbers = new List<int>();
  int _currentTrackIndex;
  
  @override
  Future<void> onPause() async {
    await this._audioPlayer.pause();
    await AudioServiceBackground.setState(
      playing: false,
      processingState: AudioProcessingState.completed,
      androidCompactActions: [0, 1, 2],
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: [
        MediaAction.seekTo,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      ],
      position: this._audioPlayer.position,
    );
  }

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    _audioPlayer = new AudioPlayer()..playerStateStream.listen(
      (state) {
        if (state.processingState == ProcessingState.completed) {
          AudioService.skipToNext();
        }
        if (state.processingState == ProcessingState.ready) {
          AudioServiceBackground.sendCustomEvent(['currentTrackDuration', this._audioPlayer.duration]);
          AudioServiceBackground.sendCustomEvent(['currentTrackQueue', [this._currentTrackIndex, this._audioPlayerQueue]]);
        }
    })..positionStream.listen((position) {
      AudioServiceBackground.sendCustomEvent(['playingTrackDuration', position]);
    })..playingStream.listen((playing) {
      AudioServiceBackground.sendCustomEvent(['playing', playing]);
    });
  }

  @override
  Future<dynamic> onCustomAction(String action, dynamic params) async {
    if (action == 'currentTrackDuration') {
      AudioServiceBackground.sendCustomEvent(['currentTrackDuration', this._audioPlayer.duration]);
    }
    if (action == 'playingTrackDuration') {
      AudioServiceBackground.sendCustomEvent(['playingTrackDuration', this._audioPlayer.position]);
    }
    if (action == 'currentTrackQueue') {
      AudioServiceBackground.sendCustomEvent(['currentTrackQueue', [this._currentTrackIndex, this._audioPlayerQueue]]);
    }
    if (action == 'currentTrackIndexSwitch') {
      this._currentTrackIndex = params;
      await AudioService.playMediaItem(_audioPlayerQueue[this._currentTrackIndex]);
    }
    if (action == 'isPlaying') {
      return this._audioPlayer.playing;
    }
  }

  @override
  Future<void> onSkipToPrevious() async {
    this._currentTrackIndex--;
    if (this._currentTrackIndex == -1) {
      this._currentTrackIndex = this._audioPlayerQueue.length - 1;
    }
    await AudioService.playMediaItem(_audioPlayerQueue[_currentTrackIndex]);
  }

  @override
  Future<void> onSkipToNext() async {
    this._currentTrackIndex++;
    if (this._currentTrackIndex == this._audioPlayerQueue.length) {
      this._currentTrackIndex = 0;
    }
    await AudioService.playMediaItem(_audioPlayerQueue[_currentTrackIndex]);
  }

  @override
  Future<void> onPlayFromMediaId(String mediaId) async {
    int currentTrackNumber;
    for (MediaItem mediaItem in this._audioPlayerQueue) {
      this._albumTrackNumbers.add(
        mediaItem.extras['trackNumber'],
      );
      if (mediaItem.id == mediaId) {
        currentTrackNumber = mediaItem.extras['trackNumber'];
        this._currentTrackIndex = this._albumTrackNumbers.indexOf(currentTrackNumber);
        await this._audioPlayer.setFilePath(mediaItem.extras['filePath']);
        await AudioServiceBackground.setMediaItem(mediaItem.copyWith(duration: this._audioPlayer.duration));
        await AudioServiceBackground.setState(
          playing: true,
          processingState: AudioProcessingState.completed,
          androidCompactActions: [0, 1, 2],
          controls: [
            MediaControl.skipToPrevious,
            MediaControl.pause,
            MediaControl.skipToNext
          ],
          systemActions: [
            MediaAction.seekTo,
            MediaAction.seekForward,
            MediaAction.seekBackward,
          ],
          position: this._audioPlayer.position,
        );
        await AudioService.play();
      }
    }
  }

  @override
  Future<void> onUpdateQueue(List<MediaItem> mediaItems) async {
    this._albumTrackNumbers = new List<int>();
    this._audioPlayerQueue = mediaItems;
  }

  @override
  Future<void> onSeekTo(Duration duration) async {
    await this._audioPlayer.seek(duration);
    await AudioServiceBackground.setState(
      playing: true,
      processingState: AudioProcessingState.completed,
      androidCompactActions: [0, 1, 2],
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.pause,
        MediaControl.skipToNext
      ],
      systemActions: [
        MediaAction.seekTo,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      ],
      position: this._audioPlayer.position,
    );
  }
  
  @override
  Future<void> onStop() async {
    super.onStop();
    await this._audioPlayer.stop();
  }

  @override
  Future<void> onPlay() async {
    this._audioPlayer.play();
    await AudioServiceBackground.setState(
      playing: true,
      processingState: AudioProcessingState.completed,
      androidCompactActions: [0, 1, 2],
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.pause,
        MediaControl.skipToNext
      ],
      systemActions: [
        MediaAction.seekTo,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      ],
      position: this._audioPlayer.position,
    );
    AudioServiceBackground.sendCustomEvent(['currentTrackQueue', [this._currentTrackIndex, this._audioPlayerQueue]]);
  }

  @override
  Future<void> onPlayMediaItem(MediaItem mediaItem) async {
    await this._audioPlayer.setFilePath(mediaItem.extras['filePath']);
    await AudioServiceBackground.setMediaItem(mediaItem.copyWith(duration: this._audioPlayer.duration));
    await AudioServiceBackground.setState(
      playing: true,
      processingState: AudioProcessingState.completed,
      androidCompactActions: [0, 1, 2],
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.pause,
        MediaControl.skipToNext
      ],
      systemActions: [
        MediaAction.seekTo,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      ],
      position: this._audioPlayer.position,
    );
    AudioService.play();
  }
}
