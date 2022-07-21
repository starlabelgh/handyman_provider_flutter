import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/components/view_all_label_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/booking_detail_response.dart';
import 'package:handyman_provider_flutter/models/booking_list_response.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

class PriceCommonWidget extends StatelessWidget {
  const PriceCommonWidget({
    Key? key,
    required this.bookingDetail,
    required this.serviceDetail,
    required this.taxes,
    required this.couponData,
  }) : super(key: key);

  final BookingData bookingDetail;
  final ServiceData serviceDetail;
  final List<TaxData> taxes;
  final CouponData? couponData;

  String price(num price) {
    var formatter = NumberFormat('#,##,000.00');
    return formatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //price details
        ViewAllLabel(
          label: context.translate.lblPriceDetail,
          list: [],
        ),
        8.height,
        Container(
          padding: EdgeInsets.all(16),
          width: context.width(),
          decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, borderRadius: radius()),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.translate.hintPrice, style: secondaryTextStyle(size: 16)).expand(),
                  PriceWidget(price: serviceDetail.price.validate(), color: textPrimaryColorGlobal, isBoldText: true, size: 18).flexible(),
                ],
              ),
              if (bookingDetail.type == SERVICE_TYPE_FIXED)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(context.translate.lblSubTotal, style: secondaryTextStyle(size: 16)),
                        8.width,
                        Text(
                          '${appStore.currencySymbol}${price(serviceDetail.price.validate())} * ${bookingDetail.quantity} = ${appStore.currencySymbol}${(price(serviceDetail.price.validate() * bookingDetail.quantity.validate()))}',
                          style: boldTextStyle(size: 18),
                          textAlign: TextAlign.right,
                        ).flexible(),
                      ],
                    ),
                  ],
                ),
              if (taxes.isNotEmpty) Divider(height: 26),
              if (taxes.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(context.translate.lblTax, style: secondaryTextStyle(size: 16)).expand(),
                    PriceWidget(price: serviceDetail.taxAmount.validate(), color: Colors.red, isBoldText: true, size: 18).flexible(),
                  ],
                ),
              if (serviceDetail.discountPrice.validate() != 0 && serviceDetail.discount.validate() != 0)
                Column(
                  children: [
                    Divider(height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(context.translate.hintDiscount, style: secondaryTextStyle(size: 16)),
                            Text(
                              " (${serviceDetail.discount.validate()}% ${context.translate.lblOff})",
                              style: boldTextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                        PriceWidget(
                          price: serviceDetail.discountPrice.validate(),
                          size: 18,
                          color: Colors.green,
                          isBoldText: true,
                          isDiscountedPrice: true,
                        ).flexible(),
                      ],
                    ),
                  ],
                ),
              if (couponData != null) Divider(height: 26),
              if (couponData != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(context.translate.lblCoupon, style: secondaryTextStyle(size: 16)),
                        Text(" (${couponData!.code})", style: secondaryTextStyle(size: 16, color: primaryColor)),
                      ],
                    ),
                    PriceWidget(
                      price: serviceDetail.couponDiscountAmount.validate(),
                      size: 18,
                      color: Colors.green,
                      isBoldText: true,
                    ).flexible(),
                  ],
                ),
              Divider(height: 26),
              Row(
                children: [
                  Text(context.translate.lblTotalAmount, style: secondaryTextStyle(size: 16)).expand(),
                  if (bookingDetail.type == SERVICE_TYPE_HOURLY) Text('(${appStore.currencySymbol}${bookingDetail.price}/hr) ', style: secondaryTextStyle()),
                  PriceWidget(price: getTotalValue, color: primaryColor, size: 18),
                ],
              ),
              if (bookingDetail.type == SERVICE_TYPE_HOURLY && bookingDetail.status == BookingStatusKeys.complete)
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    children: [
                      6.height,
                      Text(
                        "${context.translate.lblOnBasisOf} ${calculateTimer(bookingDetail.durationDiff.validate().toInt())} ${getMinHour(durationDiff: bookingDetail.durationDiff.validate())}",
                        style: secondaryTextStyle(),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        )
      ],
    );
  }

  num get getTotalValue {
    if (bookingDetail.type == SERVICE_TYPE_HOURLY && bookingDetail.status == BookingStatusKeys.complete) {
      return hourlyCalculation(
        price: calculateTotalAmount(
          serviceDiscountPercent: serviceDetail.discount.validate(),
          qty: bookingDetail.quantity!.toInt(),
          detail: serviceDetail,
          servicePrice: serviceDetail.price!,
          taxes: taxes,
          couponData: couponData,
        ),
        secTime: bookingDetail.durationDiff.validate().toInt(),
      );
    }
    return calculateTotalAmount(
      serviceDiscountPercent: serviceDetail.discount.validate(),
      qty: bookingDetail.quantity.validate().toInt(),
      detail: serviceDetail,
      servicePrice: serviceDetail.price!,
      taxes: taxes,
      couponData: couponData,
    );
  }

  String getMinHour({required String durationDiff}) {
    String totalTime = calculateTimer(durationDiff.toInt());
    List<String> totalHours = totalTime.split(":");
    if (totalHours.first == "00") {
      return "min";
    } else {
      return "hour";
    }
  }
}
