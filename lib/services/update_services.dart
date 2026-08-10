import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ota_update/ota_update.dart';
import '../main.dart';

class UpdateService {
  static const String _githubUser = 'TheAngelM09';
  static const String _githubRepo = 'inventario_app';

  static Future<void> checkForUpdate() async {
    try {

      final url = Uri.parse('https://api.github.com/repos/$_githubUser/$_githubRepo/releases/latest');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        String rawTag = data['tag_name'] ?? '';
        String latestVersion = rawTag.replaceAll('v', '').trim();

        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String currentVersion = packageInfo.version;

        if (latestVersion != currentVersion) {

          String? apkUrl;
          List assets = data['assets'] ?? [];
          for (var asset in assets) {
            if (asset['name'].toString().endsWith('.apk')) {
              apkUrl = asset['browser_download_url'];
              break;
            }
          }

          final context = navigatorKey.currentContext;
          if (context != null && context.mounted) {
            _showUpdateDialog(context, latestVersion, apkUrl);
          }
        }
      }
    } catch (e) {
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al buscar actualizaciones')),
        );
      }
    }
  }

  static void _showUpdateDialog(BuildContext context, String newVersion, String? apkUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Actualización disponible'),
          content: Text('Hay una nueva versión disponible ($newVersion). ¿Deseas descargarla e instalarla ahora?'),
          actions: [
            TextButton(
              child: const Text('Más tarde'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              child: const Text('Actualizar'),
              onPressed: () {
                Navigator.of(ctx).pop();
                if (apkUrl != null) {
                  _startDownloadWithProgress(context, apkUrl);
                }
              },
            ),
          ],
        );
      },
    );
  }

  static void _startDownloadWithProgress(BuildContext context, String downloadUrl) {
    double progress = 0;
    String statusText = 'Iniciando descarga...';
    void Function(void Function())? updateDialogState;

    // Mostrar ventana con la barra de progreso
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            updateDialogState = setDialogState;

            return PopScope(
              canPop: false, // Evita cerrar el cuadro mientras descarga
              child: AlertDialog(
                title: const Text('Descargando actualización'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(statusText, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: progress > 0 ? progress / 100 : null,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${progress.toInt()}%',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    // Ejecutar descarga con OTA Update
    try {
      OtaUpdate().execute(downloadUrl, destinationFilename: 'app-release.apk').listen((OtaEvent event) {

          double parsedValue = double.tryParse(event.value ?? '0') ?? 0;

          if (updateDialogState != null) {
            updateDialogState!(() {
              progress = parsedValue;
              if (event.status == OtaStatus.DOWNLOADING) {
                statusText = 'Descargando paquete de actualización...';
              } else if (event.status == OtaStatus.INSTALLING) {
                statusText = 'Abriendo instalador del sistema...';
              }
            });
          }

          // Al pasar a la fase de instalación, se cierra la ventana de progreso
          if (event.status == OtaStatus.INSTALLING) {
            Future.delayed(const Duration(milliseconds: 500), () {
              final ctx = navigatorKey.currentContext;
              if (ctx != null && ctx.mounted){
                Navigator.of(ctx, rootNavigator: true).pop();
              }
            });
          }
        },
        onError: (error) {
          if (updateDialogState != null) {
            updateDialogState!(() {
              statusText = 'Error en la descarga. Inténtalo de nuevo.';
            });
          }
        },
      );
    } catch (e) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inesperado: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}