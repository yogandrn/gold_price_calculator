import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goldprice/cores/utilities/extensions.dart';
import 'package:provider/provider.dart';

import '../../theme_setting/provider/theme_provider.dart';
import '../provider/gold_calculator_provider.dart.dart';

class GoldCalculatorView extends StatefulWidget {
  const GoldCalculatorView({super.key});

  @override
  State<GoldCalculatorView> createState() => _GoldCalculatorViewState();
}

class _GoldCalculatorViewState extends State<GoldCalculatorView> {
  final TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoldCalculatorProvider>().fetchGoldPrice();
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SliverAppBar.large(
                title: const Text('Kalkulator Emas Realtime'),
                actions: [
                  IconButton(
                    icon: Icon(
                      themeProvider.isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode,
                    ),
                    tooltip: 'Toggle Dark Mode',
                    onPressed: () => themeProvider.toggleDarkMode(),
                  ),
                ],
              );
            },
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<GoldCalculatorProvider>(
                builder: (context, provider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // on loading
                      if (provider.isLoading) ...[
                        const SizedBox(height: 40),
                        const Center(child: CircularProgressIndicator()),
                        const SizedBox(height: 16),
                      ],

                      // on error
                      if (provider.isError) ...[
                        _buildErrorCard(
                          provider.errorMessage,
                          () => provider.fetchGoldPrice(),
                        ),
                      ],

                      // on success
                      if (provider.isSuccess || provider.goldPrice != null) ...[
                        _buildPriceInfoCard(provider),
                        const SizedBox(height: 12),
                        _buildFormCard(provider),
                        const SizedBox(height: 12),
                        if (provider.hasResult) _buildResultCard(provider),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfoCard(GoldCalculatorProvider provider) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Harga Dasar (24K)', style: textTheme.bodyMedium),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: provider.isLoading
                      ? null
                      : () => provider.fetchGoldPrice(),
                  icon: provider.isLoading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.refresh,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                  tooltip: 'Perbarui Harga',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              (provider.goldPrice?.basePrice ?? 0).formatToCurrency(),
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Terakhir Diperbarui:', style: textTheme.bodySmall),
                Text(
                  provider.goldPrice?.timestamp.formatToLocale(
                        'dd MMM yyyy, HH:mm:ss',
                      ) ??
                      '-',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(GoldCalculatorProvider provider) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Input Parameter',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Dropdown Pilih Karat (18k/22k/24k)
            DropdownButtonFormField<GoldKarat>(
              initialValue: provider.selectedKarat,
              decoration: const InputDecoration(
                labelText: 'Pilih Karat Emas',
                prefixIcon: Icon(Icons.layers),
              ),
              items: GoldKarat.values.map((GoldKarat karat) {
                return DropdownMenuItem<GoldKarat>(
                  value: karat,
                  child: Text(
                    '${karat.label} (${karat.value} Karat)',
                    style: textTheme.bodyLarge,
                  ),
                );
              }).toList(),
              onChanged: (GoldKarat? newValue) {
                if (newValue != null) provider.selectKarat(newValue);
              },
            ),
            const SizedBox(height: 16),

            // Input Berat Gram
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Berat Emas (Gram)',
                prefixIcon: const Icon(Icons.scale),
                suffixText: 'gram',
                suffixIcon: provider.weightInGram > 0
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _weightController.clear();
                          provider.resetWeight();
                        },
                      )
                    : null,
              ),
              onChanged: (value) => provider.updateWeight(value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(GoldCalculatorProvider provider) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Harga Per Gram (${provider.selectedKarat.label})',
                  style: textTheme.bodyMedium,
                ),
                Text(
                  provider.pricePerGram.formatToCurrency(),
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Berat Total', style: textTheme.bodyMedium),
                Text(
                  '${provider.weightInGram} gram',
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estimasi Total Harga',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  provider.totalPrice.formatToCurrency(),
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message, VoidCallback onRetry) {
    return Card(
      color: Colors.red.withAlpha(32),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
