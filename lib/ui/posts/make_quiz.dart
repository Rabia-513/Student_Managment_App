import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MakeQuizScreen extends StatefulWidget {
  const MakeQuizScreen({super.key});

  @override
  State<MakeQuizScreen> createState() => _MakeQuizScreenState();
}

class _MakeQuizScreenState extends State<MakeQuizScreen> {
  final _quizTitleController = TextEditingController();
  final _searchController = TextEditingController();
  final _databaseRef = FirebaseDatabase.instance.ref('Make_Quiz');
  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> _filteredQuestions = [];

  final _questionController = TextEditingController();
  final _optionAController = TextEditingController();
  final _optionBController = TextEditingController();
  final _optionCController = TextEditingController();
  final _optionDController = TextEditingController();
  String? _correctOption;

  @override
  void dispose() {
    _quizTitleController.dispose();
    _questionController.dispose();
    _optionAController.dispose();
    _optionBController.dispose();
    _optionCController.dispose();
    _optionDController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addQuestion() {
    if (_questionController.text.trim().isEmpty ||
        _optionAController.text.trim().isEmpty ||
        _optionBController.text.trim().isEmpty ||
        _optionCController.text.trim().isEmpty ||
        _optionDController.text.trim().isEmpty ||
        _correctOption == null) {
      Fluttertoast.showToast(msg: "Please fill in all fields and select the correct option.");
      return;
    }

    setState(() {
      _questions.add({
        "question": _questionController.text.trim(),
        "options": {
          "A": _optionAController.text.trim(),
          "B": _optionBController.text.trim(),
          "C": _optionCController.text.trim(),
          "D": _optionDController.text.trim(),
        },
        "correctAnswer": _correctOption,
      });

      _filteredQuestions = List.from(_questions); // Update filtered list
      _clearQuestionFields();
    });
  }

  void _clearQuestionFields() {
    _questionController.clear();
    _optionAController.clear();
    _optionBController.clear();
    _optionCController.clear();
    _optionDController.clear();
    _correctOption = null;
  }

  void _saveQuiz() async {
    if (_quizTitleController.text.trim().isEmpty || _questions.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please provide a title and add at least one question.");
      return;
    }

    // Show a confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Save Quiz",
          style: TextStyle(color: Colors.black),
        ),
        content: const Text("Are you sure you want to save this quiz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.purple),
            ),
          ),
        ],
      ),
    );

    if (confirm == null || !confirm) {
      return; // Exit if the user cancels
    }

    try {
      // Generate a unique ID for the quiz
      String quizId = _databaseRef.push().key!;

      // Prepare data for saving
      Map<String, dynamic> quizData = {
        "id": quizId,
        "title": _quizTitleController.text.trim(),
        "questions": _questions,
        "created_at": DateTime.now().toIso8601String(), // Add timestamp
      };

      // Save to Firebase
      await _databaseRef.child(quizId).set(quizData);

      // Provide feedback to the user
      Fluttertoast.showToast(msg: "Quiz saved successfully!");

      // Clear form and reset state
      setState(() {
        _quizTitleController.clear();
        _questions.clear();
        _filteredQuestions.clear();
      });
    } catch (error) {
      Fluttertoast.showToast(msg: "Failed to save quiz. Please try again.");
      debugPrint("Error saving quiz: $error");
    }
  }


  void _deleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
      _filteredQuestions = List.from(_questions);
    });
    Fluttertoast.showToast(msg: "Question deleted successfully.");
  }

  void _searchQuestions(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredQuestions = List.from(_questions);
      } else {
        _filteredQuestions = _questions
            .where((q) => q["question"].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Make a Quiz",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.purple[400],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _quizTitleController,
                decoration: const InputDecoration(
                  labelText: "Quiz Title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Add a Question",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: "Question",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _optionAController,
                decoration: const InputDecoration(
                  labelText: "Option A",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _optionBController,
                decoration: const InputDecoration(
                  labelText: "Option B",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _optionCController,
                decoration: const InputDecoration(
                  labelText: "Option C",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _optionDController,
                decoration: const InputDecoration(
                  labelText: "Option D",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Correct Answer",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  _buildRadioOption("A"),
                  _buildRadioOption("B"),
                  _buildRadioOption("C"),
                  _buildRadioOption("D"),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[400], // Background color
                  // Full-width button
                ),
                onPressed: _addQuestion,
                child: const Text("Add Question",style: TextStyle(color: Colors.white),),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                onChanged: _searchQuestions,
                decoration: const InputDecoration(
                  labelText: "Search Questions",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Questions List",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _filteredQuestions.isNotEmpty
                  ? ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredQuestions.length,
                itemBuilder: (context, index) {
                  final question = _filteredQuestions[index];
                  return Card(
                    child: ListTile(
                      title: Text(question["question"]),
                      subtitle: Text("Correct Answer: ${question["correctAnswer"]}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteQuestion(index),
                      ),
                    ),
                  );
                },
              )
                  : const Text("No questions found."),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveQuiz,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[400]),
                child: Text("Save Quiz",style: TextStyle(color: Colors.white),),

              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioOption(String option) {
    return Row(
      children: [
        Radio<String>(
          value: option,
          groupValue: _correctOption,
          onChanged: (value) {
            setState(() {
              _correctOption = value;
            });
          },
        ),
        Text(option),
      ],
    );
  }
}
