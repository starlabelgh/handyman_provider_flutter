import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/dashboard_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/components/chart_component.dart';
import 'package:handyman_provider_flutter/provider/components/commission_component.dart';
import 'package:handyman_provider_flutter/provider/components/handyman_list_component.dart';
import 'package:handyman_provider_flutter/provider/components/handyman_recently_online_component.dart';
import 'package:handyman_provider_flutter/provider/components/services_list_component.dart';
import 'package:handyman_provider_flutter/provider/components/total_component.dart';
import 'package:handyman_provider_flutter/provider/subscription/pricing_plan_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:nb_utils/nb_utils.dart';

class ProviderHomeFragment extends StatefulWidget {
  @override
  _ProviderHomeFragmentState createState() => _ProviderHomeFragmentState();
}

class _ProviderHomeFragmentState extends State<ProviderHomeFragment> {
  int currentIndex = 0;

  Future<DashboardResponse> future = providerDashboard();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  Widget _buildHeaderWidget(DashboardResponse data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        Text("${context.translate.lblHello}, ${appStore.userFullName}", style: boldTextStyle(size: 20)).paddingLeft(16),
        8.height,
        Text(context.translate.lblWelcomeBack, style: secondaryTextStyle(size: 16)).paddingLeft(16),
      ],
    );
  }

  Widget planBanner(DashboardResponse data) {
    if (data.isPlanExpired!) {
      return subSubscriptionPlanWidget(
        planBgColor: appStore.isDarkMode ? context.cardColor : Colors.red.shade50,
        planTitle: context.translate.lblPlanExpired,
        planSubtitle: context.translate.lblPlanSubTitle,
        planButtonTxt: context.translate.btnTxtBuyNow,
        btnColor: Colors.red,
        onTap: () {
          PricingPlanScreen().launch(context);
        },
      );
    } else if (data.userNeverPurchasedPlan!) {
      return subSubscriptionPlanWidget(
        planBgColor: appStore.isDarkMode ? context.cardColor : Colors.red.shade50,
        planTitle: context.translate.lblChooseYourPlan,
        planSubtitle: context.translate.lblRenewSubTitle,
        planButtonTxt: context.translate.btnTxtBuyNow,
        btnColor: Colors.red,
        onTap: () {
          PricingPlanScreen().launch(context);
        },
      );
    } else if (data.isPlanAboutToExpire!) {
      int days = getRemainingPlanDays();

      if (days != 0 && days <= PLAN_REMAINING_DAYS) {
        return subSubscriptionPlanWidget(
          planBgColor: appStore.isDarkMode ? context.cardColor : Colors.orange.shade50,
          planTitle: context.translate.lblReminder,
          planSubtitle: context.translate.planAboutToExpire(days),
          planButtonTxt: context.translate.lblRenew,
          btnColor: Colors.orange,
          onTap: () {
            PricingPlanScreen().launch(context);
          },
        );
      } else {
        return SizedBox();
      }
    } else {
      return SizedBox();
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
        future = providerDashboard();
        return await 2.seconds.delay;
      },
      child: Scaffold(
        body: Stack(
          children: [
            FutureBuilder<DashboardResponse>(
              future: future,
              builder: (context, snap) {
                if (snap.hasError) {
                  return Text(snap.error.toString()).center();
                } else if (snap.hasData) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 16),
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((snap.data!.earningType == EARNING_TYPE_SUBSCRIPTION)) planBanner(snap.data!),
                        _buildHeaderWidget(snap.data!),
                        if (snap.data!.earningType == EARNING_TYPE_COMMISSION) CommissionComponent(commission: snap.data!.commission!),
                        TotalComponent(snap: snap.data!),
                        ChartComponent(),
                        if (snap.data!.onlineHandyman!.isNotEmpty) HandymanRecentlyOnlineComponent(images: snap.data!.onlineHandyman.validate()),
                        HandymanListComponent(list: snap.data!.handyman.validate()),
                        ServiceListComponent(list: snap.data!.service.validate()),
                      ],
                    ),
                  );
                }

                return snapWidgetHelper(snap, loadingWidget: LoaderWidget());
              },
            ),
            Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading))
          ],
        ),
      ),
    );
  }
}
