import 'package:ecomerce/ui/posts/make_quiz.dart';
import 'package:ecomerce/ui/posts/make_timetable.dart';
import 'package:ecomerce/ui/posts/manage_attendence.dart';
import 'package:ecomerce/ui/posts/manage_student.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // Placeholder stats
  int totalStudents = 120;
  double attendancePercentage = 85.5;
  double averageGrades = 3.7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Stats Section
            const Text(
              "Quick Stats",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Using Wrap to handle screen size
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatCard(
                  title: "Total Students",
                  value: "$totalStudents",
                  icon: Icons.group,
                  color: Colors.blue,
                ),
                _buildStatCard(
                  title: "Attendance %",
                  value: "$attendancePercentage%",
                  icon: Icons.bar_chart,
                  color: Colors.green,
                ),
                _buildStatCard(
                  title: "Avg Grades",
                  value: "$averageGrades",
                  icon: Icons.grade,
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Action Buttons Section
            const Text(
              "Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildActionButton(
                    context,
                    title: "Manage Students",
                    icon: Icons.school,
                    color: Colors.lightBlue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageStudentScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionButton(
                    context,
                    title: "Attendance",
                    icon: Icons.check_circle_outline,
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Attendance(),
                        ),
                      );
                    },
                  ),
                  _buildActionButton(
                    context,
                    title: "Quiz",
                    icon: Icons.quiz,
                    color: Colors.deepPurple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MakeQuizScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionButton(
                    context,
                    title: "Timetable",
                    icon: Icons.calendar_today,
                    color: Colors.indigo,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MakeTimetable(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: (MediaQuery.of(context).size.width - 72) / 3, // Adjusted to fit within the screen
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 50),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance Screen")),
      body: const Center(child: Text("Attendance functionality here.")),
    );
  }
}
