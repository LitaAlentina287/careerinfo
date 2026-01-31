import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/resume_service.dart';

class ResumeScreen extends StatefulWidget {
  const ResumeScreen({super.key});

  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  final r = ResumeService();
  bool loading = true;
  bool uploadingPhoto = false;
  Map<String, dynamic>? resume;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    resume = await r.getResume();
    setState(() => loading = false);
  }

  Future<void> changePhoto() async {
    setState(() => uploadingPhoto = true);

    final url = await r.uploadPhoto();
    if (url != null) {
      await r.updatePhotoUrl(url);
      await load();
    }

    setState(() => uploadingPhoto = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Resume", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ===== BACKGROUND IMAGE =====
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/resume.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ===== OVERLAY GELAP =====
          Container(color: Colors.black.withOpacity(0.35)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: resume == null
                  ? Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text("Isi Resume"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditResumeScreen(),
                            ),
                          ).then((_) => load());
                        },
                      ),
                    )
                  : ListView(
                      children: [
                        // ===== HEADER PROFILE =====
                        Card(
                          color: Colors.white.withOpacity(0.95),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: changePhoto,
                                      child: CircleAvatar(
                                        radius: 42,
                                        backgroundColor: Colors.blue.shade800,
                                        backgroundImage:
                                            resume!['photoUrl'] != null
                                            ? NetworkImage(resume!['photoUrl'])
                                            : null,
                                        child: resume!['photoUrl'] == null
                                            ? const Icon(
                                                Icons.person,
                                                size: 42,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                    ),
                                    if (uploadingPhoto)
                                      const Positioned(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        resume!['fullName'],
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.phone,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            resume!['phone'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ===== DETAIL RESUME =====
                        Card(
                          color: Colors.white.withOpacity(0.95),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitle("Pendidikan"),
                                _sectionText(resume!['education']),
                                const Divider(height: 24),

                                _sectionTitle("Pengalaman"),
                                _sectionText(resume!['experience']),
                                const Divider(height: 24),

                                _sectionTitle("Skills"),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: (resume!['skills'] as List).map((
                                    e,
                                  ) {
                                    return Chip(
                                      label: Text(e),
                                      backgroundColor: Colors.blue.shade50,
                                      side: BorderSide(
                                        color: Colors.blue.shade200,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text("Edit Resume"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade800,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditResumeScreen(),
                              ),
                            ).then((_) => load());
                          },
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade800,
        ),
      ),
    );
  }

  Widget _sectionText(String text) {
    return Text(text, style: const TextStyle(fontSize: 15));
  }
}

// ================= EDIT RESUME SCREEN =================

class EditResumeScreen extends StatefulWidget {
  const EditResumeScreen({super.key});

  @override
  State<EditResumeScreen> createState() => _EditResumeScreenState();
}

class _EditResumeScreenState extends State<EditResumeScreen> {
  final fullNameC = TextEditingController();
  final phoneC = TextEditingController();
  final educationC = TextEditingController();
  final experienceC = TextEditingController();
  final skillsC = TextEditingController();
  final r = ResumeService();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await r.getResume();
    if (data != null) {
      fullNameC.text = data['fullName'];
      phoneC.text = data['phone'];
      educationC.text = data['education'];
      experienceC.text = data['experience'];
      skillsC.text = (data['skills'] as List).join(", ");
    }
    setState(() => loading = false);
  }

  Future<void> save() async {
    if (fullNameC.text.isEmpty || phoneC.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Nama & No HP wajib diisi")));
      return;
    }

    await r.saveResume(
      fullName: fullNameC.text,
      phone: phoneC.text,
      education: educationC.text,
      experience: experienceC.text,
      skills: skillsC.text.split(",").map((e) => e.trim()).toList(),
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Resume", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/resume.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.35)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                _input(fullNameC, "Nama Lengkap", Icons.person),
                _input(phoneC, "No HP", Icons.phone),
                _input(educationC, "Pendidikan", Icons.school),
                _input(experienceC, "Pengalaman", Icons.work_outline),
                _input(skillsC, "Skills (pisahkan dengan koma)", Icons.build),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("SIMPAN"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(TextEditingController c, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue.shade800),
          filled: true,
          fillColor: Colors.white.withOpacity(0.95),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
