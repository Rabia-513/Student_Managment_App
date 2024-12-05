import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<Attendance> {
  final DatabaseReference _studentDataRef = FirebaseDatabase.instance.ref("Student Data");
  final DatabaseReference _attendanceRef = FirebaseDatabase.instance.ref("Attendance");
  final Map<String, bool> _attendance = {}; // Stores attendance: {studentName: isPresent}
  final TextEditingController _classController = TextEditingController(); // Controller for search input
  bool _isLoading = false; // To show loading indicator during data fetch

  void _fetchStudentData(String className) async {
    setState(() {
      _isLoading = true; // Start loading indicator
      _attendance.clear(); // Clear previous attendance data
    });

    try {
      final DataSnapshot snapshot = await _studentDataRef.get(); // Fetch all data from StudentData
      if (snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);

        setState(() {
          // Filter students by matching the "class" field
          data.forEach((key, value) {
            if (value['class'].toString() == className) {
              _attendance[value['name']] = false; // Initialize all as not present
            }
          });
          _isLoading = false; // Stop loading indicator
        });

        // Show a message if no students are found for the given class
        if (_attendance.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No students found for class $className")),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        debugPrint("No data found in StudentData.");
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      debugPrint("Error fetching data: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch data.")),
      );
    }
  }

  void _saveAttendance() async {
    final attendanceData = _attendance.map((name, isPresent) => MapEntry(name, {"present": isPresent}));

    try {
      // Save attendance data under the "Attendance" table in Firebase
      await _attendanceRef.set(attendanceData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Attendance saved successfully!")),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save attendance.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mark Attendance"),
        backgroundColor: Colors.teal[400],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _classController,
                    decoration: const InputDecoration(
                      labelText: "Enter Class",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[400], // Background color
                   // Full-width button
                  ),
                  onPressed: () {

                    if (_classController.text.isNotEmpty) {
                      _fetchStudentData(_classController.text.trim());
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter a class name.")),
                      );
                    }
                  },
                  child: const Text("Search",style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
            child: _attendance.isEmpty
                ? const Center(child: Text("No students found."))
                : ListView(
              children: _attendance.keys.map((studentName) {
                return CheckboxListTile(
                  title: Text(studentName),
                  value: _attendance[studentName],
                  onChanged: (bool? value) {
                    setState(() {
                      _attendance[studentName] = value ?? false;
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _attendance.isNotEmpty ? _saveAttendance : null,
        child: const Icon(Icons.save,color:Colors.teal,size:50,),
        tooltip: "Save Attendance",
      ),
    );
  }
}
