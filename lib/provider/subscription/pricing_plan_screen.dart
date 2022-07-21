import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/background_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/plan_request_model.dart';
import 'package:handyman_provider_flutter/models/provider_subscription_model.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/payment/payment_screen.dart';
import 'package:handyman_provider_flutter/provider/provider_dashboard_screen.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class PricingPlanScreen extends StatefulWidget {
  const PricingPlanScreen({Key? key}) : super(key: key);

  @override
  _PricingPlanScreenState createState() => _PricingPlanScreenState();
}

class _PricingPlanScreenState extends State<PricingPlanScreen> {
  List<ProviderSubscriptionModel> pricingPlanList = [];

  ProviderSubscriptionModel? selectedPricingPlan;

  int currentSelectedPlan = -1;

  bool hasError = false;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      init();
    });
  }

  void init() async {
    appStore.setLoading(true);

    await getPricingPlanList().then((value) {
      appStore.setLoading(false);
      hasError = false;

      pricingPlanList = value.data.validate();

      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      hasError = true;
      toast(e.toString(), print: true);
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        init();
        return 1.seconds.delay;
      },
      child: Scaffold(
        appBar: appBarWidget(context.translate.lblPricingPlan, backWidget: BackWidget(), elevation: 0, color: primaryColor, textColor: Colors.white),
        body: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  42.height,
                  Text(context.translate.lblSelectPlan, style: boldTextStyle(size: 18)),
                  24.height,
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 90, top: 8, right: 8, left: 8),
                    itemCount: pricingPlanList.length,
                    itemBuilder: (_, index) {
                      ProviderSubscriptionModel data = pricingPlanList[index];

                      return AnimatedContainer(
                        duration: 500.milliseconds,
                        decoration: boxDecorationWithRoundedCorners(
                          borderRadius: radius(),
                          backgroundColor: context.scaffoldBackgroundColor,
                          border: Border.all(color: currentSelectedPlan == index ? primaryColor : context.dividerColor, width: 1.5),
                        ),
                        margin: EdgeInsets.all(8),
                        width: context.width(),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    currentSelectedPlan == index
                                        ? AnimatedContainer(
                                            duration: 500.milliseconds,
                                            decoration: BoxDecoration(
                                              color: context.primaryColor,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.grey.shade300),
                                            ),
                                            padding: EdgeInsets.all(2),
                                            child: Icon(Icons.check, color: Colors.white, size: 16),
                                          )
                                        : AnimatedContainer(
                                            duration: 500.milliseconds,
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.grey.shade300),
                                            ),
                                            padding: EdgeInsets.all(2),
                                            child: Icon(Icons.check, color: Colors.transparent, size: 16),
                                          ),
                                    16.width,
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text('${data.identifier.capitalizeFirstLetter()}', style: boldTextStyle()),
                                            if (data.trialPeriod.validate() != 0 && data.identifier == FREE)
                                              RichText(
                                                text: TextSpan(
                                                  text: ' (Trial for ',
                                                  style: secondaryTextStyle(),
                                                  children: <TextSpan>[
                                                    TextSpan(text: '${data.trialPeriod.validate()}', style: boldTextStyle()),
                                                    TextSpan(text: '  day(s))', style: secondaryTextStyle()),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                        8.height,
                                        Text(data.title.validate().capitalizeFirstLetter(), style: secondaryTextStyle()),
                                      ],
                                    ),
                                  ],
                                ).flexible(),
                                Container(
                                  decoration: BoxDecoration(color: context.primaryColor, borderRadius: radius()),
                                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  child: Text(
                                    data.identifier == FREE
                                        ? 'Free Trial'
                                        : "${appStore.currencySymbol}${data.amount.validate().toStringAsFixed(DECIMAL_POINT).formatNumberWithComma()}/${data.type.validate()}",
                                    style: boldTextStyle(color: white, size: 12),
                                  ),
                                ),
                              ],
                            ),
                            if (data.planLimitation != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  16.height,
                                  Container(
                                    decoration: boxDecorationWithRoundedCorners(
                                      backgroundColor: context.cardColor,
                                      borderRadius: radius(),
                                    ),
                                    padding: EdgeInsets.all(16),
                                    width: context.width(),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(getPlanStatusImage(limitData: data.planLimitation!.service!), width: 14, height: 14),
                                            8.width,
                                            getPlanStatus(limitData: data.planLimitation!.service!, name: 'Services'),
                                          ],
                                        ),
                                        8.height,
                                        Row(
                                          children: [
                                            Image.asset(getPlanStatusImage(limitData: data.planLimitation!.handyman!), width: 14, height: 14),
                                            8.width,
                                            getPlanStatus(limitData: data.planLimitation!.handyman!, name: 'Handyman'),
                                          ],
                                        ),
                                        8.height,
                                        Row(
                                          children: [
                                            Image.asset(getPlanStatusImage(limitData: data.planLimitation!.featuredService!), width: 14, height: 14),
                                            8.width,
                                            getPlanStatus(limitData: data.planLimitation!.featuredService!, name: 'Featured Services'),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              )
                          ],
                        ).onTap(() {
                          selectedPricingPlan = data;
                          currentSelectedPlan = index;

                          setState(() {});
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (selectedPricingPlan != null)
              Positioned(
                bottom: 32,
                left: 16,
                right: 16,
                child: AppButton(
                  child:
                      Text(selectedPricingPlan!.identifier == FREE ? context.translate.lblProceed.toUpperCase() : context.translate.lblMakePayment.toUpperCase(), style: boldTextStyle(color: white)),
                  color: primaryColor,
                  onTap: () async {
                    if (selectedPricingPlan!.identifier == FREE) {
                      PlanRequestModel planRequestModel = PlanRequestModel()
                        ..amount = selectedPricingPlan!.amount
                        ..description = selectedPricingPlan!.description
                        ..duration = selectedPricingPlan!.duration
                        ..identifier = selectedPricingPlan!.identifier
                        ..otherTransactionDetail = ''
                        ..paymentStatus = 'paid'
                        ..paymentType = ""
                        ..planId = selectedPricingPlan!.id
                        ..planLimitation = selectedPricingPlan!.planLimitation
                        ..planType = selectedPricingPlan!.planType
                        ..title = selectedPricingPlan!.title
                        ..txnId = ''
                        ..type = selectedPricingPlan!.type
                        ..userId = appStore.userId;

                      log('Request : ${planRequestModel.toJson()}');
                      appStore.setLoading(true);

                      await saveSubscription(planRequestModel.toJson()).then((value) {
                        appStore.setLoading(false);
                        toast("${selectedPricingPlan!.title.validate()} is successFully activated");

                        push(ProviderDashboardScreen(index: 0), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
                      }).catchError((e) {
                        appStore.setLoading(false);
                        log(e.toString());
                      });
                    } else {
                      PaymentScreen(selectedPricingPlan!).launch(context);
                    }
                  },
                ),
              ),
            Observer(builder: (_) => BackgroundComponent().center().visible(!appStore.isLoading && pricingPlanList.isEmpty && !hasError)),
            Text(errorSomethingWentWrong, style: secondaryTextStyle()).center().visible(hasError),
            Observer(builder: (_) => LoaderWidget().center().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }

  Widget getPlanStatus({required LimitData limitData, required String name}) {
    if (limitData.isChecked == null) {
      return RichTextWidget(
        list: [
          TextSpan(text: 'Unlimited $name', style: primaryTextStyle()),
        ],
      );
    } else if (limitData.isChecked.validate() == 'on' && (limitData.limit == null || limitData.limit == "0")) {
      return RichTextWidget(
        list: [
          TextSpan(text: 'Add $name upto ', style: primaryTextStyle(decoration: TextDecoration.lineThrough)),
          TextSpan(text: '0', style: boldTextStyle(color: primaryColor, decoration: TextDecoration.lineThrough)),
        ],
      );
    } else {
      return RichTextWidget(
        list: [
          TextSpan(text: 'Add $name upto ', style: primaryTextStyle()),
          TextSpan(text: '${limitData.limit.validate()}', style: boldTextStyle(color: primaryColor)),
        ],
      );
    }
  }

  String getPlanStatusImage({required LimitData limitData}) {
    if (limitData.isChecked == null) {
      return pricing_plan_accept;
    } else if (limitData.isChecked.validate() == 'on' && (limitData.limit == null || limitData.limit == "0")) {
      return pricing_plan_reject;
    } else {
      return pricing_plan_accept;
    }
  }
}
