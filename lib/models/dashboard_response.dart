import 'dart:convert';

import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/provider_subscription_model.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:nb_utils/nb_utils.dart';

import 'revenue_chart_data.dart';

class DashboardResponse {
  bool? status;
  int? totalBooking;
  int? totalService;
  int? totalHandyman;
  int? isSubscribed;
  List<ServiceData>? service;
  List<CategoryData>? category;
  List<UserData>? handyman;
  num? totalRevenue;
  List<double>? chartArray;
  List<int>? monthData;
  Commission? commission;
  ProviderSubscriptionModel? subscription;
  List<Configurations>? configurations;
  List<PaymentSetting>? paymentSettings;
  String? earningType;
  List<LanguageOption>? languageOption;

  List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'];

  //Local
  bool? isPlanAboutToExpire;
  bool? userNeverPurchasedPlan;
  bool? isPlanExpired;
  PrivacyPolicy? privacyPolicy;
  PrivacyPolicy? termConditions;
  String? inquriyEmail;
  String? helplineNumber;
  ProviderWallet? providerWallet;
  List<String>? onlineHandyman;

  DashboardResponse({
    this.chartArray,
    this.monthData,
    this.status,
    this.totalBooking,
    this.service,
    this.category,
    this.totalService,
    this.totalHandyman,
    this.isSubscribed,
    this.paymentSettings,
    this.handyman,
    this.totalRevenue,
    this.configurations,
    this.commission,
    this.subscription,
    this.earningType,
    this.privacyPolicy,
    this.termConditions,
    this.inquriyEmail,
    this.helplineNumber,
    this.providerWallet,
    this.languageOption,
    this.onlineHandyman,
  });

  DashboardResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    totalBooking = json['total_booking'];
    totalRevenue = json['total_revenue'];
    totalService = json['total_service'];
    totalHandyman = json['total_handyman'];
    isSubscribed = json['is_subscribed'] ?? 0;
    subscription = json['subscription'] != null ? ProviderSubscriptionModel.fromJson(json['subscription']) : null;
    commission = json['commission'] != null ? Commission.fromJson(json['commission']) : null;
    configurations = json['configurations'] != null ? (json['configurations'] as List).map((i) => Configurations.fromJson(i)).toList() : null;
    paymentSettings = json['payment_settings'] != null ? (json['payment_settings'] as List).map((i) => PaymentSetting.fromJson(i)).toList() : null;
    privacyPolicy = json['privacy_policy'] != null ? PrivacyPolicy.fromJson(json['privacy_policy']) : null;
    termConditions = json['term_conditions'] != null ? PrivacyPolicy.fromJson(json['term_conditions']) : null;
    inquriyEmail = json['inquriy_email'];
    helplineNumber = json['helpline_number'];
    if (json['service'] != null) {
      service = [];
      json['service'].forEach((v) {
        service!.add(new ServiceData.fromJson(v));
      });
    }
    if (json['category'] != null) {
      category = [];
      json['category'].forEach((v) {
        category!.add(new CategoryData.fromJson(v));
      });
    }
    if (json['handyman'] != null) {
      handyman = [];
      json['handyman'].forEach((v) {
        handyman!.add(UserData.fromJson(v));
      });
    }

    chartArray = [];
    monthData = [];
    Iterable it = json['monthly_revenue']['revenueData'];

    it.forEachIndexed((element, index) {
      if ((element as Map).containsKey('${index + 1}')) {
        chartArray!.add(element[(index + 1).toString()].toString().toDouble());
        monthData!.add(index);
        chartData.add(RevenueChartData(month: months[index], revenue: element[(index + 1).toString()].toString().toDouble()));
      } else {
        chartData.add(RevenueChartData(month: months[index], revenue: 0));
      }
    });

    isPlanAboutToExpire = isSubscribed == 1;
    userNeverPurchasedPlan = isSubscribed == 0 && subscription == null;
    isPlanExpired = isSubscribed == 0 && subscription != null;
    earningType = json['earning_type'];
    providerWallet = json['provider_wallet'] != null ? ProviderWallet.fromJson(json['provider_wallet']) : null;

