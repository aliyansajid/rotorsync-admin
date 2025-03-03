import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:rotorsync_admin/constants/colors.dart';
import '../controllers/mqtt_controller.dart';
import '../services/mqtt_service.dart';
import '../widgets/label.dart';
import '../widgets/input_field.dart';
import '../widgets/custom_button.dart';
import '../utils/validators.dart';

class MqttScreen extends StatelessWidget {
  const MqttScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MqttController(mqttService: MQTTService()),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: _buildAppBar(context),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: const _MqttFormContent(),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft),
        onPressed: () => Navigator.pop(context),
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
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
      style: TextStyle(fontSize: 14, color: AppColors.text),
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
        Consumer<MqttController>(
          builder: (context, controller, _) {
            return InputField(
              controller: controller.brokerController,
              hintText: "broker.hivemq.com",
              enabled: !controller.fieldsDisabled,
              validator: Validators.validateBrokerUrl,
            );
          },
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
          validator: Validators.validatePort,
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
          hintText: "mqtt",
          enabled: !controller.fieldsDisabled,
          validator: Validators.validateBasePath,
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
          validator: Validators.validateUsername,
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
          validator: Validators.validatePassword,
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
          ? null
          : () async {
              if (!controller.isConnected) {
                if (controller.formKey.currentState!.validate()) {
                  await controller.connectMQTT();
                }
              } else {
                controller.disconnectMQTT();
              }
            },
    );
  }

  Widget _buildConnectionStatus(MqttController controller) {
    return Center(
      child: Text(
        "Status: ${controller.connectionStatus}",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: controller.isConnected ? AppColors.green : AppColors.red,
        ),
      ),
    );
  }
}
