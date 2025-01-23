import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:shotflow/src/connection/connection_controller.dart';
import 'shot_card.dart';

class ShotlistView extends StatefulWidget {
  const ShotlistView({super.key});

  @override
  State<ShotlistView> createState() => _ShotlistViewState();
}

class _ShotlistViewState extends State<ShotlistView> {
  late ScrollController _scrollController;
  bool _showBackToTopButton = false;
  bool _isScrollLocked = true;
  int _currentlyLive = 7;

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
          _isScrollLocked = false;
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
      _currentlyLive * 60,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    setState(() {
      _showBackToTopButton = false;
      _isScrollLocked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<ConnectionController>(
          builder: (context, connection, child) {
            return Builder(builder: (context) {
              if (connection.shotlist.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              _currentlyLive = connection.currentlyLive;
              if (_isScrollLocked) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  _scrollController.animateTo(
                    connection.currentlyLive *
                        (context.size!.height / connection.shotlist.length),
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                });
              }

              return CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsetsDirectional.all(16),
                    sliver: SliverList.separated(
                      itemCount: connection.shotlist.length,
                      separatorBuilder: (context, _) =>
                          const SizedBox(height: 5),
                      itemBuilder: (BuildContext context, int index) {
                        return ShotCard(
                          operatorId: connection.operatorId,
                          currentlyLive: connection.currentlyLive,
                          entry: connection.shotlist[index],
                        );
                      },
                    ),
                  ),
                ],
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
    );
  }
}
