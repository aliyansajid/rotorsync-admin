import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../controllers/mqtt_controller.dart';
import '../services/mqtt_service.dart';
import '../widgets/label.dart';
import '../widgets/input_field.dart';
import '../widgets/custom_button.dart';

class MqttScreen extends StatelessWidget {
  const MqttScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MqttController(mqttService: MQTTService()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context), // Pass context here
        body: const _MqttFormContent(),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1D61E7),
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft),
        onPressed: () => Navigator.pop(context), // Use context here
      ),
      title: const Text(
        "MQTT Configuration",
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _MqttFormContent extends StatelessWidget {
  const _MqttFormContent();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MqttController>();
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDescription(),
              const SizedBox(height: 20),
              _buildProtocolField(controller),
              const SizedBox(height: 16),
              _buildBrokerUrlField(controller),
              const SizedBox(height: 16),
              _buildPortField(controller),
              if (controller.connectionType == 'websocket') ...[
                const SizedBox(height: 16),
                _buildBasePathField(controller),
              ],
              const SizedBox(height: 16),
              _buildUsernameField(controller),
              const SizedBox(height: 16),
              _buildPasswordField(controller),
              const SizedBox(height: 32),
              _buildConnectButton(controller),
              const SizedBox(height: 20),
              _buildConnectionStatus(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return const Text(
      "Please enter your MQTT broker details to establish a connection.",
      style: TextStyle(fontSize: 14, color: Colors.grey),
    );
  }

  Widget _buildProtocolField(MqttController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Label(text: "Protocol"),
        const SizedBox(height: 8),
        InputField(
          hintText: "Select protocol",
          items: const ['tls', 'websocket'],
          value: controller.connectionType,
          onChanged: controller.fieldsDisabled
              ? null
              : (String? newValue) {
                  if (newValue != null) {
                    controller.connectionType = newValue;
                  }
                },
        ),
      ],
    );
  }

  Widget _buildBrokerUrlField(MqttController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Label(text: "Broker URL"),
        const SizedBox(height: 8),
        InputField(
          controller: controller.brokerController,
          hintText: "broker.hivemq.com",
          enabled: !controller.fieldsDisabled,
        ),
      ],
    );
  }

  Widget _buildPortField(MqttController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Label(text: "Port"),
        const SizedBox(height: 8),
        InputField(
          controller: controller.portController,
          hintText: "1883",
          keyboardType: TextInputType.number,
          enabled: !controller.fieldsDisabled,
        ),
      ],
    );
  }

  Widget _buildBasePathField(MqttController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Label(text: "Base Path"),
        const SizedBox(height: 8),
        InputField(
          controller: controller.basePathController,
          hintText: "Enter base path (e.g., mqtt)",
          enabled: !controller.fieldsDisabled,
          onChanged: (value) {
            if (value != null && value.isNotEmpty && !value.startsWith('/')) {
              controller.basePathController.text = '/$value';
              controller.basePathController.selection =
                  TextSelection.fromPosition(
                TextPosition(offset: controller.basePathController.text.length),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildUsernameField(MqttController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Label(text: "Username"),
        const SizedBox(height: 8),
        InputField(
          controller: controller.usernameController,
          hintText: "john",
          enabled: !controller.fieldsDisabled,
        ),
      ],
    );
  }

  Widget _buildPasswordField(MqttController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Label(text: "Password"),
        const SizedBox(height: 8),
        InputField(
          controller: controller.passwordController,
          hintText: "••••••••",
          isPassword: true,
          enabled: !controller.fieldsDisabled,
        ),
      ],
    );
  }

  Widget _buildConnectButton(MqttController controller) {
    return CustomButton(
      text: controller.isConnected ? "Disconnect" : "Connect",
      icon: controller.isConnected ? LucideIcons.powerOff : LucideIcons.power,
      isLoading: controller.isLoading,
      isDestructive: controller.isConnected,
      onPressed: controller.isLoading
          ? null // Disable button when loading
          : controller.isConnected
              ? controller.disconnectMQTT
              : controller.connectMQTT,
    );
  }

  Widget _buildConnectionStatus(MqttController controller) {
    return Center(
      child: Text(
        "Status: ${controller.connectionStatus}",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: controller.isConnected ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
