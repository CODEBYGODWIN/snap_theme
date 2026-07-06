import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/game_service.dart';

class CountdownTimer extends StatefulWidget {

  final String roomId;
  final int round;

  const CountdownTimer({super.key,required this.roomId,required this.round,});
  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? timer;
  int seconds = 60;
  @override
  void initState() {
    super.initState();
    startListening();
  }

  void startListening(){

    FirebaseFirestore.instance.collection("rooms").doc(widget.roomId).collection("rounds").doc(widget.round.toString()).snapshots().listen((event){
      final Timestamp end = event["endsAt"];
      timer?.cancel();
      timer = Timer.periodic(
        const Duration(seconds:1),
            (timer) async{
          final remaining = end
              .toDate()
              .difference(DateTime.now())
              .inSeconds;
          if(!mounted)return;
          setState(() {
            seconds = remaining.clamp(0,60);
          });
          if(seconds==0){
            timer.cancel();
            await GameService().startVoting(
              widget.roomId,
              widget.round,
            );
          }

        },

      );

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
        fontSize:45,
        fontWeight: FontWeight.bold,
      ),
    );

  }

}