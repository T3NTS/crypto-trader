import 'package:crypto_trader/models/coin.dart';
import 'package:crypto_trader/widgets/coin_tile.dart';
import 'package:flutter/material.dart';

final _fakeCoins = [
  Coin(
    id: 'bitcoin',
    name: 'Bitcoin',
    symbol: 'btc',
    image: 'https://assets.coingecko.com/coins/images/1/large/bitcoin.png',
    currentPrice: 65000,
    priceChangePercentage24h: 2.45,
    marketCap: 1270000000000,
  ),
  Coin(
    id: 'ethereum',
    name: 'Ethereum',
    symbol: 'eth',
    image: 'https://assets.coingecko.com/coins/images/279/large/ethereum.png',
    currentPrice: 3500,
    priceChangePercentage24h: -1.20,
    marketCap: 420000000000,
  ),
  Coin(
    id: 'solana',
    name: 'Solana',
    symbol: 'sol',
    image: 'https://assets.coingecko.com/coins/images/4128/large/solana.png',
    currentPrice: 180,
    priceChangePercentage24h: 5.10,
    marketCap: 78000000000,
  ),
];

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Market')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search coins...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _fakeCoins.length,
              itemBuilder: (context, index) {
                final coin = _fakeCoins[index];
                return CoinTile(coin: coin);
              },
            ),
          ),
        ],
      ),
    );
  }
}
