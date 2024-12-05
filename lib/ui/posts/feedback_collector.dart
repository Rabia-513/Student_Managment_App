import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class FeedbackCollector extends StatefulWidget {
  const FeedbackCollector({super.key});

  @override
  State<FeedbackCollector> createState() => _FeedbackCollectorState();
}

class _FeedbackCollectorState extends State<FeedbackCollector> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref("Feedback");
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  String _feedbackMessage = '';

  // Save feedback to Firebase Realtime Database
  Future<void> _submitFeedback() async {
    final String name = _nameController.text.trim();
    final String feedback = _feedbackController.text.trim();

    if (name.isEmpty || feedback.isEmpty) {
      setState(() {
        _feedbackMessage = "Please fill out all fields.";
      });
      return;
    }

    try {
      final feedbackData = {
        'name': name,
        'feedback': feedback,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await _databaseReference.push().set(feedbackData);
      setState(() {
        _feedbackMessage = "Thank you for your feedback!";
        _nameController.clear();
        _feedbackController.clear();
      });
    } catch (e) {
      setState(() {
        _feedbackMessage = "Failed to submit feedback. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback Collector',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      )  ,backgroundColor: Colors.indigo,),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'We value your feedback!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Name field
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Feedback field
            TextField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                labelText: 'Your Feedback',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            // Submit button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
              ),
              onPressed: _submitFeedback,
              child: const Text('Submit Feedback',style: TextStyle(color: Colors.white),),
            ),
            const SizedBox(height: 20),
            // Feedback message
            if (_feedbackMessage.isNotEmpty)
              Text(
                _feedbackMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: _feedbackMessage == "Thank you for your feedback!"
                      ? Colors.green
                      : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
