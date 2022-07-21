import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/service_address_response.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

class RegisterUserFormComponent extends StatefulWidget {
  final String? userType;
  final UserData? data;
  final bool isUpdate;
  final Function? onUpdate;

  RegisterUserFormComponent({this.userType, this.data, this.isUpdate = false, this.onUpdate});

  @override
  RegisterUserFormComponentState createState() => RegisterUserFormComponentState();
}

class RegisterUserFormComponentState extends State<RegisterUserFormComponent> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController fNameCont = TextEditingController();
  TextEditingController lNameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController userNameCont = TextEditingController();
  TextEditingController mobileCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  TextEditingController cPasswordCont = TextEditingController();
  TextEditingController designationCont = TextEditingController();

  FocusNode fNameFocus = FocusNode();
  FocusNode lNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode mobileFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode cPasswordFocus = FocusNode();
  FocusNode designationFocus = FocusNode();

  List<AddressResponse> serviceAddressList = [];
  AddressResponse? selectedServiceAddress;

  int? serviceAddressId;

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
    await getAddressList();

    if (widget.data != null) {
      fNameCont.text = widget.data!.firstName.validate();
      lNameCont.text = widget.data!.lastName.validate();
      emailCont.text = widget.data!.email.validate();
      userNameCont.text = widget.data!.username.validate();
      mobileCont.text = widget.data!.contactNumber.validate();
      serviceAddressId = widget.data!.serviceAddressId.validate();
      designationCont.text = widget.data!.designation.validate();
    }
  }

  Future<void> getAddressList() async {
    getAddresses(providerId: appStore.userId).then((value) {
      appStore.setLoading(false);
      serviceAddressList.addAll(value.addressResponse!);

      serviceAddressList.forEach((e) {
        if (e.id == serviceAddressId) {
          selectedServiceAddress = e;
          log(selectedServiceAddress!.id.validate());
        }
      });
      afterInit = true;
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  /// Register the Handyman
  Future<void> register() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);
      String? type = widget.userType;

      var request = {
        if (widget.isUpdate) CommonKeys.id: widget.data!.id,
        UserKeys.firstName: fNameCont.text,
        UserKeys.lastName: lNameCont.text,
        UserKeys.userName: userNameCont.text,
        UserKeys.userType: type,
        UserKeys.providerId: appStore.userId,
        UserKeys.status: USER_STATUS_CODE,
        UserKeys.contactNumber: mobileCont.text,
        UserKeys.designation: designationCont.text.validate(),
        if (serviceAddressId != null && serviceAddressId != -1) UserKeys.serviceAddressId: serviceAddressId.validate(),
        UserKeys.email: emailCont.text,
        if (!widget.isUpdate) UserKeys.password: passwordCont.text
      };
      appStore.setLoading(true);
      if (widget.isUpdate) {
        await updateProfile(request).then((res) async {
          toast(res.message.validate());
          finish(context, widget.onUpdate!.call());
        }).catchError((e) {
          toast(e.toString());
        });
      } else {
        await registerUser(request).then((res) async {
          toast(res.message.validate());
          finish(context, widget.onUpdate!.call());
        }).catchError((e) {
          toast(e.toString());
        });
      }
      appStore.setLoading(false);
    }
  }

  /// Remove the Handyman
  Future<void> removeHandyman(int? id) async {
    appStore.setLoading(true);
    await deleteHandyman(id.validate()).then((value) {
      appStore.setLoading(false);

      finish(context, widget.onUpdate!.call());

      toast(context.translate.lblTrashHandyman, print: true);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  /// Restore the Handyman
  Future<void> restoreHandymanData() async {
    appStore.setLoading(true);
    var req = {
      CommonKeys.id: widget.data!.id,
      type: RESTORE,
    };

    await restoreHandyman(req).then((value) {
      appStore.setLoading(false);
      toast(value.message);
      finish(context, widget.onUpdate!.call());
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  /// ForceFully Delete the Handyman
  Future<void> forceDeleteHandymanData() async {
    appStore.setLoading(true);
    var req = {
      CommonKeys.id: widget.data!.id,
      type: FORCE_DELETE,
    };

    await restoreHandyman(req).then((value) {
      appStore.setLoading(false);
      toast(value.message);
      finish(context, widget.onUpdate!.call());
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {


    return SafeArea(
      child: Scaffold(
        backgroundColor: context.cardColor,
        appBar: appBarWidget(
          widget.isUpdate ? context.translate.lblUpdate : context.translate.lblAddHandyman,
          textColor: white,
          color: context.primaryColor,
          backWidget: BackWidget(),
          showBack: true,
          actions: [
            if (widget.isUpdate)
              PopupMenuButton(
                icon: Icon(Icons.more_vert, size: 24),
                onSelected: (selection) async {
                  if (selection == 1) {
                    showConfirmDialogCustom(
                      context,
                      dialogType: DialogType.DELETE,
                      title: context.translate.lblDoYouWantToDelete,
                      onAccept: (_) {
                        ifNotTester(context, () {
                          removeHandyman(widget.data!.id.validate());
                        });
                      },
                    );
                  } else if (selection == 2) {
                    showConfirmDialogCustom(
                      context,
                      dialogType: DialogType.DELETE,
                      title: context.translate.lblDoYouWantToRestore,
                      onAccept: (_) {
                        ifNotTester(context, () {
                          restoreHandymanData();
                        });
                      },
                    );
                  } else if (selection == 3) {
                    showConfirmDialogCustom(
                      context,
                      dialogType: DialogType.DELETE,
                      title: context.translate.lblDoYouWantToDeleteForcefully,
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
                    child: Text(context.translate.lblDelete),
                    value: 1,
                    enabled: widget.data!.deletedAt == null,
                  ),
                  PopupMenuItem(
                    child: Text(context.translate.lblRestore),
                    value: 2,
                    enabled: widget.data!.deletedAt != null,
                  ),
                  PopupMenuItem(
                    child: Text(context.translate.lblForceDelete),
                    value: 3,
                  ),
                ],
              ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    16.height,
                    AppTextField(
                      textFieldType: TextFieldType.NAME,
                      controller: fNameCont,
                      focus: fNameFocus,
                      nextFocus: lNameFocus,
                      decoration: inputDecoration(
                        context,
                        hint: context.translate.hintFirstNameTxt,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                      suffix: profile.iconImage(size: 10).paddingAll(14),
                    ),
                    16.height,
                    AppTextField(
                      textFieldType: TextFieldType.NAME,
                      controller: lNameCont,
                      focus: lNameFocus,
                      nextFocus: userNameFocus,
                      decoration: inputDecoration(
                        context,
                        hint: context.translate.hintLastNameTxt,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                      suffix: profile.iconImage(size: 10).paddingAll(14),
                    ),
                    16.height,
                    AppTextField(
                      textFieldType: TextFieldType.USERNAME,
                      controller: userNameCont,
                      focus: userNameFocus,
                      nextFocus: emailFocus,
                      decoration: inputDecoration(
                        context,
                        hint: context.translate.hintUserNameTxt,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                      suffix: profile.iconImage(size: 10).paddingAll(14),
                    ),
                    16.height,
                    AppTextField(
                      textFieldType: TextFieldType.EMAIL,
                      controller: emailCont,
                      focus: emailFocus,
                      nextFocus: mobileFocus,
                      decoration: inputDecoration(
                        context,
                        hint: context.translate.hintEmailAddressTxt,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                      suffix: ic_message.iconImage(size: 10).paddingAll(14),
                    ),
                    16.height,
                    AppTextField(
                      textFieldType: TextFieldType.PHONE,
                      controller: mobileCont,
                      focus: mobileFocus,
                      nextFocus: passwordFocus,
                      decoration: inputDecoration(
                        context,
                        hint: context.translate.hintContactNumberTxt,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                      suffix: calling.iconImage(size: 10).paddingAll(14),
                    ),
                    16.height,
                    AppTextField(
                      textFieldType: TextFieldType.NAME,
                      controller: designationCont,
                      focus: designationFocus,
                      isValidationRequired: false,
                      decoration: inputDecoration(
                        context,
                        hint: context.translate.lblDesignation,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                    ),
                    16.height,
                    DropdownButtonFormField<AddressResponse>(
                      decoration: inputDecoration(
                        context,
                        hint: context.translate.lblAddress,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                      isExpanded: true,
                      dropdownColor: context.cardColor,
                      value: selectedServiceAddress != null ? selectedServiceAddress : null,
                      items: serviceAddressList.map((data) {
                        return DropdownMenuItem<AddressResponse>(
                          value: data,
                          child: Text(
                            data.address.validate(),
                            style: primaryTextStyle(),
                          ),
                        );
                      }).toList(),
                      onChanged: (AddressResponse? value) async {
                        selectedServiceAddress = value;
                        serviceAddressId = selectedServiceAddress!.id.validate();
                        setState(() {});
                      },
                    ).visible(serviceAddressList.isNotEmpty),
                    16.height.visible(!widget.isUpdate),
                    AppTextField(
                      textFieldType: TextFieldType.PASSWORD,
                      controller: passwordCont,
                      focus: passwordFocus,
                      decoration: inputDecoration(
                        context,
                        hint: context.translate.hintPass,
                        fillColor: context.scaffoldBackgroundColor,
                      ),
                      onFieldSubmitted: (s) {
                        ifNotTester(context, () {
                          register();
                        });
                      },
                    ).visible(!widget.isUpdate),
                    24.height,
                    AppButton(
                      text: context.translate.btnSave,
                      height: 40,
                      color: primaryColor,
                      textStyle: primaryTextStyle(color: white),
                      width: context.width() - context.navigationBarHeight,
                      onTap: () {
                        ifNotTester(context, () {
                          register();
                        });
                      },
                    ),
                    16.height,
                  ],
                ),
              ),
            ),
            Observer(builder: (_) => LoaderWidget().center().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
