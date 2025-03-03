import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<Map<String, String>> getUserData() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value({
        "email": "No Email",
        "fullName": "Unknown User",
        "uid": "No UID",
      });
    }

    return _firestore.collection('users').doc(user.uid).snapshots().map((doc) {
      if (doc.exists) {
        return {
          "email": doc.data()?["email"] ?? user.email ?? "No Email",
          "fullName": doc.data()?["fullName"] ?? "Unknown User",
          "uid": user.uid,
        };
      } else {
        return {
          "email": user.email ?? "No Email",
          "fullName": "Unknown User",
          "uid": user.uid,
        };
      }
    });
  }

  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }
}
