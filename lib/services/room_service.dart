import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomService {
  final _db = FirebaseFirestore.instance;

  String generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      6,
      (index) => chars[Random().nextInt(chars.length)],
    ).join();
  }

  Future<({String roomId, String code})> createRoom(
    String hostId,
    String displayName,
  ) async {
    final code = generateCode();

    final roomRef = _db.collection("rooms").doc();

    await roomRef.set({
      "code": code,
      "hostId": hostId,
      "status": "waiting",
      "maxPlayers": 6,
      "currentRound": 0,
      "maxRound": 12,
    });

    await roomRef.collection("players").doc(hostId).set({
      "displayName": displayName,
      "joinedAt": FieldValue.serverTimestamp(),
      "canCapture": false,
      "isSpectator": false,
      "score": 0,
    });

    return (roomId: roomRef.id, code: code);
  }

  Future<({String roomId, String code})?> joinRoom(
    String code,
    String userId,
    String name,
  ) async {
    final query = await _db
        .collection("rooms")
        .where("code", isEqualTo: code)
        .get();
    if (query.docs.isEmpty) return null;

    final room = query.docs.first;
    final players = await room.reference.collection("players").get();
    if (players.docs.length >= room.data()["maxPlayers"]) return null;

    await room.reference.collection("players").doc(userId).set({
      "displayName": name,
      "joinedAt": FieldValue.serverTimestamp(),
      "canCapture": false,
      "isSpectator": false,
      "score": 0,
    });

    return (roomId: room.id, code: room.data()["code"] as String);
  }

  Future<void> leaveRoom(String roomId, String userId) async {
    final roomRef = _db.collection("rooms").doc(roomId);
    final roomSnap = await roomRef.get();
    if (!roomSnap.exists) return;

    final hostId = roomSnap.data()?["hostId"];

    await roomRef.collection("players").doc(userId).delete();

    // Si celui qui quitte était l'hôte, on réassigne au joueur suivant
    if (hostId == userId) {
      final remaining = await roomRef
          .collection("players")
          .orderBy("joinedAt")
          .limit(1)
          .get();

      if (remaining.docs.isNotEmpty) {
        await roomRef.update({"hostId": remaining.docs.first.id});
      }
    }
  }

  Stream<QuerySnapshot> roomStream(String roomId) {
    return _db
        .collection("rooms")
        .doc(roomId)
        .collection("players")
        .snapshots();
  }

  final List<String> _themes = [
    "Un animal mignon",
    "Un plat français",
    "Un monument connu",
    "Un super-héros",
    "Un moyen de transport",
    // ajoute les tiens
  ];

  Future<void> startGame(String roomId) async {
    final roomRef = _db.collection("rooms").doc(roomId);

    final theme = _themes[Random().nextInt(_themes.length)];

    await roomRef.collection("rounds").doc("0").set({
      "theme": theme,
      "startedAt": FieldValue.serverTimestamp(),
      "endsAt": Timestamp.fromDate(
        DateTime.now().add(const Duration(seconds: 10)), //TODO: Change to 60 seconds
      ),
    });

    await roomRef.update({"status": "playing", "currentRound": 0});
  }
}
