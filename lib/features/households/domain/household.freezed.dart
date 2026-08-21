// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'household.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Household {

 String get id; String get name;@JsonKey(name: 'is_personal') bool get isPersonal;@JsonKey(name: 'created_by') String get createdBy;
/// Create a copy of Household
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HouseholdCopyWith<Household> get copyWith => _$HouseholdCopyWithImpl<Household>(this as Household, _$identity);

  /// Serializes this Household to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Household&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isPersonal, isPersonal) || other.isPersonal == isPersonal)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,isPersonal,createdBy);

@override
String toString() {
  return 'Household(id: $id, name: $name, isPersonal: $isPersonal, createdBy: $createdBy)';
}


}

/// @nodoc
abstract mixin class $HouseholdCopyWith<$Res>  {
  factory $HouseholdCopyWith(Household value, $Res Function(Household) _then) = _$HouseholdCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'is_personal') bool isPersonal,@JsonKey(name: 'created_by') String createdBy
});




}
/// @nodoc
class _$HouseholdCopyWithImpl<$Res>
    implements $HouseholdCopyWith<$Res> {
  _$HouseholdCopyWithImpl(this._self, this._then);

  final Household _self;
  final $Res Function(Household) _then;

/// Create a copy of Household
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? isPersonal = null,Object? createdBy = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isPersonal: null == isPersonal ? _self.isPersonal : isPersonal // ignore: cast_nullable_to_non_nullable
as bool,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Household].
extension HouseholdPatterns on Household {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Household value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Household() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Household value)  $default,){
final _that = this;
switch (_that) {
case _Household():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Household value)?  $default,){
final _that = this;
switch (_that) {
case _Household() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'is_personal')  bool isPersonal, @JsonKey(name: 'created_by')  String createdBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Household() when $default != null:
return $default(_that.id,_that.name,_that.isPersonal,_that.createdBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'is_personal')  bool isPersonal, @JsonKey(name: 'created_by')  String createdBy)  $default,) {final _that = this;
switch (_that) {
case _Household():
return $default(_that.id,_that.name,_that.isPersonal,_that.createdBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'is_personal')  bool isPersonal, @JsonKey(name: 'created_by')  String createdBy)?  $default,) {final _that = this;
switch (_that) {
case _Household() when $default != null:
return $default(_that.id,_that.name,_that.isPersonal,_that.createdBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Household implements Household {
  const _Household({required this.id, required this.name, @JsonKey(name: 'is_personal') this.isPersonal = false, @JsonKey(name: 'created_by') required this.createdBy});
  factory _Household.fromJson(Map<String, dynamic> json) => _$HouseholdFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'is_personal') final  bool isPersonal;
@override@JsonKey(name: 'created_by') final  String createdBy;

/// Create a copy of Household
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HouseholdCopyWith<_Household> get copyWith => __$HouseholdCopyWithImpl<_Household>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HouseholdToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Household&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isPersonal, isPersonal) || other.isPersonal == isPersonal)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,isPersonal,createdBy);

@override
String toString() {
  return 'Household(id: $id, name: $name, isPersonal: $isPersonal, createdBy: $createdBy)';
}


}

/// @nodoc
abstract mixin class _$HouseholdCopyWith<$Res> implements $HouseholdCopyWith<$Res> {
  factory _$HouseholdCopyWith(_Household value, $Res Function(_Household) _then) = __$HouseholdCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'is_personal') bool isPersonal,@JsonKey(name: 'created_by') String createdBy
});




}
/// @nodoc
class __$HouseholdCopyWithImpl<$Res>
    implements _$HouseholdCopyWith<$Res> {
  __$HouseholdCopyWithImpl(this._self, this._then);

  final _Household _self;
  final $Res Function(_Household) _then;

/// Create a copy of Household
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? isPersonal = null,Object? createdBy = null,}) {
  return _then(_Household(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isPersonal: null == isPersonal ? _self.isPersonal : isPersonal // ignore: cast_nullable_to_non_nullable
as bool,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
