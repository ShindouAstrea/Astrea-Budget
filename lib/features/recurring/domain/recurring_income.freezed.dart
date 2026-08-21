// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_income.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecurringIncome {

 String get id;@JsonKey(name: 'household_id') String get householdId;@JsonKey(name: 'user_id') String get userId; String get description; double get amount;@JsonKey(name: 'category_id') String? get categoryId;@JsonKey(name: 'account_id') String? get accountId;@JsonKey(name: 'day_of_month') int get dayOfMonth; bool get active;@JsonKey(name: 'last_generated') DateTime? get lastGenerated;
/// Create a copy of RecurringIncome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringIncomeCopyWith<RecurringIncome> get copyWith => _$RecurringIncomeCopyWithImpl<RecurringIncome>(this as RecurringIncome, _$identity);

  /// Serializes this RecurringIncome to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringIncome&&(identical(other.id, id) || other.id == id)&&(identical(other.householdId, householdId) || other.householdId == householdId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.dayOfMonth, dayOfMonth) || other.dayOfMonth == dayOfMonth)&&(identical(other.active, active) || other.active == active)&&(identical(other.lastGenerated, lastGenerated) || other.lastGenerated == lastGenerated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,householdId,userId,description,amount,categoryId,accountId,dayOfMonth,active,lastGenerated);

@override
String toString() {
  return 'RecurringIncome(id: $id, householdId: $householdId, userId: $userId, description: $description, amount: $amount, categoryId: $categoryId, accountId: $accountId, dayOfMonth: $dayOfMonth, active: $active, lastGenerated: $lastGenerated)';
}


}

