import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/countdown_timer.dart';

class GameScreen extends StatelessWidget {
  final String roomId;

  const GameScreen({
    super.key,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context) {
    final roomRef =
        FirebaseFirestore.instance.collection("rooms").doc(roomId);

    return StreamBuilder<DocumentSnapshot>(
      stream: roomRef.snapshots(),
      builder: (context, roomSnapshot) {
        if (!roomSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final roomData =
            roomSnapshot.data!.data() as Map<String, dynamic>;

        final int currentRound = roomData["currentRound"];

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

            return Scaffold(
              appBar: AppBar(
                title: const Text("SnapThème"),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Thème",
                      style: TextStyle(fontSize: 20),
                    ),

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

                    CountdownTimer(
                      roomId: roomId,
                      round: currentRound,
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