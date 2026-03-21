import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/holding.dart';

class HoldingTile extends StatelessWidget {
  final Holding holding;
  final double currentPrice;
  final VoidCallback onTap;

  const HoldingTile({
    super.key,
    required this.holding,
    required this.currentPrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pnl = holding.pnl(currentPrice);
    final pnlPct = holding.pnlPercentage(currentPrice);
    final isPositive = pnl >= 0;
    final pnlColor = isPositive ? Colors.green : Colors.red;
    final pnlPrefix = isPositive ? '+' : '';

    return ListTile(
      onTap: onTap,
      leading: CachedNetworkImage(
        imageUrl: holding.coinImage,
        width: 40,
        height: 40,
        placeholder: (context, url) => const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (context, url, error) =>
            const Icon(Icons.currency_bitcoin),
      ),
      title: Text(
        holding.coinName,
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${holding.amount.toStringAsFixed(5)} ${holding.coinSymbol.toUpperCase()}',
        style: TextStyle(color: Colors.grey),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${holding.currentValue(currentPrice).toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            '$pnlPrefix${pnlPct.toStringAsFixed(2)}%',
            style: TextStyle(color: pnlColor, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
