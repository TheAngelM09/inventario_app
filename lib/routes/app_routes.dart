import 'package:go_router/go_router.dart';
import 'package:invbar/screens/home.dart';
import 'package:invbar/screens/login.dart';
import '../main.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  navigatorKey: navigatorKey,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home/:id',
      builder: (context, state) {
        final idResponsible = state.pathParameters['id'];
        return HomeScreen(idResponsible: idResponsible ?? '');
      }
    )
  ],
);