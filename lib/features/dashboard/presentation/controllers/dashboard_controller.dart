import 'dart:async';
import 'package:get/get.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/usecases/get_dashboard_stats.dart';

// GetX Controller - ONLY talks to UseCase (Clean Architecture)
class DashboardController extends GetxController {
  // UseCase dependency (SOLID: D)
  final GetDashboardStats _getDashboardStats;

  DashboardController(this._getDashboardStats);

  // OBSERVABLES - Reactive state
  final Rx<DashboardStats?> stats = Rx<DashboardStats?>(null);
  final RxBool isLoading = true.obs;
  final RxDouble animatedSales = 0.0.obs; // For number animation
  final RxDouble animatedProfit = 0.0.obs;

  // Timer for live updates
  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    loadStats();
    startLiveUpdates();
    animateNumbers();
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  // Load dashboard stats
  Future<void> loadStats() async {
    isLoading.value = true;
    try {
      final result = await _getDashboardStats.execute();
      stats.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Start 30-second refresh timer
  void startLiveUpdates() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      loadStats();
    });
  }

  // Animate numbers from 0 to actual value
  void animateNumbers() {
    ever<DashboardStats?>(stats, (stats) {
      if (stats == null) return;

      // Animate sales
      _animateValue(
        start: 0,
        end: stats.todaySales,
        duration: const Duration(milliseconds: 2000),
        onUpdate: (value) => animatedSales.value = value,
      );

      // Animate profit
      _animateValue(
        start: 0,
        end: stats.todayProfit,
        duration: const Duration(milliseconds: 2500),
        onUpdate: (value) => animatedProfit.value = value,
      );
    });
  }

  // Helper: Animate a value over time
  void _animateValue({
    required double start,
    required double end,
    required Duration duration,
    required Function(double) onUpdate,
  }) {
    const fps = 60;
    final steps = duration.inMilliseconds ~/ (1000 ~/ fps);
    final increment = (end - start) / steps;
    var current = start;
    var count = 0;

    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (count >= steps) {
        timer.cancel();
        onUpdate(end);
        return;
      }
      current += increment;
      onUpdate(current);
      count++;
    });
  }

  // Refresh manually (pull-to-refresh)
  Future<void> refresh() async {
    await loadStats();
  }
}
