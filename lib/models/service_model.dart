import 'package:handyman_provider_flutter/models/booking_detail_response.dart';
import 'package:handyman_provider_flutter/models/service_detail_response.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

class ServiceData {
  int? id;
  String? name;
  int? categoryId;
  int? providerId;
  num? price;
  var priceFormat;
  String? type;
  num? discount;
  String? duration;
  int? status;
  String? description;
  int? isFeatured;
  String? providerName;
  String? providerImage;
  int? cityId;
  String? categoryName;
  List<String>? imageAttachments;
  List<Attachments>? attchments;
  num? totalReview;
  num? totalRating;
  int? isFavourite;
  List<ServiceAddressMapping>? serviceAddressMapping;

  //Set Values
  num? totalAmount;
  num? discountPrice;
  num? taxAmount;
  num? couponDiscountAmount;
  String? dateTimeVal;
  String? couponId;
  num? qty;
  String? address;
  int? bookingAddressId;
  CouponData? appliedCouponData;

  //Local
  bool get isHourlyService => type.validate() == SERVICE_TYPE_HOURLY;

  String? subCategoryName;

  ServiceData(
      {this.id,
      this.name,
      this.imageAttachments,
      this.categoryId,
      this.providerId,
      this.price,
      this.priceFormat,
      this.type,
      this.discount,
      this.duration,
      this.status,
      this.description,
      this.isFeatured,
      this.providerName,
      this.providerImage,
      this.cityId,
      this.categoryName,
      this.attchments,
      this.totalReview,
      this.totalRating,
      this.isFavourite,
      this.serviceAddressMapping,
      this.totalAmount,
      this.discountPrice,
      this.taxAmount,
      this.couponDiscountAmount,
      this.dateTimeVal,
      this.couponId,
      this.qty,
      this.address,
      this.bookingAddressId,
      this.appliedCouponData});

  //Service({this.id, this.name, this.categoryId, this.providerId, this.price, this.priceFormat, this.type, this.discount, this.duration, this.status, this.description, this.isFeatured, this.providerName, this.cityId, this.categoryName, this.attchments, this.totalReview, this.totalRating, this.isFavourite, this.serviceAddressMapping, this.providerImage});

  ServiceData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    providerImage = json['provider_image'];
    categoryId = json['category_id'];
    providerId = json['provider_id'];
    price = json['price'];
    priceFormat = json['price_format'];
    type = json['type'];
    discount = json['discount'];
    duration = json['duration'];
    status = json['status'];
    description = json['description'];
    isFeatured = json['is_featured'];
    providerName = json['provider_name'];
    cityId = json['city_id'];
    categoryName = json['category_name'];
    //image_attchments = json['attchments'];
    imageAttachments = json['attchments'] != null ? List<String>.from(json['attchments']) : null;
    attchments = json['attchments_array'] != null ? (json['attchments_array'] as List).map((i) => Attachments.fromJson(i)).toList() : null;

    totalReview = json['total_review'];
    totalRating = json['total_rating'];
    isFavourite = json['is_favourite'];
    if (json['service_address_mapping'] != null) {
      serviceAddressMapping = [];
      json['service_address_mapping'].forEach((v) {
        serviceAddressMapping!.add(new ServiceAddressMapping.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['provider_image'] = this.providerImage;
    data['category_id'] = this.categoryId;
    data['provider_id'] = this.providerId;
    data['price'] = this.price;
    data['price_format'] = this.priceFormat;
    data['type'] = this.type;
    data['discount'] = this.discount;
    data['duration'] = this.duration;
    data['status'] = this.status;
    data['description'] = this.description;
    data['is_featured'] = this.isFeatured;
    data['provider_name'] = this.providerName;
    data['city_id'] = this.cityId;
    data['category_name'] = this.categoryName;
    if (this.imageAttachments != null) {
      data['attchments'] = this.imageAttachments;
    }
    data['total_review'] = this.totalReview;
    data['total_rating'] = this.totalRating;
    data['is_favourite'] = this.isFavourite;
    if (this.serviceAddressMapping != null) {
      data['service_address_mapping'] = this.serviceAddressMapping!.map((v) => v.toJson()).toList();
    }
    if (this.attchments != null) {
      data['attchments_array'] = this.attchments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
