// lib/core/config.dart
class ApiConfig {
  // Backend NestJS/Prisma local (à remplacer par le domaine de prod une fois déployé)
  static const String baseUrl = 'http://localhost:3000';
  static const String apiBaseUrl = '$baseUrl/api';
  static const int apiTimeout = 30000;

  // Auth
  static String get authLogin => '$apiBaseUrl/auth/login';
  static String get authVerify => '$apiBaseUrl/auth/verify';
  static String get authLogout => '$apiBaseUrl/auth/logout';

  // Uploads
  static String get uploadImage => '$apiBaseUrl/uploads/image';
  static String get uploadVideo => '$apiBaseUrl/uploads/video';

  // Projets
  static String get projects => '$apiBaseUrl/projects';

  // Services
  static String get services => '$apiBaseUrl/services';

  // Témoignages
  static String get testimonials => '$apiBaseUrl/testimonials';

  // Messages de contact
  static String get contactMessages => '$apiBaseUrl/contact-messages';

  // Coordonnées de l'entreprise
  static String get companyInfo => '$apiBaseUrl/company-info';
}
