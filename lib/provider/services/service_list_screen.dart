import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/background_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/components/service_widget.dart';
import 'package:handyman_provider_flutter/provider/services/add_service_screen.dart';
import 'package:handyman_provider_flutter/provider/services/service_detail_screen.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class ServiceListScreen extends StatefulWidget {
  final int? categoryId;
  final String categoryName;

  ServiceListScreen({this.categoryId, this.categoryName = ''});

  @override
  _ServiceListScreenState createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  ScrollController scrollController = ScrollController();

  TextEditingController searchList = TextEditingController();

  int page = 1;
  int providerId = 0;
  int? categoryId = 0;

  List<ServiceData> mainList = [];

  bool changeList = false;

  bool isEnabled = false;
  bool isLastPage = false;
  bool isApiCalled = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    afterBuildCreated(() => appStore.setLoading(true));

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (!isLastPage) {
          page++;
          fetchAllServices();
        }
      }
      setState(() {});
    });

    fetchAllServices();
  }

  Future<void> fetchAllServices() async {
    await getSearchList(page, search: searchList.text, providerId: appStore.userId).then((value) {
      isApiCalled = true;

      if (page == 1) {
        mainList.clear();
      }
      appStore.setLoading(false);

      isLastPage = value.data!.length != PER_PAGE_ITEM;

      mainList.addAll(value.data!);

      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      isApiCalled = true;

      toast(e.toString());
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
      appBar: appBarWidget(
        widget.categoryName.isEmpty ? context.translate.lblAllService : widget.categoryName.validate(),
        textColor: white,
        color: context.primaryColor,
        backWidget: BackWidget(),
        actions: [
          IconButton(
            onPressed: () {
              changeList = !changeList;
              setState(() {});
            },
            icon: changeList ? Image.asset(list, height: 20, width: 20) : Image.asset(grid, height: 20, width: 20),
          ),
          IconButton(
            onPressed: () async {
              bool? res;

              if (widget.categoryId != null) {
                res = await AddServiceScreen(categoryId: widget.categoryId).launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
              } else {
                res = await AddServiceScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
              }

              if (res ?? false) {
                appStore.setLoading(true);
                page = 1;

                fetchAllServices();
              }
            },
            icon: Icon(Icons.add, size: 28, color: white),
            tooltip: context.translate.lblAddService,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          page = 1;
          return await fetchAllServices();
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  AppTextField(
                    textFieldType: TextFieldType.OTHER,
                    controller: searchList,
                    onFieldSubmitted: (s) {
                      page = 1;
                      fetchAllServices();
                    },
                    decoration: InputDecoration(
                      hintText: context.translate.lblSearchHere,
                      prefixIcon: Icon(Icons.search, color: context.iconColor, size: 20),
                      hintStyle: secondaryTextStyle(),
                      border: OutlineInputBorder(
                        borderRadius: radius(8),
                        borderSide: BorderSide(width: 0, style: BorderStyle.none),
                      ),
                      filled: true,
                      contentPadding: EdgeInsets.all(16),
                      fillColor: appStore.isDarkMode ? cardDarkColor : cardColor,
                    ),
                  ).paddingOnly(left: 16, right: 16, top: 24, bottom: 8),
                  if (mainList.isNotEmpty)
                    Container(
                      alignment: Alignment.topLeft,
                      child: AnimatedWrap(
                        spacing: 16.0,
                        runSpacing: 16.0,
                        listAnimationType: ListAnimationType.Scale,
                        alignment: WrapAlignment.start,
                        itemCount: mainList.length,
                        itemBuilder: (context, index) {
                          return ServiceComponent(
                            data: mainList[index],
                            width: changeList ? context.width() : context.width() * 0.5 - 24,
                          ).onTap(
                            () async {
                              await ServiceDetailScreen(serviceId: mainList[index].id.validate()).launch(context);
                            },
                            borderRadius: radius(),
                          );
                        },
                      ).paddingSymmetric(horizontal: 16, vertical: 24),
                    ),
                ],
              ),
            ),
            Observer(builder: (context) => BackgroundComponent().center().visible(!appStore.isLoading && mainList.validate().isEmpty && isApiCalled)),
            Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading))
          ],
        ),
      ),
    );
  }
}
