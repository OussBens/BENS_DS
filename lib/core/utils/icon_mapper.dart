import 'package:flutter/material.dart';

/// Associe une clé texte (stockée en base) à une icône Material.
/// Utilisé pour les services (ex: 'web', 'mobile', 'desktop'...).
class IconMapper {
  static const Map<String, IconData> _icons = {
    'web': Icons.language_outlined,
    'mobile': Icons.phone_iphone_outlined,
    'desktop': Icons.desktop_windows_outlined,
    'cloud': Icons.cloud_outlined,
    'design': Icons.palette_outlined,
    'ui_ux': Icons.design_services_outlined,
    'database': Icons.storage_outlined,
    'api': Icons.api_outlined,
    'security': Icons.shield_outlined,
    'support': Icons.support_agent_outlined,
    'consulting': Icons.lightbulb_outline,
    'ecommerce': Icons.shopping_cart_outlined,
    'seo': Icons.trending_up_outlined,
    'maintenance': Icons.build_outlined,
  };

  static const List<MapEntry<String, IconData>> selectable = [
    MapEntry('web', Icons.language_outlined),
    MapEntry('mobile', Icons.phone_iphone_outlined),
    MapEntry('desktop', Icons.desktop_windows_outlined),
    MapEntry('cloud', Icons.cloud_outlined),
    MapEntry('design', Icons.palette_outlined),
    MapEntry('ui_ux', Icons.design_services_outlined),
    MapEntry('database', Icons.storage_outlined),
    MapEntry('api', Icons.api_outlined),
    MapEntry('security', Icons.shield_outlined),
    MapEntry('support', Icons.support_agent_outlined),
    MapEntry('consulting', Icons.lightbulb_outline),
    MapEntry('ecommerce', Icons.shopping_cart_outlined),
    MapEntry('seo', Icons.trending_up_outlined),
    MapEntry('maintenance', Icons.build_outlined),
  ];

  static IconData resolve(String key) => _icons[key] ?? Icons.apps_outlined;
}
