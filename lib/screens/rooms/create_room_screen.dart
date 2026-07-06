import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/room_service.dart';
import '../lobby_screen.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final RoomService _roomService = RoomService();

  bool isLoading = false;
  String error = "";

  Future<void> createRoom() async {
    setState(() {
      isLoading = true;
      error = "";
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          error = "Utilisateur non connecté";
          isLoading = false;
        });
        return;
      }

      final displayName = user.displayName ?? "Player";

      final result = await _roomService.createRoom(user.uid, displayName);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LobbyScreen(
            roomId: result.roomId,
            userId: user.uid,
            code: result.code,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        error = "Erreur création room";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer une room")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Créer une nouvelle partie",
                style: TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 20),

              if (error.isNotEmpty)
                Text(error, style: const TextStyle(color: Colors.red)),

              const SizedBox(height: 20),

              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: createRoom,
                      child: const Text("Créer la room"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
