import 'package:crypto_trader/widgets/holding_tile.dart';
import 'package:flutter/material.dart';
import '../../models/holding.dart';

final _fakeHoldings = [
  Holding(
    coinId: 'bitcoin',
    coinName: 'Bitcoin',
    coinSymbol: 'BTC',
    coinImage: 'https://assets.coingecko.com/coins/images/1/large/bitcoin.png',
    amount: 0.05,
    averageBuyPrice: 60000,
  ),
  Holding(
    coinId: 'ethereum',
    coinName: 'Ethereum',
    coinSymbol: 'ETH',
    coinImage:
        'https://assets.coingecko.com/coins/images/279/large/ethereum.png',
    amount: 1.2,
    averageBuyPrice: 3800,
  ),
];

const _fakeCashBalance = 3200.0;
const _fakeDailyPnl = 432.50;

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fakePrices = {'bitcoin': 65000.0, 'ethereum': 3500.0};

    final holdingsValue = _fakeHoldings.fold(
      0.0,
      (sum, h) => sum + h.currentValue(fakePrices[h.coinId] ?? 0),
    );

    final totalValue = holdingsValue + _fakeCashBalance;

    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio')),
      body: _buildPortfolio(context, totalValue, fakePrices),
    );
  }

  Widget _buildPortfolio(
    BuildContext context,
    double totalValue,
    Map<String, double> prices,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildSummaryCard(totalValue)),

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

        if (_fakeHoldings.isEmpty)
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
              final holding = _fakeHoldings[index];
              final currentPrice = prices[holding.coinId] ?? 0;
              return HoldingTile(
                holding: holding,
                currentPrice: currentPrice,
                onTap: () {},
              );
            }, childCount: _fakeHoldings.length),
          ),
      ],
    );
  }

  Widget _buildSummaryCard(double totalValue) {
    final isPositive = _fakeDailyPnl >= 0;
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
          Text(
            '\$${totalValue.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'Daily P&L',
                  value: '$pnlPrefix\$${_fakeDailyPnl.toStringAsFixed(2)}',
                  valueColor: pnlColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  label: 'Available Cash',
                  value: '\$${_fakeCashBalance.toStringAsFixed(2)}',
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
}
