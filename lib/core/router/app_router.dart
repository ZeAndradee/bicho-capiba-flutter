import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/adocoes/screens/adocoes_screen.dart';
import '../../features/adocoes/screens/adoption_form_screen.dart';
import '../../features/adote/screens/adote_screen.dart';
import '../../features/animal/screens/animal_detail_screen.dart';
import '../../features/auth/providers/auth_controller.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/register_success_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/categorias/screens/categorias_screen.dart';
import '../../features/favoritos/screens/favoritos_screen.dart';
import '../../features/perfil/screens/perfil_screen.dart';
import '../../models/animal.dart';
import '../widgets/app_shell.dart';

const _guestAllowed = {'/welcome', '/entrar', '/cadastro'};
const _authedToHome = {'/splash', '/welcome', '/entrar'};

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  return GoRouter(
    initialLocation: '/adote',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: '/entrar', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/cadastro', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/cadastro-sucesso',
        builder: (_, state) =>
            RegisterSuccessScreen(nome: state.uri.queryParameters['nome']),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/adote', builder: (_, _) => const AdoteScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/categorias',
                builder: (_, _) => const CategoriasScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/adocoes',
                builder: (_, _) => const AdocoesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favoritos',
                builder: (_, _) => const FavoritosScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/perfil', builder: (_, _) => const PerfilScreen()),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/animal/:id',
        builder: (context, state) =>
            AnimalDetailScreen(animalId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/adotar',
        builder: (context, state) =>
            AdoptionFormScreen(animal: state.extra as Animal),
      ),
    ],
  );
});

class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  _RouterNotifier(this._ref) {
    _ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final status = _ref.read(authControllerProvider).status;
    final loc = state.matchedLocation;

    if (status == AuthStatus.loading) {
      return loc == '/splash' ? null : '/splash';
    }

    final loggedIn = status == AuthStatus.authenticated;

    if (!loggedIn) {
      return _guestAllowed.contains(loc) ? null : '/welcome';
    }

    if (_authedToHome.contains(loc)) return '/adote';
    return null;
  }
}
