import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/background_component.dart';
import 'package:handyman_provider_flutter/components/total_earning_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/total_earning_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:nb_utils/nb_utils.dart';

class TotalEarningScreen extends StatefulWidget {
  const TotalEarningScreen({Key? key}) : super(key: key);

  @override
  _TotalEarningScreenState createState() => _TotalEarningScreenState();
}

class _TotalEarningScreenState extends State<TotalEarningScreen> {
  ScrollController scrollController = ScrollController();

  List<TotalData> totalEarning = [];

  int totalPage = 0;
  int currentPage = 1;
  int totalItems = 0;

  bool hasError = false;

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
        } else {
          appStore.setLoading(false);
        }
      }
    });
  }

  void init() async {
    getEarningList();
  }

  Future<void> getEarningList() async {
    appStore.setLoading(true);
    await getTotalEarningList(currentPage).then((value) {
      appStore.setLoading(false);
      hasError = false;
      totalItems = value.pagination!.totalItems;

      if (currentPage == 1) {
        totalEarning.clear();
      }
      if (totalItems >= 1) {
        totalEarning.addAll(value.data!);
        totalPage = value.pagination!.totalPages!;
        currentPage = value.pagination!.currentPage!;
      }
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
  void dispose() {
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(context.translate.lblEarningList, backWidget: BackWidget(), elevation: 0, color: primaryColor, textColor: Colors.white),
      body: Stack(
        children: [
          ListView.builder(
            controller: scrollController,
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            itemCount: totalEarning.length,
            itemBuilder: (_, index) {
              return TotalEarningWidget(totalEarning: totalEarning[index]);
            },
          ),
          Observer(builder: (_) => BackgroundComponent().center().visible(!appStore.isLoading && totalEarning.isEmpty && !hasError)),
          Text(errorSomethingWentWrong, style: secondaryTextStyle()).center().visible(hasError),
          Observer(builder: (_) => LoaderWidget().center().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
