import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/auth/sign_in_screen.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/base_response.dart';
import 'package:handyman_provider_flutter/models/booking_detail_response.dart';
import 'package:handyman_provider_flutter/models/booking_list_response.dart';
import 'package:handyman_provider_flutter/models/booking_status_response.dart';
import 'package:handyman_provider_flutter/models/caregory_response.dart';
import 'package:handyman_provider_flutter/models/city_list_response.dart';
import 'package:handyman_provider_flutter/models/country_list_response.dart';
import 'package:handyman_provider_flutter/models/dashboard_response.dart';
import 'package:handyman_provider_flutter/models/document_list_response.dart';
import 'package:handyman_provider_flutter/models/handyman_dashboard_response.dart';
import 'package:handyman_provider_flutter/models/login_response.dart';
import 'package:handyman_provider_flutter/models/notification_list_response.dart';
import 'package:handyman_provider_flutter/models/payment_list_reasponse.dart';
import 'package:handyman_provider_flutter/models/plan_list_response.dart';
import 'package:handyman_provider_flutter/models/plan_request_model.dart';
import 'package:handyman_provider_flutter/models/profile_update_response.dart';
import 'package:handyman_provider_flutter/models/provider_document_list_response.dart';
import 'package:handyman_provider_flutter/models/provider_info_model.dart';
import 'package:handyman_provider_flutter/models/provider_subscription_model.dart';
import 'package:handyman_provider_flutter/models/register_response.dart';
import 'package:handyman_provider_flutter/models/search_list_response.dart';
import 'package:handyman_provider_flutter/models/service_address_response.dart';
import 'package:handyman_provider_flutter/models/service_detail_response.dart';
import 'package:handyman_provider_flutter/models/service_response.dart';
import 'package:handyman_provider_flutter/models/service_review_response.dart';
import 'package:handyman_provider_flutter/models/state_list_response.dart';
import 'package:handyman_provider_flutter/models/subscription_history_model.dart';
import 'package:handyman_provider_flutter/models/tax_list_response.dart';
import 'package:handyman_provider_flutter/models/total_earning_response.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/models/user_info_response.dart';
import 'package:handyman_provider_flutter/models/user_list_response.dart';
import 'package:handyman_provider_flutter/models/user_type_response.dart';
import 'package:handyman_provider_flutter/networks/network_utils.dart';
import 'package:handyman_provider_flutter/provider/provider_dashboard_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/wallet_history_list_response.dart';

//region Auth API
Future<void> logout(BuildContext context) async {
  showInDialog(
    context,
    contentPadding: EdgeInsets.zero,
    builder: (_) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(logout_logo, width: context.width(), fit: BoxFit.cover),
              32.height,
              Text(context.translate.lblDeleteTitle, style: boldTextStyle(size: 20)),
              16.height,
              Text(context.translate.lblDeleteSubTitle, style: secondaryTextStyle()),
              28.height,
              Row(
                children: [
                  AppButton(
                    child: Text(context.translate.lblNo, style: boldTextStyle()),
                    color: context.cardColor,
                    elevation: 0,
                    onTap: () {
                      finish(context);
                    },
                  ).expand(),
                  16.width,
                  AppButton(
                    child: Text(context.translate.lblYes, style: boldTextStyle(color: white)),
                    color: primaryColor,
                    elevation: 0,
                    onTap: () async {
                      if (await isNetworkAvailable()) {
                        appStore.setLoading(true);
                        await logoutApi().then((value) async {}).catchError((e) {
                          appStore.setLoading(false);
                          toast(e.toString());
                        });

                        appStore.setLoading(false);

                        await appStore.setFirstName('');
                        await appStore.setLastName('');
                        if (!getBoolAsync(IS_REMEMBERED)) await appStore.setUserEmail('');
                        await appStore.setUserName('');
                        await appStore.setContactNumber('');
                        await appStore.setCountryId(0);
                        await appStore.setStateId(0);
                        await appStore.setCityId(0);
                        await appStore.setUId('');
                        await appStore.setToken('');
                        await appStore.setCurrencySymbol('');
                        await appStore.setLoggedIn(false);
                        await appStore.setPlanSubscribeStatus(false);
                        await appStore.setPlanTitle('');
                        await appStore.setIdentifier('');
                        await appStore.setPlanEndDate('');
                        await appStore.setTester(false);
                        await appStore.setPrivacyPolicy('');
                        await appStore.setTermConditions('');
                        await appStore.setInquiryEmail('');
                        await appStore.setHelplineNumber('');

                        SignInScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
                      } else {
                        toast(errorInternetNotAvailable);
                      }
                    },
                  ).expand(),
                ],
              ),
            ],
          ).paddingSymmetric(horizontal: 16, vertical: 24),
          Observer(builder: (_) => LoaderWidget().withSize(width: 60, height: 60).visible(appStore.isLoading)),
        ],
      );
    },
  );
}

