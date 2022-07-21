import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/models/user_type_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:nb_utils/nb_utils.dart';

class DropdownUserTypeComponent extends StatefulWidget {
  final String? statusType;
  final String? userType;
  final Function(UserTypeData value) onValueChanged;
  final bool isValidate;

  DropdownUserTypeComponent({required this.onValueChanged, required this.isValidate, this.statusType, this.userType});

  @override
  _DropdownUserTypeComponentState createState() => _DropdownUserTypeComponentState();
}

class _DropdownUserTypeComponentState extends State<DropdownUserTypeComponent> {
  UserTypeData? selectedData;
  List<UserTypeData> userTypeList = [];

  @override
  void initState() {
    super.initState();
    init();
    LiveStream().on(SELECT_USER_TYPE, (p0) {
      if (selectedData != null) {
        selectedData = null;
        userTypeList = [];
        setState(() {});
      }
      init(userType: p0.toString());
    });
  }

  init({String? userType}) {
    getUserType(type: userType ?? widget.userType.validate()).then((value) {
      userTypeList = value.userTypeData.validate();
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
    return DropdownButtonFormField<UserTypeData>(
      onChanged: (UserTypeData? val) {
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
      decoration: inputDecoration(context, hint: context.translate.lblSelectUserType),
      items: List.generate(
        userTypeList.length,
        (index) {
          UserTypeData data = userTypeList[index];
          return DropdownMenuItem<UserTypeData>(
            child: Text(data.name.toString(), style: primaryTextStyle()),
            value: data,
          );
        },
      ),
    );
  }
}
