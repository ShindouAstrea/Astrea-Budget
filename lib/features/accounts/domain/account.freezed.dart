// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Account {

 String get id;@JsonKey(name: 'household_id') String get householdId;@JsonKey(name: 'user_id') String get userId; String get name; AccountType get type;@JsonKey(name: 'initial_balance') double get initialBalance;// Campos de crédito (sólo cuando type == credito).
@JsonKey(name: 'credit_limit') double? get creditLimit;@JsonKey(name: 'statement_day') int? get statementDay;@JsonKey(name: 'payment_due_day') int? get paymentDueDay; String get color; String get icon; bool get archived;
/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountCopyWith<Account> get copyWith => _$AccountCopyWithImpl<Account>(this as Account, _$identity);

  /// Serializes this Account to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Account&&(identical(other.id, id) || other.id == id)&&(identical(other.householdId, householdId) || other.householdId == householdId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.initialBalance, initialBalance) || other.initialBalance == initialBalance)&&(identical(other.creditLimit, creditLimit) || other.creditLimit == creditLimit)&&(identical(other.statementDay, statementDay) || other.statementDay == statementDay)&&(identical(other.paymentDueDay, paymentDueDay) || other.paymentDueDay == paymentDueDay)&&(identical(other.color, color) || other.color == color)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.archived, archived) || other.archived == archived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,householdId,userId,name,type,initialBalance,creditLimit,statementDay,paymentDueDay,color,icon,archived);

@override
String toString() {
  return 'Account(id: $id, householdId: $householdId, userId: $userId, name: $name, type: $type, initialBalance: $initialBalance, creditLimit: $creditLimit, statementDay: $statementDay, paymentDueDay: $paymentDueDay, color: $color, icon: $icon, archived: $archived)';
}


}

/// @nodoc
abstract mixin class $AccountCopyWith<$Res>  {
  factory $AccountCopyWith(Account value, $Res Function(Account) _then) = _$AccountCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'household_id') String householdId,@JsonKey(name: 'user_id') String userId, String name, AccountType type,@JsonKey(name: 'initial_balance') double initialBalance,@JsonKey(name: 'credit_limit') double? creditLimit,@JsonKey(name: 'statement_day') int? statementDay,@JsonKey(name: 'payment_due_day') int? paymentDueDay, String color, String icon, bool archived
});




}
/// @nodoc
class _$AccountCopyWithImpl<$Res>
    implements $AccountCopyWith<$Res> {
  _$AccountCopyWithImpl(this._self, this._then);

  final Account _self;
  final $Res Function(Account) _then;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? householdId = null,Object? userId = null,Object? name = null,Object? type = null,Object? initialBalance = null,Object? creditLimit = freezed,Object? statementDay = freezed,Object? paymentDueDay = freezed,Object? color = null,Object? icon = null,Object? archived = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AccountType,initialBalance: null == initialBalance ? _self.initialBalance : initialBalance // ignore: cast_nullable_to_non_nullable
as double,creditLimit: freezed == creditLimit ? _self.creditLimit : creditLimit // ignore: cast_nullable_to_non_nullable
as double?,statementDay: freezed == statementDay ? _self.statementDay : statementDay // ignore: cast_nullable_to_non_nullable
as int?,paymentDueDay: freezed == paymentDueDay ? _self.paymentDueDay : paymentDueDay // ignore: cast_nullable_to_non_nullable
as int?,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Account].
extension AccountPatterns on Account {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Account value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Account() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Account value)  $default,){
final _that = this;
switch (_that) {
case _Account():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Account value)?  $default,){
final _that = this;
switch (_that) {
case _Account() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'household_id')  String householdId, @JsonKey(name: 'user_id')  String userId,  String name,  AccountType type, @JsonKey(name: 'initial_balance')  double initialBalance, @JsonKey(name: 'credit_limit')  double? creditLimit, @JsonKey(name: 'statement_day')  int? statementDay, @JsonKey(name: 'payment_due_day')  int? paymentDueDay,  String color,  String icon,  bool archived)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Account() when $default != null:
return $default(_that.id,_that.householdId,_that.userId,_that.name,_that.type,_that.initialBalance,_that.creditLimit,_that.statementDay,_that.paymentDueDay,_that.color,_that.icon,_that.archived);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'household_id')  String householdId, @JsonKey(name: 'user_id')  String userId,  String name,  AccountType type, @JsonKey(name: 'initial_balance')  double initialBalance, @JsonKey(name: 'credit_limit')  double? creditLimit, @JsonKey(name: 'statement_day')  int? statementDay, @JsonKey(name: 'payment_due_day')  int? paymentDueDay,  String color,  String icon,  bool archived)  $default,) {final _that = this;
switch (_that) {
case _Account():
return $default(_that.id,_that.householdId,_that.userId,_that.name,_that.type,_that.initialBalance,_that.creditLimit,_that.statementDay,_that.paymentDueDay,_that.color,_that.icon,_that.archived);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'household_id')  String householdId, @JsonKey(name: 'user_id')  String userId,  String name,  AccountType type, @JsonKey(name: 'initial_balance')  double initialBalance, @JsonKey(name: 'credit_limit')  double? creditLimit, @JsonKey(name: 'statement_day')  int? statementDay, @JsonKey(name: 'payment_due_day')  int? paymentDueDay,  String color,  String icon,  bool archived)?  $default,) {final _that = this;
switch (_that) {
case _Account() when $default != null:
return $default(_that.id,_that.householdId,_that.userId,_that.name,_that.type,_that.initialBalance,_that.creditLimit,_that.statementDay,_that.paymentDueDay,_that.color,_that.icon,_that.archived);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Account extends Account {
  const _Account({required this.id, @JsonKey(name: 'household_id') required this.householdId, @JsonKey(name: 'user_id') required this.userId, required this.name, this.type = AccountType.debito, @JsonKey(name: 'initial_balance') this.initialBalance = 0, @JsonKey(name: 'credit_limit') this.creditLimit, @JsonKey(name: 'statement_day') this.statementDay, @JsonKey(name: 'payment_due_day') this.paymentDueDay, this.color = '#2563EB', this.icon = 'account_balance_wallet', this.archived = false}): super._();
  factory _Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

@override final  String id;
@override@JsonKey(name: 'household_id') final  String householdId;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String name;
@override@JsonKey() final  AccountType type;
@override@JsonKey(name: 'initial_balance') final  double initialBalance;
// Campos de crédito (sólo cuando type == credito).
@override@JsonKey(name: 'credit_limit') final  double? creditLimit;
@override@JsonKey(name: 'statement_day') final  int? statementDay;
@override@JsonKey(name: 'payment_due_day') final  int? paymentDueDay;
@override@JsonKey() final  String color;
@override@JsonKey() final  String icon;
@override@JsonKey() final  bool archived;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountCopyWith<_Account> get copyWith => __$AccountCopyWithImpl<_Account>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Account&&(identical(other.id, id) || other.id == id)&&(identical(other.householdId, householdId) || other.householdId == householdId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.initialBalance, initialBalance) || other.initialBalance == initialBalance)&&(identical(other.creditLimit, creditLimit) || other.creditLimit == creditLimit)&&(identical(other.statementDay, statementDay) || other.statementDay == statementDay)&&(identical(other.paymentDueDay, paymentDueDay) || other.paymentDueDay == paymentDueDay)&&(identical(other.color, color) || other.color == color)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.archived, archived) || other.archived == archived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,householdId,userId,name,type,initialBalance,creditLimit,statementDay,paymentDueDay,color,icon,archived);

