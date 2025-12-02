import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/risk_models.dart';

class ApiService {
  
  // Statik fonksiyon: Her yerden ApiService.predictRisk(...) diye çağırabiliriz.
  static Future<RiskResponse> predictRisk(RiskRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/predict'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return RiskResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Sunucu Hatası: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Bağlantı Hatası: $e");
    }
  }
}