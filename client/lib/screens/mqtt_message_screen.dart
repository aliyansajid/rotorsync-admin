import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:rotorsync_admin/constants/colors.dart';
import 'package:rotorsync_admin/widgets/custom_button.dart';
import 'package:rotorsync_admin/widgets/input_field.dart';
import 'package:rotorsync_admin/widgets/label.dart';
import '../controllers/mqtt_controller.dart';
import '../services/mqtt_service.dart';

class MqttMessageScreen extends StatefulWidget {
  const MqttMessageScreen({super.key});

  @override
  MqttMessageScreenState createState() => MqttMessageScreenState();
}

class MqttMessageScreenState extends State<MqttMessageScreen> {
  late MqttController _mqttController;

  @override
  void initState() {
    super.initState();
    _mqttController = MqttController(mqttService: MQTTService());
  }

  @override
  void dispose() {
    _mqttController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _mqttController,
      child: Consumer<MqttController>(
        builder: (context, controller, _) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: AppColors.white,
              appBar: _buildAppBar(),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDescription(),
                    const SizedBox(height: 20),
                    _buildTopicInput(controller),
                    const SizedBox(height: 16),
                    _buildMessageInput(controller),
                    const SizedBox(height: 32),
                    _buildActionButtons(controller),
                    const SizedBox(height: 20),
                    _buildMessageDisplay(controller),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      title: const Text(
        "Message Test",
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
      ),
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildDescription() {
    return const Text(
      "Please enter MQTT topic and message to test the connection.",
      style: TextStyle(fontSize: 14, color: AppColors.text),
    );
  }

  Widget _buildTopicInput(MqttController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Label(text: "Topic"),
        const SizedBox(height: 8),
        InputField(
          controller: controller.topicController,
          hintText: "helicopter/1/fuel_level",
        ),
      ],
    );
  }

  Widget _buildMessageInput(MqttController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Label(text: "Message"),
        const SizedBox(height: 8),
        InputField(
          controller: controller.messageController,
          hintText: "Hello from Flutter",
        ),
      ],
    );
  }

  Widget _buildActionButtons(MqttController controller) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: "Publish",
            icon: LucideIcons.send,
            isLoading: controller.isPublishing,
            onPressed: controller.publishMessage,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CustomButton(
            text: "Subscribe",
            icon: LucideIcons.bellRing,
            isLoading: controller.isSubscribing,
            onPressed: controller.subscribeToTopic,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageDisplay(MqttController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Messages",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<String>(
          valueListenable: controller.messageNotifier,
          builder: (context, message, child) {
            return Container(
              padding: const EdgeInsets.all(12.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.secondary,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
