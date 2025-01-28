import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shotflow/src/connection/connection_controller.dart';

class DisconnectedOverlay extends StatelessWidget {
  final ConnectionController connection;

  const DisconnectedOverlay({
    super.key,
    required this.connection,
  });

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
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                child: Text(AppLocalizations.of(context)!.connectionLost),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text(AppLocalizations.of(context)!.goToLoginPage),
              ),
              SizedBox(height: 60),
              if (connection.isReconnecting) ...[
                DefaultTextStyle(
                  style: TextStyle(fontSize: 14),
                  child:
                      Text(AppLocalizations.of(context)!.attemptingToReconnect),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 10,
                  child: CircularProgressIndicator(),
                ),
              ] else ...[
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  child:
                      Text(AppLocalizations.of(context)!.cantConnectToServer),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    connection.reconnect();
                  },
                  child: Text(AppLocalizations.of(context)!.tryAgain),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
