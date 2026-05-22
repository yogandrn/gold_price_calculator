part of '../main.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  "/calculator": (context) => const GoldCalculatorView(),
};
