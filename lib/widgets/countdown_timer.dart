import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/game_service.dart';

class CountdownTimer extends StatefulWidget {
  final String roomId;
  final int round;

  const CountdownTimer({
    super.key,
    required this.roomId,
    required this.round,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? timer;
  int seconds = 0;

  @override
  void initState() {
    super.initState();
    _listenToEndsAt();
  }

  void _listenToEndsAt() {
    final ref = FirebaseFirestore.instance
        .collection("rooms")
        .doc(widget.roomId)
        .collection("rounds")
        .doc(widget.round.toString());

    ref.snapshots().listen((event) {
      if (!event.exists) return;

      final data = event.data() as Map<String, dynamic>;

      final Timestamp? endTimestamp = data["endsAt"];

      if (endTimestamp == null) return;

      timer?.cancel();

      timer = Timer.periodic(const Duration(seconds: 1), (_) async {
        final endTime = endTimestamp.toDate();
        final now = DateTime.now();

        final remaining = endTime.difference(now).inSeconds;

        if (!mounted) return;

        setState(() {
          seconds = remaining < 0 ? 0 : remaining;
        });

        if (seconds <= 0) {
          timer?.cancel();

          await GameService().startVoting(widget.roomId, widget.round);
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "$seconds",
      style: const TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}