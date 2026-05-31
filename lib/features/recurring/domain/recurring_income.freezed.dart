// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_income.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RecurringIncome _$RecurringIncomeFromJson(Map<String, dynamic> json) {
  return _RecurringIncome.fromJson(json);
}

/// @nodoc
mixin _$RecurringIncome {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'household_id')
  String get householdId => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_id')
  String? get categoryId => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_id')
  String? get accountId => throw _privateConstructorUsedError;
  @JsonKey(name: 'day_of_month')
  int get dayOfMonth => throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_generated')
  DateTime? get lastGenerated => throw _privateConstructorUsedError;

  /// Serializes this RecurringIncome to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecurringIncome
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecurringIncomeCopyWith<RecurringIncome> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecurringIncomeCopyWith<$Res> {
  factory $RecurringIncomeCopyWith(
    RecurringIncome value,
    $Res Function(RecurringIncome) then,
  ) = _$RecurringIncomeCopyWithImpl<$Res, RecurringIncome>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'household_id') String householdId,
    @JsonKey(name: 'user_id') String userId,
    String description,
    double amount,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'account_id') String? accountId,
    @JsonKey(name: 'day_of_month') int dayOfMonth,
    bool active,
    @JsonKey(name: 'last_generated') DateTime? lastGenerated,
  });
}

/// @nodoc
class _$RecurringIncomeCopyWithImpl<$Res, $Val extends RecurringIncome>
    implements $RecurringIncomeCopyWith<$Res> {
  _$RecurringIncomeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecurringIncome
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? userId = null,
    Object? description = null,
    Object? amount = null,
    Object? categoryId = freezed,
    Object? accountId = freezed,
    Object? dayOfMonth = null,
    Object? active = null,
    Object? lastGenerated = freezed,
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
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            categoryId: freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String?,
            accountId: freezed == accountId
                ? _value.accountId
                : accountId // ignore: cast_nullable_to_non_nullable
                      as String?,
            dayOfMonth: null == dayOfMonth
                ? _value.dayOfMonth
                : dayOfMonth // ignore: cast_nullable_to_non_nullable
                      as int,
            active: null == active
                ? _value.active
                : active // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastGenerated: freezed == lastGenerated
                ? _value.lastGenerated
                : lastGenerated // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecurringIncomeImplCopyWith<$Res>
    implements $RecurringIncomeCopyWith<$Res> {
  factory _$$RecurringIncomeImplCopyWith(
    _$RecurringIncomeImpl value,
    $Res Function(_$RecurringIncomeImpl) then,
  ) = __$$RecurringIncomeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'household_id') String householdId,
    @JsonKey(name: 'user_id') String userId,
    String description,
    double amount,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'account_id') String? accountId,
    @JsonKey(name: 'day_of_month') int dayOfMonth,
    bool active,
    @JsonKey(name: 'last_generated') DateTime? lastGenerated,
  });
}

/// @nodoc
class __$$RecurringIncomeImplCopyWithImpl<$Res>
    extends _$RecurringIncomeCopyWithImpl<$Res, _$RecurringIncomeImpl>
    implements _$$RecurringIncomeImplCopyWith<$Res> {
  __$$RecurringIncomeImplCopyWithImpl(
    _$RecurringIncomeImpl _value,
    $Res Function(_$RecurringIncomeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecurringIncome
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? userId = null,
    Object? description = null,
    Object? amount = null,
    Object? categoryId = freezed,
    Object? accountId = freezed,
    Object? dayOfMonth = null,
    Object? active = null,
    Object? lastGenerated = freezed,
  }) {
    return _then(
      _$RecurringIncomeImpl(
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
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        categoryId: freezed == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String?,
        accountId: freezed == accountId
            ? _value.accountId
            : accountId // ignore: cast_nullable_to_non_nullable
                  as String?,
        dayOfMonth: null == dayOfMonth
            ? _value.dayOfMonth
            : dayOfMonth // ignore: cast_nullable_to_non_nullable
                  as int,
        active: null == active
            ? _value.active
            : active // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastGenerated: freezed == lastGenerated
            ? _value.lastGenerated
            : lastGenerated // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecurringIncomeImpl implements _RecurringIncome {
  const _$RecurringIncomeImpl({
    required this.id,
    @JsonKey(name: 'household_id') required this.householdId,
    @JsonKey(name: 'user_id') required this.userId,
    required this.description,
    this.amount = 0,
    @JsonKey(name: 'category_id') this.categoryId,
    @JsonKey(name: 'account_id') this.accountId,
    @JsonKey(name: 'day_of_month') required this.dayOfMonth,
    this.active = true,
    @JsonKey(name: 'last_generated') this.lastGenerated,
  });

  factory _$RecurringIncomeImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecurringIncomeImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'household_id')
  final String householdId;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String description;
  @override
  @JsonKey()
  final double amount;
  @override
  @JsonKey(name: 'category_id')
  final String? categoryId;
  @override
  @JsonKey(name: 'account_id')
  final String? accountId;
  @override
  @JsonKey(name: 'day_of_month')
  final int dayOfMonth;
  @override
  @JsonKey()
  final bool active;
  @override
  @JsonKey(name: 'last_generated')
  final DateTime? lastGenerated;

  @override
  String toString() {
    return 'RecurringIncome(id: $id, householdId: $householdId, userId: $userId, description: $description, amount: $amount, categoryId: $categoryId, accountId: $accountId, dayOfMonth: $dayOfMonth, active: $active, lastGenerated: $lastGenerated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecurringIncomeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.householdId, householdId) ||
                other.householdId == householdId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.dayOfMonth, dayOfMonth) ||
                other.dayOfMonth == dayOfMonth) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.lastGenerated, lastGenerated) ||
                other.lastGenerated == lastGenerated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    householdId,
    userId,
    description,
    amount,
    categoryId,
    accountId,
    dayOfMonth,
    active,
    lastGenerated,
  );

  /// Create a copy of RecurringIncome
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecurringIncomeImplCopyWith<_$RecurringIncomeImpl> get copyWith =>
      __$$RecurringIncomeImplCopyWithImpl<_$RecurringIncomeImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RecurringIncomeImplToJson(this);
  }
}

abstract class _RecurringIncome implements RecurringIncome {
  const factory _RecurringIncome({
    required final String id,
    @JsonKey(name: 'household_id') required final String householdId,
    @JsonKey(name: 'user_id') required final String userId,
    required final String description,
    final double amount,
    @JsonKey(name: 'category_id') final String? categoryId,
    @JsonKey(name: 'account_id') final String? accountId,
    @JsonKey(name: 'day_of_month') required final int dayOfMonth,
    final bool active,
    @JsonKey(name: 'last_generated') final DateTime? lastGenerated,
  }) = _$RecurringIncomeImpl;

  factory _RecurringIncome.fromJson(Map<String, dynamic> json) =
      _$RecurringIncomeImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'household_id')
  String get householdId;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get description;
  @override
  double get amount;
  @override
  @JsonKey(name: 'category_id')
  String? get categoryId;
  @override
  @JsonKey(name: 'account_id')
  String? get accountId;
  @override
  @JsonKey(name: 'day_of_month')
  int get dayOfMonth;
  @override
  bool get active;
  @override
  @JsonKey(name: 'last_generated')
  DateTime? get lastGenerated;

  /// Create a copy of RecurringIncome
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecurringIncomeImplCopyWith<_$RecurringIncomeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
