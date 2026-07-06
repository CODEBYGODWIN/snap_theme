import 'package:cloud_firestore/cloud_firestore.dart';

class GameService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  Future<void> startRound({
    required String roomId,
  }) async {
    final roomRef = _db.collection("rooms").doc(roomId);

    final room = await roomRef.get();

    final currentRound = room["currentRound"] + 1;

    await roomRef.update({
      "status": "playing",
      "currentRound": currentRound,
    });

    await roomRef
        .collection("rounds")
        .doc(currentRound.toString())
        .set({
      "theme": "",
      "status": "theme",
      "endsAt": null,
    });
  }

  Future<void> startPhotoPhase({
    required String roomId,
    required int round,
    required String theme,
  }) async {
    final roomRef = _db.collection("rooms").doc(roomId);

    await roomRef
        .collection("rounds")
        .doc(round.toString())
        .update({
      "theme": theme,
      "status": "photo",
      "endsAt": Timestamp.fromDate(
        DateTime.now().add(
          const Duration(seconds: 60),
        ),
      ),
    });
  }

  Future<void> startVoting(
    String roomId,
    int currentRound,
  ) async {
    final roomRef = _db.collection("rooms").doc(roomId);

    await roomRef
        .collection("rounds")
        .doc(currentRound.toString())
        .update({
      "status": "vote",
    });
  }
}