import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResumeService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  Future<Map<String, dynamic>?> getResume() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final snap = await _db.collection('users').doc(uid).get();
    return snap.data()?['resume'];
  }

  Future<void> saveResume({
    required String fullName,
    required String phone,
    required String education,
    required String experience,
    required List<String> skills,
    String? photoUrl,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _db.collection('users').doc(uid).set({
      'resume': {
        'fullName': fullName,
        'phone': phone,
        'education': education,
        'experience': experience,
        'skills': skills,
        if (photoUrl != null) 'photoUrl': photoUrl,
      },
    }, SetOptions(merge: true));
  }

  Future<String?> uploadPhoto() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;

    final file = File(picked.path);

    final ref = _storage.ref().child('resume_photos/$uid.jpg');
    await ref.putFile(file);

    return await ref.getDownloadURL();
  }

  Future<void> updatePhotoUrl(String url) async {
    final uid = _auth.currentUser?.uid;
    await _db.collection('users').doc(uid).set({
      'resume': {'photoUrl': url},
    }, SetOptions(merge: true));
  }
}