Future<void> logoutApi() async {
  return await handleResponse(await buildHttpResponse('logout', method: HttpMethod.GET));
}

Future<RegisterResponse> registerUser(Map request) async {
  return RegisterResponse.fromJson(await (handleResponse(await buildHttpResponse('register', request: request, method: HttpMethod.POST))));
}

Future<LoginResponse> loginUser(Map request) async {
  LoginResponse res = LoginResponse.fromJson(await (handleResponse(await buildHttpResponse('login', request: request, method: HttpMethod.POST))));

  return res;
}

Future<void> saveUserData(UserData data) async {
  if (data.status == 1) {
    if (data.apiToken != null) await appStore.setToken(data.apiToken.validate());
    await appStore.setUserId(data.id.validate());
    await appStore.setFirstName(data.firstName.validate());
    await appStore.setUserType(data.userType.validate());
    await appStore.setLastName(data.lastName.validate());
    await appStore.setUserEmail(data.email.validate());
    await appStore.setUserName(data.username.validate());
    await appStore.setContactNumber('${data.contactNumber.validate()}');
    await appStore.setUserProfile(data.profileImage.validate());
    await appStore.setCountryId(data.countryId.validate());
    await appStore.setStateId(data.stateId.validate());
    await appStore.setDesignation(data.designation.validate());
    await userService.getUser(email: data.email.validate()).then((value) async {
      await appStore.setUId(value.uid.validate());
    }).catchError((e) {
      log(e.toString());
    });
    await appStore.setCityId(data.cityId.validate());
    await appStore.setProviderId(data.providerId.validate());
    if (data.serviceAddressId != null) await appStore.setServiceAddressId(data.serviceAddressId!);
    await appStore.setCreatedAt(data.createdAt.validate());
    if (data.subscription != null) {
      await setSaveSubscription(
        isSubscribe: data.isSubscribe,
        title: data.subscription!.title.validate(),
        identifier: data.subscription!.identifier.validate(),
        endAt: data.subscription!.endAt.validate(),
      );
    }

    await appStore.setAddress(data.address.validate().isNotEmpty ? data.address.validate() : '');
    //TODO setTotalBooking
    //await appStore.setTotalBooking(data.);

    await appStore.setLoggedIn(true);
  }
}

Future<BaseResponseModel> changeUserPassword(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('change-password', request: request, method: HttpMethod.POST)));
}

Future<UserInfoResponse> getUserDetail(int id) async {
  return UserInfoResponse.fromJson(await handleResponse(await buildHttpResponse('user-detail?id=$id', method: HttpMethod.GET)));
}

Future<HandymanInfoResponse> getProviderDetail(int id) async {
  return HandymanInfoResponse.fromJson(await handleResponse(await buildHttpResponse('user-detail?id=$id', method: HttpMethod.GET)));
}

Future<BaseResponseModel> forgotPassword(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('forgot-password', request: request, method: HttpMethod.POST)));
}

