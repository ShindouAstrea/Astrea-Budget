// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Account _$AccountFromJson(Map<String, dynamic> json) {
  return _Account.fromJson(json);
}

/// @nodoc
mixin _$Account {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'household_id')
  String get householdId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  AccountType get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'initial_balance')
  double get initialBalance => throw _privateConstructorUsedError; // Campos de crédito (sólo cuando type == credito).
  @JsonKey(name: 'credit_limit')
  double? get creditLimit => throw _privateConstructorUsedError;
  @JsonKey(name: 'statement_day')
  int? get statementDay => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_due_day')
  int? get paymentDueDay => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  bool get archived => throw _privateConstructorUsedError;

  /// Serializes this Account to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Account
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AccountCopyWith<Account> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccountCopyWith<$Res> {
  factory $AccountCopyWith(Account value, $Res Function(Account) then) =
      _$AccountCopyWithImpl<$Res, Account>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'household_id') String householdId,
    @JsonKey(name: 'user_id') String userId,
    String name,
    AccountType type,
    @JsonKey(name: 'initial_balance') double initialBalance,
    @JsonKey(name: 'credit_limit') double? creditLimit,
    @JsonKey(name: 'statement_day') int? statementDay,
    @JsonKey(name: 'payment_due_day') int? paymentDueDay,
    String color,
    String icon,
    bool archived,
  });
}

/// @nodoc
class _$AccountCopyWithImpl<$Res, $Val extends Account>
    implements $AccountCopyWith<$Res> {
  _$AccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Account
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? userId = null,
    Object? name = null,
    Object? type = null,
    Object? initialBalance = null,
    Object? creditLimit = freezed,
    Object? statementDay = freezed,
    Object? paymentDueDay = freezed,
    Object? color = null,
    Object? icon = null,
    Object? archived = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            householdId: null == householdId
                ? _value.householdId
                : householdId // ignore: cast_nullable_to_non_nullable
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
                      as AccountType,
            initialBalance: null == initialBalance
                ? _value.initialBalance
                : initialBalance // ignore: cast_nullable_to_non_nullable
                      as double,
            creditLimit: freezed == creditLimit
                ? _value.creditLimit
                : creditLimit // ignore: cast_nullable_to_non_nullable
                      as double?,
            statementDay: freezed == statementDay
                ? _value.statementDay
                : statementDay // ignore: cast_nullable_to_non_nullable
                      as int?,
            paymentDueDay: freezed == paymentDueDay
                ? _value.paymentDueDay
                : paymentDueDay // ignore: cast_nullable_to_non_nullable
                      as int?,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String,
            archived: null == archived
                ? _value.archived
                : archived // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AccountImplCopyWith<$Res> implements $AccountCopyWith<$Res> {
  factory _$$AccountImplCopyWith(
    _$AccountImpl value,
    $Res Function(_$AccountImpl) then,
  ) = __$$AccountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'household_id') String householdId,
    @JsonKey(name: 'user_id') String userId,
    String name,
    AccountType type,
    @JsonKey(name: 'initial_balance') double initialBalance,
    @JsonKey(name: 'credit_limit') double? creditLimit,
    @JsonKey(name: 'statement_day') int? statementDay,
    @JsonKey(name: 'payment_due_day') int? paymentDueDay,
    String color,
    String icon,
    bool archived,
  });
}

