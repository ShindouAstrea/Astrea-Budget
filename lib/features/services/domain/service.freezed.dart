// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Service {

 String get id;@JsonKey(name: 'user_id') String get userId; String get name; ServiceType get type; ServiceCategory get category;@JsonKey(name: 'estimated_amount') double get estimatedAmount;@JsonKey(name: 'billing_day') int? get billingDay; ServiceFrequency get frequency;/// Mes (día 1) del primer cobro: ancla del ciclo para frecuencias no
/// mensuales. Null en servicios creados antes de existir la columna.
@JsonKey(name: 'first_charge_month') DateTime? get firstChargeMonth;/// Mes del último cobro: una suscripción cancelada que corre hasta cierta
/// fecha deja de generar pagos sola. Null = sin término.
@JsonKey(name: 'last_charge_month') DateTime? get lastChargeMonth;/// Categoría de GASTO a la que se imputa el pago (distinta de [category],
/// que sólo clasifica el servicio en esencial/suscripción). Sin ella, el
/// gasto no cuenta en los presupuestos por categoría.
@JsonKey(name: 'category_id') String? get expenseCategoryId; bool get active;
/// Create a copy of Service
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceCopyWith<Service> get copyWith => _$ServiceCopyWithImpl<Service>(this as Service, _$identity);

  /// Serializes this Service to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Service&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.category, category) || other.category == category)&&(identical(other.estimatedAmount, estimatedAmount) || other.estimatedAmount == estimatedAmount)&&(identical(other.billingDay, billingDay) || other.billingDay == billingDay)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.firstChargeMonth, firstChargeMonth) || other.firstChargeMonth == firstChargeMonth)&&(identical(other.lastChargeMonth, lastChargeMonth) || other.lastChargeMonth == lastChargeMonth)&&(identical(other.expenseCategoryId, expenseCategoryId) || other.expenseCategoryId == expenseCategoryId)&&(identical(other.active, active) || other.active == active));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,type,category,estimatedAmount,billingDay,frequency,firstChargeMonth,lastChargeMonth,expenseCategoryId,active);

@override
String toString() {
  return 'Service(id: $id, userId: $userId, name: $name, type: $type, category: $category, estimatedAmount: $estimatedAmount, billingDay: $billingDay, frequency: $frequency, firstChargeMonth: $firstChargeMonth, lastChargeMonth: $lastChargeMonth, expenseCategoryId: $expenseCategoryId, active: $active)';
}


}

