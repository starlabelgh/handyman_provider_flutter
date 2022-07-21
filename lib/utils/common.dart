import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom_tabs;
import 'package:geocoding/geocoding.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/html_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/booking_detail_response.dart';
import 'package:handyman_provider_flutter/models/booking_list_response.dart';
import 'package:handyman_provider_flutter/models/dashboard_response.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

//region App Default Settings
void defaultSettings() {
  passwordLengthGlobal = 6;
  appButtonBackgroundColorGlobal = primaryColor;
  defaultRadius = 12;
  defaultAppButtonTextColorGlobal = Colors.white;
  defaultElevation = 0;
  defaultBlurRadius = 0;
  defaultSpreadRadius = 0;
}
//endregion

//region Set User Values when user is logged In
Future<void> setLoginValues() async {
  if (appStore.isLoggedIn) {
    await appStore.setUserId(getIntAsync(USER_ID), isInitializing: true);
    await appStore.setFirstName(getStringAsync(FIRST_NAME), isInitializing: true);
    await appStore.setLastName(getStringAsync(LAST_NAME), isInitializing: true);
    await appStore.setUserEmail(getStringAsync(USER_EMAIL), isInitializing: true);
    await appStore.setUserName(getStringAsync(USERNAME), isInitializing: true);
    await appStore.setContactNumber(getStringAsync(CONTACT_NUMBER), isInitializing: true);
    await appStore.setUserProfile(getStringAsync(PROFILE_IMAGE), isInitializing: true);
    await appStore.setCountryId(getIntAsync(COUNTRY_ID), isInitializing: true);
    await appStore.setStateId(getIntAsync(STATE_ID), isInitializing: true);
    await appStore.setUId(getStringAsync(UID), isInitializing: true);
    await appStore.setCityId(getIntAsync(CITY_ID), isInitializing: true);
    await appStore.setUserType(getStringAsync(USER_TYPE), isInitializing: true);
    await appStore.setServiceAddressId(getIntAsync(SERVICE_ADDRESS_ID), isInitializing: true);
    await appStore.setProviderId(getIntAsync(PROVIDER_ID), isInitializing: true);

    await appStore.setCurrencyCode(getStringAsync(CURRENCY_COUNTRY_CODE), isInitializing: true);
    await appStore.setCurrencyCountryId(getStringAsync(CURRENCY_COUNTRY_ID), isInitializing: true);
    await appStore.setCurrencySymbol(getStringAsync(CURRENCY_COUNTRY_SYMBOL), isInitializing: true);
    await appStore.setCreatedAt(getStringAsync(CREATED_AT), isInitializing: true);
    await appStore.setTotalBooking(getIntAsync(TOTAL_BOOKING), isInitializing: true);

    await appStore.setToken(getStringAsync(TOKEN), isInitializing: true);

    await appStore.setTester(getBoolAsync(IS_TESTER), isInitializing: true);
    await appStore.setPrivacyPolicy(getStringAsync(PRIVACY_POLICY), isInitializing: true);
    await appStore.setTermConditions(getStringAsync(TERM_CONDITIONS), isInitializing: true);
    await appStore.setInquiryEmail(getStringAsync(INQUIRY_EMAIL), isInitializing: true);
    await appStore.setHelplineNumber(getStringAsync(HELPLINE_NUMBER), isInitializing: true);
    await setSaveSubscription();
  }
}

Future<void> setSaveSubscription({int? isSubscribe, String? title, String? identifier, String? endAt}) async {
  await appStore.setPlanTitle(title ?? getStringAsync(PLAN_TITLE), isInitializing: title == null);
  await appStore.setIdentifier(identifier ?? getStringAsync(PLAN_IDENTIFIER), isInitializing: identifier == null);
  await appStore.setPlanEndDate(endAt ?? getStringAsync(PLAN_END_DATE), isInitializing: endAt == null);
  await appStore.setPlanSubscribeStatus(isSubscribe.validate() == 1, isInitializing: isSubscribe == null);
}

//endregion

