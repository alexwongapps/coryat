import 'package:coryat/constants/coryatelement.dart';
import 'package:coryat/constants/customcolor.dart';
import 'package:coryat/constants/font.dart';
import 'package:coryat/constants/iap.dart';
import 'package:coryat/constants/securestorage.dart';
import 'package:coryat/data/firebase.dart';
import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class UpgradeScreen extends StatefulWidget {
  UpgradeScreen(
      {Key? key, this.doubleCoryatString = "", required this.onUpgradeSelected})
      : super(key: key);

  final String doubleCoryatString;
  final VoidCallback onUpgradeSelected;

  @override
  _UpgradeScreenState createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  bool _restoring = false;
  bool _doubleCoryatCoded = false;
  bool _finalCoryatCoded = false;

  TextEditingController _codeTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => onload(context));
    super.initState();
  }

  Future<void> onload(BuildContext context) async {
    bool dc = await IAP.doubleCoryatPurchased();
    if (_successfulPurchase() || dc) {
      Navigator.of(context).pop();
      widget.onUpgradeSelected();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
        navigationBar: CoryatElement.cupertinoNavigationBar("Upgrade"),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  CoryatElement.cupertinoButton(
                    "Buy Double Coryat",
                    _successfulPurchase()
                        ? () {}
                        : () async {
                            final bool available =
                                await InAppPurchase.instance.isAvailable();
                            if (!available) {
                              // error
                              setState(() {
                                CoryatElement.presentBasicAlertDialog(
                                    context, "Error", "Unable to access IAPs");
                              });
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
                              setState(() {
                                CoryatElement.presentBasicAlertDialog(
                                    context, "Error", "Unable to find IAPs");
                              });
                              return;
                            }
                            List<ProductDetails> products =
                                response.productDetails;
                            if (products.length < 1) {
                              // error
                              setState(() {
                                CoryatElement.presentBasicAlertDialog(
                                    context, "Error", "Unable to find IAPs");
                              });
                              return;
                            }
                            final ProductDetails productDetails = products[0];
                            final PurchaseParam purchaseParam =
                                PurchaseParam(productDetails: productDetails);
                            InAppPurchase.instance
                                .buyNonConsumable(purchaseParam: purchaseParam);
                          },
                    size: Font.size_large_button,
                    color: _successfulPurchase()
                        ? CustomColor.disabledButton
                        : CustomColor.primaryColor,
                  ),
                  Text(widget.doubleCoryatString),
                ],
              ),
              CoryatElement.text("• Store unlimited games\n    (currently: " +
                  IAP.FREE_NUMBER_OF_GAMES.toString() +
                  " games)\n\n• Stats for each\n    dollar value/category\n\n• Graphs of Coryat and more\n\n• Export games\n\n• Any future Double\n    Coryat features\n\n• All for \$0.99!"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CoryatElement.cupertinoButton(
                    "Restore",
                    _restoring
                        ? () {}
                        : () async {
                            setState(() {
                              _restoring = true;
                            });
                            await InAppPurchase.instance
                                .restorePurchases()
                                .catchError((error) {
                              setState(() {
                                _restoring = false;
                                CoryatElement.presentBasicAlertDialog(
                                    context, "Error", "Unable to access IAPs");
                              });
                            });
                          },
                    color: _restoring
                        ? CustomColor.disabledButton
                        : CustomColor.primaryColor,
                  ),
                  CoryatElement.cupertinoButton("Code?", () {
                    _codeTextController.text = "";
                    Widget backButton = CoryatElement.cupertinoButton(
                      "Cancel",
                      () {
                        Navigator.of(context).pop();
                      },
                      color: CupertinoColors.destructiveRed,
                    );
                    Widget doneButton = CoryatElement.cupertinoButton(
                      "Done",
                      () async {
                        if (_codeTextController.text == "") {
                          return;
                        }
                        Navigator.of(context).pop();
                        Map<String, bool> map =
                            await Firebase.redeemCode(_codeTextController.text);
                        setState(() {
                          _doubleCoryatCoded =
                              map[Firebase.DOUBLE_CORYAT_FIELD] ?? false;
                          _finalCoryatCoded =
                              map[Firebase.FINAL_CORYAT_FIELD] ?? false;
                        });
                        if (_doubleCoryatCoded) {
                          await SecureStorage.writeIAPVariable(
                              SecureStorage.DOUBLE_CORYAT_KEY, true);
                        }
                        if (_finalCoryatCoded) {
                          await SecureStorage.writeIAPVariable(
                              SecureStorage.FINAL_CORYAT_KEY, true);
                        }
                        if (_doubleCoryatCoded || _finalCoryatCoded) {
                          CoryatElement.presentBasicAlertDialog(
                              context,
                              "Code Redeemed!",
                              "Redeemed:" +
                                  (_doubleCoryatCoded
                                      ? "\nDouble Coryat"
                                      : "") +
                                  (_finalCoryatCoded ? "\Final Coryat" : ""),
                              onPressed: () {
                            Navigator.of(context).pop();
                            widget.onUpgradeSelected();
                          });
                        } else {
                          CoryatElement.presentBasicAlertDialog(
                              context,
                              "Unable to redeem code",
                              "Make sure you entered the code correctly");
                        }
                      },
                    );

                    CupertinoAlertDialog alert = CupertinoAlertDialog(
                      title: Text("Enter Code"),
                      content: Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: CupertinoTextField(
                          controller: _codeTextController,
                          placeholder: "Code",
                          autofocus: true,
                        ),
                      ),
                      actions: [
                        backButton,
                        doneButton,
                      ],
                    );

                    showCupertinoDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      },
                    );
                  }),
                  CoryatElement.cupertinoButton("Back", () {
                    Navigator.of(context).pop();
                  }),
                ],
              ),
            ],
          ),
        ));
  }

  bool _successfulPurchase() {
    return widget.doubleCoryatString == IAP.PURCHASE_SUCCESSFUL_MESSAGE ||
        widget.doubleCoryatString == IAP.RESTORE_SUCCESSFUL_MESSAGE ||
        _doubleCoryatCoded;
  }
}
