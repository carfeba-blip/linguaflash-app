import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final _player = AudioPlayer();

  static Future<void> playCorrect() async {
    try {
      await _player.play(AssetSource('sounds/correct.wav'));
    } catch (_) {}
  }

  static Future<void> playWrong() async {
    try {
      await _player.play(AssetSource('sounds/wrong.wav'));
    } catch (_) {}
  }

  static Future<void> playClick() async {
    if (kIsWeb) return;
    try {
      await _player.play(AssetSource('sounds/click.wav'));
    } catch (_) {}
  }
}
