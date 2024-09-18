import 'package:audioplayers/audioplayers.dart';
import 'dart:typed_data';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playAudio(Uint8List audioBytes) async {
    try {
      // Use the BytesSource to play the audio
      await _audioPlayer.play(BytesSource(audioBytes));
    } catch (e) {
      print('Error playing audio: $e');
    }
  }
}
