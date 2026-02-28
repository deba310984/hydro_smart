import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydro_smart/features/market_prices/market_price_service.dart';

// ─── STATE ────────────────────────────────────────────────────

class MarketPriceState {
  final List<MarketPrice> domesticPrices;
  final List<MarketPrice> internationalPrices;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const MarketPriceState({
    this.domesticPrices = const [],
    this.internationalPrices = const [],
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  List<MarketPrice> get allPrices =>
      [...domesticPrices, ...internationalPrices];

  MarketPriceState copyWith({
    List<MarketPrice>? domesticPrices,
    List<MarketPrice>? internationalPrices,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return MarketPriceState(
      domesticPrices: domesticPrices ?? this.domesticPrices,
      internationalPrices: internationalPrices ?? this.internationalPrices,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

// ─── NOTIFIER ─────────────────────────────────────────────────

class MarketPriceNotifier extends StateNotifier<MarketPriceState> {
  Timer? _refreshTimer;

  MarketPriceNotifier() : super(const MarketPriceState(isLoading: true)) {
    fetchPrices();
    // Auto-refresh every 5 minutes
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => fetchPrices(),
    );
  }

  Future<void> fetchPrices() async {
    state = state.copyWith(isLoading: state.domesticPrices.isEmpty);

    try {
      // Fetch domestic and international in parallel
      final results = await Future.wait([
        MarketPriceService.fetchDomesticPrices(),
        MarketPriceService.fetchInternationalPrices(),
      ]);

      state = MarketPriceState(
        domesticPrices: results[0],
        internationalPrices: results[1],
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch prices: $e',
      );
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

// ─── PROVIDERS ────────────────────────────────────────────────

final marketPriceProvider =
    StateNotifierProvider<MarketPriceNotifier, MarketPriceState>((ref) {
  return MarketPriceNotifier();
});

/// Convenience providers
final domesticPricesProvider = Provider<List<MarketPrice>>((ref) {
  return ref.watch(marketPriceProvider).domesticPrices;
});

final internationalPricesProvider = Provider<List<MarketPrice>>((ref) {
  return ref.watch(marketPriceProvider).internationalPrices;
});

final allMarketPricesProvider = Provider<List<MarketPrice>>((ref) {
  return ref.watch(marketPriceProvider).allPrices;
});

final marketPriceLoadingProvider = Provider<bool>((ref) {
  return ref.watch(marketPriceProvider).isLoading;
});
