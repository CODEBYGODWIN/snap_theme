import 'package:cloud_firestore/cloud_firestore.dart';

class VoteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> vote({
    required String roomId,
    required int roundId,
    required String voterId,
    required String votedForId,
  }) async {

    final voteId = "${roundId}_$voterId";

    final voteRef = _db
        .collection("rooms")
        .doc(roomId)
        .collection("votes")
        .doc(voteId);

    await voteRef.set({
      "round": roundId,
      "votedForPlayerId": votedForId,
    });
  }
}