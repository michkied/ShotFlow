import 'package:flutter/material.dart';
import 'package:shotflow/src/connection/types.dart';

class ShotCard extends StatelessWidget {
  const ShotCard(
      {super.key,
      required this.operatorId,
      required this.currentlyLive,
      required this.entry});

  final int operatorId;
  final int currentlyLive;
  final ShotlistEntry entry;
  bool get isLive => currentlyLive == entry.id;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin:
            isLive ? null : EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        elevation: isLive ? 10 : 0,
        color: operatorId == entry.operatorId
            ? Colors.blueAccent
            : currentlyLive > entry.id
                ? Colors.grey[800]
                : null,
        shape: isLive
            ? RoundedRectangleBorder(
                side: BorderSide(color: Colors.red, width: 5.0),
                borderRadius: BorderRadius.circular(16.0),
              )
            : null,
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: 16.0,
                  top: isLive ? 15.0 : 5.0,
                  bottom: isLive ? 15.0 : 5.0),
              child: SizedBox(
                  width: 70,
                  child: Text(entry.id.toString(),
                      style: const TextStyle(fontSize: 30))),
            ),
            Expanded(
              child: Text(entry.title, style: const TextStyle(fontSize: 25)),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(entry.operatorName),
            ),
          ],
        ),
      ),
    );
  }
}
