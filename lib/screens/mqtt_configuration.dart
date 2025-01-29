import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';

class MqttScreen extends StatefulWidget {
  const MqttScreen({super.key});

  @override
  MqttScreenState createState() => MqttScreenState();
}

class MqttScreenState extends State<MqttScreen> {
  final TextEditingController brokerController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _fieldsDisabled = false;

  final MQTTService _mqttService = MQTTService();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    await _mqttService.loadSavedCredentials();
    setState(() {
      brokerController.text = _mqttService.credentials['broker'] ?? '';
      portController.text = _mqttService.credentials['port'].toString();
      usernameController.text = _mqttService.credentials['username'] ?? '';
      passwordController.text = _mqttService.credentials['password'] ?? '';
      _fieldsDisabled = _mqttService.isConnected;
    });
  }

  Future<void> connectMQTT() async {
    setState(() {
      _isLoading = true;
      _fieldsDisabled = true;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = false;
        _fieldsDisabled = false;
      });
      return;
    }

    String broker = brokerController.text.trim();
    int port = int.tryParse(portController.text) ?? 8883;
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    await _mqttService.connect(broker, port, username, password);
    setState(() {
      _isLoading = false;
      _fieldsDisabled = _mqttService.isConnected;
    });
  }

  void disconnectMQTT() {
    _mqttService.disconnect();
    setState(() {
      _fieldsDisabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("MQTT Configuration"),
          backgroundColor: const Color(0xFF1D61E7),
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Please enter your MQTT broker details to establish a connection.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel("Broker URL"),
                  const SizedBox(height: 8),
                  _buildInputField(
                      brokerController, "broker.hivemq.com", !_fieldsDisabled),
                  const SizedBox(height: 16),
                  _buildLabel("Port"),
                  const SizedBox(height: 8),
                  _buildInputField(portController, "1883", !_fieldsDisabled,
                      isNumber: true),
                  const SizedBox(height: 16),
                  _buildLabel("Username"),
                  const SizedBox(height: 8),
                  _buildInputField(
                      usernameController, "john", !_fieldsDisabled),
                  const SizedBox(height: 16),
                  _buildLabel("Password"),
                  const SizedBox(height: 8),
                  _buildInputField(
                      passwordController, "••••••••", !_fieldsDisabled,
                      isPassword: true),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        backgroundColor: _mqttService.isConnected
                            ? Colors.red
                            : const Color(0xFF1D61E7),
                      ),
                      onPressed: _isLoading
                          ? null
                          : _mqttService.isConnected
                              ? disconnectMQTT
                              : connectMQTT,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              _mqttService.isConnected
                                  ? "Disconnect"
                                  : "Connect",
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      _mqttService.isConnected
                          ? "Status: Connected ✅"
                          : "Status: Disconnected ❌",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _mqttService.isConnected
                              ? Colors.green
                              : Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String labelText) {
    return Text(
      labelText,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color(0xFF6C7278),
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller, String hintText, bool enabled,
      {bool isPassword = false, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: enabled ? const Color(0xFF9CA3AF) : const Color(0xFFB0BEC5),
          fontSize: 14,
        ),
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF5F5F5),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFEDF1F3),
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFEDF1F3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: enabled ? const Color(0xFF1D61E7) : const Color(0xFFEDF1F3),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      style: TextStyle(
        fontSize: 14,
        color: enabled ? const Color(0xFF1A1C1E) : const Color(0xFF78909C),
      ),
    );
  }
}
