import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/capture_service.dart';
import '../services/room_service.dart';

class CaptureResult {
  final XFile? photo;
  final bool becameSpectator;
  const CaptureResult.photo(XFile this.photo) : becameSpectator = false;
  const CaptureResult.spectator() : photo = null, becameSpectator = true;
}

enum _CaptureState {
  requesting,
  readyToShoot,
  denied,
  permanentlyDenied,
  noCamera,
  preview,
}

class CaptureScreen extends StatefulWidget {
  final String roomId;
  final String userId;

  const CaptureScreen({super.key, required this.roomId, required this.userId});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final CaptureService _capture = CaptureService();
  final RoomService _roomService = RoomService();

  _CaptureState _state = _CaptureState.requesting;
  XFile? _photo;

  @override
  void initState() {
    super.initState();
    _requestPermissionThenShoot();
  }

  Future<void> _requestPermissionThenShoot() async {
    setState(() => _state = _CaptureState.requesting);
    final access = await _capture.requestCameraPermission();
    if (!mounted) return;
    switch (access) {
      case CameraAccess.granted:
        await _openCamera();
      case CameraAccess.denied:
        setState(() => _state = _CaptureState.denied);
      case CameraAccess.permanentlyDenied:
        setState(() => _state = _CaptureState.permanentlyDenied);
    }
  }

  Future<void> _openCamera() async {
    try {
      final photo = await _capture.takePhoto();
      if (!mounted) return;
      if (photo == null) {
        setState(() => _state = _CaptureState.readyToShoot);
      } else {
        setState(() {
          _photo = photo;
          _state = _CaptureState.preview;
        });
      }
    } on CameraUnavailableException {
      if (!mounted) return;
      setState(() => _state = _CaptureState.noCamera);
    }
  }

  Future<void> _pickFromGallery() async {
    final photo = await _capture.pickFromGallery();
    if (!mounted || photo == null) return;
    setState(() {
      _photo = photo;
      _state = _CaptureState.preview;
    });
  }

  Future<void> _becomeSpectator() async {
    await _roomService.setSpectator(widget.roomId, widget.userId);
    if (!mounted) return;
    Navigator.pop(context, const CaptureResult.spectator());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ta photo pour cette manche")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: switch (_state) {
            _CaptureState.requesting => const CircularProgressIndicator(),
            _CaptureState.readyToShoot => _readyView(),
            _CaptureState.denied => _deniedView(),
            _CaptureState.permanentlyDenied => _permanentlyDeniedView(),
            _CaptureState.noCamera => _noCameraView(),
            _CaptureState.preview => _previewView(),
          },
        ),
      ),
    );
  }

  Widget _readyView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.photo_camera, size: 64),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _openCamera,
          icon: const Icon(Icons.photo_camera),
          label: const Text("Ouvrir la caméra"),
        ),
      ],
    );
  }

  Widget _deniedView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.no_photography, size: 64),
        const SizedBox(height: 16),
        const Text(
          "SnapThème a besoin de la caméra pour jouer cette manche.\n"
          "Sans elle, tu peux envoyer une image de ta galerie ou regarder en spectateur.",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _requestPermissionThenShoot,
          child: const Text("Réessayer"),
        ),
        TextButton(
          onPressed: _pickFromGallery,
          child: const Text("Choisir dans la galerie"),
        ),
        TextButton(
          onPressed: _becomeSpectator,
          child: const Text("Continuer en spectateur"),
        ),
      ],
    );
  }

  Widget _permanentlyDeniedView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.settings, size: 64),
        const SizedBox(height: 16),
        const Text(
          "La permission caméra a été refusée définitivement.\n"
          "Tu peux l'activer dans les paramètres de l'application, "
          "ou continuer sans caméra.",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => _capture.openSystemSettings(),
          child: const Text("Ouvrir les paramètres"),
        ),
        TextButton(
          onPressed: _requestPermissionThenShoot,
          child: const Text("Réessayer"),
        ),
        TextButton(
          onPressed: _pickFromGallery,
          child: const Text("Choisir dans la galerie"),
        ),
        TextButton(
          onPressed: _becomeSpectator,
          child: const Text("Continuer en spectateur"),
        ),
      ],
    );
  }

  Widget _noCameraView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.videocam_off, size: 64),
        const SizedBox(height: 16),
        const Text(
          "Aucune caméra disponible sur cet appareil (émulateur ?).\n"
          "Choisis une image dans la galerie à la place.",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _pickFromGallery,
          icon: const Icon(Icons.photo_library),
          label: const Text("Choisir dans la galerie"),
        ),
        TextButton(
          onPressed: _becomeSpectator,
          child: const Text("Continuer en spectateur"),
        ),
      ],
    );
  }

  Widget _previewView() {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(File(_photo!.path), fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: _openCamera,
              icon: const Icon(Icons.refresh),
              label: const Text("Reprendre"),
            ),
            const SizedBox(width: 16),
            FilledButton.icon(
              onPressed: () =>
                  Navigator.pop(context, CaptureResult.photo(_photo!)),
              icon: const Icon(Icons.check),
              label: const Text("Valider"),
            ),
          ],
        ),
      ],
    );
  }
}
