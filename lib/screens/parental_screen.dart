import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_settings.dart';
import '../services/storage_service.dart';
import '../utils/alphabet_data.dart';
import '../utils/constants.dart';

class ParentalScreen extends StatefulWidget {
  const ParentalScreen({super.key});

  @override
  State<ParentalScreen> createState() => _ParentalScreenState();
}

class _ParentalScreenState extends State<ParentalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final s = game.settings;
    final isFrench = s.language == Language.french;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: AppColors.skyTop,
        foregroundColor: Colors.white,
        title: Text(
          isFrench ? '⚙  Espace Parents' : '⚙  المنطقة الوالدية',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: isFrench ? 'Réglages' : 'الإعدادات'),
            Tab(text: isFrench ? 'Progrès' : 'التقدم'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _SettingsTab(game: game, settings: s, isFrench: isFrench),
          _ProgressTab(game: game, isFrench: isFrench),
        ],
      ),
    );
  }
}

// ── Settings Tab ──────────────────────────────────────────────────────────────

class _SettingsTab extends StatelessWidget {
  final GameProvider game;
  final GameSettings settings;
  final bool isFrench;

  const _SettingsTab({
    required this.game,
    required this.settings,
    required this.isFrench,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader(title: isFrench ? 'Langue' : 'اللغة'),
        _LanguageCard(game: game, settings: settings, isFrench: isFrench),
        const SizedBox(height: 16),
        _SectionHeader(title: isFrench ? 'Niveau' : 'المستوى'),
        _LevelCard(game: game, settings: settings, isFrench: isFrench),
        const SizedBox(height: 16),
        _SectionHeader(title: isFrench ? 'Vitesse des ballons' : 'سرعة البالونات'),
        _SpeedCard(game: game, settings: settings, isFrench: isFrench),
        const SizedBox(height: 16),
        _SectionHeader(title: isFrench ? 'Sons' : 'الأصوات'),
        _SoundCard(game: game, settings: settings, isFrench: isFrench),
        const SizedBox(height: 16),
        _SectionHeader(title: isFrench ? 'Modes' : 'الأوضاع'),
        _ModesCard(game: game, settings: settings, isFrench: isFrench),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF5C6BC0),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final GameProvider game;
  final GameSettings settings;
  final bool isFrench;

  const _LanguageCard(
      {required this.game, required this.settings, required this.isFrench});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          _LangChip(
            label: '🇫🇷  Français',
            selected: settings.language == Language.french,
            onTap: () => game.updateSettings(
                settings.copyWith(language: Language.french)),
          ),
          const SizedBox(width: 10),
          _LangChip(
            label: '🌙  العربية',
            selected: settings.language == Language.arabic,
            onTap: () => game.updateSettings(
                settings.copyWith(language: Language.arabic)),
          ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.skyTop : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final GameProvider game;
  final GameSettings settings;
  final bool isFrench;

  const _LevelCard(
      {required this.game, required this.settings, required this.isFrench});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: List.generate(3, (i) {
          final selected = settings.level == i;
          return GestureDetector(
            onTap: () => game.updateSettings(settings.copyWith(level: i)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.skyTop.withAlpha(30)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? AppColors.skyTop
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: selected ? AppColors.skyTop : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AlphabetData.levelName(settings.language, i),
                    style: TextStyle(
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                      color: selected ? AppColors.skyTop : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SpeedCard extends StatelessWidget {
  final GameProvider game;
  final GameSettings settings;
  final bool isFrench;

  const _SpeedCard(
      {required this.game, required this.settings, required this.isFrench});

  @override
  Widget build(BuildContext context) {
    final labels = isFrench
        ? ['Très lent', 'Lent', 'Normal', 'Rapide', 'Très rapide']
        : ['بطيء جداً', 'بطيء', 'عادي', 'سريع', 'سريع جداً'];
    final idx = ((settings.speedMultiplier - 0.5) / 0.375).round().clamp(0, 4);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isFrench ? 'Vitesse : ' : 'السرعة : ',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                labels[idx],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.skyTop,
                ),
              ),
            ],
          ),
          Slider(
            value: settings.speedMultiplier,
            min: 0.5,
            max: 2.0,
            divisions: 6,
            activeColor: AppColors.skyTop,
            onChanged: (v) =>
                game.updateSettings(settings.copyWith(speedMultiplier: v)),
          ),
        ],
      ),
    );
  }
}

class _SoundCard extends StatelessWidget {
  final GameProvider game;
  final GameSettings settings;
  final bool isFrench;

