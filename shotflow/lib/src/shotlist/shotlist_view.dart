import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:shotflow/src/connection/connection_controller.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shotflow/src/shotlist/next_shot_bar.dart';
import 'shot_card.dart';

class ShotlistView extends StatefulWidget {
  const ShotlistView({super.key});

  @override
  State<ShotlistView> createState() => _ShotlistViewState();
}

class _ShotlistViewState extends State<ShotlistView> {
  final _scrollController = ItemScrollController();
  bool _showBackToTopButton = false;
  bool _isAutoScrolling = true;
  int _currentlyLive = 0;

  void _scrollToLive() async {
    await _autoScroll();
    setState(() {
      _showBackToTopButton = false;
    });
  }

  Future<void> _autoScroll() async {
    _isAutoScrolling = true;
    await _scrollController.scrollTo(
        index: _currentlyLive,
        alignment: 0.1,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut);
    _isAutoScrolling = false;
  }

  Widget getShotlistWidget() {
    return Consumer<ConnectionController>(
      builder: (context, connection, child) {
        return Builder(builder: (context) {
          if (connection.shotlist.isEmpty) {
            return Center(
              child: Text("shhh... you're disturbing the silence"),
            );
          }

          SchedulerBinding.instance.addPostFrameCallback((_) {
            _currentlyLive = connection.currentlyLive;
            if (!_showBackToTopButton) {
              _autoScroll();
            }
          });

          return NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollUpdateNotification) {
                if (!_showBackToTopButton && !_isAutoScrolling) {
                  setState(() {
                    _showBackToTopButton = true;
                  });
                }
              }
              return true;
            },
            child: ScrollablePositionedList.builder(
              itemScrollController: _scrollController,
              itemCount: connection.shotlist.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 16.0),
                  child: ShotCard(
                    operatorId: connection.operatorId,
                    currentlyLive: connection.currentlyLive,
                    entry: connection.shotlist[index],
                  ),
                );
              },
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Expanded(
            child: Stack(children: [
          getShotlistWidget(),
          if (_showBackToTopButton)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: _scrollToLive,
                child: Icon(Icons.lock_outline),
              ),
            ),
        ])),
        SizedBox(height: 70, child: NextShotBar())
      ],
    );
  }
}
