import 'dart:io';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:connectivity_plus/connectivity_plus.dart';

import '../model/gold_price_model.dart';

class GoldPriceRepository {
  GoldPriceRepository();

  static const _minPrice = 2115000;
  static const _maxPrice = 2450000;
  static const _delayMs = 1000; // Simulasi delay 1 detik

  Future<GoldPriceModel> fetchGoldPrice() async {
    try {
      // simulasi loading network dengan delay
      await Future.delayed(const Duration(milliseconds: _delayMs));

      // simulasi jika tidak ada koneksi internet, maka lempar error
      final connections = await Connectivity().checkConnectivity();
      if (connections.firstOrNull == ConnectivityResult.none) {
        throw SocketException('No internet connection');
      }

      final basePrice = _minPrice + Random().nextInt(_maxPrice - _minPrice + 1);

      return GoldPriceModel.fromJson({
        'base_price': basePrice,
        'currency': 'IDR',
        'timestamp': DateTime.now(),
      });
    } catch (e) {
      dev.log("[GoldPriceRepository] Error fetching gold price: $e");
      rethrow;
    }
  }
}
