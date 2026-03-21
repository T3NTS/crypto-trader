import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/coin.dart';

class CoinTile extends StatelessWidget {
  final Coin coin;
  final VoidCallback? onTap;

  const CoinTile({super.key, required this.coin, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPositive = coin.priceChangePercentage24h >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;
    final changePrefix = isPositive ? '+' : '';

    return ListTile(
      onTap: onTap,
      leading: CachedNetworkImage(
        imageUrl: coin.image,
        width: 40,
        height: 40,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) =>
            const Icon(Icons.currency_bitcoin),
      ),
      title: Text(coin.name, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        coin.symbol.toUpperCase(),
        style: TextStyle(color: Colors.grey),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${coin.currentPrice.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            '$changePrefix${coin.priceChangePercentage24h.toStringAsFixed(2)}%',
            style: TextStyle(color: changeColor, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
