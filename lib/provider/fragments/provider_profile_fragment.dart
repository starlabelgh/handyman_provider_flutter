import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:handyman_provider_flutter/auth/change_password_screen.dart';
import 'package:handyman_provider_flutter/auth/edit_profile_screen.dart';
import 'package:handyman_provider_flutter/components/theme_selection_dailog.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/handyman_list_screen.dart';
import 'package:handyman_provider_flutter/provider/service_address/service_addresses_screen.dart';
import 'package:handyman_provider_flutter/provider/services/service_list_screen.dart';
import 'package:handyman_provider_flutter/provider/subscription/subscription_history_screen.dart';
import 'package:handyman_provider_flutter/provider/taxes/taxes_screen.dart';
import 'package:handyman_provider_flutter/provider/wallet/wallet_history_screen.dart';
import 'package:handyman_provider_flutter/screens/about_us_screen.dart';
import 'package:handyman_provider_flutter/screens/languages_screen.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class ProviderProfileFragment extends StatefulWidget {
  final List<UserData>? list;

  ProviderProfileFragment({this.list});

  @override
  ProviderProfileFragmentState createState() => ProviderProfileFragmentState();
}

class ProviderProfileFragmentState extends State<ProviderProfileFragment> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(
        builder: (_) => SingleChildScrollView(
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  24.height,
                  if (appStore.userProfileImage.isNotEmpty)
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          decoration: boxDecorationDefault(
                            border: Border.all(color: primaryColor, width: 3),
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            decoration: boxDecorationDefault(
                              border: Border.all(color: context.scaffoldBackgroundColor, width: 4),
                              shape: BoxShape.circle,
                            ),
                            child: circleImage(image: appStore.userProfileImage.validate(), size: 120),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 8,
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(6),
                            decoration: boxDecorationDefault(
                              shape: BoxShape.circle,
                              color: primaryColor,
                              border: Border.all(color: context.cardColor, width: 2),
                            ),
                            child: Icon(AntDesign.edit, color: white, size: 18),
                          ).onTap(() {
                            HEditProfileScreen().launch(
                              context,
                              pageRouteAnimation: PageRouteAnimation.Fade,
                            );
                          }),
                        ),
                      ],
                    ),
                  16.height,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        appStore.userFullName,
                        style: boldTextStyle(color: primaryColor, size: 18),
                      ),
                      4.height,
                      Text(appStore.userEmail, style: secondaryTextStyle()),
                    ],
                  ),
                ],
              ).center().visible(appStore.isLoggedIn),
              if (appStore.earningTypeSubscription && appStore.isPlanSubscribe)
                Column(
                  children: [
                    32.height,
                    Container(
                      decoration: boxDecorationWithRoundedCorners(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        backgroundColor: appStore.isDarkMode ? cardDarkColor : primaryColor.withOpacity(0.1),
                      ),
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(context.translate.lblCurrentPlan, style: boldTextStyle(color: appStore.isDarkMode ? white : gray)),
                              Text(context.translate.lblValidTill, style: boldTextStyle(color: appStore.isDarkMode ? white : gray)),
                            ],
                          ),
                          16.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(appStore.planTitle.validate().capitalizeFirstLetter(), style: boldTextStyle()),
                              Text(
                                formatDate(appStore.planEndDate.validate(), format: DATE_FORMAT_2),
                                style: boldTextStyle(color: primaryColor),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              32.height,
              Container(
                decoration: boxDecorationWithRoundedCorners(
                  borderRadius: BorderRadius.only(topRight: Radius.circular(32), topLeft: Radius.circular(32)),
                  backgroundColor: appStore.isDarkMode ? cardDarkColor : cardColor,
                ),
                child: Column(
                  children: [
                    16.height,
                    if (appStore.earningTypeSubscription)
                      SettingItemWidget(
                        leading: Image.asset(services, height: 20, width: 20, color: appStore.isDarkMode ? white : gray.withOpacity(0.8)),
                        title: context.translate.lblSubscriptionHistory,
                        trailing: Icon(Icons.chevron_right, color: appStore.isDarkMode ? white : gray.withOpacity(0.8), size: 24),
                        onTap: () async {
                          SubscriptionHistoryScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Fade).then((value) {
                            setState(() {});
                          });
                        },
                      ),
                    if (appStore.earningTypeSubscription) Divider(height: 0, thickness: 1, indent: 15.0, endIndent: 15.0).visible(appStore.isLoggedIn),
                    SettingItemWidget(
                      leading: Image.asset(services, height: 20, width: 20, color: appStore.isDarkMode ? white : gray.withOpacity(0.8)),
                      title: context.translate.lblServices,
                      trailing: Icon(Icons.chevron_right, color: appStore.isDarkMode ? white : gray.withOpacity(0.8), size: 24),
                      onTap: () {
                        ServiceListScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                      },
                    ),
                    Divider(height: 0, thickness: 1, indent: 15.0, endIndent: 15.0).visible(appStore.isLoggedIn),
                    SettingItemWidget(
                      leading: Image.asset(
                        handyman,
                        height: 20,
                        width: 20,
                        color: appStore.isDarkMode ? white : gray.withOpacity(0.8),
                      ),
                      title: context.translate.lblAllHandyman,
                      trailing: Icon(Icons.chevron_right, color: appStore.isDarkMode ? white : gray.withOpacity(0.8), size: 24),
                      onTap: () {
                        HandymanListScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                      },
                    ),
                    Divider(
                      height: 0,
                      thickness: 1,
                      indent: 15.0,
                      endIndent: 15.0,
                    ).visible(appStore.isLoggedIn),
                    SettingItemWidget(
                      leading: Image.asset(
                        servicesAddress,
                        height: 20,
                        width: 20,
                        color: appStore.isDarkMode ? white : gray.withOpacity(0.8),
                      ),
                      title: context.translate.lblServiceAddress,
                      trailing: Icon(Icons.chevron_right, color: appStore.isDarkMode ? white : gray.withOpacity(0.8), size: 24),
                      onTap: () {
                        ServiceAddressesScreen(false).launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                      },
                    ),
                    Divider(
                      height: 0,
                      thickness: 1,
                      indent: 15.0,
                      endIndent: 15.0,
                    ).visible(appStore.isLoggedIn),
                    SettingItemWidget(
                      leading: Image.asset(
                        percent_line,
                        height: 20,
                        width: 20,
                        color: appStore.isDarkMode ? white : gray.withOpacity(0.8),
                      ),
                      title: context.translate.lblTaxes,
                      trailing: Icon(Icons.chevron_right, color: appStore.isDarkMode ? white : gray.withOpacity(0.8), size: 24),
                      onTap: () {
                        TaxesScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                      },
                    ),
                    if (appStore.earningTypeCommission)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(height: 0, thickness: 1, indent: 15.0, endIndent: 15.0).visible(appStore.isLoggedIn),
                          SettingItemWidget(
                            leading: Image.asset(
                              percent_line,
                              height: 20,
                              width: 20,
                              color: appStore.isDarkMode ? white : gray.withOpacity(0.8),
                            ),
                            title: context.translate.lblWalletHistory,
                            trailing: Icon(Icons.chevron_right, color: appStore.isDarkMode ? white : gray.withOpacity(0.8), size: 24),
                            onTap: () {
                              WalletHistoryScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                            },
                          ),
                        ],
                      ),
                    Divider(height: 0, thickness: 1, indent: 15.0, endIndent: 15.0).visible(appStore.isLoggedIn),
                    SettingItemWidget(
                      leading: Image.asset(
                        ic_theme,
                        height: 20,
                        width: 20,
                        color: appStore.isDarkMode ? white : gray.withOpacity(0.8),
                      ),
                      title: context.translate.appTheme,
                      trailing: Icon(Icons.chevron_right, color: appStore.isDarkMode ? white : gray.withOpacity(0.8), size: 24),
                      onTap: () async {
                        await showInDialog(
                          context,
                          builder: (context) => ThemeSelectionDaiLog(context),
                          contentPadding: EdgeInsets.zero,
                        );
                      },
                    ),
                    Divider(height: 0, thickness: 1, indent: 15.0, endIndent: 15.0).visible(appStore.isLoggedIn),
                    SettingItemWidget(
                      leading: Image.asset(
                        language,
                        height: 20,
                        width: 20,
                        color: appStore.isDarkMode ? white : gray.withOpacity(0.8),
                      ),
                      title: context.translate.language,
                      trailing: Icon(Icons.chevron_right, color: appStore.isDarkMode ? white : gray.withOpacity(0.8), size: 24),
                      onTap: () {
                        LanguagesScreen().launch(context);
                      },
                    ),
                    Divider(height: 0, thickness: 1, indent: 15.0, endIndent: 15.0).visible(appStore.isLoggedIn),
                    SettingItemWidget(
                      leading: Image.asset(changePassword, height: 20, width: 20, color: appStore.isDarkMode ? white : gray.withOpacity(0.8)),
                      title: context.translate.changePassword,
                      trailing: Icon(Icons.chevron_right, color: appStore.isDarkMode ? white : gray.withOpacity(0.8), size: 24),
                      onTap: () {
                        ChangePasswordScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                      },
                    ),
                    Divider(height: 0, thickness: 1, indent: 15.0, endIndent: 15.0).visible(appStore.isLoggedIn),
                    SettingItemWidget(
                      leading: Image.asset(about, height: 20, width: 20, color: appStore.isDarkMode ? white : gray.withOpacity(0.8)),
                      title: context.translate.lblAbout,
                      trailing: Icon(Icons.chevron_right, color: appStore.isDarkMode ? white : gray.withOpacity(0.8), size: 24),
                      onTap: () {
                        AboutUsScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                      },
                    ),
                    Divider(height: 0, thickness: 1, indent: 15.0, endIndent: 15.0).visible(appStore.isLoggedIn),
                    SettingItemWidget(
                      leading: Image.asset(purchase, height: 20, width: 20, color: appStore.isDarkMode ? white : gray.withOpacity(0.8)),
                      title: context.translate.lblPurchaseCode,
                      trailing: Icon(Icons.chevron_right, color: appStore.isDarkMode ? white : gray.withOpacity(0.8), size: 24),
                      onTap: () {
                        launchUrlCustomTab(PURCHASE_URL);
                      },
                    ).visible(isIqonicProduct),
                    20.height,
                    TextButton(
                      child: Text(context.translate.logout, style: boldTextStyle(color: primaryColor, size: 18)),
                      onPressed: () {
                        appStore.setLoading(false);
                        logout(context);
                      },
                    ).visible(appStore.isLoggedIn),
                    VersionInfoWidget(prefixText: 'v', textStyle: secondaryTextStyle(size: 14)).center(),

                    /*FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snap) {
                        if (snap.hasData) {
                          return Text("v${snap.data!.version.validate(value: '1.0.0')}", style: secondaryTextStyle(size: 14));
                        }
                        return snapWidgetHelper(snap, loadingWidget: Offstage());
                      },
                    ).center(),*/
                    24.height,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
