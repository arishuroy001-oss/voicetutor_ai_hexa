import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../utils/constants.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  String _currentLang = 'English';

  bool get isListening => _stt.isListening;
  bool get isSpeaking => _tts.toString().isNotEmpty; // Proxy check
  String get currentLanguage => _currentLang;

  Future<bool> initSpeech() async {
    if (_initialized) return true;

    _initialized = await _stt.initialize(
      onError: (error) => print('STT Error: ${error.errorMsg}'),
      onStatus: (status) => print('STT Status: $status'),
      debugLogging: false,
    );

    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);

    _tts.setStartHandler(() => print('TTS started'));
    _tts.setCompletionHandler(() => print('TTS completed'));
    _tts.setErrorHandler((msg) => print('TTS error: $msg'));

    return _initialized;
  }

  Future<void> setLanguage(String language) async {
    _currentLang = language;
    final code = Constants.langCodes[language] ?? 'en-IN';
    await _tts.setLanguage(code);
  }

  Future<void> startListening({
    required Function(String) onResult,
    Function()? onTimeout,
  }) async {
    if (!_initialized) await initSpeech();
    if (!_initialized) return;

    final code = Constants.langCodes[_currentLang] ?? 'en-IN';

    await _stt.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
      localeId: code,
      listenFor: Duration(seconds: Constants.listenTimeoutSeconds),
      pauseFor: Duration(seconds: Constants.pauseTimeoutSeconds),
      onSoundLevelChange: null,
      listenMode: ListenMode.confirmation,
    );

    // Timeout handler
    Future.delayed(
      Duration(seconds: Constants.listenTimeoutSeconds + 1),
      () {
        if (_stt.isListening) {
          _stt.stop();
          onTimeout?.call();
        }
      },
    );
  }

  Future<void> stopListening() async {
    if (_stt.isListening) await _stt.stop();
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  Future<List<dynamic>> getAvailableLanguages() async {
    return await _tts.getLanguages;
  }

  void dispose() {
    _stt.cancel();
    _tts.stop();
  }
}