//region OneSignal Setup
setOneSignal() async {
  OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

  await OneSignal.shared.setAppId(ONESIGNAL_APP_ID).then((value) {
    OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
      print("Accepted permission: $accepted");
    });

    OneSignal.shared.setNotificationWillShowInForegroundHandler((OSNotificationReceivedEvent? event) {
      return event?.complete(event.notification);
    });

    OneSignal.shared.getDeviceState().then((value) async {
      if (value!.userId.validate().isNotEmpty) await setValue(PLAYERID, value.userId.validate());
    });

    OneSignal.shared.disablePush(false);

    OneSignal.shared.consentGranted(true);
    OneSignal.shared.requiresUserPrivacyConsent();
    OneSignal.shared.consentGranted(true);
    OneSignal.shared.promptUserForPushNotificationPermission();

    OneSignal.shared.setSubscriptionObserver((changes) async {
      if (!changes.to.userId.isEmptyOrNull) await setValue(PLAYERID, changes.to.userId);
    });
  });
}

//endregion

Decoration cardDecoration(BuildContext context, {Color? color, bool showBorder = true}) {
  return boxDecorationWithRoundedCorners(
    borderRadius: radius(),
    backgroundColor: color ?? context.scaffoldBackgroundColor,
    border: showBorder ? Border.all(color: context.dividerColor, width: 1.0) : null,
  );
}

Decoration categoryDecoration(BuildContext context, {Color? color, bool showBorder = true}) {
  return boxDecorationWithRoundedCorners(
    borderRadius: radius(),
    backgroundColor: color ?? context.cardColor,
    border: showBorder ? Border.all(color: context.dividerColor, width: 1.0) : null,
  );
}

int getRemainingPlanDays() {
  if (appStore.planEndDate.isNotEmpty) {
    var now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);
    DateTime endAt = DateFormat(DATE_FORMAT_7).parse(appStore.planEndDate);

    return (date.difference(endAt).inDays).abs();
  } else {
    return 0;
  }
}

