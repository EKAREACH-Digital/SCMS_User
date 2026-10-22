import 'dart:convert';

class QrEncryptionUtils {
  /// Encodes a QR payload map into a Base64 string for display.
  /// In production this should use a proper encryption scheme (e.g. AES-GCM).
  static String encode(Map<String, dynamic> payload) {
    final json = jsonEncode(payload);
    return base64UrlEncode(utf8.encode(json));
  }

  /// Decodes a Base64 QR string back into a payload map.
  static Map<String, dynamic> decode(String encoded) {
    final json = utf8.decode(base64Url.decode(encoded));
    return jsonDecode(json) as Map<String, dynamic>;
  }

  /// Builds the standard SCMS ticket payload.
  static Map<String, dynamic> ticketPayload({
    required String studentId,
    required String mealSession,
    required DateTime issuedAt,
  }) {
    return {
      'sid': studentId,
      'session': mealSession,
      'iat': issuedAt.toIso8601String(),
      'exp': issuedAt.add(const Duration(minutes: 30)).toIso8601String(),
    };
  }
}
