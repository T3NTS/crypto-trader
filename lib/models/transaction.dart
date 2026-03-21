enum TransactionType { buy, sell }

class Transaction {
  final String coinId;
  final String coinName;
  final String coinSymbol;
  final double amount;
  final double priceAtTrade;
  final TransactionType type;
  final DateTime timestamp;

  const Transaction({
    required this.coinId,
    required this.coinName,
    required this.coinSymbol,
    required this.amount,
    required this.priceAtTrade,
    required this.type,
    required this.timestamp,
  });

  double get total => amount * priceAtTrade;

  bool get isBuy => type == TransactionType.buy;

  Map<String, dynamic> toJson() => {
    'coinId': coinId,
    'coinName': coinName,
    'coinSymbol': coinSymbol,
    'amount': amount,
    'priceAtTrade': priceAtTrade,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    coinId: json['coinId'] as String,
    coinName: json['coinName'] as String,
    coinSymbol: json['coinSymbol'] as String,
    amount: (json['amount'] as num).toDouble(),
    priceAtTrade: (json['priceAtTrade'] as num).toDouble(),
    type: TransactionType.values.byName(json['type'] as String),
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}
