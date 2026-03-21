class Holding {
  final String coinId;
  final String coinName;
  final String coinSymbol;
  final String coinImage;
  final double amount;
  final double averageBuyPrice;

  const Holding({
    required this.coinId,
    required this.coinName,
    required this.coinSymbol,
    required this.coinImage,
    required this.amount,
    required this.averageBuyPrice,
  });

  double currentValue(double currentPrice) => amount * currentPrice;
  double pnl(double currentPrice) => (currentPrice - averageBuyPrice) * amount;
  double pnlPercentage(double currentPrice) =>
      ((currentPrice - averageBuyPrice) / averageBuyPrice) * 100;

  Map<String, dynamic> toJson() => {
    'coinId': coinId,
    'coinName': coinName,
    'coinSymbol': coinSymbol,
    'coinImage': coinImage,
    'amount': amount,
    'averageBuyPrice': averageBuyPrice,
  };

  factory Holding.fromJson(Map<String, dynamic> json) => Holding(
    coinId: json['coinId'] as String,
    coinName: json['coinName'] as String,
    coinSymbol: json['coinSymbol'] as String,
    coinImage: json['coinImage'] as String,
    amount: (json['amount'] as num).toDouble(),
    averageBuyPrice: (json['averageBuyPrice'] as num).toDouble(),
  );
}
