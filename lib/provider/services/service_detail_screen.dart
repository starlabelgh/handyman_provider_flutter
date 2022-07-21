import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/review_list_view_component.dart';
import 'package:handyman_provider_flutter/components/view_all_label_component.dart';
import 'package:handyman_provider_flutter/models/booking_detail_response.dart';
import 'package:handyman_provider_flutter/models/service_detail_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/services/components/service_detail_header_component.dart';
import 'package:handyman_provider_flutter/provider/services/components/service_faq_widget.dart';
import 'package:handyman_provider_flutter/screens/rating_view_all_screen.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId;

  ServiceDetailScreen({required this.serviceId});

  @override
  ServiceDetailScreenState createState() => ServiceDetailScreenState();
}

class ServiceDetailScreenState extends State<ServiceDetailScreen> {
  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    setStatusBarColor(transparentColor, delayInMilliSeconds: 1000);
  }

  Widget serviceFaqWidget({required List<ServiceFaq> data}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.height,
          ViewAllLabel(label: context.translate.lblFAQs, list: data),
          8.height,
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: data.length,
            itemBuilder: (_, index) {
              return ServiceFaqWidget(serviceFaq: data[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget customerReviewWidget({required List<RatingData> data, int? serviceId}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        ViewAllLabel(
          label: context.translate.review,
          list: data,
          onTap: () {
            RatingViewAllScreen(serviceId: serviceId).launch(context).then((value) => init());
          },
        ),
        8.height,
        data.isNotEmpty
            ? ReviewListViewComponent(
                ratings: data,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 6),
              )
            : Text(context.translate.lblNoReviewYet, style: secondaryTextStyle()).paddingOnly(top: 16),
      ],
    ).paddingSymmetric(horizontal: 16);
  }


  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildBodyWidget(AsyncSnapshot<ServiceDetailResponse> snap) {
      if (snap.hasError) {
        return Text(snap.error.toString()).center();
      } else if (snap.hasData) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ServiceDetailHeaderComponent(serviceDetail: snap.data!.serviceDetail!),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.translate.hintDescription, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                  16.height,
                  snap.data!.serviceDetail!.description.validate().isNotEmpty
                      ? ReadMoreText(
                          snap.data!.serviceDetail!.description.validate(),
                          style: secondaryTextStyle(),
                        )
                      : Text(context.translate.lblNoDescriptionAvailable, style: secondaryTextStyle()),
                ],
              ).paddingAll(16),
              if (snap.data!.serviceFaq.validate().isNotEmpty) serviceFaqWidget(data: snap.data!.serviceFaq.validate()),
              customerReviewWidget(data: snap.data!.ratingData!, serviceId: snap.data!.serviceDetail!.id),
              24.height,
            ],
          ),
        );
      }
      return LoaderWidget().center();
    }

    return FutureBuilder<ServiceDetailResponse>(
      future: getServiceDetail({'service_id': widget.serviceId.validate()}),
      builder: (context, snap) {
        return Scaffold(
          body: buildBodyWidget(snap),
          floatingActionButton: (snap.hasData && snap.data!.serviceDetail!.isFeatured.validate(value: 0) == 1)
              ? FloatingActionButton(
                  elevation: 0.0,
                  child: Image.asset(featured, height: 22, width: 22, color: white),
                  backgroundColor: primaryColor,
                  onPressed: () {
                    toast(context.translate.lblFeatureProduct);
                  },
                )
              : Offstage(),
        );
      },
    );
  }
}
