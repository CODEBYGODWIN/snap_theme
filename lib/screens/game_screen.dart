import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/game_service.dart';
import '../services/submission_service.dart';
import '../widgets/countdown_timer.dart';
import 'capture_screen.dart';
import 'leaderboard_screen.dart';
import 'vote_screen.dart';

class GameScreen extends StatelessWidget {
  final String roomId;
  final String userId;

  const GameScreen({super.key, required this.roomId, required this.userId});

  @override
  Widget build(BuildContext context) {
    final roomRef = FirebaseFirestore.instance.collection("rooms").doc(roomId);

    return StreamBuilder<DocumentSnapshot>(
      stream: roomRef.snapshots(),
      builder: (context, roomSnapshot) {
        if (!roomSnapshot.hasData || !roomSnapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final roomData = roomSnapshot.data!.data() as Map<String, dynamic>;

        final int currentRound = roomData["currentRound"];
        final String status = roomData["status"];

        if (status == "vote") {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => VoteScreen(
                  roomId: roomId,
                  roundId: currentRound,
                  userId: userId,
                ),
              ),
            );
          });
        } else if (status == "leaderboard" || status == "finished") {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    LeaderboardScreen(roomId: roomId, userId: userId),
              ),
            );
          });
        }

        final roundRef = roomRef
            .collection("rounds")
            .doc(currentRound.toString());

        return StreamBuilder<DocumentSnapshot>(
          stream: roundRef.snapshots(),
          builder: (context, roundSnapshot) {
            if (!roundSnapshot.hasData || !roundSnapshot.data!.exists) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final roundData =
                roundSnapshot.data!.data() as Map<String, dynamic>;
            final roundStatus = roundData["status"];

            return Scaffold(
              appBar: AppBar(title: const Text("SnapThème")),
              body: roundStatus == "theme"
                  ? _ThemePicker(
                      roomId: roomId,
                      userId: userId,
                      round: currentRound,
                      chooserId: roundData["chooserId"],
                    )
                  : _PhotoPhase(
                      roomId: roomId,
                      userId: userId,
                      round: currentRound,
                      theme: roundData["theme"],
                    ),
            );
          },
        );
      },
    );
  }
}

class _ThemePicker extends StatefulWidget {
  final String roomId;
  final String userId;
  final int round;
  final String chooserId;

  const _ThemePicker({
    required this.roomId,
    required this.userId,
    required this.round,
    required this.chooserId,
  });

  @override
  State<_ThemePicker> createState() => _ThemePickerState();
}

class _ThemePickerState extends State<_ThemePicker> {
  final _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isChooser = widget.userId == widget.chooserId;

    if (!isChooser) {
      final chooserRef = FirebaseFirestore.instance
          .collection("rooms")
          .doc(widget.roomId)
          .collection("players")
          .doc(widget.chooserId);

      return StreamBuilder<DocumentSnapshot>(
        stream: chooserRef.snapshots(),
        builder: (context, snapshot) {
          final name = snapshot.data?.get("displayName") ?? "...";
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(
                  "$name choisit le thème de la manche...",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          );
        },
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "C'est à toi de choisir le thème !",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: "Ex: quelque chose de bleu",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _submitting
                ? const CircularProgressIndicator()
                : FilledButton(
                    onPressed: () async {
                      final theme = _controller.text.trim();
                      if (theme.isEmpty) return;
                      setState(() => _submitting = true);
                      await GameService().chooseTheme(
                        roomId: widget.roomId,
                        round: widget.round,
                        theme: theme,
                      );
                    },
                    child: const Text("Valider le thème"),
                  ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPhase extends StatelessWidget {
  final String roomId;
  final String userId;
  final int round;
  final String theme;

  const _PhotoPhase({
    required this.roomId,
    required this.userId,
    required this.round,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final roomRef = FirebaseFirestore.instance.collection("rooms").doc(roomId);
    final playerRef = roomRef.collection("players").doc(userId);
    final submissionRef = roomRef
        .collection("rounds")
        .doc(round.toString())
        .collection("submissions")
        .doc(userId);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Thème", style: TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          Text(
            theme,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          CountdownTimer(roomId: roomId, round: round),
          const SizedBox(height: 30),
          StreamBuilder<DocumentSnapshot>(
            stream: playerRef.snapshots(),
            builder: (context, playerSnapshot) {
              final isSpectator =
                  playerSnapshot.data?.get("isSpectator") ?? false;

              if (isSpectator) {
                return const Text(
                  "Tu es spectateur pour cette manche : tu pourras voter.",
                  textAlign: TextAlign.center,
                );
              }

              return StreamBuilder<DocumentSnapshot>(
                stream: submissionRef.snapshots(),
                builder: (context, submissionSnapshot) {
                  if (submissionSnapshot.data?.exists ?? false) {
                    return const Text(
                      "✅ Photo envoyée, en attente des autres joueurs...",
                      textAlign: TextAlign.center,
                    );
                  }

                  return FilledButton.icon(
                    onPressed: () => _capture(context),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Prendre ma photo"),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _capture(BuildContext context) async {
    final result = await Navigator.push<CaptureResult>(
      context,
      MaterialPageRoute(
        builder: (_) => CaptureScreen(roomId: roomId, userId: userId),
      ),
    );

    if (result == null || result.photo == null) return;

    try {
      await SubmissionService().submitPhoto(
        roomId: roomId,
        round: round,
        userId: userId,
        photo: result.photo!,
      );
    } on SubmissionClosedException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Trop tard, le temps est écoulé.")),
        );
      }
    }
  }
}