Future<ProfileUpdateResponse> updateProfile(Map request) async {
  return ProfileUpdateResponse.fromJson(await handleResponse(await buildHttpResponse('update-profile', request: request, method: HttpMethod.POST)));
}
//endregion

//region Country API
Future<List<CountryListResponse>> getCountryList() async {
  Iterable res = await (handleResponse(await buildHttpResponse('country-list', method: HttpMethod.POST)));
  return res.map((e) => CountryListResponse.fromJson(e)).toList();
}

Future<List<StateListResponse>> getStateList(Map request) async {
  Iterable res = await (handleResponse(await buildHttpResponse('state-list', request: request, method: HttpMethod.POST)));
  return res.map((e) => StateListResponse.fromJson(e)).toList();
}

Future<List<CityListResponse>> getCityList(Map request) async {
  Iterable res = await (handleResponse(await buildHttpResponse('city-list', request: request, method: HttpMethod.POST)));
  return res.map((e) => CityListResponse.fromJson(e)).toList();
}
//endregion

//region Category API
Future<CategoryResponse> getCategoryList({String perPage = ''}) async {
  return CategoryResponse.fromJson(await handleResponse(await buildHttpResponse('category-list$perPage', method: HttpMethod.GET)));
}
//endregion

//region SubCategory Api
Future<CategoryResponse> getSubCategoryList({required int catId}) async {
  return CategoryResponse.fromJson(await handleResponse(await buildHttpResponse('subcategory-list?category_id=$catId&per_page=all', method: HttpMethod.GET)));
}
//endregion

//region Provider API
Future<DashboardResponse> providerDashboard() async {
  DashboardResponse data = DashboardResponse.fromJson(await handleResponse(await buildHttpResponse('provider-dashboard', method: HttpMethod.GET)));

  setCurrencies(value: data.configurations, paymentSetting: data.paymentSettings);

  if (data.subscription != null) {
    await setSaveSubscription(
      isSubscribe: data.isSubscribed,
      title: data.subscription!.title.validate(),
      identifier: data.subscription!.identifier.validate(),
      endAt: data.subscription!.endAt.validate(),
    );
  }

  if (data.earningType == EARNING_TYPE_SUBSCRIPTION) {
    await setValue(IS_PLAN_SUBSCRIBE, true);
  } else {
    await setValue(IS_PLAN_SUBSCRIBE, false);
  }
  appStore.setEarningType(data.earningType.validate());

  if (data.privacyPolicy != null) {
    if (data.privacyPolicy!.value.validate().isNotEmpty) {
      appStore.setPrivacyPolicy(data.privacyPolicy!.value.validate());
    } else {
      appStore.setPrivacyPolicy(PRIVACY_POLICY_URL);
    }
  } else {
    appStore.setPrivacyPolicy(PRIVACY_POLICY_URL);
  }
  if (data.termConditions != null) {
    if (data.termConditions!.value.validate().isNotEmpty) {
      appStore.setTermConditions(data.termConditions!.value.validate());
    } else {
      appStore.setTermConditions(TERMS_CONDITION_URL);
    }
  } else {
    appStore.setTermConditions(TERMS_CONDITION_URL);
  }

  if (data.inquriyEmail.validate().isNotEmpty) {
    appStore.setInquiryEmail(data.inquriyEmail.validate());
  } else {
    appStore.setInquiryEmail(HELP_SUPPORT_URL);
  }

  if (data.helplineNumber.validate().isNotEmpty) {
    appStore.setHelplineNumber(data.helplineNumber.validate());
  }

  if (data.languageOption != null) {
    setValue(SERVER_LANGUAGES, jsonEncode(data.languageOption!.toList()));
  }

  return data;
}

Future<ProviderDocumentListResponse> getProviderDoc() async {
  return ProviderDocumentListResponse.fromJson(await handleResponse(await buildHttpResponse('provider-document-list', method: HttpMethod.GET)));
}

Future<ProfileUpdateResponse> deleteProviderDoc(int? id) async {
  return ProfileUpdateResponse.fromJson(await handleResponse(await buildHttpResponse('provider-document-delete/$id', method: HttpMethod.POST)));
}
//endregion

