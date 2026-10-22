/// A card the user saved for checkout. Device-local for now — there is no
/// card API behind it yet.
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

  SavedCard copyWith({
    String? id,
    CardBrand? brand,
    String? last4,
    String? holder,
    String? expiry,
  }) {
    return SavedCard(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      last4: last4 ?? this.last4,
      holder: holder ?? this.holder,
      expiry: expiry ?? this.expiry,
    );
  }

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
