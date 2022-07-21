import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/background_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/contact_model.dart';
import 'package:handyman_provider_flutter/screens/chat/components/user_item_builder.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class UserChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        context.translate.lblChat,
        textColor: white,
        showBack: Navigator.canPop(context),
        elevation: 3.0,
        backWidget: BackWidget(),
        color: context.primaryColor,
      ),
      body: PaginateFirestore(
        itemBuilder: (context, snap, index) {
          ContactModel contact = ContactModel.fromJson(snap[index].data() as Map<String, dynamic>);
          return UserItemBuilder(userUid: contact.uid.validate());
        },
        options: GetOptions(source: Source.serverAndCache),
        isLive: false,
        padding: EdgeInsets.only(left: 0, top: 8, right: 0, bottom: 0),
        itemsPerPage: PER_PAGE_CHAT_LIST_COUNT,
        separator: Divider(height: 0, indent: 82),
        shrinkWrap: true,
        query: chatMessageService.fetchChatListQuery(userId: appStore.uId),
        onEmpty: BackgroundComponent(),
        initialLoader: LoaderWidget(),
        itemBuilderType: PaginateBuilderType.listView,
        onError: (e) => BackgroundComponent(),
      ),
    );
  }
}
