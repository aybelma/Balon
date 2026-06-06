class ProgressData {
  final Map<String, int> correctCounts;
  final Map<String, int> missedCounts;
  int totalSessions;
  int totalTouched;

  ProgressData({
    Map<String, int>? correctCounts,
    Map<String, int>? missedCounts,
    this.totalSessions = 0,
    this.totalTouched = 0,
  })  : correctCounts = correctCounts ?? {},
        missedCounts = missedCounts ?? {};

  void recordSuccess(String letter) {
    correctCounts[letter] = (correctCounts[letter] ?? 0) + 1;
    totalTouched++;
  }

  void recordMissed(String letter) {
    missedCounts[letter] = (missedCounts[letter] ?? 0) + 1;
  }

  double accuracyFor(String letter) {
    final c = correctCounts[letter] ?? 0;
    final m = missedCounts[letter] ?? 0;
    final total = c + m;
    if (total == 0) return 1.0;
    return c / total;
  }

  double weightFor(String letter) {
    final acc = accuracyFor(letter);
    if (acc >= 0.8) return 1.0;
    if (acc >= 0.6) return 1.5;
    if (acc >= 0.4) return 2.0;
    return 3.0;
  }

  Map<String, dynamic> toJson() => {
        'correctCounts': correctCounts,
        'missedCounts': missedCounts,
        'totalSessions': totalSessions,
        'totalTouched': totalTouched,
      };

  factory ProgressData.fromJson(Map<String, dynamic> json) => ProgressData(
        correctCounts: Map<String, int>.from(json['correctCounts'] ?? {}),
        missedCounts: Map<String, int>.from(json['missedCounts'] ?? {}),
        totalSessions: json['totalSessions'] ?? 0,
        totalTouched: json['totalTouched'] ?? 0,
      );
}
