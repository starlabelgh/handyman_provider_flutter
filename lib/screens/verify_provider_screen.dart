import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/background_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/document_list_response.dart';
import 'package:handyman_provider_flutter/models/provider_document_list_response.dart';
import 'package:handyman_provider_flutter/networks/network_utils.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

class VerifyProviderScreen extends StatefulWidget {
  @override
  _VerifyProviderScreenState createState() => _VerifyProviderScreenState();
}

class _VerifyProviderScreenState extends State<VerifyProviderScreen> {
  DocumentListResponse? documentListResponse;
  List<Documents> documents = [];
  FilePickerResult? filePickerResult;
  List<ProviderDocuments> providerDocuments = [];
  List<File>? imageFiles;
  PickedFile? pickedFile;
  List<String> eAttachments = [];
  int? updateDocId;
  List<int>? uploadedDocList = [];
  Documents? selectedDoc;
  int docId = 0;

  @override
  void initState() {
    super.initState();

    afterBuildCreated(() {
      init();
    });
  }

  void init() async {
    appStore.setLoading(true);
    log(getIntAsync(USER_ID));
    getDocumentList();
    getProviderDocList();
  }

//get Document list
  getDocumentList() {
    appStore.setLoading(true);
    getDocList().then((res) {
      log(res.documents);
      documents.addAll(res.documents!);
      setState(() {});
      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  //SelectImage
  getMultipleFile(int? docId, {int? updateId}) async {
    filePickerResult = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.custom, allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf']);

    if (filePickerResult != null) {
      showConfirmDialogCustom(
        context,
        title: context.translate.confirmationUpload,
        onAccept: (BuildContext context) {
          setState(() {
            imageFiles = filePickerResult!.paths.map((path) => File(path!)).toList();
            eAttachments = [];
          });

          ifNotTester(context, () {
            addDocument(docId, updateId: updateId);
          });
        },
        positiveText: context.translate.lblYes,
        negativeText: context.translate.lblNo,
        primaryColor: primaryColor,
      );
    } else {}
  }

  //Add Documents
  addDocument(int? docId, {int? updateId}) async {
    MultipartRequest multiPartRequest = await getMultiPartRequest('provider-document-save');
    multiPartRequest.fields[CommonKeys.id] = updateId != null ? updateId.toString() : '';
    multiPartRequest.fields[CommonKeys.providerId] = appStore.userId.toString();
    multiPartRequest.fields[AddDocument.documentId] = docId.toString();
    multiPartRequest.fields[AddDocument.isVerified] = '0';
    if (imageFiles != null) {
      multiPartRequest.files.add(await MultipartFile.fromPath(AddDocument.providerDocument, imageFiles!.first.path));
    }
    log(multiPartRequest);
    multiPartRequest.headers.addAll(buildHeaderTokens());
    appStore.setLoading(true);
    sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        appStore.setLoading(false);

        toast(context.translate.toastSuccess, print: true);
        providerDocuments.clear();
        getProviderDocList();
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

  //Get Uploaded Documents List
  getProviderDocList() {
    getProviderDoc().then((res) {
      appStore.setLoading(false);
      log(res.providerDocuments);
      providerDocuments.addAll(res.providerDocuments!);
      providerDocuments.forEach((element) {
        uploadedDocList!.add(element.documentId!);
        updateDocId = element.id;
        log(uploadedDocList);
      });
      setState(() {});
    }).catchError((e) {
      toast(e.toString(), print: true);
    });
  }

  //Delete Documents
  deleteDoc(int? id) {
    appStore.setLoading(true);
    deleteProviderDoc(id).then((value) {
      toast(value.message, print: true);
      uploadedDocList!.clear();
      providerDocuments.clear();
      getProviderDocList();
      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(context.translate.btnVerifyId, textColor: white, color: context.primaryColor),
      body: Observer(
        builder: (_) => Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (documents.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: viewLineColor, width: 1),
                            borderRadius: radius(5),
                          ),
                          child: DropdownButtonFormField<Documents>(
                            decoration: InputDecoration.collapsed(hintText: null),
                            hint: Text(context.translate.lblSelectDoc, style: primaryTextStyle()),
                            value: selectedDoc,
                            dropdownColor: context.cardColor,
                            items: documents.map((Documents e) {
                              return DropdownMenuItem<Documents>(
                                value: e,
                                child: Text(e.name!, style: primaryTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (Documents? value) async {
                              log(uploadedDocList);
                              selectedDoc = value;
                              docId = value!.id!;
                              log(docId);
                              setState(() {});
                            },
                          ),
                        ).expand(),
                      8.width.visible(!uploadedDocList!.contains(docId)),
                      if (docId != 0)
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: boxDecorationWithRoundedCorners(backgroundColor: Colors.green.withOpacity(0.1)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: Colors.green, size: 24),
                              Text(context.translate.lblAddDoc, style: secondaryTextStyle()),
                            ],
                          ),
                        ).onTap(() {
                          getMultipleFile(docId);
                        }).visible(!uploadedDocList!.contains(docId)),
                    ],
                  ),
                  16.height,
                  ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      itemCount: providerDocuments.length,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return providerDocuments[index].providerDocument!.contains('.pdf')
                            ? Container(
                                padding: EdgeInsets.all(8),
                                alignment: Alignment.bottomCenter,
                                width: context.width(),
                                decoration: boxDecorationWithRoundedCorners(
                                  border: Border.all(width: 0.1),
                                  gradient: LinearGradient(
                                    begin: FractionalOffset.topCenter,
                                    end: FractionalOffset.bottomCenter,
                                    colors: [Colors.transparent, Colors.black26],
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(providerDocuments[index].providerDocument!, style: primaryTextStyle()),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          providerDocuments[index].documentName!,
                                          style: boldTextStyle(size: 18, color: white),
                                        ).expand(),
                                        Container(
                                          padding: EdgeInsets.all(6),
                                          decoration: boxDecorationWithRoundedCorners(backgroundColor: white.withOpacity(0.5)),
                                          child: Icon(AntDesign.edit, color: primaryColor, size: 20),
                                        ).onTap(() {
                                          getMultipleFile(providerDocuments[index].documentId, updateId: providerDocuments[index].id.validate());
                                        }).visible(providerDocuments[index].isVerified == 0),
                                        6.width,
                                        Container(
                                          padding: EdgeInsets.all(6),
                                          decoration: boxDecorationWithRoundedCorners(
                                            backgroundColor: Colors.white.withOpacity(0.5),
                                          ),
                                          child: Icon(Icons.delete_forever, color: Colors.red, size: 20),
                                        ).onTap(() {
                                          deleteDoc(providerDocuments[index].id);
                                        }).visible(providerDocuments[index].isVerified == 0),
                                        Icon(
                                          MaterialIcons.verified_user,
                                          color: Colors.green,
                                        ).visible(providerDocuments[index].isVerified == 1),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  cachedImage(
                                    providerDocuments[index].providerDocument,
                                    height: 200,
                                    width: context.width(),
                                    fit: BoxFit.cover,
                                  ).cornerRadiusWithClipRRect(8),
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    alignment: Alignment.bottomCenter,
                                    height: 200,
                                    width: context.width(),
                                    decoration: boxDecorationWithRoundedCorners(
                                      border: Border.all(width: 0.1),
                                      gradient: LinearGradient(
                                        begin: FractionalOffset.topCenter,
                                        end: FractionalOffset.bottomCenter,
                                        colors: [Colors.transparent, Colors.black26],
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(providerDocuments[index].documentName!, style: boldTextStyle(size: 18, color: white)).expand(),
                                        Container(
                                          padding: EdgeInsets.all(6),
                                          decoration: boxDecorationWithRoundedCorners(backgroundColor: white.withOpacity(0.5)),
                                          child: Icon(AntDesign.edit, color: primaryColor, size: 20),
                                        ).onTap(() {
                                          getMultipleFile(providerDocuments[index].documentId, updateId: providerDocuments[index].id.validate());
                                        }).visible(providerDocuments[index].isVerified == 0),
                                        6.width,
                                        Container(
                                          padding: EdgeInsets.all(6),
                                          decoration: boxDecorationWithRoundedCorners(
                                            backgroundColor: Colors.white.withOpacity(0.5),
                                          ),
                                          child: Icon(Icons.delete_forever, color: Colors.red, size: 20),
                                        ).onTap(() {
                                          showConfirmDialogCustom(context, dialogType: DialogType.DELETE, onAccept: (_) {
                                            ifNotTester(context, () {
                                              deleteDoc(providerDocuments[index].id);
                                            });
                                          });
                                        }).visible(providerDocuments[index].isVerified == 0),
                                        Icon(
                                          MaterialIcons.verified_user,
                                          color: Colors.green,
                                        ).visible(providerDocuments[index].isVerified == 1),
                                      ],
                                    ),
                                  )
                                ],
                              ).paddingSymmetric(vertical: 8);
                      })
                ],
              ),
            ),
            BackgroundComponent().center().visible(!appStore.isLoading && documents.isEmpty && providerDocuments.isEmpty),
            LoaderWidget().center().visible(appStore.isLoading),
          ],
        ),
      ),
    );
  }
}
