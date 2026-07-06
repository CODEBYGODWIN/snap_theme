import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/room_service.dart';
import 'lobby_screen.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final RoomService _roomService = RoomService();

  final TextEditingController codeController = TextEditingController();

  bool isLoading = false;
  String error = "";

  Future<void> joinRoom() async {
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

      final roomId = await _roomService.joinRoom(
        codeController.text.trim().toUpperCase(),
        user.uid,
        displayName,
      );

      if (roomId == null) {
        setState(() {
          error = "Room introuvable ou pleine";
          isLoading = false;
        });
        return;
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LobbyScreen(
            roomId: roomId,
            userId: user.uid,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        error = "Erreur lors de la connexion à la room";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rejoindre une room")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Entrer le code de la room",
                style: TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Code (ex: ABC12)",
                ),
              ),

              const SizedBox(height: 20),

              if (error.isNotEmpty)
                Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                ),

              const SizedBox(height: 20),

              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: joinRoom,
                      child: const Text("Rejoindre"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}