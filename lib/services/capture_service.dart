import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

enum CameraAccess { granted, denied, permanentlyDenied }

class CameraUnavailableException implements Exception {
  final String? details;
  CameraUnavailableException([this.details]);
}

class CaptureService {
  final ImagePicker _picker = ImagePicker();

  Future<CameraAccess> requestCameraPermission() async {
    final status = await ph.Permission.camera.request();
    if (status.isGranted || status.isLimited) return CameraAccess.granted;
    if (status.isPermanentlyDenied) return CameraAccess.permanentlyDenied;
    return CameraAccess.denied;
  }

  Future<XFile?> takePhoto() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1280,
        imageQuality: 80,
      );
    } on PlatformException catch (e) {
      if (e.code == 'camera_access_denied') rethrow;
      throw CameraUnavailableException(e.message);
    }
  }

  Future<XFile?> pickFromGallery() => _picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 1280,
    imageQuality: 80,
  );

  Future<bool> openSystemSettings() => ph.openAppSettings();
}
