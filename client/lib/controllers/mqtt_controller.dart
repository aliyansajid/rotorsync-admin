import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';

class MqttController extends ChangeNotifier {
  final MQTTService _mqttService;
  final TextEditingController brokerController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController basePathController = TextEditingController();

  bool _isLoading = false;
  bool _fieldsDisabled = false;
  String connectionStatus = "Disconnected ❌";
  String _connectionType = 'tls';

  MqttController({required MQTTService mqttService})
      : _mqttService = mqttService {
    _mqttService.onConnectionStatusChange = (status) {
      connectionStatus = status;
      _isLoading = false;
      _fieldsDisabled = _mqttService.isConnected;
      notifyListeners();
    };
    loadSavedCredentials();
  }

  bool get isLoading => _isLoading;
  bool get fieldsDisabled => _fieldsDisabled;
  String get connectionType => _connectionType;
  bool get isConnected => _mqttService.isConnected;

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
      await _mqttService.saveCredentials(
          broker, port, username, password, _connectionType, basePath);
      connectionStatus = "Connected ✅";
    } catch (e) {
      connectionStatus = "Connection Failed ❌";
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
}
