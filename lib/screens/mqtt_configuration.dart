import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/mqtt_service.dart';
import 'package:rotorsync_admin/widgets/label.dart';
import 'package:rotorsync_admin/widgets/input_field.dart';
import 'package:rotorsync_admin/widgets/custom_button.dart';

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
          title: const Text(
            "MQTT Configuration",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: const Color(0xFF1D61E7),
          foregroundColor: Colors.white,
          centerTitle: true,
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
                  const Label(text: "Broker URL"),
                  const SizedBox(height: 8),
                  InputField(
                    controller: brokerController,
                    hintText: "broker.hivemq.com",
                    focusNode: FocusNode(),
                    keyboardType: TextInputType.text,
                    enabled: !_fieldsDisabled,
                  ),
                  const SizedBox(height: 16),
                  const Label(text: "Port"),
                  const SizedBox(height: 8),
                  InputField(
                    controller: portController,
                    hintText: "1883",
                    focusNode: FocusNode(),
                    keyboardType: TextInputType.number,
                    enabled: !_fieldsDisabled,
                  ),
                  const SizedBox(height: 16),
                  const Label(text: "Username"),
                  const SizedBox(height: 8),
                  InputField(
                    controller: usernameController,
                    hintText: "john",
                    focusNode: FocusNode(),
                    keyboardType: TextInputType.text,
                    enabled: !_fieldsDisabled,
                  ),
                  const SizedBox(height: 16),
                  const Label(text: "Password"),
                  const SizedBox(height: 8),
                  InputField(
                    controller: passwordController,
                    hintText: "••••••••",
                    focusNode: FocusNode(),
                    isPassword: true,
                    enabled: !_fieldsDisabled,
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: _mqttService.isConnected ? "Disconnect" : "Connect",
                    icon: _mqttService.isConnected
                        ? LucideIcons.powerOff
                        : LucideIcons.power,
                    isLoading: _isLoading,
                    isDestructive: _mqttService.isConnected,
                    onPressed: _isLoading
                        ? null
                        : _mqttService.isConnected
                            ? disconnectMQTT
                            : connectMQTT,
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
}
