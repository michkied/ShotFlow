import 'dart:convert';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shotflow/src/connection/connection_controller.dart';
import 'package:shotflow/src/login/qr_scan_view.dart';

import '../connection/types.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController urlController = TextEditingController();

  final TextEditingController tokenController = TextEditingController();

  bool isLoggingIn = false;

  Future<void> login(
    ConnectionController connection,
    BuildContext context,
  ) async {
    setState(() {
      isLoggingIn = true;
    });
    final url = urlController.text;
    final token = tokenController.text;

    final status = await connection.connect(url, token);
    if (!context.mounted) {
      return;
    }

    switch (status) {
      case ConnectionResult.success:
        await Navigator.of(context).pushReplacementNamed('/home');
      case ConnectionResult.invalidToken:
        _showErrorMessage(context, AppLocalizations.of(context)!.invalidToken);
      case ConnectionResult.connectionError:
        _showErrorMessage(
          context,
          AppLocalizations.of(context)!.connectionError,
        );
    }
    setState(() {
      isLoggingIn = false;
    });
  }

  void _showErrorMessage(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.black,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectionController>(
      builder: (context, connection, child) {
        if (connection.isConnected) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/home');
          });
          return Container();
        }
        return Scaffold(
          body: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons.videocam,
                          size: 100,
                        ),
                        Text(
                          AppLocalizations.of(context)!.appTitle,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextField(
                          controller: urlController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.urlLabel,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: tokenController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.tokenLabel,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => login(connection, context),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              AppLocalizations.of(context)!.login,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        if (defaultTargetPlatform == TargetPlatform.iOS ||
                            defaultTargetPlatform == TargetPlatform.android ||
                            kIsWeb)
                          Padding(
                            padding: const EdgeInsets.all(28),
                            child: Text(
                              AppLocalizations.of(context)!.or,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (defaultTargetPlatform == TargetPlatform.iOS ||
                            defaultTargetPlatform == TargetPlatform.android ||
                            kIsWeb)
                          ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute<String?>(
                                  builder: (context) => const QRViewScreen(),
                                ),
                              );
                              if (result != null) {
                                try {
                                  final scanData = jsonDecode(result)
                                      as Map<String, dynamic>;
                                  urlController.text =
                                      scanData['url'].toString();
                                  tokenController.text =
                                      scanData['token'].toString();
                                  if (context.mounted) {
                                    await login(connection, context);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    _showErrorMessage(
                                      context,
                                      AppLocalizations.of(context)!.invalidQR,
                                    );
                                  }

                                  debugPrint('Error parsing QR Code JSON: $e');
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(Icons.qr_code, size: 30),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.scanQRButton,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isLoggingIn || connection.isReconnecting)
                Positioned.fill(
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.black.withAlpha(200),
                    child: const CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
