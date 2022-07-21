import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/locale/base_language.dart';

extension ContextExt on BuildContext {
  Languages get translate => Languages.of(this);
}
