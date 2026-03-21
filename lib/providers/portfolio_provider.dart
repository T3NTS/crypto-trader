import 'package:crypto_trader/models/transaction.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/holding.dart';
import '../models/coin.dart';

class PortfolioState {
  final double cashBalance;
  final List<Holding> holdings;
  final List<Transaction> transactions;
  final bool isLoading;

  const PortfolioState({
    this.cashBalance = 10000.0,
    this.holdings = const [],
    this.transactions = const [],
    this.isLoading = false,
  });

  double totalValue(Map<String, double> prices) {
    final holdingsValue = holdings.fold(
      0.0,
      (sum, h) => sum + h.currentValue(prices[h.coinId] ?? 0),
    );
    return cashBalance + holdingsValue;
  }

  double dailyPnl(Map<String, double> prices) {
    return holdings.fold(0.0, (sum, h) => sum + h.pnl(prices[h.coinId] ?? 0));
  }

  PortfolioState copyWith({
    double? cashBalance,
    List<Holding>? holdings,
    List<Transaction>? transactions,
    bool? isLoading,
  }) {
    return PortfolioState(
      cashBalance: cashBalance ?? this.cashBalance,
      holdings: holdings ?? this.holdings,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PortfolioNotifier extends StateNotifier<PortfolioState> {
  final Box _box;

  PortfolioNotifier(this._box) : super(const PortfolioState()) {
    loadPortfolio();
  }

  void loadPortfolio() {
    state = state.copyWith(isLoading: true);

    final cashBalance =
        _box.get('cashBalance', defaultValue: 10000.0) as double;

    final rawHoldings = _box.get('holdings', defaultValue: []) as List;
    final holdings = rawHoldings
        .map((e) => Holding.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final rawTransactions = _box.get('transactions', defaultValue: []) as List;
    final transactions = rawTransactions
        .map((e) => Transaction.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    state = PortfolioState(
      cashBalance: cashBalance,
      holdings: holdings,
      transactions: transactions,
      isLoading: false,
    );
  }

  Future<void> _save() async {
    await _box.put('cashBalance', state.cashBalance);
    await _box.put('holdings', state.holdings.map((h) => h.toJson()).toList());
    await _box.put(
      'transactions',
      state.transactions.map((t) => t.toJson()).toList(),
    );
  }

  Future<void> buy(Coin coin, double amount) async {
    final cost = coin.currentPrice * amount;

    if (cost > state.cashBalance) {
      throw Exception('Insufficient funds');
    }

    final existingIndex = state.holdings.indexWhere((h) => h.coinId == coin.id);
    final updatedHoldings = [...state.holdings];

    if (existingIndex >= 0) {
      final existing = updatedHoldings[existingIndex];
      final totalAmount = existing.amount + amount;
      final avgPrice =
          ((existing.amount * existing.averageBuyPrice) +
              (amount * coin.currentPrice)) /
          totalAmount;

      updatedHoldings[existingIndex] = Holding(
        coinId: existing.coinId,
        coinName: existing.coinName,
        coinSymbol: existing.coinSymbol,
        coinImage: existing.coinImage,
        amount: totalAmount,
        averageBuyPrice: avgPrice,
      );
    } else {
      updatedHoldings.add(
        Holding(
          coinId: coin.id,
          coinName: coin.name,
          coinSymbol: coin.symbol,
          coinImage: coin.image,
          amount: amount,
          averageBuyPrice: coin.currentPrice,
        ),
      );
    }

    final transaction = Transaction(
      coinId: coin.id,
      coinName: coin.name,
      coinSymbol: coin.symbol,
      amount: amount,
      priceAtTrade: coin.currentPrice,
      type: TransactionType.buy,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      cashBalance: state.cashBalance - cost,
      holdings: updatedHoldings,
      transactions: [...state.transactions, transaction],
    );

    await _save();
  }

  Future<void> sell(Coin coin, double amount) async {
    final existingIndex = state.holdings.indexWhere((h) => h.coinId == coin.id);

    if (existingIndex < 0) {
      throw Exception('No holdings for ${coin.name}');
    }

    final existing = state.holdings[existingIndex];

    if (amount > existing.amount) {
      throw Exception('Insufficient holdings');
    }

    final proceeds = coin.currentPrice * amount;
    final updatedHoldings = [...state.holdings];

    if ((existing.amount - amount) < 0.000001) {
      updatedHoldings.removeAt(existingIndex);
    } else {
      updatedHoldings[existingIndex] = Holding(
        coinId: existing.coinId,
        coinName: existing.coinName,
        coinSymbol: existing.coinSymbol,
        coinImage: existing.coinImage,
        amount: existing.amount - amount,
        averageBuyPrice: existing.averageBuyPrice,
      );
    }

    final transaction = Transaction(
      coinId: coin.id,
      coinName: coin.name,
      coinSymbol: coin.symbol,
      amount: amount,
      priceAtTrade: coin.currentPrice,
      type: TransactionType.sell,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      cashBalance: state.cashBalance + proceeds,
      holdings: updatedHoldings,
      transactions: [...state.transactions, transaction],
    );

    await _save();
  }

  Future<void> reset() async {
    state = const PortfolioState();
    await _box.clear();
  }
}

final portfolioProvider =
    StateNotifierProvider<PortfolioNotifier, PortfolioState>((ref) {
      final box = Hive.box('portfolio');
      return PortfolioNotifier(box);
    });
