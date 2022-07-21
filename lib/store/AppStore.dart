import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/locale/base_language.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';

part 'AppStore.g.dart';

class AppStore = _AppStore with _$AppStore;

abstract class _AppStore with Store {
  @observable
  bool isLoggedIn = false;

  @observable
  bool isDarkMode = false;

  @observable
  bool isLoading = false;

  @observable
  bool isRememberMe = false;

  @observable
  bool isTester = false;

  @observable
  String selectedLanguageCode = DEFAULT_LANGUAGE;

  @observable
  String userProfileImage = '';

  @observable
  String currencySymbol = '';

  @observable
  String currencyCode = '';

  @observable
  String currencyCountryId = '';

  @observable
  String uId = '';

  @observable
  bool isPlanSubscribe = false;

  @observable
  String planTitle = '';

  @observable
  String identifier = '';

  @observable
  String planEndDate = '';

  @observable
  String userFirstName = '';

  @observable
  String userLastName = '';

  @observable
  String userContactNumber = '';

  @observable
  String userEmail = '';

  @observable
  String userName = '';

  @observable
  String token = '';

  @observable
  int countryId = 0;

  @observable
  int stateId = 0;

  @observable
  int cityId = 0;

  @observable
  String address = '';

  @observable
  String playerId = '';

  @observable
  String designation = '';

  @computed
  String get userFullName => '$userFirstName $userLastName'.trim();

  @observable
  int? userId = -1;

  @observable
  int? providerId = -1;

  @observable
  int serviceAddressId = -1;

  @observable
  String userType = '';

  @observable
  String privacyPolicy = '';

  @observable
  String termConditions = '';

  @observable
  String inquiryEmail = '';

  @observable
  String helplineNumber = '';

  @observable
  int initialAdCount = 0;

  @observable
  int totalBooking = 0;

  @observable
  String createdAt = '';

  @observable
  String earningType = '';

  @observable
  int handymanAvailability = 0;

  @computed
  bool get earningTypeCommission => earningType == EARNING_TYPE_COMMISSION;

  @computed
  bool get earningTypeSubscription => earningType == EARNING_TYPE_SUBSCRIPTION;

  @action
  Future<void> setEarningType(String val, {bool isInitializing = false}) async {
    earningType = val;
    if (!isInitializing) await setValue(EARNING_TYPE, val);
  }

  @action
  Future<void> setTester(bool val, {bool isInitializing = false}) async {
    isTester = val;
    if (!isInitializing) await setValue(IS_TESTER, isTester);
  }

  @action
  Future<void> setUserProfile(String val, {bool isInitializing = false}) async {
    userProfileImage = val;
    if (!isInitializing) await setValue(PROFILE_IMAGE, val);
  }

  @action
  Future<void> setPlayerId(String val, {bool isInitializing = false}) async {
    playerId = val;
    if (!isInitializing) await setValue(PLAYERID, val);
  }

  @action
  Future<void> setToken(String val, {bool isInitializing = false}) async {
    token = val;
    if (!isInitializing) await setValue(TOKEN, val);
  }

  @action
  Future<void> setCountryId(int val, {bool isInitializing = false}) async {
    countryId = val;
    if (!isInitializing) await setValue(COUNTRY_ID, val);
  }

  @action
  Future<void> setStateId(int val, {bool isInitializing = false}) async {
    stateId = val;
    if (!isInitializing) await setValue(STATE_ID, val);
  }

  @action
  Future<void> setCurrencySymbol(String val, {bool isInitializing = false}) async {
    currencySymbol = val;
    if (!isInitializing) await setValue(CURRENCY_COUNTRY_SYMBOL, val);
  }

  @action
  Future<void> setCurrencyCode(String val, {bool isInitializing = false}) async {
    currencyCode = val;
    if (!isInitializing) await setValue(CURRENCY_COUNTRY_CODE, val);
  }

  @action
  Future<void> setCurrencyCountryId(String val, {bool isInitializing = false}) async {
    currencyCountryId = val;
    if (!isInitializing) await setValue(CURRENCY_COUNTRY_ID, val);
  }

  @action
  Future<void> setCityId(int val, {bool isInitializing = false}) async {
    cityId = val;
    if (!isInitializing) await setValue(CITY_ID, val);
  }

  @action
  Future<void> setUId(String val, {bool isInitializing = false}) async {
    uId = val;
    if (!isInitializing) await setValue(UID, val);
  }

  @action
  Future<void> setPlanSubscribeStatus(bool val, {bool isInitializing = false}) async {
    isPlanSubscribe = val && planTitle.isNotEmpty;
    if (!isInitializing) await setValue(IS_PLAN_SUBSCRIBE, val);
  }

  @action
  Future<void> setPlanTitle(String val, {bool isInitializing = false}) async {
    planTitle = val;
    if (!isInitializing) await setValue(PLAN_TITLE, val);
  }

  @action
  Future<void> setIdentifier(String val, {bool isInitializing = false}) async {
    identifier = val;
    if (!isInitializing) await setValue(PLAN_IDENTIFIER, val);
  }

  @action
  Future<void> setPlanEndDate(String val, {bool isInitializing = false}) async {
    planEndDate = val;
    if (!isInitializing) await setValue(PLAN_END_DATE, val);
  }

