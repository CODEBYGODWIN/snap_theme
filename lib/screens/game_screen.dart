import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/game_service.dart';
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
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final TextEditingController themeController = TextEditingController();

  @override
  void dispose() {
    themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomRef =
        FirebaseFirestore.instance.collection("rooms").doc(widget.roomId);

    return StreamBuilder<DocumentSnapshot>(
      stream: roomRef.snapshots(),
      builder: (context, roomSnapshot) {
        if (!roomSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final roomDoc = roomSnapshot.data!;

        // 🔥 IMPORTANT : sécurité null + cast safe
        final room = roomDoc.data() as Map<String, dynamic>?;

        if (room == null) {
          return const Scaffold(
            body: Center(child: Text("Room introuvable")),
          );
        }

        final int currentRound = room["currentRound"] ?? 0;
        final String hostId = room["hostId"] ?? "";

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

            final roundDoc = roundSnapshot.data!;

            // 🔥 FIX PRINCIPAL ICI
            final roundData =
                roundDoc.data() as Map<String, dynamic>?;

            // 👉 si round pas encore créé
            if (roundData == null) {
              return const Scaffold(
                body: Center(
                  child: Text("En attente du lancement du round..."),
                ),
              );
            }

            final String status = roundData["status"] ?? "theme";
            final String theme = roundData["theme"] ?? "";

            // ===============================
            // NAVIGATION VOTE
            // ===============================
            if (status == "vote") {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VoteScreen(
                      roomId: widget.roomId,
                      roundId: currentRound,
                      userId: widget.userId,
                    ),
                  ),
                );
              });
            }

            return Scaffold(
              appBar: AppBar(
                title: Text("Manche $currentRound"),
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Builder(
                    builder: (_) {

                      // ===============================
                      // THEME PHASE
                      // ===============================
                      if (status == "theme") {
                        if (widget.userId == hostId) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Choisissez le thème",
                                style: TextStyle(fontSize: 24),
                              ),
                              const SizedBox(height: 20),

                              TextField(
                                controller: themeController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Ex : Voiture rouge",
                                ),
                              ),

                              const SizedBox(height: 20),

                              ElevatedButton(
                                onPressed: () async {
                                  final value =
                                      themeController.text.trim();

                                  if (value.isEmpty) return;

                                  await GameService().startPhotoPhase(
                                    roomId: widget.roomId,
                                    round: currentRound,
                                    theme: value,
                                  );
                                },
                                child: const Text("Valider"),
                              ),
                            ],
                          );
                        }

                        return const Text(
                          "Le host choisit un thème...",
                          style: TextStyle(fontSize: 22),
                        );
                      }

                      // ===============================
                      // PHOTO PHASE
                      // ===============================
                      if (status == "photo") {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Thème",
                              style: TextStyle(fontSize: 22),
                            ),

                            const SizedBox(height: 20),

                            Text(
                              theme,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 50),

                            CountdownTimer(
                              roomId: widget.roomId,
                              round: currentRound,
                            ),
                          ],
                        );
                      }

                      return const CircularProgressIndicator();
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}