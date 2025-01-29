import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  static final MQTTService _instance = MQTTService._internal();

  factory MQTTService() => _instance;

  MQTTService._internal();

  MqttServerClient? _client;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<void> connect(
      String broker, int port, String username, String password) async {
    if (_client == null) {
      _client = MqttServerClient.withPort(broker, 'mqtt_flutter_client', port);
      _client!.secure = true;
      _client!.securityContext = SecurityContext.defaultContext; // TLS context
      _client!.logging(on: true);
      _client!.keepAlivePeriod = 20;

      _client!.onDisconnected = _onDisconnected;
      _client!.onConnected = _onConnected;
    }

    if (_client!.connectionStatus?.state == MqttConnectionState.connected) {
      return; // Already connected
    }

    try {
      await _client!.connect(username, password);
    } on NoConnectionException catch (e) {
      print('🚫 No connection: $e');
      _client!.disconnect();
    } on SocketException catch (e) {
      print('🚫 Socket exception: $e');
      _client!.disconnect();
    } catch (e) {
      print('🚫 Unexpected exception: $e');
      _client!.disconnect();
    }
  }

  void disconnect() {
    _client?.disconnect();
  }

  void _onDisconnected() {
    _isConnected = false;
    print('Disconnected from broker');
  }

  void _onConnected() {
    _isConnected = true;
    print('Connected to broker');
  }
}
