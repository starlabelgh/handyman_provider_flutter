import 'package:handyman_provider_flutter/models/provider_subscription_model.dart';

class UserData {
  int? id;
  String? uid;
  String? username;
  String? firstName;
  String? lastName;
  String? email;
  String? emailVerifiedAt;
  String? userType;
  String? contactNumber;
  int? countryId;
  int? stateId;
  int? cityId;
  String? address;
  int? providerId;
  String? playerId;
  int? status;
  int? providertypeId;
  int? isFeatured;
  String? displayName;
  String? timeZone;
  String? lastNotificationSeen;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  List<String>? userRole;
  String? apiToken;
  String? profileImage;
  String? description;
  int? serviceAddressId;
  num? handymanRating;
  ProviderSubscriptionModel? subscription;
  int? isSubscribe;
  String? designation;

  String? cityName;
  String? providertype;
  bool? isHandymanAvailable;
  String? loginType;

  //Local
  bool isActive = false;

  UserData({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.emailVerifiedAt,
    this.userType,
    this.contactNumber,
    this.countryId,
    this.stateId,
    this.cityId,
    this.address,
    this.providerId,
    this.playerId,
    this.status,
    this.providertypeId,
    this.isFeatured,
    this.displayName,
    this.timeZone,
    this.lastNotificationSeen,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.userRole,
    this.apiToken,
    this.profileImage,
    this.description,
    this.serviceAddressId,
    this.handymanRating,
    this.subscription,
    this.isSubscribe,
    this.uid,
    this.designation,
    this.cityName,
    this.providertype,
    this.isHandymanAvailable,
    this.loginType,
  });

  UserData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    userType = json['user_type'];
    contactNumber = json['contact_number'];
    countryId = json['country_id'];
    stateId = json['state_id'];
    cityId = json['city_id'];
    address = json['address'];
    providerId = json['provider_id'];
    playerId = json['player_id'];
    status = json['status'];
    isActive = status == 1;
    serviceAddressId = json['service_address_id'];
    handymanRating = json['handyman_rating'];
    //providertypeId = json['providertype_id'];
    isFeatured = json['is_featured'];
    displayName = json['display_name'];
    timeZone = json['time_zone'];
    lastNotificationSeen = json['last_notification_seen'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    // userRole = json['user_role'].cast<String>();
    apiToken = json['api_token'];
    profileImage = json['profile_image'];
    description = json['description'];
    uid = json['uid'];
    subscription = json['subscription'] != null ? ProviderSubscriptionModel.fromJson(json['subscription']) : null;
    isSubscribe = json['is_subscribe'];
    designation = json['designation'];
    cityName = json['city_name'];
    providertype = json['providertype'];
    isHandymanAvailable = json['isHandymanAvailable'] != null ? json['isHandymanAvailable'] == 1 : false;
    loginType = json['login_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['email'] = this.email;
    data['service_address_id'] = this.serviceAddressId;
    data['handyman_rating'] = this.handymanRating;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['user_type'] = this.userType;
    data['contact_number'] = this.contactNumber;
    data['country_id'] = this.countryId;
    data['state_id'] = this.stateId;
    data['city_id'] = this.cityId;
    data['address'] = this.address;
    data['provider_id'] = this.providerId;
    data['player_id'] = this.playerId;
    data['status'] = this.status;
    data['providertype_id'] = this.providertypeId;
    data['is_featured'] = this.isFeatured;
    data['display_name'] = this.displayName;
    data['time_zone'] = this.timeZone;
    data['last_notification_seen'] = this.lastNotificationSeen;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['user_role'] = this.userRole;
    data['api_token'] = this.apiToken;
    data['profile_image'] = this.profileImage;
    data['description'] = this.description;
    data['uid'] = this.uid;
    data['is_subscribe'] = this.designation;
    data['city_name'] = this.cityName;
    data['providertype'] = this.providertype;
    data['isHandymanAvailable'] = this.isHandymanAvailable;
    data['login_type'] = this.loginType;

    if (this.subscription != null) {
      data['subscription'] = this.subscription!.toJson();
    }
    data['designation'] = this.designation;
    return data;
  }
}
