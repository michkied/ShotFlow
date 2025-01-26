import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:shotflow/src/connection/connection_controller.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Consumer<ConnectionController>(
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
            ],
          ),
        ),
        Consumer<ConnectionController>(builder: (context, connection, child) {
          final nextEntry = connection.getNextEntry();
          if (connection.shotlist.isEmpty) {
            return Container();
          }

          if (nextEntry.$1 == -1) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("That's all! Good job ;)"),
            );
          }

          if (nextEntry.$1 == 0) {
            return SizedBox(
              height: 70,
              child: Center(
                child: Text(
                  "You're live!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }

          return SizedBox(
            height: 70,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Your next shot:'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      nextEntry.$2!.title,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, bottom: 8.0, left: 30, right: 10),
                      child: Text(
                        'in',
                        style: TextStyle(
                            fontWeight: FontWeight.w100, fontSize: 12),
                      ),
                    ),
                    Text(
                      nextEntry.$1.toString(),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                  ],
                )
              ],
            ),
          );
        })
      ],
    );
  }
}
