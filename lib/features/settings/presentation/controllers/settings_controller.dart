import 'package:get/get.dart';
// googleapis removed - handled by BackupService
import '../../../../core/services/backup_service.dart';

class SettingsController extends GetxController {
  final BackupService backupService = BackupService.to;

  final RxBool isLoadingBackups = false.obs;

  // Fetch backups and show dialog
  Future<void> handleRestore() async {
    isLoadingBackups.value = true;
    final backups = await backupService.listBackups();
    isLoadingBackups.value = false;

    if (backups.isEmpty) {
      Get.snackbar("No Backups", "No SmartPOS backups found in Drive.");
      return;
    }

    // Pass list to UI to show dialog (Logic separated)
    // In GetX, we can trigger dialogs from here
    // But for cleaner UI, we usually return the list or set an observable
  }
}
