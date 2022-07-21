import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/fragments/booking_fragment.dart';
import 'package:handyman_provider_flutter/fragments/notification_fragment.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/provider/fragments/provider_home_fragment.dart';
import 'package:handyman_provider_flutter/provider/fragments/provider_payment_fragment.dart';
import 'package:handyman_provider_flutter/provider/fragments/provider_profile_fragment.dart';
import 'package:handyman_provider_flutter/screens/chat/user_chat_list_screen.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class ProviderDashboardScreen extends StatefulWidget {
  final int? index;

  ProviderDashboardScreen({this.index});

  @override
  ProviderDashboardScreenState createState() => ProviderDashboardScreenState();
}

class ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  int currentIndex = 0;

  DateTime? currentBackPressTime;

  List<Widget> fragmentList = [
    ProviderHomeFragment(),
    BookingFragment(),
    ProviderPaymentFragment(),
    ProviderProfileFragment(),
  ];

  List<String> screenName = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    afterBuildCreated(
      () async {
        if (getIntAsync(THEME_MODE_INDEX) == THEME_MODE_SYSTEM) {
          appStore.setDarkMode(context.platformBrightness() == Brightness.dark);
        }

        window.onPlatformBrightnessChanged = () async {
          if (getIntAsync(THEME_MODE_INDEX) == THEME_MODE_SYSTEM) {
            appStore.setDarkMode(context.platformBrightness() == Brightness.light);
          }
        };
      },
    );

    LiveStream().on(LIVESTREAM_PROVIDER_ALL_BOOKING, (index) {
      currentIndex = index as int;
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    LiveStream().dispose(LIVESTREAM_PROVIDER_ALL_BOOKING);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        DateTime now = DateTime.now();

        if (currentBackPressTime == null || now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
          currentBackPressTime = now;
          toast(context.translate.lblCloseAppMsg);
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Scaffold(
        body: fragmentList[currentIndex],
        appBar: appBarWidget(
          [
            context.translate.lblProviderDashboard,
            context.translate.lblBooking,
            context.translate.lblPayment,
            context.translate.lblProfile,
          ][currentIndex],
          color: primaryColor,
          textColor: Colors.white,
          showBack: false,
          actions: [
            IconButton(
              icon: chat.iconImage(color: white, size: 20),
              onPressed: () async {
                UserChatListScreen().launch(context);
              },
            ),
            IconButton(
              icon: ic_notification.iconImage(color: white, size: 20),
              onPressed: () async {
                NotificationFragment().launch(context);
              },
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          items: [
            BottomNavigationBarItem(
              icon: ic_home.iconImage(color: appTextSecondaryColor),
              label: 'Dashboard',
              activeIcon: ic_fill_home.iconImage(color: primaryColor),
            ),
            BottomNavigationBarItem(
              icon: total_booking.iconImage(color: appTextSecondaryColor),
              label: 'Bookings',
              activeIcon: fill_ticket.iconImage(color: primaryColor),
            ),
            BottomNavigationBarItem(
              icon: un_fill_wallet.iconImage(color: appTextSecondaryColor),
              label: 'Payment',
              activeIcon: ic_fill_wallet.iconImage(color: primaryColor),
            ),
            BottomNavigationBarItem(
              icon: ic_notification.iconImage(color: appTextSecondaryColor),
              label: 'Notifications',
              activeIcon: ic_fill_profile.iconImage(color: primaryColor),
            ),
          ],
          onTap: (index) {
            currentIndex = index;
            setState(() {});
          },
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
        ),
      ),
    );
  }
}
