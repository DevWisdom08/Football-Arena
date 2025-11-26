import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'l10n/app_localizations.dart';
import 'core/constants/app_colors.dart';
import 'core/routes/app_router.dart';
import 'core/services/storage_service.dart';
import 'core/services/locale_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed: $e');
    // App will continue to work without Firebase features
  }

  // Initialize services
  await StorageService.instance.init();

  runApp(const ProviderScope(child: FootballTriviaApp()));
}

class FootballTriviaApp extends ConsumerWidget {
  const FootballTriviaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    final isRTL = LocaleService.isRTL(locale);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Football Arena',
      locale: locale,
      supportedLocales: LocaleService.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFD700),
          brightness: Brightness.dark, // ← Dark theme
        ),
        useMaterial3: true,
        // Apply Staatliches font globally
        textTheme: GoogleFonts.staatlichesTextTheme(
          ThemeData.dark().textTheme.copyWith(
            // Headings - Bold and impactful
            headlineLarge: GoogleFonts.staatliches(
              fontSize: 32,
              fontWeight: FontWeight.w400,
              color: AppColors.heading,
              letterSpacing: 1.2,
            ),
            headlineMedium: GoogleFonts.staatliches(
              fontSize: 28,
              fontWeight: FontWeight.w400,
              color: AppColors.heading,
              letterSpacing: 1.0,
            ),
            headlineSmall: GoogleFonts.staatliches(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
            // Titles
            titleLarge: GoogleFonts.staatliches(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
            titleMedium: GoogleFonts.staatliches(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
            titleSmall: GoogleFonts.staatliches(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
            // Body text - Keep readable (Roboto for body)
            bodyLarge: GoogleFonts.roboto(fontSize: 16, color: Colors.white),
            bodyMedium: GoogleFonts.roboto(fontSize: 14, color: Colors.white70),
            bodySmall: GoogleFonts.roboto(fontSize: 12, color: Colors.white60),
            // Labels - Staatliches for impact
            labelLarge: GoogleFonts.staatliches(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            labelMedium: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}

// Old classes removed - now using separate feature files
