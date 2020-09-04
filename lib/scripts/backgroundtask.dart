import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';


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
        MediaControl.skipToNext
      ],
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
    // print('Current Track Index: ' + this._currentTrackIndex.toString());
    // print('Album Track Numbers: ' + this._albumTrackNumbers.toString());
    // print('Audio Player Queue : ' + this._audioPlayerQueue.toString());
    this._currentTrackIndex--;
    if (this._currentTrackIndex == -1) {
      this._currentTrackIndex = this._audioPlayerQueue.length - 1;
    }
    await AudioService.playMediaItem(_audioPlayerQueue[_currentTrackIndex]);
  }

  @override
  Future<void> onSkipToNext() async {
    // print('Current Track Index: ' + this._currentTrackIndex.toString());
    // print('Album Track Numbers: ' + this._albumTrackNumbers.toString());
    // print('Audio Player Queue : ' + this._audioPlayerQueue.toString());
    this._currentTrackIndex++;
    if (this._currentTrackIndex == this._audioPlayerQueue.length) {
      this._currentTrackIndex = 0;
    }
    await AudioService.playMediaItem(_audioPlayerQueue[_currentTrackIndex]);
  }

  @override
  Future<void> onPlayFromMediaId(String mediaId) async {
    
    // print('Media ID required: ' + mediaId);

    int currentTrackNumber;

    for (MediaItem mediaItem in this._audioPlayerQueue) {
      // print('Media ID found  : ' + mediaItem.id);
      this._albumTrackNumbers.add(
        mediaItem.extras['track_number'],
      );
      if (mediaItem.id == mediaId) {
        currentTrackNumber = mediaItem.extras['track_number'];
        await this._audioPlayer.setFilePath(mediaItem.extras['track_path']);
        await AudioServiceBackground.setMediaItem(mediaItem);
        await AudioServiceBackground.setState(
          playing: true,
          processingState: AudioProcessingState.completed,
          androidCompactActions: [0, 1, 2],
          controls: [
            MediaControl.skipToPrevious,
            MediaControl.pause,
            MediaControl.skipToNext
          ],
        );
        await AudioService.play();
      }
    }
  
    this._currentTrackIndex = this._albumTrackNumbers.indexOf(currentTrackNumber);
  }

  @override
  Future<void> onUpdateQueue(List<MediaItem> mediaItems) async {
    this._audioPlayerQueue = new List<MediaItem>();
    this._albumTrackNumbers = new List<int>();

    this._audioPlayerQueue = mediaItems;
  }

  @override
  Future<void> onSeekTo(Duration duration) async {
    this._audioPlayer.seek(duration);
  }
  
  @override
  Future<void> onStop() async {
    super.onStop();
    await this._audioPlayer.stop();
    print('Audio service is stopped.');
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
    );
  }

  @override
  Future<void> onPlayMediaItem(MediaItem mediaItem) async {
    this._audioPlayer.setFilePath(mediaItem.extras['track_path']);
    await AudioServiceBackground.setMediaItem(mediaItem);
    await AudioServiceBackground.setState(
      playing: true,
      processingState: AudioProcessingState.completed,
      androidCompactActions: [0, 1, 2],
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.pause,
        MediaControl.skipToNext
      ],
    );
    AudioService.play();
  }
}