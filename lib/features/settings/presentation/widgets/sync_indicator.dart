import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smartpos_mobile_manager/core/services/sync_service.dart';

class SyncIndicator extends StatelessWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final syncService = SyncService.to;

      if (syncService.isSyncing.value) {
        // Rotating animation
        return LoadingAnimationWidget.progressiveDots(
          size: 30,
          color: Colors.blue,
        );
      }

      if (syncService.pendingCount.value > 0) {
        // Red badge with count
        return Badge(
          label: Text('${syncService.pendingCount.value}'),
          backgroundColor: Colors.red,
          child: const Icon(Icons.cloud_upload_outlined, color: Colors.grey),
        );
      }

      // Green checkmark when synced
      return const Icon(Icons.cloud_done, color: Colors.green);
    });
  }
}
