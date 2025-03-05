import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:rotorsync_admin/constants/colors.dart';
import 'package:rotorsync_admin/utils/uuid_mapping.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:rotorsync_admin/widgets/custom_snackbar.dart';
import 'package:rotorsync_admin/widgets/input_field.dart';
import 'package:rotorsync_admin/widgets/label.dart';

class ServiceCharacteristicTile extends StatelessWidget {
  final BluetoothService service;
  final Map<String, TextEditingController> topicControllers;
  final Map<String, String> characteristicValues;
  final Function(BluetoothCharacteristic) onReadCharacteristic;
  final Function(BluetoothCharacteristic, Function(String)) onEnableNotify;
  final Function(BuildContext, String, String) onSaveTopic;

  const ServiceCharacteristicTile({
    super.key,
    required this.service,
    required this.topicControllers,
    required this.characteristicValues,
    required this.onReadCharacteristic,
    required this.onEnableNotify,
    required this.onSaveTopic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide.none,
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide.none,
          ),
          title: Text(
            UUIDMapping.getServiceName(
              UUIDMapping.expandUUID(
                  service.uuid.toString().trim().toLowerCase()),
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          subtitle: Text(
            "UUID: ${service.uuid}",
            style: const TextStyle(fontSize: 14, color: AppColors.text),
          ),
          children: service.characteristics.map((characteristic) {
            String uuid = characteristic.uuid.toString();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          UUIDMapping.getCharacteristicName(
                            UUIDMapping.expandUUID(uuid),
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => onReadCharacteristic(characteristic),
                        child: const Icon(
                          LucideIcons.arrowDownToLine,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => onEnableNotify(characteristic, (value) {
                          characteristicValues[uuid] = value;
                        }),
                        child: const Icon(
                          LucideIcons.bell,
                          size: 20,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Value: ${characteristicValues[uuid] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 14, color: AppColors.text),
                  ),
                  const SizedBox(height: 20),
                  const Label(text: "MQTT Topic"),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InputField(
                          controller: topicControllers[uuid],
                          hintText: "helicopter/1/temperature",
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          String topic = topicControllers[uuid]!.text;
                          if (topic.isNotEmpty) {
                            onSaveTopic(context, uuid, topic);
                          } else {
                            customSnackbar(context, "Topic can't be empty",
                                isError: true);
                          }
                        },
                        child: const Text("Save"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
