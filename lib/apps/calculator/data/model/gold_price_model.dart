/// Model representasi response dari API harga emas.
class GoldPriceModel {
  final int basePrice;
  final String currency;
  final DateTime timestamp;

  const GoldPriceModel({
    required this.basePrice,
    required this.currency,
    required this.timestamp,
  });

  factory GoldPriceModel.fromJson(Map<String, dynamic> json) {
    return GoldPriceModel(
      basePrice: json['base_price'],
      currency: json['currency'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() => {
    'base_price': basePrice,
    'currency': currency,
    'timestamp': timestamp.toIso8601String(),
  };

  @override
  String toString() =>
      'GoldPriceModel(basePrice: $basePrice, currency: $currency, timestamp: $timestamp)';
}
