import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geocoding/geocoding.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/background_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/service_address_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

import 'components/service_addresses_component.dart';

class ServiceAddressesScreen extends StatefulWidget {
  final bool? isUpdate;
  final String? updatedAddress;

  ServiceAddressesScreen(this.isUpdate, {this.updatedAddress});

  @override
  ServiceAddressesScreenState createState() => ServiceAddressesScreenState();
}

class ServiceAddressesScreenState extends State<ServiceAddressesScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController addressNameCont = TextEditingController();

  ScrollController scrollController = ScrollController();

  List<AddressResponse> serviceAddressList = [];

  double? destinationLatitude;
  double? destinationLongitude;

  int totalPage = 0;
  int currentPage = 1;
  int totalItems = 0;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      appStore.setLoading(true);
      init();
      scrollController.addListener(() {
        scrollHandler();
      });
    });
  }

  Future<void> init() async {
    getServicesAddressList();
  }

  scrollHandler() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !appStore.isLoading) {
      currentPage++;
      getServicesAddressList();
    }
  }

  Future<void> getServicesAddressList() async {
    appStore.setLoading(true);

    getAddresses(providerId: appStore.userId).then((value) {
      appStore.setLoading(false);
      totalItems = value.pagination!.totalItems;
      if (!mounted) return;
      serviceAddressList.clear();
      if (totalItems != 0) {
        serviceAddressList.addAll(value.addressResponse!);
        print(value);
        totalPage = value.pagination!.totalPages!;
        currentPage = value.pagination!.currentPage!;
      }
      setState(() {});
    }).catchError((e) {
      if (!mounted) return;
      isLastPage = true;
      toast(e.toString(), print: true);
      appStore.setLoading(false);
    });
  }

  Future<void> addAddress() async {
    appStore.setLoading(true);
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);
      List<Location> destinationPlacemark = await locationFromAddress(addressNameCont.text);
      destinationLatitude = destinationPlacemark[0].latitude;
      destinationLongitude = destinationPlacemark[0].longitude;

      if (destinationPlacemark.isNotEmpty) {
        Map request = {
          AddAddressKey.id: '',
          AddAddressKey.providerId: appStore.userId,
          AddAddressKey.latitude: destinationLatitude,
          AddAddressKey.longitude: destinationLongitude,
          AddAddressKey.status: '1',
          AddAddressKey.address: addressNameCont.text,
        };

        await addAddresses(request).then((value) {
          appStore.setLoading(false);
          serviceAddressList.clear();
          currentPage = 1;
          getServicesAddressList();

          addressNameCont.text = '';
          setState(() {});
          finish(context);
        }).catchError((e) {
          appStore.setLoading(false);
          toast(e.toString(), print: true);
        });
      }
    }
  }

  void addAddressDialog() {
    showInDialog(
      context,
      contentPadding: EdgeInsets.all(0),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: boxDecorationWithRoundedCorners(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                backgroundColor: primaryColor,
              ),
              padding: EdgeInsets.only(left: 24, right: 8, bottom: 8, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.translate.lblAddServiceAddress, style: boldTextStyle(color: white), textAlign: TextAlign.justify),
                  IconButton(
                    onPressed: () {
                      finish(context);
                      appStore.setLoading(false);
                    },
                    icon: Icon(Icons.close, size: 22, color: white),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTextField(
                      textFieldType: TextFieldType.MULTILINE,
                      controller: addressNameCont,
                      validator: (s) {
                        if (s!.isEmpty)
                          return errorThisFieldRequired;
                        else
                          return null;
                      },
                      maxLines: 5,
                      minLines: 2,
                      decoration: inputDecoration(context, hint: context.translate.hintAddress),
                    ),
                    24.height,
                    AppButton(
                      text: context.translate.hintAdd,
                      height: 40,
                      color: primaryColor,
                      textStyle: primaryTextStyle(color: white),
                      width: context.width() - context.navigationBarHeight,
                      onTap: () async {
                        ifNotTester(context, () {
                          addAddress();
                        });
                      },
                    ),
                  ],
                ).paddingSymmetric(horizontal: 16, vertical: 24),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        context.translate.lblServiceAddress,
        textColor: white,
        showBack: true,
        backWidget: BackWidget(),
        color: context.primaryColor,
        actions: [
          IconButton(
              onPressed: () {
                addAddressDialog();
              },
              icon: Icon(Icons.add, size: 28, color: white),
              tooltip: context.translate.lblAddServiceAddress),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          serviceAddressList.clear();
          currentPage = 1;
          getServicesAddressList();
          await 2.seconds.delay;
        },
        child: Stack(
          children: [
            if (serviceAddressList.isNotEmpty)
              AnimatedListView(
                physics: AlwaysScrollableScrollPhysics(),
                controller: scrollController,
                itemCount: serviceAddressList.length,
                shrinkWrap: true,
                padding: EdgeInsets.all(16),
                itemBuilder: (_, i) {
                  return ServiceAddressesComponent(
                    serviceAddressList[i],
                    onUpdate: () async {
                      serviceAddressList.removeAt(i);
                      setState(() {});
                    },
                  );
                },
              ),
            Observer(builder: (_) => BackgroundComponent().center().visible(!appStore.isLoading && serviceAddressList.isEmpty)),
            Observer(builder: (_) => LoaderWidget().center().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
