import 'package:crypto_trader/providers/market_provider.dart';
import 'package:crypto_trader/widgets/coin_tile.dart';
import 'package:crypto_trader/widgets/trade_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final threshold = _scrollController.position.maxScrollExtent * 0.8;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(marketProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Market')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                ref.read(marketProvider.notifier).updateSearch(query);
              },
              decoration: InputDecoration(
                hintText: 'Search coins...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  Widget _buildBody(MarketState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Something went wrong'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.read(marketProvider.notifier).refresh(),
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    if (state.filteredCoins.isEmpty && state.searchQuery.isNotEmpty) {
      return const Center(child: Text('No coins found'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(marketProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: state.filteredCoins.length + 1,
        itemBuilder: (context, index) {
          if (index == state.filteredCoins.length) {
            if (state.isPaginating) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return const SizedBox.shrink();
          }

          final coin = state.filteredCoins[index];
          return CoinTile(
            coin: coin,
            onTap: () => showTradeModal(context, coin: coin),
          );
        },
      ),
    );
  }
}
