import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const DOUBLE_CORYAT_KEY = "doubleCoryatPurchased";
  static const FINAL_CORYAT_KEY = "finalCoryatPurchased";
  static const PURCHASED = "purchased";
  static const NOT_PURCHASED = "notPurchased";

  static Future<void> writeIAPVariable(String key, bool purchased) async {
    final storage = new FlutterSecureStorage();
    await storage.write(
        key: key,
        value:
            purchased ? SecureStorage.PURCHASED : SecureStorage.NOT_PURCHASED);
  }
}
