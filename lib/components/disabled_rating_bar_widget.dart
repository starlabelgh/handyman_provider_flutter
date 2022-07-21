import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class DisabledRatingBarWidget extends StatelessWidget {
  final num rating;
  final double? size;
  final Color? activeColor;

  DisabledRatingBarWidget({required this.rating, this.size, this.activeColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RatingBarWidget(
          onRatingChanged: null,
          itemCount: 5,
          size: size ?? 18,
          disable: true,
          rating: rating.validate().toDouble(),
          activeColor: rattingColor,
        ),
        //8.width,
        //Text(rating.validate().toString(), style: primaryTextStyle(size: size)),
      ],
    );
  }
}
