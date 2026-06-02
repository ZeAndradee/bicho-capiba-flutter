import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/adote/screens/adote_screen.dart';
import '../../features/animal/screens/animal_detail_screen.dart';
import '../../features/auth/providers/auth_controller.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../widgets/app_shell.dart';

const _authRoutes = {'/welcome', '/entrar', '/cadastro'};

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: '/entrar', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/cadastro', builder: (_, _) => const RegisterScreen()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, _) => const AdoteScreen()),
          GoRoute(path: '/adote', builder: (_, _) => const AdoteScreen()),
        ],
      ),
      GoRoute(
        path: '/animal/:id',
        builder: (context, state) =>
            AnimalDetailScreen(animalId: state.pathParameters['id']!),
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
    final onAuthFlow = _authRoutes.contains(loc) || loc == '/splash';

    if (!loggedIn) {
      return _authRoutes.contains(loc) ? null : '/welcome';
    }

    if (onAuthFlow) return '/';
    return null;
  }
}
