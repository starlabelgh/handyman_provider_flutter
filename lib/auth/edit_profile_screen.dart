import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/city_list_response.dart';
import 'package:handyman_provider_flutter/models/country_list_response.dart';
import 'package:handyman_provider_flutter/models/service_address_response.dart';
import 'package:handyman_provider_flutter/models/state_list_response.dart';
import 'package:handyman_provider_flutter/networks/network_utils.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/screens/verify_provider_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/user_update_response.dart';

class HEditProfileScreen extends StatefulWidget {
  @override
  HEditProfileScreenState createState() => HEditProfileScreenState();
}

class HEditProfileScreenState extends State<HEditProfileScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  File? imageFile;
  XFile? pickedFile;

  List<CountryListResponse> countryList = [];
  List<StateListResponse> stateList = [];
  List<CityListResponse> cityList = [];

  List<AddressResponse> serviceAddressList = [];
  AddressResponse? selectedAddress;

  CountryListResponse? selectedCountry;
  StateListResponse? selectedState;
  CityListResponse? selectedCity;

  TextEditingController fNameCont = TextEditingController();
  TextEditingController lNameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController userNameCont = TextEditingController();
  TextEditingController mobileCont = TextEditingController();
  TextEditingController addressCont = TextEditingController();
  TextEditingController designationCont = TextEditingController();

  FocusNode fNameFocus = FocusNode();
  FocusNode lNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode mobileFocus = FocusNode();
  FocusNode designationFocus = FocusNode();

  int countryId = 0;
  int stateId = 0;
  int cityId = 0;
  int? serviceAddressId;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    afterBuildCreated(() {
      setStatusBarColor(context.primaryColor);
      appStore.setLoading(true);
    });

    if (isUserTypeHandyman) await getAddressList();

    countryId = getIntAsync(COUNTRY_ID).validate();
    stateId = getIntAsync(STATE_ID).validate();
    cityId = getIntAsync(CITY_ID).validate();

    fNameCont.text = appStore.userFirstName.validate();
    lNameCont.text = appStore.userLastName.validate();
    emailCont.text = appStore.userEmail.validate();
    userNameCont.text = appStore.userName.validate();
    mobileCont.text = '${appStore.userContactNumber.validate()}';
    countryId = appStore.countryId.validate();
    stateId = appStore.stateId.validate();
    cityId = appStore.cityId.validate();
    addressCont.text = appStore.address.validate();
    serviceAddressId = appStore.serviceAddressId.validate();
    designationCont.text = appStore.designation.validate();

    if (getIntAsync(COUNTRY_ID) != 0) {
      await getCountry();
      await getStates(getIntAsync(COUNTRY_ID));
      if (getIntAsync(STATE_ID) != 0) {
        await getCity(getIntAsync(STATE_ID));
      }

      setState(() {});
    } else {
      await getCountry();
    }
  }

  Future<void> getAddressList() async {
    await getAddresses(providerId: appStore.providerId).then((value) {
      serviceAddressList.addAll(value.addressResponse!);
      value.addressResponse!.forEach((e) {
        if (e.id == getIntAsync(SERVICE_ADDRESS_ID)) {
          selectedAddress = e;
        }
      });
      appStore.setLoading(false);
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> getCountry() async {
    await getCountryList().then((value) async {
      countryList.clear();
      countryList.addAll(value);
      setState(() {});
      value.forEach((e) {
        if (e.id == getIntAsync(COUNTRY_ID)) {
          selectedCountry = e;
        }
      });
    }).catchError((e) {
      toast('$e', print: true);
    });
    appStore.setLoading(false);
  }

  Future<void> getStates(int countryId) async {
    appStore.setLoading(true);
    await getStateList({'country_id': countryId}).then((value) async {
      stateList.clear();
      stateList.addAll(value);
      value.forEach((e) {
        if (e.id == getIntAsync(STATE_ID)) {
          selectedState = e;
        }
      });
      setState(() {});
    }).catchError((e) {
      toast('$e', print: true);
    });
    appStore.setLoading(false);
  }

  Future<void> getCity(int stateId) async {
    appStore.setLoading(true);

    await getCityList({'state_id': stateId}).then((value) async {
      cityList.clear();
      cityList.addAll(value);
      value.forEach((e) {
        if (e.id == getIntAsync(CITY_ID)) {
          selectedCity = e;
        }
      });
    }).catchError((e) {
      toast('$e', print: true);
    });
    appStore.setLoading(false);
  }

  Future<void> update() async {
    MultipartRequest multiPartRequest = await getMultiPartRequest('update-profile');
    multiPartRequest.fields[UserKeys.firstName] = fNameCont.text;
    multiPartRequest.fields[UserKeys.lastName] = lNameCont.text;
    multiPartRequest.fields[UserKeys.userName] = userNameCont.text;
    multiPartRequest.fields[UserKeys.userType] = getStringAsync(USER_TYPE);
    multiPartRequest.fields[UserKeys.contactNumber] = mobileCont.text;
    multiPartRequest.fields[UserKeys.email] = emailCont.text;
    multiPartRequest.fields[UserKeys.countryId] = countryId.toString();
    multiPartRequest.fields[UserKeys.stateId] = stateId.toString();
    multiPartRequest.fields[UserKeys.cityId] = cityId.toString();
    multiPartRequest.fields[CommonKeys.address] = addressCont.text.validate();
    multiPartRequest.fields[UserKeys.designation] = designationCont.text.validate();

    if (isUserTypeHandyman && serviceAddressId != null) multiPartRequest.fields[UserKeys.serviceAddressId] = serviceAddressId.toString();
    if (imageFile != null) {
      multiPartRequest.files.add(await MultipartFile.fromPath(UserKeys.profileImage, imageFile!.path));
    } else {
      Image.asset(ic_home, fit: BoxFit.cover);
    }

    multiPartRequest.headers.addAll(buildHeaderTokens());

    Map<String, dynamic> req = {
      UserKeys.firstName: fNameCont.text,
      UserKeys.lastName: lNameCont.text,
      UserKeys.contactNumber: mobileCont.text,
      UserKeys.email: emailCont.text,
      UserKeys.designation: designationCont.text.validate(),
      UserKeys.countryId: countryId.toString().toInt(),
      UserKeys.stateId: stateId.toString().toInt(),
      UserKeys.cityId: cityId.toString().toInt(),
      CommonKeys.address: addressCont.text.validate(),
      if (isUserTypeHandyman && serviceAddressId != null) UserKeys.serviceAddressId: serviceAddressId.toString().validate().toInt(),
      UserKeys.profileImage: appStore.userProfileImage.validate(),
      'updatedAt': Timestamp.now(),
    };

    log('Req : $req');

    appStore.setLoading(true);

    userService.updateUserInfo(req, getStringAsync(UID), profileImage: imageFile != null ? File(imageFile!.path) : null).then((value) {
      appStore.setLoading(true);

      sendMultiPartRequest(
        multiPartRequest,
        onSuccess: (data) async {
          appStore.setLoading(false);
          if (data != null) {
            if ((data as String).isJson()) {
              UserUpdateResponse res = UserUpdateResponse.fromJson(jsonDecode(data));
              saveUserData(res.data!);
              finish(context);
              snackBar(context, title: res.message!);

              finish(context);
            }
          }
        },
        onError: (error) {
          toast(error.toString(), print: true);
          appStore.setLoading(false);
        },
      ).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  void _getFromGallery() async {
    pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1800, maxHeight: 1800);
    if (pickedFile != null) {
      _showSelectionDialog(context);
    }
  }

  _getFromCamera() async {
    pickedFile = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 1800, maxHeight: 1800);
    if (pickedFile != null) {
      _showSelectionDialog(context);
    }
  }

  Future<void> _showSelectionDialog(BuildContext context) {
    return showConfirmDialogCustom(
      context,
      title: context.translate.confirmationRequestTxt,
      positiveText: context.translate.lblOk,
      negativeText: context.translate.lblNo,
      onAccept: (BuildContext context) async {
        imageFile = File(pickedFile!.path);
        setState(() {});
      },
      onCancel: (BuildContext context) {
        imageFile = null;
      },
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: context.cardColor,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SettingItemWidget(
              title: context.translate.lblGallery,
              leading: Icon(Icons.image, color: context.iconColor),
              onTap: () {
                _getFromGallery();
                finish(context);
              },
            ),
            SettingItemWidget(
              title: context.translate.camera,
              leading: Icon(Icons.camera, color: context.iconColor),
              onTap: () {
                _getFromCamera();
                finish(context);
              },
            ),
          ],
        ).paddingAll(16.0);
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => SafeArea(
        child: Scaffold(
          appBar: appBarWidget(
            context.translate.editProfile,
            textColor: white,
            color: context.primaryColor,
            backWidget: BackWidget(),
            showBack: true,
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Container(
                            decoration: boxDecorationDefault(
                              border: Border.all(color: context.scaffoldBackgroundColor, width: 4),
                              shape: BoxShape.circle,
                            ),
                            child: imageFile != null
                                ? Image.file(imageFile!, width: 90, height: 90, fit: BoxFit.cover).cornerRadiusWithClipRRect(45)
                                : Observer(
                                    builder: (_) => cachedImage(
                                      appStore.userProfileImage,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ).cornerRadiusWithClipRRect(64),
                                  ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 2,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: boxDecorationWithRoundedCorners(
                                boxShape: BoxShape.circle,
                                backgroundColor: primaryColor,
                                border: Border.all(color: Colors.white),
                              ),
                              child: Icon(AntDesign.camera, color: Colors.white, size: 16).paddingAll(4.0),
                            ).onTap(() async {
                              _showBottomSheet(context);
                            }),
                          )
                        ],
                      ),
                      16.height,
                      AppTextField(
                        textFieldType: TextFieldType.NAME,
                        controller: fNameCont,
                        focus: fNameFocus,
                        nextFocus: lNameFocus,
                        decoration: inputDecoration(context, hint: context.translate.hintFirstNameTxt),
                        suffix: profile.iconImage(size: 10).paddingAll(14),
                      ),
                      16.height,
                      AppTextField(
                        textFieldType: TextFieldType.NAME,
                        controller: lNameCont,
                        focus: lNameFocus,
                        nextFocus: userNameFocus,
                        decoration: inputDecoration(context, hint: context.translate.hintLastNameTxt),
                        suffix: profile.iconImage(size: 10).paddingAll(14),
                      ),
                      16.height,
                      AppTextField(
                        textFieldType: TextFieldType.NAME,
                        controller: userNameCont,
                        focus: userNameFocus,
                        nextFocus: emailFocus,
                        decoration: inputDecoration(context, hint: context.translate.hintUserNameTxt),
                        suffix: profile.iconImage(size: 10).paddingAll(14),
                      ),
                      16.height,
                      AppTextField(
                        textFieldType: TextFieldType.EMAIL,
                        controller: emailCont,
                        focus: emailFocus,
                        nextFocus: mobileFocus,
                        decoration: inputDecoration(context, hint: context.translate.hintEmailTxt),
                        suffix: ic_message.iconImage(size: 10).paddingAll(14),
                      ),
                      16.height,
                      AppTextField(
                        textFieldType: TextFieldType.PHONE,
                        controller: mobileCont,
                        focus: mobileFocus,
                        decoration: inputDecoration(context, hint: context.translate.hintContactNumberTxt),
                        suffix: calling.iconImage(size: 10).paddingAll(14),
                        validator: (mobileCont) {
                          String value = mobileCont.toString();
                          String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
                          RegExp regExp = RegExp(pattern);
                          if (value.length == 0) {
                            return "Please enter mobile number";
                          } else if (!regExp.hasMatch(value.toString())) {
                            return "Contact number must be 10 digit only";
                          }
                          return null;
                        },
                      ),
                      16.height,
                      AppTextField(
                        textFieldType: TextFieldType.NAME,
                        controller: designationCont,
                        isValidationRequired: false,
                        focus: designationFocus,
                        decoration: inputDecoration(context, hint: context.translate.lblDesignation),
                      ),
                      16.height,
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: viewLineColor, width: 1),
                              borderRadius: radius(5),
                              color: context.cardColor,
                            ),
                            child: DropdownButtonFormField<CountryListResponse>(
                              decoration: InputDecoration.collapsed(hintText: null),
                              hint: Text(context.translate.selectCountry, style: primaryTextStyle()),
                              isExpanded: true,
                              menuMaxHeight: 300,
                              value: selectedCountry,
                              dropdownColor: context.cardColor,
                              items: countryList.map((CountryListResponse e) {
                                return DropdownMenuItem<CountryListResponse>(
                                  value: e,
                                  child: Text(e.name!, style: primaryTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (CountryListResponse? value) async {
                                countryId = value!.id!;
                                selectedCountry = value;
                                selectedState = null;
                                selectedCity = null;
                                getStates(value.id!);

                                setState(() {});
                              },
                            ),
                          ).expand(),
                          8.width.visible(stateList.isNotEmpty),
                          if (stateList.isNotEmpty)
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: viewLineColor, width: 1),
                                borderRadius: radius(5),
                                color: context.cardColor,
                              ),
                              child: DropdownButtonFormField<StateListResponse>(
                                decoration: InputDecoration.collapsed(hintText: null),
                                hint: Text(context.translate.selectState, style: primaryTextStyle()),
                                isExpanded: true,
                                dropdownColor: context.cardColor,
                                menuMaxHeight: 300,
                                value: selectedState,
                                items: stateList.map((StateListResponse e) {
                                  return DropdownMenuItem<StateListResponse>(
                                    value: e,
                                    child: Text(e.name!, style: primaryTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: (StateListResponse? value) async {
                                  selectedCity = null;
                                  selectedState = value;
                                  stateId = value!.id!;
                                  await getCity(value.id!);
                                  setState(() {});
                                },
                              ),
                            ).expand(),
                        ],
                      ),
                      16.height,
                      if (cityList.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: viewLineColor, width: 1),
                            borderRadius: radius(5),
                            color: context.cardColor,
                          ),
                          child: DropdownButtonFormField<CityListResponse>(
                            decoration: InputDecoration.collapsed(hintText: null),
                            hint: Text(context.translate.selectCity, style: primaryTextStyle()),
                            isExpanded: true,
                            menuMaxHeight: 400,
                            value: selectedCity,
                            dropdownColor: context.cardColor,
                            items: cityList.map(
                              (CityListResponse e) {
                                return DropdownMenuItem<CityListResponse>(
                                  value: e,
                                  child: Text(e.name!, style: primaryTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                                );
                              },
                            ).toList(),
                            onChanged: (CityListResponse? value) async {
                              selectedCity = value;
                              cityId = value!.id!;

                              setState(() {});
                            },
                          ),
                        ),
                      if (isUserTypeHandyman && serviceAddressList.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: viewLineColor, width: 1),
                            borderRadius: radius(5),
                            color: context.cardColor,
                          ),
                          child: DropdownButtonFormField<AddressResponse>(
                            decoration: InputDecoration.collapsed(hintText: null),
                            hint: Text(context.translate.lblSelectAddress, style: secondaryTextStyle()),
                            isExpanded: true,
                            value: selectedAddress != null ? selectedAddress : null,
                            dropdownColor: context.cardColor,
                            items: serviceAddressList.map((AddressResponse data) {
                              return DropdownMenuItem<AddressResponse>(
                                value: data,
                                child: Text(data.address.validate(), style: primaryTextStyle()),
                              );
                            }).toList(),
                            onChanged: (AddressResponse? value) async {
                              selectedAddress = value;
                              serviceAddressId = selectedAddress!.id.validate();
                              setState(() {});
                            },
                          ),
                        ).paddingTop(16),
                      16.height,
                      AppTextField(
                        controller: addressCont,
                        textFieldType: TextFieldType.MULTILINE,
                        maxLines: 5,
                        minLines: 3,
                        decoration: inputDecoration(context, hint: context.translate.hintAddress),
                      ),
                      28.height,
                      Row(
                        children: [
                          if (appStore.userType != USER_TYPE_HANDYMAN)
                            AppButton(
                              text: context.translate.btnVerifyId,
                              height: 40,
                              color: Colors.green,
                              textStyle: primaryTextStyle(color: white),
                              width: context.width() - context.navigationBarHeight,
                              onTap: () {
                                VerifyProviderScreen().launch(context);
                              },
                            ).expand(),
                          if (appStore.userType != USER_TYPE_HANDYMAN) 16.width,
                          AppButton(
                            text: context.translate.saveChanges,
                            height: 40,
                            color: primaryColor,
                            textStyle: primaryTextStyle(color: white),
                            width: context.width() - context.navigationBarHeight,
                            onTap: () {
                              ifNotTester(context, () {
                                update();
                              });
                            },
                          ).expand(),
                        ],
                      ),
                      24.height,
                    ],
                  ),
                ),
              ),
              Observer(builder: (_) => LoaderWidget().center().visible(appStore.isLoading)),
            ],
          ),
        ),
      ),
    );
  }
}
