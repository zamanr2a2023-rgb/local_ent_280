import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/features/auth/data/user_session.dart';
import 'package:local_ent_280/presentation/widgets/user_avatar.dart';

/// Circular avatar showing the authenticated user's photo or initials.
class SessionProfileAvatar extends StatelessWidget {
  const SessionProfileAvatar({
    super.key,
    this.size,
    this.onTap,
    this.fontSize,
  });

  final double? size;
  final double? fontSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserSession.instance,
      builder: (context, _) {
        return UserAvatar(
          profile: UserSession.instance.profile,
          size: size ?? 40.w,
          fontSize: fontSize,
          onTap: onTap,
        );
      },
    );
  }
}
