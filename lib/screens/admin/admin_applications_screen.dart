import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/application_service.dart';
import 'application_detail_dialog.dart';

class AdminApplicationsScreen extends StatefulWidget {
  final String searchQuery;
  const AdminApplicationsScreen({super.key, this.searchQuery = ''});

  @override
  State<AdminApplicationsScreen> createState() =>
      _AdminApplicationsScreenState();
}

class _AdminApplicationsScreenState extends State<AdminApplicationsScreen> {
  final Map<String, String> userNameCache = {};

  /// ================= GET USER NAME =================
  Future<String> getUserName(String uid) async {
    if (userNameCache.containsKey(uid)) {
      return userNameCache[uid]!;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      final data = userDoc.data();
      final resume = data?['resume'];

      if (resume == null) {
        return 'Belum Mengisi Resume';
      }

      final name = resume['fullName'] ?? 'Tanpa Nama';
      userNameCache[uid] = name;
      return name;
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: ApplicationService().getApplicationsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Belum ada lamaran masuk"));
        }

        final apps = snapshot.data!.docs;
        final query = widget.searchQuery.toLowerCase();

        /// 🔍 FILTER SEARCH
        final filteredApps = apps.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final jobTitle = (data['jobTitle'] ?? '').toString().toLowerCase();
          final companyName = (data['companyName'] ?? '')
              .toString()
              .toLowerCase();

          return jobTitle.contains(query) || companyName.contains(query);
        }).toList();

        if (filteredApps.isEmpty) {
          return const Center(child: Text("Data tidak ditemukan"));
        }

        return ListView.builder(
          itemCount: filteredApps.length,
          itemBuilder: (context, index) {
            final doc = filteredApps[index];
            final app = doc.data() as Map<String, dynamic>;

            final applicantId = app['applicantId'];
            final status = app['status'] ?? 'pending';

            return FutureBuilder<String>(
              future: getUserName(applicantId),
              builder: (context, snapshot) {
                final name = snapshot.data ?? 'Loading...';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.blue),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Posisi: ${app['jobTitle']}"),
                        Text("Perusahaan: ${app['companyName']}"),
                      ],
                    ),
                    trailing: _statusText(status),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) =>
                            ApplicationDetailDialog(appId: doc.id, data: app),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// ================= STATUS TEXT =================
  Widget _statusText(String status) {
    Color color;
    switch (status) {
      case 'accepted':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Text(
      status.toUpperCase(),
      style: TextStyle(fontWeight: FontWeight.bold, color: color),
    );
  }
}
