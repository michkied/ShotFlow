import 'package:flutter/material.dart';
import 'shot_card.dart';

class ShotlistView extends StatelessWidget {
  const ShotlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.all(16),
          sliver: SliverList.separated(
              itemCount: 3,
              itemBuilder: (BuildContext context, int index) {
                // final item = items[index];
                return CardExample();
              },
              // {
              //   final item = items[index];
              //   return ListTile(
              //       title: Text('SampleItem ${item.id}'),
              //       leading: const CircleAvatar(
              //         // Display the Flutter Logo image asset.
              //         foregroundImage:
              //             AssetImage('assets/images/flutter_logo.png'),
              //       ),
              //       onTap: () {
              //         // Navigate to the details page. If the user leaves and returns to
              //         // the app after it has been killed while running in the
              //         // background, the navigation stack is restored.
              //         Navigator.restorablePushNamed(
              //           context,
              //           SampleItemDetailsView.routeName,
              //         );
              //       });
              // },
              separatorBuilder: (context, _) => const SizedBox(height: 16)),
        ),
      ],
    );
  }
}
