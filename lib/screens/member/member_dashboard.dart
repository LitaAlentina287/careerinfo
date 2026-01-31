import 'package:flutter/material.dart';
import 'job_list_screen.dart';
import 'my_applications_screen.dart';
import 'profile_screen.dart';
import 'about_screen.dart';

class MemberDashboard extends StatefulWidget {
  const MemberDashboard({super.key});

  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  int index = 0;

  final pages = const [
    JobListScreen(),
    MyApplicationsScreen(),
    ProfileScreen(),
    AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Member", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/member.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Overlay gelap
          Container(color: Colors.black.withOpacity(0.3)),

          // Page aktif
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: pages[index],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.blue.shade600.withOpacity(0.9),
        type: BottomNavigationBarType.fixed, // WAJIB karena 4 item
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work), label: "Lowongan"),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "Lamaran",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "About"),
        ],
      ),
    );
  }
}
