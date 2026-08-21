// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'household_invitation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HouseholdInvitation {

 String get id;@JsonKey(name: 'household_id') String get householdId; String get email; String get status;@JsonKey(name: 'expires_at') DateTime get expiresAt;
/// Create a copy of HouseholdInvitation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HouseholdInvitationCopyWith<HouseholdInvitation> get copyWith => _$HouseholdInvitationCopyWithImpl<HouseholdInvitation>(this as HouseholdInvitation, _$identity);

  /// Serializes this HouseholdInvitation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HouseholdInvitation&&(identical(other.id, id) || other.id == id)&&(identical(other.householdId, householdId) || other.householdId == householdId)&&(identical(other.email, email) || other.email == email)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,householdId,email,status,expiresAt);

@override
String toString() {
  return 'HouseholdInvitation(id: $id, householdId: $householdId, email: $email, status: $status, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $HouseholdInvitationCopyWith<$Res>  {
  factory $HouseholdInvitationCopyWith(HouseholdInvitation value, $Res Function(HouseholdInvitation) _then) = _$HouseholdInvitationCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'household_id') String householdId, String email, String status,@JsonKey(name: 'expires_at') DateTime expiresAt
});




}
/// @nodoc
class _$HouseholdInvitationCopyWithImpl<$Res>
    implements $HouseholdInvitationCopyWith<$Res> {
  _$HouseholdInvitationCopyWithImpl(this._self, this._then);

  final HouseholdInvitation _self;
  final $Res Function(HouseholdInvitation) _then;

/// Create a copy of HouseholdInvitation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? householdId = null,Object? email = null,Object? status = null,Object? expiresAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [HouseholdInvitation].
extension HouseholdInvitationPatterns on HouseholdInvitation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HouseholdInvitation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HouseholdInvitation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HouseholdInvitation value)  $default,){
final _that = this;
switch (_that) {
case _HouseholdInvitation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HouseholdInvitation value)?  $default,){
final _that = this;
switch (_that) {
case _HouseholdInvitation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'household_id')  String householdId,  String email,  String status, @JsonKey(name: 'expires_at')  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HouseholdInvitation() when $default != null:
return $default(_that.id,_that.householdId,_that.email,_that.status,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'household_id')  String householdId,  String email,  String status, @JsonKey(name: 'expires_at')  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _HouseholdInvitation():
return $default(_that.id,_that.householdId,_that.email,_that.status,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'household_id')  String householdId,  String email,  String status, @JsonKey(name: 'expires_at')  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _HouseholdInvitation() when $default != null:
return $default(_that.id,_that.householdId,_that.email,_that.status,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HouseholdInvitation implements HouseholdInvitation {
  const _HouseholdInvitation({required this.id, @JsonKey(name: 'household_id') required this.householdId, required this.email, required this.status, @JsonKey(name: 'expires_at') required this.expiresAt});
  factory _HouseholdInvitation.fromJson(Map<String, dynamic> json) => _$HouseholdInvitationFromJson(json);

@override final  String id;
@override@JsonKey(name: 'household_id') final  String householdId;
@override final  String email;
@override final  String status;
@override@JsonKey(name: 'expires_at') final  DateTime expiresAt;

/// Create a copy of HouseholdInvitation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HouseholdInvitationCopyWith<_HouseholdInvitation> get copyWith => __$HouseholdInvitationCopyWithImpl<_HouseholdInvitation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HouseholdInvitationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HouseholdInvitation&&(identical(other.id, id) || other.id == id)&&(identical(other.householdId, householdId) || other.householdId == householdId)&&(identical(other.email, email) || other.email == email)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,householdId,email,status,expiresAt);

@override
String toString() {
  return 'HouseholdInvitation(id: $id, householdId: $householdId, email: $email, status: $status, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$HouseholdInvitationCopyWith<$Res> implements $HouseholdInvitationCopyWith<$Res> {
  factory _$HouseholdInvitationCopyWith(_HouseholdInvitation value, $Res Function(_HouseholdInvitation) _then) = __$HouseholdInvitationCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'household_id') String householdId, String email, String status,@JsonKey(name: 'expires_at') DateTime expiresAt
});




}
/// @nodoc
class __$HouseholdInvitationCopyWithImpl<$Res>
    implements _$HouseholdInvitationCopyWith<$Res> {
  __$HouseholdInvitationCopyWithImpl(this._self, this._then);

  final _HouseholdInvitation _self;
  final $Res Function(_HouseholdInvitation) _then;

/// Create a copy of HouseholdInvitation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? householdId = null,Object? email = null,Object? status = null,Object? expiresAt = null,}) {
  return _then(_HouseholdInvitation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$ReceivedInvitation {

 String get id;@JsonKey(name: 'household_id') String get householdId;@JsonKey(name: 'household_name') String get householdName;@JsonKey(name: 'invited_by_name') String? get invitedByName;@JsonKey(name: 'expires_at') DateTime get expiresAt;
/// Create a copy of ReceivedInvitation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceivedInvitationCopyWith<ReceivedInvitation> get copyWith => _$ReceivedInvitationCopyWithImpl<ReceivedInvitation>(this as ReceivedInvitation, _$identity);

  /// Serializes this ReceivedInvitation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceivedInvitation&&(identical(other.id, id) || other.id == id)&&(identical(other.householdId, householdId) || other.householdId == householdId)&&(identical(other.householdName, householdName) || other.householdName == householdName)&&(identical(other.invitedByName, invitedByName) || other.invitedByName == invitedByName)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,householdId,householdName,invitedByName,expiresAt);

@override
String toString() {
  return 'ReceivedInvitation(id: $id, householdId: $householdId, householdName: $householdName, invitedByName: $invitedByName, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $ReceivedInvitationCopyWith<$Res>  {
  factory $ReceivedInvitationCopyWith(ReceivedInvitation value, $Res Function(ReceivedInvitation) _then) = _$ReceivedInvitationCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'household_id') String householdId,@JsonKey(name: 'household_name') String householdName,@JsonKey(name: 'invited_by_name') String? invitedByName,@JsonKey(name: 'expires_at') DateTime expiresAt
});




}
/// @nodoc
class _$ReceivedInvitationCopyWithImpl<$Res>
    implements $ReceivedInvitationCopyWith<$Res> {
  _$ReceivedInvitationCopyWithImpl(this._self, this._then);

  final ReceivedInvitation _self;
  final $Res Function(ReceivedInvitation) _then;

/// Create a copy of ReceivedInvitation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? householdId = null,Object? householdName = null,Object? invitedByName = freezed,Object? expiresAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,householdName: null == householdName ? _self.householdName : householdName // ignore: cast_nullable_to_non_nullable
as String,invitedByName: freezed == invitedByName ? _self.invitedByName : invitedByName // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ReceivedInvitation].
extension ReceivedInvitationPatterns on ReceivedInvitation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReceivedInvitation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReceivedInvitation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReceivedInvitation value)  $default,){
final _that = this;
switch (_that) {
case _ReceivedInvitation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReceivedInvitation value)?  $default,){
final _that = this;
switch (_that) {
case _ReceivedInvitation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'household_id')  String householdId, @JsonKey(name: 'household_name')  String householdName, @JsonKey(name: 'invited_by_name')  String? invitedByName, @JsonKey(name: 'expires_at')  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReceivedInvitation() when $default != null:
return $default(_that.id,_that.householdId,_that.householdName,_that.invitedByName,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'household_id')  String householdId, @JsonKey(name: 'household_name')  String householdName, @JsonKey(name: 'invited_by_name')  String? invitedByName, @JsonKey(name: 'expires_at')  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _ReceivedInvitation():
return $default(_that.id,_that.householdId,_that.householdName,_that.invitedByName,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'household_id')  String householdId, @JsonKey(name: 'household_name')  String householdName, @JsonKey(name: 'invited_by_name')  String? invitedByName, @JsonKey(name: 'expires_at')  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _ReceivedInvitation() when $default != null:
return $default(_that.id,_that.householdId,_that.householdName,_that.invitedByName,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReceivedInvitation implements ReceivedInvitation {
  const _ReceivedInvitation({required this.id, @JsonKey(name: 'household_id') required this.householdId, @JsonKey(name: 'household_name') required this.householdName, @JsonKey(name: 'invited_by_name') this.invitedByName, @JsonKey(name: 'expires_at') required this.expiresAt});
  factory _ReceivedInvitation.fromJson(Map<String, dynamic> json) => _$ReceivedInvitationFromJson(json);

@override final  String id;
@override@JsonKey(name: 'household_id') final  String householdId;
@override@JsonKey(name: 'household_name') final  String householdName;
@override@JsonKey(name: 'invited_by_name') final  String? invitedByName;
@override@JsonKey(name: 'expires_at') final  DateTime expiresAt;

/// Create a copy of ReceivedInvitation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceivedInvitationCopyWith<_ReceivedInvitation> get copyWith => __$ReceivedInvitationCopyWithImpl<_ReceivedInvitation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceivedInvitationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReceivedInvitation&&(identical(other.id, id) || other.id == id)&&(identical(other.householdId, householdId) || other.householdId == householdId)&&(identical(other.householdName, householdName) || other.householdName == householdName)&&(identical(other.invitedByName, invitedByName) || other.invitedByName == invitedByName)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,householdId,householdName,invitedByName,expiresAt);

@override
String toString() {
  return 'ReceivedInvitation(id: $id, householdId: $householdId, householdName: $householdName, invitedByName: $invitedByName, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$ReceivedInvitationCopyWith<$Res> implements $ReceivedInvitationCopyWith<$Res> {
  factory _$ReceivedInvitationCopyWith(_ReceivedInvitation value, $Res Function(_ReceivedInvitation) _then) = __$ReceivedInvitationCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'household_id') String householdId,@JsonKey(name: 'household_name') String householdName,@JsonKey(name: 'invited_by_name') String? invitedByName,@JsonKey(name: 'expires_at') DateTime expiresAt
});




}
/// @nodoc
class __$ReceivedInvitationCopyWithImpl<$Res>
    implements _$ReceivedInvitationCopyWith<$Res> {
  __$ReceivedInvitationCopyWithImpl(this._self, this._then);

  final _ReceivedInvitation _self;
  final $Res Function(_ReceivedInvitation) _then;

/// Create a copy of ReceivedInvitation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? householdId = null,Object? householdName = null,Object? invitedByName = freezed,Object? expiresAt = null,}) {
  return _then(_ReceivedInvitation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,householdId: null == householdId ? _self.householdId : householdId // ignore: cast_nullable_to_non_nullable
as String,householdName: null == householdName ? _self.householdName : householdName // ignore: cast_nullable_to_non_nullable
as String,invitedByName: freezed == invitedByName ? _self.invitedByName : invitedByName // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