List<LanguageDataModel> languageList() {
  return [
    LanguageDataModel(id: 1, name: 'English', languageCode: 'en', fullLanguageCode: 'en-US', flag: 'assets/flag/ic_us.png'),
    LanguageDataModel(id: 2, name: 'Hindi', languageCode: 'hi', fullLanguageCode: 'hi-IN', flag: 'assets/flag/ic_india.png'),
    LanguageDataModel(id: 3, name: 'Gujarati', languageCode: 'gu', fullLanguageCode: 'gu-IN', flag: 'assets/flag/ic_india.png'),
    LanguageDataModel(id: 4, name: 'Afrikaans', languageCode: 'af', fullLanguageCode: 'ar-AF', flag: 'assets/flag/ic_ar.png'),
    LanguageDataModel(id: 5, name: 'Arabic', languageCode: 'ar', fullLanguageCode: 'ar-AR', flag: 'assets/flag/ic_ar.png'),
    LanguageDataModel(id: 6, name: 'Dutch', languageCode: 'nl', fullLanguageCode: 'nl-NL', flag: 'assets/flag/ic_nl.png'),
    LanguageDataModel(id: 7, name: 'French', languageCode: 'fr', fullLanguageCode: 'fr-FR', flag: 'assets/flag/ic_fr.png'),
    LanguageDataModel(id: 8, name: 'German', languageCode: 'de', fullLanguageCode: 'de-DE', flag: 'assets/flag/ic_de.png'),
    LanguageDataModel(id: 9, name: 'Indonesian', languageCode: 'id', fullLanguageCode: 'id-ID', flag: 'assets/flag/ic_id.png'),
    LanguageDataModel(id: 10, name: 'Portugal', languageCode: 'pt', fullLanguageCode: 'pt-PT', flag: 'assets/flag/ic_pt.png'),
    LanguageDataModel(id: 11, name: 'Spanish', languageCode: 'es', fullLanguageCode: 'es-ES', flag: 'assets/flag/ic_es.png'),
    LanguageDataModel(id: 12, name: 'Turkish', languageCode: 'tr', fullLanguageCode: 'tr-TR', flag: 'assets/flag/ic_tr.png'),
    LanguageDataModel(id: 13, name: 'Vietnam', languageCode: 'vi', fullLanguageCode: 'vi-VI', flag: 'assets/flag/ic_vi.png'),
    LanguageDataModel(id: 14, name: 'Albanian', languageCode: 'sq', fullLanguageCode: 'sq-SQ', flag: 'assets/flag/ic_arbanian.png'),
  ];

  /*if (getStringAsync(SERVER_LANGUAGES).isNotEmpty) {
    Iterable it = jsonDecode(getStringAsync(SERVER_LANGUAGES));
    var res = it.map((e) => LanguageOption.fromJson(e)).toList();

    localeLanguageList.clear();

    res.forEach((element) {
      localeLanguageList.add(LanguageDataModel(languageCode: element.id.validate().toString(), flag: element.flagImage, name: element.title));
    });

    return localeLanguageList;
  } else {
    return [
      LanguageDataModel(id: 1, name: 'English', languageCode: 'en', fullLanguageCode: 'en-US', flag: 'assets/flag/ic_us.png'),
      LanguageDataModel(id: 2, name: 'Hindi', languageCode: 'hi', fullLanguageCode: 'hi-IN', flag: 'assets/flag/ic_india.png'),
      LanguageDataModel(id: 3, name: 'Gujarati', languageCode: 'gu', fullLanguageCode: 'gu-IN', flag: 'assets/flag/ic_india.png'),
      LanguageDataModel(id: 4, name: 'Afrikaans', languageCode: 'af', fullLanguageCode: 'ar-AF', flag: 'assets/flag/ic_ar.png'),
      LanguageDataModel(id: 5, name: 'Arabic', languageCode: 'ar', fullLanguageCode: 'ar-AR', flag: 'assets/flag/ic_ar.png'),
      LanguageDataModel(id: 6, name: 'Dutch', languageCode: 'nl', fullLanguageCode: 'nl-NL', flag: 'assets/flag/ic_nl.png'),
      LanguageDataModel(id: 7, name: 'French', languageCode: 'fr', fullLanguageCode: 'fr-FR', flag: 'assets/flag/ic_fr.png'),
      LanguageDataModel(id: 8, name: 'German', languageCode: 'de', fullLanguageCode: 'de-DE', flag: 'assets/flag/ic_de.png'),
      LanguageDataModel(id: 9, name: 'Indonesian', languageCode: 'id', fullLanguageCode: 'id-ID', flag: 'assets/flag/ic_id.png'),
      LanguageDataModel(id: 10, name: 'Portugal', languageCode: 'pt', fullLanguageCode: 'pt-PT', flag: 'assets/flag/ic_pt.png'),
      LanguageDataModel(id: 11, name: 'Spanish', languageCode: 'es', fullLanguageCode: 'es-ES', flag: 'assets/flag/ic_es.png'),
      LanguageDataModel(id: 12, name: 'Turkish', languageCode: 'tr', fullLanguageCode: 'tr-TR', flag: 'assets/flag/ic_tr.png'),
      LanguageDataModel(id: 13, name: 'Vietnam', languageCode: 'vi', fullLanguageCode: 'vi-VI', flag: 'assets/flag/ic_vi.png'),
      LanguageDataModel(id: 14, name: 'Albanian', languageCode: 'sq', fullLanguageCode: 'sq-SQ', flag: 'assets/flag/ic_arbanian.png'),
    ];
  }*/
}

InputDecoration inputDecoration(BuildContext context, {Widget? prefixIcon, String? hint, Color? fillColor, String? counterText, double? borderRadius}) {
  return InputDecoration(
    contentPadding: EdgeInsets.only(left: 12, bottom: 10, top: 10, right: 10),
    labelText: hint,
    labelStyle: secondaryTextStyle(),
    alignLabelWithHint: true,
    counterText: counterText,
    prefixIcon: prefixIcon,
    enabledBorder: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? defaultRadius),
      borderSide: BorderSide(color: Colors.transparent, width: 0.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? defaultRadius),
      borderSide: BorderSide(color: Colors.red, width: 0.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? defaultRadius),
      borderSide: BorderSide(color: Colors.red, width: 1.0),
    ),
    errorMaxLines: 2,
    errorStyle: primaryTextStyle(color: Colors.red, size: 12),
    focusedBorder: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? defaultRadius),
      borderSide: BorderSide(color: primaryColor, width: 0.0),
    ),
    filled: true,
    fillColor: fillColor ?? context.cardColor,
  );
}

