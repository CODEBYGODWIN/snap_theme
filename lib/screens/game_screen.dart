import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/submission_service.dart';
import '../widgets/countdown_timer.dart';
import 'capture_screen.dart';

class GameScreen extends StatefulWidget {
  final String roomId;

  const GameScreen({super.key, required this.roomId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final SubmissionService _submissionService = SubmissionService();

  XFile? _photo;
  bool _isSpectator = false;

  bool _uploading = false;
  bool _submitted = false;
  String? _uploadError;

  Future<void> _capturePhoto(int round) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final result = await Navigator.of(context).push<CaptureResult>(
      MaterialPageRoute(
        builder: (_) => CaptureScreen(roomId: widget.roomId, userId: userId),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _photo = result.photo;
      _isSpectator = result.becameSpectator;
      _submitted = false;
      _uploadError = null;
    });
    if (result.photo != null) await _uploadPhoto(round);
  }

  Future<void> _uploadPhoto(int round) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    setState(() {
      _uploading = true;
      _uploadError = null;
    });
    try {
      await _submissionService.submitPhoto(
        roomId: widget.roomId,
        round: round,
        userId: userId,
        photo: _photo!,
      );
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _submitted = true;
      });
    } on SubmissionClosedException {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _uploadError = "Temps écoulé : la soumission est fermée.";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _uploadError = "Échec de l'envoi. Vérifie ta connexion.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomRef = FirebaseFirestore.instance
        .collection("rooms")
        .doc(widget.roomId);

    return StreamBuilder<DocumentSnapshot>(
      stream: roomRef.snapshots(),
      builder: (context, roomSnapshot) {
        if (!roomSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final roomData = roomSnapshot.data!.data() as Map<String, dynamic>;

        final int currentRound = roomData["currentRound"];

        final roundRef = roomRef
            .collection("rounds")
            .doc(currentRound.toString());

        return StreamBuilder<DocumentSnapshot>(
          stream: roundRef.snapshots(),
          builder: (context, roundSnapshot) {
            if (!roundSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final roundData =
                roundSnapshot.data!.data() as Map<String, dynamic>;

            final theme = roundData["theme"];
            final endsAt = (roundData["endsAt"] as Timestamp).toDate();
            final canShoot =
                roundData["status"] == "playing" &&
                DateTime.now().isBefore(endsAt);

            return Scaffold(
              appBar: AppBar(title: const Text("SnapThème")),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Thème", style: TextStyle(fontSize: 20)),

                    const SizedBox(height: 20),

                    Text(
                      theme,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 50),

                    CountdownTimer(roomId: widget.roomId, round: currentRound),

                    const SizedBox(height: 30),

                    if (_isSpectator)
                      const Text(
                        "👀 Mode spectateur : tu voteras à la fin du round",
                      )
                    else if (_photo != null) ...[
                      SizedBox(
                        height: 160,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(File(_photo!.path)),
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (_uploading)
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text("Envoi en cours…"),
                          ],
                        )
                      else if (_submitted) ...[
                        const Text("✅ Photo envoyée !"),
                        if (canShoot)
                          TextButton(
                            onPressed: () => _capturePhoto(currentRound),
                            child: const Text("Changer de photo"),
                          ),
                      ] else if (_uploadError != null) ...[
                        Text(
                          _uploadError!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        if (canShoot)
                          FilledButton.icon(
                            onPressed: () => _uploadPhoto(currentRound),
                            icon: const Icon(Icons.refresh),
                            label: const Text("Réessayer l'envoi"),
                          ),
                      ],
                    ] else if (canShoot)
                      FilledButton.icon(
                        onPressed: () => _capturePhoto(currentRound),
                        icon: const Icon(Icons.photo_camera),
                        label: const Text("Prendre ma photo"),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
