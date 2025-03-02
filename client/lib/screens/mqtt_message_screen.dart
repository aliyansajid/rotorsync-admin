import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
  final FocusNode topicFocusNode = FocusNode();
  final FocusNode messageFocusNode = FocusNode();
  late final MqttController _mqttController;

  @override
  void initState() {
    super.initState();
    _mqttController = MqttController(mqttService: MQTTService());
  }

  @override
  void dispose() {
    topicFocusNode.dispose();
    messageFocusNode.dispose();
    _mqttController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        topicFocusNode.unfocus();
        messageFocusNode.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        "Message Test",
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
      ),
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, color: AppColors.white),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDescription(),
          const SizedBox(height: 20),
          _buildTopicInput(),
          const SizedBox(height: 16),
          _buildMessageInput(),
          const SizedBox(height: 32),
          _buildActionButtons(),
          const SizedBox(height: 20),
          _buildMessageDisplay(),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return const Text(
      "Please enter MQTT topic and message to test the connection.",
      style: TextStyle(fontSize: 14, color: AppColors.text),
    );
  }

  Widget _buildTopicInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Label(text: "Topic"),
        const SizedBox(height: 8),
        InputField(
          controller: _mqttController.topicController,
          hintText: "helicopter/1/fuel_level",
          focusNode: topicFocusNode,
        ),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Label(text: "Message"),
        const SizedBox(height: 8),
        InputField(
          controller: _mqttController.messageController,
          hintText: "Hello from Flutter",
          focusNode: messageFocusNode,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: "Publish",
            icon: LucideIcons.send,
            isLoading: _mqttController.isPublishing,
            onPressed: _mqttController.publishMessage,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CustomButton(
            text: "Subscribe",
            icon: LucideIcons.bellRing,
            isLoading: _mqttController.isSubscribing,
            onPressed: _mqttController.subscribeToTopic,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Messages",
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<String>(
          valueListenable: _mqttController.messageNotifier,
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
