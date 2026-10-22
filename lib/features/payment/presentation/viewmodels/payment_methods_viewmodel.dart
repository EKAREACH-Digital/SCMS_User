import 'package:flutter/foundation.dart';

import 'package:smart_canteen_user_frontend/features/payment/domain/entities/saved_card.dart';

/// The user's saved cards and which one is the default. In-memory only —
/// there is no card API yet.
class PaymentMethodsViewModel extends ChangeNotifier {
  final List<SavedCard> _cards = [
    const SavedCard(
      id: 'seed-visa',
      brand: CardBrand.visa,
      last4: '4242',
      holder: 'Sokhunmony Soun',
      expiry: '08/27',
    ),
  ];

  /// Id of the default card; defaults to the first card.
  String? _defaultId = 'seed-visa';

  List<SavedCard> get cards => List.unmodifiable(_cards);
  String? get defaultId => _defaultId;

  void addCard(SavedCard card) {
    _setState(() {
      _cards.add(card);
      _defaultId ??= card.id;
    });
  }

  void removeCard(String id) {
    _setState(() {
      _cards.removeWhere((c) => c.id == id);
      if (_defaultId == id) {
        _defaultId = _cards.isEmpty ? null : _cards.first.id;
      }
    });
  }

  void setDefault(String id) {
    if (_defaultId == id) return;
    _setState(() => _defaultId = id);
  }

  /// The only place listeners are notified: applies [update], then rebuilds
  /// listeners. This view model has no async work, so it has no `ViewState`.
  void _setState(VoidCallback update) {
    update();
    notifyListeners();
  }
}
