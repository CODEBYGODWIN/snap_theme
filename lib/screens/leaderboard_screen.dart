import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  final String roomId;

  const LeaderboardScreen({
    super.key,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context) {
    final playersRef = FirebaseFirestore.instance
        .collection("rooms")
        .doc(roomId)
        .collection("players");

    return Scaffold(
      appBar: AppBar(title: const Text("Classement")),
      body: StreamBuilder<QuerySnapshot>(
        stream: playersRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final players = snapshot.data!.docs;

          players.sort((a, b) =>
              b["score"].compareTo(a["score"]));

          return ListView(
            children: players.map((p) {
              return ListTile(
                title: Text(p["displayName"]),
                trailing: Text("${p["score"]} pts"),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}