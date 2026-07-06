import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> calculateRoundWinner({
    required String roomId,
    required int roundId,
  }) async {

    final votes = await _db
        .collection("rooms")
        .doc(roomId)
        .collection("votes")
        .where("round", isEqualTo: roundId)
        .get();

    final Map<String, int> count = {};

    for (var v in votes.docs) {
      final votedFor = v["votedForPlayerId"];
      count[votedFor] = (count[votedFor] ?? 0) + 1;
    }

    // trouver le max
    String? winner;
    int maxVotes = 0;

    count.forEach((player, votes) {
      if (votes > maxVotes) {
        maxVotes = votes;
        winner = player;
      }
    });

    if (winner == null) return null;

    final playerRef = _db
        .collection("rooms")
        .doc(roomId)
        .collection("players")
        .doc(winner);

    await playerRef.update({
      "score": FieldValue.increment(1),
    });

    return winner;
  }
}