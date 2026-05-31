// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'household_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$HouseholdMember {
  String get userId => throw _privateConstructorUsedError;
  HouseholdRole get role => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  bool get isMe => throw _privateConstructorUsedError;

  /// Create a copy of HouseholdMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HouseholdMemberCopyWith<HouseholdMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HouseholdMemberCopyWith<$Res> {
  factory $HouseholdMemberCopyWith(
    HouseholdMember value,
    $Res Function(HouseholdMember) then,
  ) = _$HouseholdMemberCopyWithImpl<$Res, HouseholdMember>;
  @useResult
  $Res call({String userId, HouseholdRole role, String displayName, bool isMe});
}

/// @nodoc
class _$HouseholdMemberCopyWithImpl<$Res, $Val extends HouseholdMember>
    implements $HouseholdMemberCopyWith<$Res> {
  _$HouseholdMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HouseholdMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? role = null,
    Object? displayName = null,
    Object? isMe = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as HouseholdRole,
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
            isMe: null == isMe
                ? _value.isMe
                : isMe // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HouseholdMemberImplCopyWith<$Res>
    implements $HouseholdMemberCopyWith<$Res> {
  factory _$$HouseholdMemberImplCopyWith(
    _$HouseholdMemberImpl value,
    $Res Function(_$HouseholdMemberImpl) then,
  ) = __$$HouseholdMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId, HouseholdRole role, String displayName, bool isMe});
}

/// @nodoc
class __$$HouseholdMemberImplCopyWithImpl<$Res>
    extends _$HouseholdMemberCopyWithImpl<$Res, _$HouseholdMemberImpl>
    implements _$$HouseholdMemberImplCopyWith<$Res> {
  __$$HouseholdMemberImplCopyWithImpl(
    _$HouseholdMemberImpl _value,
    $Res Function(_$HouseholdMemberImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HouseholdMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? role = null,
    Object? displayName = null,
    Object? isMe = null,
  }) {
    return _then(
      _$HouseholdMemberImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as HouseholdRole,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
        isMe: null == isMe
            ? _value.isMe
            : isMe // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$HouseholdMemberImpl implements _HouseholdMember {
  const _$HouseholdMemberImpl({
    required this.userId,
    required this.role,
    required this.displayName,
    required this.isMe,
  });

  @override
  final String userId;
  @override
  final HouseholdRole role;
  @override
  final String displayName;
  @override
  final bool isMe;

  @override
  String toString() {
    return 'HouseholdMember(userId: $userId, role: $role, displayName: $displayName, isMe: $isMe)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HouseholdMemberImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.isMe, isMe) || other.isMe == isMe));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId, role, displayName, isMe);

  /// Create a copy of HouseholdMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HouseholdMemberImplCopyWith<_$HouseholdMemberImpl> get copyWith =>
      __$$HouseholdMemberImplCopyWithImpl<_$HouseholdMemberImpl>(
        this,
        _$identity,
      );
}

abstract class _HouseholdMember implements HouseholdMember {
  const factory _HouseholdMember({
    required final String userId,
    required final HouseholdRole role,
    required final String displayName,
    required final bool isMe,
  }) = _$HouseholdMemberImpl;

  @override
  String get userId;
  @override
  HouseholdRole get role;
  @override
  String get displayName;
  @override
  bool get isMe;

  /// Create a copy of HouseholdMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HouseholdMemberImplCopyWith<_$HouseholdMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
