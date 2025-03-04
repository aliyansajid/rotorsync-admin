import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';

class MqttController extends ChangeNotifier {
  final MQTTService _mqttService;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController brokerController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController basePathController = TextEditingController();
  final TextEditingController topicController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  bool _isLoading = false;
  bool _fieldsDisabled = false;
  String connectionStatus = "Disconnected";
  String _connectionType = 'websocket';
  bool _isPublishing = false;
  bool _isSubscribing = false;

  final ValueNotifier<String> messageNotifier =
      ValueNotifier("No messages received");

  MqttController({required MQTTService mqttService})
      : _mqttService = mqttService {
    _mqttService.onConnectionStatusChange = (status) {
      connectionStatus = status;
      _isLoading = false;
      _fieldsDisabled = _mqttService.isConnected;
      notifyListeners();
    };

    _mqttService.onMessageReceived = (topic, message) {
      messageNotifier.value = "[$topic]: $message";
    };

    loadSavedCredentials();
  }

  bool get isLoading => _isLoading;
  bool get fieldsDisabled => _fieldsDisabled;
  String get connectionType => _connectionType;
  bool get isConnected => _mqttService.isConnected;
  bool get isPublishing => _isPublishing;
  bool get isSubscribing => _isSubscribing;

  set connectionType(String type) {
    _connectionType = type;
    notifyListeners();
  }

  Future<void> loadSavedCredentials() async {
    try {
      final credentials = await _mqttService.loadSavedCredentials();

      if (credentials.isNotEmpty) {
        brokerController.text = credentials['broker'] ?? '';
        portController.text = credentials['port'].toString();
        usernameController.text = credentials['username'] ?? '';
        passwordController.text = credentials['password'] ?? '';
        basePathController.text = credentials['basePath'] ?? '';
        _fieldsDisabled = credentials['isConnected'] == true;
        _connectionType = credentials['connectionType'] ?? 'websocket';

        if (credentials['isConnected'] == true) {
          _mqttService.setupClient(
            brokerController.text.trim(),
            int.parse(portController.text),
            _connectionType,
            basePathController.text.trim(),
          );
          await _mqttService.connect(
            usernameController.text.trim(),
            passwordController.text.trim(),
          );
        }
      }
    } catch (e) {
      connectionStatus = "Error loading credentials";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> connectMQTT() async {
    _isLoading = true;
    _fieldsDisabled = true;
    notifyListeners();

    String broker = brokerController.text.trim();
    int port = int.tryParse(portController.text) ?? 8884;
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();
    String basePath = basePathController.text.trim();

    try {
      _mqttService.setupClient(broker, port, _connectionType, basePath);
      await _mqttService.connect(username, password);

      if (_mqttService.isConnected) {
        await _mqttService.saveCredentials(
            broker, port, username, password, _connectionType, basePath);
      }
    } finally {
      _isLoading = false;
      _fieldsDisabled = _mqttService.isConnected;
      notifyListeners();
    }
  }

  void disconnectMQTT() {
    _mqttService.disconnect();
    _fieldsDisabled = false;
    _isLoading = false;
    connectionStatus = "Disconnected";
    notifyListeners();
  }

  Future<void> publishMessage() async {
    if (topicController.text.isNotEmpty && messageController.text.isNotEmpty) {
      _isPublishing = true;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 500));
      _mqttService.publishMessage(topicController.text, messageController.text);

      _isPublishing = false;
      notifyListeners();
    }
  }

  Future<void> subscribeToTopic() async {
    if (topicController.text.isNotEmpty) {
      _isSubscribing = true;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 500));
      _mqttService.subscribeToTopic(topicController.text);

      messageNotifier.value = "Subscribed to ${topicController.text}";
      _isSubscribing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    brokerController.dispose();
    portController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    basePathController.dispose();
    topicController.dispose();
    messageController.dispose();
    messageNotifier.dispose();
    super.dispose();
  }
}
