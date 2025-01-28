import 'package:flutter/material.dart';
import 'package:shotflow/src/connection/types.dart';

class ShotCard extends StatelessWidget {
  const ShotCard({
    super.key,
    required this.operatorId,
    required this.currentlyLive,
    required this.entry,
  });

  final int operatorId;
  final int currentlyLive;
  final ShotlistEntry entry;
  bool get isLive => currentlyLive == entry.id;
  bool get isHighlited => operatorId == entry.operatorId;
  bool get isPast => currentlyLive > entry.id;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        shape: isLive
            ? RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        margin: isLive
            ? null
            : const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        elevation: isLive ? 10 : 0,
        color: isHighlited
            ? Theme.of(context).colorScheme.primaryContainer
            : isPast
                ? Theme.of(context).colorScheme.surfaceBright
                : null,
        child: DefaultTextStyle(
          style: TextStyle(
            color: isHighlited
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: SizedBox(
                  width: 20,
                  child: Text(
                    entry.id.toString(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: SizedBox(
                  width: 60,
                  child: Text(
                    '${entry.duration} s',
                    style: const TextStyle(fontSize: 25),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: isLive ? 20.0 : 10.0),
                  child:
                      Text(entry.title, style: const TextStyle(fontSize: 25)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16, left: 8),
                child: Text(entry.operatorName),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
