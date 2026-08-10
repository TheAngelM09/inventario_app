import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import '../services/update_services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green.shade600,
        ),
      ),
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,
      // Usamos el builder para capturar el BuildContext global y lanzar la verificación
      builder: (context, child) {
        return UpdateCheckerWrapper(child: child ?? const SizedBox());
      },
    );
  }
}

/// Wrapper que ejecuta la verificación de GitHub al iniciar
class UpdateCheckerWrapper extends StatefulWidget {
  final Widget child;
  const UpdateCheckerWrapper({super.key, required this.child});

  @override
  State<UpdateCheckerWrapper> createState() => _UpdateCheckerWrapperState();
}

class _UpdateCheckerWrapperState extends State<UpdateCheckerWrapper> {
  @override
  void initState() {
    super.initState();
    // Revisa actualizaciones de GitHub inmediatamente tras dibujar la pantalla inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService.checkAndPromptUpdate(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}