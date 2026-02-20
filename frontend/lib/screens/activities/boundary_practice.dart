import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BoundaryPractice extends StatefulWidget {
  const BoundaryPractice({super.key});

  @override
  State<BoundaryPractice> createState() => _BoundaryPracticeState();
}

class _BoundaryPracticeState extends State<BoundaryPractice> {
  // Survey State
  bool _isSurveyComplete = false;
  String? _selectedGoal;
  String? _selectedSituation;

  // Practice State
  int _turnIndex = 0; // Tracks conversation depth
  List<ChatMessage> _messages = [];
  bool _showOptions = false;
  ScenarioTree? _activeScenario;

  final List<String> _goals = [
    "Being Assertive",
    "Being Polite",
    "Being Less Passive",
  ];

  final List<String> _situations = [
    "Work/Office",
    "Family",
    "Friends",
    "School/College",
  ];

  void _startPractice() {
    // Select specific scenario based on situation
    _activeScenario = _getScenarioForSituation(_selectedSituation!);
    setState(() {
      _isSurveyComplete = true;
      _turnIndex = 0;
      _messages.clear();
      _addMessage(ChatMessage(
        text: _activeScenario!.nodes[0]!.message,
        isUser: false,
      ));
      _showOptions = true;
    });
  }

  // Define Multi-turn Scenarios
  ScenarioTree _getScenarioForSituation(String situation) {
    if (situation == "Work/Office") {
      return ScenarioTree(
        nodes: {
          0: ScenarioNode( // Turn 1
             message: "Hey, can you finish that report tonight? I know it's late.",
             options: [
               Option("Sure, I'll do it.", BoundaryType.passive, 1),
               Option("I can't tonight, but early tomorrow.", BoundaryType.assertive, 2),
               Option("No, it's 9 PM!", BoundaryType.aggressive, 3),
             ]
          ),
          1: ScenarioNode( // User picked Passive
             message: "Thanks! I knew I could count on you. Also, can you check the emails?",
             options: [
               Option("Okay...", BoundaryType.passive, 99), // 99 = End
               Option("I definitely can't do emails too.", BoundaryType.assertive, 99),
             ]
          ),
          2: ScenarioNode( // User picked Assertive
             message: "But I really need it for the 8 AM meeting properly formatted.",
             options: [
               Option("Fine, I'll stay up.", BoundaryType.passive, 99),
               Option("I'll send a draft now, format it tomorrow.", BoundaryType.assertive, 99),
             ]
          ),
          3: ScenarioNode( // User picked Aggressive
             message: "Wow, okay. No need to yell. I'll just ask someone else.",
             options: [
               Option("Good.", BoundaryType.aggressive, 99),
               Option("Sorry, I'm just tired.", BoundaryType.assertive, 99),
             ]
          ),
          // Add more depth if needed, but 2-3 turns is good for demo
        }
      );
    } else {
       // Placeholder for other scenarios to prevent null errors
       return ScenarioTree(
        nodes: {
           0: ScenarioNode(
             message: "Default Scenario: Can you help me?",
             options: [
                Option("Yes", BoundaryType.passive, 99),
                Option("No", BoundaryType.assertive, 99),
             ]
           )
        }
       );
    }
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
  }

  void _handleOptionSelected(Option option) async {
    setState(() => _showOptions = false);
    
    // User reply
    _addMessage(ChatMessage(text: option.text, isUser: true));
    await Future.delayed(const Duration(seconds: 1));

    // Determine Next Step
    if (option.nextNodeId == 99) {
       _showFinalReport();
    } else {
       // Continue conversation
       final nextNode = _activeScenario!.nodes[option.nextNodeId];
       if (nextNode != null) {
          _addMessage(ChatMessage(text: nextNode.message, isUser: false));
          setState(() {
             _turnIndex = option.nextNodeId; // Or manage by node ID directly
             // We need to update the OPTIONS to match this new node
             _showOptions = true;
          });
       }
    }
  }
  
