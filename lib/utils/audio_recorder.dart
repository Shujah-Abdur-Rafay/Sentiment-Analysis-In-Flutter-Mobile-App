import 'package:record/record.dart' as record_pkg;

/// A wrapper for the Record package (v5.2.1) to handle audio recording
class AudioRecorder {
  // Create an instance of the package's AudioRecorder class
  final record_pkg.AudioRecorder _recorder = record_pkg.AudioRecorder();

  /// Check if the app has permission to record audio
  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  /// Start recording audio to a file with default configuration
  Future<void> start({required String path}) async {
    final config = record_pkg.RecordConfig(
      encoder: record_pkg.AudioEncoder.aacLc,
      bitRate: 128000,
      sampleRate: 44100,
    );
    await _recorder.start(config, path: path);
  }

  /// Stop recording and return the file path
  Future<String?> stop() async {
    return await _recorder.stop();
  }

  /// Pause the current recording
  Future<void> pause() async {
    await _recorder.pause();
  }

  /// Resume a paused recording
  Future<void> resume() async {
    await _recorder.resume();
  }

  /// Dispose of the recorder resources
  Future<void> dispose() async {
    await _recorder.dispose();
  }
}
