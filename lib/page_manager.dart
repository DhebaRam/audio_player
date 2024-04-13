import 'package:flutter/foundation.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'notifiers/repeat_button_notifier.dart';
import 'package:audio_service/audio_service.dart';
import 'services/playlist_repository.dart';
import 'services/service_locator.dart';

class PageManager {
  // Listeners: Updates going to the UI
  final currentSongTitleNotifier = ValueNotifier<String>('');
  final currentSongImageNotifier = ValueNotifier<String>('');
  final playlistNotifier = ValueNotifier<List<String>>([]);
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);

  final _audioHandler = getIt<AudioHandler>();

  // Events: Calls coming from the UI
  void init() async {
    await _loadPlaylist();
    _listenToChangesInPlaylist();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
  }

  Future<void> _loadPlaylist() async {
    // final songRepository = getIt<PlaylistRepository>();
    // final playlist = await songRepository.fetchInitialPlaylist();
    // final mediaItems = playlist
    //     .map((song) => MediaItem(
    //           id: song['id'] ?? '',
    //           album: song['album'] ?? '',
    //           title: song['title'] ?? '',
    //           extras: {'url': song['url']},
    //         ))
    //     .toList();

    List<MediaItem> songList = [
      MediaItem(
        id: 'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3',
        album: 'XYZ',
        title: 'title',
        artUri: Uri.parse('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRIcm62olyo-OUTS6uoFbUFpBaOOjTxbL7Iqw&s'),
        extras: {
          'url': 'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3'
        },
      ),
      MediaItem(
        id: 'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
        album: 'ABC',
        title: 'title1',
        artUri: Uri.parse('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTvH6PyrTelDxGYwhABBdicwc8yrVSXi31CpP0GwEPwb7ykWJnNwKLfFuP6DNq2cTuvZM0&usqp=CAU'),
        extras: {
          'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'
        },
      ),
      MediaItem(
        id: 'https://commondatastorage.googleapis.com/codeskulptor-assets/sounddogs/explosion.mp3',
        album: 'AB',
        title: 'title2',
        artUri: Uri.parse('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTvH6PyrTelDxGYwhABBdicwc8yrVSXi31CpP0GwEPwb7ykWJnNwKLfFuP6DNq2cTuvZM0&usqp=CAU'),
        extras: {
          'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3'
        },
      ),
      MediaItem(
        id: 'https://codeskulptor-demos.commondatastorage.googleapis.com/descent/background%20music.mp3',
        album: 'AB',
        title: 'title2',
        artUri: Uri.parse('https://example.com/art.jpg'),
        extras: {
          'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3'
        },
      ),
      MediaItem(
        id: 'https://codeskulptor-demos.commondatastorage.googleapis.com/descent/gotitem.mp3',
        album: 'AB',
        title: 'title2',
        artUri: Uri.parse('https://example.com/art.jpg'),
        extras: {
          'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3'
        },
      ),
      MediaItem(
        id: 'https://codeskulptor-demos.commondatastorage.googleapis.com/descent/Zombie.mp3',
        album: 'AB',
        title: 'title2',
        artUri: Uri.parse('https://example.com/art.jpg'),
        extras: {
          'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3'
        },
      )
    ];
    _audioHandler.addQueueItems(songList);
    print('_audioHandler Length---> ${_audioHandler.queue.value.length}');
  }

  void _listenToChangesInPlaylist() {
    _audioHandler.queue.listen((playlist) {
      if (playlist.isEmpty) {
        playlistNotifier.value = [];
        currentSongTitleNotifier.value = '';
      } else {
        final newList = playlist.map((item) => item.title).toList();
        playlistNotifier.value = newList;
      }
      _updateSkipButtons();
    });
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != AudioProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        _audioHandler.seek(Duration.zero);
        _audioHandler.pause();
      }
    });
  }

  void _listenToCurrentPosition() {
    AudioService.position.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenToBufferedPosition() {
    _audioHandler.playbackState.listen((playbackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: playbackState.bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: mediaItem?.duration ?? Duration.zero,
      );
    });
  }

  void _listenToChangesInSong() {
    _audioHandler.mediaItem.listen((mediaItem) {
      print('Item ---> ${mediaItem?.artUri}');
      currentSongTitleNotifier.value = mediaItem?.title ?? '';
      currentSongImageNotifier.value = mediaItem?.artUri.toString() ?? '';
      _updateSkipButtons();
    });
  }

  void _updateSkipButtons() {
    final mediaItem = _audioHandler.mediaItem.value;
    final playlist = _audioHandler.queue.value;
    if (playlist.length < 2 || mediaItem == null) {
      isFirstSongNotifier.value = true;
      isLastSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = playlist.first == mediaItem;
      isLastSongNotifier.value = playlist.last == mediaItem;
    }
  }

  void play() => _audioHandler.play();
  void pause() => _audioHandler.pause();

  void seek(Duration position) => _audioHandler.seek(position);

  void previous() => _audioHandler.skipToPrevious();
  void next() => _audioHandler.skipToNext();

  void repeat() {
    repeatButtonNotifier.nextState();
    final repeatMode = repeatButtonNotifier.value;
    switch (repeatMode) {
      case RepeatState.off:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
        break;
      case RepeatState.repeatSong:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case RepeatState.repeatPlaylist:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
        break;
    }
  }

  void shuffle() {
    final enable = !isShuffleModeEnabledNotifier.value;
    isShuffleModeEnabledNotifier.value = enable;
    if (enable) {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    } else {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    }
  }

  Future<void> add() async {
    final songRepository = getIt<PlaylistRepository>();
    final song = await songRepository.fetchAnotherSong();
    final mediaItem = MediaItem(
      id: song['id'] ?? '',
      album: song['album'] ?? '',
      title: song['title'] ?? '',
      extras: {'url': song['url']},
    );
    _audioHandler.addQueueItem(mediaItem);
  }

  void remove() {
    final lastIndex = _audioHandler.queue.value.length - 1;
    if (lastIndex < 0) return;
    _audioHandler.removeQueueItemAt(lastIndex);
  }

  void dispose() {
    _audioHandler.customAction('dispose');
  }

  void stop() {
    _audioHandler.stop();
  }
}
