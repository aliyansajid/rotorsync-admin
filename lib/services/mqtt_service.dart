import 'dart:io';
import 'dart:developer';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MQTTService {
  static final MQTTService _instance = MQTTService._internal();
  factory MQTTService() => _instance;
  MQTTService._internal();

  MqttServerClient? _client;
  bool _isConnected = false;
  Map<String, dynamic> _credentials = {};

  bool get isConnected => _isConnected;
  Map<String, dynamic> get credentials => _credentials;

  Future<void> connect(
      String broker, int port, String username, String password) async {
    if (_client == null) {
      _client = MqttServerClient.withPort(broker, 'mqtt_flutter_client', port);
      _client!.secure = true;
      _client!.securityContext = SecurityContext.defaultContext;
      _client!.logging(on: true);
      _client!.keepAlivePeriod = 20;

      _client!.onDisconnected = _onDisconnected;
      _client!.onConnected = _onConnected;
    }

    if (_client!.connectionStatus?.state == MqttConnectionState.connected) {
      return;
    }

    try {
      await _client!.connect(username, password);
      if (_client!.connectionStatus?.state == MqttConnectionState.connected) {
        await _saveCredentials(broker, port, username, password, true);
        _credentials = {
          'broker': broker,
          'port': port,
          'username': username,
          'password': password
        };
        _isConnected = true;
      }
    } catch (e) {
      log('🚫 Connection error: $e');
      _client!.disconnect();
    }
  }

  void disconnect() async {
    _client?.disconnect();
    await _saveCredentials('', 0, '', '', false);
    _credentials.clear();
    _isConnected = false;
  }

  void _onDisconnected() {
    _isConnected = false;
    log('Disconnected from broker');
  }

  void _onConnected() {
    _isConnected = true;
    log('Connected to broker');
  }

  Future<void> _saveCredentials(String broker, int port, String username,
      String password, bool isConnected) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('broker', broker);
    prefs.setInt('port', port);
    prefs.setString('username', username);
    prefs.setString('password', password);
    prefs.setBool('isConnected', isConnected);
  }

  Future<void> loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    _credentials = {
      'broker': prefs.getString('broker') ?? '',
      'port': prefs.getInt('port') ?? 1883,
      'username': prefs.getString('username') ?? '',
      'password': prefs.getString('password') ?? '',
      'isConnected': prefs.getBool('isConnected') ?? false,
    };
    _isConnected = _credentials['isConnected'];
  }
}
