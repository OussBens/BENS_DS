import 'package:flutter/material.dart';

class AppConstants {
  // Palette BENS DIGITAL SOLUTIONS
  static const Color primaryDark = Color(0xFF00415F);
  static const Color primaryDarkEnd = Color(0xFF008E96);
  static const Color teal = Color(0xFF00BEB7);
  static const Color cyan = Color(0xFF00F5F2);
  static const Color yellow = Color(0xFFFFDA13);

  // Accent utilisé pour les CTA / états actifs (hover un ton plus foncé)
  static const Color accent = yellow;
  static const Color accentHover = Color(0xFFE0C011);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primaryDarkEnd],
  );

  static const LinearGradient tealCyanGradient = LinearGradient(
    colors: [teal, cyan],
  );

  // Catégories de projets (filtre de la galerie)
  static const List<String> projectCategories = ['Tous', 'Web', 'Mobile', 'Desktop', 'Autre'];
}
