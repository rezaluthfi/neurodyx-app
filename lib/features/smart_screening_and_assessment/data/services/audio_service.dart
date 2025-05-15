import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool _isDisposed = false;
  bool _isProcessing = false;

  /// Plays a sound from the given URL with the specified playback speed.
  Future<void> playSound(String? url, {double speed = 1.0}) async {
    if (_isDisposed || _isProcessing || url == null) return;
    _isProcessing = true;
    try {
      await _player.setPlaybackRate(speed);
      await _player.play(UrlSource(url));
    } catch (e) {
      print('Error playing sound: $e');
      // Optionally notify the UI (e.g., via a callback or event)
    } finally {
      _isProcessing = false;
    }
  }

  /// Stops the currently playing sound.
  Future<void> stop() async {
    if (_isDisposed || _isProcessing) return;
    _isProcessing = true;
    try {
      await _player.stop();
    } catch (e) {
      print('Error stopping sound: $e');
    } finally {
      _isProcessing = false;
    }
  }

  /// Resets the AudioPlayer to a clean state.
  Future<void> reset() async {
    if (_isDisposed || _isProcessing) return;
    _isProcessing = true;
    try {
      await _player.stop();
      await _player.release();
    } catch (e) {
      print('Error resetting player: $e');
    } finally {
      _isProcessing = false;
    }
  }

  /// Stream of player state changes.
  Stream<PlayerState> get playerState => _player.onPlayerStateChanged;

  /// Disposes of the AudioPlayer, ensuring it’s only called once.
  Future<void> dispose() async {
    if (_isDisposed || _isProcessing) return;
    _isProcessing = true;
    _isDisposed = true;
    try {
      await _player.stop();
      await _player.release();
      await _player.dispose();
    } catch (e) {
      print('Error disposing player: $e');
    } finally {
      _isProcessing = false;
    }
  }
}
