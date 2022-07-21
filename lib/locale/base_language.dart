import 'package:flutter/material.dart';

abstract class Languages {
  static Languages of(BuildContext context) => Localizations.of<Languages>(context, Languages)!;

  String planAboutToExpire(int days);

  String get appName;

  String get lblProviderDashboard;

  String get provider;

  String get welcome;

  String get back;

  String get lblHandymanDashboard;

  String get lblShowingOnly4Handyman;

  String get lblRecentlyOnlineHandyman;

  String get lblStartDrive;

  String get handyman;

  String get signIn;

  String get signUp;

  String get signInTitle;

  String get signUpTitle;

  String get hintNameTxt;

  String get hintFirstNameTxt;

  String get hintLastNameTxt;

  String get hintContactNumberTxt;

  String get hintEmailAddressTxt;

  String get hintUserNameTxt;

  String get hintPasswordTxt;

  String get hintReenterPasswordTxt;

  String get confirm;

  String get hintEmailTxt;

  String get hintConfirmPasswordTxt;

  String get forgotPassword;

  String get reset;

  String get alreadyHaveAccountTxt;

  String get rememberMe;

  String get forgotPasswordTitleTxt;

  String get resetPassword;

  String get loginSuccessfully;

  String get editProfile;

  String get saveChanges;

  String get camera;

  String get language;

  String get supportLanguage;

  String get appTheme;

  String get bookingHistory;

  String get logout;

  String get afterLogoutTxt;

  String get chooseTheme;

  String get selectCountry;

  String get selectState;

  String get selectCity;

  String get changePassword;

  String get passwordNotMatch;

  String get doNotHaveAccount;

  String get hintNewPasswordTxt;

  String get hintOldPasswordTxt;

  String get home;

  String get review;

  String get notification;

  String get accept;

  String get decline;

  String get noDataFound;

  String get pending;

  String get paymentPending;

  String get darkMode;

  String get lightMode;

  String get systemDefault;

  String get serviceDetail;

  String get confirmationRequestTxt;

  String get notAvailable;

  String get lblGallery;

  String get markAsRead;

  String get cantLogin;

  String get pleaseContactAdmin;

  String get lblOk;

  String get totalWorking;

  String get paymentStatus;

  String get paymentMethod;

  String get category;

  String get hintAddress;

  String get lblCheckInternet;

  String get quantity;

  String get paymentReceived;

  String get lblInternetWait;

  String get lblYes;

  String get lblNo;

  String get lblReason;

  String get cantChangePw;

  String get lblSelectHandyman;

  String get lblAssign;

  String get lblCall;

  String get lblLocation;

  String get lblAssignHandyman;

  String get lblAssigned;

  String get viewAll;

  String get lblMonthlyRevenue;

  String get lblRevenue;

  String get lblAddHandyman;

  String get hintName;

  String get hintLastName;

  String get hintEmail;

  String get hintUserName;

  String get hintContact;

  String get hintPass;

  String get lblBooking;

  String get lblTotalBooking;

  String get lblTotalService;

  String get lblTotalHandyman;

  String get lblTotalRevenue;

  String get lblPayment;

  String get lblBookingID;

  String get lblPaymentID;

  String get lblAmount;

  String get toastConnected;

  String get hintAddService;

  String get hintServiceName;

  String get hintSelectCategory;

  String get hintSelectType;

  String get hintSelectStatus;

  String get hintPrice;

  String get hintDiscount;

  String get hintDuration;

  String get hintDescription;

  String get hintSetAsFeature;

  String get hintAdd;

  String get hintChooseImage;

  String get customer;

  String get lblCategory;

  String get lblProfile;

  String get lblAllHandyman;

  String get lblTime;

  String get lblMyService;

  String get lblAllService;

  String get lblAddService;

  String get lblCreateAccount;

  String get lblChat;

  String get dltMessage;

  String get lblImg;

  String get lblVideo;

  String get lblAudio;

  String get selectAddress;

  String get btnSave;

  String get editAddress;

  String get lblUpdate;

  String get lblEdit;

  String get lblDelete;

  String get lblServiceAddress;

  String get lblServices;

  String get lblEditService;

  String get selectImgNote;

  String get lblDurationHr;

  String get lblDurationMin;

  String get lblError;

  String get lblWriteMsg;

  String get lblWaitForAcceptReq;

  String get lblContactAdmin;

  String get lblAddServiceAddress;

  String get lblAvailableAddress;

  String get lblEnterValidEmailPw;

  String get lblSomethingWrong;

  String get lblNotFoundUser;

  String get lblNoUserFound;

  String get lblNoDataFound;

  String get lblInvalidUrl;

  String get errorPasswordLength;

  String get hintEmailAddress;

  String get hintPassword;

  String get hintFirstNm;

  String get hintLastNm;

  String get hintUserNm;

  String get hintContactNumber;

