import 'package:smart_canteen_user_frontend/features/payment/domain/entities/topup_session.dart';

/// A payment session opened by our backend against the gateway.
///
/// The app never sees gateway credentials — the backend signs the request and
/// returns only what's needed to present the payment.
class TopupSessionDto {
  const TopupSessionDto({
    required this.tranId,
    required this.qrImage,
    required this.qrString,
    required this.abapayDeeplink,
    required this.amountUsd,
  });

  /// Our reference for this payment; used to poll for completion.
  final String tranId;

  /// `data:image/png;base64,...` rendered by the gateway.
  final String qrImage;

  /// Raw EMVCo KHQR payload — what we actually render, so the QR matches the
  /// app's own styling instead of the gateway's template.
  final String qrString;

  /// `abamobilebank://...` — opens the bank app on this device.
  final String abapayDeeplink;

  final double amountUsd;

  factory TopupSessionDto.fromJson(Map<String, dynamic> json) =>
      TopupSessionDto(
        tranId: json['tranId'] as String,
        qrImage: (json['qrImage'] as String?) ?? '',
        qrString: (json['qrString'] as String?) ?? '',
        abapayDeeplink: (json['abapayDeeplink'] as String?) ?? '',
        amountUsd: switch (json['amount']) {
          num n => n.toDouble(),
          String s => double.tryParse(s) ?? 0,
          _ => 0,
        },
      );

  TopupSession toEntity() => TopupSession(
        tranId: tranId,
        qrString: qrString,
        abapayDeeplink: abapayDeeplink,
        amountUsd: amountUsd,
      );
}

/// Parses the backend's status string (`PENDING` | `PAID` | `FAILED` |
/// `NOT_FOUND`); anything unknown is treated as still pending.
TopupStatus parseTopupStatus(String raw) => switch (raw.toUpperCase()) {
      'PAID' => TopupStatus.paid,
      'FAILED' => TopupStatus.failed,
      'NOT_FOUND' => TopupStatus.notFound,
      _ => TopupStatus.pending,
    };
