import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/models/wallet_history_list_response.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

class WalletWidget extends StatefulWidget {
  final WalletHistory data;

  WalletWidget(this.data);

  @override
  WalletWidgetState createState() => WalletWidgetState();
}

class WalletWidgetState extends State<WalletWidget> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: EdgeInsets.all(8),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 1, color: viewLineColor),
        backgroundColor: context.scaffoldBackgroundColor,
      ),
      width: context.width(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.data.activityData!.title.validate(), style: boldTextStyle()),
              8.height,
              Text(formatDate(widget.data.datetime.validate(), format: DATE_FORMAT_2), style: secondaryTextStyle()),
            ],
          ),
          PriceWidget(price: widget.data.activityData!.amount.validate(), color: primaryColor, isBoldText: true)
        ],
      ),
    );
  }
}
