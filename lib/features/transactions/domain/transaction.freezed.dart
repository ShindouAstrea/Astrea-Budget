// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransactionModel {

 String get id;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'household_id') String? get householdId;@JsonKey(name: 'account_id') String? get accountId; TransactionType get type; double get amount; DateTime get date; String? get description;@JsonKey(name: 'category_id') String? get categoryId;@JsonKey(name: 'service_id') String? get serviceId;@JsonKey(name: 'transfer_group_id') String? get transferGroupId;// Compras en cuotas: N filas (una por mes) con el mismo grupo.
@JsonKey(name: 'installment_group_id') String? get installmentGroupId;@JsonKey(name: 'installments_total') int? get installmentsTotal;@JsonKey(name: 'installment_number') int? get installmentNumber;
/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionModelCopyWith<TransactionModel> get copyWith => _$TransactionModelCopyWithImpl<TransactionModel>(this as TransactionModel, _$identity);

  /// Serializes this TransactionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.householdId, householdId) || other.householdId == householdId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.description, description) || other.description == description)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.transferGroupId, transferGroupId) || other.transferGroupId == transferGroupId)&&(identical(other.installmentGroupId, installmentGroupId) || other.installmentGroupId == installmentGroupId)&&(identical(other.installmentsTotal, installmentsTotal) || other.installmentsTotal == installmentsTotal)&&(identical(other.installmentNumber, installmentNumber) || other.installmentNumber == installmentNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,householdId,accountId,type,amount,date,description,categoryId,serviceId,transferGroupId,installmentGroupId,installmentsTotal,installmentNumber);

@override
String toString() {
  return 'TransactionModel(id: $id, userId: $userId, householdId: $householdId, accountId: $accountId, type: $type, amount: $amount, date: $date, description: $description, categoryId: $categoryId, serviceId: $serviceId, transferGroupId: $transferGroupId, installmentGroupId: $installmentGroupId, installmentsTotal: $installmentsTotal, installmentNumber: $installmentNumber)';
}


}

/// @nodoc
abstract mixin class $TransactionModelCopyWith<$Res>  {
  factory $TransactionModelCopyWith(TransactionModel value, $Res Function(TransactionModel) _then) = _$TransactionModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'household_id') String? householdId,@JsonKey(name: 'account_id') String? accountId, TransactionType type, double amount, DateTime date, String? description,@JsonKey(name: 'category_id') String? categoryId,@JsonKey(name: 'service_id') String? serviceId,@JsonKey(name: 'transfer_group_id') String? transferGroupId,@JsonKey(name: 'installment_group_id') String? installmentGroupId,@JsonKey(name: 'installments_total') int? installmentsTotal,@JsonKey(name: 'installment_number') int? installmentNumber
});




}
/// @nodoc
class _$TransactionModelCopyWithImpl<$Res>
    implements $TransactionModelCopyWith<$Res> {
  _$TransactionModelCopyWithImpl(this._self, this._then);

  final TransactionModel _self;
  final $Res Function(TransactionModel) _then;

/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? householdId = freezed,Object? accountId = freezed,Object? type = null,Object? amount = null,Object? date = null,Object? description = freezed,Object? categoryId = freezed,Object? serviceId = freezed,Object? transferGroupId = freezed,Object? installmentGroupId = freezed,Object? installmentsTotal = freezed,Object? installmentNumber = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,householdId: freezed == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,serviceId: freezed == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String?,transferGroupId: freezed == transferGroupId ? _self.transferGroupId : transferGroupId // ignore: cast_nullable_to_non_nullable
as String?,installmentGroupId: freezed == installmentGroupId ? _self.installmentGroupId : installmentGroupId // ignore: cast_nullable_to_non_nullable
as String?,installmentsTotal: freezed == installmentsTotal ? _self.installmentsTotal : installmentsTotal // ignore: cast_nullable_to_non_nullable
as int?,installmentNumber: freezed == installmentNumber ? _self.installmentNumber : installmentNumber // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionModel].
extension TransactionModelPatterns on TransactionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionModel value)  $default,){
final _that = this;
switch (_that) {
case _TransactionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionModel value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'household_id')  String? householdId, @JsonKey(name: 'account_id')  String? accountId,  TransactionType type,  double amount,  DateTime date,  String? description, @JsonKey(name: 'category_id')  String? categoryId, @JsonKey(name: 'service_id')  String? serviceId, @JsonKey(name: 'transfer_group_id')  String? transferGroupId, @JsonKey(name: 'installment_group_id')  String? installmentGroupId, @JsonKey(name: 'installments_total')  int? installmentsTotal, @JsonKey(name: 'installment_number')  int? installmentNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
return $default(_that.id,_that.userId,_that.householdId,_that.accountId,_that.type,_that.amount,_that.date,_that.description,_that.categoryId,_that.serviceId,_that.transferGroupId,_that.installmentGroupId,_that.installmentsTotal,_that.installmentNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'household_id')  String? householdId, @JsonKey(name: 'account_id')  String? accountId,  TransactionType type,  double amount,  DateTime date,  String? description, @JsonKey(name: 'category_id')  String? categoryId, @JsonKey(name: 'service_id')  String? serviceId, @JsonKey(name: 'transfer_group_id')  String? transferGroupId, @JsonKey(name: 'installment_group_id')  String? installmentGroupId, @JsonKey(name: 'installments_total')  int? installmentsTotal, @JsonKey(name: 'installment_number')  int? installmentNumber)  $default,) {final _that = this;
switch (_that) {
case _TransactionModel():
return $default(_that.id,_that.userId,_that.householdId,_that.accountId,_that.type,_that.amount,_that.date,_that.description,_that.categoryId,_that.serviceId,_that.transferGroupId,_that.installmentGroupId,_that.installmentsTotal,_that.installmentNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'household_id')  String? householdId, @JsonKey(name: 'account_id')  String? accountId,  TransactionType type,  double amount,  DateTime date,  String? description, @JsonKey(name: 'category_id')  String? categoryId, @JsonKey(name: 'service_id')  String? serviceId, @JsonKey(name: 'transfer_group_id')  String? transferGroupId, @JsonKey(name: 'installment_group_id')  String? installmentGroupId, @JsonKey(name: 'installments_total')  int? installmentsTotal, @JsonKey(name: 'installment_number')  int? installmentNumber)?  $default,) {final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
return $default(_that.id,_that.userId,_that.householdId,_that.accountId,_that.type,_that.amount,_that.date,_that.description,_that.categoryId,_that.serviceId,_that.transferGroupId,_that.installmentGroupId,_that.installmentsTotal,_that.installmentNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionModel extends TransactionModel {
  const _TransactionModel({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'household_id') this.householdId, @JsonKey(name: 'account_id') this.accountId, required this.type, required this.amount, required this.date, this.description, @JsonKey(name: 'category_id') this.categoryId, @JsonKey(name: 'service_id') this.serviceId, @JsonKey(name: 'transfer_group_id') this.transferGroupId, @JsonKey(name: 'installment_group_id') this.installmentGroupId, @JsonKey(name: 'installments_total') this.installmentsTotal, @JsonKey(name: 'installment_number') this.installmentNumber}): super._();
  factory _TransactionModel.fromJson(Map<String, dynamic> json) => _$TransactionModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'household_id') final  String? householdId;
@override@JsonKey(name: 'account_id') final  String? accountId;
@override final  TransactionType type;
@override final  double amount;
@override final  DateTime date;
@override final  String? description;
@override@JsonKey(name: 'category_id') final  String? categoryId;
@override@JsonKey(name: 'service_id') final  String? serviceId;
@override@JsonKey(name: 'transfer_group_id') final  String? transferGroupId;
// Compras en cuotas: N filas (una por mes) con el mismo grupo.
@override@JsonKey(name: 'installment_group_id') final  String? installmentGroupId;
@override@JsonKey(name: 'installments_total') final  int? installmentsTotal;
@override@JsonKey(name: 'installment_number') final  int? installmentNumber;

/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionModelCopyWith<_TransactionModel> get copyWith => __$TransactionModelCopyWithImpl<_TransactionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.householdId, householdId) || other.householdId == householdId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.description, description) || other.description == description)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.transferGroupId, transferGroupId) || other.transferGroupId == transferGroupId)&&(identical(other.installmentGroupId, installmentGroupId) || other.installmentGroupId == installmentGroupId)&&(identical(other.installmentsTotal, installmentsTotal) || other.installmentsTotal == installmentsTotal)&&(identical(other.installmentNumber, installmentNumber) || other.installmentNumber == installmentNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,householdId,accountId,type,amount,date,description,categoryId,serviceId,transferGroupId,installmentGroupId,installmentsTotal,installmentNumber);

