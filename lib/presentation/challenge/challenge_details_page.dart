import 'package:flutter/material.dart';

class ChallengeDetailsPage extends StatelessWidget {
  const ChallengeDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Challenge Details')),
      body: const Center(
        child: Text(
          'This is the Challenge Details Page (Demo)',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
} 