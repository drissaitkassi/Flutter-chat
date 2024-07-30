import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import '../consts/const.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _openAI = OpenAI.instance.build(token: OPEN_AI_KEY, enableLog: true);
  final ChatUser _currentUser =
      ChatUser(id: '1', firstName: 'Driss', lastName: 'AIT KASSI');
  final ChatUser _assistante =
      ChatUser(id: '2', firstName: 'CHAT', lastName: 'GPT');

  List<ChatMessage> _chatMessages = <ChatMessage>[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        title: const Text('Chat Bot Open AI'),
      ),
      body: DashChat(
        currentUser: _currentUser,
        onSend: (ChatMessage m) {
          getChatMessage(m);
        },
        messages: _chatMessages,
      ),
    );
  }

  Future<void> getChatMessage(ChatMessage m) async {
    setState(() {
      _chatMessages.insert(0, m);
    });

    List<Messages> _messageHistory = _chatMessages.reversed.map((m) {
      if (m.user == _currentUser) {
        return Messages(role: Role.user, content: m.text);
      } else {
        return Messages(role: Role.assistant, content: m.text);
      }
    }).toList();
    final request = ChatCompleteText(
        model: Gpt4ChatModel(),
        messages: [
          Messages(role: Role.user, content: m.text, name: "last user mesage")
              .toJson()
        ],
        maxToken: 200);

    final response = await _openAI.onChatCompletion(request: request);
    for (var element in response!.choices) {
      if (element.message != null) {
        setState(() {
          _chatMessages.insert(
              0,
              ChatMessage(
                  user: _assistante,
                  createdAt: DateTime.now(),
                  text: element.message!.content));
        });
      }
    }
  }
}
