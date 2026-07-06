// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Player _$PlayerFromJson(Map<String, dynamic> json) => _Player(
  id: json['id'] as String,
  displayName: json['displayName'] as String,
  isSpectator: json['isSpectator'] as bool? ?? false,
  score: (json['score'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PlayerToJson(_Player instance) => <String, dynamic>{
  'id': instance.id,
  'displayName': instance.displayName,
  'isSpectator': instance.isSpectator,
  'score': instance.score,
};
