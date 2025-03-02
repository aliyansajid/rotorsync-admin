import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<Map<String, String>> getUserData() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(
          {"email": "No Email", "firstName": "Unknown", "lastName": "User"});
    }

    return _firestore.collection('users').doc(user.uid).snapshots().map((doc) {
      if (doc.exists) {
        return {
          "email": doc.data()?["email"] ?? user.email ?? "No Email",
          "firstName": doc.data()?["firstName"] ?? "Unknown",
          "lastName": doc.data()?["lastName"] ?? "User",
        };
      } else {
        return {
          "email": user.email ?? "No Email",
          "firstName": "Unknown",
          "lastName": "User",
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
