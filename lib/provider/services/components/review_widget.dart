import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/image_border_component.dart';
import 'package:handyman_provider_flutter/models/booking_detail_response.dart';
import 'package:handyman_provider_flutter/screens/zoom_image_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

class ReviewWidget extends StatelessWidget {
  final RatingData data;
  final bool isCustomer;
  final bool showServiceName;

  ReviewWidget({required this.data, this.isCustomer = false, this.showServiceName = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 8),
      width: context.width(),
      decoration: boxDecorationDefault(color: context.cardColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageBorder(
                child: circleImage(
                    image: data.profileImage.validate().isNotEmpty ? data.profileImage.validate() : (isCustomer ? data.customerProfileImage.validate() : data.handymanProfileImage.validate()),
                    size: 50),
              ).onTap(() {
                ZoomImageScreen(galleryImages: [
                  data.profileImage.validate().isNotEmpty ? data.profileImage.validate() : (isCustomer ? data.customerProfileImage.validate() : data.handymanProfileImage.validate())
                ], index: 0)
                    .launch(context);
              }),
              16.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${data.customerName.validate()}', style: boldTextStyle(size: 14), maxLines: 1, overflow: TextOverflow.ellipsis).flexible(),
                      Row(
                        children: [
                          Image.asset('assets/icons/ic_star_fill.png', height: 16, color: getRatingBarColor(data.rating.validate().toInt())),
                          4.width,
                          Text('${data.rating.validate().toStringAsFixed(1).toString()}', style: boldTextStyle(color: getRatingBarColor(data.rating.validate().toInt()), size: 14)),
                        ],
                      ),
                    ],
                  ),
                  data.createdAt.validate().isNotEmpty ? Text(formatDate('${DateTime.parse(data.createdAt.validate())}', format: DATE_FORMAT_4), style: secondaryTextStyle()) : SizedBox(),
                  if (showServiceName) Text('Service: ${data.serviceName.validate()}', style: primaryTextStyle(size: 14), maxLines: 1, overflow: TextOverflow.ellipsis).paddingTop(8),
                  if (data.review != null) Text(data.review.validate(), style: secondaryTextStyle()).paddingTop(8),
                ],
              ).flexible(),
            ],
          ),
        ],
      ),
    );
  }
}
