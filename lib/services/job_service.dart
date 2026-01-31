import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class JobService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ===============================
  // GET JOBS (Realtime)
  // ===============================
  Stream<QuerySnapshot> getJobs() {
    return _db
        .collection('jobs')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ===============================
  // ADD JOB
  // ===============================
  Future<void> addJob(
    String title,
    String company,
    String description,
    String location,
    File? imageFile,
  ) async {
    String? imageUrl;

    if (imageFile != null) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('job_images/$fileName');

      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
    }

    await _db.collection('jobs').add({
      'title': title,
      'company': company,
      'description': description,
      'location': location,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ===============================
  // DELETE JOB
  // ===============================
  Future<void> deleteJob(String jobId) async {
    final doc = await _db.collection('jobs').doc(jobId).get();
    final data = doc.data();

    if (data != null && data['imageUrl'] != null) {
      try {
        final ref = _storage.refFromURL(data['imageUrl']);
        await ref.delete();
      } catch (e) {
        print('Error deleting image: $e');
      }
    }

    await _db.collection('jobs').doc(jobId).delete();
  }

  // ===============================
  // UPDATE JOB (VERSI BARU – DIPAKAI ADMIN)
  // ===============================
  Future<void> updateJob(
    String jobId,
    Map<String, dynamic> data, {
    File? imageFile,
  }) async {
    String? imageUrl = data['imageUrl'];

    // Jika admin upload gambar baru
    if (imageFile != null) {
      // hapus gambar lama
      if (imageUrl != null) {
        try {
          final oldRef = _storage.refFromURL(imageUrl);
          await oldRef.delete();
        } catch (e) {
          print('Gagal hapus gambar lama: $e');
        }
      }

      // upload gambar baru
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('job_images/$fileName');

      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();

      data['imageUrl'] = imageUrl;
    }

    data['updatedAt'] = FieldValue.serverTimestamp();

    await _db.collection('jobs').doc(jobId).update(data);
  }
}
