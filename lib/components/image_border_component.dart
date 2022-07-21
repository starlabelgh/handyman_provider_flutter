import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class ImageBorder extends StatelessWidget {
  final Widget child;

  ImageBorder({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.dividerColor, width: 1),
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}
