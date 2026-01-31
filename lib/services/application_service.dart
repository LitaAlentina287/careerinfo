import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApplicationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ======================================================
  // ======================= ADMIN ========================
  // ======================================================

  /// ADMIN: Ambil SEMUA lamaran (untuk dashboard admin)
  Stream<QuerySnapshot> getApplicationsStream() {
    return _db
        .collection('applications')
        .orderBy('appliedAt', descending: true)
        .snapshots();
  }

  /// ADMIN: Update status lamaran (accepted / rejected)
  Future<void> updateStatus(String appId, String newStatus) async {
    await _db.collection('applications').doc(appId).update({
      'status': newStatus,
    });
  }

  /// ADMIN: Hapus lamaran
  Future<void> deleteApplication(String appId) async {
    await _db.collection('applications').doc(appId).delete();
  }

  // ======================================================
  // ======================= MEMBER =======================
  // ======================================================

  /// MEMBER: Apply ke job
  Future<void> applyToJob({
    required String jobId,
    required String jobTitle,
    required String companyName,
    required String coverLetter,
    required String resumeUrl,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    await _db.collection('applications').add({
      'jobId': jobId,
      'jobTitle': jobTitle,
      'companyName': companyName,
      'applicantId': uid, // 🔑 KUNCI FILTER
      'resumeUrl': resumeUrl,
      'coverLetter': coverLetter,
      'status': 'pending',
      'appliedAt': FieldValue.serverTimestamp(),
    });
  }

  /// MEMBER: Lihat SEMUA lamaran MILIK SENDIRI
  Stream<QuerySnapshot> getMyApplications() {
    final uid = _auth.currentUser?.uid;

    // Jika belum login → stream kosong (tidak crash)
    if (uid == null) {
      return const Stream.empty();
    }

    return _db
        .collection('applications')
        .where('applicantId', isEqualTo: uid) // 🔥 FILTER USER LOGIN
        .orderBy('appliedAt', descending: true)
        .snapshots();
  }
}
