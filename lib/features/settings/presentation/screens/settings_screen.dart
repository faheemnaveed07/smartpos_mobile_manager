import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import '../../../../controllers/auth_controller.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/services/sync_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Services directly for simple settings
    final backupService = BackupService.to;
    final syncService = SyncService.to;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('Settings & Backup')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. SYNC STATUS CARD
          GlassContainer(
            blur: 15,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white, width: 2),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.sync, color: Colors.blue),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Sync Status",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Obx(
                            () => Text(
                              syncService.syncStatus.value,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Obx(
                        () => syncService.isSyncing.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: () => syncService.syncAll(),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Obx(
                    () => LinearProgressIndicator(
                      value: syncService.isSyncing.value ? null : 1.0,
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            "Backup & Restore",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // 2. BACKUP CARD
          GlassContainer(
            blur: 10,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.cloud_upload_outlined,
                    color: Colors.green,
                  ),
                  title: const Text("Backup to Drive"),
                  subtitle: Obx(
                    () => Text(
                      "Last: ${backupService.lastBackupDate.value?.toString().split('.')[0] ?? 'Never'}",
                    ),
                  ),
                  trailing: Obx(
                    () => backupService.isBackingUp.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => backupService.backupNow(),
                            child: const Text("Backup"),
                          ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.restore, color: Colors.redAccent),
                  title: const Text("Restore Data"),
                  subtitle: const Text("Overwrite local data from Cloud"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    // Logic to show dialog
                    final backups = await backupService.listBackups();
                    if (backups.isEmpty) {
                      Get.snackbar("Info", "No backups found");
                      return;
                    }
                    Get.dialog(_buildRestoreDialog(backups, backupService));
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          const Text(
            "Account",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // LOGOUT CARD
          GlassContainer(
            blur: 10,
            borderRadius: BorderRadius.circular(16),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, color: Colors.red),
              ),
              title: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text("Sign out from your account"),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.red,
              ),
              onTap: () => _showLogoutConfirmation(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 10),
            Text("Logout"),
          ],
        ),
        content: const Text(
          "Are you sure you want to logout from your account?",
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              Get.find<AuthController>().logout();
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreDialog(List<dynamic> backups, BackupService service) {
    return AlertDialog(
      title: const Text("Select Backup"),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: backups.length,
          itemBuilder: (context, index) {
            final file = backups[index];
            return ListTile(
              leading: const Icon(Icons.history),
              title: Text(file.name),
              subtitle: Text(file.createdTime?.toString() ?? ''),
              onTap: () {
                Get.back(); // Close list
                service.restoreFromBackup(file.id);
              },
            );
          },
        ),
      ),
    );
  }
}
