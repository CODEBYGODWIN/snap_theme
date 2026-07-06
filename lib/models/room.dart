import 'package:freezed_annotation/freezed_annotation.dart';

part 'room.freezed.dart';
part 'room.g.dart';

@freezed
abstract class Room with _$Room {
  const factory Room({
    required String id,
    required String code,
    required String hostId,
    required String status,
    @Default(6) int maxPlayers,
    @Default(0) int currentRound,
    @Default(12) int maxRound,
  }) = _Room;

  factory Room.fromJson(Map<String, dynamic> json) =>
      _$RoomFromJson(json);
}