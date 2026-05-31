// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'household_invitation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HouseholdInvitationImpl _$$HouseholdInvitationImplFromJson(
  Map<String, dynamic> json,
) => _$HouseholdInvitationImpl(
  id: json['id'] as String,
  householdId: json['household_id'] as String,
  email: json['email'] as String,
  status: json['status'] as String,
  expiresAt: DateTime.parse(json['expires_at'] as String),
);

Map<String, dynamic> _$$HouseholdInvitationImplToJson(
  _$HouseholdInvitationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'household_id': instance.householdId,
  'email': instance.email,
  'status': instance.status,
  'expires_at': instance.expiresAt.toIso8601String(),
};

_$ReceivedInvitationImpl _$$ReceivedInvitationImplFromJson(
  Map<String, dynamic> json,
) => _$ReceivedInvitationImpl(
  id: json['id'] as String,
  householdId: json['household_id'] as String,
  householdName: json['household_name'] as String,
  invitedByName: json['invited_by_name'] as String?,
  expiresAt: DateTime.parse(json['expires_at'] as String),
);

Map<String, dynamic> _$$ReceivedInvitationImplToJson(
  _$ReceivedInvitationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'household_id': instance.householdId,
  'household_name': instance.householdName,
  'invited_by_name': instance.invitedByName,
  'expires_at': instance.expiresAt.toIso8601String(),
};
