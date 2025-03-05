import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rotorsync_admin/widgets/custom_snackbar.dart';
import 'mqtt_service.dart';

class BleServiceManager {
  final BluetoothDevice device;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  BleServiceManager({required this.device});

  Future<List<BluetoothService>> discoverServices() async {
    return await device.discoverServices();
  }

  Future<void> saveTopic(
      BuildContext context, String uuid, String topic) async {
    try {
      await firestore
          .collection("users")
          .doc(userId)
          .collection("ble_mappings")
          .doc(uuid)
          .set({
        'uuid': uuid,
        'mqtt_topic': topic,
      });
      customSnackbar(context, "Topic saved successfully.");
    } catch (e) {
      customSnackbar(context, "Failed to save topic: $e", isError: true);
    }
  }

  Future<String?> loadTopic(String uuid) async {
    DocumentSnapshot snapshot = await firestore
        .collection("users")
        .doc(userId)
        .collection("ble_mappings")
        .doc(uuid)
        .get();
    return snapshot.exists ? snapshot['mqtt_topic'] : null;
  }

  void publishToMqtt(String topic, String data) {
    if (topic.isNotEmpty) {
      MQTTService().publishMessage(topic, data);
    }
  }

  Future<String> readCharacteristic(
      BluetoothCharacteristic characteristic) async {
    var value = await characteristic.read();
    return parseCharacteristicValue(characteristic, value);
  }

  void enableNotify(BluetoothCharacteristic characteristic,
      Function(String) onValueChanged) async {
    await characteristic.setNotifyValue(true);
    characteristic.lastValueStream.listen((value) {
      String parsedValue = parseCharacteristicValue(characteristic, value);
      onValueChanged(parsedValue);
    });
  }

  String parseCharacteristicValue(
      BluetoothCharacteristic characteristic, List<int> value) {
    if (value.isEmpty) return "N/A";
    String uuid = characteristic.uuid.toString().toUpperCase();
    if (uuid.endsWith("2A6E")) {
      if (value.length < 2) return "Invalid Data";
      int rawValue = (value[1] << 8) | value[0];
      if (rawValue & 0x8000 != 0) {
        rawValue -= 0x10000;
      }
      double temperature = rawValue / 100.0;
      return "${temperature.toStringAsFixed(2)}°C";
    } else if (uuid.endsWith("2A6F")) {
      if (value.length < 2) return "Invalid Data";
      int rawValue = (value[1] << 8) | value[0];
      double humidity = rawValue / 100.0;
      return "${humidity.toStringAsFixed(2)}%";
    } else if (uuid.endsWith("2A19")) {
      if (value.isEmpty) return "Invalid Data";
      int battery = value[0];
      return "$battery%";
    } else {
      return value.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ');
    }
  }
}