/// @nodoc
class __$$AccountImplCopyWithImpl<$Res>
    extends _$AccountCopyWithImpl<$Res, _$AccountImpl>
    implements _$$AccountImplCopyWith<$Res> {
  __$$AccountImplCopyWithImpl(
    _$AccountImpl _value,
    $Res Function(_$AccountImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Account
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? userId = null,
    Object? name = null,
    Object? type = null,
    Object? initialBalance = null,
    Object? creditLimit = freezed,
    Object? statementDay = freezed,
    Object? paymentDueDay = freezed,
    Object? color = null,
    Object? icon = null,
    Object? archived = null,
  }) {
    return _then(
      _$AccountImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        householdId: null == householdId
            ? _value.householdId
            : householdId // ignore: cast_nullable_to_non_nullable
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
                  as AccountType,
        initialBalance: null == initialBalance
            ? _value.initialBalance
            : initialBalance // ignore: cast_nullable_to_non_nullable
                  as double,
        creditLimit: freezed == creditLimit
            ? _value.creditLimit
            : creditLimit // ignore: cast_nullable_to_non_nullable
                  as double?,
        statementDay: freezed == statementDay
            ? _value.statementDay
            : statementDay // ignore: cast_nullable_to_non_nullable
                  as int?,
        paymentDueDay: freezed == paymentDueDay
            ? _value.paymentDueDay
            : paymentDueDay // ignore: cast_nullable_to_non_nullable
                  as int?,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String,
        archived: null == archived
            ? _value.archived
            : archived // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AccountImpl extends _Account {
  const _$AccountImpl({
    required this.id,
    @JsonKey(name: 'household_id') required this.householdId,
    @JsonKey(name: 'user_id') required this.userId,
    required this.name,
    this.type = AccountType.debito,
    @JsonKey(name: 'initial_balance') this.initialBalance = 0,
    @JsonKey(name: 'credit_limit') this.creditLimit,
    @JsonKey(name: 'statement_day') this.statementDay,
    @JsonKey(name: 'payment_due_day') this.paymentDueDay,
    this.color = '#2563EB',
    this.icon = 'account_balance_wallet',
    this.archived = false,
  }) : super._();

  factory _$AccountImpl.fromJson(Map<String, dynamic> json) =>
      _$$AccountImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'household_id')
  final String householdId;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String name;
  @override
  @JsonKey()
  final AccountType type;
  @override
  @JsonKey(name: 'initial_balance')
  final double initialBalance;
  // Campos de crédito (sólo cuando type == credito).
  @override
  @JsonKey(name: 'credit_limit')
  final double? creditLimit;
  @override
  @JsonKey(name: 'statement_day')
  final int? statementDay;
  @override
  @JsonKey(name: 'payment_due_day')
  final int? paymentDueDay;
  @override
  @JsonKey()
  final String color;
  @override
  @JsonKey()
  final String icon;
  @override
  @JsonKey()
  final bool archived;

  @override
  String toString() {
    return 'Account(id: $id, householdId: $householdId, userId: $userId, name: $name, type: $type, initialBalance: $initialBalance, creditLimit: $creditLimit, statementDay: $statementDay, paymentDueDay: $paymentDueDay, color: $color, icon: $icon, archived: $archived)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.householdId, householdId) ||
                other.householdId == householdId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.initialBalance, initialBalance) ||
                other.initialBalance == initialBalance) &&
            (identical(other.creditLimit, creditLimit) ||
                other.creditLimit == creditLimit) &&
            (identical(other.statementDay, statementDay) ||
                other.statementDay == statementDay) &&
            (identical(other.paymentDueDay, paymentDueDay) ||
                other.paymentDueDay == paymentDueDay) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.archived, archived) ||
                other.archived == archived));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    householdId,
    userId,
    name,
    type,
    initialBalance,
    creditLimit,
    statementDay,
    paymentDueDay,
    color,
    icon,
    archived,
  );

  /// Create a copy of Account
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AccountImplCopyWith<_$AccountImpl> get copyWith =>
      __$$AccountImplCopyWithImpl<_$AccountImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AccountImplToJson(this);
  }
}

abstract class _Account extends Account {
  const factory _Account({
    required final String id,
    @JsonKey(name: 'household_id') required final String householdId,
    @JsonKey(name: 'user_id') required final String userId,
    required final String name,
    final AccountType type,
    @JsonKey(name: 'initial_balance') final double initialBalance,
    @JsonKey(name: 'credit_limit') final double? creditLimit,
    @JsonKey(name: 'statement_day') final int? statementDay,
    @JsonKey(name: 'payment_due_day') final int? paymentDueDay,
    final String color,
    final String icon,
    final bool archived,
  }) = _$AccountImpl;
  const _Account._() : super._();

  factory _Account.fromJson(Map<String, dynamic> json) = _$AccountImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'household_id')
  String get householdId;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get name;
  @override
  AccountType get type;
  @override
  @JsonKey(name: 'initial_balance')
  double get initialBalance; // Campos de crédito (sólo cuando type == credito).
  @override
  @JsonKey(name: 'credit_limit')
  double? get creditLimit;
  @override
  @JsonKey(name: 'statement_day')
  int? get statementDay;
  @override
  @JsonKey(name: 'payment_due_day')
  int? get paymentDueDay;
  @override
  String get color;
  @override
  String get icon;
  @override
  bool get archived;

  /// Create a copy of Account
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AccountImplCopyWith<_$AccountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
