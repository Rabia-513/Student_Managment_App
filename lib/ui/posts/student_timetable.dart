import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class StudentTimetable extends StatefulWidget {
  const StudentTimetable({super.key});

  @override
  State<StudentTimetable> createState() => _StudentTimetableState();
}

class _StudentTimetableState extends State<StudentTimetable> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("StudentTimeTable");
  final TextEditingController _timetableNameController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  List<Map<String, dynamic>> _allTimetables = [];
  bool _isLoading = false;

  // Fetch all timetables from the "StudentTimeTable" node
  void _fetchAllTimetables() async {
    setState(() {
      _isLoading = true;
      _allTimetables.clear();
    });

    try {
      DataSnapshot snapshot = await _dbRef.get();

      if (snapshot.exists) {
        Map<String, dynamic> timetablesData = Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);
        List<Map<String, dynamic>> timetables = [];
        timetablesData.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            timetables.add({
              "key": key,
              ...Map<String, dynamic>.from(value),
            });
          }
        });

        setState(() {
          _allTimetables = timetables;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No timetables available!')),
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

  // Add a new timetable to "StudentTimeTable"
  void _addTimetable() async {
    String name = _timetableNameController.text.trim();
    String day = _dayController.text.trim();
    String subject = _subjectController.text.trim();
    String title = _titleController.text.trim();
    String time = _timeController.text.trim();

    if (name.isEmpty || day.isEmpty || subject.isEmpty || title.isEmpty || time.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required!')),
      );
      return;
    }

    try {
      await _dbRef.push().set({
        "name": name,
        "day": day,
        "subject": subject,
        "title": title,
        "time": time,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Timetable added successfully!')),
      );
      _fetchAllTimetables();
      _clearInputs();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  // Delete a timetable by key
  void _deleteTimetable(String key) async {
    try {
      await _dbRef.child(key).remove();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Timetable deleted successfully!')),
      );
      _fetchAllTimetables();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  // Clear input fields
  void _clearInputs() {
    _timetableNameController.clear();
    _dayController.clear();
    _subjectController.clear();
    _titleController.clear();
    _timeController.clear();
  }

  @override
  void initState() {
    super.initState();
    _fetchAllTimetables();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Timetables',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.teal[400],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _timetableNameController,
              decoration: const InputDecoration(labelText: 'Timetable Name'),
            ),
            TextField(
              controller: _dayController,
              decoration: const InputDecoration(labelText: 'Day'),
            ),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(labelText: 'Time'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              onPressed: _addTimetable,
              child: const Text('Add Timetable',style: TextStyle(color: Colors.white),),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (!_isLoading && _allTimetables.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _allTimetables.length,
                  itemBuilder: (context, index) {
                    final timetable = _allTimetables[index];
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        title: Text('Name: ${timetable['name']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Day: ${timetable['day']}'),
                            Text('Subject: ${timetable['subject']}'),
                            Text('Title: ${timetable['title']}'),
                            Text('Time: ${timetable['time']}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTimetable(timetable['key']),
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (!_isLoading && _allTimetables.isEmpty)
              const Text(
                'No timetables found!',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
