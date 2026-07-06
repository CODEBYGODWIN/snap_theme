// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'round.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Round _$RoundFromJson(Map<String, dynamic> json) => _Round(
  theme: json['theme'] as String,
  status: json['status'] as String,
  endsAt: DateTime.parse(json['endsAt'] as String),
);

Map<String, dynamic> _$RoundToJson(_Round instance) => <String, dynamic>{
  'theme': instance.theme,
  'status': instance.status,
  'endsAt': instance.endsAt.toIso8601String(),
};
