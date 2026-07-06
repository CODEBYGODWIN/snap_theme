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
    int maxPlayers,
    int maxRounds,
  ) async {
    final code = generateCode();
    final roomRef = _db.collection("rooms").doc();

    await roomRef.set({
      "code": code,
      "hostId": hostId,
      "status": "waiting",
      "maxPlayers": maxPlayers,
      "currentRound": 0,
      "maxRound": maxRounds,
      "gameStarted": false,
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

    await roomRef.collection("players").doc(userId).delete();
  }

  Future<void> startGame(String roomId) async {
    final roomRef = _db.collection("rooms").doc(roomId);
    final players = await roomRef.collection("players").get();

    for (final p in players.docs) {
      await p.reference.update({"score": 0});
    }

    await roomRef.update({
      "status": "playing",
      "currentRound": 1,
      "gameStarted": true,
    });
  }

  Future<void> resetToLobby(String roomId) async {
    await _db.collection("rooms").doc(roomId).update({
      "status": "waiting",
      "currentRound": 0,
      "gameStarted": false,
    });
  }

  Future<void> setSpectator(String roomId, String userId) async {
    await _db
        .collection("rooms")
        .doc(roomId)
        .collection("players")
        .doc(userId)
        .set({
          "isSpectator": true,
          "canCapture": false,
        }, SetOptions(merge: true));
  }
}