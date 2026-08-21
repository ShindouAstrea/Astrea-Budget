// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'savings_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavingsGoal {

 String get id;@JsonKey(name: 'household_id') String get householdId;@JsonKey(name: 'user_id') String get userId; String get name;@JsonKey(name: 'target_amount') double get targetAmount;@JsonKey(name: 'current_amount') double get currentAmount;@JsonKey(name: 'target_date') DateTime? get targetDate;@JsonKey(name: 'account_id') String? get accountId; String get icon; String get color;
/// Create a copy of SavingsGoal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavingsGoalCopyWith<SavingsGoal> get copyWith => _$SavingsGoalCopyWithImpl<SavingsGoal>(this as SavingsGoal, _$identity);

  /// Serializes this SavingsGoal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavingsGoal&&(identical(other.id, id) || other.id == id)&&(identical(other.householdId, householdId) || other.householdId == householdId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.currentAmount, currentAmount) || other.currentAmount == currentAmount)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,householdId,userId,name,targetAmount,currentAmount,targetDate,accountId,icon,color);

@override
String toString() {
  return 'SavingsGoal(id: $id, householdId: $householdId, userId: $userId, name: $name, targetAmount: $targetAmount, currentAmount: $currentAmount, targetDate: $targetDate, accountId: $accountId, icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class $SavingsGoalCopyWith<$Res>  {
  factory $SavingsGoalCopyWith(SavingsGoal value, $Res Function(SavingsGoal) _then) = _$SavingsGoalCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'household_id') String householdId,@JsonKey(name: 'user_id') String userId, String name,@JsonKey(name: 'target_amount') double targetAmount,@JsonKey(name: 'current_amount') double currentAmount,@JsonKey(name: 'target_date') DateTime? targetDate,@JsonKey(name: 'account_id') String? accountId, String icon, String color
});




}
/// @nodoc
class _$SavingsGoalCopyWithImpl<$Res>
    implements $SavingsGoalCopyWith<$Res> {
  _$SavingsGoalCopyWithImpl(this._self, this._then);

  final SavingsGoal _self;
  final $Res Function(SavingsGoal) _then;

/// Create a copy of SavingsGoal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? householdId = null,Object? userId = null,Object? name = null,Object? targetAmount = null,Object? currentAmount = null,Object? targetDate = freezed,Object? accountId = freezed,Object? icon = null,Object? color = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as double,currentAmount: null == currentAmount ? _self.currentAmount : currentAmount // ignore: cast_nullable_to_non_nullable
as double,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SavingsGoal].
extension SavingsGoalPatterns on SavingsGoal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavingsGoal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavingsGoal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavingsGoal value)  $default,){
final _that = this;
switch (_that) {
case _SavingsGoal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavingsGoal value)?  $default,){
final _that = this;
switch (_that) {
case _SavingsGoal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'household_id')  String householdId, @JsonKey(name: 'user_id')  String userId,  String name, @JsonKey(name: 'target_amount')  double targetAmount, @JsonKey(name: 'current_amount')  double currentAmount, @JsonKey(name: 'target_date')  DateTime? targetDate, @JsonKey(name: 'account_id')  String? accountId,  String icon,  String color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavingsGoal() when $default != null:
return $default(_that.id,_that.householdId,_that.userId,_that.name,_that.targetAmount,_that.currentAmount,_that.targetDate,_that.accountId,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'household_id')  String householdId, @JsonKey(name: 'user_id')  String userId,  String name, @JsonKey(name: 'target_amount')  double targetAmount, @JsonKey(name: 'current_amount')  double currentAmount, @JsonKey(name: 'target_date')  DateTime? targetDate, @JsonKey(name: 'account_id')  String? accountId,  String icon,  String color)  $default,) {final _that = this;
switch (_that) {
case _SavingsGoal():
return $default(_that.id,_that.householdId,_that.userId,_that.name,_that.targetAmount,_that.currentAmount,_that.targetDate,_that.accountId,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'household_id')  String householdId, @JsonKey(name: 'user_id')  String userId,  String name, @JsonKey(name: 'target_amount')  double targetAmount, @JsonKey(name: 'current_amount')  double currentAmount, @JsonKey(name: 'target_date')  DateTime? targetDate, @JsonKey(name: 'account_id')  String? accountId,  String icon,  String color)?  $default,) {final _that = this;
switch (_that) {
case _SavingsGoal() when $default != null:
return $default(_that.id,_that.householdId,_that.userId,_that.name,_that.targetAmount,_that.currentAmount,_that.targetDate,_that.accountId,_that.icon,_that.color);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavingsGoal extends SavingsGoal {
  const _SavingsGoal({required this.id, @JsonKey(name: 'household_id') required this.householdId, @JsonKey(name: 'user_id') required this.userId, required this.name, @JsonKey(name: 'target_amount') this.targetAmount = 0, @JsonKey(name: 'current_amount') this.currentAmount = 0, @JsonKey(name: 'target_date') this.targetDate, @JsonKey(name: 'account_id') this.accountId, this.icon = 'savings', this.color = '#16A34A'}): super._();
  factory _SavingsGoal.fromJson(Map<String, dynamic> json) => _$SavingsGoalFromJson(json);

@override final  String id;
@override@JsonKey(name: 'household_id') final  String householdId;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String name;
@override@JsonKey(name: 'target_amount') final  double targetAmount;
@override@JsonKey(name: 'current_amount') final  double currentAmount;
@override@JsonKey(name: 'target_date') final  DateTime? targetDate;
@override@JsonKey(name: 'account_id') final  String? accountId;
@override@JsonKey() final  String icon;
@override@JsonKey() final  String color;

/// Create a copy of SavingsGoal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavingsGoalCopyWith<_SavingsGoal> get copyWith => __$SavingsGoalCopyWithImpl<_SavingsGoal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavingsGoalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavingsGoal&&(identical(other.id, id) || other.id == id)&&(identical(other.householdId, householdId) || other.householdId == householdId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.currentAmount, currentAmount) || other.currentAmount == currentAmount)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,householdId,userId,name,targetAmount,currentAmount,targetDate,accountId,icon,color);

@override
String toString() {
  return 'SavingsGoal(id: $id, householdId: $householdId, userId: $userId, name: $name, targetAmount: $targetAmount, currentAmount: $currentAmount, targetDate: $targetDate, accountId: $accountId, icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class _$SavingsGoalCopyWith<$Res> implements $SavingsGoalCopyWith<$Res> {
  factory _$SavingsGoalCopyWith(_SavingsGoal value, $Res Function(_SavingsGoal) _then) = __$SavingsGoalCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'household_id') String householdId,@JsonKey(name: 'user_id') String userId, String name,@JsonKey(name: 'target_amount') double targetAmount,@JsonKey(name: 'current_amount') double currentAmount,@JsonKey(name: 'target_date') DateTime? targetDate,@JsonKey(name: 'account_id') String? accountId, String icon, String color
});




}
/// @nodoc
class __$SavingsGoalCopyWithImpl<$Res>
    implements _$SavingsGoalCopyWith<$Res> {
  __$SavingsGoalCopyWithImpl(this._self, this._then);

  final _SavingsGoal _self;
  final $Res Function(_SavingsGoal) _then;

/// Create a copy of SavingsGoal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? householdId = null,Object? userId = null,Object? name = null,Object? targetAmount = null,Object? currentAmount = null,Object? targetDate = freezed,Object? accountId = freezed,Object? icon = null,Object? color = null,}) {
  return _then(_SavingsGoal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as double,currentAmount: null == currentAmount ? _self.currentAmount : currentAmount // ignore: cast_nullable_to_non_nullable
as double,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
