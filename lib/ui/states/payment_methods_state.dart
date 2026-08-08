import 'package:flutter/foundation.dart';

enum CardBrand { visa, mastercard, amex, generic }

extension CardBrandX on CardBrand {
  String get label => switch (this) {
    CardBrand.visa => 'Visa',
    CardBrand.mastercard => 'Mastercard',
    CardBrand.amex => 'Amex',
    CardBrand.generic => 'Card',
  };
}

class SavedCard {
  const SavedCard({
    required this.id,
    required this.brand,
    required this.last4,
    required this.holder,
    required this.expiry,
  });

  final String id;
  final CardBrand brand;
  final String last4;
  final String holder;
  final String expiry; // MM/YY

  /// Infers the brand from the leading digit of a card number.
  static CardBrand brandFromNumber(String digits) {
    if (digits.isEmpty) return CardBrand.generic;
    return switch (digits[0]) {
      '4' => CardBrand.visa,
      '5' => CardBrand.mastercard,
      '3' => CardBrand.amex,
      _ => CardBrand.generic,
    };
  }
}

class PaymentMethodsState extends ChangeNotifier {
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
    _cards.add(card);
    _defaultId ??= card.id;
    notifyListeners();
  }

  void removeCard(String id) {
    _cards.removeWhere((c) => c.id == id);
    if (_defaultId == id) {
      _defaultId = _cards.isEmpty ? null : _cards.first.id;
    }
    notifyListeners();
  }

  void setDefault(String id) {
    if (_defaultId == id) return;
    _defaultId = id;
    notifyListeners();
  }
}
