import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Store user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'fullName': fullName,
        'createdAt': FieldValue.serverTimestamp(),
        'bio': '',
        'profileImageUrl': '',
      });

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Login with email and password
  Future<UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) {
        // If document doesn't exist, create default values
        return {'uid': uid, 'email': '', 'fullName': 'User', 'bio': ''};
      }

      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      // Return null on error - will use default values
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    required String fullName,
    required String bio,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'fullName': fullName,
        'bio': bio,
      });
    } catch (e) {
      rethrow;
    }
  }
}