void setCurrencies({required List<Configurations>? value, List<PaymentSetting>? paymentSetting}) {
  if (value != null) {
    Configurations data = value.firstWhere((element) => element.type == "CURRENCY");

    if (data.country != null) {
      if (data.country!.currencyCode.validate() != appStore.currencyCode) appStore.setCurrencyCode(data.country!.currencyCode.validate());
      if (data.country!.id.toString().validate() != appStore.countryId.toString()) appStore.setCurrencyCountryId(data.country!.id.toString().validate());
      if (data.country!.symbol.validate() != appStore.currencySymbol) appStore.setCurrencySymbol(data.country!.symbol.validate());
    }
    if (paymentSetting != null) {
      setValue(PAYMENT_LIST, PaymentSetting.encode(paymentSetting.validate()));
    }
  }
}

String parseHtmlString(String? htmlString) {
  return parse(parse(htmlString).body!.text).documentElement!.text;
}

String formatDate(String? dateTime, {String format = DATE_FORMAT_1}) {
  if (dateTime.validate().isNotEmpty) {
    return DateFormat(format).format(DateTime.parse(dateTime.validate()));
  } else {
    return '';
  }
}

String durationToString(int minutes) {
  var d = Duration(minutes: minutes);
  List<String> parts = d.toString().split(':');
  return '${parts[0].padLeft(2, '0')} :${parts[1].padLeft(2, '0')} min';
}

String getFirstWord(String inputString) {
  List<String> wordList = inputString.split(" ");
  if (wordList.isNotEmpty) {
    return wordList[0];
  } else {
    return ' ';
  }
}

Widget confirmationButton(BuildContext context, String btnTxt, IconData iconData, {Function? onTap}) {
  return AppButton(
    elevation: 0,
    padding: EdgeInsets.zero,
    color: Colors.transparent,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(iconData, color: context.iconColor, size: 24),
        8.width,
        Text(btnTxt, style: primaryTextStyle()),
      ],
    ),
    onTap: onTap,
  );
}

Widget statusButton(double width, String btnTxt, Color color, Color txtcolor, {Function? onTap}) {
  return AppButton(
    width: width,
    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    elevation: 0,
    color: color,
    shapeBorder: RoundedRectangleBorder(
      borderRadius: radius(defaultAppButtonRadius),
      side: BorderSide(color: primaryColor),
    ),
    child: Text(
      btnTxt,
      style: boldTextStyle(color: txtcolor),
      textAlign: TextAlign.justify,
    ),
    onTap: onTap,
  );
}

Future<void> commonLaunchUrl(String address, {LaunchMode launchMode = LaunchMode.inAppWebView}) async {
  await launchUrl(Uri.parse(address), mode: launchMode).catchError((e) {
    toast('Invalid URL: $address');
  });
}

void launchCall(String? url) {
  if (url.validate().isNotEmpty) {
    if (isIOS)
      commonLaunchUrl('tel://' + url!, launchMode: LaunchMode.externalApplication);
    else
      commonLaunchUrl('tel:' + url!, launchMode: LaunchMode.externalApplication);
  }
}

void launchMail(String? url) {
  if (url.validate().isNotEmpty) {
    commonLaunchUrl('mailto:' + url!, launchMode: LaunchMode.externalApplication);
  }
}

Future<void> saveOneSignalPlayerId() async {
  await OneSignal.shared.getDeviceState().then((value) async {
    if (value!.userId.validate().isNotEmpty) await setValue(PLAYERID, value.userId.validate());
  });
}

calculateLatLong(String address) async {
  try {
    List<Location> destinationPlacemark = await locationFromAddress(address);
    double? destinationLatitude = destinationPlacemark[0].latitude;
    double? destinationLongitude = destinationPlacemark[0].longitude;
    List<double?> destinationCoordinatesString = [destinationLatitude, destinationLongitude];
    return destinationCoordinatesString;
  } catch (e) {
    throw errorSomethingWentWrong;
  }
}

bool get isRTL => RTL_LANGUAGES.contains(appStore.selectedLanguageCode);

