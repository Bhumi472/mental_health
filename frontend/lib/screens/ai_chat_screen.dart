import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AiTone { casual, supportive, professional, empathetic }

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  AiTone _selectedTone = AiTone.supportive;

  @override
  void initState() {
    super.initState();
    // Initial Greeting
    _messages.add(ChatMessage(
      text: "Hello! I'm your Mental Health companion. How are you feeling right now?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    
    final text = _controller.text;
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
      _controller.clear();
    });

    // Mock Response
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: _getMockResponse(text),
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    });
  }

  String _getMockResponse(String input) {
    if (input.toLowerCase().contains("sad")) return "I'm sorry to hear that. I'm here for you.";
    if (input.toLowerCase().contains("tired")) return "It sounds like you need some rest. Have you tried the Breathing exercise?";
    return "Tell me more about that. I'm listening.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI Companion", style: GoogleFonts.poppins(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          DropdownButton<AiTone>(
            value: _selectedTone,
            underline: Container(),
            icon: const Icon(Icons.tune, color: Colors.blue),
            items: AiTone.values.map((tone) {
              return DropdownMenuItem(
                value: tone,
                child: Text(tone.name.toUpperCase(), style: const TextStyle(fontSize: 12)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedTone = val);
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: msg.isUser ? Colors.blue.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: msg.isUser ? const Radius.circular(16) : const Radius.circular(4),
                        bottomRight: msg.isUser ? const Radius.circular(4) : const Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      msg.text,
                      style: GoogleFonts.inter(color: Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}
