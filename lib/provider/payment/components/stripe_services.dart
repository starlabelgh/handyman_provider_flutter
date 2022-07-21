import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/provider_subscription_model.dart';
import 'package:handyman_provider_flutter/models/stripe_pay_model.dart';
import 'package:handyman_provider_flutter/networks/network_utils.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';

class StripeServices {
  ProviderSubscriptionModel? data;
  num totalAmount = 0;
  String stripeURL = "";
  String stripePaymentKey = "";

  init({required String stripePaymentPublishKey, ProviderSubscriptionModel? data, required num totalAmount, required String stripeURL, required String stripePaymentKey}) async {
    Stripe.publishableKey = stripePaymentPublishKey;
    Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';

    /// You can enter AnyName

    await Stripe.instance.applySettings().catchError((e) {
      return e;
    });

    this.totalAmount = totalAmount;
    this.stripeURL = stripeURL;
    this.stripePaymentKey = stripePaymentKey;
  }

  //StripPayment
  void stripePay(ProviderSubscriptionModel? data, {VoidCallback? onPaymentComplete}) async {
    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: 'Bearer $stripePaymentKey',
      HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
    };

    var request = http.Request('POST', Uri.parse(stripeURL));

    request.bodyFields = {
      'amount': '${(totalAmount.toInt() * 100)}',

      ///TODO: UnComment Currency Code..
      'currency': '${appStore.currencyCode}',
      // 'currency': 'INR',
    };

    log(request.bodyFields);
    request.headers.addAll(headers);

    appStore.setLoading(true);

    await request.send().then((value) {
      appStore.setLoading(false);
      http.Response.fromStream(value).then((response) async {
        if (response.statusCode == 200) {
          StripePayModel res = StripePayModel.fromJson(await handleResponse(response));

          await Stripe.instance
              .initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: res.clientSecret.validate(),
              style: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              applePay: isIOS,
              googlePay: isMobile,
              testEnv: true,
              // merchantCountryCode: 'IN',
              merchantDisplayName: APP_NAME,
              customerId: appStore.userId.toString(),
              customerEphemeralKeySecret: res.clientSecret.validate(),
              setupIntentClientSecret: res.clientSecret.validate(),
            ),
          )
              .catchError((e) {
            log(e.toString());
          });
          log("e");
          await Stripe.instance.presentPaymentSheet().then(
            (value) async {
              savePayment(data: data, paymentMethod: PAYMENT_METHOD_STRIPE, paymentStatus: SERVICE_PAYMENT_STATUS_PAID);
              onPaymentComplete?.call();
            },
          ).catchError((e) {
            log("presentPaymentSheet ${e.toString()}");
          });
        } else if (response.statusCode == 400) {
          toast("Testing Credential cannot pay more then 500");
        }
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString(), print: true);
      });
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }
}

StripeServices stripeServices = StripeServices();