@override
String toString() {
  return 'Account(id: $id, householdId: $householdId, userId: $userId, name: $name, type: $type, initialBalance: $initialBalance, creditLimit: $creditLimit, statementDay: $statementDay, paymentDueDay: $paymentDueDay, color: $color, icon: $icon, archived: $archived)';
}


}

/// @nodoc
abstract mixin class _$AccountCopyWith<$Res> implements $AccountCopyWith<$Res> {
  factory _$AccountCopyWith(_Account value, $Res Function(_Account) _then) = __$AccountCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'household_id') String householdId,@JsonKey(name: 'user_id') String userId, String name, AccountType type,@JsonKey(name: 'initial_balance') double initialBalance,@JsonKey(name: 'credit_limit') double? creditLimit,@JsonKey(name: 'statement_day') int? statementDay,@JsonKey(name: 'payment_due_day') int? paymentDueDay, String color, String icon, bool archived
});




}
/// @nodoc
class __$AccountCopyWithImpl<$Res>
    implements _$AccountCopyWith<$Res> {
  __$AccountCopyWithImpl(this._self, this._then);

  final _Account _self;
  final $Res Function(_Account) _then;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? householdId = null,Object? userId = null,Object? name = null,Object? type = null,Object? initialBalance = null,Object? creditLimit = freezed,Object? statementDay = freezed,Object? paymentDueDay = freezed,Object? color = null,Object? icon = null,Object? archived = null,}) {
  return _then(_Account(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AccountType,initialBalance: null == initialBalance ? _self.initialBalance : initialBalance // ignore: cast_nullable_to_non_nullable
as double,creditLimit: freezed == creditLimit ? _self.creditLimit : creditLimit // ignore: cast_nullable_to_non_nullable
as double?,statementDay: freezed == statementDay ? _self.statementDay : statementDay // ignore: cast_nullable_to_non_nullable
as int?,paymentDueDay: freezed == paymentDueDay ? _self.paymentDueDay : paymentDueDay // ignore: cast_nullable_to_non_nullable
as int?,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
