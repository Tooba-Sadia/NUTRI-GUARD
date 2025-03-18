import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

Future<void> requestCameraAndStoragePermissions() async {
  if (!kIsWeb) {
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
    }
    if (!await Permission.camera.isGranted) {
      await Permission.camera.request();
    }
  }
}
