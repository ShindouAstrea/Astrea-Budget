// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_payment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ServicePayment {

 String get id;@JsonKey(name: 'service_id') String get serviceId;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'due_date') DateTime get dueDate; double get amount;/// El monto de este período se ajustó a mano: no se pisa al editar el
/// monto estimado del servicio ni al regenerar el mes.
@JsonKey(name: 'amount_overridden') bool get amountOverridden; PaymentStatus get status;@JsonKey(name: 'paid_date') DateTime? get paidDate;@JsonKey(name: 'transaction_id') String? get transactionId;
/// Create a copy of ServicePayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServicePaymentCopyWith<ServicePayment> get copyWith => _$ServicePaymentCopyWithImpl<ServicePayment>(this as ServicePayment, _$identity);

  /// Serializes this ServicePayment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServicePayment&&(identical(other.id, id) || other.id == id)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.amountOverridden, amountOverridden) || other.amountOverridden == amountOverridden)&&(identical(other.status, status) || other.status == status)&&(identical(other.paidDate, paidDate) || other.paidDate == paidDate)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,serviceId,userId,dueDate,amount,amountOverridden,status,paidDate,transactionId);

@override
String toString() {
  return 'ServicePayment(id: $id, serviceId: $serviceId, userId: $userId, dueDate: $dueDate, amount: $amount, amountOverridden: $amountOverridden, status: $status, paidDate: $paidDate, transactionId: $transactionId)';
}


}

