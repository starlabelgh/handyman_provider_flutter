import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/caregory_response.dart';
import 'package:handyman_provider_flutter/models/service_address_response.dart';
import 'package:handyman_provider_flutter/models/service_detail_response.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/networks/network_utils.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/services/components/dropdown_subcategory_component.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';

class AddServiceScreen extends StatefulWidget {
  final int? categoryId;
  final ServiceData? data;

  AddServiceScreen({this.categoryId, this.data});

  @override
  AddServiceScreenState createState() => AddServiceScreenState();
}

class AddServiceScreenState extends State<AddServiceScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController serviceNameCont = TextEditingController();
  TextEditingController priceCont = TextEditingController();
  TextEditingController discountCont = TextEditingController(text: '0');
  TextEditingController descriptionCont = TextEditingController();
  TextEditingController durationContHr = TextEditingController(text: '00');
  TextEditingController durationContMin = TextEditingController(text: '00');

  ServiceDetailResponse serviceDetailResponse = ServiceDetailResponse();
  ServiceData serviceDetail = ServiceData();

  //file picker
  FilePickerResult? filePickerResult;
  List<File> imageFiles = [];

  List<int> selectedAddress = [];
  bool isChecked = false;

  List<Attachments> eAttachments = [];
  List<String> addressList = [];
  bool afterInit = false;

  List<AddressResponse> serviceAddressList = [];
  List<AddressResponse> selectedServiceAddressList = [];

  FocusNode serviceNameFocus = FocusNode();
  FocusNode priceFocus = FocusNode();
  FocusNode discountFocus = FocusNode();
  FocusNode descriptionFocus = FocusNode();
  FocusNode durationHrFocus = FocusNode();
  FocusNode durationMinFocus = FocusNode();

  List<CategoryData> categoryList = [];
  List<String> typeList = ['fixed', 'hourly'];
  List<String> statusList = ['Inactive', 'Active'];

  CategoryData? selectedCategory;
  String serviceType = '';
  String serviceStatus = '';

  bool isFeature = false;
  int? serviceId;
  CategoryData? selectedSubCategoryData;
  CategoryResponse? categoryResponse;

  @override
  void initState() {
    super.initState();

    afterBuildCreated(() {
      setStatusBarColor(context.primaryColor);
      init();
    });
  }

  Future<void> init() async {
    appStore.setLoading(true);

    serviceType = typeList[0];
    serviceStatus = statusList[0];

    await getCategory();
    await getAddressesList();

    if (widget.data != null) {
      getEditServiceData();
    }

    afterInit = true;
    setState(() {});
  }

  getEditServiceData() {
    serviceDetail = widget.data!;
    serviceId = widget.data!.id;
    serviceNameCont.text = serviceDetail.name.validate();
    priceCont.text = serviceDetail.price.toString();
    discountCont.text = serviceDetail.discount.toString().validate(value: '0');
    descriptionCont.text = serviceDetail.description.validate();
    durationContHr.text = serviceDetail.duration.validate().splitBefore(':');
    durationContMin.text = serviceDetail.duration.validate().splitAfter(':');
    isFeature = serviceDetail.isFeatured.validate() == 1 ? true : false;
    serviceStatus = serviceDetail.status == 1 ? 'Active' : 'InActive';
    serviceType = serviceDetail.type.validate();
    serviceStatus = serviceDetail.status == 0 ? 'InActive' : 'Active';
    serviceDetail.attchments!.map((e) {
      eAttachments.add(e);
    }).toList();

    afterInit = true;
    setState(() {});
  }

  Future<void> getCategory() async {
    await getCategoryList(perPage: '?per_page=all').then((value) {
      categoryList.addAll(value.data!);

      if (widget.data != null) selectedCategory = categoryList.where((element) => element.id == widget.data!.categoryId).first;

      if (widget.categoryId != null && categoryList.any((element) => element.id == widget.categoryId)) {
        selectedCategory = categoryList.firstWhere((element) => element.id == widget.categoryId);
      }

      setState(() {});
      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> getAddressesList() async {
    getAddresses(providerId: appStore.userId).then((value) {
      serviceAddressList.addAll(value.addressResponse!);

      if (widget.data != null) {
        serviceAddressList.forEach(
          (addressElement) {
            serviceDetail.serviceAddressMapping!.forEach(
              (element) {
                if (element.providerAddressMapping!.id == addressElement.id) {
                  addressElement.isSelected = true;
                  selectedAddress.add(addressElement.id.validate());
                } else {
                  addressElement.isSelected = false;
                }
              },
            );
          },
        );
      }

      setState(() {});
      appStore.setLoading(false);
    }).catchError((e) {
      toast(e.toString(), print: true);
      appStore.setLoading(false);
    });
  }

  getMultipleFile() async {
    filePickerResult = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.custom, allowedExtensions: ['jpg', 'png', 'jpeg']);

    if (filePickerResult != null) {
      setState(() {
        imageFiles = filePickerResult!.paths.map((path) => File(path!)).toList();
      });
    } else {}
  }

  Future<void> addNewService() async {
    hideKeyboard(context);

    // Check if image is selected when adding new service
    if (serviceId == null && imageFiles.isEmpty) {
      return toast('Choose at-least one image.');
    }

    MultipartRequest multiPartRequest = await getMultiPartRequest('service-save');

    if (serviceId != null) {
      multiPartRequest.fields[CommonKeys.id] = serviceId.toString();
    }

    multiPartRequest.fields[AddServiceKey.name] = serviceNameCont.text.validate();
    multiPartRequest.fields[AddServiceKey.providerId] = appStore.userId.toString();
    multiPartRequest.fields[AddServiceKey.categoryId] = selectedCategory!.id.toString();
    if (selectedSubCategoryData != null) multiPartRequest.fields[AddServiceKey.subCategoryId] = selectedSubCategoryData!.id.toString();
    multiPartRequest.fields[AddServiceKey.type] = serviceType.validate();
    multiPartRequest.fields[AddServiceKey.price] = priceCont.text.toString();
    multiPartRequest.fields[AddServiceKey.discountPrice] = discountCont.text.toString().validate();
    multiPartRequest.fields[AddServiceKey.description] = descriptionCont.text.validate();
    multiPartRequest.fields[AddServiceKey.isFeatured] = isFeature ? '1' : '0';
    multiPartRequest.fields[AddServiceKey.status] = '1';

    multiPartRequest.fields[AddServiceKey.duration] = durationContHr.text.toString().validate() + ':' + durationContMin.text.toString().validate();

    for (int i = 0; i < selectedAddress.length; i++) {
      multiPartRequest.fields[AddServiceKey.providerAddressId + '[$i]'] = selectedAddress[i].toString().validate();
    }

    log('multiPartRequest.fields : ${multiPartRequest.fields}');

    if (imageFiles.isNotEmpty) {
      await Future.forEach<File>(imageFiles, (element) async {
        int i = imageFiles.indexOf(element);
        log('${AddServiceKey.serviceAttachment + i.toString()}');
        multiPartRequest.files.add(await MultipartFile.fromPath('${AddServiceKey.serviceAttachment + i.toString()}', element.path));
      });
    }

    if (imageFiles.isNotEmpty) multiPartRequest.fields[AddServiceKey.attachmentCount] = imageFiles.length.toString();

    multiPartRequest.headers.addAll(buildHeaderTokens());

    appStore.setLoading(true);
    sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        appStore.setLoading(false);
        toast(jsonDecode(data)['message'], print: true);

        finish(context, true);
      },
      onError: (error) {
        toast(error.toString(), print: true);
        appStore.setLoading(false);
      },
    ).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  void checkValidation() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);

      if (selectedCategory == null) {
        toast(context.translate.lblPlsSelectCategory);
      } else if (selectedAddress.isEmpty) {
        toast(context.translate.lblPlsSelectAddress);
      } else {
        addNewService();
      }
    }
  }

  Future<void> removeAttachment({required int id, required int index}) async {
    showConfirmDialogCustom(context, dialogType: DialogType.DELETE, onAccept: (_) async {
      appStore.setLoading(true);

      Map req = {
        "type": 'service_attachment',
        CommonKeys.id: id,
      };

      await deleteImage(req).then((value) {
        eAttachments.removeAt(index.validate());
        setState(() {});

        appStore.setLoading(false);
        toast(value.message.validate(), print: true);
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString(), print: true);
      });
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    setStatusBarColor(Colors.transparent);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appBarWidget(
          widget.data != null ? context.translate.lblEditService : context.translate.hintAddService,
          textColor: white,
          color: context.primaryColor,
          backWidget: BackWidget(),
        ),
        body: Stack(
          alignment: Alignment.topLeft,
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: context.width(),
                    height: 120,
                    child: DottedBorder(
                      color: primaryColor.withOpacity(0.6),
                      strokeWidth: 1,
                      borderType: BorderType.RRect,
                      dashPattern: [6, 5],
                      radius: Radius.circular(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(selectImage, height: 25, width: 25, color: appStore.isDarkMode ? white : gray),
                          8.height,
                          Text(context.translate.hintChooseImage, style: boldTextStyle()),
                        ],
                      ).center().onTap(borderRadius: radius(), () async {
                        getMultipleFile();
                      }),
                    ),
                  ),
                  8.height,
                  Text(context.translate.selectImgNote, style: secondaryTextStyle(size: 8)),
                  16.height,
                  HorizontalList(
                      itemCount: imageFiles.length,
                      itemBuilder: (context, i) {
                        return Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Image.file(imageFiles[i], width: 90, height: 90, fit: BoxFit.cover),
                            Container(
                              decoration: boxDecorationWithRoundedCorners(boxShape: BoxShape.circle, backgroundColor: primaryColor),
                              margin: EdgeInsets.only(right: 8, top: 8),
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.close, size: 16, color: white),
                            ).onTap(() {
                              imageFiles.removeAt(i);
                              setState(() {});
                            }),
                          ],
                        );
                      }).paddingBottom(16).visible(imageFiles.isNotEmpty),
                  HorizontalList(
                    itemCount: eAttachments.length,
                    itemBuilder: (context, i) {
                      return Stack(
                        alignment: Alignment.topRight,
                        children: [
                          cachedImage(eAttachments[i].url, width: 90, height: 90, fit: BoxFit.cover),
                          Container(
                            decoration: boxDecorationWithRoundedCorners(boxShape: BoxShape.circle, backgroundColor: primaryColor),
                            margin: EdgeInsets.only(right: 8, top: 8),
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.close, size: 16, color: white),
                          ).onTap(() {
                            removeAttachment(id: eAttachments[i].id!, index: i);
                          })
                        ],
                      );
                    },
                  ).paddingBottom(16).visible(eAttachments.isNotEmpty),
                  8.height,
                  Container(
                    decoration: boxDecorationWithRoundedCorners(
                      borderRadius: radius(),
                      backgroundColor: appStore.isDarkMode ? cardDarkColor : cardColor,
                    ),
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextField(
                            textFieldType: TextFieldType.NAME,
                            controller: serviceNameCont,
                            focus: serviceNameFocus,
                            nextFocus: priceFocus,
                            errorThisFieldRequired: context.translate.hintRequired,
                            decoration: inputDecoration(context, hint: context.translate.hintServiceName, fillColor: context.scaffoldBackgroundColor),
                          ),
                          16.height,
                          DropdownButtonFormField<CategoryData>(
                            decoration: inputDecoration(context, fillColor: context.scaffoldBackgroundColor, hint: context.translate.hintSelectCategory),
                            value: selectedCategory,
                            dropdownColor: context.scaffoldBackgroundColor,
                            items: categoryList.map((data) {
                              return DropdownMenuItem<CategoryData>(
                                value: data,
                                child: Text(data.name.validate(), style: primaryTextStyle()),
                              );
                            }).toList(),
                            onChanged: (CategoryData? value) async {
                              selectedCategory = value!;
                              setState(() {});
                              LiveStream().emit(SELECT_SUBCATEGORY, selectedCategory!.id.validate());
                            },
                          ),
                          16.height,
                          DropdownSubCategoryComponent(
                            isValidate: false,
                            categoryId: selectedCategory?.id.validate(),
                            onValueChanged: (CategoryData value) {
                              selectedSubCategoryData = value;
                              setState(() {});
                            },
                          ),
                          16.height,
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: radius(),
                              color: context.scaffoldBackgroundColor,
                            ),
                            child: ExpansionTile(
                              iconColor: context.iconColor,
                              title: Text(context.translate.selectAddress, style: primaryTextStyle()),
                              trailing: Icon(Icons.arrow_drop_down),
                              children: <Widget>[
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: serviceAddressList.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 8.0),
                                      child: CheckboxListTile(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                        title: Text(
                                          serviceAddressList[index].address.validate(),
                                          style: secondaryTextStyle(color: context.iconColor),
                                        ),
                                        autofocus: false,
                                        activeColor: primaryColor,
                                        checkColor: context.cardColor,
                                        value: selectedAddress.contains(serviceAddressList[index].id),
                                        onChanged: (bool? val) {
                                          if (selectedAddress.contains(serviceAddressList[index].id)) {
                                            selectedAddress.remove(serviceAddressList[index].id);
                                          } else {
                                            selectedAddress.add(serviceAddressList[index].id.validate());
                                          }
                                          setState(() {});
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          16.height,
                          Row(
                            children: [
                              DropdownButtonFormField<String>(
                                decoration: inputDecoration(
                                  context,
                                  fillColor: context.scaffoldBackgroundColor,
                                  hint: context.translate.lblType,
                                ),
                                hint: Text(context.translate.hintSelectType, style: secondaryTextStyle()),
                                value: serviceType.isNotEmpty ? serviceType : null,
                                dropdownColor: context.cardColor,
                                items: typeList.map((String data) {
                                  return DropdownMenuItem<String>(
                                    value: data,
                                    child: Text(data.capitalizeFirstLetter(), style: primaryTextStyle()),
                                  );
                                }).toList(),
                                onChanged: (String? value) async {
                                  serviceType = value.validate();
                                  setState(() {});
                                },
                              ).expand(flex: 1),
                              16.width,
                              DropdownButtonFormField<String>(
                                decoration: inputDecoration(
                                  context,
                                  fillColor: context.scaffoldBackgroundColor,
                                  hint: context.translate.lblStatusType,
                                ),
                                hint: Text(context.translate.hintSelectStatus, style: secondaryTextStyle()),
                                dropdownColor: context.cardColor,
                                value: serviceStatus.isNotEmpty ? serviceStatus : null,
                                items: statusList.map((String data) {
                                  return DropdownMenuItem<String>(
                                    value: data,
                                    child: Text(data, style: primaryTextStyle()),
                                  );
                                }).toList(),
                                onChanged: (String? value) async {
                                  serviceStatus = value.validate();
                                  setState(() {});
                                },
                              ).expand(flex: 1),
                            ],
                          ),
                          24.height,
                          Row(
                            children: [
                              AppTextField(
                                textFieldType: TextFieldType.PHONE,
                                controller: priceCont,
                                focus: priceFocus,
                                nextFocus: discountFocus,
                                errorThisFieldRequired: context.translate.hintRequired,
                                decoration: inputDecoration(
                                  context,
                                  hint: context.translate.hintPrice,
                                  fillColor: context.scaffoldBackgroundColor,
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                              ).expand(),
                              16.width,
                              AppTextField(
                                textFieldType: TextFieldType.PHONE,
                                controller: discountCont,
                                focus: discountFocus,
                                nextFocus: durationHrFocus,
                                errorThisFieldRequired: context.translate.hintRequired,
                                decoration: inputDecoration(
                                  context,
                                  hint: context.translate.hintDiscount.capitalizeFirstLetter(),
                                  fillColor: context.scaffoldBackgroundColor,
                                ),
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                              ).expand(),
                            ],
                          ),
                          24.height,
                          Row(
                            children: [
                              AppTextField(
                                textFieldType: TextFieldType.PHONE,
                                controller: durationContHr,
                                focus: durationHrFocus,
                                nextFocus: durationMinFocus,
                                maxLength: 2,
                                errorThisFieldRequired: context.translate.hintRequired,
                                decoration: inputDecoration(
                                  context,
                                  hint: context.translate.lblDurationHr,
                                  fillColor: context.scaffoldBackgroundColor,
                                  counterText: '',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (s) {
                                  if (s!.isEmpty) return errorThisFieldRequired;

                                  if (s.toInt() > 24) return context.translate.lblEnterHours;
                                  if (s.toInt() == 0) return errorThisFieldRequired;
                                  return null;
                                },
                              ).paddingRight(8).expand(),
                              AppTextField(
                                textFieldType: TextFieldType.PHONE,
                                controller: durationContMin,
                                focus: durationMinFocus,
                                nextFocus: descriptionFocus,
                                maxLength: 2,
                                errorThisFieldRequired: context.translate.hintRequired,
                                decoration: inputDecoration(
                                  context,
                                  hint: context.translate.lblDurationMin,
                                  fillColor: context.scaffoldBackgroundColor,
                                  counterText: '',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (s) {
                                  if (s!.isEmpty) return errorThisFieldRequired;

                                  if (s.toInt() > 60) return context.translate.lblEnterMinute;
                                  return null;
                                },
                              ).expand(),
                            ],
                          ),
                          24.height,
                          AppTextField(
                            textFieldType: TextFieldType.MULTILINE,
                            minLines: 5,
                            controller: descriptionCont,
                            focus: descriptionFocus,
                            errorThisFieldRequired: context.translate.hintRequired,
                            decoration: inputDecoration(
                              context,
                              hint: context.translate.hintDescription,
                              fillColor: context.scaffoldBackgroundColor,
                            ),
                          ),
                          8.height,
                          CheckboxListTile(
                            value: isFeature,
                            contentPadding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: radius(50), side: BorderSide(color: primaryColor)),
                            title: Text(context.translate.hintSetAsFeature, style: secondaryTextStyle()),
                            onChanged: (bool? v) {
                              isFeature = v.validate();
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  24.height,
                  AppButton(
                    text: context.translate.btnSave,
                    height: 40,
                    color: primaryColor,
                    textStyle: primaryTextStyle(color: white),
                    width: context.width() - context.navigationBarHeight,
                    onTap: () {
                      ifNotTester(context, () {
                        checkValidation();
                      });
                    },
                  ),
                  16.height,
                ],
              ).paddingAll(16),
            ),
            Observer(
              builder: (_) => LoaderWidget().center().visible(appStore.isLoading && afterInit),
            ),
          ],
        ),
      ),
    );
  }
}
