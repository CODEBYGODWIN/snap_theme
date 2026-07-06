import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomService {
  final _db = FirebaseFirestore.instance;

  String generateCode(){
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6,(index) => chars[Random().nextInt(chars.length)]).join();
  }

  Future<String> createRoom(String hostId, String displayName) async {
    final code = generateCode();

    final roomRef = _db.collection("rooms").doc();

    await roomRef.set({
      "code":code,
      "hostId":hostId,
      "status":"waiting",
      "maxPlayers":6,
      "currentRound":0,
      "maxRound":12,
    });

    await roomRef.collection("players").doc(hostId).set({
      "displayName" : displayName,
      "joinedAt" : FieldValue.serverTimestamp(),
      "canCapture" : false,
      "isSpectator" : false,
      "score" : 0,
    });
    return roomRef.id;
  }

  Future<String?> joinRoom(String code, String userId, String name) async{
    final query = await _db.collection("rooms").where("code",isEqualTo: code).get();
    if(query.docs.isEmpty) return null;
    
    final room = query.docs.first;
    final players = await room.reference.collection("players").get();
    if(players.docs.length >= room.data()["maxPlayers"]) return null;
    return room.id;
  }

  Future<void> leaveRoom(String roomId, String userId) async {
    await _db.collection("rooms").doc(roomId).collection("players").doc(userId).delete();
  }

  Stream<QuerySnapshot> roomStream(String roomId) {
    return _db.collection("rooms").doc(roomId).collection("players").snapshots();
  }
}
