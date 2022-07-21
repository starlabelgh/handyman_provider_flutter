import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController oldPasswordCont = TextEditingController();
  TextEditingController newPasswordCont = TextEditingController();
  TextEditingController reenterPasswordCont = TextEditingController();

  FocusNode oldPasswordFocus = FocusNode();
  FocusNode newPasswordFocus = FocusNode();
  FocusNode reenterPasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> changePassword() async {
    await setValue(USER_PASSWORD, newPasswordCont.text);

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);
      appStore.setLoading(true);

      var request = {
        UserKeys.oldPassword: oldPasswordCont.text,
        UserKeys.newPassword: newPasswordCont.text,
      };

      await changeUserPassword(request).then(
        (res) async {
          await authService.changePassword(newPasswordCont.text.trim()).catchError((e) {
            //
          });

          appStore.setLoading(false);
          toast(res.message);
          finish(context);
        },
      ).catchError(
        (e) {
          toast(e.toString(), print: true);
          appStore.setLoading(false);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        context.translate.changePassword,
        backWidget: BackWidget(),
        showBack: true,
        textColor: white,
        color: context.primaryColor,
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Container(
              height: context.height(),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    16.height,
                    AppTextField(
                      textFieldType: TextFieldType.PASSWORD,
                      controller: oldPasswordCont,
                      focus: oldPasswordFocus,
                      suffixPasswordVisibleWidget: ic_show.iconImage(size: 10).paddingAll(14),
                      suffixPasswordInvisibleWidget: ic_hide.iconImage(size: 10).paddingAll(14),
                      validator: (s) {
                        if (s!.isEmpty)
                          return context.translate.lblRequired;
                        else
                          return null;
                      },
                      nextFocus: newPasswordFocus,
                      decoration: inputDecoration(context, hint: context.translate.hintOldPasswordTxt),
                    ),
                    16.height,
                    AppTextField(
                      textFieldType: TextFieldType.PASSWORD,
                      controller: newPasswordCont,
                      focus: newPasswordFocus,
                      suffixPasswordVisibleWidget: ic_show.iconImage(size: 10).paddingAll(14),
                      suffixPasswordInvisibleWidget: ic_hide.iconImage(size: 10).paddingAll(14),
                      validator: (s) {
                        if (s!.isEmpty)
                          return context.translate.lblRequired;
                        else
                          return null;
                      },
                      nextFocus: reenterPasswordFocus,
                      decoration: inputDecoration(context, hint: context.translate.hintNewPasswordTxt),
                    ),
                    16.height,
                    AppTextField(
                      textFieldType: TextFieldType.PASSWORD,
                      controller: reenterPasswordCont,
                      focus: reenterPasswordFocus,
                      suffixPasswordVisibleWidget: ic_show.iconImage(size: 10).paddingAll(14),
                      suffixPasswordInvisibleWidget: ic_hide.iconImage(size: 10).paddingAll(14),
                      validator: (v) {
                        if (newPasswordCont.text != v) {
                          return context.translate.passwordNotMatch;
                        } else if (reenterPasswordCont.text.isEmpty) {
                          return context.translate.lblRequired;
                        }
                        return null;
                      },
                      onFieldSubmitted: (s) {
                        ifNotTester(context, () {
                          changePassword();
                        });
                      },
                      decoration: inputDecoration(context, hint: context.translate.hintReenterPasswordTxt),
                    ),
                    24.height,
                    AppButton(
                      text: context.translate.confirm,
                      height: 40,
                      color: primaryColor,
                      textStyle: primaryTextStyle(color: white),
                      width: context.width() - context.navigationBarHeight,
                      onTap: () {
                        ifNotTester(context, () {
                          changePassword();
                        });
                      },
                    ),
                    24.height,
                  ],
                ),
              ),
            ),
          ),
          Observer(builder: (_) => LoaderWidget().center().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