num calculateTotalAmount({
  required num servicePrice,
  required int qty,
  required num? serviceDiscountPercent,
  CouponData? couponData,
  ServiceData? detail,
  required List<TaxData>? taxes,
}) {
  double totalAmount = 0.0;
  double discountPrice = 0.0;
  double taxAmount = 0.0;
  double couponDiscountAmount = 0.0;

  if (couponData != null) {
    if (detail != null) {
      detail.couponId = couponData.id.toString();
      detail.appliedCouponData = couponData;
    }
    if (couponData.discountType == DISCOUNT_TYPE_FIXED) {
      totalAmount = totalAmount - couponData.discount.validate();
      couponDiscountAmount = couponData.discount.validate().toDouble();
    } else {
      totalAmount = totalAmount - ((totalAmount * couponData.discount.validate()) / 100);
      couponDiscountAmount = (couponDiscountAmount);
    }
  }

  taxes.validate().forEach((element) {
    if (isCommissionTypePercent(element.type)) {
      element.totalCalculatedValue = ((servicePrice * qty) * element.value.validate()) / 100;
    } else {
      element.totalCalculatedValue = element.value.validate();
    }
    taxAmount += element.totalCalculatedValue.validate().toDouble();
  });

  if (serviceDiscountPercent.validate() != 0) {
    totalAmount = (servicePrice * qty) - (((servicePrice * qty) * (serviceDiscountPercent!)) / 100);
    discountPrice = servicePrice * qty - totalAmount;
    totalAmount = (servicePrice * qty) - discountPrice - couponDiscountAmount + taxAmount;
  } else {
    totalAmount = (servicePrice * qty) - couponDiscountAmount + taxAmount;
  }

  if (detail != null) {
    detail.totalAmount = totalAmount.validate();
    detail.qty = qty.validate();
    detail.discountPrice = discountPrice.validate();
    detail.taxAmount = taxAmount.validate();
    detail.couponDiscountAmount = couponDiscountAmount.validate();
  }

  return totalAmount;
}

String calculateExperience() {
  int exp = 0;

  return exp.toString();
}

bool isCommissionTypePercent(String? type) => type.validate() == COMMISSION_TYPE_PERCENT;

bool get isUserTypeHandyman => appStore.userType == USER_TYPE_HANDYMAN;

bool get isUserTypeProvider => appStore.userType == USER_TYPE_PROVIDER;

Widget circleImage({required String image, double size = 24}) {
  return cachedImage(image, width: size, height: size, fit: BoxFit.cover).cornerRadiusWithClipRRect(90);
}

void launchUrlCustomTab(String? url) {
  if (url.validate().isNotEmpty) {
    custom_tabs.launch(
      url!,
      customTabsOption: custom_tabs.CustomTabsOption(
        enableDefaultShare: true,
        enableInstantApps: true,
        enableUrlBarHiding: true,
        showPageTitle: true,
        toolbarColor: primaryColor,
      ),
    );
  }
}

// Logic For Calculate Time
String calculateTimer(int secTime) {
  int hour = 0, minute = 0, seconds = 0;

  hour = secTime ~/ 3600;

  minute = ((secTime - hour * 3600)) ~/ 60;

  seconds = secTime - (hour * 3600) - (minute * 60);

  String hourLeft = hour.toString().length < 2 ? "0" + hour.toString() : hour.toString();

  String minuteLeft = minute.toString().length < 2 ? "0" + minute.toString() : minute.toString();

  String minutes = minuteLeft == '00' ? '01' : minuteLeft;

  String result = "$hourLeft:$minutes";

  return result;
}

num hourlyCalculation({required int secTime, required num price}) {
  num result = 0;

  String time = calculateTimer(secTime);
  String perMinuteCharge = (price / 60).toStringAsFixed(2);

  if (time == "01:00") {
    String value = (price * 1).toStringAsFixed(2);
    result = value.toDouble();
  } else {
    List<String> data = time.split(":");
    if (data.first == "00") {
      String value;
      if (secTime < 60) {
        value = (perMinuteCharge.toDouble() * 1).toStringAsFixed(2);
      } else {
        value = (perMinuteCharge.toDouble() * data.last.toDouble()).toStringAsFixed(2);
      }
      result = value.toDouble();
    } else {
      if (data.first.toInt() > 01 && data.last.toInt() == 00) {
        String value = (price * data.first.toInt()).toStringAsFixed(2);
        result = value.toDouble();
      } else {
        String value = (price * data.first.toInt()).toStringAsFixed(2);
        String extraMinuteCharge = (data.last.toDouble() * perMinuteCharge.toDouble()).toStringAsFixed(2);
        String finalPrice = (value.toDouble() + extraMinuteCharge.toDouble()).toStringAsFixed(2);
        result = finalPrice.toDouble();
      }
    }
  }

  return result.toDouble();
}

