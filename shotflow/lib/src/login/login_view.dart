import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shotflow/src/connection/connection_controller.dart';

import '../connection/types.dart';

class LoginView extends StatelessWidget {
  final TextEditingController urlController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();

  LoginView({super.key});

  Future<void> login(
      ConnectionController connection, BuildContext context) async {
    final url = urlController.text;
    final token = tokenController.text;

    ConnectionStatus status = await connection.connect(url, token);
    if (!context.mounted) {
      return;
    }

    switch (status) {
      case ConnectionStatus.success:
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case ConnectionStatus.invalidToken:
        _showErrorMessage(context, 'Invalid token. Please try again.');
        break;
      case ConnectionStatus.connectionError:
        _showErrorMessage(context, 'Connection error. Please try again.');
        break;
    }
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
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.videocam,
                size: 100.0,
              ),
              Text(
                'ShotFlow',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 32.0),
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  labelText: 'URL',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: tokenController,
                decoration: InputDecoration(
                  labelText: 'Token',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              Consumer<ConnectionController>(
                builder: (context, connection, child) {
                  return ElevatedButton(
                    onPressed: () => login(connection, context),
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: Text(
                  'or',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle QR code scan logic here
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                          Icon(Icons.qr_code, size: 30.0, color: Colors.white),
                    ),
                    Text('Scan QR Code',
                        style: TextStyle(color: Colors.white, fontSize: 16.0)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
