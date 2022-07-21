import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/models/booking_detail_response.dart';
import 'package:handyman_provider_flutter/provider/services/components/review_widget.dart';
import 'package:nb_utils/nb_utils.dart';

class ReviewListViewComponent extends StatelessWidget {
  final List<RatingData> ratings;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool isCustomer;
  final bool showServiceName;

  ReviewListViewComponent({
    required this.ratings,
    this.padding,
    this.physics,
    this.isCustomer = false,
    this.showServiceName = false,
  });

  @override
  Widget build(BuildContext conteFxt) {
    return AnimatedListView(
      shrinkWrap: true,
      padding: padding ?? EdgeInsets.all(16),
      physics: physics,
      itemCount: ratings.length,
      slideConfiguration: SlideConfiguration(delay: 50.milliseconds),
      itemBuilder: (context, index) => ReviewWidget(
        data: ratings[index],
        isCustomer: isCustomer,
        showServiceName: showServiceName,
      ),
    );
  }
}