Widget subSubscriptionPlanWidget({Color? planBgColor, String? planTitle, String? planSubtitle, String? planButtonTxt, Function? onTap, Color? btnColor}) {
  return Container(
    color: planBgColor,
    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(planTitle.validate(), style: boldTextStyle()),
            8.height,
            Text(planSubtitle.validate(), style: secondaryTextStyle()),
          ],
        ).flexible(),
        AppButton(
          child: Text(planButtonTxt.validate(), style: boldTextStyle(color: white)),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: btnColor,
          elevation: 0,
          onTap: () {
            onTap?.call();
          },
        ),
      ],
    ),
  );
}

Brightness getStatusBrightness({required bool val}) {
  return val ? Brightness.light : Brightness.dark;
}

String getPaymentStatusText(String? status, String? method) {
  if (status!.isEmpty) {
    return 'Pending';
  } else if (status == SERVICE_PAYMENT_STATUS_PAID) {
    return 'Paid';
  } else if (status == SERVICE_PAYMENT_STATUS_PENDING && method == PAYMENT_METHOD_COD) {
    return 'Pending Approval';
  }
  if (status == SERVICE_PAYMENT_STATUS_PENDING) {
    return 'Pending';
  } else {
    return "";
  }
}

String getReasonText(BuildContext context, String val) {
  if (val == BookingStatusKeys.cancelled) {
    return context.translate.lblReasonCancelling;
  } else if (val == BookingStatusKeys.rejected) {
    return context.translate.lblReasonRejecting;
  } else if (val == BookingStatusKeys.failed) {
    return context.translate.lblFailed;
  }
  return '';
}

bool get isIqonicProduct => currentPackageName == APP_PACKAGE_NAME;

void checkIfLink(BuildContext context, String value, {String? title}) {
  String temp = parseHtmlString(value.validate());
  if (value.validate().isEmpty) return;

  if (temp.startsWith("https") || temp.startsWith("http")) {
    launchUrlCustomTab(temp.validate());
  } else if (temp.validateEmail()) {
    launchMail(temp);
  } else if (temp.validatePhone() || temp.startsWith('+')) {
    launchCall(temp);
  } else {
    HtmlWidget(postContent: value, title: title).launch(context);
  }
}

String buildPaymentStatusWithMethod(String status, String method) {
  return '${getPaymentStatusText(status, method)}${status == SERVICE_PAYMENT_STATUS_PAID ? ' by $method' : ''}';
}

Color getRatingBarColor(int rating) {
  if (rating == 1 || rating == 2) {
    return Color(0xFFE80000);
  } else if (rating == 3) {
    return Color(0xFFff6200);
  } else if (rating == 4 || rating == 5) {
    return Color(0xFF73CB92);
  } else {
    return Color(0xFFE80000);
  }
}

Future<FirebaseRemoteConfig> setupFirebaseRemoteConfig() async {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  remoteConfig.setConfigSettings(RemoteConfigSettings(fetchTimeout: Duration.zero, minimumFetchInterval: Duration.zero));
  await remoteConfig.fetch();
  await remoteConfig.fetchAndActivate();

  setValue(IN_MAINTENANCE_MODE, remoteConfig.getBool(IN_MAINTENANCE_MODE));
  if (isIOS) {
    await setValue(HAS_IN_REVIEW, remoteConfig.getBool(HAS_IN_APP_STORE_REVIEW));
  } else if (isAndroid) {
    await setValue(HAS_IN_REVIEW, remoteConfig.getBool(HAS_IN_PLAY_STORE_REVIEW));
  }
  return remoteConfig;
}

void ifNotTester(BuildContext context, VoidCallback callback) {
  if (!appStore.isTester) {
    callback.call();
  } else {
    toast(context.translate.lblUnAuthorized);
  }
}
