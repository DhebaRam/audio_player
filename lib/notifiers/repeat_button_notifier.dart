import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class RepeatButtonNotifier extends ValueNotifier<RepeatState> {
  RepeatButtonNotifier() : super(_initialValue);
  static const _initialValue = RepeatState.off;

  void nextState() {
    final next = (value.index + 1) % RepeatState.values.length;
    value = RepeatState.values[next];
  }
}

enum RepeatState {
  off,
  repeatSong,
  repeatPlaylist,
}

class RepeatButtonController extends GetxController {
  Rx<RepeatState> state = RepeatState.off.obs; // Rx wrapper for RepeatState
  static const _initialValue = RepeatState.off;

  void nextState() {
    final next = (state.value.index + 1) % RepeatState.values.length;
    state.value = RepeatState.values[next];
  }
}

enum RepeatStateType {
  off,
  repeatSong,
  repeatPlaylist,
}