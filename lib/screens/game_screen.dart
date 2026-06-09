import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/balloon_data.dart';
import '../providers/game_provider.dart';
import '../utils/alphabet_data.dart';
import '../utils/constants.dart';
import '../widgets/balloon_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Duration _lastTick = Duration.zero;
  bool _started = false;

  final List<_Particle> _particles = [];
  final _rng = math.Random();

  // Cloud drift state
  double _cloud1X = 30;
  double _cloud2X = 200;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      context.read<GameProvider>().startGame();
    }
  }

  void _onTick(Duration elapsed) {
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }
    final dt = ((elapsed - _lastTick).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _lastTick = elapsed;

    context.read<GameProvider>().tick(dt);

    setState(() {
      for (final p in _particles) {
        p.update(dt);
      }
      _particles.removeWhere((p) => p.isDead);
      _cloud1X += dt * 6;
      _cloud2X += dt * 4;
    });
  }

  void _spawnParticles(double bx, double by) {
    for (var i = 0; i < 12; i++) {
      _particles.add(_Particle(
        x: bx,
        y: by,
        color: AppColors.balloonColors[_rng.nextInt(AppColors.balloonColors.length)],
      ));
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    context.read<GameProvider>().stopGame();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GameProvider>(
        builder: (ctx, game, _) {
          return LayoutBuilder(
            builder: (ctx, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;

              return Stack(
                children: [
                  // Background
                  _buildBackground(),

                  // Drifting clouds
                  CloudWidget(
                    left: _cloud1X % (w + 160) - 80,
                    top: h * 0.08,
                    scale: 0.8,
                    opacity: 0.5,
                  ),
                  CloudWidget(
                    left: _cloud2X % (w + 160) - 80,
                    top: h * 0.22,
                    scale: 0.6,
                    opacity: 0.35,
                  ),

                  // Balloons
                  for (final balloon in List.from(game.balloons))
                    BalloonWidget(
                      key: ValueKey(balloon.id),
                      balloon: balloon,
                      screenWidth: w,
                      screenHeight: h,
                      onTap: () {
                        if (balloon.state != BalloonState.popping) {
                          final bx = balloon.x * w + balloon.swayOffset;
                          final by = h - (h + AppSizes.balloonTotalHeight) * balloon.progress;
                          if (balloon.letter == game.targetLetter) {
                            _spawnParticles(bx, by);
                          }
                          game.tapBalloon(balloon.id);
                        }
                      },
                    ),

                  // Particle effects
                  for (final p in _particles)
                    Positioned(
                      left: p.x - p.size / 2,
                      top: p.y - p.size / 2,
                      child: Opacity(
                        opacity: p.life.clamp(0.0, 1.0),
                        child: Container(
                          width: p.size,
                          height: p.size,
                          decoration: BoxDecoration(
                            color: p.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),

                  // Top bar
                  _buildTopBar(ctx, game, h),

                  // Instruction bar
                  if (game.phase == GamePhase.playing ||
                      game.phase == GamePhase.paused)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildInstructionBar(game),
                    ),

                  // Pause overlay
                  if (game.phase == GamePhase.paused)
                    _buildPauseOverlay(ctx, game),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.skyTop,
            AppColors.skyMid,
            AppColors.skyBottom,
            Color(0xFFE8F5E9),
          ],
          stops: [0.0, 0.45, 0.80, 1.0],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext ctx, GameProvider game, double screenH) {
    final isFrench = game.settings.language == Language.french;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Pause / back button
            _CircleButton(
              icon: game.phase == GamePhase.paused
                  ? Icons.play_arrow_rounded
                  : Icons.pause_rounded,
              color: Colors.white.withAlpha(50),
              onTap: () {
                if (game.phase == GamePhase.paused) {
                  game.resumeGame();
                } else {
                  game.pauseGame();
                }
              },
            ),
            const SizedBox(width: 8),
            // Back to home
            _CircleButton(
              icon: Icons.home_rounded,
              color: Colors.white.withAlpha(50),
              onTap: () {
                game.stopGame();
                Navigator.pop(ctx);
              },
            ),
            const Spacer(),
            // Score
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Text('⭐ ', style: TextStyle(fontSize: 18)),
                  Text(
                    '${game.successCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (!isFrench) ...[
              const SizedBox(width: 8),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  AlphabetData.levelName(game.settings.language, game.settings.level),
                  style: TextStyle(
                    color: Colors.white.withAlpha(180),
                    fontSize: 12,
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(width: 8),
              Text(
                AlphabetData.levelName(game.settings.language, game.settings.level),
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionBar(GameProvider game) {
    final isFrench = game.settings.language == Language.french;
    final discovery = game.settings.discoveryMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.instructionBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: discovery
          ? Center(
              child: Text(
                isFrench
                    ? '🔍 Touche un ballon pour entendre la lettre !'
                    : '🔍 المس بالون لسماع الحرف !',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : Row(
              children: [
                // Target letter display
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withAlpha(80), width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      game.targetLetter,
                      style: const TextStyle(
                        color: AppColors.successGold,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Instruction text
                Expanded(
                  child: Text(
                    isFrench
                        ? 'Trouve le ${game.targetLetter} !'
                        : 'ابحث عن ${game.targetLetter} !',
                    textAlign: isFrench ? TextAlign.left : TextAlign.right,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    textDirection:
                        isFrench ? TextDirection.ltr : TextDirection.rtl,
                  ),
                ),
                const SizedBox(width: 8),
                // Replay button
                GestureDetector(
                  onTap: game.replayInstruction,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volume_up_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPauseOverlay(BuildContext ctx, GameProvider game) {
    final isFrench = game.settings.language == Language.french;
    return Container(
      color: Colors.black.withAlpha(120),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isFrench ? 'Pause ⏸' : 'إيقاف مؤقت ⏸',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _BigButton(
              label: isFrench ? '▶  Continuer' : '▶  استمرار',
              color: const Color(0xFF4ECDC4),
              onTap: game.resumeGame,
            ),
            const SizedBox(height: 12),
            _BigButton(
              label: isFrench ? '🏠  Accueil' : '🏠  الرئيسية',
              color: Colors.white.withAlpha(50),
              onTap: () {
                game.stopGame();
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BigButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _Particle {
  double x, y;
  final Color color;
  final double angle;
  final double speed;
  double size;
  double life;

  _Particle({required this.x, required this.y, required this.color})
      : angle = math.Random().nextDouble() * math.pi * 2,
        speed = 80 + math.Random().nextDouble() * 140,
        size = 7 + math.Random().nextDouble() * 9,
        life = 1.0;

  void update(double dt) {
    x += math.cos(angle) * speed * dt;
    y += math.sin(angle) * speed * dt - 60 * dt;
    life -= dt * 2.0;
    size *= 0.97;
  }

  bool get isDead => life <= 0;
}