//region Handyman API
Future<HandymanDashBoardResponse> handymanDashboard() async {
  HandymanDashBoardResponse data = HandymanDashBoardResponse.fromJson(await handleResponse(await buildHttpResponse('handyman-dashboard', method: HttpMethod.GET)));

  setCurrencies(value: data.configurations);

  if (data.privacyPolicy != null) {
    if (data.privacyPolicy!.value.validate().isNotEmpty) {
      appStore.setPrivacyPolicy(data.privacyPolicy!.value.validate());
    } else {
      appStore.setPrivacyPolicy(PRIVACY_POLICY_URL);
    }
  } else {
    appStore.setPrivacyPolicy(PRIVACY_POLICY_URL);
  }

  if (data.termConditions != null) {
    if (data.termConditions!.value.validate().isNotEmpty) {
      appStore.setTermConditions(data.termConditions!.value.validate());
    } else {
      appStore.setTermConditions(TERMS_CONDITION_URL);
    }
  } else {
    appStore.setTermConditions(TERMS_CONDITION_URL);
  }

  if (data.inquriyEmail.validate().isNotEmpty) {
    appStore.setInquiryEmail(data.inquriyEmail.validate());
  } else {
    appStore.setInquiryEmail(HELP_SUPPORT_URL);
  }

  if (data.helplineNumber.validate().isNotEmpty) {
    appStore.setHelplineNumber(data.helplineNumber.validate());
  }

  if (data.languageOption != null) {
    setValue(SERVER_LANGUAGES, jsonEncode(data.languageOption!.toList()));
  }

  appStore.setHandymanAvailability(data.isHandymanAvailable.validate());

  return data;
}

Future<BaseResponseModel> updateHandymanStatus(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('user-update-status', request: request, method: HttpMethod.POST)));
}

Future<UserListResponse> getHandyman({bool isPagination = false, int? page, int? providerId, String? userTypeHandyman = "handyman"}) async {
  if (isPagination) {
    return UserListResponse.fromJson(
        await handleResponse(await buildHttpResponse('user-list?user_type=$userTypeHandyman&provider_id=$providerId&per_page=$PER_PAGE_ITEM&page=$page', method: HttpMethod.GET)));
  } else {
    return UserListResponse.fromJson(await handleResponse(await buildHttpResponse('user-list?user_type=$userTypeHandyman&provider_id=$providerId', method: HttpMethod.GET)));
  }
}

Future<UserData> deleteHandyman(int id) async {
  return UserData.fromJson(await handleResponse(await buildHttpResponse('handyman-delete/$id', method: HttpMethod.POST)));
}

Future<BaseResponseModel> restoreHandyman(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('handyman-action', request: request, method: HttpMethod.POST)));
}

//endregion

//region Service API
Future<ServiceResponse> getServiceList(int page, int providerId, {String? searchTxt, bool isSearch = false, int? categoryId, bool isCategoryWise = false}) async {
  if (isCategoryWise) {
    return ServiceResponse.fromJson(
        await handleResponse(await buildHttpResponse('service-list?per_page=$PER_PAGE_ITEM&category_id=$categoryId&page=$page&provider_id=$providerId', method: HttpMethod.GET)));
  } else if (isSearch) {
    return ServiceResponse.fromJson(await handleResponse(await buildHttpResponse('service-list?per_page=$PER_PAGE_ITEM&page=$page&search=$searchTxt&provider_id=$providerId', method: HttpMethod.GET)));
  } else {
    return ServiceResponse.fromJson(await handleResponse(await buildHttpResponse('service-list?per_page=$PER_PAGE_ITEM&page=$page&provider_id=$providerId', method: HttpMethod.GET)));
  }
}

Future<ServiceDetailResponse> getServiceDetail(Map request) async {
  return ServiceDetailResponse.fromJson(await handleResponse(await buildHttpResponse('service-detail', request: request, method: HttpMethod.POST)));
}

