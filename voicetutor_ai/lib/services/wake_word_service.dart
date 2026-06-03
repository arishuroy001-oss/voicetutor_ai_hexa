import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:porcupine_flutter/porcupine_error.dart';
import '../utils/constants.dart';

class WakeWordService {
  PorcupineManager? _manager;
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  Future<bool> init(Function() onWakeWord) async {
    try {
      _manager = await PorcupineManager.fromKeywordPaths(
        Constants.picovoiceAccessKey,
        [Constants.wakeWordPath],
        (int keywordIndex) {
          if (keywordIndex == 0) {
            print('Wake word detected!');
            onWakeWord();
          }
        },
        errorCallback: (PorcupineException error) {
          print('Porcupine error: ${error.message}');
        },
      );
      return true;
    } on PorcupineInvalidArgumentException catch (e) {
      print('Porcupine invalid argument: ${e.message}');
      return false;
    } on PorcupineActivationException catch (e) {
      print('Porcupine activation error: ${e.message}');
      return false;
    } on PorcupineException catch (e) {
      print('Porcupine init error: ${e.message}');
      return false;
    }
  }

  Future<void> start() async {
    if (_manager == null) return;
    try {
      await _manager!.start();
      _isRunning = true;
    } catch (e) {
      print('WakeWord start error: $e');
    }
  }

  Future<void> stop() async {
    if (_manager == null || !_isRunning) return;
    try {
      await _manager!.stop();
      _isRunning = false;
    } catch (e) {
      print('WakeWord stop error: $e');
    }
  }

  Future<void> dispose() async {
    if (_manager == null) return;
    try {
      await _manager!.delete();
      _manager = null;
      _isRunning = false;
    } catch (e) {
      print('WakeWord dispose error: $e');
    }
  }
}
