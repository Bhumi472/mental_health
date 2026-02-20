import 'package:flutter/material.dart';

class BrainPretzelPage extends StatelessWidget {
  const BrainPretzelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Brain Pretzel')),
      body: const Center(
        child: Text(
          'Brain Pretzel\nGame coming soon',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
