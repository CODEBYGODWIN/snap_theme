import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/game_service.dart';
import '../services/vote_service.dart';
import '../widgets/countdown_timer.dart';
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
    final myVoteRef = votesRef.doc("${roundId}_$userId");

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
              Padding(
                padding: const EdgeInsets.all(16),
                child: CountdownTimer(
                  roomId: roomId,
                  round: roundId,
                  onExpired: () => GameService().endVoting(roomId, roundId),
                ),
              ),
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

                    return StreamBuilder<DocumentSnapshot>(
                      stream: myVoteRef.snapshots(),
                      builder: (context, myVoteSnapshot) {
                        final votedForId = myVoteSnapshot.data?.exists == true
                            ? myVoteSnapshot.data!.get("votedForPlayerId")
                                  as String?
                            : null;

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
                            final isVoted = playerId == votedForId;

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
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: isVoted
                                        ? Colors.green
                                        : Colors.transparent,
                                    width: 4,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Image.network(
                                        photoUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Text(
                                      isSelf
                                          ? "Toi"
                                          : isVoted
                                              ? "✅ Ton vote"
                                              : "Voter",
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
                          final allVoted = eligible > 0 && votes >= eligible;

                          return _CloseVoteButton(
                            roomId: roomId,
                            roundId: roundId,
                            votes: votes,
                            eligible: eligible,
                            autoClose: allVoted,
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

/// Bouton de clôture du vote côté hôte : se désactive pendant l'appel pour
/// éviter l'impression de bouton "bloqué", et se déclenche aussi tout seul
/// (une fois) dès que tous les joueurs éligibles ont voté.
class _CloseVoteButton extends StatefulWidget {
  final String roomId;
  final int roundId;
  final int votes;
  final int eligible;
  final bool autoClose;

  const _CloseVoteButton({
    required this.roomId,
    required this.roundId,
    required this.votes,
    required this.eligible,
    required this.autoClose,
  });

  @override
  State<_CloseVoteButton> createState() => _CloseVoteButtonState();
}

class _CloseVoteButtonState extends State<_CloseVoteButton> {
  bool _closing = false;

  @override
  void didUpdateWidget(covariant _CloseVoteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoClose && !_closing) {
      _close();
    }
  }

  Future<void> _close() async {
    if (_closing) return;
    setState(() => _closing = true);
    await GameService().endVoting(widget.roomId, widget.roundId);
    // Pas de setState après coup : la navigation vers le leaderboard suit.
  }

  @override
  void initState() {
    super.initState();
    if (widget.autoClose) _close();
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: _closing ? null : _close,
      child: _closing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text("Clôturer le vote (${widget.votes}/${widget.eligible})"),
    );
  }
}
