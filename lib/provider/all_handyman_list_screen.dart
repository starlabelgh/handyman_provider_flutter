import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/background_component.dart';
import 'package:handyman_provider_flutter/components/register_user_form_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/components/handyman_list_widget.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:nb_utils/nb_utils.dart';

///No Use
class AllHandymanListScreen extends StatefulWidget {
  const AllHandymanListScreen({Key? key}) : super(key: key);

  @override
  _AllHandymanListScreenState createState() => _AllHandymanListScreenState();
}

class _AllHandymanListScreenState extends State<AllHandymanListScreen> {
  ScrollController scrollController = ScrollController();
  List<UserData> userData = [];
  bool afterInit = false;

  int totalPage = 0;
  int currentPage = 1;
  int totalItems = 0;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();

    afterBuildCreated(() {
      setStatusBarColor(context.primaryColor);
      appStore.setLoading(true);
      init();
    });
  }

  Future<void> init() async {
    scrollController.addListener(() {
      scrollHandler();
    });
    getHandymanList();
  }

  scrollHandler() {
    if (currentPage <= totalPage) {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !appStore.isLoading) {
        currentPage++;
        appStore.setLoading(true);
        getHandymanList();
      }
    }
  }

  Future<void> getHandymanList() async {
    await getHandyman(page: currentPage, isPagination: true, providerId: appStore.userId).then((value) {
      appStore.setLoading(false);
      totalItems = value.pagination!.totalItems;
      if (!mounted) return;

      if (currentPage == 1) {
        userData.clear();
      }
      if (totalItems != 0) {
        userData.addAll(value.data!);

        totalPage = value.pagination!.totalPages!;
        currentPage = value.pagination!.currentPage!;
      }
      afterInit = true;
      setState(() {});
    }).catchError((e) {
      if (!mounted) return;
      toast(e.toString(), print: true);
      appStore.setLoading(false);
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
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          currentPage = 1;

          return await getHandymanList();
        },
        child: Scaffold(
          appBar: appBarWidget(
            context.translate.lblAllHandyman,
            textColor: white,
            color: context.primaryColor,
            showBack: true,
            backWidget: BackWidget(),
            actions: [
              IconButton(
                icon: Icon(Icons.add, size: 28, color: white),
                tooltip: context.translate.lblAddHandyman,
                onPressed: () async {
                  bool? res = await RegisterUserFormComponent(userType: USER_TYPE_HANDYMAN).launch(context);
                  if (res ?? false) {
                    userData.clear();
                    currentPage = 1;

                    appStore.setLoading(true);
                    await getHandymanList();
                  }
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              ListView.builder(
                padding: EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 8),
                controller: scrollController,
                itemCount: userData.length,
                physics: AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (_, index) {
                  return HandymanListWidget(
                    data: userData[index],
                    onUpdate: () async {
                      userData.clear();
                      appStore.setLoading(true);
                      currentPage = 1;

                      await getHandymanList();
                    },
                  );
                },
              ).visible(userData.isNotEmpty),
              Observer(builder: (_) => BackgroundComponent().center()).visible(!appStore.isLoading && userData.isEmpty && afterInit),
              Observer(builder: (_) => LoaderWidget().center().visible(appStore.isLoading)),
            ],
          ),
        ),
      ),
    );
  }
}
