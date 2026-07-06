// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'round.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Round {

 String get theme;// theme | photo | vote | leaderboard
 String get status; DateTime get endsAt;
/// Create a copy of Round
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoundCopyWith<Round> get copyWith => _$RoundCopyWithImpl<Round>(this as Round, _$identity);

  /// Serializes this Round to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Round&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.status, status) || other.status == status)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,theme,status,endsAt);

@override
String toString() {
  return 'Round(theme: $theme, status: $status, endsAt: $endsAt)';
}


}

/// @nodoc
abstract mixin class $RoundCopyWith<$Res>  {
  factory $RoundCopyWith(Round value, $Res Function(Round) _then) = _$RoundCopyWithImpl;
@useResult
$Res call({
 String theme, String status, DateTime endsAt
});




}
/// @nodoc
class _$RoundCopyWithImpl<$Res>
    implements $RoundCopyWith<$Res> {
  _$RoundCopyWithImpl(this._self, this._then);

  final Round _self;
  final $Res Function(Round) _then;

/// Create a copy of Round
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? theme = null,Object? status = null,Object? endsAt = null,}) {
  return _then(_self.copyWith(
theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,endsAt: null == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Round].
extension RoundPatterns on Round {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Round value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Round() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Round value)  $default,){
final _that = this;
switch (_that) {
case _Round():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Round value)?  $default,){
final _that = this;
switch (_that) {
case _Round() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String theme,  String status,  DateTime endsAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Round() when $default != null:
return $default(_that.theme,_that.status,_that.endsAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String theme,  String status,  DateTime endsAt)  $default,) {final _that = this;
switch (_that) {
case _Round():
return $default(_that.theme,_that.status,_that.endsAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String theme,  String status,  DateTime endsAt)?  $default,) {final _that = this;
switch (_that) {
case _Round() when $default != null:
return $default(_that.theme,_that.status,_that.endsAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Round implements Round {
  const _Round({required this.theme, required this.status, required this.endsAt});
  factory _Round.fromJson(Map<String, dynamic> json) => _$RoundFromJson(json);

@override final  String theme;
// theme | photo | vote | leaderboard
@override final  String status;
@override final  DateTime endsAt;

/// Create a copy of Round
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoundCopyWith<_Round> get copyWith => __$RoundCopyWithImpl<_Round>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoundToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Round&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.status, status) || other.status == status)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,theme,status,endsAt);

@override
String toString() {
  return 'Round(theme: $theme, status: $status, endsAt: $endsAt)';
}


}

/// @nodoc
abstract mixin class _$RoundCopyWith<$Res> implements $RoundCopyWith<$Res> {
  factory _$RoundCopyWith(_Round value, $Res Function(_Round) _then) = __$RoundCopyWithImpl;
@override @useResult
$Res call({
 String theme, String status, DateTime endsAt
});




}
/// @nodoc
class __$RoundCopyWithImpl<$Res>
    implements _$RoundCopyWith<$Res> {
  __$RoundCopyWithImpl(this._self, this._then);

  final _Round _self;
  final $Res Function(_Round) _then;

/// Create a copy of Round
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? theme = null,Object? status = null,Object? endsAt = null,}) {
  return _then(_Round(
theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,endsAt: null == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
