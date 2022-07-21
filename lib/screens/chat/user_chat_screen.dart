import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/background_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/chat_message_model.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/networks/firebase_services/chat_messages_service.dart';
import 'package:handyman_provider_flutter/screens/chat/components/chat_item_widget.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class UserChatScreen extends StatefulWidget {
  final UserData receiverUser;

  UserChatScreen({required this.receiverUser});

  @override
  _UserChatScreenState createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  TextEditingController messageCont = TextEditingController();
  FocusNode messageFocus = FocusNode();

  late final UserData senderUser;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if (widget.receiverUser.uid!.isEmpty) {
      appStore.setLoading(true);
      await userService.getUser(email: widget.receiverUser.email.validate()).then((value) {
        widget.receiverUser.uid = value.uid;
      }).catchError((e) {
        log(e.toString());
      });
    }
    senderUser = await userService.getUser(email: appStore.userEmail.validate());
    setState(() {});

    chatMessageService = ChatMessageService();
    await chatMessageService.setUnReadStatusToTrue(senderId: appStore.uId, receiverId: widget.receiverUser.uid!);
    appStore.setLoading(false);
  }

  //region Widget
  Widget _buildChatFieldWidget() {
    return Row(
      children: [
        AppTextField(
          textFieldType: TextFieldType.OTHER,
          controller: messageCont,
          textStyle: primaryTextStyle(),
          minLines: 1,
          onFieldSubmitted: (s) {
            sendMessages();
          },
          focus: messageFocus,
          cursorHeight: 20,
          maxLines: 5,
          cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          decoration: inputDecoration(context, borderRadius: 30).copyWith(
            hintText: context.translate.lblWriteMsg,
            hintStyle: secondaryTextStyle(),
          ),
        ).expand(),
        8.width,
        Container(
          decoration: boxDecorationDefault(borderRadius: radius(80), color: primaryColor),
          child: IconButton(
            icon: Icon(Icons.send, color: Colors.white, size: 24),
            onPressed: () {
              sendMessages();
            },
          ),
        )
      ],
    );
  }

  //endregion

  //region Methods
  Future<void> sendMessages() async {
    // If Message TextField is Empty.
    if (messageCont.text.trim().isEmpty) {
      messageFocus.requestFocus();
      return;
    }

    // Making Request for sending data to firebase
    ChatMessageModel data = ChatMessageModel();

    data.receiverId = widget.receiverUser.uid;
    data.senderId = appStore.uId;
    data.message = messageCont.text;
    data.isMessageRead = false;
    data.createdAt = DateTime.now().millisecondsSinceEpoch;
    data.messageType = MessageType.TEXT.name;

    messageCont.clear();

    await chatMessageService.addMessage(data).then((value) async {
      log("--Message Successfully Added--");

      /// Send Notification
      notificationService.sendPushNotifications(getStringAsync(DISPLAY_NAME), messageCont.text, receiverPlayerId: widget.receiverUser.playerId).catchError((e) {
        log("Notification Error ${e.toString()}");
      });

      await chatMessageService.addMessageToDb(senderRef: value, chatData: data, sender: senderUser, receiverUser: widget.receiverUser).then((value) {
        //
      }).catchError((e) {
        log(e.toString());
      });

      /// Save receiverId to Sender Doc.
      userService.saveToContacts(senderId: appStore.uId, receiverId: widget.receiverUser.uid.validate()).then((value) => log("---ReceiverId to Sender Doc.---")).catchError((e) {
        log(e.toString());
      });

      /// Save senderId to Receiver Doc.
      userService.saveToContacts(senderId: widget.receiverUser.uid.validate(), receiverId: appStore.uId).then((value) => log("---SenderId to Receiver Doc.---")).catchError((e) {
        log(e.toString());
      });
    }).catchError((e) {
      log(e.toString());
    });
  }

  //endregion

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "",
        color: context.primaryColor,
        backWidget: BackWidget(),
        titleWidget: Hero(
          tag: widget.receiverUser.uid.validate(),
          child: Text(widget.receiverUser.displayName.validate(), style: TextStyle(color: whiteColor)),
        ),
      ),
      body: SizedBox(
        height: context.height(),
        width: context.width(),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.asset(chat_default_wallpaper).image,
                  fit: BoxFit.cover,
                  colorFilter: appStore.isDarkMode ? ColorFilter.mode(Colors.black54, BlendMode.luminosity) : ColorFilter.mode(primaryColor, BlendMode.overlay),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 80),
              child: PaginateFirestore(
                reverse: true,
                isLive: true,
                padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
                physics: BouncingScrollPhysics(),
                query: chatMessageService.chatMessagesWithPagination(senderId: appStore.uId, receiverUserId: widget.receiverUser.uid.validate()),
                initialLoader: LoaderWidget(),
                itemsPerPage: PER_PAGE_CHAT_COUNT,
                onEmpty: Text(context.translate.lblNoChatFound, style: boldTextStyle(size: 20)).center(),
                shrinkWrap: true,
                onError: (e) {
                  return BackgroundComponent();
                },
                itemBuilderType: PaginateBuilderType.listView,
                itemBuilder: (context, snap, index) {
                  ChatMessageModel data = ChatMessageModel.fromJson(snap[index].data() as Map<String, dynamic>);
                  data.isMe = data.senderId == appStore.uId;
                  return ChatItemWidget(chatItemData: data);
                },
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: _buildChatFieldWidget(),
            )
          ],
        ),
      ),
    );
  }
}