/// @nodoc
abstract mixin class $RecurringIncomeCopyWith<$Res>  {
  factory $RecurringIncomeCopyWith(RecurringIncome value, $Res Function(RecurringIncome) _then) = _$RecurringIncomeCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'household_id') String householdId,@JsonKey(name: 'user_id') String userId, String description, double amount,@JsonKey(name: 'category_id') String? categoryId,@JsonKey(name: 'account_id') String? accountId,@JsonKey(name: 'day_of_month') int dayOfMonth, bool active,@JsonKey(name: 'last_generated') DateTime? lastGenerated
});




}
/// @nodoc
class _$RecurringIncomeCopyWithImpl<$Res>
    implements $RecurringIncomeCopyWith<$Res> {
  _$RecurringIncomeCopyWithImpl(this._self, this._then);

  final RecurringIncome _self;
  final $Res Function(RecurringIncome) _then;

/// Create a copy of RecurringIncome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? householdId = null,Object? userId = null,Object? description = null,Object? amount = null,Object? categoryId = freezed,Object? accountId = freezed,Object? dayOfMonth = null,Object? active = null,Object? lastGenerated = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,dayOfMonth: null == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as int,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,lastGenerated: freezed == lastGenerated ? _self.lastGenerated : lastGenerated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurringIncome].
extension RecurringIncomePatterns on RecurringIncome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringIncome value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringIncome() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringIncome value)  $default,){
final _that = this;
switch (_that) {
case _RecurringIncome():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringIncome value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringIncome() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'household_id')  String householdId, @JsonKey(name: 'user_id')  String userId,  String description,  double amount, @JsonKey(name: 'category_id')  String? categoryId, @JsonKey(name: 'account_id')  String? accountId, @JsonKey(name: 'day_of_month')  int dayOfMonth,  bool active, @JsonKey(name: 'last_generated')  DateTime? lastGenerated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringIncome() when $default != null:
return $default(_that.id,_that.householdId,_that.userId,_that.description,_that.amount,_that.categoryId,_that.accountId,_that.dayOfMonth,_that.active,_that.lastGenerated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'household_id')  String householdId, @JsonKey(name: 'user_id')  String userId,  String description,  double amount, @JsonKey(name: 'category_id')  String? categoryId, @JsonKey(name: 'account_id')  String? accountId, @JsonKey(name: 'day_of_month')  int dayOfMonth,  bool active, @JsonKey(name: 'last_generated')  DateTime? lastGenerated)  $default,) {final _that = this;
switch (_that) {
case _RecurringIncome():
return $default(_that.id,_that.householdId,_that.userId,_that.description,_that.amount,_that.categoryId,_that.accountId,_that.dayOfMonth,_that.active,_that.lastGenerated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'household_id')  String householdId, @JsonKey(name: 'user_id')  String userId,  String description,  double amount, @JsonKey(name: 'category_id')  String? categoryId, @JsonKey(name: 'account_id')  String? accountId, @JsonKey(name: 'day_of_month')  int dayOfMonth,  bool active, @JsonKey(name: 'last_generated')  DateTime? lastGenerated)?  $default,) {final _that = this;
switch (_that) {
case _RecurringIncome() when $default != null:
return $default(_that.id,_that.householdId,_that.userId,_that.description,_that.amount,_that.categoryId,_that.accountId,_that.dayOfMonth,_that.active,_that.lastGenerated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecurringIncome implements RecurringIncome {
  const _RecurringIncome({required this.id, @JsonKey(name: 'household_id') required this.householdId, @JsonKey(name: 'user_id') required this.userId, required this.description, this.amount = 0, @JsonKey(name: 'category_id') this.categoryId, @JsonKey(name: 'account_id') this.accountId, @JsonKey(name: 'day_of_month') required this.dayOfMonth, this.active = true, @JsonKey(name: 'last_generated') this.lastGenerated});
  factory _RecurringIncome.fromJson(Map<String, dynamic> json) => _$RecurringIncomeFromJson(json);

@override final  String id;
@override@JsonKey(name: 'household_id') final  String householdId;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String description;
@override@JsonKey() final  double amount;
@override@JsonKey(name: 'category_id') final  String? categoryId;
@override@JsonKey(name: 'account_id') final  String? accountId;
@override@JsonKey(name: 'day_of_month') final  int dayOfMonth;
@override@JsonKey() final  bool active;
@override@JsonKey(name: 'last_generated') final  DateTime? lastGenerated;

/// Create a copy of RecurringIncome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringIncomeCopyWith<_RecurringIncome> get copyWith => __$RecurringIncomeCopyWithImpl<_RecurringIncome>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecurringIncomeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringIncome&&(identical(other.id, id) || other.id == id)&&(identical(other.householdId, householdId) || other.householdId == householdId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.dayOfMonth, dayOfMonth) || other.dayOfMonth == dayOfMonth)&&(identical(other.active, active) || other.active == active)&&(identical(other.lastGenerated, lastGenerated) || other.lastGenerated == lastGenerated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,householdId,userId,description,amount,categoryId,accountId,dayOfMonth,active,lastGenerated);

@override
String toString() {
  return 'RecurringIncome(id: $id, householdId: $householdId, userId: $userId, description: $description, amount: $amount, categoryId: $categoryId, accountId: $accountId, dayOfMonth: $dayOfMonth, active: $active, lastGenerated: $lastGenerated)';
}


}

/// @nodoc
abstract mixin class _$RecurringIncomeCopyWith<$Res> implements $RecurringIncomeCopyWith<$Res> {
  factory _$RecurringIncomeCopyWith(_RecurringIncome value, $Res Function(_RecurringIncome) _then) = __$RecurringIncomeCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'household_id') String householdId,@JsonKey(name: 'user_id') String userId, String description, double amount,@JsonKey(name: 'category_id') String? categoryId,@JsonKey(name: 'account_id') String? accountId,@JsonKey(name: 'day_of_month') int dayOfMonth, bool active,@JsonKey(name: 'last_generated') DateTime? lastGenerated
});




}
/// @nodoc
class __$RecurringIncomeCopyWithImpl<$Res>
    implements _$RecurringIncomeCopyWith<$Res> {
  __$RecurringIncomeCopyWithImpl(this._self, this._then);

  final _RecurringIncome _self;
  final $Res Function(_RecurringIncome) _then;

/// Create a copy of RecurringIncome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? householdId = null,Object? userId = null,Object? description = null,Object? amount = null,Object? categoryId = freezed,Object? accountId = freezed,Object? dayOfMonth = null,Object? active = null,Object? lastGenerated = freezed,}) {
  return _then(_RecurringIncome(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,dayOfMonth: null == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as int,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,lastGenerated: freezed == lastGenerated ? _self.lastGenerated : lastGenerated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
