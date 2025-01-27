import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shotflow/src/connection/connection_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NextShotBar extends StatelessWidget {
  const NextShotBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child:
          Consumer<ConnectionController>(builder: (context, connection, child) {
        final nextEntry = connection.getNextEntry();
        if (connection.shotlist.isEmpty) {
          return Container();
        }

        if (nextEntry.$1 == -1) {
          return Center(
            child: Text(AppLocalizations.of(context)!.allDone),
          );
        }

        if (nextEntry.$1 == 0) {
          return Container(
            color: Colors.red,
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.youreLive,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(AppLocalizations.of(context)!.nextShot),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  nextEntry.$2!.title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, bottom: 8.0, left: 30, right: 10),
                  child: Text(
                    AppLocalizations.of(context)!.approx,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Text(
                  '${nextEntry.$1} s',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
              ],
            )
          ],
        );
      }),
    );
  }
}
