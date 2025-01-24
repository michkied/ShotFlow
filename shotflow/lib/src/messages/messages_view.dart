import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ChatMessage {
  ChatMessage(
      {required this.isOperator, required this.text, required this.name});

  final bool isOperator;
  final String name;
  final String text;
}

class MessagesView extends StatefulWidget {
  const MessagesView({super.key});

  @override
  _MessagesViewState createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  final List<ChatMessage> _messages = List.generate(
    20,
    (index) => ChatMessage(
      isOperator: index % 2 == 0,
      text: 'This is the message content $index.',
      name: 'User $index',
    ),
  );

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage(String text) async {
    if (text.isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(
          isOperator: true,
          text: text,
          name: 'You',
        ));
        _controller.clear();
      });
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 100,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
    return Column(
      children: <Widget>[
        Expanded(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final message = _messages[index];
                    return Align(
                      alignment: message.isOperator
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 2 / 3,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: message.isOperator
                                ? Colors.grey[800]
                                : Colors.grey[900],
                            borderRadius:
                                BorderRadius.circular(16.0), // Rounded corners
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                message.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(message.text),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: _messages.length,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _sendMessage('👍'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child:
                          Icon(Icons.thumb_up, color: Colors.white, size: 24),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _sendMessage('👎'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child:
                          Icon(Icons.thumb_down, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
