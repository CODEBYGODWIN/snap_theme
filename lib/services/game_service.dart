import 'package:cloud_firestore/cloud_firestore.dart';

class GameService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// =========================
  /// CREATE ROUND (fix missing)
  /// =========================
  Future<void> createRound({
    required String roomId,
    required int round,
  }) async {
    final roomRef = _db.collection("rooms").doc(roomId);

    await roomRef.collection("rounds").doc(round.toString()).set({
      "status": "theme",
      "theme": "",
      "createdAt": FieldValue.serverTimestamp(),
      "endsAt": null,
    });
  }

  // =========================
  // THEME → PHOTO
  // =========================
  Future<void> startPhotoPhase({
    required String roomId,
    required int round,
    required String theme,
  }) async {
    final roundRef = _db
        .collection("rooms")
        .doc(roomId)
        .collection("rounds")
        .doc(round.toString());

    final endsAt = Timestamp.fromDate(
      DateTime.now().add(const Duration(seconds: 60)),
    );

    await roundRef.update({
      "theme": theme,
      "status": "photo",
      "endsAt": endsAt,
    });
  }

  // =========================
  // PHOTO → VOTE
  // =========================
  Future<void> startVoting({
    required String roomId,
    required int round,
  }) async {
    final roomRef = _db.collection("rooms").doc(roomId);
    final roundRef = roomRef.collection("rounds").doc(round.toString());

    await roomRef.update({
      "status": "voting",
    });

    await roundRef.update({
      "status": "vote",
    });
  }

  // =========================
  // VOTE → LEADERBOARD
  // =========================
  Future<void> startLeaderboard({
    required String roomId,
    required int round,
  }) async {
    final roomRef = _db.collection("rooms").doc(roomId);
    final roundRef = roomRef.collection("rounds").doc(round.toString());

    await roomRef.update({
      "status": "playing",
    });

    await roundRef.update({
      "status": "leaderboard",
    });
  }

  // =========================
  // NEXT ROUND
  // =========================
  Future<void> nextRound({
    required String roomId,
    required int currentRound,
  }) async {
    final roomRef = _db.collection("rooms").doc(roomId);
    final nextRound = currentRound + 1;

    await roomRef.update({
      "currentRound": nextRound,
    });

    await roomRef.collection("rounds").doc(nextRound.toString()).set({
      "theme": "",
      "status": "theme",
      "endsAt": null,
    });
  }

  // =========================
  // END GAME
  // =========================
  Future<void> finishGame({
    required String roomId,
  }) async {
    final roomRef = _db.collection("rooms").doc(roomId);

    await roomRef.update({
      "status": "finished",
    });
  }
}