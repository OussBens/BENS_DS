import 'package:go_router/go_router.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/services/service_page.dart';
import '../../presentation/pages/projets/projet_page.dart';
import '../../presentation/pages/contact/contact_page.dart';
import '../../presentation/pages/login/login_page.dart';
import '../../presentation/pages/admin/admin_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/auth_provider.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final container = ProviderScope.containerOf(context);
    final authState = container.read(authProvider);

    // Attendre que l'auth soit initialisée
    if (!authState.isInitialized) {
      return null;
    }

    // Si l'authentification est en chargement (login en cours)
    if (authState.isLoading) {
      return null;
    }

    final isAuthenticated = authState.isAuthenticated;
    final isLoginRoute = state.matchedLocation == '/login';
    final isAdminRoute = state.matchedLocation == '/admin';

    // Routes accessibles sans authentification
    final isPublicRoute = state.matchedLocation == '/' ||
        state.matchedLocation == '/services' ||
        state.matchedLocation == '/projets' ||
        state.matchedLocation == '/contact';

    // Si l'utilisateur est admin et essaie d'accéder à une route publique
    if (isAuthenticated && isPublicRoute && !isAdminRoute) {
      return '/admin';
    }

    // Protection des routes admin (admin uniquement)
    if (isAdminRoute && !isAuthenticated) {
      return '/';
    }

    // Éviter login si déjà connecté
    if (isLoginRoute && isAuthenticated) {
      return '/admin';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/services',
      name: 'services',
      builder: (context, state) => const ServicePage(),
    ),
    GoRoute(
      path: '/projets',
      name: 'projets',
      builder: (context, state) => const ProjetPage(),
    ),
    GoRoute(
      path: '/contact',
      name: 'contact',
      builder: (context, state) => const ContactPage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/admin',
      name: 'admin',
      builder: (context, state) => const AdminPage(),
    ),
  ],
);
