import 'dart:async';

import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/customcolor.dart';
import 'package:coryat/constants/securestorage.dart';
import 'package:coryat/data/sqlitepersistence.dart';
import 'package:coryat/screens/homescreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'constants/font.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await SqlitePersistence.init();
  if (defaultTargetPlatform == TargetPlatform.android) {
    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<List<PurchaseDetails>> _subscription;

  @override
  void initState() {
    final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Coryat',
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(
                fontFamily: Font.family,
                fontSize: Font.size_default,
                color: CupertinoColors.black)),
        barBackgroundColor: CustomColor.backgroundColor,
        scaffoldBackgroundColor: CustomColor.backgroundColor,
        primaryColor: CustomColor.primaryColor,
      ),
      localizationsDelegates: [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      home: HomeScreen(title: 'Coryat'),
    );
  }

  // IAP
  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // TODO: pending UI
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          CoryatElement.presentBasicAlertDialog(
              context,
              "Unable to complete purchase",
              "There was an error with your purchase. Please try again.");
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            _deliverProduct(purchaseDetails);
          } else {
            CoryatElement.presentBasicAlertDialog(context, "Invalid purchase",
                "The purchase was unsuccessful. Please try again.");
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    });
  }

  void _deliverProduct(PurchaseDetails purchaseDetails) async {
    final storage = new FlutterSecureStorage();
    await storage.write(
        key: SecureStorage.DOUBLE_CORYAT_KEY, value: SecureStorage.PURCHASED);
    CoryatElement.presentBasicAlertDialog(context, "Purchase successful",
        "Congratulations! Return to the home screen to use your new features.");
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // TODO
    return true;
  }
}
