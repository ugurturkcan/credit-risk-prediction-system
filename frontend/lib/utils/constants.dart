import 'package:flutter/foundation.dart'; 

class Constants {
  // ------------------------------------------------------------------
  // ⚙️ ADRES TANIMLARI
  // ------------------------------------------------------------------

  // Android Emülatörünün "Bilgisayara Ulaşma" Adresi
  static const String androidUrl = "http://10.0.2.2:8000";

  // Web (Chrome), iOS Simülatörü ve Windows için "Yerel" Adres
  static const String localhostUrl = "http://127.0.0.1:8000";

  // ------------------------------------------------------------------
  // 🚀 AKILLI SEÇİM (OTOMATİK)
  // ------------------------------------------------------------------
  
  // Mantık: "Eğer Web tarayıcısındaysak (kIsWeb) -> localhost'u kullan."
  // "Değilsek (yani Telefondaysak) -> androidUrl'yi kullan."
  
  static const String apiUrl = kIsWeb ? localhostUrl : androidUrl;
}
