import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/game_service.dart';
import '../services/room_service.dart';
import 'game_screen.dart';
import 'lobby_screen.dart';

class LeaderboardScreen extends StatelessWidget {
  final String roomId;
  final String userId;

  const LeaderboardScreen({
    super.key,
    required this.roomId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final roomRef = FirebaseFirestore.instance.collection("rooms").doc(roomId);
    final playersRef = roomRef.collection("players");

    return StreamBuilder<DocumentSnapshot>(
      stream: roomRef.snapshots(),
      builder: (context, roomSnapshot) {
        if (!roomSnapshot.hasData || !roomSnapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final roomData = roomSnapshot.data!.data() as Map<String, dynamic>;
        final status = roomData["status"] as String;
        final hostId = roomData["hostId"] as String;
        final currentRound = roomData["currentRound"] as int;
        final maxRound = roomData["maxRound"] as int;

        if (status == "theme") {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => GameScreen(roomId: roomId, userId: userId),
              ),
            );
          });
        } else if (status == "waiting") {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => LobbyScreen(
                  roomId: roomId,
                  userId: userId,
                  code: roomData["code"] as String?,
                ),
              ),
            );
          });
        }

        final roundRef = roomRef
            .collection("rounds")
            .doc(currentRound.toString());

        return StreamBuilder<DocumentSnapshot>(
          stream: roundRef.snapshots(),
          builder: (context, roundSnapshot) {
            final winnerId = roundSnapshot.data?.get("winnerId") as String?;

            return Scaffold(
              appBar: AppBar(
                title: Text(
                  status == "finished"
                      ? "🏆 Classement final"
                      : "Classement — Manche $currentRound/$maxRound",
                ),
              ),
              body: StreamBuilder<QuerySnapshot>(
                stream: playersRef.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final players = snapshot.data!.docs.toList()
                    ..sort((a, b) => b["score"].compareTo(a["score"]));

                  return Column(
                    children: [
                      if (winnerId != null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            "🎉 ${_nameOf(players, winnerId)} remporte la manche !",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Expanded(
                        child: ListView(
                          children: players.map((p) {
                            return ListTile(
                              title: Text(p["displayName"]),
                              trailing: Text("${p["score"]} pts"),
                            );
                          }).toList(),
                        ),
                      ),
                      if (hostId == userId)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: FilledButton(
                            onPressed: () async {
                              if (status == "finished") {
                                await RoomService().resetToLobby(roomId);
                              } else {
                                await GameService().startNextRound(roomId);
                              }
                            },
                            child: Text(
                              status == "finished"
                                  ? "Retour au lobby"
                                  : currentRound < maxRound
                                  ? "Manche suivante"
                                  : "Voir le classement final",
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  String _nameOf(List<QueryDocumentSnapshot> players, String id) {
    final match = players.where((p) => p.id == id);
    if (match.isEmpty) return "?";
    return match.first["displayName"];
  }
}
