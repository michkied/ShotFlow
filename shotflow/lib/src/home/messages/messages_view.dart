import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:shotflow/src/connection/types.dart';
import 'package:shotflow/src/home/messages/message_bubble.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../connection/connection_controller.dart';

class MessagesView extends StatefulWidget {
  const MessagesView({super.key});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  void _sendMessage(ConnectionController connection, String text) async {
    if (text.isNotEmpty) {
      setState(() {
        connection.sendChatMessage(text);
        controller.clear();
      });
    }
  }

  void _scrollToBottom() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent + 200,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  Widget getListOfMessages(List<ChatMessage> messages) {
    return Expanded(
      child: CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return MessageBubble(message: messages[index]);
              },
              childCount: messages.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget getQuickResponseMenu(ConnectionController connection) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _sendMessage(connection, '👍'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Icon(Icons.thumb_up, color: Colors.white, size: 24),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _sendMessage(connection, '👎'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Icon(Icons.thumb_down, color: Colors.white, size: 24),
          ),
        ),
      ],
    );
  }

  Widget getMessageBox(ConnectionController connection) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.messageBox,
              border: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(16.0))),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: () => _sendMessage(connection, controller.text),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
    return Consumer<ConnectionController>(
        builder: (context, connection, child) {
      final messages = connection.chatMessages;
      connection.unreadMessages = 0;
      return Column(
        children: <Widget>[
          getListOfMessages(messages),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                getMessageBox(connection),
                SizedBox(height: 8),
                getQuickResponseMenu(connection),
              ],
            ),
          ),
        ],
      );
    });
  }
}
