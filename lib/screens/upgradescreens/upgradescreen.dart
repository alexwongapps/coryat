import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/customcolor.dart';
import 'package:coryat/constants/font.dart';
import 'package:coryat/constants/iap.dart';
import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class UpgradeScreen extends StatefulWidget {
  UpgradeScreen({Key key, this.doubleCoryatString = ""}) : super(key: key);

  final String doubleCoryatString;

  @override
  _UpgradeScreenState createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  bool _restoring = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CoryatElement.cupertinoNavigationBar("Upgrade"),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  CoryatElement.cupertinoButton(
                    "Buy Double Coryat",
                    widget.doubleCoryatString ==
                                IAP.PURCHASE_SUCCESSFUL_MESSAGE ||
                            widget.doubleCoryatString ==
                                IAP.RESTORE_SUCCESSFUL_MESSAGE
                        ? null
                        : () async {
                            final bool available =
                                await InAppPurchase.instance.isAvailable();
                            if (!available) {
                              // error
                              return;
                            }
                            const Set<String> _kIds = <String>{
                              IAP.DOUBLE_CORYAT_ID
                            };
                            final ProductDetailsResponse response =
                                await InAppPurchase.instance
                                    .queryProductDetails(_kIds);
                            if (response.notFoundIDs.isNotEmpty) {
                              // error
                              return;
                            }
                            List<ProductDetails> products =
                                response.productDetails;
                            if (products.length < 1) {
                              // error
                              return;
                            }
                            final ProductDetails productDetails = products[0];
                            final PurchaseParam purchaseParam =
                                PurchaseParam(productDetails: productDetails);
                            InAppPurchase.instance
                                .buyNonConsumable(purchaseParam: purchaseParam);
                          },
                    size: Font.size_large_button,
                    color: widget.doubleCoryatString ==
                                IAP.PURCHASE_SUCCESSFUL_MESSAGE ||
                            widget.doubleCoryatString ==
                                IAP.RESTORE_SUCCESSFUL_MESSAGE
                        ? CustomColor.disabledButton
                        : CustomColor.primaryColor,
                  ),
                  Text(widget.doubleCoryatString),
                ],
              ),
              CoryatElement.text(
                  "• Unlimited games\n\n• Stats for each\n    dollar value/category\n\n• Graphs of Coryat and more\n\n• Export data\n\n• Any future Double\n    Coryat features\n\n• All for \$0.99!"),
              Column(
                children: [
                  CoryatElement.cupertinoButton(
                    "Restore",
                    _restoring
                        ? null
                        : () async {
                            setState(() {
                              _restoring = true;
                            });
                            // TODO: validate? https://pub.dev/packages/in_app_purchase
                            await InAppPurchase.instance.restorePurchases();
                          },
                    size: Font.size_large_button,
                    color: _restoring
                        ? CustomColor.disabledButton
                        : CustomColor.primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
