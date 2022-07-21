import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/background_component.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/payment_list_reasponse.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/screens/booking_detail_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:nb_utils/nb_utils.dart';

class ProviderPaymentFragment extends StatefulWidget {
  @override
  ProviderPaymentFragmentState createState() => ProviderPaymentFragmentState();
}

class ProviderPaymentFragmentState extends State<ProviderPaymentFragment> {
  ScrollController scrollController = ScrollController();

  List<Data> paymentDataList = [];

  int totalPage = 0;
  int currentPage = 1;
  int totalItems = 0;

  bool hasError = false;
  bool isApiCalled = false;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      appStore.setLoading(true);
      init();
    });
    scrollController.addListener(() {
      if (currentPage <= totalPage) {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
          currentPage++;
          init();
        }
      } else {
        appStore.setLoading(false);
      }
    });
  }

  Future<void> init() async {
    getPayment();
  }

  Future<void> getPayment() async {
    appStore.setLoading(true);

    await getPaymentList(currentPage).then((value) {
      appStore.setLoading(false);
      isApiCalled = true;
      hasError = false;
      totalItems = value.pagination!.totalItems!;

      if (currentPage == 1) {
        paymentDataList.clear();
      }
      if (totalItems >= 1) {
        paymentDataList.addAll(value.data!);
        totalPage = value.pagination!.totalPages!;
        currentPage = value.pagination!.currentPage!;
      }
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      isApiCalled = true;
      hasError = true;
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          currentPage = 1;

          return await getPayment();
        },
        child: Stack(
          children: [
            if (paymentDataList.isNotEmpty)
              AnimatedListView(
                controller: scrollController,
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                itemCount: paymentDataList.length,
                slideConfiguration: SlideConfiguration(verticalOffset: 400),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      CommonBookingDetailScreen(bookingId: paymentDataList[index].bookingId).launch(context);
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 8, bottom: 8),
                      width: context.width(),
                      decoration: cardDecoration(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: boxDecorationWithRoundedCorners(
                              backgroundColor: primaryColor.withOpacity(0.2),
                              borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius),
                            ),
                            width: context.width(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(paymentDataList[index].customerName.validate(), style: boldTextStyle()).flexible(),
                                Text(
                                  '#' + paymentDataList[index].bookingId.validate().toString(),
                                  style: boldTextStyle(color: primaryColor),
                                )
                              ],
                            ),
                          ),
                          4.height,
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(context.translate.lblPaymentID, style: secondaryTextStyle(size: 16)),
                                  Text("#" + paymentDataList[index].id.validate().toString(), style: boldTextStyle()),
                                ],
                              ).paddingSymmetric(vertical: 4),
                              Divider(thickness: 0.9),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(context.translate.paymentStatus, style: secondaryTextStyle(size: 16)),
                                  Text(
                                    paymentDataList[index].paymentStatus.validate().capitalizeFirstLetter(),
                                    style: boldTextStyle(),
                                  ),
                                ],
                              ).paddingSymmetric(vertical: 4),
                              Divider(thickness: 0.9),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(context.translate.paymentMethod, style: secondaryTextStyle(size: 16)),
                                  Text(
                                    (paymentDataList[index].paymentMethod.validate().isNotEmpty ? paymentDataList[index].paymentMethod.validate() : context.translate.notAvailable)
                                        .capitalizeFirstLetter(),
                                    style: boldTextStyle(),
                                  ),
                                ],
                              ).paddingSymmetric(vertical: 4),
                              Divider(thickness: 0.9),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(context.translate.lblAmount, style: secondaryTextStyle(size: 16)),
                                  PriceWidget(
                                    price: calculateTotalAmount(
                                      servicePrice: paymentDataList[index].price.validate(),
                                      qty: paymentDataList[index].quantity.validate(),
                                      couponData: paymentDataList[index].couponData != null ? paymentDataList[index].couponData : null,
                                      taxes: paymentDataList[index].taxes.validate(),
                                      serviceDiscountPercent: paymentDataList[index].discount.validate(),
                                    ),
                                    color: primaryColor,
                                    size: 16,
                                    isBoldText: true,
                                  ),
                                ],
                              ).paddingSymmetric(vertical: 4),
                            ],
                          ).paddingSymmetric(horizontal: 16, vertical: 10),
                          // 8.height,
                        ],
                      ),
                    ),
                  );
                },
              ),
            Text(errorSomethingWentWrong, style: secondaryTextStyle()).center().visible(hasError),
            Observer(builder: (_) => BackgroundComponent().center().visible(!appStore.isLoading && paymentDataList.isEmpty && isApiCalled)),
            Observer(builder: (_) => LoaderWidget().center().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
