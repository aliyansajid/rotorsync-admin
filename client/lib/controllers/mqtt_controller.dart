import 'package:flutter/material.dart';
import 'package:rotorsync_admin/utils/validators.dart';
import '../services/mqtt_service.dart';

class MqttController extends ChangeNotifier {
  final MQTTService _mqttService;
  final TextEditingController brokerController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController basePathController = TextEditingController();
  final TextEditingController topicController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? brokerError;
  String? portError;
  String? basePathError;
  String? usernameError;
  String? passwordError;

  bool _isLoading = false;
  bool _fieldsDisabled = false;
  String connectionStatus = "Disconnected ❌";
  String _connectionType = 'tls';
  bool _isPublishing = false;
  bool _isSubscribing = false;

  final ValueNotifier<String> messageNotifier =
      ValueNotifier("No messages received");

  // Corrected: Only one unnamed constructor
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

  void validateBroker() {
    brokerError = Validators.validateBrokerUrl(brokerController.text);
    notifyListeners();
  }

  void validatePort() {
    portError = Validators.validatePort(portController.text);
    notifyListeners();
  }

  void validateBasePath() {
    basePathError = Validators.validateBasePath(basePathController.text);
    notifyListeners();
  }

  void validateUsername() {
    usernameError = Validators.validateUsername(usernameController.text);
    notifyListeners();
  }

  void validatePassword() {
    passwordError = Validators.validatePassword(passwordController.text);
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
        _connectionType = credentials['connectionType'] ?? 'tls';

        if (credentials['isConnected'] == true) {
          _mqttService.setupClient(
            brokerController.text.trim(),
            int.tryParse(portController.text) ?? 8883,
            _connectionType,
            basePathController.text.trim(),
          );
          await _mqttService.connect(
            usernameController.text.trim(),
            passwordController.text.trim(),
          );
          connectionStatus = "Connected ✅";
        } else {
          connectionStatus = "Disconnected ❌";
        }
      } else {
        connectionStatus = "Disconnected ❌";
      }
    } catch (e) {
      connectionStatus = "Error loading credentials ❌";
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
    int port = int.tryParse(portController.text) ?? 8883;
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();
    String basePath = basePathController.text.trim();

    if (_connectionType == 'websocket' && !basePath.startsWith('/')) {
      basePath = '/$basePath';
      basePathController.text = basePath;
    }

    try {
      _mqttService.setupClient(broker, port, _connectionType, basePath);
      await _mqttService.connect(username, password);
      if (_mqttService.isConnected) {
        await _mqttService.saveCredentials(
            broker, port, username, password, _connectionType, basePath);
        connectionStatus = "Connected ✅";
      } else {
        connectionStatus = "Connection Failed ❌";
      }
    } catch (e) {
      connectionStatus = "Connection Error ❌: $e";
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
    connectionStatus = "Disconnected ❌";
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
