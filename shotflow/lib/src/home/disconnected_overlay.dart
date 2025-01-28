import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shotflow/src/connection/connection_controller.dart';

class DisconnectedOverlay extends StatelessWidget {
  const DisconnectedOverlay({
    super.key,
    required this.connection,
  });
  final ConnectionController connection;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                child: Text(AppLocalizations.of(context)!.connectionLost),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text(AppLocalizations.of(context)!.goToLoginPage),
              ),
              const SizedBox(height: 60),
              if (connection.isReconnecting) ...[
                DefaultTextStyle(
                  style: const TextStyle(fontSize: 14),
                  child:
                      Text(AppLocalizations.of(context)!.attemptingToReconnect),
                ),
                const SizedBox(height: 10),
                const SizedBox(
                  height: 10,
                  child: CircularProgressIndicator(),
                ),
              ] else ...[
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  child:
                      Text(AppLocalizations.of(context)!.cantConnectToServer),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: connection.reconnect,
                  child: Text(AppLocalizations.of(context)!.tryAgain),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
