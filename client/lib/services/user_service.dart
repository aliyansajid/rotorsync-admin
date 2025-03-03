import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class UserService {
  static final UserService _instance = UserService._internal();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  final String backendUrl = dotenv.env['BACKEND_URL'] ??
      (kReleaseMode
          ? throw Exception('BACKEND_URL not set')
          : 'https://localhost:5000');

  Future<http.Response> createUser(Map<String, dynamic> userData) async {
    final url = '$backendUrl/api/users/create';
    return await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
  }

  Future<http.Response> updateUser(
      String userId, Map<String, dynamic> userData) async {
    final url = '$backendUrl/api/users/update/$userId';
    return await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
  }

  Future<http.Response> deleteUsers(Set<String> userIds) async {
    final url = '$backendUrl/api/users/delete';
    return await http.delete(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userIds': userIds.toList()}),
    );
  }
}
