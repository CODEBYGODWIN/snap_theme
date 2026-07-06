import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/game_service.dart';
import '../services/vote_service.dart';
import 'leaderboard_screen.dart';

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
    final roomRef = FirebaseFirestore.instance.collection("rooms").doc(roomId);
    final roundRef =
        roomRef.collection("rounds").doc(roundId.toString());
    final submissionsRef = roundRef.collection("submissions");
    final votesRef = roomRef.collection("votes");

    return StreamBuilder<DocumentSnapshot>(
      stream: roomRef.snapshots(),
      builder: (context, roomSnapshot) {
        final roomData = roomSnapshot.data?.data() as Map<String, dynamic>?;
        final status = roomData?["status"] as String?;
        final hostId = roomData?["hostId"] as String?;

        if (status != null && status != "vote") {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    LeaderboardScreen(roomId: roomId, userId: userId),
              ),
            );
          });
        }

        return Scaffold(
          appBar: AppBar(title: const Text("Vote")),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: submissionsRef.snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final photos = snapshot.data!.docs;

                    if (photos.isEmpty) {
                      return const Center(
                        child: Text("Aucune photo soumise pour cette manche."),
                      );
                    }

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
              ),
              if (hostId == userId)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: roomRef
                        .collection("players")
                        .where("isSpectator", isEqualTo: false)
                        .snapshots(),
                    builder: (context, playersSnapshot) {
                      final eligible = playersSnapshot.data?.docs.length ?? 0;

                      return StreamBuilder<QuerySnapshot>(
                        stream: votesRef
                            .where("round", isEqualTo: roundId)
                            .snapshots(),
                        builder: (context, voteSnapshot) {
                          final votes = voteSnapshot.data?.docs.length ?? 0;

                          // Tout le monde a voté : on clôture automatiquement.
                          if (eligible > 0 && votes >= eligible) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              GameService().endVoting(roomId, roundId);
                            });
                          }

                          return FilledButton(
                            onPressed: () async {
                              await GameService().endVoting(roomId, roundId);
                            },
                            child: Text("Clôturer le vote ($votes/$eligible)"),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
