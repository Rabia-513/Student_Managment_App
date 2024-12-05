import 'package:ecomerce/ui/posts/admin_screen.dart';
import 'package:ecomerce/ui/auth/login_screen.dart';
import 'package:ecomerce/ui/posts/student_screen.dart';
import 'package:ecomerce/utills/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
 // Import your profile screen

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final auth = FirebaseAuth.instance;

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                auth.signOut().then((value) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                }).onError((error, stackTrace) {
                  Utils().toastMessage(error.toString());
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToProfileScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  StudentScreen()),
    );
  }

  void _navigateToBusinessScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>AdminScreen()),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text("Post Screen", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        actions: [
          IconButton(
            onPressed: () {
              _showLogoutConfirmationDialog(context);
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [


          Expanded(
            child: GestureDetector(
              onTap: _navigateToBusinessScreen,
              child: Card(
                margin: EdgeInsets.all(16.0),
                child: Center(
                  child: ListTile(
                    leading: Icon(Icons.admin_panel_settings, color: Colors.blue, size: 48),
                    title: Text("Adimin", style: TextStyle(fontSize: 24)),
                    subtitle: Text("View Admin interface"),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _navigateToProfileScreen,
              child: Card(
                margin: EdgeInsets.all(16.0),
                child: Center(
                  child: ListTile(
                    leading: Icon(Icons.person_2, color: Colors.blue, size: 48),
                    title: Text("Student", style: TextStyle(fontSize: 24)),
                    subtitle: Text("View Student Interface"),
                  ),
                ),
              ),
            ),
          ),


        ],
      ),
    );
  }
}