Future<ProfileUpdateResponse> deleteService(int id) async {
  return ProfileUpdateResponse.fromJson(await handleResponse(await buildHttpResponse('service-delete/$id', method: HttpMethod.POST)));
}

Future<BaseResponseModel> deleteImage(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('remove-file', request: request, method: HttpMethod.POST)));
}

//endregion

//region Booking API
Future<List<BookingStatusResponse>> bookingStatus() async {
  Iterable res = await (handleResponse(await buildHttpResponse('booking-status', method: HttpMethod.GET)));
  return res.map((e) => BookingStatusResponse.fromJson(e)).toList();
}

Future<BookingListResponse> getBookingList(int page, {var perPage = PER_PAGE_ITEM, String status = ''}) async {
  if (status == "All") {
    return BookingListResponse.fromJson(await handleResponse(await buildHttpResponse('booking-list?per_page=$perPage&page=$page', method: HttpMethod.GET)));
  }

  return BookingListResponse.fromJson(await handleResponse(await buildHttpResponse('booking-list?status=$status&per_page=$perPage&page=$page', method: HttpMethod.GET)));
}

Future<SearchListResponse> getSearchList(int page, {var perPage = PER_PAGE_ITEM, int? categoryId, int? providerId, String? search}) async {
  return SearchListResponse.fromJson(await handleResponse(await buildHttpResponse('search-list?per_page=$perPage&page=$page&search=$search&provider_id=$providerId', method: HttpMethod.GET)));
}

Future<BookingDetailResponse> bookingDetail(Map request) async {
  BookingDetailResponse bookingDetailResponse = BookingDetailResponse.fromJson(
    await handleResponse(await buildHttpResponse('booking-detail', request: request, method: HttpMethod.POST)),
  );

  calculateTotalAmount(
    serviceDiscountPercent: bookingDetailResponse.service!.discount.validate(),
    qty: bookingDetailResponse.bookingDetail!.quantity.validate().toInt(),
    detail: bookingDetailResponse.service,
    servicePrice: bookingDetailResponse.service!.price.validate(),
    taxes: bookingDetailResponse.bookingDetail!.taxes.validate(),
    couponData: bookingDetailResponse.couponData,
  );

  return bookingDetailResponse;
}

Future<BaseResponseModel> bookingUpdate(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('booking-update', request: request, method: HttpMethod.POST)));
}

Future<BaseResponseModel> assignBooking(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('booking-assigned', request: request, method: HttpMethod.POST)));
}
//endregion

//region Address API
Future<ServiceAddressesResponse> getAddresses({int? providerId}) async {
  return ServiceAddressesResponse.fromJson(await handleResponse(await buildHttpResponse('provideraddress-list?provider_id=$providerId', method: HttpMethod.GET)));
}

Future<BaseResponseModel> addAddresses(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('save-provideraddress', request: request, method: HttpMethod.POST)));
}

Future<BaseResponseModel> removeAddress(int? id) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('provideraddress-delete/$id', method: HttpMethod.POST)));
}
//endregion

//region Reviews API
Future<List<RatingData>> serviceReviews(Map request) async {
  ServiceReviewResponse res = ServiceReviewResponse.fromJson(await handleResponse(await buildHttpResponse('service-reviews?per_page=all', request: request, method: HttpMethod.POST)));

  return res.data.validate();
}

Future<List<RatingData>> handymanReviews(Map request) async {
  ServiceReviewResponse res = ServiceReviewResponse.fromJson(await handleResponse(await buildHttpResponse('handyman-reviews?per_page=all', request: request, method: HttpMethod.POST)));
  return res.data.validate();
}
//endregion

//region Subscription API
Future<PlanListResponse> getPricingPlanList() async {
  return PlanListResponse.fromJson(await handleResponse(await buildHttpResponse('plan-list', method: HttpMethod.GET)));
}

