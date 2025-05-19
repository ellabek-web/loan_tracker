import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    // File? profileImage,
  }) async {
    try {
      // 1. Create Firebase Auth user
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Upload profile image (if provided)
      // String? profileImageUrl;
      // if (profileImage != null) {
      //   final Reference storageRef = _storage.ref()
      //     .child('profile_images/${credential.user!.uid}.jpg');
      //   await storageRef.putFile(profileImage);
      //   profileImageUrl = await storageRef.getDownloadURL();
      // }

      // 3. Save user data to Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        // 'profileImageUrl': profileImageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}