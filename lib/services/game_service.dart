import 'package:cloud_firestore/cloud_firestore.dart';

import 'score_service.dart';

class GameService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> startNextRound(String roomId) async {
    final roomRef = _db.collection("rooms").doc(roomId);
    final room = await roomRef.get();

    final currentRound = room["currentRound"] as int;
    final maxRound = room["maxRound"] as int;
    final nextRound = currentRound + 1;

    if (nextRound > maxRound) {
      await roomRef.update({"status": "finished"});
      return;
    }

    final hostId = room["hostId"] as String;

    String chooserId;
    if (currentRound == 0) {
      chooserId = hostId;
    } else {
      final previousRoundRef = roomRef
          .collection("rounds")
          .doc(currentRound.toString());
      final previousRoundSnap = await previousRoundRef.get();
      final winnerId = previousRoundSnap.data()?["winnerId"] as String?;
      chooserId = winnerId ?? hostId;
    }

    await roomRef.collection("rounds").doc(nextRound.toString()).set({
      "theme": "",
      "status": "theme",
      "chooserId": chooserId,
      "endsAt": Timestamp.now(),
    });

    await roomRef.update({"status": "theme", "currentRound": nextRound});
  }

  Future<void> chooseTheme({
    required String roomId,
    required int round,
    required String theme,
  }) async {
    final roomRef = _db.collection("rooms").doc(roomId);
    final endsAt = Timestamp.fromDate(
      DateTime.now().add(const Duration(seconds: 60)),
    );

    await roomRef.collection("rounds").doc(round.toString()).update({
      "theme": theme,
      "status": "photo",
      "endsAt": endsAt,
    });

    await roomRef.update({"status": "photo"});
  }

  Future<void> startVoting(String roomId, int currentRound) async {
    final roomRef = _db.collection("rooms").doc(roomId);
    final endsAt = Timestamp.fromDate(
      DateTime.now().add(const Duration(seconds: 30)),
    );

    await roomRef.update({"status": "vote"});
    await roomRef.collection("rounds").doc(currentRound.toString()).update({
      "status": "vote",
      "endsAt": endsAt,
    });
  }

  /// La bascule de statut se fait dans une transaction : si plusieurs
  /// clients déclenchent la clôture en même temps (auto-clôture + bouton
  /// hôte), un seul calcule le gagnant et incrémente le score.
  Future<void> endVoting(String roomId, int round) async {
    final roundRef = _db
        .collection("rooms")
        .doc(roomId)
        .collection("rounds")
        .doc(round.toString());

    final shouldProceed = await _db.runTransaction((tx) async {
      final snap = await tx.get(roundRef);
      if (snap.get("status") != "vote") return false;
      tx.update(roundRef, {"status": "leaderboard"});
      return true;
    });

    if (!shouldProceed) return;

    final winnerId = await ScoreService().calculateRoundWinner(
      roomId: roomId,
      roundId: round,
    );

    await roundRef.update({"winnerId": winnerId});
    await _db.collection("rooms").doc(roomId).update({"status": "leaderboard"});
  }
}