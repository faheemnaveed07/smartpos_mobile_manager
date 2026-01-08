import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/sync_service.dart';

/// SyncIndicator Widget for AppBar
/// Shows sync status with different states:
/// - Idle: Cloud icon
/// - Syncing: Rotating sync icon
/// - Pending: Cloud with badge count
/// - Error: Cloud with error color
/// - Offline: Cloud off icon
class SyncIndicator extends StatelessWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<SyncService>(
      init: SyncService.to,
      builder: (sync) {
        return GestureDetector(
          onTap: () => _showSyncDetails(context, sync),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildIcon(sync),
                if (sync.pendingCount.value > 0 &&
                    sync.syncStatus.value != 'syncing')
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${sync.pendingCount.value > 99 ? "99+" : sync.pendingCount.value}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIcon(SyncService sync) {
    switch (sync.syncStatus.value) {
      case 'syncing':
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(seconds: 1),
          builder: (context, value, child) {
            return Transform.rotate(
              angle: value * 2 * 3.14159,
              child: const Icon(Icons.sync, color: Colors.blue),
            );
          },
          onEnd: () {
            // Repeat animation while syncing
          },
        );
      case 'success':
        return const Icon(Icons.cloud_done, color: Colors.green);
      case 'error':
        return const Icon(Icons.cloud_off, color: Colors.red);
      case 'offline':
        return const Icon(Icons.cloud_off, color: Colors.grey);
      default: // idle
        return sync.pendingCount.value > 0
            ? const Icon(Icons.cloud_upload, color: Colors.orange)
            : const Icon(Icons.cloud_done, color: Colors.green);
    }
  }

  void _showSyncDetails(BuildContext context, SyncService sync) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _getStatusIcon(sync.syncStatus.value),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusTitle(sync.syncStatus.value),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getStatusSubtitle(sync),
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (sync.pendingCount.value > 0)
              ListTile(
                leading: const Icon(
                  Icons.pending_actions,
                  color: Colors.orange,
                ),
                title: Text('${sync.pendingCount.value} items waiting to sync'),
                subtitle: const Text('Will sync when online'),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: sync.isSyncing.value ? null : () => sync.forceSync(),
                icon: sync.isSyncing.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                label: Text(sync.isSyncing.value ? 'Syncing...' : 'Sync Now'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Icon _getStatusIcon(String status) {
    switch (status) {
      case 'syncing':
        return const Icon(Icons.sync, color: Colors.blue, size: 40);
      case 'success':
        return const Icon(Icons.check_circle, color: Colors.green, size: 40);
      case 'error':
        return const Icon(Icons.error, color: Colors.red, size: 40);
      case 'offline':
        return const Icon(Icons.wifi_off, color: Colors.grey, size: 40);
      default:
        return const Icon(Icons.cloud_queue, color: Colors.blue, size: 40);
    }
  }

  String _getStatusTitle(String status) {
    switch (status) {
      case 'syncing':
        return 'Syncing...';
      case 'success':
        return 'All Synced';
      case 'error':
        return 'Sync Error';
      case 'offline':
        return 'Offline';
      default:
        return 'Sync Status';
    }
  }

  String _getStatusSubtitle(SyncService sync) {
    if (sync.syncStatus.value == 'offline') {
      return 'No internet connection';
    } else if (sync.pendingCount.value > 0) {
      return '${sync.pendingCount.value} items pending';
    } else {
      return 'Everything is up to date';
    }
  }
}
