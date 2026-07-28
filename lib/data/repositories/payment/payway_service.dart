import 'dart:convert';
import 'package:http/http.dart' as http;

/// Talks to your NestJS backend (NOT PayWay directly — the backend holds the secrets).
///
/// For a real device testing against a backend on your Mac, use your Mac's LAN IP
/// (e.g. http://192.168.1.20:3000), not localhost — localhost on the phone means
/// the phone itself. Android emulator uses http://10.0.2.2:3000.
class PaywayService {
  final String apiBase;
  PaywayService({required this.apiBase});

  /// Ask the backend to create a transaction and return the ABA deeplink + QR.
  Future<TopUpResult> startTopUp({
    required double amount,
    required String userId,
  }) async {
    final res = await http.post(
      Uri.parse('$apiBase/api/payments/topup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amount, 'userId': userId}),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Top-up failed: ${res.statusCode} ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return TopUpResult(
      tranId: data['tranId'] as String,
      abapayDeeplink: data['abapayDeeplink'] as String,
      qrImage:
          data['qrImage'] as String, // data:image/png;base64,... (fallback)
    );
  }

  /// Ask the backend whether the payment is done yet.
  /// Returns one of: 'PENDING', 'PAID', 'NOT_FOUND'.
  Future<String> checkStatus(String tranId) async {
    final res = await http.get(
      Uri.parse('$apiBase/api/payments/status/$tranId'),
    );
    if (res.statusCode != 200) return 'PENDING';
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['status'] as String?) ?? 'PENDING';
  }
}

class TopUpResult {
  final String tranId;
  final String abapayDeeplink;
  final String qrImage;
  TopUpResult({
    required this.tranId,
    required this.abapayDeeplink,
    required this.qrImage,
  });
}
