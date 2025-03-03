import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileService {
  final String backendUrl =
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> fetchUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() ?? {};
      } else {
        throw Exception("User data not found in Firestore.");
      }
    } catch (e) {
      throw Exception("Error fetching user data: $e");
    }
  }

  Future<http.Response> updateUser(
      String uid, Map<String, dynamic> userData) async {
    try {
      final response = await http.put(
        Uri.parse('$backendUrl/api/users/update/$uid'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(userData),
      );

      return response;
    } catch (e) {
      throw Exception("Error updating user data: $e");
    }
  }
}
