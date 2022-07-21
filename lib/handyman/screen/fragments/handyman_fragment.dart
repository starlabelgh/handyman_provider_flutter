import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/handyman/component/handyman_comission_component.dart';
import 'package:handyman_provider_flutter/handyman/component/handyman_review_component.dart';
import 'package:handyman_provider_flutter/handyman/component/handyman_total_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/handyman_dashboard_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/components/chart_component.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:nb_utils/nb_utils.dart';

class HandymanHomeFragment extends StatefulWidget {
  const HandymanHomeFragment({Key? key}) : super(key: key);

  @override
  _HandymanHomeFragmentState createState() => _HandymanHomeFragmentState();
}

class _HandymanHomeFragmentState extends State<HandymanHomeFragment> {
  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      init();
    });
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});

          return await 1.seconds.delay;
        },
        child: FutureBuilder<HandymanDashBoardResponse>(
          future: handymanDashboard(),
          builder: (context, snap) {
            if (snap.hasData) {
              return SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: 16, top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${context.translate.lblHello}, ${appStore.userFullName}", style: boldTextStyle(size: 22)).paddingLeft(16),
                    8.height,
                    Text(context.translate.lblWelcomeBack, style: secondaryTextStyle(size: 16)).paddingLeft(16),
                    if (snap.data!.commission != null)
                      Column(
                        children: [
                          32.height,
                          HandymanCommissionComponent(commission: snap.data!.commission!),
                        ],
                      ),
                    8.height,
                    HandymanTotalComponent(snap: snap.data!),
                    8.height,
                    ChartComponent(),
                    16.height,
                    HandymanReviewComponent(reviews: snap.data!.handymanReviews.validate()),
                  ],
                ),
              );
            }
            return snapWidgetHelper(snap, loadingWidget: LoaderWidget());
          },
        ),
      ),
    );
  }
}
