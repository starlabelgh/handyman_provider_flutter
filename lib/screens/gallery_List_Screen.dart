import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/screens/gallery_component.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:nb_utils/nb_utils.dart';

class GalleryListScreen extends StatelessWidget {
  final List<String> galleryImages;
  final String? serviceName;

  GalleryListScreen({required this.galleryImages, required this.serviceName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("${context.translate.lblGallery} ${'- ${serviceName.validate()}'}", textColor: Colors.white, color: context.primaryColor, backWidget: BackWidget()),
      body: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: List.generate(galleryImages.length, (i) => GalleryComponent(images: galleryImages, index: i)),
      ).paddingSymmetric(horizontal: 16, vertical: 16),
    );
  }
}
