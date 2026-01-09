import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:get/get.dart';
import '../database/database_helper.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BackupService extends GetxService {
  static BackupService get to => Get.find();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  final RxBool isBackingUp = false.obs;
  final RxBool isRestoring = false.obs;
  final Rx<DateTime?> lastBackupDate = Rx<DateTime?>(null);
  final Rx<GoogleSignInAccount?> currentUser = Rx<GoogleSignInAccount?>(null);

  // Google Sign-In v7
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isInitialized = false;

  // Web Client ID for serverClientId (required for Android)
  static const String _serverClientId =
      '86432102508-7nb2t0u06tcmg9l1fi8oolo0qgnuhe41.apps.googleusercontent.com';

  @override
  void onInit() {
    super.onInit();
    _loadLastBackupDate();
    _initGoogleSignIn();
  }

  Future<void> _initGoogleSignIn() async {
    if (_isInitialized) return;

    try {
      // Initialize with serverClientId for Android
      await _googleSignIn.initialize(serverClientId: _serverClientId);
      _isInitialized = true;

      // Listen for authentication events
      _googleSignIn.authenticationEvents.listen((event) {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          currentUser.value = event.user;
        } else if (event is GoogleSignInAuthenticationEventSignOut) {
          currentUser.value = null;
        }
      });

      // Try lightweight auth (silent sign-in) - ignore errors
      try {
        await _googleSignIn.attemptLightweightAuthentication();
      } catch (_) {
        // Silent sign-in failed, user will need to sign in manually
      }
    } catch (e) {
      // Google Sign-In not configured - ignore silently on startup
      debugPrint('Google Sign-In init: $e');
    }
  }

  Future<drive.DriveApi?> _getDriveApi() async {
    try {
      await _initGoogleSignIn();

      if (!_isInitialized) {
        Get.snackbar(
          'Setup Required',
          'Google Drive backup requires OAuth configuration. Please contact developer.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return null;
      }

      // If not signed in, authenticate
      if (currentUser.value == null) {
        if (_googleSignIn.supportsAuthenticate()) {
          await _googleSignIn.authenticate();
        } else {
          Get.snackbar(
            'Error',
            'Google Sign-In not supported on this platform',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return null;
        }
      }

      final user = currentUser.value;
      if (user == null) {
        Get.snackbar(
          'Sign-In Required',
          'Please sign in with Google to use backup',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return null;
      }

      // Request authorization for Drive scope
      final authorization = await user.authorizationClient.authorizeScopes([
        drive.DriveApi.driveFileScope,
      ]);

      // Build auth headers from authorization
      final authHeaders = <String, String>{
        'Authorization': 'Bearer ${authorization.accessToken}',
      };
      final authenticateClient = GoogleAuthClient(authHeaders);
      return drive.DriveApi(authenticateClient);
    } catch (e) {
      Get.snackbar(
        'Backup Unavailable',
        'Google Drive backup is not configured yet',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      debugPrint('Drive API error: $e');
      return null;
    }
  }

  Future<void> backupNow() async {
    isBackingUp.value = true;
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) {
        isBackingUp.value = false;
        return;
      }

      final dbBytes = await _dbHelper.exportDatabase();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')[0];
      final fileName = 'SmartPOS_Backup_$timestamp.db';

      final file = drive.File()..name = fileName;

      await driveApi.files.create(
        file,
        uploadMedia: drive.Media(Stream.value(dbBytes), dbBytes.length),
      );

      lastBackupDate.value = DateTime.now();
      await _saveLastBackupDate();
      Get.snackbar('Success', 'Backup uploaded successfully!');
    } catch (e) {
      Get.snackbar('Backup Failed', e.toString());
    } finally {
      isBackingUp.value = false;
    }
  }

  Future<List<drive.File>> listBackups() async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return [];

      final result = await driveApi.files.list(
        q: "name contains 'SmartPOS_Backup' and trashed = false",
        orderBy: 'createdTime desc',
      );
      return result.files ?? [];
    } catch (e) {
      Get.snackbar('Error', 'Could not fetch backups');
      return [];
    }
  }

  Future<void> restoreFromBackup(String fileId) async {
    isRestoring.value = true;
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) {
        isRestoring.value = false;
        return;
      }

      final file =
          await driveApi.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;
      final bytes = <int>[];

      await for (var data in file.stream) {
        bytes.addAll(data);
      }

      await _dbHelper.importDatabase(bytes);

      Get.defaultDialog(
        title: "Restart Required",
        middleText: "Data restored. Please restart the app.",
        confirm: ElevatedButton(
          onPressed: () => exit(0),
          child: const Text("Exit App"),
        ),
      );
    } catch (e) {
      Get.snackbar('Restore Failed', e.toString());
    } finally {
      isRestoring.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      currentUser.value = null;
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  Future<void> _saveLastBackupDate() async {
    final prefs = await SharedPreferences.getInstance();
    if (lastBackupDate.value != null) {
      prefs.setString('last_backup', lastBackupDate.value!.toIso8601String());
    }
  }

  Future<void> _loadLastBackupDate() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('last_backup');
    if (str != null) lastBackupDate.value = DateTime.parse(str);
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();
  GoogleAuthClient(this._headers);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _client.send(request..headers.addAll(_headers));
}
