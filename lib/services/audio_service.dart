import 'package:flutter_tts/flutter_tts.dart';
import '../utils/alphabet_data.dart';

class AudioService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _enabled = true;
  Language _currentLanguage = Language.french;

  Future<void> initialize() async {
    if (_initialized) return;
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.1);
    await _tts.setSpeechRate(0.42);
    await _setLang(Language.french);
    _initialized = true;
  }

  Future<void> _setLang(Language lang) async {
    _currentLanguage = lang;
    await _tts.setLanguage(AlphabetData.getLanguageCode(lang));
  }

  Future<void> setLanguage(Language lang) => _setLang(lang);

  Future<void> _speak(String text) async {
    if (!_enabled) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> speakInstruction(Language lang, String letter) async {
    if (_currentLanguage != lang) await _setLang(lang);
    await _speak(AlphabetData.getInstruction(lang, letter));
  }

  Future<void> speakSuccess(Language lang, String letter) async {
    if (_currentLanguage != lang) await _setLang(lang);
    await _speak(AlphabetData.getSuccessMessage(lang, letter));
  }

  Future<void> speakMissed(Language lang, String letter) async {
    if (_currentLanguage != lang) await _setLang(lang);
    await _speak(AlphabetData.getMissedMessage(lang, letter));
  }

  Future<void> speakLetter(Language lang, String letter) async {
    if (_currentLanguage != lang) await _setLang(lang);
    await _speak(letter);
  }

  void setEnabled(bool v) {
    _enabled = v;
    if (!v) _tts.stop();
  }

  Future<void> stop() async => _tts.stop();

  void dispose() => _tts.stop();
}
