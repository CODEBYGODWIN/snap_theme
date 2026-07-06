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

  int maxPlayers = 4;
  int maxRounds = 5;

  bool isLoading = false;
  String error = "";

  Future<void> createRoom() async {
    setState(() {
      isLoading = true;
      error = "";
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final displayName = user.displayName ?? "Player";

      final result = await _roomService.createRoom(
        user.uid,
        displayName,
        maxPlayers,
        maxRounds,
      );

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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Configuration de la partie"),

            const SizedBox(height: 20),

            Text("Joueurs max: $maxPlayers"),
            Slider(
              value: maxPlayers.toDouble(),
              min: 2,
              max: 8,
              divisions: 6,
              onChanged: (v) => setState(() => maxPlayers = v.toInt()),
            ),

            Text("Rounds: $maxRounds"),
            Slider(
              value: maxRounds.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (v) => setState(() => maxRounds = v.toInt()),
            ),

            const SizedBox(height: 20),

            if (error.isNotEmpty)
              Text(error, style: const TextStyle(color: Colors.red)),

            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: createRoom,
                    child: const Text("Créer"),
                  ),
          ],
        ),
      ),
    );
  }
}