import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:nb_utils/nb_utils.dart';

class TotalWidget extends StatelessWidget {
  final String title;
  final String total;
  final String icon;
  final Color? color;

  TotalWidget({required this.title, required this.total, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: cardDecoration(context, showBorder: true),
      width: context.width() / 2 - 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: context.width() / 2 - 94, child: AutoSizeText(total.validate(), style: boldTextStyle(color: primaryColor, size: 20), maxLines: 1)),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: appStore.isDarkMode ? cardDarkColor : primaryColor.withOpacity(0.1),
                ),
                child: Image.asset(icon, width: 18, height: 18, color: primaryColor),
              ),
            ],
          ),
          8.height,
          Text(title, style: secondaryTextStyle(size: 14)),
        ],
      ),
    );
  }
}
