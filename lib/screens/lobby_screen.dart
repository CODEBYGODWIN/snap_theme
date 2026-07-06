import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snap_theme/services/game_service.dart';
import 'package:snap_theme/services/room_service.dart';
import 'game_screen.dart';

class LobbyScreen extends StatelessWidget {
  final String roomId;
  final String userId;
  final String? code;

  const LobbyScreen({
    super.key,
    required this.roomId,
    required this.userId,
    this.code,
  });

  @override
  Widget build(BuildContext context) {
    final roomRef = FirebaseFirestore.instance.collection("rooms").doc(roomId);
    final roomService = RoomService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lobby"),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: "Quitter la room",
            onPressed: () async {
              await roomService.leaveRoom(roomId, userId);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: roomRef.snapshots(),
        builder: (context, roomSnapshot) {
          if (!roomSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final roomData = roomSnapshot.data!;
          final hostId = roomData["hostId"];
          final status = roomData["status"];

          // 🚀 Dès que la partie démarre, tout le monde bascule sur GameScreen
          if (status != "waiting") {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => GameScreen(roomId: roomId, userId: userId),
                ),
              );
            });
          }

          return Column(
            children: [
              if (code != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            "Code de la room",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            code!,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 👥 PLAYERS LIVE
              StreamBuilder(
                stream: roomRef.collection("players").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final players = snapshot.data!.docs;

                  return Expanded(
                    child: ListView(
                      children: players.map((p) {
                        final isHost = p.id == hostId;
                        return ListTile(
                          title: Row(
                            children: [
                              Text(p["displayName"]),
                              if (isHost) ...[
                                const SizedBox(width: 6),
                                const Text(
                                  "👑",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Text("Score: ${p["score"]}"),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),

              if (hostId == userId)
                StreamBuilder(
                  stream: roomRef.collection("players").snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData) return const SizedBox();

                    final players = snap.data!.docs;
                    final canStart = players.length >= 2;

                    return ElevatedButton(
                      onPressed: canStart
                          ? () async {
                              await roomService.startGame(roomId);
                              await GameService().startNextRound(roomId);
                            }
                          : null,
                      child: const Text("Démarrer la partie"),
                    );
                  },
                ),

              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
}

