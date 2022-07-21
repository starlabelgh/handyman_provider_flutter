import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/disabled_rating_bar_widget.dart';
import 'package:handyman_provider_flutter/components/image_border_component.dart';
import 'package:handyman_provider_flutter/components/review_list_view_component.dart';
import 'package:handyman_provider_flutter/components/view_all_label_component.dart';
import 'package:handyman_provider_flutter/models/provider_info_model.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/screens/rating_view_all_screen.dart';
import 'package:handyman_provider_flutter/screens/zoom_image_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:nb_utils/nb_utils.dart';

class HandymanInfoScreen extends StatefulWidget {
  final int? handymanId;
  final ServiceData? service;

  HandymanInfoScreen({this.handymanId, this.service});

  @override
  HandymanInfoScreenState createState() => HandymanInfoScreenState();
}

class HandymanInfoScreenState extends State<HandymanInfoScreen> {
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

  Widget aboutWidget({required String desc}) {
    return Text(desc.validate(), style: boldTextStyle());
  }

  Widget emailWidget({required UserData data}) {
    return Container(
      decoration: boxDecorationDefault(color: context.cardColor),
      padding: EdgeInsets.all(16),
      width: context.width(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.translate.lblEmail, style: secondaryTextStyle()),
              4.height,
              Text(data.email.validate(), style: boldTextStyle()),
              24.height,
            ],
          ).onTap(() {
            launchMail(" ${data.email.validate()}");
          }),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.translate.hintContactNumber, style: secondaryTextStyle()),
              4.height,
              Text(data.contactNumber.validate(), style: boldTextStyle()),
              24.height,
            ],
          ).onTap(() {
            launchCall(data.contactNumber.validate());
          }),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.translate.lblMemberSince, style: secondaryTextStyle()),
              4.height,
              Text("${DateTime.parse(data.createdAt.validate()).year}", style: boldTextStyle()),
            ],
          ),
        ],
      ),
    );
  }

  Widget handymanWidget({required HandymanInfoResponse data}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: boxDecorationDefault(
        color: context.cardColor,
        border: Border.all(color: context.dividerColor, width: 1),
        borderRadius: radiusOnly(bottomRight: defaultRadius, bottomLeft: defaultRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (data.handymanData!.profileImage.validate().isNotEmpty)
                ImageBorder(
                  child: circleImage(
                    image: data.handymanData!.profileImage.validate(),
                    size: 90,
                  ),
                ).onTap(() {
                  ZoomImageScreen(galleryImages: [data.handymanData!.profileImage.validate()], index: 0).launch(context);
                }),
              16.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  10.height,
                  Text(data.handymanData!.displayName.validate(), style: boldTextStyle(size: 18)),
                  if (data.handymanData!.designation.validate().isNotEmpty) Text(data.handymanData!.designation.validate(), style: secondaryTextStyle()),
                  10.height,
                  DisabledRatingBarWidget(rating: data.handymanData!.handymanRating.validate().toDouble(), size: 14),
                ],
              ).expand(),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget buildBodyWidget(AsyncSnapshot<HandymanInfoResponse> snap) {
      if (snap.hasError) {
        return Text(snap.error.toString()).center();
      } else if (snap.hasData) {
        log(snap.data!.toJson());
        return Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BasicInfoComponent(0,customerData: snap.data.!,service: widget.service),
                  handymanWidget(data: snap.data!),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      16.height,
                      Text(context.translate.lblAbout, style: boldTextStyle(size: 18)),
                      16.height,
                      if (snap.data!.handymanData!.description.validate().isNotEmpty) aboutWidget(desc: snap.data!.handymanData!.description.validate()),
                      emailWidget(data: snap.data!.handymanData!),
                      16.height,
                      ViewAllLabel(
                        label: context.translate.review,
                        list: snap.data!.handymanRatingReview!,
                        onTap: () {
                          RatingViewAllScreen(handymanId: snap.data!.handymanData!.id).launch(context);
                        },
                      ),
                      snap.data!.handymanRatingReview.validate().isNotEmpty
                          ? ReviewListViewComponent(
                              ratings: snap.data!.handymanRatingReview!,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(vertical: 6),
                              isCustomer: true,
                            )
                          : Text(context.translate.lblNoReviewYet, style: secondaryTextStyle()).center().paddingOnly(top: 16),
                    ],
                  ).paddingAll(16),
                ],
              ),
            ),
          ],
        );
      }
      return LoaderWidget().center();
    }

    return FutureBuilder<HandymanInfoResponse>(
      future: getProviderDetail(widget.handymanId.validate()),
      builder: (context, snap) {
        return Scaffold(
          appBar: appBarWidget(
            context.translate.lblAboutHandyman,
            textColor: white,
            elevation: 1.5,
            color: context.primaryColor,
            backWidget: BackWidget(),
          ),
          body: buildBodyWidget(snap),
        );
      },
    );
  }
}