    // providerWallet = json['provider_wallet'] != null ? (json['provider_wallet'] as List).map((i) => ProviderWallet.fromJson(i)).toList() : null;
    languageOption = json['language_option'] != null ? (json['language_option'] as List).map((i) => LanguageOption.fromJson(i)).toList() : null;
    onlineHandyman = json['online_handyman'] != null ? json['online_handyman'].cast<String>() : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['total_booking'] = this.totalBooking;
    data['is_subscribed'] = this.isSubscribed;
    data['total_service'] = this.totalService;
    if (this.privacyPolicy != null) {
      data['privacy_policy'] = this.privacyPolicy;
    }
    if (this.termConditions != null) {
      data['term_conditions'] = this.termConditions;
    }
    data['inquriy_email'] = this.inquriyEmail;
    data['helpline_number'] = this.helplineNumber;
    if (this.commission != null) {
      data['commission'] = this.commission!.toJson();
    }
    if (this.subscription != null) {
      data['subscription'] = this.subscription!.toJson();
    }
    if (this.configurations != null) {
      data['configurations'] = this.configurations!.map((v) => v.toJson()).toList();
    }
    data['total_handyman'] = this.totalHandyman;
    if (this.service != null) {
      data['service'] = this.service!.map((v) => v.toJson()).toList();
    }
    if (this.category != null) {
      data['category'] = this.category!.map((v) => v.toJson()).toList();
    }
    if (this.paymentSettings != null) {
      data['payment_settings'] = this.paymentSettings!.map((v) => v.toJson()).toList();
    }
    if (this.handyman != null) {
      data['handyman'] = this.handyman!.map((v) => v.toJson()).toList();
    }
    data['total_revenue'] = this.totalRevenue;
    data['earning_type'] = this.earningType;
    data['online_handyman'] = this.onlineHandyman;
    if (this.providerWallet != null) {
      data['provider_wallet'] = this.providerWallet!.toJson();
    }

