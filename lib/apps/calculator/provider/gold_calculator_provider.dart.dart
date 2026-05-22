import 'package:flutter/foundation.dart';

import '../data/model/gold_price_model.dart';
import '../data/repository/gold_price_repository.dart';

/// app states
enum GoldPriceStatus { initial, loading, success, error }

/// options
enum GoldKarat {
  k24(label: '24K', value: 24),
  k22(label: '22K', value: 22),
  k18(label: '18K', value: 18);

  const GoldKarat({required this.label, required this.value});
  final String label;
  final int value;
}

class GoldCalculatorProvider extends ChangeNotifier {
  GoldCalculatorProvider({GoldPriceRepository? repository})
    : _repository = repository ?? GoldPriceRepository();
  // dependency
  final GoldPriceRepository _repository;

  // states
  GoldPriceStatus _status = GoldPriceStatus.initial;
  GoldPriceModel? _goldPrice;
  String _errorMessage = '';

  GoldKarat _selectedKarat = GoldKarat.k24;
  double _weightInGram = 0.0;

  // getters
  GoldPriceStatus get status => _status;
  GoldPriceModel? get goldPrice => _goldPrice;
  String get errorMessage => _errorMessage;
  GoldKarat get selectedKarat => _selectedKarat;
  double get weightInGram => _weightInGram;
  bool get isInitial => _status == GoldPriceStatus.initial;
  bool get isLoading => _status == GoldPriceStatus.loading;
  bool get isSuccess => _status == GoldPriceStatus.success;
  bool get isError => _status == GoldPriceStatus.error;

  /// Harga per gram berdasarkan karat yang dipilih.
  /// Formula: harga_24k * (karat / 24)
  double get pricePerGram {
    if (_goldPrice == null) return 0.0;
    return _goldPrice!.basePrice * (_selectedKarat.value / 24);
  }

  /// Total harga = harga per gram × berat.
  double get totalPrice => pricePerGram * _weightInGram;

  bool get hasResult => isSuccess && _weightInGram > 0;

  Future<void> fetchGoldPrice() async {
    _setStatus(GoldPriceStatus.loading);
    _errorMessage = '';

    try {
      _goldPrice = await _repository.fetchGoldPrice();
      _setStatus(GoldPriceStatus.success);
    } catch (e, _) {
      _errorMessage = _parseError(e);
      _setStatus(GoldPriceStatus.error);
    }
  }

  void selectKarat(GoldKarat karat) {
    if (_selectedKarat == karat) return;
    _selectedKarat = karat;
    notifyListeners();
  }

  void updateWeight(String value) {
    final parsed = double.tryParse(value) ?? 0.0;
    if (_weightInGram == parsed) return;
    _weightInGram = parsed;
    notifyListeners();
  }

  void resetWeight() {
    _weightInGram = 0.0;
    notifyListeners();
  }

  void _setStatus(GoldPriceStatus status) {
    _status = status;
    notifyListeners();
  }

  String _parseError(Object e) {
    final raw = e.toString();
    if (raw.startsWith('Exception: '))
      return raw.replaceFirst('Exception: ', '');
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}
