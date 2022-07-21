class UserInfoResponse {
  Data? data;

  // List<Service>? service;

  UserInfoResponse({this.data /*, this.service*/
      });

  factory UserInfoResponse.fromJson(Map<String, dynamic> json) {
    return UserInfoResponse(
      data: Data.fromJson(json['data']),
      // service: json['service'] != null ? (json['service'] as List).map((i) => Service.fromJson(i)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    // if (this.service != null) {
    //   data['service'] = this.service!.map((v) => v.toJson()).toList();
    // }
    return data;
  }
}

class Data {
  String? address;
  int? cityId;
  String? cityName;
  String? contactNumber;
  int? countryId;
  String? createdAt;
  String? description;
  String? displayName;
  String? email;
  String? firstName;
  int? id;
  int? isFeatured;
  String? lastName;
  String? profileImage;
  int? providerId;
  String? providertype;
  int? providertypeId;
  int? stateId;
  int? status;
  String? updatedAt;
  String? userType;
  String? userName;

  Data(
      {this.address,
      this.cityId,
      this.cityName,
      this.contactNumber,
      this.countryId,
      this.createdAt,
      this.description,
      this.displayName,
      this.email,
      this.firstName,
      this.id,
      this.isFeatured,
      this.lastName,
      this.profileImage,
      this.providerId,
      this.providertype,
      this.providertypeId,
      this.stateId,
      this.status,
      this.updatedAt,
      this.userType,
      this.userName});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      address: json['address'],
      cityId: json['city_id'],
      cityName: json['city_name'],
      contactNumber: json['contact_number'],
      countryId: json['country_id'],
      createdAt: json['created_at'],
      description: json['description'],
      displayName: json['display_name'],
      email: json['email'],
      firstName: json['first_name'],
      id: json['id'],
      isFeatured: json['is_featured'],
      lastName: json['last_name'],
      profileImage: json['profile_image'],
      providerId: json['provider_id'],
      providertype: json['providertype'],
      providertypeId: json['providertype_id'],
      stateId: json['state_id'],
      status: json['status'],
      updatedAt: json['updated_at'],
      userType: json['user_type'],
      userName: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    // data['city_id'] = this.city_id;
    // data['city_name'] = this.city_name;
    // data['contact_number'] = this.contact_number;
    // data['country_id'] = this.country_id;
    // data['created_at'] = this.created_at;
    // data['description'] = this.description;
    // data['display_name'] = this.display_name;
    // data['email'] = this.email;
    // data['first_name'] = this.first_name;
    // data['id'] = this.id;
    // data['is_featured'] = this.is_featured;
    // data['last_name'] = this.last_name;
    // data['profile_image'] = this.profile_image;
    // data['provider_id'] = this.provider_id;
    // data['providertype'] = this.providertype;
    // data['providertype_id'] = this.providertype_id;
    // data['state_id'] = this.state_id;
    // data['status'] = this.status;
    // data['updated_at'] = this.updated_at;
    // data['user_type'] = this.user_type;
    // data['username'] = this.username;
    return data;
  }
}
