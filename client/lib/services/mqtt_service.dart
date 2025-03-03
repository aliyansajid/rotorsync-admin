import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  static final MQTTService _instance = MQTTService._internal();

  factory MQTTService({
    Function(String)? onConnectionStatusChange,
    Function(String, String)? onMessageReceived,
  }) {
    _instance.onConnectionStatusChange = onConnectionStatusChange;
    _instance.onMessageReceived = onMessageReceived;
    return _instance;
  }

  MQTTService._internal();

  late MqttServerClient _client;
  bool isConnected = false;
  Function(String)? onConnectionStatusChange;
  Function(String, String)? onMessageReceived;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _docId = "mqtt_connection";
  final Set<String> _subscribedTopics = {};

  Future<void> initialize() async {
    final credentials = await loadSavedCredentials();
    if (credentials['broker'].isNotEmpty &&
        credentials['isConnected'] == true) {
      setupClient(credentials['broker'], credentials['port'],
          credentials['connectionType']);
      await connect(credentials['username'], credentials['password']);
    }
  }

  Future<Map<String, dynamic>> loadSavedCredentials() async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('mqtt').doc(_docId).get();
      if (snapshot.exists && snapshot.data() != null) {
        var data = snapshot.data() as Map<String, dynamic>;
        return {
          'broker': data['broker'] ?? '',
          'port': data['port'] ?? 8883,
          'basePath': data['basePath'] ?? '/mqtt',
          'username': data['username'] ?? '',
          'password': data['password'] ?? '',
          'isConnected': data['isConnected'] ?? false,
          'connectionType': data['connectionType'] ?? 'tls',
        };
      }
    } catch (e) {
      log("Error loading credentials: $e");
    }
    return {
      'broker': '',
      'port': 8883,
      'username': '',
      'basePath': '',
      'password': '',
      'isConnected': false,
      'connectionType': 'tls',
    };
  }

  Future<void> saveCredentials(String broker, int port, String username,
      String password, String connectionType,
      [String basePath = "/mqtt"]) async {
    await _firestore.collection('mqtt').doc(_docId).set({
      'broker': broker,
      'port': port,
      'username': username,
      'password': password,
      'isConnected': true,
      'connectionType': connectionType,
      'basePath': basePath
    }, SetOptions(merge: true));
  }

  Future<void> updateConnectionStatus(bool status) async {
    await _firestore
        .collection('mqtt')
        .doc(_docId)
        .update({'isConnected': status});
  }

  void setupClient(String broker, int port, String connectionType,
      [String basePath = "mqtt"]) {
    var uuid = const Uuid();
    String clientId = uuid.v4();

    if (connectionType == 'websocket') {
      String formattedBasePath =
          basePath.startsWith('/') ? basePath : '/$basePath';
      String websocketUrl = "wss://$broker:$port$formattedBasePath";
      _client = MqttServerClient.withPort(websocketUrl, clientId, port);
      _client.useWebSocket = true;
      _client.websocketProtocols = ['mqtt'];
    } else if (connectionType == 'tls') {
      _client = MqttServerClient.withPort(broker, clientId, port);
      _client.secure = true;
      _client.securityContext = SecurityContext.defaultContext;
    } else {
      _client = MqttServerClient.withPort(broker, clientId, port);
    }

    _client.keepAlivePeriod = 20;
    _client.logging(on: true);

    _client.onDisconnected = () {
      isConnected = false;
      onConnectionStatusChange?.call("Disconnected ❌");
    };

    _client.onConnected = () {
      isConnected = true;
      onConnectionStatusChange?.call("Connected ✅");
    };

    listenToMessages();
  }

  void listenToMessages() {
    _client.updates?.listen((List<MqttReceivedMessage<MqttMessage>>? messages) {
      if (messages != null && messages.isNotEmpty) {
        final String topic = messages[0].topic;
        final MqttPublishMessage recMessage =
            messages[0].payload as MqttPublishMessage;
        final String message = MqttPublishPayload.bytesToStringAsString(
            recMessage.payload.message);
        onMessageReceived?.call(topic, message);
      }
    });
  }

  Future<void> connect(String username, String password) async {
    try {
      onConnectionStatusChange?.call("Connecting... ⏳");
      await _client.connect(username, password);

      if (_client.connectionStatus!.state == MqttConnectionState.connected) {
        isConnected = true;
        onConnectionStatusChange?.call("Connected ✅");
      } else {
        isConnected = false;
        onConnectionStatusChange?.call("Connection Failed ❌");
        _client.disconnect();
      }
    } catch (e) {
      isConnected = false;
      onConnectionStatusChange?.call("Connection Error ❌: $e");
      _client.disconnect();
    }
  }

  void disconnect() {
    _client.disconnect();
    isConnected = false;
    _subscribedTopics.clear();
    onConnectionStatusChange?.call("Disconnected ❌");
  }

  void publishMessage(String topic, String message) {
    if (!isConnected) return;
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void subscribeToTopic(String topic) {
    if (!isConnected || _subscribedTopics.contains(topic)) return;
    _client.subscribe(topic, MqttQos.exactlyOnce);
    _subscribedTopics.add(topic);
    listenToMessages();
  }
}
