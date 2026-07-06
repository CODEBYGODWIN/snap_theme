import 'package:cloud_firestore/cloud_firestore.dart';

class GameService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> startRound({required String roomId,required String theme,}) async {
    final roomRef = _db.collection("rooms").doc(roomId);

    final room = await roomRef.get();

    final currentRound = room["currentRound"] + 1;

    final endsAt = Timestamp.fromDate(
      DateTime.now().add(const Duration(seconds: 60)),
    );

    await roomRef.update({"status": "playing","theme": theme,"currentRound": currentRound,});

    await roomRef.collection("rounds").doc(currentRound.toString()).set({"theme": theme,"status": "playing","endsAt": endsAt,});
  }

  Future<void> startVoting(String roomId,int currentRound,) async {

    final roomRef = _db.collection("rooms").doc(roomId);

    await roomRef.update({"status": "voting",});

    await roomRef.collection("rounds").doc(currentRound.toString()).update({"status": "voting",});
  }
}