  const _SoundCard(
      {required this.game, required this.settings, required this.isFrench});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          _SwitchRow(
            label: isFrench ? 'Instructions vocales' : 'التعليمات الصوتية',
            icon: Icons.volume_up_rounded,
            value: settings.soundEnabled,
            onChanged: (v) =>
                game.updateSettings(settings.copyWith(soundEnabled: v)),
          ),
        ],
      ),
    );
  }
}

class _ModesCard extends StatelessWidget {
  final GameProvider game;
  final GameSettings settings;
  final bool isFrench;

  const _ModesCard(
      {required this.game, required this.settings, required this.isFrench});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          _SwitchRow(
            label: isFrench ? 'Majuscules et minuscules' : 'أحرف كبيرة وصغيرة',
            icon: Icons.text_fields_rounded,
            value: settings.showLowercase,
            onChanged: (v) =>
                game.updateSettings(settings.copyWith(showLowercase: v)),
          ),
          const Divider(),
          _SwitchRow(
            label: isFrench ? 'Mode découverte' : 'وضع الاستكشاف',
            icon: Icons.explore_rounded,
            value: settings.discoveryMode,
            onChanged: (v) =>
                game.updateSettings(settings.copyWith(discoveryMode: v)),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.skyTop, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 15)),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.skyTop,
        ),
      ],
    );
  }
}

// ── Progress Tab ──────────────────────────────────────────────────────────────

class _ProgressTab extends StatelessWidget {
  final GameProvider game;
  final bool isFrench;

  const _ProgressTab({required this.game, required this.isFrench});

  @override
  Widget build(BuildContext context) {
    final progress = game.progress;
    final letters =
        AlphabetData.getLettersForLevel(game.settings.language, game.settings.level);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary
        _Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatBox(
                value: '${progress.totalTouched}',
                label: isFrench ? 'Lettres\ntouchées' : 'حروف\nmلمست',
                icon: Icons.touch_app_rounded,
              ),
              _StatBox(
                value: '${progress.totalSessions}',
                label: isFrench ? 'Sessions' : 'جلسات',
                icon: Icons.play_circle_rounded,
              ),
              _StatBox(
                value: _globalAccuracy(progress, letters),
                label: isFrench ? 'Précision' : 'الدقة',
                icon: Icons.check_circle_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionHeader(
            title: isFrench ? 'Précision par lettre' : 'الدقة لكل حرف'),
        _Card(
          child: Column(
            children: letters.map((l) {
              final acc = progress.accuracyFor(l);
              final correct = progress.correctCounts[l] ?? 0;
              final missed = progress.missedCounts[l] ?? 0;
              if (correct + missed == 0) return const SizedBox.shrink();
              return _LetterProgressRow(
                letter: l,
                accuracy: acc,
                correct: correct,
                missed: missed,
                language: game.settings.language,
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        // Reset button
        Center(
          child: TextButton.icon(
            onPressed: () => _showResetDialog(context),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: Text(
              isFrench ? 'Réinitialiser les progrès' : 'إعادة تعيين التقدم',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  String _globalAccuracy(progress, List<String> letters) {
    var totalC = 0;
    var totalM = 0;
    for (final l in letters) {
      totalC += progress.correctCounts[l] ?? 0;
      totalM += progress.missedCounts[l] ?? 0;
    }
    if (totalC + totalM == 0) return '—';
    return '${((totalC / (totalC + totalM)) * 100).round()}%';
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isFrench ? 'Réinitialiser ?' : 'إعادة تعيين ؟'),
        content: Text(
          isFrench
              ? 'Les progrès seront effacés pour cette langue.'
              : 'سيتم مسح التقدم لهذه اللغة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isFrench ? 'Annuler' : 'إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final storage = StorageService();
              await storage.clearProgress(game.settings.language);
              await game.initialize();
            },
            child: Text(
              isFrench ? 'Réinitialiser' : 'إعادة تعيين',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatBox(
      {required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.skyTop, size: 26),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.skyTop,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}

class _LetterProgressRow extends StatelessWidget {
  final String letter;
  final double accuracy;
  final int correct;
  final int missed;
  final Language language;

  const _LetterProgressRow({
    required this.letter,
    required this.accuracy,
    required this.correct,
    required this.missed,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final color = accuracy >= 0.8
        ? const Color(0xFF4CAF50)
        : accuracy >= 0.5
            ? const Color(0xFFFFC107)
            : const Color(0xFFF44336);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              letter,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textDirection: language == Language.arabic
                  ? TextDirection.rtl
                  : TextDirection.ltr,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: accuracy,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${(accuracy * 100).round()}%',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '($correct✓ $missed✗)',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
