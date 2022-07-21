import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class BackgroundComponent extends StatelessWidget {
  final String? image;
  final String? text;
  final double? size;

  BackgroundComponent({this.image, this.text, this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.height(),
      width: context.width(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image ?? notDataFoundImg,
            height: size ?? 100,
          ),
          30.height,
          Text(text ?? context.translate.lblNoDataFound, style: boldTextStyle(size: 20), textAlign: TextAlign.center),
        ],
      ),
    ).center();
  }
}
