import 'package:handyman_provider_flutter/models/booking_detail_response.dart';
import 'package:handyman_provider_flutter/models/booking_list_response.dart';
import 'package:handyman_provider_flutter/models/pagination_model.dart';

class PaymentListResponse {
  Pagination? pagination;
  List<Data>? data;

  PaymentListResponse({this.pagination, this.data});

  PaymentListResponse.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null ? new Pagination.fromJson(json['pagination']) : null;
    if (json['data'] != null) {
      data = (json['data'] as List).map((i) => Data.fromJson(i)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  int? bookingId;
  int? customerId;
  num? totalAmount;
  String? paymentStatus;
  String? paymentMethod;
  String? customerName;
  int? quantity;
  CouponData? couponData;
  List<TaxData>? taxes;
  num? discount;
  num? price;

  Data({
    this.id,
    this.bookingId,
    this.customerId,
    this.totalAmount,
    this.paymentStatus,
    this.paymentMethod,
    this.customerName,
    this.quantity,
    this.couponData,
    this.taxes,
    this.discount,
    this.price,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookingId = json['booking_id'];
    customerId = json['customer_id'];
    totalAmount = json['total_amount'];
    paymentStatus = json['payment_status'];
    paymentMethod = json['payment_method'];
    customerName = json['customer_name'];
    quantity = json['quantity'];
    taxes = json['taxes'] != null ? (json['taxes'] as List).map((i) => TaxData.fromJson(i)).toList() : null;
    couponData = json['coupon_data'] != null ? CouponData.fromJson(json['coupon_data']) : null;
    discount = json['discount'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['booking_id'] = this.bookingId;
    data['customer_id'] = this.customerId;
    data['total_amount'] = this.totalAmount;
    data['payment_status'] = this.paymentStatus;
    data['payment_method'] = this.paymentMethod;
    data['customer_name'] = this.customerName;
    data['quantity'] = this.quantity;
    data['discount'] = this.discount;
    data['price'] = this.price;
    if (this.taxes != null) {
      data['taxes'] = this.taxes!.map((v) => v.toJson()).toList();
    }
    if (this.couponData != null) {
      data['coupon_data'] = this.couponData!.toJson();
    }
    return data;
  }
}