  void _showFinalReport() {
    _addMessage(ChatMessage(
      text: "Interaction Complete.",
      isUser: false, 
      isSystem: true
    ));
    
    setState(() {
       _messages.add(ChatMessage(
          text: "View Feedback Report",
          isUser: false,
          isSystem: true,
          isAction: true,
          onAction: () {
             showDialog(context: context, builder: (ctx) => AlertDialog(
                title: const Text("Feedback Report"),
                content: const Text("You navigated the scenario well! \n\nGoal: Assertiveness. \nResult: You maintained your boundaries in 2/3 turns."),
                actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Done"))],
             ));
          }
       ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Boundary Practice'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_isSurveyComplete) {
              setState(() => _isSurveyComplete = false); // Go back to survey
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: _isSurveyComplete ? _buildChatInterface() : _buildSurveyInterface(),
    );
  }

  Widget _buildSurveyInterface() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "What do you want to work on?",
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._goals.map((goal) => _buildRadioOption(
            goal, 
            _selectedGoal == goal, 
            () => setState(() => _selectedGoal = goal)
          )),
          
          const SizedBox(height: 32),
          Text(
            "Choose a situation:",
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: _situations.map((sit) => ChoiceChip(
              label: Text(sit),
              selected: _selectedSituation == sit,
              onSelected: (selected) => setState(() => _selectedSituation = sit),
              selectedColor: const Color(0xFF6B9BD1),
              labelStyle: TextStyle(color: _selectedSituation == sit ? Colors.white : Colors.black),
            )).toList(),
          ),

          const Spacer(),
          ElevatedButton(
            onPressed: (_selectedGoal != null && _selectedSituation != null) 
              ? _startPractice 
              : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B9BD1),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Start Practice", style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6B9BD1).withOpacity(0.1) : Colors.white,
          border: Border.all(color: selected ? const Color(0xFF6B9BD1) : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? const Color(0xFF6B9BD1) : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(text, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInterface() {
     // Identify current node options
     // If turnIndex matches a node in _activeScenario, show those options
     List<Option> currentOptions = [];
     if (_showOptions && _activeScenario != null && _activeScenario!.nodes.containsKey(_turnIndex)) {
        currentOptions = _activeScenario!.nodes[_turnIndex]!.options;
     } else if (_showOptions && _turnIndex != 0) {
        // Fallback for sub-nodes if logic gets complex, using turnIndex as NodeID
        if (_activeScenario!.nodes.containsKey(_turnIndex)) {
           currentOptions = _activeScenario!.nodes[_turnIndex]!.options;
        }
     }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              if (msg.isSystem) {
                 if (msg.isAction) {
                    return Center(
                       child: Padding(
                         padding: const EdgeInsets.symmetric(vertical: 20),
                         child: ElevatedButton(
                           onPressed: msg.onAction,
                           style: ElevatedButton.styleFrom(
                             backgroundColor: const Color(0xFF6B9BD1),
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                           ),
                           child: const Text("View Report", style: TextStyle(color: Colors.white)),
                         ),
                       ),
                     );
                 }
                 return Text(msg.text, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey));
              }
              
              return Align(
                alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  decoration: BoxDecoration(
                    color: msg.isUser ? const Color(0xFF6B9BD1) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: msg.isUser ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: msg.isUser ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Text(msg.text, style: GoogleFonts.inter(color: msg.isUser ? Colors.white : Colors.black87)),
                ),
              );
            },
          ),
        ),
        if (_showOptions)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: currentOptions.map((option) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OutlinedButton(
                    onPressed: () => _handleOptionSelected(option),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      side: const BorderSide(color: Color(0xFFCBD5E0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.centerLeft,
                    ),
                    child: Text(option.text, style: GoogleFonts.inter(color: const Color(0xFF2D3748))),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isSystem;
  final bool isAction;
  final VoidCallback? onAction;
  final Color? color;
  final IconData? icon;

  ChatMessage({required this.text, required this.isUser, this.isSystem = false, this.isAction = false, this.onAction, this.color, this.icon});
}

// Multi-turn Structure
class ScenarioTree {
  final Map<int, ScenarioNode> nodes; // ID -> Node
  ScenarioTree({required this.nodes});
}

class ScenarioNode {
  final String message;
  final List<Option> options;
  ScenarioNode({required this.message, required this.options});
}

class Option {
  final String text;
  final BoundaryType type;
  final int nextNodeId; // Pointer to next node
  Option(this.text, this.type, this.nextNodeId);
}

enum BoundaryType { passive, assertive, aggressive }
