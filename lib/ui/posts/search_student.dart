import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SearchStudent extends StatefulWidget {
  const SearchStudent({super.key});

  @override
  State<SearchStudent> createState() => _SearchStudentState();
}

class _SearchStudentState extends State<SearchStudent> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("Student Data");
  Map<String, dynamic>? _studentData;
  bool _isLoading = false;

  void _searchStudent() async {
    String studentName = _searchController.text.trim();

    if (studentName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a student name!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _studentData = null; // Reset previous data
    });

    try {
      // Fetch all students from the "Student Data" node
      DataSnapshot snapshot = await _dbRef.get();

      if (snapshot.exists) {
        Map<String, dynamic> students = Map<String, dynamic>.from(
            snapshot.value as Map<dynamic, dynamic>);

        // Search for the student by name
        bool studentFound = false;
        students.forEach((key, value) {
          if (value['name'] == studentName) {
            setState(() {
              _studentData = Map<String, dynamic>.from(value);
            });
            studentFound = true;
          }
        });

        if (!studentFound) {
          setState(() {
            _studentData = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student not found!')),
          );
        }
      } else {
        setState(() {
          _studentData = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No student data available!')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Student',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter Student Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchStudent,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (!_isLoading && _studentData != null)
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _studentData!.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            if (!_isLoading && _studentData == null && _searchController.text.isNotEmpty)
              const Text(
                'No data found!',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
