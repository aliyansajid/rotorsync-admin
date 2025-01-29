import 'package:flutter/material.dart';
import '../services/mqtt_service.dart'; // Import the MQTTService class

class MqttScreen extends StatefulWidget {
  const MqttScreen({Key? key}) : super(key: key);

  @override
  _MqttScreenState createState() => _MqttScreenState();
}

class _MqttScreenState extends State<MqttScreen> {
  final TextEditingController brokerController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final MQTTService _mqttService = MQTTService();

  @override
  void initState() {
    super.initState();
    _updateConnectionStatus();
  }

  void _updateConnectionStatus() {
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> connectMQTT() async {
    setState(() {
      _isLoading = true;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    String broker = brokerController.text.trim();
    int port = int.tryParse(portController.text) ?? 8883;
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    await _mqttService.connect(broker, port, username, password);
    _updateConnectionStatus();
  }

  void disconnectMQTT() {
    _mqttService.disconnect();
    _updateConnectionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("MQTT Connection"),
          backgroundColor: const Color(0xFF1D61E7),
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Please enter your MQTT broker details to establish a connection.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel("Broker URL"),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: brokerController,
                    hintText: "broker.hivemq.com",
                    keyboardType: TextInputType.url,
                    enabled: !_mqttService.isConnected,
                    validator: (value) =>
                        value!.isEmpty ? "Broker URL is required." : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel("Port"),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: portController,
                    hintText: "1883",
                    keyboardType: TextInputType.number,
                    enabled: !_mqttService.isConnected,
                    validator: (value) =>
                        value!.isEmpty ? "Port is required." : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel("Username"),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: usernameController,
                    hintText: "Enter your username",
                    enabled: !_mqttService.isConnected,
                    validator: (value) =>
                        value!.isEmpty ? "Username is required." : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel("Password"),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: passwordController,
                    hintText: "••••••••",
                    isPassword: true,
                    enabled: !_mqttService.isConnected,
                    validator: (value) =>
                        value!.isEmpty ? "Password is required." : null,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: const Color(0xFF1D61E7),
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
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _mqttService.isConnected
                                  ? "Disconnect"
                                  : "Connect",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      _mqttService.isConnected
                          ? "Status: Connected"
                          : "Status: Disconnected",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _mqttService.isConnected
                            ? Colors.green
                            : Colors.red,
                      ),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    FocusNode? focusNode,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFEDF1F3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFEDF1F3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFF1D61E7),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF1A1C1E),
      ),
    );
  }
}
