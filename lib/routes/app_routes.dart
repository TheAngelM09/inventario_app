import 'package:flutter/material.dart';
import '../screens/login.dart';
import '../screens/home.dart';

class AppRoutes {
  static const String login = '/';
  static const String inventory = '/inventory';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case inventory:
        final responsibleName = (settings.arguments is String) ? settings.arguments as String : '';
        return MaterialPageRoute(
          builder: (_) => InventoryScreen(responsibleName: responsibleName),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
          settings: settings,
        );
    }
  }
}
