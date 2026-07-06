import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {

  final String roomId;
  final int round;
  final Future<void> Function() onExpired;

  const CountdownTimer({
    super.key,
    required this.roomId,
    required this.round,
    required this.onExpired,
  });
  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? timer;
  int? seconds;

  @override
  void initState() {
    super.initState();
    startListening();
  }

  void startListening(){

    FirebaseFirestore.instance.collection("rooms").doc(widget.roomId).collection("rounds").doc(widget.round.toString()).snapshots().listen((event){
      final Timestamp end = event["endsAt"];
      timer?.cancel();
      _tick(end);
      timer = Timer.periodic(
        const Duration(seconds:1),
            (timer) => _tick(end),
      );

    });

  }

  void _tick(Timestamp end) async {
    final remaining = end
        .toDate()
        .difference(DateTime.now())
        .inSeconds;
    if(!mounted)return;
    setState(() {
      seconds = remaining.clamp(0,60);
    });
    if(seconds==0){
      timer?.cancel();
      await widget.onExpired();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (seconds == null) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Text(
      "$seconds",
      style: const TextStyle(
        fontSize:45,
        fontWeight: FontWeight.bold,
      ),
    );

  }

}
