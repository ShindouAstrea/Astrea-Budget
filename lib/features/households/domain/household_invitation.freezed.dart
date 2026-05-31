// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'household_invitation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

HouseholdInvitation _$HouseholdInvitationFromJson(Map<String, dynamic> json) {
  return _HouseholdInvitation.fromJson(json);
}

/// @nodoc
mixin _$HouseholdInvitation {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'household_id')
  String get householdId => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at')
  DateTime get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this HouseholdInvitation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HouseholdInvitation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HouseholdInvitationCopyWith<HouseholdInvitation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HouseholdInvitationCopyWith<$Res> {
  factory $HouseholdInvitationCopyWith(
    HouseholdInvitation value,
    $Res Function(HouseholdInvitation) then,
  ) = _$HouseholdInvitationCopyWithImpl<$Res, HouseholdInvitation>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'household_id') String householdId,
    String email,
    String status,
    @JsonKey(name: 'expires_at') DateTime expiresAt,
  });
}

/// @nodoc
class _$HouseholdInvitationCopyWithImpl<$Res, $Val extends HouseholdInvitation>
    implements $HouseholdInvitationCopyWith<$Res> {
  _$HouseholdInvitationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HouseholdInvitation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? email = null,
    Object? status = null,
    Object? expiresAt = null,
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
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            expiresAt: null == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HouseholdInvitationImplCopyWith<$Res>
    implements $HouseholdInvitationCopyWith<$Res> {
  factory _$$HouseholdInvitationImplCopyWith(
    _$HouseholdInvitationImpl value,
    $Res Function(_$HouseholdInvitationImpl) then,
  ) = __$$HouseholdInvitationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'household_id') String householdId,
    String email,
    String status,
    @JsonKey(name: 'expires_at') DateTime expiresAt,
  });
}

/// @nodoc
class __$$HouseholdInvitationImplCopyWithImpl<$Res>
    extends _$HouseholdInvitationCopyWithImpl<$Res, _$HouseholdInvitationImpl>
    implements _$$HouseholdInvitationImplCopyWith<$Res> {
  __$$HouseholdInvitationImplCopyWithImpl(
    _$HouseholdInvitationImpl _value,
    $Res Function(_$HouseholdInvitationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HouseholdInvitation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? email = null,
    Object? status = null,
    Object? expiresAt = null,
  }) {
    return _then(
      _$HouseholdInvitationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        householdId: null == householdId
            ? _value.householdId
            : householdId // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        expiresAt: null == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HouseholdInvitationImpl implements _HouseholdInvitation {
  const _$HouseholdInvitationImpl({
    required this.id,
    @JsonKey(name: 'household_id') required this.householdId,
    required this.email,
    required this.status,
    @JsonKey(name: 'expires_at') required this.expiresAt,
  });

  factory _$HouseholdInvitationImpl.fromJson(Map<String, dynamic> json) =>
      _$$HouseholdInvitationImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'household_id')
  final String householdId;
  @override
  final String email;
  @override
  final String status;
  @override
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;

  @override
  String toString() {
    return 'HouseholdInvitation(id: $id, householdId: $householdId, email: $email, status: $status, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HouseholdInvitationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.householdId, householdId) ||
                other.householdId == householdId) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, householdId, email, status, expiresAt);

  /// Create a copy of HouseholdInvitation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HouseholdInvitationImplCopyWith<_$HouseholdInvitationImpl> get copyWith =>
      __$$HouseholdInvitationImplCopyWithImpl<_$HouseholdInvitationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$HouseholdInvitationImplToJson(this);
  }
}

abstract class _HouseholdInvitation implements HouseholdInvitation {
  const factory _HouseholdInvitation({
    required final String id,
    @JsonKey(name: 'household_id') required final String householdId,
    required final String email,
    required final String status,
    @JsonKey(name: 'expires_at') required final DateTime expiresAt,
  }) = _$HouseholdInvitationImpl;

  factory _HouseholdInvitation.fromJson(Map<String, dynamic> json) =
      _$HouseholdInvitationImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'household_id')
  String get householdId;
  @override
  String get email;
  @override
  String get status;
  @override
  @JsonKey(name: 'expires_at')
  DateTime get expiresAt;

  /// Create a copy of HouseholdInvitation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HouseholdInvitationImplCopyWith<_$HouseholdInvitationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReceivedInvitation _$ReceivedInvitationFromJson(Map<String, dynamic> json) {
  return _ReceivedInvitation.fromJson(json);
}

/// @nodoc
mixin _$ReceivedInvitation {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'household_id')
  String get householdId => throw _privateConstructorUsedError;
  @JsonKey(name: 'household_name')
  String get householdName => throw _privateConstructorUsedError;
  @JsonKey(name: 'invited_by_name')
  String? get invitedByName => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at')
  DateTime get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this ReceivedInvitation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReceivedInvitation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReceivedInvitationCopyWith<ReceivedInvitation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReceivedInvitationCopyWith<$Res> {
  factory $ReceivedInvitationCopyWith(
    ReceivedInvitation value,
    $Res Function(ReceivedInvitation) then,
  ) = _$ReceivedInvitationCopyWithImpl<$Res, ReceivedInvitation>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'household_id') String householdId,
    @JsonKey(name: 'household_name') String householdName,
    @JsonKey(name: 'invited_by_name') String? invitedByName,
    @JsonKey(name: 'expires_at') DateTime expiresAt,
  });
}

