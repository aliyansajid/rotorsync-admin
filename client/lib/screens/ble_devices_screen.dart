import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:rotorsync_admin/constants/colors.dart';
import 'package:rotorsync_admin/services/ble_services.dart';
import 'package:rotorsync_admin/widgets/custom_snackbar.dart';
import 'package:rotorsync_admin/widgets/device_list.dart';

class BleDevicesScreen extends StatefulWidget {
  const BleDevicesScreen({super.key});

  @override
  State<BleDevicesScreen> createState() => _BleDevicesScreenState();
}

class _BleDevicesScreenState extends State<BleDevicesScreen> {
  List<ScanResult> scanResults = [];
  bool isScanning = false;

  void startScan() async {
    setState(() {
      isScanning = true;
      scanResults.clear();
    });

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        scanResults = results;
      });
    });

    await Future.delayed(const Duration(seconds: 5));
    FlutterBluePlus.stopScan();
    setState(() => isScanning = false);
  }

  void connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BleServices(device: device),
        ),
      );
    } catch (e) {
      customSnackbar(context, "Connection failed: $e", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          "Devices",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: isScanning
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    LucideIcons.rotateCw,
                    size: 20,
                  ),
            onPressed: isScanning ? null : startScan,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DeviceList(
                scanResults: scanResults,
                isScanning: isScanning,
                onDeviceTap: connectToDevice,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
