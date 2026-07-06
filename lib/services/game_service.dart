import 'package:cloud_firestore/cloud_firestore.dart';

class GameService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🚀 DÉMARRER PARTIE → CRÉER ROUND 1 DIRECTEMENT
  Future<void> startGame({
    required String roomId,
  }) async {
    final roomRef = _db.collection("rooms").doc(roomId);

    final roomSnap = await roomRef.get();
    final data = roomSnap.data() as Map<String, dynamic>;

    final firstRound = 1;

    await roomRef.update({
      "status": "playing",
      "currentRound": firstRound,
    });

    // 🔥 CRÉATION OBLIGATOIRE DU ROUND 1
    await roomRef.collection("rounds").doc(firstRound.toString()).set({
      "theme": "",
      "status": "theme", // 👈 important
      "endsAt": null,
    });
  }

  /// 🎯 HOST ENTRE LE THEME → PASSAGE PHOTO
  Future<void> startPhotoPhase({
    required String roomId,
    required int round,
    required String theme,
  }) async {
    final roomRef = _db.collection("rooms").doc(roomId);
    final roundRef = roomRef.collection("rounds").doc(round.toString());

    final endsAt = Timestamp.fromDate(
      DateTime.now().add(const Duration(seconds: 60)),
    );

    await roundRef.update({
      "theme": theme,
      "status": "photo",
      "endsAt": endsAt,
    });
  }

  /// 🗳 PASSAGE VOTE
  Future<void> startVoting({
    required String roomId,
    required int round,
  }) async {
    final roomRef = _db.collection("rooms").doc(roomId);

    await roomRef.update({
      "status": "voting",
    });

    await roomRef
        .collection("rounds")
        .doc(round.toString())
        .update({
      "status": "vote",
    });
  }
}