  @action
  Future<void> setUserId(int val, {bool isInitializing = false}) async {
    userId = val;
    if (!isInitializing) await setValue(USER_ID, val);
  }

  @action
  Future<void> setDesignation(String val, {bool isInitializing = false}) async {
    designation = val;
    if (!isInitializing) await setValue(DESIGNATION, val);
  }

  @action
  Future<void> setUserType(String val, {bool isInitializing = false}) async {
    userType = val;
    if (!isInitializing) await setValue(USER_TYPE, val);
  }

  @action
  Future<void> setPrivacyPolicy(String val, {bool isInitializing = false}) async {
    privacyPolicy = val;
    if (!isInitializing) await setValue(PRIVACY_POLICY, val);
  }

  @action
  Future<void> setTermConditions(String val, {bool isInitializing = false}) async {
    termConditions = val;
    if (!isInitializing) await setValue(TERM_CONDITIONS, val);
  }

  @action
  Future<void> setInquiryEmail(String val, {bool isInitializing = false}) async {
    inquiryEmail = val;
    if (!isInitializing) await setValue(INQUIRY_EMAIL, val);
  }

  @action
  Future<void> setHelplineNumber(String val, {bool isInitializing = false}) async {
    helplineNumber = val;
    if (!isInitializing) await setValue(HELPLINE_NUMBER, val);
  }

  @action
  Future<void> setTotalBooking(int val, {bool isInitializing = false}) async {
    totalBooking = val;
    if (!isInitializing) await setValue(TOTAL_BOOKING, val);
  }

  @action
  Future<void> setCreatedAt(String val, {bool isInitializing = false}) async {
    createdAt = val;
    if (!isInitializing) await setValue(CREATED_AT, val);
  }

  @action
  Future<void> setProviderId(int val, {bool isInitializing = false}) async {
    providerId = val;
    if (!isInitializing) await setValue(PROVIDER_ID, val);
  }

  @action
  Future<void> setServiceAddressId(int val, {bool isInitializing = false}) async {
    serviceAddressId = val;
    if (!isInitializing) await setValue(SERVICE_ADDRESS_ID, val);
  }

  @action
  Future<void> setUserEmail(String val, {bool isInitializing = false}) async {
    userEmail = val;
    if (!isInitializing) await setValue(USER_EMAIL, val);
  }

  @action
  Future<void> setAddress(String val, {bool isInitializing = false}) async {
    address = val;
    if (!isInitializing) await setValue(ADDRESS, val);
  }

  @action
  Future<void> setFirstName(String val, {bool isInitializing = false}) async {
    userFirstName = val;
    if (!isInitializing) await setValue(FIRST_NAME, val);
  }

  @action
  Future<void> setLastName(String val, {bool isInitializing = false}) async {
    userLastName = val;
    if (!isInitializing) await setValue(LAST_NAME, val);
  }

  @action
  Future<void> setContactNumber(String val, {bool isInitializing = false}) async {
    userContactNumber = val;
    if (!isInitializing) await setValue(CONTACT_NUMBER, val);
  }

  @action
  Future<void> setUserName(String val, {bool isInitializing = false}) async {
    userName = val;
    if (!isInitializing) await setValue(USERNAME, val);
  }

  @action
  Future<void> setLoggedIn(bool val, {bool isInitializing = false}) async {
    isLoggedIn = val;
    if (!isInitializing) await setValue(IS_LOGGED_IN, val);
  }

  @action
  void setLoading(bool val) {
    isLoading = val;
  }

  @action
  void setRemember(bool val) {
    isRememberMe = val;
  }

  @action
  Future<void> setInitialAdCount(int val) async {
    countryId = val;
    // await setValue(INITIAL_AD_COUNT, val);
  }

  @action
  Future<void> setDarkMode(bool val) async {
    isDarkMode = val;
    if (isDarkMode) {
      textPrimaryColorGlobal = Colors.white;
      textSecondaryColorGlobal = textSecondaryColor;

      defaultLoaderBgColorGlobal = scaffoldSecondaryDark;
      appButtonBackgroundColorGlobal = appButtonColorDark;
      shadowColorGlobal = Colors.white12;
      setStatusBarColor(appButtonColorDark);
    } else {
      textPrimaryColorGlobal = textPrimaryColor;
      textSecondaryColorGlobal = textSecondaryColor;

      defaultLoaderBgColorGlobal = Colors.white;
      appButtonBackgroundColorGlobal = Colors.white;
      shadowColorGlobal = Colors.black12;
      setStatusBarColor(primaryColor);
    }
  }

  @action
  Future<void> setLanguage(String val, {BuildContext? context}) async {
    selectedLanguageCode = val;

    await setValue(SELECTED_LANGUAGE_CODE, selectedLanguageCode);
    selectedLanguageDataModel = getSelectedLanguageModel();

    if (context != null) languages = Languages.of(context);
  }

  @action
  Future<void> setHandymanAvailability(int val, {bool isInitializing = false}) async {
    handymanAvailability = val;
    if (isInitializing) await setValue(HANDYMAN_AVAILABLE_STATUS, val);
  }
}
