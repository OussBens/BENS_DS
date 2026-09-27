import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:easy_localization/easy_localization.dart';
import 'core/routes/app_router.dart' as AppRouter;
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Pré-charge les fichiers de traduction dans le cache de rootBundle avant
  // le premier rendu : sans ça, easy_localization les récupère de façon
  // asynchrone après le montage du widget, et les Text('...').tr() affichent
  // brièvement la clé brute (ex: "find_your") le temps que le fetch termine.
  await Future.wait([
    rootBundle.loadString('assets/traduction/fr.json'),
    rootBundle.loadString('assets/traduction/ar.json'),
  ]);

  if (!kIsWeb) {
    HttpOverrides.global = MyHttpOverrides();
    try {
      await dotenv.load(fileName: '.env.production');
    } catch (e) {
      await dotenv.load();
    }
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('fr'), Locale('ar')],
      path: 'assets/traduction',
      fallbackLocale: const Locale('fr'),
      startLocale: const Locale('fr'),
      child: const ProviderScope(
        child: MyApp(),
      ),
    ),
  );
}

class _BootLoadingScreen extends StatelessWidget {
  const _BootLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppConstants.heroGradient),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo/bens_ds_logo.png',
              height: 80,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.apps_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 36),
            const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation(AppConstants.yellow),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // 👇 AJOUT : Flag pour le temps minimum
  bool _minSplashElapsed = false;

  @override
  void initState() {
    super.initState();

    // Durée minimale courte pour éviter un flash du logo, sans bloquer
    // artificiellement le démarrage comme le faisait le délai de 3s précédent.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _minSplashElapsed = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Le splash reste tant que l'initialisation n'est pas finie
    // OU que la durée minimale ne s'est pas écoulée.
    if (!authState.isInitialized || !_minSplashElapsed) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _BootLoadingScreen(),
      );
    }

    return MaterialApp.router(
      title: 'app_title'.tr(),
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      builder: (context, child) {
        final isArabic = context.locale.languageCode == 'ar';
        return Directionality(
          textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: child!,
        );
      },
    );
  }
}