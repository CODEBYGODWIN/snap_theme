import 'package:freezed_annotation/freezed_annotation.dart';

part 'round.freezed.dart';
part 'round.g.dart';

@freezed
abstract class Round with _$Round {
  const factory Round({
    required String theme,

    // theme | photo | vote | leaderboard
    required String status,

    required DateTime endsAt,
  }) = _Round;

  factory Round.fromJson(Map<String, dynamic> json) =>
      _$RoundFromJson(json);
}