/// @nodoc
abstract mixin class $ServiceCopyWith<$Res>  {
  factory $ServiceCopyWith(Service value, $Res Function(Service) _then) = _$ServiceCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String name, ServiceType type, ServiceCategory category,@JsonKey(name: 'estimated_amount') double estimatedAmount,@JsonKey(name: 'billing_day') int? billingDay, ServiceFrequency frequency,@JsonKey(name: 'first_charge_month') DateTime? firstChargeMonth,@JsonKey(name: 'last_charge_month') DateTime? lastChargeMonth,@JsonKey(name: 'category_id') String? expenseCategoryId, bool active
});




}
/// @nodoc
class _$ServiceCopyWithImpl<$Res>
    implements $ServiceCopyWith<$Res> {
  _$ServiceCopyWithImpl(this._self, this._then);

  final Service _self;
  final $Res Function(Service) _then;

/// Create a copy of Service
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? type = null,Object? category = null,Object? estimatedAmount = null,Object? billingDay = freezed,Object? frequency = null,Object? firstChargeMonth = freezed,Object? lastChargeMonth = freezed,Object? expenseCategoryId = freezed,Object? active = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ServiceType,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ServiceCategory,estimatedAmount: null == estimatedAmount ? _self.estimatedAmount : estimatedAmount // ignore: cast_nullable_to_non_nullable
as double,billingDay: freezed == billingDay ? _self.billingDay : billingDay // ignore: cast_nullable_to_non_nullable
as int?,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as ServiceFrequency,firstChargeMonth: freezed == firstChargeMonth ? _self.firstChargeMonth : firstChargeMonth // ignore: cast_nullable_to_non_nullable
as DateTime?,lastChargeMonth: freezed == lastChargeMonth ? _self.lastChargeMonth : lastChargeMonth // ignore: cast_nullable_to_non_nullable
as DateTime?,expenseCategoryId: freezed == expenseCategoryId ? _self.expenseCategoryId : expenseCategoryId // ignore: cast_nullable_to_non_nullable
as String?,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Service].
extension ServicePatterns on Service {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Service value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Service() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Service value)  $default,){
final _that = this;
switch (_that) {
case _Service():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Service value)?  $default,){
final _that = this;
switch (_that) {
case _Service() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String name,  ServiceType type,  ServiceCategory category, @JsonKey(name: 'estimated_amount')  double estimatedAmount, @JsonKey(name: 'billing_day')  int? billingDay,  ServiceFrequency frequency, @JsonKey(name: 'first_charge_month')  DateTime? firstChargeMonth, @JsonKey(name: 'last_charge_month')  DateTime? lastChargeMonth, @JsonKey(name: 'category_id')  String? expenseCategoryId,  bool active)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Service() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.type,_that.category,_that.estimatedAmount,_that.billingDay,_that.frequency,_that.firstChargeMonth,_that.lastChargeMonth,_that.expenseCategoryId,_that.active);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String name,  ServiceType type,  ServiceCategory category, @JsonKey(name: 'estimated_amount')  double estimatedAmount, @JsonKey(name: 'billing_day')  int? billingDay,  ServiceFrequency frequency, @JsonKey(name: 'first_charge_month')  DateTime? firstChargeMonth, @JsonKey(name: 'last_charge_month')  DateTime? lastChargeMonth, @JsonKey(name: 'category_id')  String? expenseCategoryId,  bool active)  $default,) {final _that = this;
switch (_that) {
case _Service():
return $default(_that.id,_that.userId,_that.name,_that.type,_that.category,_that.estimatedAmount,_that.billingDay,_that.frequency,_that.firstChargeMonth,_that.lastChargeMonth,_that.expenseCategoryId,_that.active);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId,  String name,  ServiceType type,  ServiceCategory category, @JsonKey(name: 'estimated_amount')  double estimatedAmount, @JsonKey(name: 'billing_day')  int? billingDay,  ServiceFrequency frequency, @JsonKey(name: 'first_charge_month')  DateTime? firstChargeMonth, @JsonKey(name: 'last_charge_month')  DateTime? lastChargeMonth, @JsonKey(name: 'category_id')  String? expenseCategoryId,  bool active)?  $default,) {final _that = this;
switch (_that) {
case _Service() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.type,_that.category,_that.estimatedAmount,_that.billingDay,_that.frequency,_that.firstChargeMonth,_that.lastChargeMonth,_that.expenseCategoryId,_that.active);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Service extends Service {
  const _Service({required this.id, @JsonKey(name: 'user_id') required this.userId, required this.name, this.type = ServiceType.fijo, this.category = ServiceCategory.esencial, @JsonKey(name: 'estimated_amount') this.estimatedAmount = 0, @JsonKey(name: 'billing_day') this.billingDay, this.frequency = ServiceFrequency.mensual, @JsonKey(name: 'first_charge_month') this.firstChargeMonth, @JsonKey(name: 'last_charge_month') this.lastChargeMonth, @JsonKey(name: 'category_id') this.expenseCategoryId, this.active = true}): super._();
  factory _Service.fromJson(Map<String, dynamic> json) => _$ServiceFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String name;
@override@JsonKey() final  ServiceType type;
@override@JsonKey() final  ServiceCategory category;
@override@JsonKey(name: 'estimated_amount') final  double estimatedAmount;
@override@JsonKey(name: 'billing_day') final  int? billingDay;
@override@JsonKey() final  ServiceFrequency frequency;
/// Mes (día 1) del primer cobro: ancla del ciclo para frecuencias no
/// mensuales. Null en servicios creados antes de existir la columna.
@override@JsonKey(name: 'first_charge_month') final  DateTime? firstChargeMonth;
/// Mes del último cobro: una suscripción cancelada que corre hasta cierta
/// fecha deja de generar pagos sola. Null = sin término.
@override@JsonKey(name: 'last_charge_month') final  DateTime? lastChargeMonth;
/// Categoría de GASTO a la que se imputa el pago (distinta de [category],
/// que sólo clasifica el servicio en esencial/suscripción). Sin ella, el
/// gasto no cuenta en los presupuestos por categoría.
@override@JsonKey(name: 'category_id') final  String? expenseCategoryId;
@override@JsonKey() final  bool active;

/// Create a copy of Service
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceCopyWith<_Service> get copyWith => __$ServiceCopyWithImpl<_Service>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Service&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.category, category) || other.category == category)&&(identical(other.estimatedAmount, estimatedAmount) || other.estimatedAmount == estimatedAmount)&&(identical(other.billingDay, billingDay) || other.billingDay == billingDay)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.firstChargeMonth, firstChargeMonth) || other.firstChargeMonth == firstChargeMonth)&&(identical(other.lastChargeMonth, lastChargeMonth) || other.lastChargeMonth == lastChargeMonth)&&(identical(other.expenseCategoryId, expenseCategoryId) || other.expenseCategoryId == expenseCategoryId)&&(identical(other.active, active) || other.active == active));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,type,category,estimatedAmount,billingDay,frequency,firstChargeMonth,lastChargeMonth,expenseCategoryId,active);

