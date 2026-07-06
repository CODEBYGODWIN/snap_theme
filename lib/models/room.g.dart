// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Room _$RoomFromJson(Map<String, dynamic> json) => _Room(
  id: json['id'] as String,
  code: json['code'] as String,
  hostId: json['hostId'] as String,
  status: json['status'] as String,
  maxPlayers: (json['maxPlayers'] as num?)?.toInt() ?? 6,
  currentRound: (json['currentRound'] as num?)?.toInt() ?? 0,
  maxRound: (json['maxRound'] as num?)?.toInt() ?? 12,
);

Map<String, dynamic> _$RoomToJson(_Room instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'hostId': instance.hostId,
  'status': instance.status,
  'maxPlayers': instance.maxPlayers,
  'currentRound': instance.currentRound,
  'maxRound': instance.maxRound,
};
