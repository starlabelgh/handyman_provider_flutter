import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/handyman_name_widget.dart';
import 'package:handyman_provider_flutter/components/register_user_form_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

///No Use
class HandymanListWidget extends StatefulWidget {
  final UserData data;
  final Function? onUpdate;

  HandymanListWidget({required this.data, this.onUpdate});

  @override
  State<HandymanListWidget> createState() => _HandymanListWidgetState();
}

class _HandymanListWidgetState extends State<HandymanListWidget> {
  //
  Future<void> changeStatus(int status) async {
    appStore.setLoading(true);
    Map request = {CommonKeys.id: widget.data.id, UserKeys.status: status};

    await updateHandymanStatus(request).then((value) {
      appStore.setLoading(false);
      toast(value.message.toString(), print: true);
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
      widget.data.isActive = !widget.data.isActive;
    });
  }

  Color getStatusBackgroundColor(bool status) {
    if (status) {
      return context.primaryColor;
    } else {
      return context.scaffoldBackgroundColor;
    }
  }

  Color getStatusTextColor(bool status) {
    if (status) {
      return Colors.white;
    } else {
      return context.primaryColor;
    }
  }

  Future<void> removeHandyman(int? id) async {
    appStore.setLoading(true);
    await deleteHandyman(id.validate()).then((value) {
      appStore.setLoading(false);
      widget.onUpdate?.call();

      toast(context.translate.lblTrashHandyman, print: true);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> restoreHandymanData() async {
    appStore.setLoading(true);
    var req = {
      CommonKeys.id: widget.data.id,
      type: RESTORE,
    };

    await restoreHandyman(req).then((value) {
      appStore.setLoading(false);
      toast(value.message);
      widget.onUpdate?.call();
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> forceDeleteHandymanData() async {
    appStore.setLoading(true);
    var req = {
      CommonKeys.id: widget.data.id,
      type: FORCE_DELETE,
    };

    await restoreHandyman(req).then((value) {
      appStore.setLoading(false);
      widget.onUpdate?.call();
      toast(value.message);
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 16),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius(0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              8.height,
              circleImage(image: widget.data.profileImage!.isNotEmpty ? widget.data.profileImage.validate() : '', size: 80),
              16.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      HandymanNameWidget(
                        name: widget.data.displayName.validate(),
                        isHandymanAvailable: widget.data.isHandymanAvailable.validate(),
                      ).expand(),
                      8.width,
                      PopupMenuButton(
                        icon: Icon(Icons.more_horiz, size: 24),
                        onSelected: (selection) async {
                          if (selection == 1) {
                            RegisterUserFormComponent(
                              userType: USER_TYPE_HANDYMAN,
                              data: widget.data,
                              isUpdate: true,
                              onUpdate: () {
                                widget.onUpdate?.call();
                              },
                            ).launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                          } else if (selection == 2) {
                            showConfirmDialogCustom(
                              context,
                              dialogType: DialogType.DELETE,
                              onAccept: (_) {
                                ifNotTester(context, () {
                                  removeHandyman(widget.data.id.validate());
                                });
                              },
                            );
                          } else if (selection == 3) {
                            showConfirmDialogCustom(
                              context,
                              dialogType: DialogType.DELETE,
                              onAccept: (_) {
                                ifNotTester(context, () {
                                  restoreHandymanData();
                                });
                              },
                            );
                          } else if (selection == 4) {
                            showConfirmDialogCustom(
                              context,
                              dialogType: DialogType.DELETE,
                              onAccept: (_) {
                                ifNotTester(context, () {
                                  forceDeleteHandymanData();
                                });
                              },
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Text(context.translate.lblEdit, style: boldTextStyle()),
                            value: 1,
                          ),
                          if (widget.data.deletedAt.validate().isEmpty)
                            PopupMenuItem(
                              child: Text(context.translate.lblDelete, style: boldTextStyle()),
                              value: 2,
                            ),
                          if (widget.data.deletedAt != null)
                            PopupMenuItem(
                              child: Text(context.translate.lblRestore, style: boldTextStyle()),
                              value: 3,
                            ),
                          if (widget.data.deletedAt != null)
                            PopupMenuItem(
                              child: Text(context.translate.lblForceDelete, style: boldTextStyle()),
                              value: 4,
                            ),
                        ],
                      ),
                    ],
                  ),
                  4.height,
                  if (widget.data.email.validate().isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ic_message.iconImage(color: context.iconColor, size: 20),
                            8.width,
                            Text(
                              '${widget.data.email.validate()}',
                              style: primaryTextStyle(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ).flexible()
                          ],
                        ).onTap(() {
                          launchMail(widget.data.email.validate());
                        }),
                        12.height,
                      ],
                    ),
                  if (widget.data.address.validate().isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            servicesAddress.iconImage(color: context.iconColor, size: 20),
                            8.width,
                            Text(
                              '${widget.data.address.validate()}',
                              style: primaryTextStyle(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ).flexible()
                          ],
                        ).onTap(() {
                          commonLaunchUrl('$GOOGLE_MAP_PREFIX${Uri.encodeFull(widget.data.address.validate())}', launchMode: LaunchMode.externalApplication);
                        }),
                        12.height,
                      ],
                    ),
                  if (widget.data.contactNumber.validate().isNotEmpty)
                    Row(
                      children: [
                        calling.iconImage(color: context.iconColor, size: 20),
                        8.width,
                        Text(
                          '${widget.data.contactNumber.validate()}',
                          style: primaryTextStyle(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ).flexible()
                      ],
                    ).onTap(() {
                      launchCall(widget.data.contactNumber.validate());
                    }),
                ],
              ).expand(),
            ],
          ),
          28.height,
          Row(
            children: [
              AppButton(
                child: Text(
                  widget.data.isActive.validate() ? context.translate.lblActivated : context.translate.lblActivate,
                  style: boldTextStyle(color: getStatusTextColor(widget.data.isActive.validate())),
                ),
                width: context.width(),
                color: getStatusBackgroundColor(widget.data.isActive.validate()),
                elevation: 0,
                onTap: () {
                  ifNotTester(context, () {
                    changeStatus(1);
                    widget.data.isActive = true;
                  });
                },
              ).expand(),
              16.width,
              AppButton(
                child: Text(
                  !widget.data.isActive.validate() ? context.translate.lblDeactivated : context.translate.lblDeactivate,
                  style: boldTextStyle(color: getStatusTextColor(!widget.data.isActive.validate())),
                ),
                width: context.width(),
                elevation: 0,
                color: getStatusBackgroundColor(!widget.data.isActive.validate()),
                onTap: () {
                  ifNotTester(context, () {
                    changeStatus(0);
                    widget.data.isActive = false;
                  });
                },
              ).expand(),
            ],
          )
        ],
      ),
    );
  }
}
