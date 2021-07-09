import 'package:coryat/constants/securestorage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class IAP {
  static const String DOUBLE_CORYAT_ID = "com.alexwongapps.Coryat.doublecoryat";
  static Future<bool> doubleCoryatPurchased() async {
    final storage = new FlutterSecureStorage();
    String value = await storage.read(key: SecureStorage.DOUBLE_CORYAT_KEY);
    if (value == null) {
      return false;
    }
    if (value != SecureStorage.PURCHASED) {
      return false;
    }
    return true;
  }
}
