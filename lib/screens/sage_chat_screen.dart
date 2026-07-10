import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../widgets/gradient_background.dart';

class SageChatScreen extends StatefulWidget {
  const SageChatScreen({super.key});

  @override
  State<SageChatScreen> createState() => _SageChatScreenState();
}

class _SageChatScreenState extends State<SageChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;

  final List<Map<String, dynamic>> messages = [
    {
      "isUser": false,
      "text":
          "👋 Hi! I'm Sage, your AI Career Counselor.\n\nWhether you're confused about choosing a career, exploring higher studies, comparing jobs, or planning your future, I'm here to help.\n\nAsk me anything! 🌱",
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final question = _controller.text.trim();

    setState(() {
      messages.add({
        "isUser": true,
        "text": question,
      });

      _isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    final reply = await GeminiService.askGemini(
      careerData: "",
      userQuestion: question,
    );

    setState(() {
      _isTyping = false;

      messages.add({
        "isUser": false,
        "text": reply,
      });
    });

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "🤖 Sage",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Your AI Career Counselor",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        body: Column(
          children: [

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {

                  final message = messages[index];

                  return Align(
                    alignment: message["isUser"]
                        ? Alignment.centerRight
                        : Alignment.centerLeft,

                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(14),

                      constraints: const BoxConstraints(
                        maxWidth: 420,
                      ),

                      decoration: BoxDecoration(
                        color: message["isUser"]
                            ? const Color(0xFF8B5CF6)
                            : const Color(0xFFE8D9FF),

                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(
                            message["isUser"] ? 18 : 4,
                          ),
                          bottomRight: Radius.circular(
                            message["isUser"] ? 4 : 18,
                          ),
                        ),
                      ),

                      child: Text(
                        message["text"],
                        style: TextStyle(
                          color: message["isUser"]
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_isTyping)
              const Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  bottom: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "🤖 Sage is thinking...",
                    style: TextStyle(
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),

                child: Row(
                  children: [

                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(
                          color: Colors.white,
                        ),

                        decoration: InputDecoration(
                          hintText: "Ask Sage anything...",
                          hintStyle: const TextStyle(
                            color: Colors.white70,
                          ),

                          filled: true,
                          fillColor: Colors.white.withOpacity(0.15),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),

                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),

                    const SizedBox(width: 8),

                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFC8A8E9),

                      child: IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),

                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}