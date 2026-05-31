import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/enums.dart';

part 'household_member.freezed.dart';

/// Miembro de un household, ya enlazado con su nombre visible (display_name).
/// Se ensambla en el repositorio uniendo `household_members` + `profiles`.
@freezed
class HouseholdMember with _$HouseholdMember {
  const factory HouseholdMember({
    required String userId,
    required HouseholdRole role,
    required String displayName,
    required bool isMe,
  }) = _HouseholdMember;
}
