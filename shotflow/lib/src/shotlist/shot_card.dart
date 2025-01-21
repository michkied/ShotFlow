import 'package:flutter/material.dart';

class ShotCard extends StatelessWidget {
  const ShotCard(
      {super.key,
      required this.isLive,
      required this.index,
      required this.title,
      required this.operator});

  final bool isLive;
  final int index;
  final String title;
  final String operator;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin:
            isLive ? null : EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        elevation: isLive ? 10 : 0,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 5.0, bottom: 5.0),
              child: SizedBox(
                  width: 70,
                  child: Text(index.toString(),
                      style: const TextStyle(fontSize: 30))),
            ),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 25)),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(operator),
            ),
          ],
        ),
        // child: ListTile(
        //   leading: Text(widget.index.toString(),
        //       style: const TextStyle(fontSize: 25)),
        //   contentPadding: isLive
        //       ? const EdgeInsets.all(16.0)
        //       : const EdgeInsets.symmetric(horizontal: 16.0),
        //   title: Text(widget.title, style: const TextStyle(fontSize: 20)),
        //   // subtitle: Text(widget.operator),
        //   onTap: () => setState(() => isLive = !isLive),
        // ),
      ),
    );
  }
}
