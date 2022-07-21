import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/background_component.dart';
import 'package:handyman_provider_flutter/components/view_all_label_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/provider/components/handyman_widget.dart';
import 'package:handyman_provider_flutter/provider/handyman_list_screen.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:nb_utils/nb_utils.dart';

class HandymanListComponent extends StatelessWidget {
  final List<UserData> list;

  HandymanListComponent({required this.list});

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) return Offstage();

    return Container(
      color: context.cardColor,
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ViewAllLabel(
            label: context.translate.handyman,
            subLabel: context.translate.lblShowingOnly4Handyman,
            list: list,
            onTap: () {
              HandymanListScreen().launch(context);
            },
          ),
          16.height,
          Stack(
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: List.generate(
                  list.take(4).length,
                  (index) {
                    return HandymanWidget(
                      data: list[index],
                      width: context.width() * 0.48 - 20,
                      onUpdate: () {},
                    );
                  },
                ),
              ),
              Observer(builder: (context) => BackgroundComponent().center().visible(!appStore.isLoading && list.validate().isEmpty)),
            ],
          ),
        ],
      ),
    );
  }
}
