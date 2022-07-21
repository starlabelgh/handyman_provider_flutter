import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/models/caregory_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:nb_utils/nb_utils.dart';

class DropdownSubCategoryComponent extends StatefulWidget {
  final int? categoryId;
  final Function(CategoryData value) onValueChanged;
  final bool isValidate;

  DropdownSubCategoryComponent({required this.onValueChanged, required this.isValidate, this.categoryId});

  @override
  _DropdownUserTypeComponentState createState() => _DropdownUserTypeComponentState();
}

class _DropdownUserTypeComponentState extends State<DropdownSubCategoryComponent> {
  CategoryData? selectedData;
  List<CategoryData> subCategoryList = [];

  @override
  void initState() {
    super.initState();
    init();
    LiveStream().on(SELECT_SUBCATEGORY, (p0) {
      if (selectedData != null) {
        selectedData = null;
        setState(() {});
      }
      init(subCategory: p0.toString());
    });
  }

  init({String? subCategory}) async {
    await getSubCategoryList(catId: subCategory.toInt()).then((value) {
      subCategoryList = value.data.validate();
      setState(() {});
    }).catchError((e) {
      log(e.toString());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<CategoryData>(
      onChanged: (CategoryData? val) {
        widget.onValueChanged.call(val!);
        selectedData = val;
      },
      validator: widget.isValidate
          ? (c) {
              if (c == null) return errorThisFieldRequired;
              return null;
            }
          : null,
      value: selectedData,
      dropdownColor: context.cardColor,
      decoration: inputDecoration(context, fillColor: context.scaffoldBackgroundColor, hint: context.translate.lblSelectSubCategory),
      items: List.generate(
        subCategoryList.length,
        (index) {
          CategoryData data = subCategoryList[index];
          return DropdownMenuItem<CategoryData>(
            child: Text(data.name.toString(), style: primaryTextStyle()),
            value: data,
          );
        },
      ),
    );
  }
}
