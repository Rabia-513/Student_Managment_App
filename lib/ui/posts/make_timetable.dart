import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MakeTimetable extends StatefulWidget {
  const MakeTimetable({super.key});

  @override
  State<MakeTimetable> createState() => _MakeTimetableState();
}

class _MakeTimetableState extends State<MakeTimetable> {
  final _timetableNameController = TextEditingController();
  final _dayController = TextEditingController();
  final _subjectController = TextEditingController();
  final _timeController = TextEditingController();
  final _searchController = TextEditingController();

  final List<Map<String, String>> _timetableEntries = [];
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("AdminTime_Table");

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  // Add a new entry to the local timetable list
  void _addEntry() {
    if (_dayController.text.isNotEmpty &&
        _subjectController.text.isNotEmpty &&
        _timeController.text.isNotEmpty) {
      setState(() {
        _timetableEntries.add({
          'day': _dayController.text,
          'subject': _subjectController.text,
          'time': _timeController.text,
        });
        _dayController.clear();
        _subjectController.clear();
        _timeController.clear();
      });
    }
  }

  // Save the timetable (with title and entries) to Firebase
  void _saveTimetable() {
    if (_timetableNameController.text.isEmpty || _timetableEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a name and entries!')),
      );
      return;
    }

    _dbRef.child(_timetableNameController.text).set({
      'timetableName': _timetableNameController.text,
      'entries': _timetableEntries,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Timetable saved successfully!')),
      );
      _timetableNameController.clear();
      setState(() {
        _timetableEntries.clear();
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving timetable: $error')),
      );
    });
  }

  // Search for timetables in Firebase
  void _searchTimetables() async {
    String query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchResults.clear();
    });

    try {
      DataSnapshot snapshot = await _dbRef.child(query).get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _searchResults = [
            {
              "name": data["timetableName"],
              "entries": List<Map<String, dynamic>>.from(data["entries"]),
            }
          ];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No timetable found!')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching timetable: $error')),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  // Delete a timetable entry locally
  void _deleteEntry(int index) {
    setState(() {
      _timetableEntries.removeAt(index);
    });
  }

  // Delete a timetable from Firebase
  void _deleteTimetable(String timetableName) async {
    try {
      await _dbRef.child(timetableName).remove();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Timetable "$timetableName" deleted successfully!')),
      );
      setState(() {
        _searchResults.clear();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting timetable: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Timetable',),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timetable Name Input
            TextField(
              controller: _timetableNameController,
              decoration: InputDecoration(
                labelText: 'Timetable Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Day Input
            TextField(
              controller: _dayController,
              decoration: InputDecoration(
                labelText: 'Day',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Subject Input
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Time Input
            TextField(
              controller: _timeController,
              decoration: InputDecoration(
                labelText: 'Time',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Add Entry Button
            ElevatedButton(
              onPressed: _addEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
              ),
              child: const Text('Add Entry',style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            // Timetable Entries List
            Expanded(
              child: ListView.builder(
                itemCount: _timetableEntries.length,
                itemBuilder: (context, index) {
                  final entry = _timetableEntries[index];
                  return Card(
                    elevation: 5,
                    color: Colors.teal.shade50,
                    child: ListTile(
                      title: Text('${entry['day']} - ${entry['subject']}'),
                      subtitle: Text(entry['time']!),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteEntry(index),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Save Timetable Button
            ElevatedButton(
              onPressed: _saveTimetable,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
              ),
              child: const Text('Save Timetable',style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            // Search Timetable Section

            const SizedBox(height: 10),
            if (_isSearching)
              const Center(child: CircularProgressIndicator()),
            if (!_isSearching && _searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    return Card(
                      elevation: 5,
                      child: ListTile(
                        title: Text(result["name"]),
                        subtitle: Text('Entries: ${result["entries"].length}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTimetable(result["name"]),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
