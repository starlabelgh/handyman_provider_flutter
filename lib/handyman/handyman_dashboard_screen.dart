import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/fragments/booking_fragment.dart';
import 'package:handyman_provider_flutter/fragments/notification_fragment.dart';
import 'package:handyman_provider_flutter/handyman/screen/fragments/handyman_fragment.dart';
import 'package:handyman_provider_flutter/handyman/screen/fragments/handyman_profile_fragment.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/screens/chat/user_chat_list_screen.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class HandymanDashboardScreen extends StatefulWidget {
  final int? index;

  HandymanDashboardScreen({this.index});

  @override
  _HandymanDashboardScreenState createState() => _HandymanDashboardScreenState();
}

class _HandymanDashboardScreenState extends State<HandymanDashboardScreen> {
  int currentIndex = 0;

  List<Widget> fragmentList = [
    HandymanHomeFragment(),
    BookingFragment(),
    NotificationFragment(),
    HandymanProfileFragment(),
  ];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    setStatusBarColor(primaryColor);

    afterBuildCreated(() async {
      if (getIntAsync(THEME_MODE_INDEX) == THEME_MODE_SYSTEM) {
        appStore.setDarkMode(context.platformBrightness() == Brightness.dark);
      }

      window.onPlatformBrightnessChanged = () async {
        if (getIntAsync(THEME_MODE_INDEX) == THEME_MODE_SYSTEM) {
          appStore.setDarkMode(context.platformBrightness() == Brightness.light);
        }
      };
    });

    LiveStream().on(LIVESTREAM_HANDY_BOARD, (index) {
      currentIndex = index as int;
      setState(() {});
    });

    LiveStream().on(LIVESTREAM_HANDYMAN_ALL_BOOKING, (index) {
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
    LiveStream().dispose(LIVESTREAM_HANDY_BOARD);
    LiveStream().dispose(LIVESTREAM_HANDYMAN_ALL_BOOKING);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: fragmentList[currentIndex],
      appBar: appBarWidget(
        [
          context.translate.lblHandymanDashboard,
          context.translate.lblBooking,
          context.translate.notification,
          context.translate.lblProfile,
        ][currentIndex],
        color: primaryColor,
        elevation: 0.0,
        textColor: Colors.white,
        showBack: false,
        actions: [
          IconButton(
            icon: Image.asset(chat, height: 20, width: 20, color: white),
            onPressed: () async {
              UserChatListScreen().launch(context);
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
            icon: ic_notification.iconImage(color: appTextSecondaryColor),
            label: 'Notifications',
            activeIcon: ic_fill_notification.iconImage(color: primaryColor),
          ),
          BottomNavigationBarItem(
            icon: profile.iconImage(color: appTextSecondaryColor),
            label: 'Profile',
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
    );
  }
}
