import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/spin_kit_chasing_dots.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/booking_list_response.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

Widget cachedImage(
  String? url, {
  double? height,
  double? width,
  BoxFit? fit,
  Color? color,
  String? placeHolderImage,
  AlignmentGeometry? alignment,
  bool usePlaceholderIfUrlEmpty = true,
}) {
  if (url.validate().isEmpty) {
    return Container(
      height: height,
      width: width,
      color: grey.withOpacity(0.1),
      alignment: alignment,
      padding: EdgeInsets.all(10),
      child: Image.asset(ic_no_photo, color: appStore.isDarkMode ? Colors.white : Colors.black),
    );
  } else if (url.validate().startsWith('http')) {
    return CachedNetworkImage(
      placeholder: (_, __) {
        return placeHolderWidget(placeHolderImage: placeHolderImage, height: height, width: width, fit: fit, alignment: alignment);
      },
      imageUrl: url!,
      height: height,
      width: width,
      fit: fit,
      color: color,
      alignment: alignment as Alignment? ?? Alignment.center,
      errorWidget: (_, s, d) {
        return placeHolderWidget(placeHolderImage: placeHolderImage, height: height, width: width, fit: fit, alignment: alignment);
      },
    );
  } else {
    return Image.asset(
      url!,
      height: height,
      width: width,
      fit: fit,
      color: color,
      alignment: alignment ?? Alignment.center,
      errorBuilder: (_, s, d) {
        return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment);
      },
    );
  }
}

Widget placeHolderWidget({String? placeHolderImage, double? height, double? width, BoxFit? fit, AlignmentGeometry? alignment}) {
  return PlaceHolderWidget(
    height: height,
    width: width,
    alignment: alignment ?? Alignment.center,
  );
}

String commonPrice(num price) {
  var formatter = NumberFormat('#,##,000.00');
  return formatter.format(price);
}

class LoaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SpinKitChasingDots(color: primaryColor);
  }
}

Widget aboutCustomerWidget({BuildContext? context, BookingData? bookingDetail}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      //AboutCustomer
      Text(context!.translate.lblAboutCustomer, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
      OutlinedButton(
        child: Text(context.translate.lblGetDirection, style: boldTextStyle(color: primaryColor)),
        onPressed: () {
          commonLaunchUrl('$GOOGLE_MAP_PREFIX${Uri.encodeFull(bookingDetail!.address.validate())}', launchMode: LaunchMode.externalApplication);
        },
      ),
    ],
  );
}
