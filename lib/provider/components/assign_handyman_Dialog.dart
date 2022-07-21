import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/handyman_name_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

class AssignHandymanDialog extends StatefulWidget {
  final int? bookingId;
  final Function? onUpdate;
  final int? serviceAddressId;

  AssignHandymanDialog({this.bookingId, this.onUpdate, this.serviceAddressId});

  @override
  _AssignHandymanDialogState createState() => _AssignHandymanDialogState();
}

class _AssignHandymanDialogState extends State<AssignHandymanDialog> {
  List<UserData> userData = [];
  List<UserData> handymanData = [];
  List<UserData> filteredData = [];
  List<int> assignedHandyman = [];

  UserData? userListData;

  bool afterInit = false;

  @override
  void initState() {
    super.initState();
    init();

    afterBuildCreated(() {
      appStore.setLoading(true);
    });
  }

  Future<void> init() async {
    await getHandyman(isPagination: false, providerId: appStore.userId).then((res) {
      appStore.setLoading(false);

      if (res.data != null && res.data!.isNotEmpty) {
        handymanData.addAll(res.data!);
      }

      for (int i = 0; i < handymanData.length; i++) {
        if (handymanData[i].status == 1) {
          log('${handymanData[i].serviceAddressId} ${widget.serviceAddressId}');
          if (handymanData[i].serviceAddressId == widget.serviceAddressId) {
            userData.add(handymanData[i]);

            setState(() {});
          }
        }
      }

      afterInit = true;
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      if (!mounted) return;
      toast(e.toString(), print: true);
    });
  }

  Future<void> assignHandyman() async {
    var request = {
      CommonKeys.id: widget.bookingId,
      CommonKeys.handymanId: assignedHandyman,
    };
    appStore.setLoading(true);
    await assignBooking(request).then((res) async {
      appStore.setLoading(false);
      widget.onUpdate?.call();
      finish(context);
      toast(res.message);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.serviceAddressId != null) {
      filteredData = userData;
    } else {
      filteredData = handymanData;
    }

    return Dialog(
      child: SizedBox(
        height: context.height() * 0.7,
        child: Stack(
          children: [
            Column(
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
                      Text(context.translate.lblAssignHandyman, style: boldTextStyle(color: white, size: 18)),
                      IconButton(
                        onPressed: () {
                          finish(context);
                        },
                        icon: Icon(Icons.close, size: 22, color: white),
                      ),
                    ],
                  ),
                ),
                ListView.separated(
                  itemCount: filteredData.length,
                  separatorBuilder: (context, _) => Divider(endIndent: 16.0, indent: 16.0, color: gray.withOpacity(0.3), height: 0),
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 8, bottom: 90),
                  itemBuilder: (context, index) {
                    return RadioListTile<UserData>(
                      value: filteredData[index],
                      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                      controlAffinity: ListTileControlAffinity.trailing,
                      groupValue: userListData,
                      title: Row(
                        children: [
                          cachedImage(
                            filteredData[index].profileImage!.isNotEmpty ? filteredData[index].profileImage.validate() : "",
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ).cornerRadiusWithClipRRect(30),
                          16.width,
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Marquee(
                                child: HandymanNameWidget(
                                  size: 14,
                                  name: filteredData[index].displayName.validate(),
                                  isHandymanAvailable: filteredData[index].isHandymanAvailable,
                                ),
                              ),
                              8.height,
                              Text(
                                "${context.translate.lblMemberSince} ${DateTime.parse(filteredData[index].createdAt.validate()).year}",
                                style: secondaryTextStyle(),
                              ),
                            ],
                          ).flexible(),
                        ],
                      ),
                      onChanged: (value) {
                        assignedHandyman.clear();
                        assignedHandyman.add(filteredData[index].id.validate());
                        userListData = value!;

                        setState(() {});
                      },
                      activeColor: primaryColor,
                      selected: true,
                    ).paddingOnly(bottom: 2, top: 2);
                  },
                ).flexible().visible(afterInit && filteredData.isNotEmpty),
                Text(
                  context.translate.noDataFound,
                  style: boldTextStyle(),
                  textAlign: TextAlign.center,
                ).paddingAll(16).visible(!appStore.isLoading && afterInit && filteredData.isEmpty),
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              left: 16,
              child: AppButton(
                onTap: () {
                  if (userListData != null) {
                    if (userListData!.isHandymanAvailable!) {
                      assignHandyman();
                    } else {
                      toast(context.translate.lblHandymanIsOffline);
                    }
                  } else {
                    toast(context.translate.lblSelectHandyman);
                  }
                },
                color: primaryColor,
                width: context.width(),
                text: context.translate.lblAssign,
              ).paddingOnly(bottom: 16).visible(afterInit && filteredData.isNotEmpty),
            ),
            Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
