import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../database/database_helper.dart';

class SyncService extends GetxService {
  static SyncService get to => Get.find();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observables for UI
  final RxBool isSyncing = false.obs;
  final RxInt pendingCount = 0.obs;
  final RxString syncStatus =
      'idle'.obs; // idle, syncing, success, error, offline

  Timer? _syncTimer;
  static const int _maxRetries = 3;
  static const Duration _syncInterval = Duration(seconds: 60);

  @override
  void onInit() {
    super.onInit();
    _checkPendingItems();

    // Auto sync on connectivity change
    Connectivity().onConnectivityChanged.listen((result) {
      if (!result.contains(ConnectivityResult.none)) {
        syncAll();
      } else {
        syncStatus.value = 'offline';
      }
    });

    // Periodic sync every 60 seconds
    _syncTimer = Timer.periodic(_syncInterval, (_) => syncAll());
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    super.onClose();
  }

  Future<void> _checkPendingItems() async {
    pendingCount.value = await _dbHelper.getTotalUnsyncedCount();
  }

  /// Main sync method - syncs all unsynced data
  Future<void> syncAll() async {
    if (isSyncing.value) return;

    // Check connectivity
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      syncStatus.value = 'offline';
      return;
    }

    isSyncing.value = true;
    syncStatus.value = 'syncing';

    try {
      await _checkPendingItems();

      if (pendingCount.value == 0) {
        syncStatus.value = 'success';
        isSyncing.value = false;
        _resetStatusAfterDelay();
        return;
      }

      // Sync all entity types
      await _syncProducts();
      await _syncSales();
      await _syncCustomers();
      await _syncLedgerEntries();

      await _checkPendingItems();
      syncStatus.value = 'success';
      _resetStatusAfterDelay();
    } catch (e) {
      syncStatus.value = 'error';
      print("Sync Error: $e");
    } finally {
      isSyncing.value = false;
    }
  }

  void _resetStatusAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (syncStatus.value == 'success') {
        syncStatus.value = 'idle';
      }
    });
  }

  // ==================== PRODUCT SYNC (Server Wins) ====================
  Future<void> _syncProducts() async {
    final localProducts = await _dbHelper.getUnsyncedProducts();

    for (var localProduct in localProducts) {
      await _syncWithRetry(() => _syncSingleProduct(localProduct));
    }
  }

  Future<void> _syncSingleProduct(Map<String, dynamic> localProduct) async {
    final docRef = _firestore.collection('products').doc(localProduct['id']);
    final serverDoc = await docRef.get();

    if (serverDoc.exists) {
      // CONFLICT RESOLUTION: Server Wins
      final serverData = serverDoc.data()!;
      final serverUpdatedAt =
          DateTime.tryParse(serverData['updatedAt'] ?? '') ?? DateTime(2000);
      final localUpdatedAt =
          DateTime.tryParse(localProduct['updatedAt'] ?? '') ?? DateTime(2000);

      if (serverUpdatedAt.isAfter(localUpdatedAt)) {
        // Server is newer - update local with server data
        await _dbHelper.insertProduct({...serverData, 'isSynced': 1});
        Get.snackbar(
          'Sync Conflict',
          'Product "${localProduct['name']}" was updated from server',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        // Local is newer or same - push to server
        await docRef.set({...localProduct, 'isSynced': 1});
        await _dbHelper.markProductAsSynced(localProduct['id']);
      }
    } else {
      // No server doc - just upload
      await docRef.set({...localProduct, 'isSynced': 1});
      await _dbHelper.markProductAsSynced(localProduct['id']);
    }
    pendingCount.value--;
  }

  // ==================== SALES SYNC ====================
  Future<void> _syncSales() async {
    final localSales = await _dbHelper.getUnsyncedSales();

    for (var sale in localSales) {
      await _syncWithRetry(() async {
        await _firestore.collection('sales').doc(sale['id']).set({
          ...sale,
          'isSynced': 1,
        });
        await _dbHelper.markSaleAsSynced(sale['id']);
        pendingCount.value--;
      });
    }
  }

  // ==================== CUSTOMER SYNC (Server Wins) ====================
  Future<void> _syncCustomers() async {
    final localCustomers = await _dbHelper.getUnsyncedCustomers();

    for (var customer in localCustomers) {
      await _syncWithRetry(() => _syncSingleCustomer(customer));
    }
  }

  Future<void> _syncSingleCustomer(Map<String, dynamic> localCustomer) async {
    final docRef = _firestore.collection('customers').doc(localCustomer['id']);
    final serverDoc = await docRef.get();

    if (serverDoc.exists) {
      final serverData = serverDoc.data()!;
      final serverCreatedAt =
          DateTime.tryParse(serverData['createdAt'] ?? '') ?? DateTime(2000);
      final localCreatedAt =
          DateTime.tryParse(localCustomer['createdAt'] ?? '') ?? DateTime(2000);

      // Server wins if timestamps differ
      if (serverCreatedAt.isAfter(localCreatedAt)) {
        await _dbHelper.insertCustomer({...serverData, 'isSynced': 1});
      } else {
        await docRef.set({...localCustomer, 'isSynced': 1});
        await _dbHelper.markCustomerAsSynced(localCustomer['id']);
      }
    } else {
      await docRef.set({...localCustomer, 'isSynced': 1});
      await _dbHelper.markCustomerAsSynced(localCustomer['id']);
    }
    pendingCount.value--;
  }

  // ==================== LEDGER SYNC ====================
  Future<void> _syncLedgerEntries() async {
    final entries = await _dbHelper.getUnsyncedLedgerEntries();

    for (var entry in entries) {
      await _syncWithRetry(() async {
        await _firestore.collection('ledger_entries').doc(entry['id']).set({
          ...entry,
          'isSynced': 1,
        });
        await _dbHelper.markLedgerEntryAsSynced(entry['id']);
        pendingCount.value--;
      });
    }
  }

  // ==================== RETRY LOGIC ====================
  Future<void> _syncWithRetry(Future<void> Function() syncOperation) async {
    int attempts = 0;
    while (attempts < _maxRetries) {
      try {
        await syncOperation();
        return; // Success
      } catch (e) {
        attempts++;
        if (attempts >= _maxRetries) {
          print("Sync failed after $_maxRetries attempts: $e");
          rethrow;
        }
        // Wait before retry (exponential backoff)
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
  }

  /// Force immediate sync (called from UI)
  Future<void> forceSync() async {
    await syncAll();
  }
}
