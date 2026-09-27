import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Charte graphique du site vitrine public BENS Digital Solutions.
/// (Le back-office / login gardent le thème clair de core/theme/app_theme.dart.)
class AppColors {
  static const bg = Color(0xFF050F0E);
  static const glass = Color(0x0DFFFFFF); // blanc à 5%
  static const glassBorder = Color(0x1AFFFFFF); // blanc à 10%
  static const tealGlow = Color(0xFF22E6C8);
  static const tealDeep = Color(0xFF0F6E63);
  static const gold = Color(0xFFFFD400);
  static const white = Color(0xFFF4FBFA);
  static const muted = Color(0xFF93AFAB);
}

/// Styles de texte réutilisables pour les pages publiques (Space Grotesk =
/// titres, Inter = corps).
class AppText {
  static TextStyle h1 = GoogleFonts.spaceGrotesk(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    height: 1.15,
    letterSpacing: -0.5,
  );

  static TextStyle h2 = GoogleFonts.spaceGrotesk(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
  );

  static TextStyle h3 = GoogleFonts.spaceGrotesk(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static TextStyle eyebrow = GoogleFonts.inter(
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    color: AppColors.tealGlow,
    letterSpacing: 0.3,
  );

  static TextStyle body = GoogleFonts.inter(
    fontSize: 14.5,
    color: AppColors.muted,
    height: 1.55,
  );

  static TextStyle bodyLight = GoogleFonts.inter(
    fontSize: 14,
    color: const Color(0xFFD6E8E5),
    height: 1.5,
  );

  static TextStyle statNumber = GoogleFonts.spaceGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.gold,
  );

  static TextStyle button = GoogleFonts.inter(
    fontSize: 14.5,
    fontWeight: FontWeight.w600,
  );
}

/// Décoration "glassmorphism" réutilisée sur les cartes des pages publiques.
BoxDecoration glassDecoration({double radius = 18, Color? borderColor}) {
  return BoxDecoration(
    color: AppColors.glass,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: borderColor ?? AppColors.glassBorder),
  );
}

/// Halo de couleur diffus utilisé en arrière-plan des sections sombres.
class GlowBlob extends StatelessWidget {
  final double size;
  final Color color;

  const GlowBlob({super.key, this.size = 320, this.color = AppColors.tealGlow});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(0.28), color.withOpacity(0.0)],
          ),
        ),
      ),
    );
  }
}
