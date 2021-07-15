import 'package:coryat/constants/securestorage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class IAP {
  static const String DOUBLE_CORYAT_ID = "com.alexwongapps.coryat.doublecoryat";
  static const String FINAL_CORYAT_ID = "com.alexwongapps.coryat.finalcoryat";
  static const int FREE_NUMBER_OF_GAMES = 5; // TODO: change
  static const String PURCHASE_SUCCESSFUL_MESSAGE = "Purchase Successful!";
  static const String RESTORE_SUCCESSFUL_MESSAGE = "Restore Successful!";

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

  static Future<bool> finalCoryatPurchased() async {
    final storage = new FlutterSecureStorage();
    String value = await storage.read(key: SecureStorage.FINAL_CORYAT_KEY);
    if (value == null) {
      return false;
    }
    if (value != SecureStorage.PURCHASED) {
      return false;
    }
    return true;
  }
}
