import 'package:crypto_trader/models/coin.dart';
import 'package:crypto_trader/widgets/holding_tile.dart';
import 'package:crypto_trader/widgets/trade_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/portfolio_provider.dart';
import '../../providers/market_provider.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolio = ref.watch(portfolioProvider);
    final market = ref.watch(marketProvider);

    final prices = {
      for (final coin in market.coins) coin.id: coin.currentPrice,
    };

    final totalValue = portfolio.totalValue(prices);
    final dailyPnl = portfolio.dailyPnl(prices);
    final dailyPnlPercentage = totalValue > 0
        ? (dailyPnl / totalValue) * 100
        : 0.0;

    if (portfolio.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _confirmReset(context, ref),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildSummaryCard(
              totalValue: totalValue,
              dailyPnl: dailyPnl,
              dailyPnlPercentage: dailyPnlPercentage,
              cashBalance: portfolio.cashBalance,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'My Positions',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (portfolio.holdings.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No positions yet. Head to the Market to buy your first coin.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final holding = portfolio.holdings[index];
                final currentPrice = prices[holding.coinId] ?? 0;
                return HoldingTile(
                  holding: holding,
                  currentPrice: currentPrice,
                  onTap: () => showTradeModal(
                    context,
                    coin: Coin(
                      id: holding.coinId,
                      name: holding.coinName,
                      symbol: holding.coinSymbol,
                      image: holding.coinImage,
                      currentPrice: currentPrice,
                      priceChangePercentage24h: 0,
                      marketCap: 0,
                    ),
                    existingHolding: holding,
                  ),
                );
              }, childCount: portfolio.holdings.length),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required double totalValue,
    required double dailyPnl,
    required double dailyPnlPercentage,
    required double cashBalance,
  }) {
    final isPositive = dailyPnl >= 0;
    final pnlColor = isPositive ? Colors.green : Colors.red;
    final pnlPrefix = isPositive ? '+' : '';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Value',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${totalValue.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '$pnlPrefix${dailyPnlPercentage.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: pnlColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'Daily P&L',
                  value: '$pnlPrefix\$${dailyPnl.toStringAsFixed(2)}',
                  valueColor: pnlColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  label: 'Available Cash',
                  value: '\$${cashBalance.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Portfolio'),
        content: const Text(
          'This will reset your balance to \$10,000 and clear all positions. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(portfolioProvider.notifier).reset();
              Navigator.pop(context);
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
