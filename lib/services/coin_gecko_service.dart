import 'package:dio/dio.dart';
import '../models/coin.dart';

class CoinGeckoService {
  CoinGeckoService(this._dio);

  final Dio _dio;

  static const _perPage = 25;
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
