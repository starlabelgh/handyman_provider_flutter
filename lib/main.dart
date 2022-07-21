import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/no_internet_component.dart';
import 'package:handyman_provider_flutter/locale/applocalizations.dart';
import 'package:handyman_provider_flutter/locale/base_language.dart';
import 'package:handyman_provider_flutter/models/file_model.dart';
import 'package:handyman_provider_flutter/models/revenue_chart_data.dart';
import 'package:handyman_provider_flutter/networks/firebase_services/auth_services.dart';
import 'package:handyman_provider_flutter/networks/firebase_services/chat_messages_service.dart';
import 'package:handyman_provider_flutter/networks/firebase_services/notification_service.dart';
import 'package:handyman_provider_flutter/networks/firebase_services/user_services.dart';
import 'package:handyman_provider_flutter/screens/booking_detail_screen.dart';
import 'package:handyman_provider_flutter/screens/splash_screen.dart';
import 'package:handyman_provider_flutter/store/AppStore.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'app_theme.dart';

//region Mobx Stores
AppStore appStore = AppStore();
//endregion
bool isCurrentlyOnNoInternet = false;
bool disableTestUserForcefully = false;

//region App languages
Languages? languages;
//endregion

//region Firebase Services
UserService userService = UserService();
AuthServices authService = AuthServices();

ChatMessageService chatMessageService = ChatMessageService();
NotificationService notificationService = NotificationService();
//endregion

//region Chart Model
late List<FileModel> fileList = [];
List<RevenueChartData> chartData = [];
//endregion

//region Chat Variable
bool mIsEnterKey = false;
String currentPackageName = '';
//endregion

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!isDesktop) {
    Firebase.initializeApp().then((value) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    }).catchError((e) {
      log(e.toString());
      return e;
    });
  }

  defaultSettings();

  await initialize();

  localeLanguageList = languageList();

  Firebase.initializeApp().then((value) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    setupFirebaseRemoteConfig();
  });

  appStore.setLanguage(DEFAULT_LANGUAGE);
  await appStore.setLoggedIn(getBoolAsync(IS_LOGGED_IN));

  await setLoginValues();

  setOneSignal();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<ConnectivityResult> connectivitySubscription;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult notification) {
      try {
        var notId = notification.notification.additionalData!.containsKey('id') ? notification.notification.additionalData!['id'] : 0;
        push(CommonBookingDetailScreen(bookingId: notId.toString().toInt()));
      } catch (e) {
        throw errorSomethingWentWrong;
      }
    });
    afterBuildCreated(() {
      int val = getIntAsync(THEME_MODE_INDEX);

      if (val == THEME_MODE_LIGHT) {
        appStore.setDarkMode(false);
      } else if (val == THEME_MODE_DARK) {
        appStore.setDarkMode(true);
      }

      connectivitySubscription = Connectivity().onConnectivityChanged.listen((e) {
        if (e == ConnectivityResult.none) {
          isCurrentlyOnNoInternet = true;
          push(OppsScreen(), pageRouteAnimation: PageRouteAnimation.Fade);
        } else {
          if (isCurrentlyOnNoInternet) {
            pop();
            isCurrentlyOnNoInternet = false;
          }
        }
      });
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        home: SplashScreen(),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        scrollBehavior: SBehavior(),
        supportedLocales: LanguageDataModel.languageLocales(),
        localizationsDelegates: [
          AppLocalizations(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) => locale,
        locale: Locale(appStore.selectedLanguageCode),
      ),
    );
  }
}

class RestartWidget extends StatefulWidget {
  final Widget child;

  RestartWidget({required this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()!.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
