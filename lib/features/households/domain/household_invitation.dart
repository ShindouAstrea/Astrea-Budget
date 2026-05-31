import 'package:freezed_annotation/freezed_annotation.dart';

part 'household_invitation.freezed.dart';
part 'household_invitation.g.dart';

/// Invitación emitida por el owner de un household (vista del que invita).
@freezed
class HouseholdInvitation with _$HouseholdInvitation {
  const factory HouseholdInvitation({
    required String id,
    @JsonKey(name: 'household_id') required String householdId,
    required String email,
    required String status,
    @JsonKey(name: 'expires_at') required DateTime expiresAt,
  }) = _HouseholdInvitation;

  factory HouseholdInvitation.fromJson(Map<String, dynamic> json) =>
      _$HouseholdInvitationFromJson(json);
}

/// Invitación recibida por el usuario actual (vía RPC `my_invitations`, que
/// incluye el nombre del household y de quien invita, no legibles por RLS aún).
@freezed
class ReceivedInvitation with _$ReceivedInvitation {
  const factory ReceivedInvitation({
    required String id,
    @JsonKey(name: 'household_id') required String householdId,
    @JsonKey(name: 'household_name') required String householdName,
    @JsonKey(name: 'invited_by_name') String? invitedByName,
    @JsonKey(name: 'expires_at') required DateTime expiresAt,
  }) = _ReceivedInvitation;

  factory ReceivedInvitation.fromJson(Map<String, dynamic> json) =>
      _$ReceivedInvitationFromJson(json);
}
