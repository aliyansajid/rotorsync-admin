import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:rotorsync_admin/constants/colors.dart';

class DeviceList extends StatelessWidget {
  final List<ScanResult> scanResults;
  final bool isScanning;
  final Function(BluetoothDevice) onDeviceTap;

  const DeviceList({
    super.key,
    required this.scanResults,
    required this.isScanning,
    required this.onDeviceTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: scanResults.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final result = scanResults[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            leading: const CircleAvatar(
              backgroundColor: AppColors.accent,
              child: Icon(LucideIcons.bluetooth, color: AppColors.primary),
            ),
            title: Text(
              result.device.platformName.isNotEmpty
                  ? result.device.platformName
                  : "Unknown Device",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
            ),
            trailing: const Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: AppColors.grey,
            ),
            onTap: () => onDeviceTap(result.device),
          ),
        );
      },
    );
  }
}
