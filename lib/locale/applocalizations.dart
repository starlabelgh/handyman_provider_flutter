import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/locale/base_language.dart';
import 'package:handyman_provider_flutter/locale/language_af.dart';
import 'package:handyman_provider_flutter/locale/language_ar.dart';
import 'package:handyman_provider_flutter/locale/language_de.dart';
import 'package:handyman_provider_flutter/locale/language_en.dart';
import 'package:handyman_provider_flutter/locale/language_es.dart';
import 'package:handyman_provider_flutter/locale/language_fr.dart';
import 'package:handyman_provider_flutter/locale/language_gu.dart';
import 'package:handyman_provider_flutter/locale/language_hi.dart';
import 'package:handyman_provider_flutter/locale/language_id.dart';
import 'package:handyman_provider_flutter/locale/language_nl.dart';
import 'package:handyman_provider_flutter/locale/language_pt.dart';
import 'package:handyman_provider_flutter/locale/language_tr.dart';
import 'package:handyman_provider_flutter/locale/language_vi.dart';
import 'package:nb_utils/nb_utils.dart';

import 'language_sq.dart';

class AppLocalizations extends LocalizationsDelegate<Languages> {
  const AppLocalizations();

  @override
  Future<Languages> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return LanguageEn();
      case 'hi':
        return LanguageHi();
      case 'gu':
        return LanguageGu();
      case 'af':
        return LanguageAf();
      case 'ar':
        return LanguageAr();
      case 'nl':
        return LanguageNl();
      case 'de':
        return LanguageDe();
      case 'fr':
        return LanguageFr();
      case 'id':
        return LanguageId();
      case 'pt':
        return LanguagePt();
      case 'es':
        return LanguageEs();
      case 'tr':
        return LanguageTr();
      case 'vi':
        return LanguageVi();
      case 'sq':
        return LanguageSq();
      default:
        return LanguageEn();
    }
  }

  @override
  bool isSupported(Locale locale) => LanguageDataModel.languages().contains(locale.languageCode);

  @override
  bool shouldReload(LocalizationsDelegate<Languages> old) => false;
}
