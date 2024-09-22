import 'package:http/http.dart' as http;
import 'dart:convert';
import 'exchange_rate.dart';

class ExchangeRateService {
  final String apiKey = '08d25510bfe37d525d234919';
  final String baseUrl = 'https://v6.exchangerate-api.com/v6';

  Future<ExchangeRate> fetchExchangeRate() async {
    final url = '$baseUrl/$apiKey/latest/USD'; // Menggunakan API Key
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ExchangeRate.fromJson(data);
    } else {
      throw Exception('Failed to load exchange rates');
    }
  }
}