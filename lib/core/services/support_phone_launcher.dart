import 'package:url_launcher/url_launcher.dart';

class SupportPhoneLaunchResult {
  const SupportPhoneLaunchResult({
    required this.launched,
    required this.dialUri,
    required this.displayPhone,
  });

  final bool launched;
  final Uri dialUri;
  final String displayPhone;
}

class SupportPhoneLauncher {
  const SupportPhoneLauncher();

  String sanitizePhone(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    final buffer = StringBuffer();
    for (var i = 0; i < trimmed.length; i++) {
      final char = trimmed[i];
      if (char == '+' && buffer.isEmpty) {
        buffer.write(char);
      } else if (char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57) {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  Uri buildDialUri(String phone) {
    final sanitized = sanitizePhone(phone);
    return Uri(scheme: 'tel', path: sanitized);
  }

  Future<SupportPhoneLaunchResult> call(String phone) async {
    final displayPhone = phone.trim();
    final sanitized = sanitizePhone(phone);
    if (sanitized.isEmpty) {
      return SupportPhoneLaunchResult(
        launched: false,
        dialUri: Uri(scheme: 'tel'),
        displayPhone: displayPhone,
      );
    }

    final uri = buildDialUri(phone);
    var launched = false;

    if (await canLaunchUrl(uri)) {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (!launched) {
      launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
    }

    return SupportPhoneLaunchResult(
      launched: launched,
      dialUri: uri,
      displayPhone: displayPhone.isNotEmpty ? displayPhone : sanitized,
    );
  }
}
