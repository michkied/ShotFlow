import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'shot_card.dart';

class ShotlistView extends StatefulWidget {
  const ShotlistView({super.key});

  @override
  State<ShotlistView> createState() => _ShotlistViewState();
}

class _ShotlistViewState extends State<ShotlistView> {
  final int isLive = 7;

  List<(String, String)> items = [
    ('Shot 1', 'Operator 1'),
    ('Strings', 'Alice'),
    ('Woodwinds', 'Bob'),
    ('Brass', 'Charlie'),
    ('Percussion', 'David'),
    ('Keyboard', 'Eve'),
    ('Guitar', 'Frank'),
    ('Bass', 'Grace'),
    ('Vocals', 'Heidi'),
    ('Strings', 'Alice'),
    ('Woodwinds', 'Bob'),
    ('Brass', 'Charlie'),
    ('Percussion', 'David'),
    ('Keyboard', 'Eve'),
    ('Guitar', 'Frank'),
    ('Bass', 'Grace'),
    ('Vocals', 'Heidi')
  ];

  late ScrollController _scrollController;
  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      // Show or hide the button based on scroll position
      if (_scrollController.position.userScrollDirection !=
          ScrollDirection.idle) {
        setState(() {
          _showBackToTopButton = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToLive() {
    _scrollController.animateTo(
      isLive * 60, // Scroll to the top
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    setState(() {
      _showBackToTopButton = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsetsDirectional.all(16),
            sliver: SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (context, _) => const SizedBox(height: 5),
              itemBuilder: (BuildContext context, int index) {
                return ShotCard(
                    isLive: index == isLive,
                    index: index + 1,
                    title: items[index].$1,
                    operator: items[index].$2);
              },
            ),
          ),
        ],
      ),
      if (_showBackToTopButton)
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _scrollToLive,
            child: Icon(Icons.lock_outline),
          ),
        ),
    ]);
  }
}
