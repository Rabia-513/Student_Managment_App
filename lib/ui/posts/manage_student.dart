import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../widgets/round_button.dart';

class ManageStudentScreen extends StatefulWidget {
  const ManageStudentScreen({super.key});

  @override
  State<ManageStudentScreen> createState() => _ManageStudentScreenState();
}

class _ManageStudentScreenState extends State<ManageStudentScreen> {
  bool loading = false;
  bool showSearchResults = false;
  final _formKey = GlobalKey<FormState>();
  final _databaseRef = FirebaseDatabase.instance.ref('Student Data');

  final _nameController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _coursesController = TextEditingController();
  final _classController = TextEditingController();
  final _searchController = TextEditingController();

  Map<String, dynamic>? _searchedStudent;
  List<Map<String, dynamic>> _studentsList = [];

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollNumberController.dispose();
    _coursesController.dispose();
    _classController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchStudents() async {
    DataSnapshot snapshot = await _databaseRef.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> students = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _studentsList = students.entries.map((entry) {
          final studentData = entry.value as Map<dynamic, dynamic>;
          return {
            "id": entry.key,
            "name": studentData["name"],
            "rollNumber": studentData["rollNumber"],
            "courses": studentData["courses"],
            "class": studentData["class"],
          };
        }).toList();
      });
    } else {
      Fluttertoast.showToast(msg: "No students found.");
    }
  }

  void _addStudent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });

      String id = _databaseRef.push().key!;
      await _databaseRef.child(id).set({
        "name": _nameController.text.trim(),
        "rollNumber": _rollNumberController.text.trim(),
        "courses": _coursesController.text.trim(),
        "class": _classController.text.trim(),
      });

      Fluttertoast.showToast(msg: "Student added successfully!");
      _fetchStudents();
      _clearFields();
      setState(() {
        loading = false;
      });
    }
  }

  void _deleteStudent(String id) async {
    await _databaseRef.child(id).remove();
    Fluttertoast.showToast(msg: "Student deleted successfully!");
    _fetchStudents();
  }

  void _searchStudent(String query) {
    setState(() {
      _searchedStudent = _studentsList.firstWhere(
            (student) => student["name"]
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()),
        orElse: () => {},
      );
      showSearchResults = _searchedStudent != null && _searchedStudent!.isNotEmpty;
    });

    if (!showSearchResults) {
      Fluttertoast.showToast(msg: "No matching students found.");
    }
  }

  void _clearFields() {
    _nameController.clear();
    _rollNumberController.clear();
    _coursesController.clear();
    _classController.clear();
    _searchController.clear();
    setState(() {
      showSearchResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Students"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: "Search by Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onFieldSubmitted: _searchStudent,
              ),
              const SizedBox(height: 20),
              if (showSearchResults && _searchedStudent != null)
                Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Name: ${_searchedStudent!["name"]}", style: const TextStyle(fontSize: 18)),
                        Text("Roll Number: ${_searchedStudent!["rollNumber"]}", style: const TextStyle(fontSize: 18)),
                        Text("Courses: ${_searchedStudent!["courses"]}", style: const TextStyle(fontSize: 18)),
                        Text("Class: ${_searchedStudent!["class"]}", style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _deleteStudent(_searchedStudent!["id"]),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text("Delete"),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField("Name", _nameController),
                    _buildTextField("Roll Number", _rollNumberController),
                    _buildTextField("Courses", _coursesController),
                    _buildTextField("Class", _classController),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              RoundButton(
                title: "Add Student",
                loading: loading,
                onTap: _addStudent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Please enter $label";
          }
          return null;
        },
      ),
    );
  }
}
