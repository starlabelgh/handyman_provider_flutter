import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutterwave_standard/core/TransactionCallBack.dart';
import 'package:flutterwave_standard/core/navigation_controller.dart';
import 'package:flutterwave_standard/models/requests/customer.dart' as c;
import 'package:flutterwave_standard/models/requests/customizations.dart';
import 'package:flutterwave_standard/models/requests/standard_request.dart';
import 'package:flutterwave_standard/view/flutterwave_style.dart';
import 'package:flutterwave_standard/view/view_utils.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/dashboard_response.dart';
import 'package:handyman_provider_flutter/models/provider_subscription_model.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/payment/components/razor_pay_services.dart';
import 'package:handyman_provider_flutter/provider/payment/components/stripe_services.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';

class PaymentScreen extends StatefulWidget {
  final ProviderSubscriptionModel selectedPricingPlan;

  const PaymentScreen(this.selectedPricingPlan);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> implements TransactionCallBack {
  RazorPayServices razorPayServices = RazorPayServices();
  List<PaymentSetting> paymentList = [];

  PaymentSetting? currentTimeValue;

  bool isDisabled = false;
  bool isPaymentProcessing = false;

  late NavigationController controller;

  num totalAmount = 0;
  num price = 0;

  String flutterWavePublicKey = "";

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    paymentList = PaymentSetting.decode(getStringAsync(PAYMENT_LIST));
    paymentList.removeWhere((element) => element.type == PAYMENT_METHOD_COD);
    if (paymentList.isNotEmpty) {
      currentTimeValue = paymentList.first;
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void _handleClick() async {
    if (isPaymentProcessing) return;
    isPaymentProcessing = false;

    if (currentTimeValue!.type == PAYMENT_METHOD_STRIPE) {
      if (currentTimeValue!.isTest == 1) {
        await stripeServices.init(
            data: widget.selectedPricingPlan,
            stripePaymentPublishKey: currentTimeValue!.testValue!.stripePublickey.validate(),
            totalAmount: widget.selectedPricingPlan.amount.validate(),
            stripeURL: currentTimeValue!.testValue!.stripeUrl.validate(),
            stripePaymentKey: currentTimeValue!.testValue!.stripeKey.validate());
        await 1.seconds.delay;
        stripeServices.stripePay(widget.selectedPricingPlan, onPaymentComplete: () {
          isPaymentProcessing = false;
        });
      } else {
        await stripeServices.init(
            data: widget.selectedPricingPlan,
            stripePaymentPublishKey: currentTimeValue!.liveValue!.stripePublickey.validate(),
            totalAmount: widget.selectedPricingPlan.amount.validate(),
            stripeURL: currentTimeValue!.liveValue!.stripeUrl.validate(),
            stripePaymentKey: currentTimeValue!.liveValue!.stripeKey.validate());
        await 1.seconds.delay;
        stripeServices.stripePay(widget.selectedPricingPlan, onPaymentComplete: () {
          isPaymentProcessing = false;
        });
      }
    } else if (currentTimeValue!.type == PAYMENT_METHOD_RAZOR) {
      if (currentTimeValue!.isTest == 1) {
        appStore.setLoading(true);
        razorPayServices.init(razorKey: currentTimeValue!.testValue!.razorKey!, data: widget.selectedPricingPlan);
        await 1.seconds.delay;
        appStore.setLoading(false);
        razorPayServices.razorPayCheckout(widget.selectedPricingPlan.amount.validate());
      } else {
        appStore.setLoading(true);
        razorPayServices.init(razorKey: currentTimeValue!.liveValue!.razorKey!, data: widget.selectedPricingPlan);
        await 1.seconds.delay;
        appStore.setLoading(false);
        razorPayServices.razorPayCheckout(widget.selectedPricingPlan.amount.validate());
      }
    } else if (currentTimeValue!.type == PAYMENT_METHOD_FLUTTER_WAVE) {
      if (currentTimeValue!.isTest == 1) {
        appStore.setLoading(true);
        flutterWaveCheckout(flutterWavePublicKeys: currentTimeValue!.testValue!.flutterwavePublic.validate());
        await 1.seconds.delay;
        appStore.setLoading(false);
      } else {
        appStore.setLoading(true);
        flutterWaveCheckout(flutterWavePublicKeys: currentTimeValue!.liveValue!.flutterwavePublic.validate());
        await 1.seconds.delay;
        appStore.setLoading(false);
      }
    }
  }

  @override
  onTransactionError() {
    toast("Transaction error");
    snackBar(context, title: errorMessage);
  }

  @override
  onCancelled() {
    toast("Transaction Cancelled");
  }

  void _toggleButtonActive(final bool shouldEnable) {
    setState(() {
      isDisabled = !shouldEnable;
    });
  }

  void flutterWaveCheckout({required String flutterWavePublicKeys}) {
    isPaymentProcessing = false;
    flutterWavePublicKey = flutterWavePublicKeys;

    if (isDisabled) return;
    _showConfirmDialog();
  }

  final style = FlutterwaveStyle(
      appBarText: "My Standard Blue",
      buttonColor: Color(0xffd0ebff),
      appBarIcon: Icon(Icons.message, color: Color(0xffd0ebff)),
      buttonTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      appBarColor: Color(0xffd0ebff),
      dialogCancelTextStyle: TextStyle(color: Colors.redAccent, fontSize: 18),
      dialogContinueTextStyle: TextStyle(color: Colors.blue, fontSize: 18));

  void _showConfirmDialog() {
    FlutterwaveViewUtils.showConfirmPaymentModal(
      context,
      getStringAsync(CURRENCY_COUNTRY_CODE),
      widget.selectedPricingPlan.amount.validate().toString(),
      style.getMainTextStyle(),
      style.getDialogBackgroundColor(),
      style.getDialogCancelTextStyle(),
      style.getDialogContinueTextStyle(),
      _handlePayment,
    );
  }

  void _handlePayment() async {
    final c.Customer customer = c.Customer(
      name: appStore.userName,
      phoneNumber: appStore.userContactNumber,
      email: appStore.userEmail,
    );

    final request = StandardRequest(
      txRef: DateTime.now().millisecond.toString(),
      amount: widget.selectedPricingPlan.amount.validate().toString(),
      customer: customer,
      paymentOptions: "card, payattitude",
      customization: Customization(title: "Test Payment"),
      isTestMode: true,
      publicKey: flutterWavePublicKey,
      currency: getStringAsync(CURRENCY_COUNTRY_CODE),
      redirectUrl: "https://www.google.com",
    );

    try {
      Navigator.of(context).pop(); // to remove confirmation dialog
      _toggleButtonActive(false);
      controller.startTransaction(request);
      _toggleButtonActive(true);
    } catch (error) {
      _toggleButtonActive(true);

      toast(error.toString());
    }
  }

  @override
  onTransactionSuccess(String id, String txRef) {
    isPaymentProcessing = false;
    savePayment(data: widget.selectedPricingPlan, paymentMethod: PAYMENT_METHOD_FLUTTER_WAVE, paymentStatus: SERVICE_PAYMENT_STATUS_PAID);
    toast("Payment Successfully done");
  }

  @override
  Widget build(BuildContext context) {
    controller = NavigationController(Client(), style, this);

    return Scaffold(
      appBar: appBarWidget(context.translate.lblPayment, color: context.primaryColor, textColor: Colors.white, backWidget: BackWidget()),
      body: Stack(
        children: [
          if (paymentList.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.height,
                Text(context.translate.lblChoosePaymentMethod, style: boldTextStyle(size: 18)).paddingOnly(left: 16),
                16.height,
                ListView.builder(
                  itemCount: paymentList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    PaymentSetting value = paymentList[index];
                    return RadioListTile<PaymentSetting>(
                      dense: true,
                      activeColor: primaryColor,
                      value: value,
                      controlAffinity: ListTileControlAffinity.trailing,
                      groupValue: currentTimeValue,
                      onChanged: (PaymentSetting? ind) {
                        currentTimeValue = ind;
                        setState(() {});
                      },
                      title: Text(value.title.validate(), style: primaryTextStyle()),
                    );
                  },
                ),
                Spacer(),
                AppButton(
                  onTap: () {
                    if (currentTimeValue!.type == PAYMENT_METHOD_COD) {
                      showConfirmDialogCustom(
                        context,
                        dialogType: DialogType.CONFIRMATION,
                        title: "${context.translate.lblPayWith} ${currentTimeValue!.title.validate()}",
                        primaryColor: primaryColor,
                        onAccept: (p0) {
                          _handleClick();
                        },
                      );
                    } else {
                      _handleClick();
                    }
                  },
                  text: context.translate.lblProceed,
                  color: context.primaryColor,
                  width: context.width(),
                ).paddingAll(16),
              ],
            ),
          if (paymentList.isEmpty)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(notDataFoundImg, height: 150),
                16.height,
                Text(context.translate.lblNoPayments, style: boldTextStyle()).center(),
              ],
            ),
          Observer(builder: (context) => LoaderWidget().center().visible(appStore.isLoading))
        ],
      ),
    );
  }
}
