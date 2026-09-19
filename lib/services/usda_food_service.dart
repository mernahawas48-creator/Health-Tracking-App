import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meditrack/config/nutrition_api_config.dart';
import 'package:meditrack/models/nutrition_food.dart';

class UsdaFoodService {
  UsdaFoodService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;
  static const _baseUrl = 'https://api.nal.usda.gov/fdc/v1/foods/search';

  Future<List<NutritionFood>> search(String query) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl?api_key=${NutritionApiConfig.usdaApiKey}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query, 'pageSize': 20}),
    );
    if (response.statusCode != 200)
      throw Exception('Food search failed. Please try again.');
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['foods'] as List? ?? [])
        .map((item) => NutritionFood.fromUsdaJson(item as Map<String, dynamic>))
        .toList();
  }
}
