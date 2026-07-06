import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/submission_service.dart';
import '../widgets/countdown_timer.dart';
import 'vote_screen.dart';

class GameScreen extends StatefulWidget {
  final String roomId;
  final String userId;

  const GameScreen({
    super.key,
    required this.roomId,
    required this.userId,
  });

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
        final String status = roomData["status"];

        // 🗳️ Dès que le vote démarre, tout le monde bascule sur VoteScreen
        if (status == "voting") {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => VoteScreen(
                  roomId: roomId,
                  roundId: currentRound,
                  userId: userId,
                ),
              ),
            );
          });
        }

        // 🔥 On écoute directement la manche actuelle
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
