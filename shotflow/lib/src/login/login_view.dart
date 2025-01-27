import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:shotflow/src/connection/connection_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shotflow/src/login/qr_scan_view.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

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
      ConnectionController connection, BuildContext context) async {
    setState(() {
      isLoggingIn = true;
    });
    final url = urlController.text;
    final token = tokenController.text;

    ConnectionResult status = await connection.connect(url, token);
    if (!context.mounted) {
      return;
    }

    switch (status) {
      case ConnectionResult.success:
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case ConnectionResult.invalidToken:
        _showErrorMessage(context, AppLocalizations.of(context)!.invalidToken);
        break;
      case ConnectionResult.connectionError:
        _showErrorMessage(
            context, AppLocalizations.of(context)!.connectionError);
        break;
    }
    setState(() {
      isLoggingIn = false;
    });
  }

  void _showErrorMessage(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.videocam,
                          size: 100.0,
                        ),
                        Text(
                          AppLocalizations.of(context)!.appTitle,
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 32.0),
                        TextField(
                          controller: urlController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.urlLabel,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        TextField(
                          controller: tokenController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.tokenLabel,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          obscureText: true,
                        ),
                        SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () => login(connection, context),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              AppLocalizations.of(context)!.login,
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ),
                        ),
                        if (Platform.isAndroid || Platform.isIOS || kIsWeb)
                          Padding(
                            padding: const EdgeInsets.all(28.0),
                            child: Text(
                              AppLocalizations.of(context)!.or,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (Platform.isAndroid || Platform.isIOS || kIsWeb)
                          ElevatedButton(
                            onPressed: () async {
                              final result = (await Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          QRViewScreen()))) as String?;
                              if (result != null) {
                                try {
                                  final scanData = jsonDecode(result);
                                  urlController.text = scanData['url'];
                                  tokenController.text = scanData['token'];
                                  if (context.mounted) {
                                    login(connection, context);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    _showErrorMessage(
                                        context,
                                        AppLocalizations.of(context)!
                                            .invalidQR);
                                  }

                                  debugPrint('Error parsing QR Code JSON: $e');
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(Icons.qr_code, size: 30.0),
                                  ),
                                  Text(
                                      AppLocalizations.of(context)!
                                          .scanQRButton,
                                      style: TextStyle(fontSize: 18.0)),
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
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
