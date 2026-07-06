import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LobbyScreen extends StatelessWidget {
  final String roomId;
  final String userId;

  const LobbyScreen({super.key, required this.roomId, required this.userId});

  @override
  Widget build(BuildContext context) {
    final roomRef = FirebaseFirestore.instance.collection("rooms").doc(roomId);

    return Scaffold(
      appBar: AppBar(title: const Text("Lobby")),
      body: Column(
        children: [
          StreamBuilder(
            stream: roomRef.collection("players").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();

              final players = snapshot.data!.docs;

              return Expanded(
                child: ListView(
                  children: players.map((p) {
                    return ListTile(
                      title: Text(p["displayName"]),
                      subtitle: Text("Score: ${p["score"]}"),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          StreamBuilder(
            stream: roomRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              final data = snapshot.data!;
              final hostId = data["hostId"];

              return StreamBuilder(
                stream: roomRef.collection("players").snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) return const SizedBox();

                  final players = snap.data!.docs;

                  final canStart = hostId == userId && players.length >= 3;

                  return ElevatedButton(
                    onPressed: canStart
                        ? () async {
                            await roomRef.update({"status": "playing"});
                          }
                        : null,
                    child: const Text("Démarrer la partie"),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
