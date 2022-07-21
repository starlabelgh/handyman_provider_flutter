import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/service_address_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

class ServiceAddressesComponent extends StatefulWidget {
  final AddressResponse data;
  final Function? onUpdate;

  ServiceAddressesComponent(this.data, {this.onUpdate});

  @override
  ServiceAddressesComponentState createState() => ServiceAddressesComponentState();
}

class ServiceAddressesComponentState extends State<ServiceAddressesComponent> {
  double? destinationLatitude;
  double? destinationLongitude;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  Future<void> updateAddressStatus(int status, String? address, String? lat, String? long, int updateType) async {
    appStore.setLoading(true);
    Map request = {
      AddAddressKey.id: widget.data.id,
      AddAddressKey.providerId: appStore.userId,
      AddAddressKey.latitude: lat,
      AddAddressKey.longitude: long,
      AddAddressKey.status: status,
      AddAddressKey.address: address,
    };
    await addAddresses(request).then((value) {
      if (updateType == 1) {
        widget.data.address = address;
        finish(context);
        setState(() {});
      }
      appStore.setLoading(false);
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> deleteAddress(int? id) async {
    appStore.setLoading(true);
    await removeAddress(id).then((value) {
      appStore.setLoading(false);
      widget.onUpdate?.call();
      toast(value.message);
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> editAddress(int? id) async {
    appStore.setLoading(true);
    await removeAddress(id).then((value) {
      appStore.setLoading(false);
      widget.onUpdate?.call();
      setState(() {});
    });
  }

  void editDialog(String? address) {
    TextEditingController textFieldAddress = TextEditingController(text: address);
    showInDialog(
      context,
      contentPadding: EdgeInsets.all(0),
      builder: (_) {
        return SizedBox(
          height: context.height() * 0.4,
          child: Column(
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
                    Text(context.translate.editAddress, style: boldTextStyle(color: white), textAlign: TextAlign.justify),
                    IconButton(
                      onPressed: () {
                        finish(context);
                      },
                      icon: Icon(Icons.close, size: 22, color: white),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTextField(
                      onChanged: (value) {},
                      controller: textFieldAddress,
                      textFieldType: TextFieldType.MULTILINE,
                      decoration: inputDecoration(context),
                      minLines: 4,
                      maxLines: 10,
                    ),
                    24.height,
                    AppButton(
                      color: primaryColor,
                      height: 40,
                      text: context.translate.lblUpdate,
                      textStyle: boldTextStyle(color: Colors.white),
                      width: context.width() - context.navigationBarHeight,
                      shapeBorder: RoundedRectangleBorder(
                        borderRadius: radius(defaultAppButtonRadius),
                        side: BorderSide(color: viewLineColor),
                      ),
                      onTap: () async {
                        appStore.setLoading(true);
                        try {
                          List<Location> destinationPlacemark = await locationFromAddress(textFieldAddress.text);
                          destinationLatitude = destinationPlacemark[0].latitude;
                          destinationLongitude = destinationPlacemark[0].longitude;

                          ifNotTester(context, () {
                            updateAddressStatus(widget.data.status.validate().toInt(), textFieldAddress.text, destinationLatitude.toString(), destinationLongitude.toString(), 1);
                          });
                        } catch (e) {
                          log(e);
                        }
                      },
                    )
                  ],
                ).paddingSymmetric(horizontal: 16, vertical: 24),
              ),
            ],
          ),
        );
      },
    );
  }

  void deleteDialog() {
    showInDialog(
      context,
      contentPadding: EdgeInsets.all(0),
      builder: (_) {
        return SizedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(delete, width: 110, height: 110, fit: BoxFit.cover),
              32.height,
              Text(context.translate.lblDeleteAddress, style: boldTextStyle(size: 20)),
              16.height,
              Text(context.translate.lblDeleteAddressMsg, style: secondaryTextStyle(), textAlign: TextAlign.center),
              28.height,
              Row(
                children: [
                  AppButton(
                    child: Text(context.translate.lblCancel, style: boldTextStyle()),
                    color: context.cardColor,
                    elevation: 0,
                    onTap: () {
                      finish(context);
                    },
                  ).expand(),
                  16.width,
                  AppButton(
                    child: Text(context.translate.lblDelete, style: boldTextStyle(color: white)),
                    color: primaryColor,
                    elevation: 0,
                    onTap: () async {
                      deleteAddress(widget.data.id);
                      finish(context);
                    },
                  ).expand(),
                ],
              ),
            ],
          ).paddingSymmetric(horizontal: 16, vertical: 28),
        );
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 16),
      margin: EdgeInsets.only(bottom: 16),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: appStore.isDarkMode ? scaffoldDarkColor : cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.data.address.validate(), style: boldTextStyle(), overflow: TextOverflow.ellipsis, maxLines: 4).expand(),
              Switch(
                activeColor: white,
                inactiveThumbColor: white,
                inactiveTrackColor: primaryColor.withOpacity(0.3),
                activeTrackColor: primaryColor,
                value: widget.data.status == 1 ? true : false,
                onChanged: (bool? value) {
                  ifNotTester(context, () {
                    setState(() {
                      if (widget.data.status == 1) {
                        widget.data.status = 0;
                        updateAddressStatus(0, widget.data.address, widget.data.latitude, widget.data.longitude, 0);
                      } else {
                        widget.data.status = 1;
                        updateAddressStatus(1, widget.data.address, widget.data.latitude, widget.data.longitude, 0);
                      }
                    });
                  });
                },
              ).paddingLeft(16),
            ],
          ),
          Row(
            children: [
              Text(context.translate.lblEdit, style: secondaryTextStyle()).onTap(
                () {
                  ifNotTester(context, () {
                    editDialog(widget.data.address);
                  });
                },
              ),
              16.width,
              Text(context.translate.lblDelete, style: secondaryTextStyle()).onTap(
                () {
                  ifNotTester(context, () {
                    deleteDialog();
                  });
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
