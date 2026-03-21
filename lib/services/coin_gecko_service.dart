import 'package:dio/dio.dart';
import '../models/coin.dart';

class CoinGeckoService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.coingecko.com/api/v3',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static const _perPage = 50;
  static const _vsCurrency = 'usd';

  Future<List<Coin>> getCoins(int page) async {
    try {
      final response = await _dio.get(
        '/coins/markets',
        queryParameters: {
          'vs_currency': _vsCurrency,
          'order': 'market_cap_desc',
          'per_page': _perPage,
          'page': page,
          'price_change_percentage': '24h',
        },
      );

      final data = response.data as List<dynamic>;
      return data.map((json) => Coin.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch coins: ${e.message}');
    }
  }
}
