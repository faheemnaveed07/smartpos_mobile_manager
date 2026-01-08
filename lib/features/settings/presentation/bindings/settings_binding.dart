import 'package:get/get.dart';
import 'package:smartpos_mobile_manager/core/services/backup_service.dart';
import 'package:smartpos_mobile_manager/core/services/sync_service.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SyncService());
    Get.lazyPut(() => BackupService());
  }
}
