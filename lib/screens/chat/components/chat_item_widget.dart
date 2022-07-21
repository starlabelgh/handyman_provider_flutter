import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/chat_message_model.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

class ChatItemWidget extends StatelessWidget {
  final ChatMessageModel chatItemData;

  ChatItemWidget({required this.chatItemData});

  @override
  Widget build(BuildContext context) {
    String time;

    DateTime date = DateTime.fromMicrosecondsSinceEpoch(chatItemData.createdAt! * 1000);
    if (date.day == DateTime.now().day) {
      time = DateFormat('hh:mm a').format(DateTime.fromMicrosecondsSinceEpoch(chatItemData.createdAt! * 1000));
    } else {
      time = DateFormat('dd-mm-yyyy hh:mm a').format(DateTime.fromMicrosecondsSinceEpoch(chatItemData.createdAt! * 1000));
    }

    Widget chatItem(String? messageTypes) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: chatItemData.isMe! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            chatItemData.message!,
            style: primaryTextStyle(color: chatItemData.isMe! ? Colors.white : textPrimaryColorGlobal),
            maxLines: null,
          ),
          1.height,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: primaryTextStyle(
                  color: !chatItemData.isMe.validate() ? Colors.blueGrey.withOpacity(0.6) : whiteColor.withOpacity(0.6),
                  size: 10,
                ),
              ),
              2.width,
              chatItemData.isMe!
                  ? !chatItemData.isMessageRead!
                      ? Icon(Icons.done, size: 12, color: Colors.white60)
                      : Icon(Icons.done_all, size: 12, color: Colors.white60)
                  : Offstage()
            ],
          ),
        ],
      );
    }

    EdgeInsetsGeometry customPadding(String? messageTypes) {
      return EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    }

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: chatItemData.isMe.validate() ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisAlignment: chatItemData.isMe! ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            margin: chatItemData.isMe.validate()
                ? EdgeInsets.only(top: 0.0, bottom: 0.0, left: isRTL ? 0 : context.width() * 0.25, right: 8)
                : EdgeInsets.only(top: 2.0, bottom: 2.0, left: 8, right: isRTL ? 0 : context.width() * 0.25),
            padding: customPadding(chatItemData.messageType),
            decoration: BoxDecoration(
              boxShadow: appStore.isDarkMode ? null : defaultBoxShadow(),
              color: chatItemData.isMe.validate() ? primaryColor : context.cardColor,
              borderRadius:
                  chatItemData.isMe.validate() ? radiusOnly(bottomLeft: 12, topLeft: 12, bottomRight: 0, topRight: 12) : radiusOnly(bottomLeft: 0, topLeft: 12, bottomRight: 12, topRight: 12),
            ),
            child: chatItem(chatItemData.messageType),
          ),
        ],
      ),
      margin: EdgeInsets.only(top: 2, bottom: 2),
    );
  }
}