/// @nodoc
class _$ReceivedInvitationCopyWithImpl<$Res, $Val extends ReceivedInvitation>
    implements $ReceivedInvitationCopyWith<$Res> {
  _$ReceivedInvitationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReceivedInvitation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? householdName = null,
    Object? invitedByName = freezed,
    Object? expiresAt = null,
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
            householdName: null == householdName
                ? _value.householdName
                : householdName // ignore: cast_nullable_to_non_nullable
                      as String,
            invitedByName: freezed == invitedByName
                ? _value.invitedByName
                : invitedByName // ignore: cast_nullable_to_non_nullable
                      as String?,
            expiresAt: null == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReceivedInvitationImplCopyWith<$Res>
    implements $ReceivedInvitationCopyWith<$Res> {
  factory _$$ReceivedInvitationImplCopyWith(
    _$ReceivedInvitationImpl value,
    $Res Function(_$ReceivedInvitationImpl) then,
  ) = __$$ReceivedInvitationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'household_id') String householdId,
    @JsonKey(name: 'household_name') String householdName,
    @JsonKey(name: 'invited_by_name') String? invitedByName,
    @JsonKey(name: 'expires_at') DateTime expiresAt,
  });
}

/// @nodoc
class __$$ReceivedInvitationImplCopyWithImpl<$Res>
    extends _$ReceivedInvitationCopyWithImpl<$Res, _$ReceivedInvitationImpl>
    implements _$$ReceivedInvitationImplCopyWith<$Res> {
  __$$ReceivedInvitationImplCopyWithImpl(
    _$ReceivedInvitationImpl _value,
    $Res Function(_$ReceivedInvitationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReceivedInvitation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? householdName = null,
    Object? invitedByName = freezed,
    Object? expiresAt = null,
  }) {
    return _then(
      _$ReceivedInvitationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        householdId: null == householdId
            ? _value.householdId
            : householdId // ignore: cast_nullable_to_non_nullable
                  as String,
        householdName: null == householdName
            ? _value.householdName
            : householdName // ignore: cast_nullable_to_non_nullable
                  as String,
        invitedByName: freezed == invitedByName
            ? _value.invitedByName
            : invitedByName // ignore: cast_nullable_to_non_nullable
                  as String?,
        expiresAt: null == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReceivedInvitationImpl implements _ReceivedInvitation {
  const _$ReceivedInvitationImpl({
    required this.id,
    @JsonKey(name: 'household_id') required this.householdId,
    @JsonKey(name: 'household_name') required this.householdName,
    @JsonKey(name: 'invited_by_name') this.invitedByName,
    @JsonKey(name: 'expires_at') required this.expiresAt,
  });

  factory _$ReceivedInvitationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReceivedInvitationImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'household_id')
  final String householdId;
  @override
  @JsonKey(name: 'household_name')
  final String householdName;
  @override
  @JsonKey(name: 'invited_by_name')
  final String? invitedByName;
  @override
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;

  @override
  String toString() {
    return 'ReceivedInvitation(id: $id, householdId: $householdId, householdName: $householdName, invitedByName: $invitedByName, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReceivedInvitationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.householdId, householdId) ||
                other.householdId == householdId) &&
            (identical(other.householdName, householdName) ||
                other.householdName == householdName) &&
            (identical(other.invitedByName, invitedByName) ||
                other.invitedByName == invitedByName) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    householdId,
    householdName,
    invitedByName,
    expiresAt,
  );

  /// Create a copy of ReceivedInvitation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReceivedInvitationImplCopyWith<_$ReceivedInvitationImpl> get copyWith =>
      __$$ReceivedInvitationImplCopyWithImpl<_$ReceivedInvitationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ReceivedInvitationImplToJson(this);
  }
}

abstract class _ReceivedInvitation implements ReceivedInvitation {
  const factory _ReceivedInvitation({
    required final String id,
    @JsonKey(name: 'household_id') required final String householdId,
    @JsonKey(name: 'household_name') required final String householdName,
    @JsonKey(name: 'invited_by_name') final String? invitedByName,
    @JsonKey(name: 'expires_at') required final DateTime expiresAt,
  }) = _$ReceivedInvitationImpl;

  factory _ReceivedInvitation.fromJson(Map<String, dynamic> json) =
      _$ReceivedInvitationImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'household_id')
  String get householdId;
  @override
  @JsonKey(name: 'household_name')
  String get householdName;
  @override
  @JsonKey(name: 'invited_by_name')
  String? get invitedByName;
  @override
  @JsonKey(name: 'expires_at')
  DateTime get expiresAt;

  /// Create a copy of ReceivedInvitation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReceivedInvitationImplCopyWith<_$ReceivedInvitationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
