import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/usecases/get_dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../data/datasources/dashboard_local_data_source.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../controllers/dashboard_controller.dart';
import '../../../../services/sqlite_service.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Register SQLiteService if not already registered
    if (!Get.isRegistered<SQLiteService>()) {
      Get.put(SQLiteService());
    }

    // Data Sources - Use SQLiteService's database
    Get.lazyPut<DashboardLocalDataSource>(() {
      // We'll pass SQLiteService and get database from it
      return DashboardLocalDataSource(Get.find<SQLiteService>());
    });

    Get.lazyPut<DashboardRemoteDataSource>(
      () => DashboardRemoteDataSource(FirebaseFirestore.instance),
    );

    // Repository (Interface -> Implementation)
    Get.lazyPut<DashboardRepository>(
      () => DashboardRepositoryImpl(local: Get.find(), remote: Get.find()),
    );

    // UseCase
    Get.lazyPut(() => GetDashboardStats(Get.find()));

    // Controller (depends on UseCase, NOT repository)
    Get.lazyPut(() => DashboardController(Get.find()));
  }
}
