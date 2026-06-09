import '../utils/alphabet_data.dart';

class GameSettings {
  Language language;
  int level;
  double speedMultiplier;
  bool soundEnabled;
  bool musicEnabled;
  bool showLowercase;
  bool discoveryMode;

  GameSettings({
    this.language = Language.french,
    this.level = 0,
    this.speedMultiplier = 1.0,
    this.soundEnabled = true,
    this.musicEnabled = false,
    this.showLowercase = false,
    this.discoveryMode = false,
  });

  GameSettings copyWith({
    Language? language,
    int? level,
    double? speedMultiplier,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? showLowercase,
    bool? discoveryMode,
  }) {
    return GameSettings(
      language: language ?? this.language,
      level: level ?? this.level,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      showLowercase: showLowercase ?? this.showLowercase,
      discoveryMode: discoveryMode ?? this.discoveryMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'language': language.index,
        'level': level,
        'speedMultiplier': speedMultiplier,
        'soundEnabled': soundEnabled,
        'musicEnabled': musicEnabled,
        'showLowercase': showLowercase,
        'discoveryMode': discoveryMode,
      };

  factory GameSettings.fromJson(Map<String, dynamic> json) => GameSettings(
        language: Language.values[json['language'] ?? 0],
        level: json['level'] ?? 0,
        speedMultiplier: (json['speedMultiplier'] ?? 1.0).toDouble(),
        soundEnabled: json['soundEnabled'] ?? true,
        musicEnabled: json['musicEnabled'] ?? false,
        showLowercase: json['showLowercase'] ?? false,
        discoveryMode: json['discoveryMode'] ?? false,
      );
}
