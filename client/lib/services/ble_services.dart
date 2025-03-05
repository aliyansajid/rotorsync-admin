import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:rotorsync_admin/constants/colors.dart';
import 'package:rotorsync_admin/services/ble_service_manager.dart';
import 'package:rotorsync_admin/widgets/service_characteristic_tile.dart';

class BleServices extends StatefulWidget {
  final BluetoothDevice device;
  const BleServices({super.key, required this.device});

  @override
  State<BleServices> createState() => _BleServicesState();
}

class _BleServicesState extends State<BleServices> {
  late BleServiceManager _bleServiceManager;
  List<BluetoothService> services = [];
  Map<String, TextEditingController> topicControllers = {};
  Map<String, String> characteristicValues = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _bleServiceManager = BleServiceManager(device: widget.device);
    _initialize();
  }

  Future<void> _initialize() async {
    services = await _bleServiceManager.discoverServices();
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        String uuid = characteristic.uuid.toString();
        String? topic = await _bleServiceManager.loadTopic(uuid);
        topicControllers[uuid] = TextEditingController(text: topic);
      }
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: Text(
          "Services - ${widget.device.platformName}",
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppColors.white,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.separated(
                itemCount: services.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, serviceIndex) {
                  final service = services[serviceIndex];
                  return ServiceCharacteristicTile(
                    service: service,
                    topicControllers: topicControllers,
                    characteristicValues: characteristicValues,
                    onReadCharacteristic: (characteristic) async {
                      String value = await _bleServiceManager
                          .readCharacteristic(characteristic);
                      setState(() {
                        characteristicValues[characteristic.uuid.toString()] =
                            value;
                      });
                      _bleServiceManager.publishToMqtt(
                        topicControllers[characteristic.uuid.toString()]!.text,
                        value,
                      );
                    },
                    onEnableNotify: (characteristic, onValueChanged) {
                      _bleServiceManager.enableNotify(
                        characteristic,
                        (value) {
                          setState(() {
                            characteristicValues[
                                characteristic.uuid.toString()] = value;
                          });
                          _bleServiceManager.publishToMqtt(
                            topicControllers[characteristic.uuid.toString()]!
                                .text,
                            value,
                          );
                        },
                      );
                    },
                    onSaveTopic: (context, uuid, topic) {
                      _bleServiceManager.saveTopic(context, uuid, topic);
                    },
                  );
                },
              ),
            ),
    );
  }
}
