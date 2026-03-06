import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'screens/setup_screen.dart';
import 'services/moves_service.dart';

final movesService = MovesService();

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const RanJitzuApp());
}

class RanJitzuApp extends StatelessWidget {
  const RanJitzuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RanJitzu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE63946),
          surface: Color(0xFF1A1A2E),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: const SetupScreen(),
    );
  }
}