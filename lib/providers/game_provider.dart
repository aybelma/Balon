import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/balloon_data.dart';
import '../models/progress_data.dart';
import '../models/game_settings.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../utils/alphabet_data.dart';
import '../utils/constants.dart';

enum GamePhase { idle, playing, paused }

class GameProvider extends ChangeNotifier {
  final AudioService _audio;
  final StorageService _storage;
  final _uuid = const Uuid();
  final _rng = math.Random();

  final List<BalloonData> balloons = [];
  String targetLetter = '';
  GamePhase phase = GamePhase.idle;
  GameSettings settings = GameSettings();
  ProgressData progress = ProgressData();

  int _successCount = 0;
  double _spawnTimer = 0.0;
  bool _awaitingNewTarget = false;
  double _targetGuaranteeTimer = 0.0;
  double _adaptiveSpeed = 1.0;
  int _recentCorrect = 0;
  int _recentAttempts = 0;

  int get successCount => _successCount;

  GameProvider({required AudioService audio, required StorageService storage})
      : _audio = audio,
        _storage = storage;

  Future<void> initialize() async {
    await _audio.initialize();
    settings = await _storage.loadSettings();
    progress = await _storage.loadProgress(settings.language);
    await _audio.setLanguage(settings.language);
  }

  Future<void> startGame() async {
    balloons.clear();
    _spawnTimer = 0.0;
    _awaitingNewTarget = false;
    _targetGuaranteeTimer = 0.0;
    _adaptiveSpeed = 1.0;
    _recentCorrect = 0;
    _recentAttempts = 0;
    _successCount = 0;

    progress.totalSessions++;
    _pickNextTarget('');
    phase = GamePhase.playing;

    for (var i = 0; i < 3; i++) {
      _spawnBalloon(forceTarget: i == 0);
    }
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));
    if (phase == GamePhase.playing) _say();
  }

  void pauseGame() {
    if (phase != GamePhase.playing) return;
    phase = GamePhase.paused;
    _audio.stop();
    notifyListeners();
  }

  void resumeGame() {
    if (phase != GamePhase.paused) return;
    phase = GamePhase.playing;
    notifyListeners();
    _say();
  }

  void stopGame() {
    phase = GamePhase.idle;
    balloons.clear();
    _audio.stop();
    notifyListeners();
  }

  void tick(double dt) {
    if (phase != GamePhase.playing) return;

    bool targetMissed = false;
    final toRemove = <BalloonData>[];

    for (final b in balloons) {
      switch (b.state) {
        case BalloonState.rising:
          b.progress += _currentSpeed * dt;
          b.swayPhase += b.swaySpeed * dt;
          b.swayOffset = math.sin(b.swayPhase) * 9.0;
          if (b.shouldRemove) {
            if (b.letter == targetLetter && !settings.discoveryMode) {
              targetMissed = true;
            }
            toRemove.add(b);
          }
          break;

        case BalloonState.popping:
          b.popProgress += dt * 2.8;
          if (b.shouldRemove) toRemove.add(b);
          break;

        case BalloonState.wrongTap:
          b.shakeTime += dt;
          b.progress += _currentSpeed * dt * 0.25;
          if (b.shakeTime >= 0.6) {
            b.state = BalloonState.rising;
            b.shakeTime = 0.0;
          }
          break;
      }
    }

    for (final b in toRemove) {
      balloons.remove(b);
    }

    if (targetMissed && !_awaitingNewTarget) {
      progress.recordMissed(targetLetter);
      _audio.speakMissed(settings.language, targetLetter);
      _saveProgress();
    }

    if (!_awaitingNewTarget) {
      final hasTarget = balloons.any(
        (b) => b.letter == targetLetter && b.state == BalloonState.rising,
      );
      if (!hasTarget) {
        _targetGuaranteeTimer += dt;
        if (_targetGuaranteeTimer >= 2.5) {
          _spawnBalloon(forceTarget: true);
          _targetGuaranteeTimer = 0.0;
        }
      } else {
        _targetGuaranteeTimer = 0.0;
      }
    }

    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0.0;
      _spawnBalloon();
    }

    notifyListeners();
  }

  void tapBalloon(String id) {
    final b = balloons.where((x) => x.id == id).firstOrNull;
    if (b == null || b.state == BalloonState.popping) return;

    if (settings.discoveryMode) {
      _audio.speakLetter(settings.language, b.letter);
      b.state = BalloonState.popping;
      notifyListeners();
      return;
    }

    if (b.letter == targetLetter) {
      _onCorrect(b);
    } else {
      _onWrong(b);
    }
  }

  void replayInstruction() {
    if (settings.soundEnabled) _say();
  }

  Future<void> updateSettings(GameSettings next) async {
    final langChanged = next.language != settings.language;
    settings = next;
    await _storage.saveSettings(settings);
    if (langChanged) {
      progress = await _storage.loadProgress(settings.language);
      await _audio.setLanguage(settings.language);
    }
    _audio.setEnabled(settings.soundEnabled);
    notifyListeners();
  }

  void _onCorrect(BalloonData b) {
    b.state = BalloonState.popping;
    progress.recordSuccess(targetLetter);
    _successCount++;
    _recentCorrect++;
    _recentAttempts++;
    _updateAdaptiveSpeed();
    _saveProgress();
    _awaitingNewTarget = true;

    if (settings.soundEnabled) {
      _audio.speakSuccess(settings.language, targetLetter);
    }

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (phase == GamePhase.playing) {
        final prev = targetLetter;
        _pickNextTarget(prev);
        _awaitingNewTarget = false;
        _spawnBalloon(forceTarget: true);
        notifyListeners();
        if (settings.soundEnabled) _say();
      }
    });

    notifyListeners();
  }

  void _onWrong(BalloonData b) {
    if (b.state == BalloonState.wrongTap) return;
    b.state = BalloonState.wrongTap;
    b.shakeTime = 0.0;
    _recentAttempts++;
    _updateAdaptiveSpeed();
    notifyListeners();
  }

  void _pickNextTarget(String exclude) {
    final available = AlphabetData.getLettersForLevel(settings.language, settings.level);
    if (available.isEmpty) return;

    final weights = available.map((l) => progress.weightFor(l)).toList();
    final total = weights.fold(0.0, (a, b) => a + b);
    var rand = _rng.nextDouble() * total;

    String selected = available.last;
    for (var i = 0; i < available.length; i++) {
      rand -= weights[i];
      if (rand <= 0) {
        selected = available[i];
        break;
      }
    }

    if (selected == exclude && available.length > 1) {
      _pickNextTarget('__force__');
      return;
    }
    targetLetter = selected;
  }

  void _spawnBalloon({bool forceTarget = false}) {
    if (balloons.length >= GameConfig.maxBalloonsOnScreen) return;
    final available = AlphabetData.getLettersForLevel(settings.language, settings.level);
    if (available.isEmpty) return;

    final onScreen = balloons.map((b) => b.letter).toSet();
    final hasTarget = onScreen.contains(targetLetter) &&
        balloons.any((b) => b.letter == targetLetter && b.state == BalloonState.rising);

    String letter;
    if (forceTarget || (!hasTarget && _rng.nextDouble() < 0.65)) {
      letter = targetLetter;
    } else {
      letter = _pickDistractor(available, exclude: onScreen);
    }

    final x = 0.06 + _rng.nextDouble() * 0.82;
    final color = AppColors.balloonColors[_rng.nextInt(AppColors.balloonColors.length)];

    balloons.add(BalloonData(
      id: _uuid.v4(),
      letter: letter,
      color: color,
      x: x,
      progress: -0.06,
    ));
  }

  String _pickDistractor(List<String> available, {required Set<String> exclude}) {
    final similar = settings.language == Language.french
        ? AlphabetData.frenchSimilar
        : AlphabetData.arabicSimilar;

    final candidates = (similar[targetLetter] ?? [])
        .where((l) => available.contains(l) && !exclude.contains(l))
        .toList();

    if (candidates.isNotEmpty && _rng.nextDouble() < 0.4) {
      return candidates[_rng.nextInt(candidates.length)];
    }

    final filtered = available.where((l) => l != targetLetter && !exclude.contains(l)).toList();
    if (filtered.isEmpty) {
      final any = available.where((l) => l != targetLetter).toList();
      return any.isEmpty ? available.first : any[_rng.nextInt(any.length)];
    }
    return filtered[_rng.nextInt(filtered.length)];
  }

  void _say() {
    if (!settings.soundEnabled || targetLetter.isEmpty) return;
    _audio.speakInstruction(settings.language, targetLetter);
  }

  void _updateAdaptiveSpeed() {
    if (_recentAttempts < 5) return;
    final rate = _recentCorrect / _recentAttempts;
    if (rate >= 0.8) {
      _adaptiveSpeed = (_adaptiveSpeed + 0.1).clamp(0.8, 1.6);
    } else if (rate <= 0.4) {
      _adaptiveSpeed = (_adaptiveSpeed - 0.1).clamp(0.5, 1.6);
    }
    _recentCorrect = 0;
    _recentAttempts = 0;
  }

  double get _currentSpeed {
    final base = GameConfig.levelSpeeds[settings.level.clamp(0, 2)];
    return base * settings.speedMultiplier * _adaptiveSpeed;
  }

  double get _spawnInterval =>
      GameConfig.baseSpawnInterval / (settings.speedMultiplier * _adaptiveSpeed).clamp(0.5, 3.0);

  Future<void> _saveProgress() async {
    await _storage.saveProgress(settings.language, progress);
  }
}
