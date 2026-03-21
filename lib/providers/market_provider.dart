import 'package:crypto_trader/services/coin_gecko_service.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/coin.dart';

class MarketState {
  final List<Coin> coins;
  final bool isLoading;
  final bool isPaginating;
  final bool hasError;
  final bool hasMore;
  final int currentPage;
  final String searchQuery;

  const MarketState({
    this.coins = const [],
    this.isLoading = false,
    this.isPaginating = false,
    this.hasError = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.searchQuery = '',
  });

  MarketState copyWith({
    List<Coin>? coins,
    bool? isLoading,
    bool? isPaginating,
    bool? hasError,
    bool? hasMore,
    int? currentPage,
    String? searchQuery,
  }) {
    return MarketState(
      coins: coins ?? this.coins,
      isLoading: isLoading ?? this.isLoading,
      isPaginating: isPaginating ?? this.isPaginating,
      hasError: hasError ?? this.hasError,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<Coin> get filteredCoins {
    if (searchQuery.isEmpty) return coins;
    return coins
        .where(
          (coin) =>
              coin.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              coin.symbol.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }
}

class MarketNotifier extends StateNotifier<MarketState> {
  final CoinGeckoService _service;

  MarketNotifier(this._service) : super(const MarketState()) {
    fetchInitial();
  }

  Future<void> fetchInitial() async {
    if (state.coins.isNotEmpty) return;

    state = state.copyWith(isLoading: true, hasError: false);

    try {
      final coins = await _service.getCoins(1);
      state = state.copyWith(
        coins: coins,
        isLoading: false,
        currentPage: 1,
        hasMore: coins.length == 25,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, hasError: true);
    }
  }

  Future<void> loadMore() async {
    if (state.isPaginating) return;
    if (!state.hasMore) return;
    if (state.currentPage >= 10) return;
    if (state.searchQuery.isNotEmpty) return;

    state = state.copyWith(isPaginating: true);

    try {
      final nextPage = state.currentPage + 1;
      final newCoins = await _service.getCoins(nextPage);

      state = state.copyWith(
        coins: [...state.coins, ...newCoins],
        isPaginating: false,
        currentPage: nextPage,
        hasMore: newCoins.length == 25,
      );
    } catch (e) {
      state = state.copyWith(isPaginating: false, hasError: true);
    }
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> refresh() async {
    state = const MarketState();
    await fetchInitial();
  }
}

final marketProvider = StateNotifierProvider<MarketNotifier, MarketState>((
  ref,
) {
  return MarketNotifier(CoinGeckoService());
});
