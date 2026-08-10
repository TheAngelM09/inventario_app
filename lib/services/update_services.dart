import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ota_update/ota_update.dart';

class UpdateService {
  // CONFIGURA TUS DATOS DE GITHUB AQUÍ
  static const String _githubUser = 'TheAngelM09';
  static const String _githubRepo = 'inventario_app';

  /// Revisa si hay actualizaciones en GitHub y muestra el diálogo si existe una nueva versión
  static Future<void> checkAndPromptUpdate(BuildContext context) async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      final url = Uri.parse(
        'https://api.github.com/repos/$_githubUser/$_githubRepo/releases/latest',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        String tagName = data['tag_name'].toString().replaceAll('v', '').trim();
        String releaseNotes = data['body'] ?? 'Nuevas mejoras disponibles.';

        List assets = data['assets'];
        var apkAsset = assets.firstWhere(
              (asset) => asset['name'].toString().endsWith('.apk'),
          orElse: () => null,
        );

        if (apkAsset != null) {
          String downloadUrl = apkAsset['browser_download_url'];

          if (_isVersionNewer(tagName, currentVersion)) {
            if (context.mounted) {
              _showUpdateDialog(context, tagName, releaseNotes, downloadUrl);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error comprobando actualización: $e');
    }
  }

  static bool _isVersionNewer(String latest, String current) {
    try {
      List<int> latestParts = latest.split('.').map(int.parse).toList();
      List<int> currentParts = current.split('.').map(int.parse).toList();

      for (int i = 0; i < latestParts.length; i++) {
        if (i >= currentParts.length) return true;
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }
    } catch (e) {
      debugPrint('Error al comparar versiones: $e');
    }
    return false;
  }

  static void _showUpdateDialog(
      BuildContext context,
      String newVersion,
      String releaseNotes,
      String apkUrl,
      ) {
    double progress = 0.0;
    bool isDownloading = false;
    String statusText = 'Actualización disponible';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text('Versión $newVersion disponible'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isDownloading) ...[
                      const Text(
                        'Novedades:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(releaseNotes),
                    ] else ...[
                      Text(statusText),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress / 100,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('${progress.toStringAsFixed(0)}%'),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                if (!isDownloading)
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Más tarde'),
                  ),
                if (!isDownloading)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        isDownloading = true;
                        statusText = 'Iniciando descarga...';
                      });
                      try {
                        OtaUpdate().execute(
                          apkUrl,
                          destinationFilename: 'update.apk',
                        ).listen(
                              (OtaEvent event) {
                            setState(() {
                              if (event.status == OtaStatus.DOWNLOADING) {
                                statusText = 'Descargando APK...';
                                progress = double.tryParse(event.value ?? '0') ?? 0;
                              } else if (event.status == OtaStatus.INSTALLING) {
                                statusText = 'Abriendo instalador...';
                                Navigator.pop(dialogContext);
                              } else if (event.status == OtaStatus.PERMISSION_NOT_GRANTED_ERROR) {
                                statusText = 'Permisos no concedidos.';
                                isDownloading = false;
                              } else if (event.status == OtaStatus.INTERNAL_ERROR) {
                                statusText = 'Error en la descarga.';
                                isDownloading = false;
                              }
                            });
                          },
                          onError: (e) {
                            setState(() {
                              statusText = 'Error de conexión.';
                              isDownloading = false;
                            });
                          },
                        );
                      } catch (e) {
                        setState(() {
                          statusText = 'No se pudo iniciar la actualización.';
                          isDownloading = false;
                        });
                      }
                    },
                    child: const Text('Actualizar'),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}