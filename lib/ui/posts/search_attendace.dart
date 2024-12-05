import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SearchAttendance extends StatefulWidget {
  const SearchAttendance({super.key});

  @override
  State<SearchAttendance> createState() => _SearchAttendanceState();
}

class _SearchAttendanceState extends State<SearchAttendance> {
  final TextEditingController _nameController = TextEditingController();
  final DatabaseReference _attendanceRef = FirebaseDatabase.instance.ref('Attendance');
  bool _isLoading = false;
  String _attendanceStatus = '';

  // Method to check the attendance
  void _checkAttendance() async {
    String studentName = _nameController.text.trim().toLowerCase(); // Convert to lowercase for case-insensitive comparison

    if (studentName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a student name!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _attendanceStatus = '';
    });

    try {
      // Fetch all data under "Attendance" node
      DataSnapshot snapshot = await _attendanceRef.get();

      if (snapshot.exists) {
        Map<String, dynamic> attendanceData = Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);

        // Check if student exists in the attendance data
        if (attendanceData.containsKey(studentName)) {
          bool isPresent = attendanceData[studentName]['present'] ?? false; // Check attendance status

          setState(() {
            _attendanceStatus = isPresent ? '$studentName is Present' : '$studentName is Absent';
          });
        } else {
          setState(() {
            _attendanceStatus = 'No attendance record found for this student!';
          });
        }
      } else {
        setState(() {
          _attendanceStatus = 'No attendance data available!';
        });
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
        title: const Text('Check Attendance'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Enter Student Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: _checkAttendance,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Check Attendance',style: TextStyle(color: Colors.white),),
            ),
            const SizedBox(height: 20),
            if (_attendanceStatus.isNotEmpty)
              Text(
                _attendanceStatus,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
