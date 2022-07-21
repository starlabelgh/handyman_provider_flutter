import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/screens/chat/components/last_messege_chat.dart';
import 'package:handyman_provider_flutter/screens/chat/user_chat_screen.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:nb_utils/nb_utils.dart';

class UserItemBuilder extends StatefulWidget {
  final String userUid;

  UserItemBuilder({required this.userUid});

  @override
  State<UserItemBuilder> createState() => _UserItemBuilderState();
}

class _UserItemBuilderState extends State<UserItemBuilder> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserData>(
      stream: chatMessageService.getUserDetailsById(id: widget.userUid),
      builder: (context, snap) {
        if (snap.hasData) {
          UserData data = snap.data!;

          return InkWell(
            onTap: () async {
              push(UserChatScreen(receiverUser: snap.data!), pageRouteAnimation: PageRouteAnimation.Fade, duration: 200.milliseconds);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    padding: EdgeInsets.all(10),
                    color: primaryColor,
                    child: Text(data.displayName![0].validate().toUpperCase(), style: secondaryTextStyle(color: Colors.white)).center().fit(),
                  ).cornerRadiusWithClipRRect(50),
                  16.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Hero(
                            tag: data.uid.validate(),
                            child: Text(
                              data.displayName.validate(),
                              style: primaryTextStyle(size: 18),
                              maxLines: 1,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ).expand(),
                          StreamBuilder<int>(
                            stream: chatMessageService.getUnReadCount(senderId: appStore.uId.validate(), receiverId: data.uid!),
                            builder: (context, snap) {
                              if (snap.hasData) {
                                if (snap.data != 0) {
                                  return Container(
                                    height: 18,
                                    width: 18,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: primaryColor),
                                    child: Text(
                                      snap.data.validate().toString(),
                                      style: secondaryTextStyle(size: 12, color: white),
                                    ).fit().center(),
                                  );
                                }
                              }
                              return SizedBox(height: 18, width: 18);
                            },
                          ),
                        ],
                      ),
                      4.height,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LastMessageChat(
                            stream: chatMessageService.fetchLastMessageBetween(senderId: appStore.uId.validate(), receiverId: widget.userUid),
                          ),
                        ],
                      ),
                    ],
                  ).expand(),
                ],
              ),
            ),
          );
        }
        return snapWidgetHelper(snap, errorWidget: Offstage(), loadingWidget: Offstage());
      },
    );
  }
}
