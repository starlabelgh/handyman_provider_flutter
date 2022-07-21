import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/auth/component/dropdown_user_type_component.dart';
import 'package:handyman_provider_flutter/auth/sign_in_screen.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/selected_item_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/user_type_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

bool isNew = false;

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController fNameCont = TextEditingController();
  TextEditingController lNameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController userNameCont = TextEditingController();
  TextEditingController mobileCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  TextEditingController designationCont = TextEditingController();

  FocusNode fNameFocus = FocusNode();
  FocusNode lNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode mobileFocus = FocusNode();
  FocusNode userTypeFocus = FocusNode();
  FocusNode typeFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode designationFocus = FocusNode();

  String? selectedUserTypeValue;
  UserTypeData? selectedUserTypeData;

  bool isAcceptedTc = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {}

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  //region Widgets

  Widget _buildTopWidget() {
    return Column(
      children: [
        Container(
          width: 85,
          height: 85,
          decoration: boxDecorationWithRoundedCorners(boxShape: BoxShape.circle, backgroundColor: primaryColor),
          child: Image.asset(profile, height: 45, width: 45, color: white),
        ),
        16.height,
        Text(context.translate.lblsignuptitle, style: boldTextStyle(size: 22)),
        16.height,
        Text(
          context.translate.lblsignupsubtitle,
          style: secondaryTextStyle(size: 16),
          textAlign: TextAlign.center,
        ).paddingSymmetric(horizontal: 32),
        32.height,
      ],
    );
  }

  Widget _buildFormWidget() {
    return Column(
      children: [
        AppTextField(
          textFieldType: TextFieldType.NAME,
          controller: fNameCont,
          focus: fNameFocus,
          nextFocus: lNameFocus,
          errorThisFieldRequired: context.translate.hintRequired,
          decoration: inputDecoration(context, hint: context.translate.hintFirstNm),
          suffix: profile.iconImage(size: 10).paddingAll(14),
        ),
        16.height,
        AppTextField(
          textFieldType: TextFieldType.NAME,
          controller: lNameCont,
          focus: lNameFocus,
          nextFocus: userNameFocus,
          errorThisFieldRequired: context.translate.hintRequired,
          decoration: inputDecoration(context, hint: context.translate.hintLastNm),
          suffix: profile.iconImage(size: 10).paddingAll(14),
        ),
        16.height,
        AppTextField(
          textFieldType: TextFieldType.USERNAME,
          controller: userNameCont,
          focus: userNameFocus,
          nextFocus: emailFocus,
          errorThisFieldRequired: context.translate.hintRequired,
          decoration: inputDecoration(context, hint: context.translate.hintUserNm),
          suffix: profile.iconImage(size: 10).paddingAll(14),
        ),
        16.height,
        AppTextField(
          textFieldType: TextFieldType.EMAIL,
          controller: emailCont,
          focus: emailFocus,
          nextFocus: mobileFocus,
          errorThisFieldRequired: context.translate.hintRequired,
          decoration: inputDecoration(context, hint: context.translate.hintEmailAddress),
          suffix: ic_message.iconImage(size: 10).paddingAll(14),
        ),
        16.height,
        AppTextField(
          textFieldType: TextFieldType.PHONE,
          controller: mobileCont,
          focus: mobileFocus,
          nextFocus: designationFocus,
          errorThisFieldRequired: context.translate.hintRequired,
          decoration: inputDecoration(context, hint: context.translate.hintContactNumber),
          suffix: calling.iconImage(size: 10).paddingAll(14),
        ),
        16.height,
        AppTextField(
          textFieldType: TextFieldType.USERNAME,
          controller: designationCont,
          isValidationRequired: false,
          focus: designationFocus,
          nextFocus: passwordFocus,
          decoration: inputDecoration(context, hint: context.translate.lblDesignation),
          suffix: profile.iconImage(size: 10).paddingAll(14),
        ),
        16.height,
        DropdownButtonFormField<String>(
          items: [
            DropdownMenuItem(
              child: Text(context.translate.provider, style: primaryTextStyle()),
              value: USER_TYPE_PROVIDER,
            ),
            DropdownMenuItem(
              child: Text(context.translate.handyman, style: primaryTextStyle()),
              value: USER_TYPE_HANDYMAN,
            ),
          ],
          focusNode: userTypeFocus,
          dropdownColor: context.cardColor,
          decoration: inputDecoration(context, hint: context.translate.lblUserType),
          value: selectedUserTypeValue,
          validator: (value) {
            if (value == null) return errorThisFieldRequired;
            return null;
          },
          onChanged: (c) {
            hideKeyboard(context);
            selectedUserTypeValue = c.validate();
            LiveStream().emit(SELECT_USER_TYPE, selectedUserTypeValue);
          },
        ),
        16.height,
        DropdownUserTypeComponent(
          isValidate: true,
          userType: selectedUserTypeValue,
          onValueChanged: (UserTypeData value) {
            selectedUserTypeData = value;
            setState(() {});
          },
        ),
        16.height,
        AppTextField(
          textFieldType: TextFieldType.PASSWORD,
          controller: passwordCont,
          focus: passwordFocus,
          suffixPasswordVisibleWidget: ic_show.iconImage(size: 10).paddingAll(14),
          suffixPasswordInvisibleWidget: ic_hide.iconImage(size: 10).paddingAll(14),
          errorThisFieldRequired: context.translate.hintRequired,
          decoration: inputDecoration(context, hint: context.translate.hintPassword),
          onFieldSubmitted: (s) {
            saveUser();
          },
        ),
        20.height,
        _buildTcAcceptWidget(),
        8.height,
        AppButton(
          text: context.translate.lblsignup,
          height: 40,
          color: primaryColor,
          textStyle: primaryTextStyle(color: white),
          width: context.width() - context.navigationBarHeight,
          onTap: () {
            saveUser();
          },
        ),
      ],
    );
  }

  Widget _buildFooterWidget() {
    return Column(
      children: [
        16.height,
        RichTextWidget(
          list: [
            TextSpan(text: "${context.translate.alreadyHaveAccountTxt} ? ", style: secondaryTextStyle()),
            TextSpan(
              text: context.translate.signIn,
              style: boldTextStyle(color: primaryColor, size: 14),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  finish(context);
                },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTcAcceptWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SelectedItemWidget(isSelected: isAcceptedTc).onTap(() async {
          isAcceptedTc = !isAcceptedTc;
          setState(() {});
        }),
        16.width,
        RichTextWidget(
          list: [
            TextSpan(text: '${context.translate.lblIAgree} ', style: secondaryTextStyle()),
            TextSpan(
              text: context.translate.lblTermsOfService,
              style: boldTextStyle(color: primaryColor, size: 14),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launch(TERMS_CONDITION_URL);
                },
            ),
            TextSpan(text: ' & ', style: secondaryTextStyle()),
            TextSpan(
              text: context.translate.lblPrivacyPolicy,
              style: boldTextStyle(color: primaryColor, size: 14),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launch(PRIVACY_POLICY_URL);
                },
            ),
          ],
        ).flexible(flex: 2),
      ],
    ).paddingAll(16);
  }

  //endregion

  //region Methods
  void saveUser() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);

      if (isAcceptedTc) {
        appStore.setLoading(true);

        var request = {
          UserKeys.firstName: fNameCont.text.trim(),
          UserKeys.lastName: lNameCont.text.trim(),
          UserKeys.userName: userNameCont.text.trim(),
          UserKeys.userType: selectedUserTypeValue,
          UserKeys.contactNumber: mobileCont.text.trim(),
          UserKeys.email: emailCont.text.trim(),
          UserKeys.password: passwordCont.text.trim(),
        };

        if (selectedUserTypeValue == USER_TYPE_PROVIDER) {
          request.putIfAbsent(UserKeys.providerTypeId, () => selectedUserTypeData!.id.toString());
        } else {
          request.putIfAbsent(UserKeys.handymanTypeId, () => selectedUserTypeData!.id.toString());
        }

        log(request);

        await registerUser(request).then((value) async {
          value.data!.password = passwordCont.text.trim();
          value.data!.userType = selectedUserTypeValue;

          await authService.signUpWithEmailPassword(context, registerData: value.data!, isLogin: false).then((value) {
//
          }).catchError((e) {
            if (e.toString() == USER_CANNOT_LOGIN) {
              toast(context.translate.lblLoginAgain);
              SignInScreen().launch(context, isNewTask: true);
            } else if (e.toString() == USER_NOT_CREATED) {
              toast(context.translate.lblLoginAgain);
              SignInScreen().launch(context, isNewTask: true);
            }
          });
        }).catchError((e) {
          appStore.setLoading(false);
          toast(e.toString(), print: true);
        });
      } else {
        appStore.setLoading(false);
        toast(context.translate.lblTermCondition);
      }
    }
  }

  //endregion

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "",
        elevation: 0,
        color: context.scaffoldBackgroundColor,
        systemUiOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: getStatusBrightness(val: appStore.isDarkMode), statusBarColor: context.scaffoldBackgroundColor),
      ),
      body: SizedBox(
        width: context.width(),
        child: Stack(
          children: [
            Form(
              key: formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTopWidget(),
                    _buildFormWidget(),
                    _buildFooterWidget(),
                  ],
                ),
              ),
            ),
            Observer(
              builder: (context) => LoaderWidget().center().visible(appStore.isLoading),
            )
          ],
        ),
      ),
    );
  }
}
