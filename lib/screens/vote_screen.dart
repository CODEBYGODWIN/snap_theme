import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/vote_service.dart';

class VoteScreen extends StatelessWidget {
  final String roomId;
  final int roundId;
  final String userId;

  const VoteScreen({
    super.key,
    required this.roomId,
    required this.roundId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final roundRef = FirebaseFirestore.instance
        .collection("rooms")
        .doc(roomId)
        .collection("rounds")
        .doc(roundId.toString());

    final submissionsRef = roundRef.collection("submissions");

    return Scaffold(
      appBar: AppBar(title: const Text("Vote")),
      body: StreamBuilder<QuerySnapshot>(
        stream: submissionsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final photos = snapshot.data!.docs;

          return GridView.builder(
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];

              final playerId = photo.id;

              final photoUrl = photo["photoUrl"];

              final isSelf = playerId == userId;

              return GestureDetector(
                onTap: isSelf
                    ? null
                    : () async {
                        await VoteService().vote(
                          roomId: roomId,
                          roundId: roundId,
                          voterId: userId,
                          votedForId: playerId,
                        );
                      },
                child: Card(
                  color: isSelf ? Colors.grey : Colors.white,
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Text(isSelf ? "Toi" : "Voter"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}