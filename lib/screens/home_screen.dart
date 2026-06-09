import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/alphabet_data.dart';
import '../utils/constants.dart';
import '../widgets/balloon_widget.dart';
import 'game_screen.dart';
import 'parental_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _titleController;
  late List<_DecorationBalloon> _decorBalloons;
  final _rng = math.Random();
  Ticker? _ticker;
  Duration _lastTick = Duration.zero;

  // Parental lock
  bool _longPressing = false;
  double _lockProgress = 0.0;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _decorBalloons = List.generate(8, (_) => _DecorationBalloon(_rng));

    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    setState(() {
      for (final b in _decorBalloons) {
        b.update(dt);
      }
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _titleController.dispose();
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final isFrench = game.settings.language == Language.french;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.skyTop,
                  AppColors.skyMid,
                  AppColors.skyBottom,
                  Color(0xFFE3F2FD),
                ],
                stops: [0.0, 0.4, 0.75, 1.0],
              ),
            ),
          ),

          // Clouds
          const CloudWidget(left: 20, top: 60, scale: 0.9, opacity: 0.6),
          const CloudWidget(left: 180, top: 30, scale: 1.1, opacity: 0.5),
          const CloudWidget(left: -20, top: 140, scale: 0.7, opacity: 0.4),

          // Decoration balloons floating up
          for (final b in _decorBalloons)
            Positioned(
              left: b.x,
              top: b.y,
              child: Opacity(
                opacity: b.opacity,
                child: _miniBallon(b.color, b.letter),
              ),
            ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Title
                FadeTransition(
                  opacity: _titleController,
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _titleController,
                      curve: Curves.elasticOut,
                    ),
                    child: _buildTitle(isFrench),
                  ),
                ),
                const Spacer(),
                // Language selector
                _buildLanguageSelector(context, game, isFrench),
                const SizedBox(height: 28),
                // Play button
                _buildPlayButton(context, game, isFrench),
                const SizedBox(height: 16),
                // Discovery mode toggle
                _buildDiscoveryButton(context, game, isFrench),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // Parental access (bottom-right corner, hidden)
          Positioned(
            right: 12,
            bottom: 12,
            child: _buildParentalTrigger(context, game),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(bool isFrench) {
    return Column(
      children: [
        Text(
          isFrench ? '🎈 Les Ballons Magiques' : '🎈 البالونات السحرية',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Color(0x881565C0),
                offset: Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isFrench
              ? 'Apprends les lettres en t\'amusant !'
              : 'تعلم الحروف بطريقة ممتعة !',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withAlpha(220),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector(
      BuildContext context, GameProvider game, bool isFrench) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white.withAlpha(80), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _langBtn(
            label: '🇫🇷  Français',
            selected: isFrench,
            onTap: () => game.updateSettings(
                game.settings.copyWith(language: Language.french)),
          ),
          const SizedBox(width: 6),
          _langBtn(
            label: '🌙  العربية',
            selected: !isFrench,
            onTap: () => game.updateSettings(
                game.settings.copyWith(language: Language.arabic)),
          ),
        ],
      ),
    );
  }

  Widget _langBtn({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
          boxShadow: selected
              ? [
                  const BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.skyTop : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton(
      BuildContext context, GameProvider game, bool isFrench) {
    return GestureDetector(
      onTap: () => _startGame(context, game),
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (_, __) {
          final offset = math.sin(_floatController.value * math.pi) * 6;
          return Transform.translate(
            offset: Offset(0, -offset),
            child: Container(
              width: 180,
              height: 70,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                ),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  const BoxShadow(
                    color: Color(0x88FF6B6B),
                    blurRadius: 20,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  isFrench ? 'JOUER ! 🎈' : 'العب ! 🎈',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiscoveryButton(
      BuildContext context, GameProvider game, bool isFrench) {
    return GestureDetector(
      onTap: () => game.updateSettings(
        game.settings.copyWith(discoveryMode: !game.settings.discoveryMode),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: game.settings.discoveryMode
              ? Colors.white.withAlpha(50)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withAlpha(120),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              game.settings.discoveryMode
                  ? Icons.explore
                  : Icons.explore_outlined,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isFrench ? 'Mode découverte' : 'وضع الاستكشاف',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentalTrigger(BuildContext context, GameProvider game) {
    return GestureDetector(
      onLongPressStart: (_) {
        setState(() {
          _longPressing = true;
          _lockProgress = 0.0;
        });
        _startLockTimer(context, game);
      },
      onLongPressEnd: (_) {
        setState(() {
          _longPressing = false;
          _lockProgress = 0.0;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _longPressing
              ? Colors.white.withAlpha(60)
              : Colors.white.withAlpha(25),
          shape: BoxShape.circle,
        ),
        child: _longPressing
            ? CircularProgressIndicator(
                value: _lockProgress,
                strokeWidth: 2.5,
                color: Colors.white,
                backgroundColor: Colors.white24,
              )
            : Icon(
                Icons.settings,
                color: Colors.white.withAlpha(120),
                size: 22,
              ),
      ),
    );
  }

  void _startLockTimer(BuildContext context, GameProvider game) async {
    const steps = 40;
    for (var i = 0; i <= steps; i++) {
      await Future.delayed(const Duration(milliseconds: 75));
      if (!_longPressing) return;
      if (!mounted) return;
      setState(() => _lockProgress = i / steps);
    }
    if (!_longPressing) return;
    setState(() {
      _longPressing = false;
      _lockProgress = 0.0;
    });
    _showParentalChallenge(context, game);
  }

  void _showParentalChallenge(BuildContext context, GameProvider game) {
    final answer = (2 + math.Random().nextInt(4));
    final a = 1 + math.Random().nextInt(answer - 1);
    final b = answer - a;
    final isFrench = game.settings.language == Language.french;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isFrench ? 'Espace Parents' : 'المنطقة الوالدية',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isFrench ? 'Combien font $a + $b ?' : 'كم يساوي $a + $b ؟',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Builder(builder: (_) {
              final opts = [answer - 1, answer, answer + 1, answer + 2]
                ..shuffle();
              return Wrap(
                spacing: 10,
                runSpacing: 8,
                children: opts
                    .map((n) => ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            if (n == answer) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ParentalScreen(),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.skyMid,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                          ),
                          child: Text(
                            '$n',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ))
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _startGame(BuildContext context, GameProvider game) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const GameScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Widget _miniBallon(Color color, String letter) {
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
    );
  }
}

class _DecorationBalloon {
  double x, y, speed;
  Color color;
  String letter;
  double opacity;

  static final _letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');

  _DecorationBalloon(math.Random rng)
      : x = rng.nextDouble() * 400,
        y = 600 + rng.nextDouble() * 400,
        speed = 20 + rng.nextDouble() * 30,
        color = AppColors.balloonColors[rng.nextInt(AppColors.balloonColors.length)],
        letter = _letters[rng.nextInt(_letters.length)],
        opacity = 0.3 + rng.nextDouble() * 0.4;

  void update(double dt) {
    y -= speed * dt;
    if (y < -80) {
      y = 700 + math.Random().nextDouble() * 200;
      x = math.Random().nextDouble() * 400;
    }
  }
}
