import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _backendUrl = 'http://192.168.100.3:5000/api/users';

  Stream<QuerySnapshot> getUsersStream() {
    return _firestore.collection('users').snapshots();
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    return userDoc.exists ? userDoc.data() as Map<String, dynamic> : null;
  }

  Future<void> deleteUsers(Set<String> userIds) async {
    try {
      final response = await http.delete(
        Uri.parse('$_backendUrl/delete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userIds': userIds.toList()}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete users: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to delete users: $e');
    }
  }
}