@override
String toString() {
  return 'Service(id: $id, userId: $userId, name: $name, type: $type, category: $category, estimatedAmount: $estimatedAmount, billingDay: $billingDay, frequency: $frequency, firstChargeMonth: $firstChargeMonth, lastChargeMonth: $lastChargeMonth, expenseCategoryId: $expenseCategoryId, active: $active)';
}


}

/// @nodoc
abstract mixin class _$ServiceCopyWith<$Res> implements $ServiceCopyWith<$Res> {
  factory _$ServiceCopyWith(_Service value, $Res Function(_Service) _then) = __$ServiceCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String name, ServiceType type, ServiceCategory category,@JsonKey(name: 'estimated_amount') double estimatedAmount,@JsonKey(name: 'billing_day') int? billingDay, ServiceFrequency frequency,@JsonKey(name: 'first_charge_month') DateTime? firstChargeMonth,@JsonKey(name: 'last_charge_month') DateTime? lastChargeMonth,@JsonKey(name: 'category_id') String? expenseCategoryId, bool active
});




}
/// @nodoc
class __$ServiceCopyWithImpl<$Res>
    implements _$ServiceCopyWith<$Res> {
  __$ServiceCopyWithImpl(this._self, this._then);

  final _Service _self;
  final $Res Function(_Service) _then;

/// Create a copy of Service
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? type = null,Object? category = null,Object? estimatedAmount = null,Object? billingDay = freezed,Object? frequency = null,Object? firstChargeMonth = freezed,Object? lastChargeMonth = freezed,Object? expenseCategoryId = freezed,Object? active = null,}) {
  return _then(_Service(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ServiceType,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ServiceCategory,estimatedAmount: null == estimatedAmount ? _self.estimatedAmount : estimatedAmount // ignore: cast_nullable_to_non_nullable
as double,billingDay: freezed == billingDay ? _self.billingDay : billingDay // ignore: cast_nullable_to_non_nullable
as int?,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as ServiceFrequency,firstChargeMonth: freezed == firstChargeMonth ? _self.firstChargeMonth : firstChargeMonth // ignore: cast_nullable_to_non_nullable
as DateTime?,lastChargeMonth: freezed == lastChargeMonth ? _self.lastChargeMonth : lastChargeMonth // ignore: cast_nullable_to_non_nullable
as DateTime?,expenseCategoryId: freezed == expenseCategoryId ? _self.expenseCategoryId : expenseCategoryId // ignore: cast_nullable_to_non_nullable
as String?,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