Future<ProviderSubscriptionModel> saveSubscription(Map request) async {
  return ProviderSubscriptionModel.fromJson(await handleResponse(await buildHttpResponse('save-subscription', request: request, method: HttpMethod.POST)));
}

Future<SubscriptionHistoryResponse> getSubscriptionHistory(int page, {var perPage = PER_PAGE_ITEM}) async {
  return SubscriptionHistoryResponse.fromJson(await handleResponse(await buildHttpResponse('subscription-history?per_page=$perPage&page=$page&orderby=desc', method: HttpMethod.GET)));
}

Future<void> cancelSubscription(Map request) async {
  return await handleResponse(await buildHttpResponse('cancel-subscription', request: request, method: HttpMethod.POST));
}

Future<void> savePayment({
  ProviderSubscriptionModel? data,
  String? paymentStatus = SERVICE_PAYMENT_STATUS_PENDING,
  String? paymentMethod,
  String? txtId,
}) async {
  if (data != null) {
    PlanRequestModel planRequestModel = PlanRequestModel()
      ..amount = data.amount
      ..description = data.description
      ..duration = data.duration
      ..identifier = data.identifier
      ..otherTransactionDetail = ''
      ..paymentStatus = paymentStatus.validate()
      ..paymentType = paymentMethod.validate()
      ..planId = data.id
      ..planLimitation = data.planLimitation
      ..planType = data.planType
      ..title = data.title
      ..txnId = txtId
      ..type = data.type
      ..userId = appStore.userId;

    appStore.setLoading(true);
    log('Request : $planRequestModel');

    await saveSubscription(planRequestModel.toJson()).then((value) {
      toast("${data.title.validate()}  is successFully activated");
      // toast("${data.title.validate()} ${context.translate.lblIsSuccessFullyActivated}");
      push(ProviderDashboardScreen(index: 0), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
    }).catchError((e) {
      log(e.toString());
    }).whenComplete(() => appStore.setLoading(false));
  }
}

Future<WalletHistoryListResponse> getWalletHistory(int page, {var perPage = PER_PAGE_ITEM}) async {
  return WalletHistoryListResponse.fromJson(await handleResponse(await buildHttpResponse('wallet-history?per_page=$perPage&page=$page&orderby=desc', method: HttpMethod.GET)));
}

Future<BaseResponseModel> updateHandymanAvailabilityApi({required Map request}) async {
  return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('handyman-update-available-status', request: request, method: HttpMethod.POST)));
}

//endregion

//region Payment API
Future<PaymentListResponse> getPaymentList(int page, {var perPage = PER_PAGE_ITEM}) async {
  return PaymentListResponse.fromJson(await handleResponse(await buildHttpResponse('payment-list?per_page="$perPage"&page=$page', method: HttpMethod.GET)));
}
//endregion

//region Common API
Future<TaxListResponse> getTaxList() async {
  return TaxListResponse.fromJson(await handleResponse(await buildHttpResponse('tax-list', method: HttpMethod.GET)));
}

Future<NotificationListResponse> getNotification(Map request, {int? page = 1}) async {
  return NotificationListResponse.fromJson(await handleResponse(await buildHttpResponse('notification-list?page=$page', request: request, method: HttpMethod.POST)));
}

Future<DocumentListResponse> getDocList() async {
  return DocumentListResponse.fromJson(await handleResponse(await buildHttpResponse('document-list', method: HttpMethod.GET)));
}

Future<TotalEarningResponse> getTotalEarningList(int page, {var perPage = PER_PAGE_ITEM}) async {
  return TotalEarningResponse.fromJson(
      await handleResponse(await buildHttpResponse('${isUserTypeProvider ? 'provider-payout-list' : 'handyman-payout-list'}?per_page="$perPage"&page=$page', method: HttpMethod.GET)));
}

Future<UserTypeResponse> getUserType({String type = "provider"}) async {
  return UserTypeResponse.fromJson(await handleResponse(await buildHttpResponse('type-list?type=$type')));
}
//endregion
