import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'services/supabase_service.dart';  // ← NUEVO

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ════════════════════════════════════════════════════════════
  // INICIALIZAR SUPABASE (IMPORTANTE)
  // ════════════════════════════════════════════════════════════
  try {
    await SupabaseService.init();
    print('✅ Supabase inicializado correctamente');
  } catch (e) {
    print('❌ Error iniciando Supabase: $e');
    // En producción, mostrar error en UI
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const UnsaacApp());
}

class UnsaacApp extends StatelessWidget {
  const UnsaacApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UNSAAC - Gestión de Residuos',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B21A8),
          brightness: Brightness.dark,
          primary: const Color(0xFF9333EA),
          secondary: const Color(0xFFB06EF5),
          surface: const Color(0xFF1A1A2E),
          background: const Color(0xFF0D0D1A),
        ),
        scaffoldBackgroundColor: const Color(0xFF0D0D1A),

        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.12),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFF9333EA), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B21A8),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 8,
            shadowColor: const Color(0xFF6B21A8).withOpacity(0.5),
          ),
        ),
      ),

      home: const LoginScreen(),
    );
  }
}