import 'package:flutter/material.dart';
import '../../services/application_service.dart';

class ApplicationDetailDialog extends StatefulWidget {
  final String appId;
  final Map<String, dynamic> data;

  const ApplicationDetailDialog({
    super.key,
    required this.appId,
    required this.data,
  });

  @override
  State<ApplicationDetailDialog> createState() =>
      _ApplicationDetailDialogState();
}

class _ApplicationDetailDialogState extends State<ApplicationDetailDialog> {
  Map<String, dynamic>? resume;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      resume = widget.data['resume'];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final status = widget.data['status'] ?? 'pending';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= JOB INFO =================
              Text(
                widget.data['jobTitle'] ?? 'Unknown Job',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.data['companyName'] ?? '-',
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 8),
              Text("Status: $status"),
              const Divider(height: 24),

              // ================= RESUME =================
              const Text(
                "Resume Pelamar",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),

              if (resume != null) ...[
                if (resume!['photoUrl'] != null)
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(resume!['photoUrl']),
                    ),
                  ),
                const SizedBox(height: 10),

                _info("Nama", resume!['fullName']),
                _info("No HP", resume!['phone']),
                _info("Pendidikan", resume!['education']),
                _info("Pengalaman", resume!['experience']),
                _info(
                  "Skills",
                  resume!['skills'] is List
                      ? (resume!['skills'] as List).join(', ')
                      : '-',
                ),
              ] else ...[
                const Text("Resume belum diisi oleh pelamar."),
              ],

              const SizedBox(height: 20),

              // ================= COVER LETTER =================
              const Text(
                "Cover Letter",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(widget.data['coverLetter'] ?? '-'),

              const SizedBox(height: 24),

              // ================= ACTION BUTTON =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () async {
                      await ApplicationService().updateStatus(
                        widget.appId,
                        'accepted',
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text("ACCEPT"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      await ApplicationService().updateStatus(
                        widget.appId,
                        'rejected',
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text("REJECT"),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ================= DELETE BUTTON =================
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    "HAPUS LAMARAN",
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Hapus Lamaran"),
                        content: const Text(
                          "Apakah kamu yakin ingin menghapus lamaran ini?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("BATAL"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("HAPUS"),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await ApplicationService().deleteApplication(
                        widget.appId,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                ),
              ),

              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("TUTUP"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HELPER =================
  Widget _info(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text("$label: ${value ?? '-'}"),
    );
  }
}