/// @nodoc
abstract mixin class $ServicePaymentCopyWith<$Res>  {
  factory $ServicePaymentCopyWith(ServicePayment value, $Res Function(ServicePayment) _then) = _$ServicePaymentCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'service_id') String serviceId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'due_date') DateTime dueDate, double amount,@JsonKey(name: 'amount_overridden') bool amountOverridden, PaymentStatus status,@JsonKey(name: 'paid_date') DateTime? paidDate,@JsonKey(name: 'transaction_id') String? transactionId
});




}
/// @nodoc
class _$ServicePaymentCopyWithImpl<$Res>
    implements $ServicePaymentCopyWith<$Res> {
  _$ServicePaymentCopyWithImpl(this._self, this._then);

  final ServicePayment _self;
  final $Res Function(ServicePayment) _then;

/// Create a copy of ServicePayment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? serviceId = null,Object? userId = null,Object? dueDate = null,Object? amount = null,Object? amountOverridden = null,Object? status = null,Object? paidDate = freezed,Object? transactionId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,serviceId: null == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,amountOverridden: null == amountOverridden ? _self.amountOverridden : amountOverridden // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentStatus,paidDate: freezed == paidDate ? _self.paidDate : paidDate // ignore: cast_nullable_to_non_nullable
as DateTime?,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ServicePayment].
extension ServicePaymentPatterns on ServicePayment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServicePayment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServicePayment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServicePayment value)  $default,){
final _that = this;
switch (_that) {
case _ServicePayment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServicePayment value)?  $default,){
final _that = this;
switch (_that) {
case _ServicePayment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'service_id')  String serviceId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'due_date')  DateTime dueDate,  double amount, @JsonKey(name: 'amount_overridden')  bool amountOverridden,  PaymentStatus status, @JsonKey(name: 'paid_date')  DateTime? paidDate, @JsonKey(name: 'transaction_id')  String? transactionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServicePayment() when $default != null:
return $default(_that.id,_that.serviceId,_that.userId,_that.dueDate,_that.amount,_that.amountOverridden,_that.status,_that.paidDate,_that.transactionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'service_id')  String serviceId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'due_date')  DateTime dueDate,  double amount, @JsonKey(name: 'amount_overridden')  bool amountOverridden,  PaymentStatus status, @JsonKey(name: 'paid_date')  DateTime? paidDate, @JsonKey(name: 'transaction_id')  String? transactionId)  $default,) {final _that = this;
switch (_that) {
case _ServicePayment():
return $default(_that.id,_that.serviceId,_that.userId,_that.dueDate,_that.amount,_that.amountOverridden,_that.status,_that.paidDate,_that.transactionId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'service_id')  String serviceId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'due_date')  DateTime dueDate,  double amount, @JsonKey(name: 'amount_overridden')  bool amountOverridden,  PaymentStatus status, @JsonKey(name: 'paid_date')  DateTime? paidDate, @JsonKey(name: 'transaction_id')  String? transactionId)?  $default,) {final _that = this;
switch (_that) {
case _ServicePayment() when $default != null:
return $default(_that.id,_that.serviceId,_that.userId,_that.dueDate,_that.amount,_that.amountOverridden,_that.status,_that.paidDate,_that.transactionId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServicePayment extends ServicePayment {
  const _ServicePayment({required this.id, @JsonKey(name: 'service_id') required this.serviceId, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'due_date') required this.dueDate, required this.amount, @JsonKey(name: 'amount_overridden') this.amountOverridden = false, this.status = PaymentStatus.pendiente, @JsonKey(name: 'paid_date') this.paidDate, @JsonKey(name: 'transaction_id') this.transactionId}): super._();
  factory _ServicePayment.fromJson(Map<String, dynamic> json) => _$ServicePaymentFromJson(json);

@override final  String id;
@override@JsonKey(name: 'service_id') final  String serviceId;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'due_date') final  DateTime dueDate;
@override final  double amount;
/// El monto de este período se ajustó a mano: no se pisa al editar el
/// monto estimado del servicio ni al regenerar el mes.
@override@JsonKey(name: 'amount_overridden') final  bool amountOverridden;
@override@JsonKey() final  PaymentStatus status;
@override@JsonKey(name: 'paid_date') final  DateTime? paidDate;
@override@JsonKey(name: 'transaction_id') final  String? transactionId;

/// Create a copy of ServicePayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServicePaymentCopyWith<_ServicePayment> get copyWith => __$ServicePaymentCopyWithImpl<_ServicePayment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServicePaymentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServicePayment&&(identical(other.id, id) || other.id == id)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.amountOverridden, amountOverridden) || other.amountOverridden == amountOverridden)&&(identical(other.status, status) || other.status == status)&&(identical(other.paidDate, paidDate) || other.paidDate == paidDate)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,serviceId,userId,dueDate,amount,amountOverridden,status,paidDate,transactionId);

@override
String toString() {
  return 'ServicePayment(id: $id, serviceId: $serviceId, userId: $userId, dueDate: $dueDate, amount: $amount, amountOverridden: $amountOverridden, status: $status, paidDate: $paidDate, transactionId: $transactionId)';
}


}

/// @nodoc
abstract mixin class _$ServicePaymentCopyWith<$Res> implements $ServicePaymentCopyWith<$Res> {
  factory _$ServicePaymentCopyWith(_ServicePayment value, $Res Function(_ServicePayment) _then) = __$ServicePaymentCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'service_id') String serviceId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'due_date') DateTime dueDate, double amount,@JsonKey(name: 'amount_overridden') bool amountOverridden, PaymentStatus status,@JsonKey(name: 'paid_date') DateTime? paidDate,@JsonKey(name: 'transaction_id') String? transactionId
});




}
/// @nodoc
class __$ServicePaymentCopyWithImpl<$Res>
    implements _$ServicePaymentCopyWith<$Res> {
  __$ServicePaymentCopyWithImpl(this._self, this._then);

  final _ServicePayment _self;
  final $Res Function(_ServicePayment) _then;

/// Create a copy of ServicePayment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? serviceId = null,Object? userId = null,Object? dueDate = null,Object? amount = null,Object? amountOverridden = null,Object? status = null,Object? paidDate = freezed,Object? transactionId = freezed,}) {
  return _then(_ServicePayment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,serviceId: null == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,amountOverridden: null == amountOverridden ? _self.amountOverridden : amountOverridden // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PaymentStatus,paidDate: freezed == paidDate ? _self.paidDate : paidDate // ignore: cast_nullable_to_non_nullable
as DateTime?,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
