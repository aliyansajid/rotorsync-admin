import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String backendUrl =
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  Stream<QuerySnapshot> getUsersStream() {
    return _firestore.collection('users').snapshots();
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    return userDoc.exists ? userDoc.data() as Map<String, dynamic> : null;
  }

  Future<http.Response> deleteUsers(Set<String> userIds) async {
    final url = '$backendUrl/api/users/delete';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userIds': userIds.toList()}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete users: ${response.body}');
      }

      return response;
    } catch (e) {
      throw Exception('Failed to delete users: $e');
    }
  }
}
