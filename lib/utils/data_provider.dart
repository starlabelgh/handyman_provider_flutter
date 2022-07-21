import 'package:flutter/cupertino.dart';
import 'package:handyman_provider_flutter/models/about_model.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/images.dart';

List<AboutModel> getAboutDataModel({BuildContext? context}) {
  List<AboutModel> aboutList = [];

  aboutList.add(AboutModel(title: context!.translate.lblTermsAndConditions, image: termCondition));
  aboutList.add(AboutModel(title: context.translate.lblPrivacyPolicy, image: privacy_policy));
  aboutList.add(AboutModel(title: context.translate.lblHelpAndSupport, image: termCondition));
  aboutList.add(AboutModel(title: context.translate.lblHelpLineNum, image: calling));
  aboutList.add(AboutModel(title: context.translate.lblRateUs, image: rateUs));

  return aboutList;
}
