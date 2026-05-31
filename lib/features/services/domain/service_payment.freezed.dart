// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_payment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ServicePayment _$ServicePaymentFromJson(Map<String, dynamic> json) {
  return _ServicePayment.fromJson(json);
}

/// @nodoc
mixin _$ServicePayment {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'service_id')
  String get serviceId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'due_date')
  DateTime get dueDate => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  PaymentStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'paid_date')
  DateTime? get paidDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_id')
  String? get transactionId => throw _privateConstructorUsedError;

  /// Serializes this ServicePayment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServicePayment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServicePaymentCopyWith<ServicePayment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServicePaymentCopyWith<$Res> {
  factory $ServicePaymentCopyWith(
    ServicePayment value,
    $Res Function(ServicePayment) then,
  ) = _$ServicePaymentCopyWithImpl<$Res, ServicePayment>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'service_id') String serviceId,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'due_date') DateTime dueDate,
    double amount,
    PaymentStatus status,
    @JsonKey(name: 'paid_date') DateTime? paidDate,
    @JsonKey(name: 'transaction_id') String? transactionId,
  });
}

/// @nodoc
class _$ServicePaymentCopyWithImpl<$Res, $Val extends ServicePayment>
    implements $ServicePaymentCopyWith<$Res> {
  _$ServicePaymentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServicePayment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serviceId = null,
    Object? userId = null,
    Object? dueDate = null,
    Object? amount = null,
    Object? status = null,
    Object? paidDate = freezed,
    Object? transactionId = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            serviceId: null == serviceId
                ? _value.serviceId
                : serviceId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            dueDate: null == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as PaymentStatus,
            paidDate: freezed == paidDate
                ? _value.paidDate
                : paidDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            transactionId: freezed == transactionId
                ? _value.transactionId
                : transactionId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ServicePaymentImplCopyWith<$Res>
    implements $ServicePaymentCopyWith<$Res> {
  factory _$$ServicePaymentImplCopyWith(
    _$ServicePaymentImpl value,
    $Res Function(_$ServicePaymentImpl) then,
  ) = __$$ServicePaymentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'service_id') String serviceId,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'due_date') DateTime dueDate,
    double amount,
    PaymentStatus status,
    @JsonKey(name: 'paid_date') DateTime? paidDate,
    @JsonKey(name: 'transaction_id') String? transactionId,
  });
}

/// @nodoc
class __$$ServicePaymentImplCopyWithImpl<$Res>
    extends _$ServicePaymentCopyWithImpl<$Res, _$ServicePaymentImpl>
    implements _$$ServicePaymentImplCopyWith<$Res> {
  __$$ServicePaymentImplCopyWithImpl(
    _$ServicePaymentImpl _value,
    $Res Function(_$ServicePaymentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ServicePayment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serviceId = null,
    Object? userId = null,
    Object? dueDate = null,
    Object? amount = null,
    Object? status = null,
    Object? paidDate = freezed,
    Object? transactionId = freezed,
  }) {
    return _then(
      _$ServicePaymentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        serviceId: null == serviceId
            ? _value.serviceId
            : serviceId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        dueDate: null == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as PaymentStatus,
        paidDate: freezed == paidDate
            ? _value.paidDate
            : paidDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        transactionId: freezed == transactionId
            ? _value.transactionId
            : transactionId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ServicePaymentImpl extends _ServicePayment {
  const _$ServicePaymentImpl({
    required this.id,
    @JsonKey(name: 'service_id') required this.serviceId,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'due_date') required this.dueDate,
    required this.amount,
    this.status = PaymentStatus.pendiente,
    @JsonKey(name: 'paid_date') this.paidDate,
    @JsonKey(name: 'transaction_id') this.transactionId,
  }) : super._();

  factory _$ServicePaymentImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServicePaymentImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'service_id')
  final String serviceId;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'due_date')
  final DateTime dueDate;
  @override
  final double amount;
  @override
  @JsonKey()
  final PaymentStatus status;
  @override
  @JsonKey(name: 'paid_date')
  final DateTime? paidDate;
  @override
  @JsonKey(name: 'transaction_id')
  final String? transactionId;

  @override
  String toString() {
    return 'ServicePayment(id: $id, serviceId: $serviceId, userId: $userId, dueDate: $dueDate, amount: $amount, status: $status, paidDate: $paidDate, transactionId: $transactionId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServicePaymentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.serviceId, serviceId) ||
                other.serviceId == serviceId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paidDate, paidDate) ||
                other.paidDate == paidDate) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    serviceId,
    userId,
    dueDate,
    amount,
    status,
    paidDate,
    transactionId,
  );

  /// Create a copy of ServicePayment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServicePaymentImplCopyWith<_$ServicePaymentImpl> get copyWith =>
      __$$ServicePaymentImplCopyWithImpl<_$ServicePaymentImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ServicePaymentImplToJson(this);
  }
}

abstract class _ServicePayment extends ServicePayment {
  const factory _ServicePayment({
    required final String id,
    @JsonKey(name: 'service_id') required final String serviceId,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'due_date') required final DateTime dueDate,
    required final double amount,
    final PaymentStatus status,
    @JsonKey(name: 'paid_date') final DateTime? paidDate,
    @JsonKey(name: 'transaction_id') final String? transactionId,
  }) = _$ServicePaymentImpl;
  const _ServicePayment._() : super._();

  factory _ServicePayment.fromJson(Map<String, dynamic> json) =
      _$ServicePaymentImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'service_id')
  String get serviceId;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'due_date')
  DateTime get dueDate;
  @override
  double get amount;
  @override
  PaymentStatus get status;
  @override
  @JsonKey(name: 'paid_date')
  DateTime? get paidDate;
  @override
  @JsonKey(name: 'transaction_id')
  String? get transactionId;

  /// Create a copy of ServicePayment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServicePaymentImplCopyWith<_$ServicePaymentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