    if (this.languageOption != null) {
      data['language_option'] = this.languageOption!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class PrivacyPolicy {
  int? id;
  String? key;
  String? type;
  String? value;

  PrivacyPolicy({this.id, this.key, this.type, this.value});

  factory PrivacyPolicy.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicy(
      id: json['id'],
      key: json['key'],
      type: json['type'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['key'] = this.key;
    data['type'] = this.type;
    data['value'] = this.value;
    return data;
  }
}

class LiveValue {
  String? stripeUrl;
  String? stripeKey;
  String? stripePublickey;
  String? razorUrl;
  String? razorKey;
  String? razorSecret;
  String? flutterwavePublic;
  String? flutterwaveSecret;
  String? flutterwaveEncryption;
  String? paystackPublic;

  LiveValue(
      {this.stripeUrl,
      this.stripeKey,
      this.stripePublickey,
      this.razorUrl,
      this.razorKey,
      this.razorSecret,
      this.flutterwavePublic,
      this.flutterwaveSecret,
      this.flutterwaveEncryption,
      this.paystackPublic});

  factory LiveValue.fromJson(Map<String, dynamic> json) {
    return LiveValue(
      stripeUrl: json['stripe_url'],
      stripeKey: json['stripe_key'],
      stripePublickey: json['stripe_publickey'],
      razorUrl: json['razor_url'],
      razorKey: json['razor_key'],
      razorSecret: json['razor_secret'],
      flutterwavePublic: json['flutterwave_public'],
      flutterwaveSecret: json['flutterwave_secret'],
      flutterwaveEncryption: json['flutterwave_encryption'],
      paystackPublic: json['paystack_public'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stripe_url'] = this.stripeUrl;
    data['stripe_key'] = this.stripeKey;
    data['stripe_publickey'] = this.stripePublickey;
    data['razor_url'] = this.razorUrl;
    data['razor_key'] = this.razorKey;
    data['razor_secret'] = this.razorSecret;
    data['flutterwave_public'] = this.flutterwavePublic;
    data['flutterwave_secret'] = this.flutterwaveSecret;
    data['flutterwave_encryption'] = this.flutterwaveEncryption;
    data['paystack_public'] = this.paystackPublic;
    return data;
  }
}

class PaymentSetting {
  int? id;
  int? isTest;
  LiveValue? liveValue;
  int? status;
  String? title;
  String? type;
  LiveValue? testValue;

  PaymentSetting({this.id, this.isTest, this.liveValue, this.status, this.title, this.type, this.testValue});

  static String encode(List<PaymentSetting> paymentList) {
    return json.encode(paymentList.map<Map<String, dynamic>>((payment) => payment.toJson()).toList());
  }

  static List<PaymentSetting> decode(String musics) {
    return (json.decode(musics) as List<dynamic>).map<PaymentSetting>((item) => PaymentSetting.fromJson(item)).toList();
  }

  factory PaymentSetting.fromJson(Map<String, dynamic> json) {
    return PaymentSetting(
      id: json['id'],
      isTest: json['is_test'],
      liveValue: json['live_value'] != null ? LiveValue.fromJson(json['live_value']) : null,
      status: json['status'],
      title: json['title'],
      type: json['type'],
      testValue: json['value'] != null ? LiveValue.fromJson(json['value']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['is_test'] = this.isTest;
    data['status'] = this.status;
    data['title'] = this.title;
    data['type'] = this.type;
    if (this.liveValue != null) {
      data['live_value'] = this.liveValue?.toJson();
    }
    if (this.testValue != null) {
      data['value'] = this.testValue?.toJson();
    }
    return data;
  }
}

class ServiceAddressMapping {
  int? id;
  int? serviceId;
  int? providerAddressId;
  String? createdAt;
  String? updatedAt;
  ProviderAddressMapping? providerAddressMapping;

  ServiceAddressMapping({this.id, this.serviceId, this.providerAddressId, this.createdAt, this.updatedAt, this.providerAddressMapping});

  ServiceAddressMapping.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serviceId = json['service_id'];
    providerAddressId = json['provider_address_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    providerAddressMapping = json['provider_address_mapping'] != null ? new ProviderAddressMapping.fromJson(json['provider_address_mapping']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['service_id'] = this.serviceId;
    data['provider_address_id'] = this.providerAddressId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.providerAddressMapping != null) {
      data['provider_address_mapping'] = this.providerAddressMapping!.toJson();
    }
    return data;
  }
}

class ProviderAddressMapping {
  int? id;
  int? providerId;
  String? address;
  String? latitude;
  String? longitude;
  int? status;
  String? createdAt;
  String? updatedAt;

  ProviderAddressMapping({this.id, this.providerId, this.address, this.latitude, this.longitude, this.status, this.createdAt, this.updatedAt});

  ProviderAddressMapping.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    providerId = json['provider_id'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['provider_id'] = this.providerId;
    data['address'] = this.address;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class CategoryData {
  int? id;
  String? name;
  int? status;
  String? description;
  int? isFeatured;
  String? color;
  String? categoryImage;

  CategoryData({this.id, this.name, this.status, this.description, this.isFeatured, this.color, this.categoryImage});

  CategoryData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
    description = json['description'];
    isFeatured = json['is_featured'];
    color = json['color'];
    categoryImage = json['category_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['status'] = this.status;
    data['description'] = this.description;
    data['is_featured'] = this.isFeatured;
    data['color'] = this.color;
    data['category_image'] = this.categoryImage;
    return data;
  }
}

class MonthlyRevenue {
  List<RevenueData>? revenueData;

  MonthlyRevenue({this.revenueData});

  MonthlyRevenue.fromJson(Map<String, dynamic> json) {
    if (json['revenueData'] != null) {
      revenueData = [];
      json['revenueData'].forEach((v) {
        revenueData!.add(new RevenueData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.revenueData != null) {
      data['revenueData'] = this.revenueData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RevenueData {
  var i;

  RevenueData({this.i});

  RevenueData.fromJson(Map<String, dynamic> json) {
    for (int i = 1; i <= 12; i++) {
      i = json['$i'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    for (int i = 1; i <= 12; i++) {
      data['$i'] = this.i;
    }
    return data;
  }
}

class Configurations {
  Country? country;
  int? id;
  String? key;
  String? type;
  String? value;

  Configurations({this.country, this.id, this.key, this.type, this.value});

  factory Configurations.fromJson(Map<String, dynamic> json) {
    return Configurations(
      country: json['country'] != null ? Country.fromJson(json['country']) : null,
      id: json['id'],
      key: json['key'],
      type: json['type'],
      value: json['value'] != null ? json['value'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['key'] = this.key;
    data['type'] = this.type;
    if (this.country != null) {
      data['country'] = this.country!.toJson();
    }
    if (this.value != null) {
      data['value'] = this.value;
    }
    return data;
  }
}

class Commission {
  int? commission;
  String? createdAt;
  String? deletedAt;
  int? id;
  String? name;
  int? status;
  String? type;
  String? updatedAt;

  Commission({this.commission, this.createdAt, this.deletedAt, this.id, this.name, this.status, this.type, this.updatedAt});

  factory Commission.fromJson(Map<String, dynamic> json) {
    return Commission(
      commission: json['commission'],
      createdAt: json['created_at'],
      deletedAt: json['deleted_at'],
      id: json['id'],
      name: json['name'],
      status: json['status'],
      type: json['type'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['commission'] = this.commission;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    data['name'] = this.name;
    data['status'] = this.status;
    data['type'] = this.type;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}

class Country {
  int? id;
  String? code;
  String? name;
  int? dialCode;
  String? currencyName;
  String? symbol;
  String? currencyCode;

  Country({this.id, this.code, this.name, this.dialCode, this.currencyName, this.symbol, this.currencyCode});

  Country.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    dialCode = json['dial_code'];
    currencyName = json['currency_name'];
    symbol = json['symbol'];
    currencyCode = json['currency_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['name'] = this.name;
    data['dial_code'] = this.dialCode;
    data['currency_name'] = this.currencyName;
    data['symbol'] = this.symbol;
    data['currency_code'] = this.currencyCode;
    return data;
  }
}

class ProviderWallet {
  int? id;
  String? title;
  int? userId;
  int? amount;
  int? status;
  String? createdAt;
  String? updatedAt;

  ProviderWallet(this.id, this.title, this.userId, this.amount, this.status, this.createdAt, this.updatedAt);

  ProviderWallet.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    userId = json['user_id'];
    amount = json['amount'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['user_id'] = this.userId;
    data['amount'] = this.amount;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class LanguageOption {
  String? flagImage;
  String? id;
  String? title;

  LanguageOption({this.flagImage, this.id, this.title});

  factory LanguageOption.fromJson(Map<String, dynamic> json) {
    return LanguageOption(
      flagImage: json['flag_image'],
      id: json['id'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['flag_image'] = this.flagImage;
    data['id'] = this.id;
    data['title'] = this.title;
    return data;
  }
}
