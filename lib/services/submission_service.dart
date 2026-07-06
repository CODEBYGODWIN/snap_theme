import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class SubmissionClosedException implements Exception {}

class SubmissionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> submitPhoto({
    required String roomId,
    required int round,
    required String userId,
    required XFile photo,
  }) async {
    final roundRef = _db
        .collection("rooms")
        .doc(roomId)
        .collection("rounds")
        .doc(round.toString());

    final roundSnap = await roundRef.get();
    final endsAt = (roundSnap["endsAt"] as Timestamp).toDate();
    if (DateTime.now().isAfter(endsAt)) {
      throw SubmissionClosedException();
    }

    final storageRef = _storage.ref("rooms/$roomId/rounds/$round/$userId.jpg");
    await storageRef.putFile(
      File(photo.path),
      SettableMetadata(contentType: "image/jpeg"),
    );
    final photoUrl = await storageRef.getDownloadURL();

    await roundRef.collection("submissions").doc(userId).set({
      "photoUrl": photoUrl,
      "submittedAt": FieldValue.serverTimestamp(),
    });

    return photoUrl;
  }
}
