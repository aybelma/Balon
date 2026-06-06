import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'services/audio_service.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  final audio = AudioService();
  final storage = StorageService();
  final game = GameProvider(audio: audio, storage: storage);
  await game.initialize();

  runApp(
    ChangeNotifierProvider.value(
      value: game,
      child: const BallosMagiquesApp(),
    ),
  );
}

class BallosMagiquesApp extends StatelessWidget {
  const BallosMagiquesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Les Ballons Magiques',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1565C0),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
