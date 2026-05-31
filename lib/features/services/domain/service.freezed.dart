// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Service _$ServiceFromJson(Map<String, dynamic> json) {
  return _Service.fromJson(json);
}

/// @nodoc
mixin _$Service {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  ServiceType get type => throw _privateConstructorUsedError;
  ServiceCategory get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'estimated_amount')
  double get estimatedAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'billing_day')
  int? get billingDay => throw _privateConstructorUsedError;
  ServiceFrequency get frequency => throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;

  /// Serializes this Service to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Service
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceCopyWith<Service> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceCopyWith<$Res> {
  factory $ServiceCopyWith(Service value, $Res Function(Service) then) =
      _$ServiceCopyWithImpl<$Res, Service>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    String name,
    ServiceType type,
    ServiceCategory category,
    @JsonKey(name: 'estimated_amount') double estimatedAmount,
    @JsonKey(name: 'billing_day') int? billingDay,
    ServiceFrequency frequency,
    bool active,
  });
}

/// @nodoc
class _$ServiceCopyWithImpl<$Res, $Val extends Service>
    implements $ServiceCopyWith<$Res> {
  _$ServiceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Service
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? type = null,
    Object? category = null,
    Object? estimatedAmount = null,
    Object? billingDay = freezed,
    Object? frequency = null,
    Object? active = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as ServiceType,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as ServiceCategory,
            estimatedAmount: null == estimatedAmount
                ? _value.estimatedAmount
                : estimatedAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            billingDay: freezed == billingDay
                ? _value.billingDay
                : billingDay // ignore: cast_nullable_to_non_nullable
                      as int?,
            frequency: null == frequency
                ? _value.frequency
                : frequency // ignore: cast_nullable_to_non_nullable
                      as ServiceFrequency,
            active: null == active
                ? _value.active
                : active // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ServiceImplCopyWith<$Res> implements $ServiceCopyWith<$Res> {
  factory _$$ServiceImplCopyWith(
    _$ServiceImpl value,
    $Res Function(_$ServiceImpl) then,
  ) = __$$ServiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    String name,
    ServiceType type,
    ServiceCategory category,
    @JsonKey(name: 'estimated_amount') double estimatedAmount,
    @JsonKey(name: 'billing_day') int? billingDay,
    ServiceFrequency frequency,
    bool active,
  });
}

/// @nodoc
class __$$ServiceImplCopyWithImpl<$Res>
    extends _$ServiceCopyWithImpl<$Res, _$ServiceImpl>
    implements _$$ServiceImplCopyWith<$Res> {
  __$$ServiceImplCopyWithImpl(
    _$ServiceImpl _value,
    $Res Function(_$ServiceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Service
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? type = null,
    Object? category = null,
    Object? estimatedAmount = null,
    Object? billingDay = freezed,
    Object? frequency = null,
    Object? active = null,
  }) {
    return _then(
      _$ServiceImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as ServiceType,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as ServiceCategory,
        estimatedAmount: null == estimatedAmount
            ? _value.estimatedAmount
            : estimatedAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        billingDay: freezed == billingDay
            ? _value.billingDay
            : billingDay // ignore: cast_nullable_to_non_nullable
                  as int?,
        frequency: null == frequency
            ? _value.frequency
            : frequency // ignore: cast_nullable_to_non_nullable
                  as ServiceFrequency,
        active: null == active
            ? _value.active
            : active // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ServiceImpl extends _Service {
  const _$ServiceImpl({
    required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    required this.name,
    this.type = ServiceType.fijo,
    this.category = ServiceCategory.esencial,
    @JsonKey(name: 'estimated_amount') this.estimatedAmount = 0,
    @JsonKey(name: 'billing_day') this.billingDay,
    this.frequency = ServiceFrequency.mensual,
    this.active = true,
  }) : super._();

  factory _$ServiceImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServiceImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String name;
  @override
  @JsonKey()
  final ServiceType type;
  @override
  @JsonKey()
  final ServiceCategory category;
  @override
  @JsonKey(name: 'estimated_amount')
  final double estimatedAmount;
  @override
  @JsonKey(name: 'billing_day')
  final int? billingDay;
  @override
  @JsonKey()
  final ServiceFrequency frequency;
  @override
  @JsonKey()
  final bool active;

  @override
  String toString() {
    return 'Service(id: $id, userId: $userId, name: $name, type: $type, category: $category, estimatedAmount: $estimatedAmount, billingDay: $billingDay, frequency: $frequency, active: $active)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.estimatedAmount, estimatedAmount) ||
                other.estimatedAmount == estimatedAmount) &&
            (identical(other.billingDay, billingDay) ||
                other.billingDay == billingDay) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.active, active) || other.active == active));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    name,
    type,
    category,
    estimatedAmount,
    billingDay,
    frequency,
    active,
  );

  /// Create a copy of Service
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceImplCopyWith<_$ServiceImpl> get copyWith =>
      __$$ServiceImplCopyWithImpl<_$ServiceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceImplToJson(this);
  }
}

abstract class _Service extends Service {
  const factory _Service({
    required final String id,
    @JsonKey(name: 'user_id') required final String userId,
    required final String name,
    final ServiceType type,
    final ServiceCategory category,
    @JsonKey(name: 'estimated_amount') final double estimatedAmount,
    @JsonKey(name: 'billing_day') final int? billingDay,
    final ServiceFrequency frequency,
    final bool active,
  }) = _$ServiceImpl;
  const _Service._() : super._();

  factory _Service.fromJson(Map<String, dynamic> json) = _$ServiceImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get name;
  @override
  ServiceType get type;
  @override
  ServiceCategory get category;
  @override
  @JsonKey(name: 'estimated_amount')
  double get estimatedAmount;
  @override
  @JsonKey(name: 'billing_day')
  int? get billingDay;
  @override
  ServiceFrequency get frequency;
  @override
  bool get active;

  /// Create a copy of Service
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceImplCopyWith<_$ServiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
