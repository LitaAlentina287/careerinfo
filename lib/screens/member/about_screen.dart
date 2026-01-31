import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get(),
      builder: (context, snapshot) {
        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        final role = userData?['role'] ?? 'member';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul besar "Tentang Aplikasi" putih mencolok
              Row(
                children: const [
                  Icon(Icons.info_outline, size: 28, color: Colors.blue),
                  SizedBox(width: 12),
                  Text(
                    "Tentang Aplikasi",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Hanya judul ini putih
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Background biru muda tipis di bawah semua Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade50.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Card Portal Lowongan Kerja
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Row(
                              children: [
                                Icon(Icons.work, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  "Portal Lowongan Kerja",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Aplikasi mobile untuk mengelola dan mencari lowongan pekerjaan secara efisien.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black, // <-- Teks hitam
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card Tim Pengembang
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.group, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  "Tim Pengembang",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Kelompok 7",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildTeamMember(
                              Icons.person,
                              "Lita Alentina_23552011097",
                            ),
                            const SizedBox(height: 8),
                            _buildTeamMember(
                              Icons.person,
                              "Derian_23552011114",
                            ),
                            const SizedBox(height: 8),
                            _buildTeamMember(
                              Icons.person,
                              "Febry Dian Nugraha_23552011111",
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card Informasi Pengguna
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.account_circle, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  "Informasi Pengguna",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              "Role",
                              role == 'admin' ? 'Admin' : 'Member',
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow("Email", user?.email ?? '-'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card Versi Aplikasi
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const Icon(Icons.info, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Versi Aplikasi",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black, // Teks hitam
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "1.0.0",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Center(
                child: Text(
                  "© 2026 Kelompok 7. All rights reserved.",
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color.fromARGB(255, 255, 252, 252),
                  ), // Teks footer hitam
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildTeamMember(IconData icon, String name) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black), // Ikon hitam
        const SizedBox(width: 8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  static Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ),
        const Text(": ", style: TextStyle(fontSize: 14, color: Colors.black)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
