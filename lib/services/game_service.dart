import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'score_service.dart';

class GameService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Démarre la manche suivante : le gagnant de la manche précédente choisit
  /// le thème (un joueur aléatoire pour la toute première manche). Si le
  /// nombre max de manches est dépassé, la partie passe en "finished".
  Future<void> startNextRound(String roomId, {String? winnerId}) async {
    final roomRef = _db.collection("rooms").doc(roomId);
    final room = await roomRef.get();

    final currentRound = room["currentRound"] as int;
    final maxRound = room["maxRound"] as int;
    final nextRound = currentRound + 1;

    if (nextRound > maxRound) {
      await roomRef.update({"status": "finished"});
      return;
    }

    String chooserId;
    if (winnerId != null) {
      chooserId = winnerId;
    } else {
      final players = await roomRef.collection("players").get();
      final eligible =
          players.docs.where((p) => !(p["isSpectator"] ?? false)).toList();
      final pool = eligible.isNotEmpty ? eligible : players.docs;
      chooserId = pool[Random().nextInt(pool.length)].id;
    }

    await roomRef.collection("rounds").doc(nextRound.toString()).set({
      "theme": "",
      "status": "theme",
      "chooserId": chooserId,
      "endsAt": Timestamp.now(),
    });

    await roomRef.update({"status": "theme", "currentRound": nextRound});
  }

  /// Le joueur désigné valide le thème : la manche passe en phase photo
  /// avec un timer de 60s synchronisé côté serveur (endsAt).
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

    await roomRef.update({"status": "vote"});
    await roomRef.collection("rounds").doc(currentRound.toString()).update({
      "status": "vote",
    });
  }

  /// Clôture le vote, calcule le gagnant et passe la manche en leaderboard.
  /// Idempotent : un vote déjà clôturé n'est pas recompté.
  Future<void> endVoting(String roomId, int round) async {
    final roundRef = _db
        .collection("rooms")
        .doc(roomId)
        .collection("rounds")
        .doc(round.toString());

    final roundSnap = await roundRef.get();
    if (roundSnap["status"] != "vote") return;

    final winnerId = await ScoreService().calculateRoundWinner(
      roomId: roomId,
      roundId: round,
    );

    await roundRef.update({"status": "leaderboard", "winnerId": winnerId});
    await _db.collection("rooms").doc(roomId).update({
      "status": "leaderboard",
    });
  }
}