  String get hintEnterProperData;

  String get hintRequired;

  String get lblUnAuthorized;

  String get btnVerifyId;

  String get confirmationUpload;

  String get toastSuccess;

  String get lblSelectDoc;

  String get lblAddDoc;

  String get lblAppSetting;

  String get lblRateUs;

  String get lblTermsAndConditions;

  String get lblPrivacyPolicy;

  String get lblHelpAndSupport;

  String get lblVersion;

  String get lblAbout;

  String get lblProviderType;

  String get lblMyCommission;

  String get lblTaxes;

  String get lblTaxName;

  String get lblMyTax;

  String get lbllogintitle;

  String get lblloginsubtitle;

  String get lblsignuptitle;

  String get lblsignupsubtitle;

  String get lblLogin;

  String get lblsignup;

  String get lblUserType;

  String get lblPurchaseCode;

  String get lblFeatureProduct;

  String get lblHours;

  String get lblRating;

  String get lblOff;

  String get lblHr;

  String get lblDate;

  String get lblAboutHandyman;

  String get lblAboutCustomer;

  String get lblPaymentDetail;

  String get lblId;

  String get lblMethod;

  String get lblStatus;

  String get lblPriceDetail;

  String get lblSubTotal;

  String get lblTax;

  String get lblCoupon;

  String get lblTotalAmount;

  String get lblOnBasisOf;

  String get lblCheckStatus;

  String get lblReady;

  String get lblCancel;

  String get lblUnreadNotification;

  String get lblMarkAllAsRead;

  String get lblCloseAppMsg;

  String get lblAddress;

  String get lblType;

  String get lblStatusType;

  String get lblHandymanType;

  String get lblFixed;

  String get lblHello;

  String get lblWelcomeBack;

  String get lblUpcomingBooking;

  String get lblTodayBooking;

  String get lblNoReviewYet;

  String get lblAllReview;

  String get lblWaitingForResponse;

  String get lblConfirmPayment;

  String get lblWaitingForPayment;

  String get lblOnGoing;

  String get lblPaymentDone;

  String get lblDelivered;

  String get lblDay;

  String get lblYear;

  String get lblExperience;

  String get lblOf;

  String get lblSelectAddress;

  String get lblActivate;

  String get lblDeactivate;

  String get lblOpps;

  String get lblNoInternet;

  String get lblRetry;

  String get lblBookingSummary;

  String get lblServiceStatus;

  String get lblMemberSince;

  String get lblDeleteAddress;

  String get lblDeleteAddressMsg;

  String get lblChoosePaymentMethod;

  String get lblNoPayments;

  String get lblPayWith;

  String get lblProceed;

  String get lblPricingPlan;

  String get lblSelectPlan;

  String get lblMakePayment;

  String get lblRestore;

  String get lblForceDelete;

  String get lblActivated;

  String get lblDeactivated;

  String get lblNoDescriptionAvailable;

  String get lblFAQs;

  String get lblGetDirection;

  String get lblDeleteTitle;

  String get lblDeleteSubTitle;

  String get lblUpcomingServices;

  String get lblTodayServices;

  String get lblPlanExpired;

  String get lblPlanSubTitle;

  String get btnTxtBuyNow;

  String get lblChooseYourPlan;

  String get lblRenewSubTitle;

  String get lblReminder;

  String get lblRenew;

  String get lblCurrentPlan;

  String get lblValidTill;

  String get lblSearchHere;

  String get lblEarningList;

  String get lblNoChatFound;

  String get lblIsSuccessFullyActivated;

  String get lblSubscriptionTitle;

  String get lblPlan;

  String get lblCancelPlan;

  String get lblSubscriptionHistory;

  String get lblDemoProvider;

  String get lblDemoHandyman;

  String get lblReset;

  String get lblRequired;

  String get lblGiveReason;

  String get lblTrashHandyman;

  String get lblPlsSelectAddress;

  String get lblPlsSelectCategory;

  String get lblEnterHours;

  String get lblEnterMinute;

  // Add Localization
  String get lblSelectSubCategory;

  String get lblServiceProof;

  String get lblTitle;

  String get lblAddImage;

  String get lblSubmit;

  String get lblNotHelpLineNum;

  String get lblWalletHistory;

  String get lblServiceRatings;

  String get lblNoServiceRatings;

  String get lblEmail;

  String get lblWallet;

  String get lblSelectUserType;

  String get lblIAgree;

  String get lblTermsOfService;

  String get lblLoginAgain;

  String get lblTermCondition;

  String get lblServiceTotalTime;

  String get lblHelpLineNum;

  String get lblReasonCancelling;

  String get lblReasonRejecting;

  String get lblFailed;

  String get lblDesignation;

  String get lblHandymanIsOffline;

  String get lblDoYouWantToRestore;

  String get lblDoYouWantToDeleteForcefully;

  String get lblDoYouWantToDelete;
}
