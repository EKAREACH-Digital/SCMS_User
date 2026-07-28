import '../../dtos/payment_dto.dart';
import 'payment_repository.dart';

/// Offline stand-in for the dev flavour.
///
/// Returns a real, well-formed KHQR payload (a sandbox response captured
/// verbatim) so the QR widget renders something scannable-looking, then
/// reports PAID after a few polls to exercise the waiting → success path
/// without a backend or the ABA app.
class PaymentRepositoryMock implements PaymentRepository {
  static const _sampleQr =
      '00020101021230510016abaakhppxxx@abaa0115111111111111111020'
      '8ABA Bank52045999530384054041.005802KH5913Smart Canteen6000'
      '62330507012795407185802KH6304A1B2';

  /// Polls remaining before the fake payment "completes".
  int _pollsUntilPaid = 0;

  @override
  Future<TopupSessionDto> startTopUp(double amountUsd) async {
    await Future.delayed(const Duration(milliseconds: 700));
    _pollsUntilPaid = 3;
    return TopupSessionDto(
      tranId: 'PWmock${DateTime.now().millisecondsSinceEpoch % 100000}',
      qrImage: '',
      qrString: _sampleQr,
      abapayDeeplink: 'abamobilebank://ababank.com?type=payway&qrcode=$_sampleQr',
      amountUsd: amountUsd,
    );
  }

  @override
  Future<TopupStatus> checkStatus(String tranId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_pollsUntilPaid > 0) {
      _pollsUntilPaid--;
      return TopupStatus.pending;
    }
    return TopupStatus.paid;
  }
}
