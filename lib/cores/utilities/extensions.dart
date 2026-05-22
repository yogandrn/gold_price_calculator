import 'dart:async';
import 'dart:io';

import 'package:intl/intl.dart';

extension ErrorHandler on Object? {
  bool isNetworkError() {
    return (this != null) &&
        (this is SocketException || this is TimeoutException);
  }

  String toMessage() {
    if (this is SocketException) {
      return 'No internet connection';
    }

    if ("$this".toLowerCase().contains('doctype')) {
      return 'Sorry, something went wrong';
    }

    if ("$this".contains("Unauthenticated")) {
      return "Session expired. Please login again.";
    }

    return "$this".replaceAll(r'Exception: ', '');
  }
}

extension DateFormating on DateTime {
  String formatToLocale(String format) {
    return DateFormat('dd MMM yyyy, HH:mm:ss').format(this);
  }
}

extension CurrencyFormatting on num {
  String formatToCurrency({String locale = 'id_ID', String symbol = 'Rp'}) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: 0,
    );
    return formatter.format(this);
  }
}
