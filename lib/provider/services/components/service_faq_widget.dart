import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/models/service_detail_response.dart';
import 'package:nb_utils/nb_utils.dart';

class ServiceFaqWidget extends StatelessWidget {
  final ServiceFaq? serviceFaq;

  const ServiceFaqWidget({Key? key, required this.serviceFaq}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(serviceFaq!.title.validate(), style: primaryTextStyle()),
      // backgroundColor: context.cardColor,
      tilePadding: EdgeInsets.symmetric(horizontal: 16),
      children: [
        ListTile(
          title: Text(serviceFaq!.description.validate(), style: secondaryTextStyle()),
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ],
    );
  }
}