@override
String toString() {
  return 'TransactionModel(id: $id, userId: $userId, householdId: $householdId, accountId: $accountId, type: $type, amount: $amount, date: $date, description: $description, categoryId: $categoryId, serviceId: $serviceId, transferGroupId: $transferGroupId, installmentGroupId: $installmentGroupId, installmentsTotal: $installmentsTotal, installmentNumber: $installmentNumber)';
}


}

/// @nodoc
abstract mixin class _$TransactionModelCopyWith<$Res> implements $TransactionModelCopyWith<$Res> {
  factory _$TransactionModelCopyWith(_TransactionModel value, $Res Function(_TransactionModel) _then) = __$TransactionModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'household_id') String? householdId,@JsonKey(name: 'account_id') String? accountId, TransactionType type, double amount, DateTime date, String? description,@JsonKey(name: 'category_id') String? categoryId,@JsonKey(name: 'service_id') String? serviceId,@JsonKey(name: 'transfer_group_id') String? transferGroupId,@JsonKey(name: 'installment_group_id') String? installmentGroupId,@JsonKey(name: 'installments_total') int? installmentsTotal,@JsonKey(name: 'installment_number') int? installmentNumber
});




}
/// @nodoc
class __$TransactionModelCopyWithImpl<$Res>
    implements _$TransactionModelCopyWith<$Res> {
  __$TransactionModelCopyWithImpl(this._self, this._then);

  final _TransactionModel _self;
  final $Res Function(_TransactionModel) _then;

/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? householdId = freezed,Object? accountId = freezed,Object? type = null,Object? amount = null,Object? date = null,Object? description = freezed,Object? categoryId = freezed,Object? serviceId = freezed,Object? transferGroupId = freezed,Object? installmentGroupId = freezed,Object? installmentsTotal = freezed,Object? installmentNumber = freezed,}) {
  return _then(_TransactionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,householdId: freezed == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,serviceId: freezed == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String?,transferGroupId: freezed == transferGroupId ? _self.transferGroupId : transferGroupId // ignore: cast_nullable_to_non_nullable
as String?,installmentGroupId: freezed == installmentGroupId ? _self.installmentGroupId : installmentGroupId // ignore: cast_nullable_to_non_nullable
as String?,installmentsTotal: freezed == installmentsTotal ? _self.installmentsTotal : installmentsTotal // ignore: cast_nullable_to_non_nullable
as int?,installmentNumber: freezed == installmentNumber ? _self.installmentNumber : installmentNumber // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
