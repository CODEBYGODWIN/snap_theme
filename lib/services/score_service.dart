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

    if (count.isEmpty) return null;

    // Chaque joueur marque autant de points que de votes reçus.
    final playersRef = _db
        .collection("rooms")
        .doc(roomId)
        .collection("players");

    final batch = _db.batch();
    count.forEach((playerId, votesReceived) {
      batch.update(playersRef.doc(playerId), {
        "score": FieldValue.increment(votesReceived),
      });
    });
    await batch.commit();

    // "Gagnant" de la manche = le(s) plus voté(s) — sert uniquement à
    // l'affichage (photo mise en avant), pas au calcul des points.
    final maxVotes = count.values.reduce((a, b) => a > b ? a : b);
    final topPlayers = count.entries
        .where((e) => e.value == maxVotes)
        .map((e) => e.key)
        .toList();

    return topPlayers.length == 1 ? topPlayers.first : null;
  }
}