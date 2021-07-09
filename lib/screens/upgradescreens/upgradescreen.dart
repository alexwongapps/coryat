import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/iap.dart';
import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class UpgradeScreen extends StatefulWidget {
  @override
  _UpgradeScreenState createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CoryatElement.cupertinoNavigationBar("Upgrade"),
        child: Center(
          child: Column(
            children: [
              CoryatElement.cupertinoButton("Purchase Double Coryat", () async {
                final bool available =
                    await InAppPurchase.instance.isAvailable();
                if (!available) {
                  CoryatElement.presentBasicAlertDialog(
                      context,
                      "Store unavailable",
                      "Unable to reach the in-app purchase store. Please try again.");
                  return;
                }
                const Set<String> _kIds = <String>{IAP.DOUBLE_CORYAT_ID};
                final ProductDetailsResponse response =
                    await InAppPurchase.instance.queryProductDetails(_kIds);
                if (response.notFoundIDs.isNotEmpty) {
                  CoryatElement.presentBasicAlertDialog(
                      context,
                      "Error loading IAPs",
                      "Unable to load in-app purchases. Please try again.");
                  return;
                }
                List<ProductDetails> products = response.productDetails;
                if (products.length < 1) {
                  CoryatElement.presentBasicAlertDialog(
                      context,
                      "Error loading IAPs",
                      "Unable to load in-app purchase details. Please try again.");
                  return;
                }
                final ProductDetails productDetails = products[0];
                final PurchaseParam purchaseParam =
                    PurchaseParam(productDetails: productDetails);
                InAppPurchase.instance
                    .buyNonConsumable(purchaseParam: purchaseParam);
              }),
              CoryatElement.cupertinoButton("Restore", () async {
                // TODO: validate? https://pub.dev/packages/in_app_purchase
                await InAppPurchase.instance.restorePurchases();
              }),
            ],
          ),
        ));
  }
}
