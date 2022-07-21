import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:nb_utils/nb_utils.dart';

class HandymanTotalWidget extends StatelessWidget {
  final String title;
  final String total;
  final String icon;
  final Color? color;

  HandymanTotalWidget({required this.title, required this.total, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: cardDecoration(context, showBorder: true),
      width: context.width() / 2 - 24,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(total.validate(), style: boldTextStyle(color: primaryColor, size: 20)),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: appStore.isDarkMode ? cardDarkColor : primaryColor.withOpacity(0.1),
                    ),
                    child: Image.asset(icon, width: 20, height: 20, color: primaryColor),
                  ),
                ],
              ),
              8.height,
              Text(title.validate(), style: secondaryTextStyle(size: 12)),
            ],
          ).expand(),
        ],
      ),
    );
  }
}
