import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/handyman_name_widget.dart';
import 'package:handyman_provider_flutter/components/register_user_form_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/screens/chat/user_chat_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

class HandymanWidget extends StatefulWidget {
  final double width;
  final UserData? data;
  final Function? onUpdate;

  HandymanWidget({required this.width, this.data, this.onUpdate});

  @override
  State<HandymanWidget> createState() => _HandymanWidgetState();
}

class _HandymanWidgetState extends State<HandymanWidget> {
  Future<void> changeStatus(int? id, int status) async {
    appStore.setLoading(true);

    Map request = {CommonKeys.id: id, UserKeys.status: status};

    await updateHandymanStatus(request).then((value) {
      appStore.setLoading(false);

      toast(value.message.toString(), print: true);

      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);

      toast(e.toString(), print: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: widget.width,
          decoration: boxDecorationWithRoundedCorners(borderRadius: radius(), backgroundColor: appStore.isDarkMode ? cardDarkColor : white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: boxDecorationWithRoundedCorners(
                  borderRadius: radius(),
                  backgroundColor: primaryColor.withOpacity(0.2),
                ),
                child: cachedImage(
                  widget.data!.profileImage!.isNotEmpty ? widget.data!.profileImage.validate() : '',
                  width: context.width(),
                  height: 110,
                  fit: BoxFit.cover,
                ).cornerRadiusWithClipRRectOnly(topRight: defaultRadius.toInt(), topLeft: defaultRadius.toInt()),
              ),
              Column(
                children: [
                  HandymanNameWidget(
                    name: widget.data!.displayName.validate(),
                    isHandymanAvailable: widget.data!.isHandymanAvailable,
                    size: 14,
                  ).center(),
                  16.height,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.data!.contactNumber.validate().isNotEmpty)
                        TextIcon(
                          onTap: () {
                            launchCall(widget.data!.contactNumber.validate());
                          },
                          prefix: Container(
                            padding: EdgeInsets.all(8),
                            decoration: boxDecorationWithRoundedCorners(
                              boxShape: BoxShape.circle,
                              backgroundColor: primaryColor.withOpacity(0.1),
                            ),
                            child: Image.asset(calling, color: primaryColor, height: 14, width: 14),
                          ),
                        ),
                      if (widget.data!.email.validate().isNotEmpty)
                        TextIcon(
                          onTap: () {
                            launchMail(widget.data!.email.validate());
                          },
                          prefix: Container(
                            padding: EdgeInsets.all(8),
                            decoration: boxDecorationWithRoundedCorners(
                              boxShape: BoxShape.circle,
                              backgroundColor: primaryColor.withOpacity(0.1),
                            ),
                            child: ic_message.iconImage(size: 14, color: primaryColor),
                          ),
                        ),
                      if (widget.data!.contactNumber.validate().isNotEmpty)
                        TextIcon(
                          onTap: () async {
                            log(widget.data!.email);
                            UserData user = await userService.getUser(email: widget.data!.email.validate()).catchError((e) {
                              log(e.toString());
                            });
                            UserChatScreen(receiverUser: user).launch(context);
                          },
                          prefix: Container(
                            padding: EdgeInsets.all(8),
                            decoration: boxDecorationWithRoundedCorners(
                              boxShape: BoxShape.circle,
                              backgroundColor: primaryColor.withOpacity(0.1),
                            ),
                            child: Image.asset(textMsg, color: primaryColor, height: 14, width: 14),
                          ),
                        ),
                    ],
                  ),
                ],
              ).paddingSymmetric(vertical: 16),
            ],
          ),
        ).onTap(
          () {
            RegisterUserFormComponent(
              userType: USER_TYPE_HANDYMAN,
              data: widget.data!,
              isUpdate: true,
              onUpdate: () {
                widget.onUpdate!.call();
              },
            ).launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
          },
          borderRadius: radius(),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: boxDecorationWithRoundedCorners(
              boxShape: BoxShape.circle,
              backgroundColor: context.cardColor,
            ),
            alignment: Alignment.center,
            child: !widget.data!.isActive ? Image.asset(block, width: 18, height: 18) : Image.asset(unBlock, width: 18, height: 18),
          ).onTap(() {
            ifNotTester(context, () {
              if (!widget.data!.isActive) {
                changeStatus(widget.data!.id, 1);
              } else {
                changeStatus(widget.data!.id, 0);
              }
              widget.data!.isActive = !widget.data!.isActive;
            });
            setState(() {});
          }),
        )
      ],
    );
  }
}
