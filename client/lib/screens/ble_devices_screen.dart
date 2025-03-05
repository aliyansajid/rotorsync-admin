import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
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

  Future<void> _checkPermissionsAndStartScan() async {
    if (!await FlutterBluePlus.isSupported) {
      if (mounted) {
        customSnackbar(context, "Bluetooth is not supported on this device",
            isError: true);
      }
      return;
    }

    var bluetoothStatus = await Permission.bluetooth.status;
    if (!bluetoothStatus.isGranted) {
      var result = await Permission.bluetooth.request();
      if (!result.isGranted) {
        if (mounted) {
          customSnackbar(
              context, "Bluetooth permission is required for scanning",
              isError: true);
        }
        return;
      }
    }

    var locationStatus = await Permission.location.status;
    if (!locationStatus.isGranted) {
      var result = await Permission.location.request();
      if (!result.isGranted) {
        if (mounted) {
          customSnackbar(
              context, "Location permission is required for scanning",
              isError: true);
        }
        return;
      }
    }

    if (!await FlutterBluePlus.adapterState.first
        .then((state) => state == BluetoothAdapterState.on)) {
      if (mounted) {
        customSnackbar(context, "Please turn on Bluetooth", isError: true);
      }
      return;
    }

    bool isLocationEnabled = await Permission.location.serviceStatus.isEnabled;
    if (!isLocationEnabled) {
      if (mounted) {
        customSnackbar(context, "Please turn on location services",
            isError: true);
      }
      return;
    }

    startScan();
  }

  void startScan() async {
    setState(() {
      isScanning = true;
      scanResults.clear();
    });

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      if (mounted) {
        setState(() {
          scanResults = results;
        });
      }
    });

    await Future.delayed(const Duration(seconds: 5));
    FlutterBluePlus.stopScan();
    if (mounted) {
      setState(() => isScanning = false);
    }
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
      if (mounted) {
        customSnackbar(context, "Connection failed: $e", isError: true);
      }
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
            onPressed: isScanning ? null : _checkPermissionsAndStartScan,
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
