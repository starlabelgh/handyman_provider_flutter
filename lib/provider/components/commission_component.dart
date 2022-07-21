import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/models/dashboard_response.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class CommissionComponent extends StatelessWidget {
  final Commission commission;

  CommissionComponent({required this.commission});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      margin: EdgeInsets.only(top: 24, left: 16, right: 16),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(8),
        backgroundColor: context.cardColor,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichTextWidget(
                textAlign: TextAlign.center,
                list: [
                  TextSpan(text: '${context.translate.lblProviderType}: ', style: secondaryTextStyle(size: 14)),
                  TextSpan(text: '${commission.name.validate()}', style: boldTextStyle(size: 14)),
                ],
              ),
              8.height,
              RichTextWidget(
                textAlign: TextAlign.center,
                list: [
                  TextSpan(text: '${context.translate.lblMyCommission}: ', style: secondaryTextStyle(size: 14)),
                  TextSpan(
                    text: isCommissionTypePercent(commission.type) ? '${commission.commission.validate()} %' : '${getStringAsync(CURRENCY_COUNTRY_SYMBOL)}${commission.commission.validate()}',
                    style: boldTextStyle(size: 14),
                  ),
                  if (isCommissionTypePercent(commission.type)) TextSpan(text: ' (${context.translate.lblFixed})', style: secondaryTextStyle(size: 12)),
                ],
              ),
            ],
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor),
            child: Image.asset(percent_line, height: 22, width: 22, color: white),
          ),
        ],
      ),
    );
  }
}
