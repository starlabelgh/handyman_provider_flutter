import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/about_model.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/data_provider.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutUsScreen extends StatefulWidget {
  @override
  AboutUsScreenState createState() => AboutUsScreenState();
}

class AboutUsScreenState extends State<AboutUsScreen> {
  int? index;

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
    List<AboutModel> aboutList = getAboutDataModel(context: context);

    return Scaffold(
      appBar: appBarWidget(
        context.translate.lblAbout,
        textColor: white,
        elevation: 0.0,
        backWidget: Icon(Icons.chevron_left, color: white, size: 32).onTap(() {
          finish(context);
        }),
        color: context.primaryColor,
      ),
      body: AnimatedWrap(
        spacing: 16,
        runSpacing: 16,
        itemCount: aboutList.length,
        listAnimationType: ListAnimationType.Scale,
        itemBuilder: (context, index) {
          return Container(
            width: context.width() * 0.5 - 26,
            height: 130,
            padding: EdgeInsets.all(16),
            decoration: boxDecorationWithRoundedCorners(
              borderRadius: radius(),
              backgroundColor: context.cardColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(aboutList[index].image.toString(), height: 28, width: 28, color: context.iconColor),
                16.height,
                Text(aboutList[index].title.toString(), style: boldTextStyle(size: 18)),
              ],
            ),
          ).onTap(
            () async {
              if (index == 0) {
                checkIfLink(context, appStore.termConditions.validate(), title: context.translate.lblTermsAndConditions);
              } else if (index == 1) {
                checkIfLink(context, appStore.privacyPolicy.validate(), title: context.translate.lblPrivacyPolicy);
              } else if (index == 2) {
                checkIfLink(context, appStore.inquiryEmail.validate(), title: context.translate.lblHelpAndSupport);
              } else if (index == 3) {
                checkIfLink(context, appStore.helplineNumber.validate(), title: context.translate.lblHelpLineNum);
              } else if (index == 4) {
                {
                  String package = '';
                  if (isAndroid) package = await getPackageName();
                  commonLaunchUrl('${isAndroid ? playStoreBaseURL : appStoreBaseURL}$package', launchMode: LaunchMode.externalApplication);
                }
              }
            },
            borderRadius: radius(),
          );
        },
      ).paddingAll(16),
    );
  }
}
