import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('ml'),
    Locale('ta'),
  ];

  /// Product name. Not translated — it is a brand.
  ///
  /// In en, this message translates to:
  /// **'ELK Business Hub'**
  String get appTitle;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @deleteListing.
  ///
  /// In en, this message translates to:
  /// **'Delete this listing?'**
  String get deleteListing;

  /// No description provided for @pauseListing.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseListing;

  /// No description provided for @resumeListing.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeListing;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved'**
  String get draftSaved;

  /// No description provided for @fillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Fill in category, title and price first.'**
  String get fillRequiredFields;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @photosAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} added'**
  String photosAdded(int count);

  /// No description provided for @markCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark completed'**
  String get markCompleted;

  /// No description provided for @needAttention.
  ///
  /// In en, this message translates to:
  /// **'{count} need attention'**
  String needAttention(int count);

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get placeOrder;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order placed · {code}'**
  String orderPlaced(String code);

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get commonSeeAll;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// Shown when a screen has no more specific message.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request timed out. Please try again.'**
  String get errorTimeout;

  /// No description provided for @errorNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network and try again.'**
  String get errorNoInternet;

  /// No description provided for @errorCancelled.
  ///
  /// In en, this message translates to:
  /// **'The request was cancelled.'**
  String get errorCancelled;

  /// No description provided for @errorInsecureConnection.
  ///
  /// In en, this message translates to:
  /// **'Could not establish a secure connection.'**
  String get errorInsecureConnection;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnknown;

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'Please check your input and try again.'**
  String get errorValidation;

  /// No description provided for @errorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get errorSessionExpired;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to do that.'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'The requested resource was not found.'**
  String get errorNotFound;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a moment and try again.'**
  String get errorTooManyRequests;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side. Please try again later.'**
  String get errorServer;

  /// No description provided for @signInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your mobile number to continue.'**
  String get signInRequired;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @registerBusinessPrompt.
  ///
  /// In en, this message translates to:
  /// **'Register your business to start receiving bookings.'**
  String get registerBusinessPrompt;

  /// No description provided for @becomeProvider.
  ///
  /// In en, this message translates to:
  /// **'Become a Provider'**
  String get becomeProvider;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change this anytime from settings.'**
  String get languageSubtitle;

  /// No description provided for @languageSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your language. Please try again.'**
  String get languageSaveFailed;

  /// No description provided for @commonOr.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get commonOr;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @byContinuingYouAgree.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to our '**
  String get byContinuingYouAgree;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get navBookings;

  /// No description provided for @navWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get navWallet;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @onboardServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'All Your Services, One App'**
  String get onboardServicesTitle;

  /// No description provided for @onboardServicesBody.
  ///
  /// In en, this message translates to:
  /// **'Book rides, cleaning, rentals, and more — from verified providers in your city. Fast, reliable, trusted.'**
  String get onboardServicesBody;

  /// No description provided for @onboardTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Real-Time Tracking & Chat'**
  String get onboardTrackingTitle;

  /// No description provided for @onboardTrackingBody.
  ///
  /// In en, this message translates to:
  /// **'Follow your provider live on the map and chat directly with them for a smooth, transparent experience.'**
  String get onboardTrackingBody;

  /// No description provided for @onboardPaymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure Payments & Rewards'**
  String get onboardPaymentsTitle;

  /// No description provided for @onboardPaymentsBody.
  ///
  /// In en, this message translates to:
  /// **'Pay safely with your wallet, card, or cash, and earn reward points on every booking you make.'**
  String get onboardPaymentsBody;

  /// No description provided for @splashSettingUp.
  ///
  /// In en, this message translates to:
  /// **'Setting up your city'**
  String get splashSettingUp;

  /// No description provided for @splashFindingPros.
  ///
  /// In en, this message translates to:
  /// **'Finding trusted pros'**
  String get splashFindingPros;

  /// No description provided for @splashAlmostThere.
  ///
  /// In en, this message translates to:
  /// **'Almost there'**
  String get splashAlmostThere;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get authWelcomeBack;

  /// No description provided for @authSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your mobile number to continue'**
  String get authSignInPrompt;

  /// No description provided for @authMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get authMobileNumber;

  /// No description provided for @authSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get authSendOtp;

  /// No description provided for @authContinueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get authContinueAsGuest;

  /// No description provided for @authVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Number'**
  String get authVerifyTitle;

  /// No description provided for @authOtpSentTo.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a 6-digit code to '**
  String get authOtpSentTo;

  /// No description provided for @authVerifyContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify & Continue'**
  String get authVerifyContinue;

  /// No description provided for @authResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get authResendCode;

  /// No description provided for @authResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in 00:{seconds}'**
  String authResendIn(String seconds);

  /// No description provided for @homeBestSellersTag.
  ///
  /// In en, this message translates to:
  /// **'Best sellers'**
  String get homeBestSellersTag;

  /// No description provided for @homeBestSellersRest.
  ///
  /// In en, this message translates to:
  /// **'near you'**
  String get homeBestSellersRest;

  /// No description provided for @homeBestSellersSub.
  ///
  /// In en, this message translates to:
  /// **'Most saved and most viewed listings'**
  String get homeBestSellersSub;

  /// No description provided for @homeDealsTag.
  ///
  /// In en, this message translates to:
  /// **'Deals'**
  String get homeDealsTag;

  /// No description provided for @homeDealsRest.
  ///
  /// In en, this message translates to:
  /// **'for you'**
  String get homeDealsRest;

  /// No description provided for @homeDealsSub.
  ///
  /// In en, this message translates to:
  /// **'More from sellers near you'**
  String get homeDealsSub;

  /// No description provided for @homeServiceAt.
  ///
  /// In en, this message translates to:
  /// **'Service at'**
  String get homeServiceAt;

  /// No description provided for @homeSelectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select location'**
  String get homeSelectLocation;

  /// No description provided for @homeServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get homeServices;

  /// No description provided for @homeBadgeFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get homeBadgeFast;

  /// No description provided for @homeBadgeNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get homeBadgeNew;

  /// No description provided for @homeBadgeTwentyOff.
  ///
  /// In en, this message translates to:
  /// **'20% OFF'**
  String get homeBadgeTwentyOff;

  /// No description provided for @homeNoSellerAds.
  ///
  /// In en, this message translates to:
  /// **'No seller ads yet'**
  String get homeNoSellerAds;

  /// No description provided for @homeMoreListingsSoon.
  ///
  /// In en, this message translates to:
  /// **'More listings will show up here as sellers post.'**
  String get homeMoreListingsSoon;

  /// No description provided for @promoFirstBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'20% off your\nfirst booking'**
  String get promoFirstBookingTitle;

  /// No description provided for @promoFirstBookingBody.
  ///
  /// In en, this message translates to:
  /// **'New members get an exclusive discount across every service.'**
  String get promoFirstBookingBody;

  /// No description provided for @promoClaimOffer.
  ///
  /// In en, this message translates to:
  /// **'Claim offer'**
  String get promoClaimOffer;

  /// No description provided for @promoFreeRidesTitle.
  ///
  /// In en, this message translates to:
  /// **'Free rides\nevery week'**
  String get promoFreeRidesTitle;

  /// No description provided for @promoFreeRidesBody.
  ///
  /// In en, this message translates to:
  /// **'Members unlock weekly perks, priority support and lower fees.'**
  String get promoFreeRidesBody;

  /// No description provided for @promoJoinNow.
  ///
  /// In en, this message translates to:
  /// **'Join now'**
  String get promoJoinNow;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignOut;

  /// No description provided for @profileSignOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get profileSignOutConfirm;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEdit;

  /// No description provided for @profileRewardPoints.
  ///
  /// In en, this message translates to:
  /// **'Reward Points'**
  String get profileRewardPoints;

  /// No description provided for @profileRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get profileRating;

  /// No description provided for @profileMyAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get profileMyAccount;

  /// No description provided for @profileOffersRewards.
  ///
  /// In en, this message translates to:
  /// **'Offers & Rewards'**
  String get profileOffersRewards;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileSavedAddresses.
  ///
  /// In en, this message translates to:
  /// **'Saved Addresses'**
  String get profileSavedAddresses;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileRateService.
  ///
  /// In en, this message translates to:
  /// **'Rate a Service'**
  String get profileRateService;

  /// No description provided for @profileProviderTools.
  ///
  /// In en, this message translates to:
  /// **'Provider Tools'**
  String get profileProviderTools;

  /// No description provided for @profileProviderDashboard.
  ///
  /// In en, this message translates to:
  /// **'Provider Dashboard'**
  String get profileProviderDashboard;

  /// No description provided for @profileSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get profileSupport;

  /// No description provided for @profileHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get profileHelpSupport;

  /// No description provided for @profileAbout.
  ///
  /// In en, this message translates to:
  /// **'About ELK Business Hub'**
  String get profileAbout;

  /// No description provided for @profileTermsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Terms & Privacy Policy'**
  String get profileTermsPrivacy;

  /// No description provided for @profileGuestTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re browsing as a guest'**
  String get profileGuestTitle;

  /// No description provided for @profileGuestBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your mobile number to view your profile, bookings, and rewards.'**
  String get profileGuestBody;

  /// No description provided for @profileNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get profileNameRequired;

  /// No description provided for @profileNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name must be 100 characters or fewer.'**
  String get profileNameTooLong;

  /// No description provided for @profileEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get profileEmailInvalid;

  /// No description provided for @profileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileNameLabel;

  /// No description provided for @profileEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get profileEmailLabel;

  /// No description provided for @walletToppedUp.
  ///
  /// In en, this message translates to:
  /// **'Wallet topped up'**
  String get walletToppedUp;

  /// No description provided for @walletWithdrawSuccess.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal successful'**
  String get walletWithdrawSuccess;

  /// No description provided for @walletStillLoading.
  ///
  /// In en, this message translates to:
  /// **'Wallet is still loading. Please try again.'**
  String get walletStillLoading;

  /// No description provided for @walletAddMoneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Money to Wallet'**
  String get walletAddMoneyTitle;

  /// No description provided for @walletWithdrawTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw to Bank'**
  String get walletWithdrawTitle;

  /// No description provided for @walletAddMoney.
  ///
  /// In en, this message translates to:
  /// **'Add Money'**
  String get walletAddMoney;

  /// No description provided for @walletWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get walletWithdraw;

  /// No description provided for @walletAmountTooSmall.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than 0'**
  String get walletAmountTooSmall;

  /// No description provided for @walletAmountTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Amount cannot exceed ₹1,000,000'**
  String get walletAmountTooLarge;

  /// No description provided for @walletSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in to use your ELK Wallet and reward points.'**
  String get walletSignInPrompt;

  /// No description provided for @walletAvailableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get walletAvailableBalance;

  /// No description provided for @walletTransactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get walletTransactionHistory;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusPendingVendor.
  ///
  /// In en, this message translates to:
  /// **'Pending vendor'**
  String get statusPendingVendor;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get statusUnknown;

  /// No description provided for @myBookingsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookingsTitle;

  /// No description provided for @bookingsSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see the services you have booked.'**
  String get bookingsSignInPrompt;

  /// No description provided for @tabUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get tabUpcoming;

  /// No description provided for @emptyUpcomingTitle.
  ///
  /// In en, this message translates to:
  /// **'No upcoming bookings'**
  String get emptyUpcomingTitle;

  /// No description provided for @emptyUpcomingBody.
  ///
  /// In en, this message translates to:
  /// **'Book a service and it will show up here.'**
  String get emptyUpcomingBody;

  /// No description provided for @emptyCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing completed yet'**
  String get emptyCompletedTitle;

  /// No description provided for @emptyCompletedBody.
  ///
  /// In en, this message translates to:
  /// **'Your finished bookings will appear here.'**
  String get emptyCompletedBody;

  /// No description provided for @emptyCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'No cancelled bookings'**
  String get emptyCancelledTitle;

  /// No description provided for @emptyCancelledBody.
  ///
  /// In en, this message translates to:
  /// **'Cancellations will be listed here.'**
  String get emptyCancelledBody;

  /// No description provided for @bookingDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking details'**
  String get bookingDetailsTitle;

  /// No description provided for @sectionStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get sectionStatus;

  /// No description provided for @sectionScheduleAddress.
  ///
  /// In en, this message translates to:
  /// **'Schedule & address'**
  String get sectionScheduleAddress;

  /// No description provided for @labelDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & time'**
  String get labelDateTime;

  /// No description provided for @labelServiceAddress.
  ///
  /// In en, this message translates to:
  /// **'Service address'**
  String get labelServiceAddress;

  /// No description provided for @sectionVendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get sectionVendor;

  /// No description provided for @vendorContactUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Vendor contact isn\'t available yet'**
  String get vendorContactUnavailable;

  /// No description provided for @callAction.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callAction;

  /// No description provided for @sectionPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get sectionPayment;

  /// No description provided for @lineService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get lineService;

  /// No description provided for @totalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total paid'**
  String get totalPaid;

  /// No description provided for @totalCancelled.
  ///
  /// In en, this message translates to:
  /// **'Total (cancelled)'**
  String get totalCancelled;

  /// No description provided for @bookingId.
  ///
  /// In en, this message translates to:
  /// **'Booking ID'**
  String get bookingId;

  /// No description provided for @copyAction.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyAction;

  /// No description provided for @cancelIsFreeNote.
  ///
  /// In en, this message translates to:
  /// **'Cancelling an upcoming booking is free and frees your slot straight away.'**
  String get cancelIsFreeNote;

  /// No description provided for @rebookThisService.
  ///
  /// In en, this message translates to:
  /// **'Rebook this service'**
  String get rebookThisService;

  /// No description provided for @ratedStar.
  ///
  /// In en, this message translates to:
  /// **'Rated ★'**
  String get ratedStar;

  /// No description provided for @rateAction.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rateAction;

  /// No description provided for @rebookAction.
  ///
  /// In en, this message translates to:
  /// **'Rebook'**
  String get rebookAction;

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track order'**
  String get trackOrder;

  /// No description provided for @cancelling.
  ///
  /// In en, this message translates to:
  /// **'Cancelling…'**
  String get cancelling;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get cancelBooking;

  /// No description provided for @cancelBookingQuestion.
  ///
  /// In en, this message translates to:
  /// **'Cancel this booking?'**
  String get cancelBookingQuestion;

  /// No description provided for @whyCancelling.
  ///
  /// In en, this message translates to:
  /// **'Why are you cancelling?'**
  String get whyCancelling;

  /// No description provided for @cancelReasonPlans.
  ///
  /// In en, this message translates to:
  /// **'Changed my plans'**
  String get cancelReasonPlans;

  /// No description provided for @cancelReasonAlternative.
  ///
  /// In en, this message translates to:
  /// **'Found another option'**
  String get cancelReasonAlternative;

  /// No description provided for @cancelReasonWrongTime.
  ///
  /// In en, this message translates to:
  /// **'Wrong date/time'**
  String get cancelReasonWrongTime;

  /// No description provided for @cancelReasonExpensive.
  ///
  /// In en, this message translates to:
  /// **'Too expensive'**
  String get cancelReasonExpensive;

  /// No description provided for @cancelReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get cancelReasonOther;

  /// No description provided for @cancellingIsFreePrefix.
  ///
  /// In en, this message translates to:
  /// **'Cancelling is free — '**
  String get cancellingIsFreePrefix;

  /// No description provided for @cancellingIsFreeSuffix.
  ///
  /// In en, this message translates to:
  /// **' will not be charged for this booking.'**
  String get cancellingIsFreeSuffix;

  /// No description provided for @keepBooking.
  ///
  /// In en, this message translates to:
  /// **'Keep booking'**
  String get keepBooking;

  /// No description provided for @rebookHint.
  ///
  /// In en, this message translates to:
  /// **'Pick the service again from the Services tab'**
  String get rebookHint;

  /// No description provided for @copiedBookingId.
  ///
  /// In en, this message translates to:
  /// **'Copied booking ID'**
  String get copiedBookingId;

  /// No description provided for @cancelledNothingCharged.
  ///
  /// In en, this message translates to:
  /// **'Cancelled — nothing was charged'**
  String get cancelledNothingCharged;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @bookingCancelledToast.
  ///
  /// In en, this message translates to:
  /// **'Booking cancelled'**
  String get bookingCancelledToast;

  /// No description provided for @timelineBooked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get timelineBooked;

  /// No description provided for @timelineBookedSub.
  ///
  /// In en, this message translates to:
  /// **'Order placed'**
  String get timelineBookedSub;

  /// No description provided for @timelineConfirmedSub.
  ///
  /// In en, this message translates to:
  /// **'Vendor accepted'**
  String get timelineConfirmedSub;

  /// No description provided for @timelineInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get timelineInProgress;

  /// No description provided for @timelineInProgressSub.
  ///
  /// In en, this message translates to:
  /// **'On the day'**
  String get timelineInProgressSub;

  /// No description provided for @timelineCompletedSub.
  ///
  /// In en, this message translates to:
  /// **'Service done'**
  String get timelineCompletedSub;

  /// No description provided for @timelineRefundIssued.
  ///
  /// In en, this message translates to:
  /// **'Refund issued to ELK Wallet'**
  String get timelineRefundIssued;

  /// No description provided for @bookingNotScheduled.
  ///
  /// In en, this message translates to:
  /// **'Not scheduled'**
  String get bookingNotScheduled;

  /// No description provided for @dateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateToday;

  /// No description provided for @dateTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get dateTomorrow;

  /// No description provided for @dateYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateYesterday;

  /// No description provided for @walletRewardPoints.
  ///
  /// In en, this message translates to:
  /// **'{points} Reward Points'**
  String walletRewardPoints(int points);

  /// No description provided for @vendorSpecialist.
  ///
  /// In en, this message translates to:
  /// **'{service} specialist'**
  String vendorSpecialist(String service);

  /// No description provided for @svcTaxiRides.
  ///
  /// In en, this message translates to:
  /// **'Taxi & Rides'**
  String get svcTaxiRides;

  /// No description provided for @svcCleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get svcCleaning;

  /// No description provided for @svcCarRental.
  ///
  /// In en, this message translates to:
  /// **'Car Rental'**
  String get svcCarRental;

  /// No description provided for @svcRepair.
  ///
  /// In en, this message translates to:
  /// **'Repair'**
  String get svcRepair;

  /// No description provided for @svcPorterMovers.
  ///
  /// In en, this message translates to:
  /// **'Porter & Movers'**
  String get svcPorterMovers;

  /// No description provided for @svcEconomyTaxi.
  ///
  /// In en, this message translates to:
  /// **'Economy Taxi'**
  String get svcEconomyTaxi;

  /// No description provided for @svcPremiumTaxi.
  ///
  /// In en, this message translates to:
  /// **'Premium Taxi'**
  String get svcPremiumTaxi;

  /// No description provided for @svcAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get svcAuto;

  /// No description provided for @svcXlVan.
  ///
  /// In en, this message translates to:
  /// **'XL Van'**
  String get svcXlVan;

  /// No description provided for @svcPgStay.
  ///
  /// In en, this message translates to:
  /// **'PG Stay'**
  String get svcPgStay;

  /// No description provided for @svcMensHostel.
  ///
  /// In en, this message translates to:
  /// **'Men\'s Hostel'**
  String get svcMensHostel;

  /// No description provided for @svcWomensHostel.
  ///
  /// In en, this message translates to:
  /// **'Women\'s Hostel'**
  String get svcWomensHostel;

  /// No description provided for @svcHomestay.
  ///
  /// In en, this message translates to:
  /// **'Homestay'**
  String get svcHomestay;

  /// No description provided for @svcHomeCleaning.
  ///
  /// In en, this message translates to:
  /// **'Home Cleaning'**
  String get svcHomeCleaning;

  /// No description provided for @svcDeepCleaning.
  ///
  /// In en, this message translates to:
  /// **'Deep Cleaning'**
  String get svcDeepCleaning;

  /// No description provided for @svcSofaUpholstery.
  ///
  /// In en, this message translates to:
  /// **'Sofa & Upholstery'**
  String get svcSofaUpholstery;

  /// No description provided for @svcKitchenCleaning.
  ///
  /// In en, this message translates to:
  /// **'Kitchen Cleaning'**
  String get svcKitchenCleaning;

  /// No description provided for @svcBathroomCleaning.
  ///
  /// In en, this message translates to:
  /// **'Bathroom Cleaning'**
  String get svcBathroomCleaning;

  /// No description provided for @svcCarpetRug.
  ///
  /// In en, this message translates to:
  /// **'Carpet & Rug'**
  String get svcCarpetRug;

  /// No description provided for @svcLaundryIron.
  ///
  /// In en, this message translates to:
  /// **'Laundry & Iron'**
  String get svcLaundryIron;

  /// No description provided for @svcWashFold.
  ///
  /// In en, this message translates to:
  /// **'Wash & Fold'**
  String get svcWashFold;

  /// No description provided for @svcWaterTank.
  ///
  /// In en, this message translates to:
  /// **'Water Tank'**
  String get svcWaterTank;

  /// No description provided for @svcSedan.
  ///
  /// In en, this message translates to:
  /// **'Sedan'**
  String get svcSedan;

  /// No description provided for @svcSuv.
  ///
  /// In en, this message translates to:
  /// **'SUV'**
  String get svcSuv;

  /// No description provided for @svcLuxury.
  ///
  /// In en, this message translates to:
  /// **'Luxury'**
  String get svcLuxury;

  /// No description provided for @svcVan.
  ///
  /// In en, this message translates to:
  /// **'Van'**
  String get svcVan;

  /// No description provided for @svcAcCooling.
  ///
  /// In en, this message translates to:
  /// **'AC & Cooling'**
  String get svcAcCooling;

  /// No description provided for @svcPlumbing.
  ///
  /// In en, this message translates to:
  /// **'Plumbing'**
  String get svcPlumbing;

  /// No description provided for @svcElectrical.
  ///
  /// In en, this message translates to:
  /// **'Electrical'**
  String get svcElectrical;

  /// No description provided for @svcCarpentry.
  ///
  /// In en, this message translates to:
  /// **'Carpentry'**
  String get svcCarpentry;

  /// No description provided for @svcPainting.
  ///
  /// In en, this message translates to:
  /// **'Painting'**
  String get svcPainting;

  /// No description provided for @svcHandyman.
  ///
  /// In en, this message translates to:
  /// **'Handyman'**
  String get svcHandyman;

  /// No description provided for @svcBikeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Bike Delivery'**
  String get svcBikeDelivery;

  /// No description provided for @svcMiniTruck.
  ///
  /// In en, this message translates to:
  /// **'Mini Truck'**
  String get svcMiniTruck;

  /// No description provided for @svcHouseShifting.
  ///
  /// In en, this message translates to:
  /// **'House Shifting'**
  String get svcHouseShifting;

  /// No description provided for @svcMoversPackers.
  ///
  /// In en, this message translates to:
  /// **'Movers & Packers'**
  String get svcMoversPackers;

  /// No description provided for @svcSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search services… (e.g. AC, taxi)'**
  String get svcSearchHint;

  /// No description provided for @rideBlurbAuto.
  ///
  /// In en, this message translates to:
  /// **'Budget auto-rickshaw rides'**
  String get rideBlurbAuto;

  /// No description provided for @rideBlurbEconomy.
  ///
  /// In en, this message translates to:
  /// **'Affordable everyday cars'**
  String get rideBlurbEconomy;

  /// No description provided for @rideBlurbPremium.
  ///
  /// In en, this message translates to:
  /// **'Top-rated premium cars'**
  String get rideBlurbPremium;

  /// No description provided for @rideBlurbXl.
  ///
  /// In en, this message translates to:
  /// **'For families, groups & big bags'**
  String get rideBlurbXl;

  /// No description provided for @rideBlurbAutoShort.
  ///
  /// In en, this message translates to:
  /// **'Budget rickshaw rides'**
  String get rideBlurbAutoShort;

  /// No description provided for @rideBlurbEconomyShort.
  ///
  /// In en, this message translates to:
  /// **'Affordable everyday rides'**
  String get rideBlurbEconomyShort;

  /// No description provided for @rideBlurbPremiumShort.
  ///
  /// In en, this message translates to:
  /// **'Extra legroom, top-rated drivers'**
  String get rideBlurbPremiumShort;

  /// No description provided for @taxiSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your mobile number to book a ride.'**
  String get taxiSignInPrompt;

  /// No description provided for @taxiBookARide.
  ///
  /// In en, this message translates to:
  /// **'Book a Ride'**
  String get taxiBookARide;

  /// No description provided for @taxiChooseRide.
  ///
  /// In en, this message translates to:
  /// **'Choose your ride'**
  String get taxiChooseRide;

  /// No description provided for @taxiPickup.
  ///
  /// In en, this message translates to:
  /// **'PICKUP'**
  String get taxiPickup;

  /// No description provided for @taxiDropoff.
  ///
  /// In en, this message translates to:
  /// **'DROP-OFF'**
  String get taxiDropoff;

  /// No description provided for @sortRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get sortRecommended;

  /// No description provided for @sortFaster.
  ///
  /// In en, this message translates to:
  /// **'Faster'**
  String get sortFaster;

  /// No description provided for @sortCheaper.
  ///
  /// In en, this message translates to:
  /// **'Cheaper'**
  String get sortCheaper;

  /// No description provided for @payCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get payCash;

  /// No description provided for @payCard.
  ///
  /// In en, this message translates to:
  /// **'Credit / Debit Card'**
  String get payCard;

  /// No description provided for @payElkWallet.
  ///
  /// In en, this message translates to:
  /// **'ELK Wallet'**
  String get payElkWallet;

  /// No description provided for @payApplePay.
  ///
  /// In en, this message translates to:
  /// **'Apple Pay'**
  String get payApplePay;

  /// No description provided for @payApplePayGooglePay.
  ///
  /// In en, this message translates to:
  /// **'Apple Pay / Google Pay'**
  String get payApplePayGooglePay;

  /// No description provided for @payCashSub.
  ///
  /// In en, this message translates to:
  /// **'Confirm to pay driver on arrival'**
  String get payCashSub;

  /// No description provided for @payCardSub.
  ///
  /// In en, this message translates to:
  /// **'Visa, Mastercard & more'**
  String get payCardSub;

  /// No description provided for @payWalletSub.
  ///
  /// In en, this message translates to:
  /// **'Pay from your ELK Wallet balance'**
  String get payWalletSub;

  /// No description provided for @payApplePaySub.
  ///
  /// In en, this message translates to:
  /// **'Fast & secure checkout'**
  String get payApplePaySub;

  /// No description provided for @changeAction.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeAction;

  /// No description provided for @bookPrefix.
  ///
  /// In en, this message translates to:
  /// **'Book '**
  String get bookPrefix;

  /// No description provided for @fare.
  ///
  /// In en, this message translates to:
  /// **'Fare'**
  String get fare;

  /// No description provided for @cancellationFee.
  ///
  /// In en, this message translates to:
  /// **'Cancellation'**
  String get cancellationFee;

  /// No description provided for @seats.
  ///
  /// In en, this message translates to:
  /// **'Seats'**
  String get seats;

  /// No description provided for @fareEstimateNote.
  ///
  /// In en, this message translates to:
  /// **'Total fare is an estimate based on distance and time. Surcharges, peak pricing, or toll fees may be added at checkout.'**
  String get fareEstimateNote;

  /// No description provided for @choosePickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose pickup location'**
  String get choosePickupLocation;

  /// No description provided for @chooseDropoffLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose drop-off location'**
  String get chooseDropoffLocation;

  /// No description provided for @fareBase.
  ///
  /// In en, this message translates to:
  /// **'Base fare'**
  String get fareBase;

  /// No description provided for @fareBookingFee.
  ///
  /// In en, this message translates to:
  /// **'Booking fee'**
  String get fareBookingFee;

  /// No description provided for @assigningDriver.
  ///
  /// In en, this message translates to:
  /// **'Assigning driver…'**
  String get assigningDriver;

  /// No description provided for @detailsOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'Details on the way'**
  String get detailsOnTheWay;

  /// No description provided for @couldNotBookRide.
  ///
  /// In en, this message translates to:
  /// **'Could not book the ride.'**
  String get couldNotBookRide;

  /// No description provided for @findingDriver.
  ///
  /// In en, this message translates to:
  /// **'Finding Driver'**
  String get findingDriver;

  /// No description provided for @lookingForDrivers.
  ///
  /// In en, this message translates to:
  /// **'Looking for nearby drivers'**
  String get lookingForDrivers;

  /// No description provided for @driverAssigned.
  ///
  /// In en, this message translates to:
  /// **'Driver Assigned'**
  String get driverAssigned;

  /// No description provided for @completePaymentNote.
  ///
  /// In en, this message translates to:
  /// **'Complete payment to confirm your booking. Your trip OTP will be issued right after.'**
  String get completePaymentNote;

  /// No description provided for @proceedToPayment.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Payment'**
  String get proceedToPayment;

  /// No description provided for @amountDue.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT DUE'**
  String get amountDue;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select payment method'**
  String get selectPaymentMethod;

  /// No description provided for @paymentsSecured.
  ///
  /// In en, this message translates to:
  /// **'Payments secured with 256-bit encryption'**
  String get paymentsSecured;

  /// No description provided for @cardYourName.
  ///
  /// In en, this message translates to:
  /// **'YOUR NAME'**
  String get cardYourName;

  /// No description provided for @cardDetails.
  ///
  /// In en, this message translates to:
  /// **'Card Details'**
  String get cardDetails;

  /// No description provided for @cardHolder.
  ///
  /// In en, this message translates to:
  /// **'CARD HOLDER'**
  String get cardHolder;

  /// No description provided for @cardExpires.
  ///
  /// In en, this message translates to:
  /// **'EXPIRES'**
  String get cardExpires;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @cardExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get cardExpiry;

  /// No description provided for @cardCvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cardCvv;

  /// No description provided for @cardholderName.
  ///
  /// In en, this message translates to:
  /// **'Cardholder Name'**
  String get cardholderName;

  /// No description provided for @cardAsShown.
  ///
  /// In en, this message translates to:
  /// **'As shown on card'**
  String get cardAsShown;

  /// No description provided for @saveCardForFuture.
  ///
  /// In en, this message translates to:
  /// **'Save card for future payments'**
  String get saveCardForFuture;

  /// No description provided for @otpBeingPrepared.
  ///
  /// In en, this message translates to:
  /// **'Your OTP is being prepared'**
  String get otpBeingPrepared;

  /// No description provided for @driverOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'Driver On The Way'**
  String get driverOnTheWay;

  /// No description provided for @shareOtpToStart.
  ///
  /// In en, this message translates to:
  /// **'Share this OTP to start your trip'**
  String get shareOtpToStart;

  /// No description provided for @safety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get safety;

  /// No description provided for @shareTrip.
  ///
  /// In en, this message translates to:
  /// **'Share Trip'**
  String get shareTrip;

  /// No description provided for @driverArrivedStartTrip.
  ///
  /// In en, this message translates to:
  /// **'Driver Arrived · Start Trip'**
  String get driverArrivedStartTrip;

  /// No description provided for @couldNotStartTrip.
  ///
  /// In en, this message translates to:
  /// **'Could not start the trip.'**
  String get couldNotStartTrip;

  /// No description provided for @tripInProgress.
  ///
  /// In en, this message translates to:
  /// **'Trip in Progress'**
  String get tripInProgress;

  /// No description provided for @headingTo.
  ///
  /// In en, this message translates to:
  /// **'HEADING TO'**
  String get headingTo;

  /// No description provided for @completeTrip.
  ///
  /// In en, this message translates to:
  /// **'Complete Trip'**
  String get completeTrip;

  /// No description provided for @couldNotCompleteTrip.
  ///
  /// In en, this message translates to:
  /// **'Could not complete the trip.'**
  String get couldNotCompleteTrip;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @farePaid.
  ///
  /// In en, this message translates to:
  /// **'Fare · Paid'**
  String get farePaid;

  /// No description provided for @addATip.
  ///
  /// In en, this message translates to:
  /// **'Add a tip'**
  String get addATip;

  /// No description provided for @noTip.
  ///
  /// In en, this message translates to:
  /// **'No tip'**
  String get noTip;

  /// No description provided for @finishTrip.
  ///
  /// In en, this message translates to:
  /// **'Finish Trip'**
  String get finishTrip;

  /// No description provided for @couldNotSubmitRating.
  ///
  /// In en, this message translates to:
  /// **'Could not submit your rating.'**
  String get couldNotSubmitRating;

  /// No description provided for @allDoneThanks.
  ///
  /// In en, this message translates to:
  /// **'All Done — Thanks for Riding!'**
  String get allDoneThanks;

  /// No description provided for @trip.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get trip;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// No description provided for @tip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get tip;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// No description provided for @receiptDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Receipt downloaded'**
  String get receiptDownloaded;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @bookAnotherTrip.
  ///
  /// In en, this message translates to:
  /// **'Book Another Trip'**
  String get bookAnotherTrip;

  /// No description provided for @svcNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No services match \"{query}\".\nTry \"AC\", \"taxi\" or \"clean\".'**
  String svcNoMatch(String query);

  /// No description provided for @rideSeats.
  ///
  /// In en, this message translates to:
  /// **'{seats} seats'**
  String rideSeats(int seats);

  /// No description provided for @fareDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance ({km} km)'**
  String fareDistance(String km);

  /// No description provided for @fareTime.
  ///
  /// In en, this message translates to:
  /// **'Time ({minutes} min)'**
  String fareTime(int minutes);

  /// No description provided for @tipWillBeCharged.
  ///
  /// In en, this message translates to:
  /// **'{amount} will be charged to your {method}'**
  String tipWillBeCharged(String amount, String method);

  /// No description provided for @totalVia.
  ///
  /// In en, this message translates to:
  /// **'Total via {method}'**
  String totalVia(String method);

  /// No description provided for @addServiceAddress.
  ///
  /// In en, this message translates to:
  /// **'Add service address'**
  String get addServiceAddress;

  /// No description provided for @cleanSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your mobile number to book cleaning services.'**
  String get cleanSignInPrompt;

  /// No description provided for @topOffers.
  ///
  /// In en, this message translates to:
  /// **'Top offers'**
  String get topOffers;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @cleanSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search \"deep clean\", \"tank\"…'**
  String get cleanSearchHint;

  /// No description provided for @playUnlockDeals.
  ///
  /// In en, this message translates to:
  /// **'Play & Unlock Summer Deals!'**
  String get playUnlockDeals;

  /// No description provided for @getWaterTankCleaning.
  ///
  /// In en, this message translates to:
  /// **'Get Water Tank Cleaning '**
  String get getWaterTankCleaning;

  /// No description provided for @whatNeedsCleaning.
  ///
  /// In en, this message translates to:
  /// **'What needs cleaning?'**
  String get whatNeedsCleaning;

  /// No description provided for @codeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code: '**
  String get codeLabel;

  /// No description provided for @ecoFriendlyProducts.
  ///
  /// In en, this message translates to:
  /// **'Eco-friendly, child-safe products'**
  String get ecoFriendlyProducts;

  /// No description provided for @trainedCleaners.
  ///
  /// In en, this message translates to:
  /// **'Trained & uniformed cleaners'**
  String get trainedCleaners;

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromLabel;

  /// No description provided for @howWeDoIt.
  ///
  /// In en, this message translates to:
  /// **'HOW WE DO IT'**
  String get howWeDoIt;

  /// No description provided for @hygieneAfterService.
  ///
  /// In en, this message translates to:
  /// **'Hygiene level after service'**
  String get hygieneAfterService;

  /// No description provided for @beforeLabel.
  ///
  /// In en, this message translates to:
  /// **'before'**
  String get beforeLabel;

  /// No description provided for @afterLabTested.
  ///
  /// In en, this message translates to:
  /// **'after · lab-tested'**
  String get afterLabTested;

  /// No description provided for @elkCleanCrew.
  ///
  /// In en, this message translates to:
  /// **'ELKclean crew'**
  String get elkCleanCrew;

  /// No description provided for @crewBlurb.
  ///
  /// In en, this message translates to:
  /// **'Uniformed · eco kit · 4.9 from 1,200+ cleans'**
  String get crewBlurb;

  /// No description provided for @priceCaps.
  ///
  /// In en, this message translates to:
  /// **'PRICE'**
  String get priceCaps;

  /// No description provided for @yourCleanPlan.
  ///
  /// In en, this message translates to:
  /// **'Your clean plan'**
  String get yourCleanPlan;

  /// No description provided for @addPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Add promo code'**
  String get addPromoCode;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @ecoSuppliesSetup.
  ///
  /// In en, this message translates to:
  /// **'Eco supplies & setup'**
  String get ecoSuppliesSetup;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'SELECT DATE'**
  String get selectDate;

  /// No description provided for @arrivalWindow.
  ///
  /// In en, this message translates to:
  /// **'ARRIVAL WINDOW'**
  String get arrivalWindow;

  /// No description provided for @fillsFast.
  ///
  /// In en, this message translates to:
  /// **'Fills fast'**
  String get fillsFast;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @crewArrivalNote.
  ///
  /// In en, this message translates to:
  /// **'Your crew arrives within a 2-hour window with all supplies. Live tracking link sent on the day.'**
  String get crewArrivalNote;

  /// No description provided for @serviceAddress.
  ///
  /// In en, this message translates to:
  /// **'Service address'**
  String get serviceAddress;

  /// No description provided for @savedPlaces.
  ///
  /// In en, this message translates to:
  /// **'SAVED PLACES'**
  String get savedPlaces;

  /// No description provided for @noSavedAddresses.
  ///
  /// In en, this message translates to:
  /// **'No saved addresses yet — add one below.'**
  String get noSavedAddresses;

  /// No description provided for @addNewAddress.
  ///
  /// In en, this message translates to:
  /// **'Add new address'**
  String get addNewAddress;

  /// No description provided for @addServiceAddressFirst.
  ///
  /// In en, this message translates to:
  /// **'Please add a service address first.'**
  String get addServiceAddressFirst;

  /// No description provided for @reviewConfirm.
  ///
  /// In en, this message translates to:
  /// **'Review & confirm'**
  String get reviewConfirm;

  /// No description provided for @whenLabel.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get whenLabel;

  /// No description provided for @whereLabel.
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get whereLabel;

  /// No description provided for @contactLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactLabel;

  /// No description provided for @verifiedAccount.
  ///
  /// In en, this message translates to:
  /// **'Verified account'**
  String get verifiedAccount;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order summary'**
  String get orderSummary;

  /// No description provided for @totalToPay.
  ///
  /// In en, this message translates to:
  /// **'Total to pay'**
  String get totalToPay;

  /// No description provided for @recleanGuarantee.
  ///
  /// In en, this message translates to:
  /// **'Not happy? We re-clean free within 48 hours. Free cancellation up to 2h before.'**
  String get recleanGuarantee;

  /// No description provided for @payCardBrands.
  ///
  /// In en, this message translates to:
  /// **'Visa, Mastercard, Amex'**
  String get payCardBrands;

  /// No description provided for @payOneTapCheckout.
  ///
  /// In en, this message translates to:
  /// **'One-tap secure checkout'**
  String get payOneTapCheckout;

  /// No description provided for @chooseMethod.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE METHOD'**
  String get chooseMethod;

  /// No description provided for @nameOnCard.
  ///
  /// In en, this message translates to:
  /// **'NAME ON CARD'**
  String get nameOnCard;

  /// No description provided for @saveCardFasterCheckout.
  ///
  /// In en, this message translates to:
  /// **'Save card for faster checkout'**
  String get saveCardFasterCheckout;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing…'**
  String get processing;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed. Please try again.'**
  String get paymentFailed;

  /// No description provided for @paidLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidLabel;

  /// No description provided for @paidCaps.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get paidCaps;

  /// No description provided for @trackMyClean.
  ///
  /// In en, this message translates to:
  /// **'Track my clean'**
  String get trackMyClean;

  /// No description provided for @noServicesYet.
  ///
  /// In en, this message translates to:
  /// **'No services yet'**
  String get noServicesYet;

  /// No description provided for @browseCleaningBlurb.
  ///
  /// In en, this message translates to:
  /// **'Browse cleaning services and build your plan.'**
  String get browseCleaningBlurb;

  /// No description provided for @browseServices.
  ///
  /// In en, this message translates to:
  /// **'Browse services'**
  String get browseServices;

  /// No description provided for @paySecurely.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount} securely'**
  String paySecurely(String amount);

  /// No description provided for @servicesAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} services added'**
  String servicesAdded(int count);

  /// No description provided for @repairSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your mobile number to book a repair.'**
  String get repairSignInPrompt;

  /// No description provided for @repairSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search \"AC service\", \"leak\"…'**
  String get repairSearchHint;

  /// No description provided for @summerReady.
  ///
  /// In en, this message translates to:
  /// **'SUMMER READY'**
  String get summerReady;

  /// No description provided for @whatNeedsFixing.
  ///
  /// In en, this message translates to:
  /// **'What needs fixing?'**
  String get whatNeedsFixing;

  /// No description provided for @whatsIncluded.
  ///
  /// In en, this message translates to:
  /// **'What\'s included'**
  String get whatsIncluded;

  /// No description provided for @topRatedCrew.
  ///
  /// In en, this message translates to:
  /// **'Top-rated crew'**
  String get topRatedCrew;

  /// No description provided for @techCrewBlurb.
  ///
  /// In en, this message translates to:
  /// **'Assigned after booking · avg 4.9 from 800+ jobs'**
  String get techCrewBlurb;

  /// No description provided for @yourWorkOrder.
  ///
  /// In en, this message translates to:
  /// **'Your work order'**
  String get yourWorkOrder;

  /// No description provided for @visitInspectionFee.
  ///
  /// In en, this message translates to:
  /// **'Visit & inspection fee'**
  String get visitInspectionFee;

  /// No description provided for @techArrivalNote.
  ///
  /// In en, this message translates to:
  /// **'Your technician arrives within a 2-hour window. You\'ll get a live tracking link on the day.'**
  String get techArrivalNote;

  /// No description provided for @chargedAfterComplete.
  ///
  /// In en, this message translates to:
  /// **'You\'re only charged after the job is confirmed complete. Free cancellation up to 2h before.'**
  String get chargedAfterComplete;

  /// No description provided for @trackMyBooking.
  ///
  /// In en, this message translates to:
  /// **'Track my booking'**
  String get trackMyBooking;

  /// No description provided for @browseTradesBlurb.
  ///
  /// In en, this message translates to:
  /// **'Browse trades and add what needs fixing.'**
  String get browseTradesBlurb;

  /// No description provided for @rentalSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your mobile number to rent a car.'**
  String get rentalSignInPrompt;

  /// No description provided for @carsAvailable.
  ///
  /// In en, this message translates to:
  /// **'cars available'**
  String get carsAvailable;

  /// No description provided for @sortPrice.
  ///
  /// In en, this message translates to:
  /// **'Sort: Price'**
  String get sortPrice;

  /// No description provided for @noCarsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No cars in this category right now.'**
  String get noCarsInCategory;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// No description provided for @porterSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your mobile number to send a package.'**
  String get porterSignInPrompt;

  /// No description provided for @selectVehicle.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle'**
  String get selectVehicle;

  /// No description provided for @pricingUpdates.
  ///
  /// In en, this message translates to:
  /// **'Pricing updates with your choice'**
  String get pricingUpdates;

  /// No description provided for @addOns.
  ///
  /// In en, this message translates to:
  /// **'Add-ons'**
  String get addOns;

  /// No description provided for @porterLogistics.
  ///
  /// In en, this message translates to:
  /// **'Porter & Logistics'**
  String get porterLogistics;

  /// No description provided for @pickupLocation.
  ///
  /// In en, this message translates to:
  /// **'PICKUP LOCATION'**
  String get pickupLocation;

  /// No description provided for @dropLocation.
  ///
  /// In en, this message translates to:
  /// **'DROP LOCATION'**
  String get dropLocation;

  /// No description provided for @packageType.
  ///
  /// In en, this message translates to:
  /// **'Package Type'**
  String get packageType;

  /// No description provided for @packageElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get packageElectronics;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @estimatedTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated Time'**
  String get estimatedTime;

  /// No description provided for @estimatedFare.
  ///
  /// In en, this message translates to:
  /// **'Estimated Fare'**
  String get estimatedFare;

  /// No description provided for @bookPorter.
  ///
  /// In en, this message translates to:
  /// **'Book Porter'**
  String get bookPorter;

  /// No description provided for @couldNotBookDelivery.
  ///
  /// In en, this message translates to:
  /// **'Could not book the delivery.'**
  String get couldNotBookDelivery;

  /// No description provided for @stepSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get stepSchedule;

  /// No description provided for @pickUpNow.
  ///
  /// In en, this message translates to:
  /// **'Pick up now'**
  String get pickUpNow;

  /// No description provided for @scheduleForLater.
  ///
  /// In en, this message translates to:
  /// **'Schedule for later'**
  String get scheduleForLater;

  /// No description provided for @pickupDate.
  ///
  /// In en, this message translates to:
  /// **'Pickup date'**
  String get pickupDate;

  /// No description provided for @selectDateAction.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDateAction;

  /// No description provided for @pickupWindow.
  ///
  /// In en, this message translates to:
  /// **'Pickup window'**
  String get pickupWindow;

  /// No description provided for @estTime.
  ///
  /// In en, this message translates to:
  /// **'Est. time'**
  String get estTime;

  /// No description provided for @continueToPayment.
  ///
  /// In en, this message translates to:
  /// **'Continue to payment'**
  String get continueToPayment;

  /// No description provided for @payCardBrandsShort.
  ///
  /// In en, this message translates to:
  /// **'Visa, Mastercard'**
  String get payCardBrandsShort;

  /// No description provided for @payCashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery'**
  String get payCashOnDelivery;

  /// No description provided for @deliveryFare.
  ///
  /// In en, this message translates to:
  /// **'Delivery fare'**
  String get deliveryFare;

  /// No description provided for @serviceFee.
  ///
  /// In en, this message translates to:
  /// **'Service fee'**
  String get serviceFee;

  /// No description provided for @gstFivePercent.
  ///
  /// In en, this message translates to:
  /// **'GST (5%)'**
  String get gstFivePercent;

  /// No description provided for @continueToCardDetails.
  ///
  /// In en, this message translates to:
  /// **'Continue to card details'**
  String get continueToCardDetails;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @confirmAndPay.
  ///
  /// In en, this message translates to:
  /// **'Confirm and pay'**
  String get confirmAndPay;

  /// No description provided for @completeCardDetails.
  ///
  /// In en, this message translates to:
  /// **'Please complete all card details'**
  String get completeCardDetails;

  /// No description provided for @paymentsSecuredByElk.
  ///
  /// In en, this message translates to:
  /// **'Payments secured by ELK gateway'**
  String get paymentsSecuredByElk;

  /// No description provided for @processingPayment.
  ///
  /// In en, this message translates to:
  /// **'Processing payment'**
  String get processingPayment;

  /// No description provided for @confirmingWithBank.
  ///
  /// In en, this message translates to:
  /// **'Confirming with your bank, do not close this screen'**
  String get confirmingWithBank;

  /// No description provided for @bookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed'**
  String get bookingConfirmed;

  /// No description provided for @porterNotified.
  ///
  /// In en, this message translates to:
  /// **'Your porter has been notified'**
  String get porterNotified;

  /// No description provided for @trackingId.
  ///
  /// In en, this message translates to:
  /// **'Tracking ID'**
  String get trackingId;

  /// No description provided for @vehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicle;

  /// No description provided for @arrival.
  ///
  /// In en, this message translates to:
  /// **'Arrival'**
  String get arrival;

  /// No description provided for @amountPaid.
  ///
  /// In en, this message translates to:
  /// **'Amount paid'**
  String get amountPaid;

  /// No description provided for @receiptSentToEmail.
  ///
  /// In en, this message translates to:
  /// **'Receipt sent to your email'**
  String get receiptSentToEmail;

  /// No description provided for @viewReceipt.
  ///
  /// In en, this message translates to:
  /// **'View receipt →'**
  String get viewReceipt;

  /// No description provided for @stepTripDetails.
  ///
  /// In en, this message translates to:
  /// **'Trip Details'**
  String get stepTripDetails;

  /// No description provided for @stepPickupDelivery.
  ///
  /// In en, this message translates to:
  /// **'Pickup & Delivery'**
  String get stepPickupDelivery;

  /// No description provided for @stepExtrasProtection.
  ///
  /// In en, this message translates to:
  /// **'Extras & Protection'**
  String get stepExtrasProtection;

  /// No description provided for @stepLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get stepLocation;

  /// No description provided for @stepExtras.
  ///
  /// In en, this message translates to:
  /// **'Extras'**
  String get stepExtras;

  /// No description provided for @stepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get stepReview;

  /// No description provided for @stepPay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get stepPay;

  /// No description provided for @yourAccount.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get yourAccount;

  /// No description provided for @branch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get branch;

  /// No description provided for @securedByElkPay.
  ///
  /// In en, this message translates to:
  /// **'Secured by ELK Pay · 256-bit encryption'**
  String get securedByElkPay;

  /// No description provided for @totalSoFar.
  ///
  /// In en, this message translates to:
  /// **'Total so far'**
  String get totalSoFar;

  /// No description provided for @whenDoYouNeedIt.
  ///
  /// In en, this message translates to:
  /// **'When do you need it?'**
  String get whenDoYouNeedIt;

  /// No description provided for @pickPlanAndDates.
  ///
  /// In en, this message translates to:
  /// **'Pick your rental plan and travel dates'**
  String get pickPlanAndDates;

  /// No description provided for @rateDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get rateDaily;

  /// No description provided for @rateWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly · 15% off'**
  String get rateWeekly;

  /// No description provided for @rateMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly · 30% off'**
  String get rateMonthly;

  /// No description provided for @pickupDateTime.
  ///
  /// In en, this message translates to:
  /// **'Pick-up date & time'**
  String get pickupDateTime;

  /// No description provided for @whenRentalBegins.
  ///
  /// In en, this message translates to:
  /// **'When your rental begins'**
  String get whenRentalBegins;

  /// No description provided for @returnDateTime.
  ///
  /// In en, this message translates to:
  /// **'Return date & time'**
  String get returnDateTime;

  /// No description provided for @whenRentalEnds.
  ///
  /// In en, this message translates to:
  /// **'When your rental ends'**
  String get whenRentalEnds;

  /// No description provided for @rentalLength.
  ///
  /// In en, this message translates to:
  /// **'Rental length'**
  String get rentalLength;

  /// No description provided for @rentalBillingNote.
  ///
  /// In en, this message translates to:
  /// **'Rentals are billed in full days. Return the car late by more than 59 minutes and an extra day applies.'**
  String get rentalBillingNote;

  /// No description provided for @howGetYourCar.
  ///
  /// In en, this message translates to:
  /// **'How would you like to get your car?'**
  String get howGetYourCar;

  /// No description provided for @collectOrDelivered.
  ///
  /// In en, this message translates to:
  /// **'Collect it yourself or have it delivered to you'**
  String get collectOrDelivered;

  /// No description provided for @selfPickup.
  ///
  /// In en, this message translates to:
  /// **'Self Pickup'**
  String get selfPickup;

  /// No description provided for @collectFromBranch.
  ///
  /// In en, this message translates to:
  /// **'Collect from an ELK branch'**
  String get collectFromBranch;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @carDelivery.
  ///
  /// In en, this message translates to:
  /// **'Car Delivery'**
  String get carDelivery;

  /// No description provided for @weBringIt.
  ///
  /// In en, this message translates to:
  /// **'We bring it to your address'**
  String get weBringIt;

  /// No description provided for @chooseBranch.
  ///
  /// In en, this message translates to:
  /// **'Choose a branch'**
  String get chooseBranch;

  /// No description provided for @mapPreviewHint.
  ///
  /// In en, this message translates to:
  /// **'Map preview · tap to open directions'**
  String get mapPreviewHint;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get deliveryAddress;

  /// No description provided for @deliveryAddressHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Koramangala, Bengaluru'**
  String get deliveryAddressHint;

  /// No description provided for @buildingVillaNo.
  ///
  /// In en, this message translates to:
  /// **'Building / Villa No.'**
  String get buildingVillaNo;

  /// No description provided for @driverDirections.
  ///
  /// In en, this message translates to:
  /// **'Directions for driver (optional)'**
  String get driverDirections;

  /// No description provided for @driverDirectionsHint.
  ///
  /// In en, this message translates to:
  /// **'Gate code, landmark, parking notes…'**
  String get driverDirectionsHint;

  /// No description provided for @locationCaptured.
  ///
  /// In en, this message translates to:
  /// **'Location captured'**
  String get locationCaptured;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get useCurrentLocation;

  /// No description provided for @deliveryFeeNote.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee ₹25 · car arrives within 2 hours of your pick-up time.'**
  String get deliveryFeeNote;

  /// No description provided for @enhanceYourTrip.
  ///
  /// In en, this message translates to:
  /// **'Enhance your trip'**
  String get enhanceYourTrip;

  /// No description provided for @optionalAddOns.
  ///
  /// In en, this message translates to:
  /// **'Optional add-ons — pick any that suit your journey'**
  String get optionalAddOns;

  /// No description provided for @reviewYourBooking.
  ///
  /// In en, this message translates to:
  /// **'Review your booking'**
  String get reviewYourBooking;

  /// No description provided for @doubleCheckBeforePay.
  ///
  /// In en, this message translates to:
  /// **'Double-check everything before you pay'**
  String get doubleCheckBeforePay;

  /// No description provided for @bookingAsYourself.
  ///
  /// In en, this message translates to:
  /// **'Booking as yourself'**
  String get bookingAsYourself;

  /// No description provided for @tripDates.
  ///
  /// In en, this message translates to:
  /// **'Trip dates'**
  String get tripDates;

  /// No description provided for @priceBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Price breakdown'**
  String get priceBreakdown;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get deliveryFee;

  /// No description provided for @promoCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Promo code — try ELK10'**
  String get promoCodeHint;

  /// No description provided for @totalInclGst.
  ///
  /// In en, this message translates to:
  /// **'Total (incl. 5% GST)'**
  String get totalInclGst;

  /// No description provided for @iAgreeToThe.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get iAgreeToThe;

  /// No description provided for @rentalTerms.
  ///
  /// In en, this message translates to:
  /// **'Rental Terms & Conditions'**
  String get rentalTerms;

  /// No description provided for @enterPromoFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter a promo code first'**
  String get enterPromoFirst;

  /// No description provided for @promoNotValid.
  ///
  /// In en, this message translates to:
  /// **'That code isn\'t valid'**
  String get promoNotValid;

  /// No description provided for @cashOnPickup.
  ///
  /// In en, this message translates to:
  /// **'Cash on Pickup'**
  String get cashOnPickup;

  /// No description provided for @chooseHowToPay.
  ///
  /// In en, this message translates to:
  /// **'Choose how you\'d like to pay'**
  String get chooseHowToPay;

  /// No description provided for @cardLabel.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get cardLabel;

  /// No description provided for @saveCardNextTime.
  ///
  /// In en, this message translates to:
  /// **'Save this card for faster checkout next time'**
  String get saveCardNextTime;

  /// No description provided for @payWithDigitalWallet.
  ///
  /// In en, this message translates to:
  /// **'Pay with your digital wallet'**
  String get payWithDigitalWallet;

  /// No description provided for @walletRedirectNote.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be redirected to complete this payment securely, then returned to ELK Business Hub.'**
  String get walletRedirectNote;

  /// No description provided for @cashAtBranchNote.
  ///
  /// In en, this message translates to:
  /// **'Pay the full amount in cash when you collect the car at the branch counter.'**
  String get cashAtBranchNote;

  /// No description provided for @cashToDriverNote.
  ///
  /// In en, this message translates to:
  /// **'Pay the full amount in cash to our driver when the car is delivered.'**
  String get cashToDriverNote;

  /// No description provided for @processingYourPayment.
  ///
  /// In en, this message translates to:
  /// **'Processing your payment…'**
  String get processingYourPayment;

  /// No description provided for @dontCloseScreen.
  ///
  /// In en, this message translates to:
  /// **'Please don\'t close this screen'**
  String get dontCloseScreen;

  /// No description provided for @bookingConfirmedBang.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed!'**
  String get bookingConfirmedBang;

  /// No description provided for @deliveredToAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivered to your address'**
  String get deliveredToAddress;

  /// No description provided for @showThisAtPickup.
  ///
  /// In en, this message translates to:
  /// **'Show this at pickup'**
  String get showThisAtPickup;

  /// No description provided for @viewEReceipt.
  ///
  /// In en, this message translates to:
  /// **'View E-Receipt'**
  String get viewEReceipt;

  /// No description provided for @payAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String payAmount(String amount);

  /// No description provided for @confirmAndPayAmount.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Pay {amount}'**
  String confirmAndPayAmount(String amount);

  /// No description provided for @branchSelfPickup.
  ///
  /// In en, this message translates to:
  /// **'{branch} (Self Pickup)'**
  String branchSelfPickup(String branch);

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String daysCount(int days);

  /// No description provided for @payUpiSub.
  ///
  /// In en, this message translates to:
  /// **'GPay, PhonePe, Paytm & more'**
  String get payUpiSub;

  /// No description provided for @payCardBrandsIn.
  ///
  /// In en, this message translates to:
  /// **'Visa, Mastercard, Rupay'**
  String get payCardBrandsIn;

  /// No description provided for @payNetBanking.
  ///
  /// In en, this message translates to:
  /// **'Net Banking'**
  String get payNetBanking;

  /// No description provided for @payAllMajorBanks.
  ///
  /// In en, this message translates to:
  /// **'All major banks'**
  String get payAllMajorBanks;

  /// No description provided for @couldNotScheduleVisit.
  ///
  /// In en, this message translates to:
  /// **'Could not schedule the visit.'**
  String get couldNotScheduleVisit;

  /// No description provided for @allStays.
  ///
  /// In en, this message translates to:
  /// **'All stays'**
  String get allStays;

  /// No description provided for @chipAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get chipAll;

  /// No description provided for @chipSingle.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get chipSingle;

  /// No description provided for @chipDouble.
  ///
  /// In en, this message translates to:
  /// **'Double'**
  String get chipDouble;

  /// No description provided for @chipFoodIncl.
  ///
  /// In en, this message translates to:
  /// **'Food incl.'**
  String get chipFoodIncl;

  /// No description provided for @chipNearMetro.
  ///
  /// In en, this message translates to:
  /// **'Near metro'**
  String get chipNearMetro;

  /// No description provided for @staysInArea.
  ///
  /// In en, this message translates to:
  /// **'stays in Koramangala'**
  String get staysInArea;

  /// No description provided for @sortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort '**
  String get sortLabel;

  /// No description provided for @staySignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your mobile number to view this stay.'**
  String get staySignInPrompt;

  /// No description provided for @stayBrowseSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your mobile number to browse stays.'**
  String get stayBrowseSignInPrompt;

  /// No description provided for @foodIncluded.
  ///
  /// In en, this message translates to:
  /// **'Food included'**
  String get foodIncluded;

  /// No description provided for @chooseSharing.
  ///
  /// In en, this message translates to:
  /// **'Choose sharing'**
  String get chooseSharing;

  /// No description provided for @amenities.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get amenities;

  /// No description provided for @ratingsReviews.
  ///
  /// In en, this message translates to:
  /// **'Ratings & reviews'**
  String get ratingsReviews;

  /// No description provided for @sampleStayReview.
  ///
  /// In en, this message translates to:
  /// **'\"Clean rooms, great food and very safe. The warden is helpful and the location is perfect for commuting.\" — Priya S.'**
  String get sampleStayReview;

  /// No description provided for @startingFrom.
  ///
  /// In en, this message translates to:
  /// **'Starting from'**
  String get startingFrom;

  /// No description provided for @visit.
  ///
  /// In en, this message translates to:
  /// **'Visit'**
  String get visit;

  /// No description provided for @reserve.
  ///
  /// In en, this message translates to:
  /// **'Reserve'**
  String get reserve;

  /// No description provided for @bookYourStay.
  ///
  /// In en, this message translates to:
  /// **'Book your stay'**
  String get bookYourStay;

  /// No description provided for @roomType.
  ///
  /// In en, this message translates to:
  /// **'Room type'**
  String get roomType;

  /// No description provided for @moveInDate.
  ///
  /// In en, this message translates to:
  /// **'MOVE-IN DATE'**
  String get moveInDate;

  /// No description provided for @durationCaps.
  ///
  /// In en, this message translates to:
  /// **'DURATION'**
  String get durationCaps;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'FULL NAME'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'PHONE NUMBER'**
  String get phoneNumber;

  /// No description provided for @reviewAndPay.
  ///
  /// In en, this message translates to:
  /// **'Review & pay'**
  String get reviewAndPay;

  /// No description provided for @paymentSummary.
  ///
  /// In en, this message translates to:
  /// **'Payment summary'**
  String get paymentSummary;

  /// No description provided for @firstMonthRent.
  ///
  /// In en, this message translates to:
  /// **'First month rent'**
  String get firstMonthRent;

  /// No description provided for @securityDeposit.
  ///
  /// In en, this message translates to:
  /// **'Security deposit'**
  String get securityDeposit;

  /// No description provided for @refundableAtMoveOut.
  ///
  /// In en, this message translates to:
  /// **'Refundable at move-out'**
  String get refundableAtMoveOut;

  /// No description provided for @elkServiceFee.
  ///
  /// In en, this message translates to:
  /// **'ELK service fee'**
  String get elkServiceFee;

  /// No description provided for @couponElknew.
  ///
  /// In en, this message translates to:
  /// **'Coupon ELKNEW'**
  String get couponElknew;

  /// No description provided for @payableNow.
  ///
  /// In en, this message translates to:
  /// **'Payable now'**
  String get payableNow;

  /// No description provided for @applyPrefix.
  ///
  /// In en, this message translates to:
  /// **'Apply '**
  String get applyPrefix;

  /// No description provided for @saveFiveHundred.
  ///
  /// In en, this message translates to:
  /// **' — save ₹500'**
  String get saveFiveHundred;

  /// No description provided for @appliedCaps.
  ///
  /// In en, this message translates to:
  /// **'APPLIED'**
  String get appliedCaps;

  /// No description provided for @applyCaps.
  ///
  /// In en, this message translates to:
  /// **'APPLY'**
  String get applyCaps;

  /// No description provided for @stayPolicyNote.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to ELK\'s stay policy and cancellation terms. Deposit is fully refundable subject to inspection.'**
  String get stayPolicyNote;

  /// No description provided for @proceedToPay.
  ///
  /// In en, this message translates to:
  /// **'Proceed to pay'**
  String get proceedToPay;

  /// No description provided for @amountPayable.
  ///
  /// In en, this message translates to:
  /// **'Amount payable'**
  String get amountPayable;

  /// No description provided for @payUsing.
  ///
  /// In en, this message translates to:
  /// **'Pay using'**
  String get payUsing;

  /// No description provided for @upiId.
  ///
  /// In en, this message translates to:
  /// **'UPI ID'**
  String get upiId;

  /// No description provided for @property.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get property;

  /// No description provided for @room.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get room;

  /// No description provided for @moveIn.
  ///
  /// In en, this message translates to:
  /// **'Move-in'**
  String get moveIn;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHome;

  /// No description provided for @pgStays.
  ///
  /// In en, this message translates to:
  /// **'PG Stays'**
  String get pgStays;

  /// No description provided for @homestays.
  ///
  /// In en, this message translates to:
  /// **'Homestays'**
  String get homestays;

  /// No description provided for @statusVisitBooked.
  ///
  /// In en, this message translates to:
  /// **'Visit booked'**
  String get statusVisitBooked;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @chooseRoomFirst.
  ///
  /// In en, this message translates to:
  /// **'Please choose a room option first.'**
  String get chooseRoomFirst;

  /// No description provided for @whatAreYouLookingFor.
  ///
  /// In en, this message translates to:
  /// **'What are you looking for?'**
  String get whatAreYouLookingFor;

  /// No description provided for @topRatedNearYou.
  ///
  /// In en, this message translates to:
  /// **'Top rated near you'**
  String get topRatedNearYou;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get goodMorning;

  /// No description provided for @staySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search area, college, or PG'**
  String get staySearchHint;

  /// No description provided for @noStaysFound.
  ///
  /// In en, this message translates to:
  /// **'No stays found'**
  String get noStaysFound;

  /// No description provided for @underTwelveK.
  ///
  /// In en, this message translates to:
  /// **'Under ₹12k'**
  String get underTwelveK;

  /// No description provided for @singleRoom.
  ///
  /// In en, this message translates to:
  /// **'Single room'**
  String get singleRoom;

  /// No description provided for @meals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get meals;

  /// No description provided for @womensPg.
  ///
  /// In en, this message translates to:
  /// **'Women\'s PG'**
  String get womensPg;

  /// No description provided for @savedStays.
  ///
  /// In en, this message translates to:
  /// **'Saved stays'**
  String get savedStays;

  /// No description provided for @noSavedStaysYet.
  ///
  /// In en, this message translates to:
  /// **'No saved stays yet'**
  String get noSavedStaysYet;

  /// No description provided for @noSavedStaysBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on a stay to keep it here.'**
  String get noSavedStaysBody;

  /// No description provided for @savedStaysSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see the stays you saved.'**
  String get savedStaysSignIn;

  /// No description provided for @myStays.
  ///
  /// In en, this message translates to:
  /// **'My stays'**
  String get myStays;

  /// No description provided for @noStaysHereYet.
  ///
  /// In en, this message translates to:
  /// **'No stays here yet'**
  String get noStaysHereYet;

  /// No description provided for @tabActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get tabActive;

  /// No description provided for @tabRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get tabRequests;

  /// No description provided for @tabPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get tabPast;

  /// No description provided for @rent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get rent;

  /// No description provided for @visitScheduledFor.
  ///
  /// In en, this message translates to:
  /// **'Visit scheduled for {date}, 5 PM'**
  String visitScheduledFor(String date);

  /// No description provided for @monthsCount.
  ///
  /// In en, this message translates to:
  /// **'{months} months'**
  String monthsCount(int months);

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @acceptJob.
  ///
  /// In en, this message translates to:
  /// **'Accept job'**
  String get acceptJob;

  /// No description provided for @accountHolderName.
  ///
  /// In en, this message translates to:
  /// **'Account holder name'**
  String get accountHolderName;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get accountNumber;

  /// No description provided for @accountVerified.
  ///
  /// In en, this message translates to:
  /// **'Account ••••4821 · Verified'**
  String get accountVerified;

  /// No description provided for @activeJobs.
  ///
  /// In en, this message translates to:
  /// **'Active jobs'**
  String get activeJobs;

  /// No description provided for @addAccountToWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Add your account to withdraw earnings'**
  String get addAccountToWithdraw;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add address'**
  String get addAddress;

  /// No description provided for @addAnAddress.
  ///
  /// In en, this message translates to:
  /// **'Add an address'**
  String get addAnAddress;

  /// No description provided for @addCommentOptional.
  ///
  /// In en, this message translates to:
  /// **'Add a comment (optional)'**
  String get addCommentOptional;

  /// No description provided for @addedToActiveJobs.
  ///
  /// In en, this message translates to:
  /// **'Added to active jobs'**
  String get addedToActiveJobs;

  /// No description provided for @addedToYourActiveJobs.
  ///
  /// In en, this message translates to:
  /// **'Added to your active jobs'**
  String get addedToYourActiveJobs;

  /// No description provided for @addPayoutFirst.
  ///
  /// In en, this message translates to:
  /// **'Add a payout method first'**
  String get addPayoutFirst;

  /// No description provided for @addressesSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save the addresses you book to.'**
  String get addressesSignInPrompt;

  /// No description provided for @addressLabelHint.
  ///
  /// In en, this message translates to:
  /// **'Label (Home, Office…)'**
  String get addressLabelHint;

  /// No description provided for @addressLineHint.
  ///
  /// In en, this message translates to:
  /// **'Building, street, area'**
  String get addressLineHint;

  /// No description provided for @addressTooLong.
  ///
  /// In en, this message translates to:
  /// **'Address must be 255 characters or fewer'**
  String get addressTooLong;

  /// No description provided for @adSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Ad submitted for review'**
  String get adSubmitted;

  /// No description provided for @allClear.
  ///
  /// In en, this message translates to:
  /// **'All clear'**
  String get allClear;

  /// No description provided for @amountToPay.
  ///
  /// In en, this message translates to:
  /// **'Amount to Pay'**
  String get amountToPay;

  /// No description provided for @applicationReviewNote.
  ///
  /// In en, this message translates to:
  /// **'We\'ll review your details and verify your documents within 24-48 hours. You\'ll get a notification once your provider account is approved.'**
  String get applicationReviewNote;

  /// No description provided for @applicationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Application Submitted!'**
  String get applicationSubmitted;

  /// No description provided for @asPrintedOnAccount.
  ///
  /// In en, this message translates to:
  /// **'As printed on your bank account'**
  String get asPrintedOnAccount;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @availableNow.
  ///
  /// In en, this message translates to:
  /// **'Available now'**
  String get availableNow;

  /// No description provided for @availableOffers.
  ///
  /// In en, this message translates to:
  /// **'Available Offers'**
  String get availableOffers;

  /// No description provided for @availableToWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Available to withdraw'**
  String get availableToWithdraw;

  /// No description provided for @avgPerJob.
  ///
  /// In en, this message translates to:
  /// **'Avg per Job'**
  String get avgPerJob;

  /// No description provided for @bankLinked.
  ///
  /// In en, this message translates to:
  /// **'Bank linked'**
  String get bankLinked;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank name'**
  String get bankName;

  /// No description provided for @booked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get booked;

  /// No description provided for @bookingAccepted.
  ///
  /// In en, this message translates to:
  /// **'Booking accepted'**
  String get bookingAccepted;

  /// No description provided for @bookingReference.
  ///
  /// In en, this message translates to:
  /// **'Booking Reference'**
  String get bookingReference;

  /// No description provided for @bookingRequest.
  ///
  /// In en, this message translates to:
  /// **'Booking request'**
  String get bookingRequest;

  /// No description provided for @bookingSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your mobile number to book this service.'**
  String get bookingSignInPrompt;

  /// No description provided for @bookService.
  ///
  /// In en, this message translates to:
  /// **'Book Service'**
  String get bookService;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get businessName;

  /// No description provided for @businessNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Royal Shine Co.'**
  String get businessNameHint;

  /// No description provided for @byAppointment.
  ///
  /// In en, this message translates to:
  /// **'By appointment'**
  String get byAppointment;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @cancelOrderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this order?'**
  String get cancelOrderConfirm;

  /// No description provided for @canNowWithdraw.
  ///
  /// In en, this message translates to:
  /// **'You can now withdraw your earnings'**
  String get canNowWithdraw;

  /// No description provided for @catPorter.
  ///
  /// In en, this message translates to:
  /// **'Porter'**
  String get catPorter;

  /// No description provided for @catTaxiRide.
  ///
  /// In en, this message translates to:
  /// **'Taxi / Ride'**
  String get catTaxiRide;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @chatSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in to message your service provider.'**
  String get chatSignInPrompt;

  /// No description provided for @chatWithProvider.
  ///
  /// In en, this message translates to:
  /// **'Chat with Provider'**
  String get chatWithProvider;

  /// No description provided for @chooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get chooseCategory;

  /// No description provided for @chooseServiceAddress.
  ///
  /// In en, this message translates to:
  /// **'Choose service address'**
  String get chooseServiceAddress;

  /// No description provided for @claimOfferArrow.
  ///
  /// In en, this message translates to:
  /// **'Claim Offer →'**
  String get claimOfferArrow;

  /// No description provided for @completedJobs.
  ///
  /// In en, this message translates to:
  /// **'Completed Jobs'**
  String get completedJobs;

  /// No description provided for @confirmWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Confirm withdrawal'**
  String get confirmWithdrawal;

  /// No description provided for @contactNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get contactNumber;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @customerHasBeenNotified.
  ///
  /// In en, this message translates to:
  /// **'The customer has been notified'**
  String get customerHasBeenNotified;

  /// No description provided for @customerNotified.
  ///
  /// In en, this message translates to:
  /// **'Customer notified'**
  String get customerNotified;

  /// No description provided for @customersCanBook.
  ///
  /// In en, this message translates to:
  /// **'Customers can book you now'**
  String get customersCanBook;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @declined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get declined;

  /// No description provided for @defaultCaps.
  ///
  /// In en, this message translates to:
  /// **'DEFAULT'**
  String get defaultCaps;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what\'s included, your experience, service area…'**
  String get descriptionHint;

  /// No description provided for @detailsForProfile.
  ///
  /// In en, this message translates to:
  /// **'We\'ll use these details to set up your provider profile.'**
  String get detailsForProfile;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @enterAccountHolderName.
  ///
  /// In en, this message translates to:
  /// **'Enter account holder name'**
  String get enterAccountHolderName;

  /// No description provided for @enterALabel.
  ///
  /// In en, this message translates to:
  /// **'Enter a label'**
  String get enterALabel;

  /// No description provided for @enterTheAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter the address'**
  String get enterTheAddress;

  /// No description provided for @enterValidAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 9–18 digit account number'**
  String get enterValidAccountNumber;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @fixedPrice.
  ///
  /// In en, this message translates to:
  /// **'Fixed price'**
  String get fixedPrice;

  /// No description provided for @fundsArriveIn.
  ///
  /// In en, this message translates to:
  /// **'Funds arrive in 1–2 business days'**
  String get fundsArriveIn;

  /// No description provided for @goesLiveIn24h.
  ///
  /// In en, this message translates to:
  /// **'Goes live within 24 hours'**
  String get goesLiveIn24h;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @howWasExperience.
  ///
  /// In en, this message translates to:
  /// **'How was your experience?'**
  String get howWasExperience;

  /// No description provided for @idDocument.
  ///
  /// In en, this message translates to:
  /// **'ID Document'**
  String get idDocument;

  /// No description provided for @idDocumentHint.
  ///
  /// In en, this message translates to:
  /// **'Upload a government-issued photo ID'**
  String get idDocumentHint;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @inReview.
  ///
  /// In en, this message translates to:
  /// **'In review'**
  String get inReview;

  /// No description provided for @labelTooLong.
  ///
  /// In en, this message translates to:
  /// **'Label must be 50 characters or fewer'**
  String get labelTooLong;

  /// No description provided for @linkAccount.
  ///
  /// In en, this message translates to:
  /// **'Link account'**
  String get linkAccount;

  /// No description provided for @linkBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Link bank account'**
  String get linkBankAccount;

  /// No description provided for @listings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get listings;

  /// No description provided for @listingTitle.
  ///
  /// In en, this message translates to:
  /// **'Listing title'**
  String get listingTitle;

  /// No description provided for @listingTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Deep home cleaning (3BHK)'**
  String get listingTitleHint;

  /// No description provided for @liveUpdatesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Live updates unavailable — reopen the chat to see new replies.'**
  String get liveUpdatesUnavailable;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @markedAllRead.
  ///
  /// In en, this message translates to:
  /// **'Marked all read'**
  String get markedAllRead;

  /// No description provided for @marking.
  ///
  /// In en, this message translates to:
  /// **'Marking…'**
  String get marking;

  /// No description provided for @myListings.
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get myListings;

  /// No description provided for @mySchedule.
  ///
  /// In en, this message translates to:
  /// **'My Schedule'**
  String get mySchedule;

  /// No description provided for @newRequest.
  ///
  /// In en, this message translates to:
  /// **'New request'**
  String get newRequest;

  /// No description provided for @newRequests.
  ///
  /// In en, this message translates to:
  /// **'New Requests'**
  String get newRequests;

  /// No description provided for @noActiveJobs.
  ///
  /// In en, this message translates to:
  /// **'No active jobs'**
  String get noActiveJobs;

  /// No description provided for @noBankLinked.
  ///
  /// In en, this message translates to:
  /// **'No bank linked'**
  String get noBankLinked;

  /// No description provided for @noBankLinkedYet.
  ///
  /// In en, this message translates to:
  /// **'No bank linked yet'**
  String get noBankLinkedYet;

  /// No description provided for @noEarningsYet.
  ///
  /// In en, this message translates to:
  /// **'No earnings yet'**
  String get noEarningsYet;

  /// No description provided for @noNewRequests.
  ///
  /// In en, this message translates to:
  /// **'You won\'t get new requests'**
  String get noNewRequests;

  /// No description provided for @noNewRequestsNow.
  ///
  /// In en, this message translates to:
  /// **'No new requests right now'**
  String get noNewRequestsNow;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @noOffersRunning.
  ///
  /// In en, this message translates to:
  /// **'No offers running right now — check back soon.'**
  String get noOffersRunning;

  /// No description provided for @noOrdersRightNow.
  ///
  /// In en, this message translates to:
  /// **'No orders here right now'**
  String get noOrdersRightNow;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @noSavedAddressesYet.
  ///
  /// In en, this message translates to:
  /// **'No saved addresses yet'**
  String get noSavedAddressesYet;

  /// No description provided for @nothingHereYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get nothingHereYet;

  /// No description provided for @nothingWaiting.
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting'**
  String get nothingWaiting;

  /// No description provided for @notificationsSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your booking and offer updates.'**
  String get notificationsSignInPrompt;

  /// No description provided for @offersSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your reward points and offers.'**
  String get offersSignInPrompt;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get orderCancelled;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderId;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @orderStatus.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get orderStatus;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @payoutMethod.
  ///
  /// In en, this message translates to:
  /// **'Payout method'**
  String get payoutMethod;

  /// No description provided for @perDay.
  ///
  /// In en, this message translates to:
  /// **'Per day'**
  String get perDay;

  /// No description provided for @perHour.
  ///
  /// In en, this message translates to:
  /// **'Per hour'**
  String get perHour;

  /// No description provided for @pickServiceType.
  ///
  /// In en, this message translates to:
  /// **'Pick the service or item type you\'re listing'**
  String get pickServiceType;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @postNewAd.
  ///
  /// In en, this message translates to:
  /// **'Post a new ad'**
  String get postNewAd;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @pricingType.
  ///
  /// In en, this message translates to:
  /// **'Pricing type'**
  String get pricingType;

  /// No description provided for @promoTwentyOffFirstBooking.
  ///
  /// In en, this message translates to:
  /// **'20% OFF First Booking'**
  String get promoTwentyOffFirstBooking;

  /// No description provided for @provider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get provider;

  /// No description provided for @providerSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your provider account.'**
  String get providerSignInPrompt;

  /// No description provided for @publishAd.
  ///
  /// In en, this message translates to:
  /// **'Publish ad'**
  String get publishAd;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @rateYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Rate Your Experience'**
  String get rateYourExperience;

  /// No description provided for @recentBookings.
  ///
  /// In en, this message translates to:
  /// **'Recent bookings'**
  String get recentBookings;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get recentTransactions;

  /// No description provided for @removeAddress.
  ///
  /// In en, this message translates to:
  /// **'Remove address'**
  String get removeAddress;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @renameAddress.
  ///
  /// In en, this message translates to:
  /// **'Rename address'**
  String get renameAddress;

  /// No description provided for @reviewSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in to rate the services you have booked.'**
  String get reviewSignInPrompt;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get saveDraft;

  /// No description provided for @selectDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDateTitle;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @serviceArea.
  ///
  /// In en, this message translates to:
  /// **'Service area'**
  String get serviceArea;

  /// No description provided for @serviceAreaHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Downtown Bengaluru'**
  String get serviceAreaHint;

  /// No description provided for @serviceCategory.
  ///
  /// In en, this message translates to:
  /// **'Service Category'**
  String get serviceCategory;

  /// No description provided for @serviceSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your mobile number to view this service.'**
  String get serviceSignInPrompt;

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get setAsDefault;

  /// No description provided for @shareDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Share details about your experience...'**
  String get shareDetailsHint;

  /// No description provided for @statement.
  ///
  /// In en, this message translates to:
  /// **'Statement'**
  String get statement;

  /// No description provided for @submitApplication.
  ///
  /// In en, this message translates to:
  /// **'Submit Application'**
  String get submitApplication;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @tapChangeToChoose.
  ///
  /// In en, this message translates to:
  /// **'Tap Change to choose your address'**
  String get tapChangeToChoose;

  /// No description provided for @teamSize.
  ///
  /// In en, this message translates to:
  /// **'Team Size'**
  String get teamSize;

  /// No description provided for @tellUsAboutBusiness.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your business'**
  String get tellUsAboutBusiness;

  /// No description provided for @todayAtAGlance.
  ///
  /// In en, this message translates to:
  /// **'Today at a glance'**
  String get todayAtAGlance;

  /// No description provided for @todaysBookings.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Bookings'**
  String get todaysBookings;

  /// No description provided for @todaysEarnings.
  ///
  /// In en, this message translates to:
  /// **'Today\'s earnings'**
  String get todaysEarnings;

  /// No description provided for @todaysTimeSlots.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Time Slots'**
  String get todaysTimeSlots;

  /// No description provided for @trackSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in to track your orders.'**
  String get trackSignInPrompt;

  /// No description provided for @tradeLicense.
  ///
  /// In en, this message translates to:
  /// **'Trade License'**
  String get tradeLicense;

  /// No description provided for @tradeLicenseHint.
  ///
  /// In en, this message translates to:
  /// **'Upload a clear photo or PDF of your trade license'**
  String get tradeLicenseHint;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessage;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @uploadDocuments.
  ///
  /// In en, this message translates to:
  /// **'Upload required documents'**
  String get uploadDocuments;

  /// No description provided for @uploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploaded;

  /// No description provided for @verifiedProvidersBlurb.
  ///
  /// In en, this message translates to:
  /// **'Verified providers get more bookings and customer trust.'**
  String get verifiedProvidersBlurb;

  /// No description provided for @viewOrders.
  ///
  /// In en, this message translates to:
  /// **'View orders'**
  String get viewOrders;

  /// No description provided for @weekdaysOnly.
  ///
  /// In en, this message translates to:
  /// **'Weekdays only'**
  String get weekdaysOnly;

  /// No description provided for @whatWentWell.
  ///
  /// In en, this message translates to:
  /// **'What went well?'**
  String get whatWentWell;

  /// No description provided for @withdrawalRequested.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal requested'**
  String get withdrawalRequested;

  /// No description provided for @withdrawEarnings.
  ///
  /// In en, this message translates to:
  /// **'Withdraw earnings'**
  String get withdrawEarnings;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

  /// No description provided for @youAreOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get youAreOffline;

  /// No description provided for @youAreOnline.
  ///
  /// In en, this message translates to:
  /// **'You\'re online'**
  String get youAreOnline;

  /// No description provided for @youEarnAfterFee.
  ///
  /// In en, this message translates to:
  /// **'You earn (after 12% fee)'**
  String get youEarnAfterFee;

  /// No description provided for @partnerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Partner dashboard'**
  String get partnerDashboard;

  /// No description provided for @linkBankToGetPaid.
  ///
  /// In en, this message translates to:
  /// **'Link your bank to get paid'**
  String get linkBankToGetPaid;

  /// No description provided for @addAccountToTransfer.
  ///
  /// In en, this message translates to:
  /// **'Add your account so we can transfer your earnings'**
  String get addAccountToTransfer;

  /// No description provided for @addBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Add bank account'**
  String get addBankAccount;

  /// No description provided for @listServiceOrItem.
  ///
  /// In en, this message translates to:
  /// **'List a service or item'**
  String get listServiceOrItem;

  /// No description provided for @earningsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Earnings this week'**
  String get earningsThisWeek;

  /// No description provided for @paymentConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Payment Confirmed'**
  String get paymentConfirmed;

  /// No description provided for @searchVendorsHint.
  ///
  /// In en, this message translates to:
  /// **'Search vendors or services…'**
  String get searchVendorsHint;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @noSellersYet.
  ///
  /// In en, this message translates to:
  /// **'No sellers yet'**
  String get noSellersYet;

  /// No description provided for @listingsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Listings will appear here once sellers start posting ads.'**
  String get listingsWillAppear;

  /// No description provided for @tapCardToViewVendor.
  ///
  /// In en, this message translates to:
  /// **'Tap a card to view the vendor'**
  String get tapCardToViewVendor;

  /// No description provided for @verifiedVendor.
  ///
  /// In en, this message translates to:
  /// **'Verified vendor'**
  String get verifiedVendor;

  /// No description provided for @aboutThisService.
  ///
  /// In en, this message translates to:
  /// **'About this service'**
  String get aboutThisService;

  /// No description provided for @locationCoverage.
  ///
  /// In en, this message translates to:
  /// **'Location & coverage'**
  String get locationCoverage;

  /// No description provided for @contactVendor.
  ///
  /// In en, this message translates to:
  /// **'Contact vendor'**
  String get contactVendor;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @sampleVendorReview.
  ///
  /// In en, this message translates to:
  /// **'\"Spotless work and very professional team. Booked again the same week.\" — Layla M.'**
  String get sampleVendorReview;

  /// No description provided for @workOrderCaps.
  ///
  /// In en, this message translates to:
  /// **'WORK ORDER'**
  String get workOrderCaps;

  /// No description provided for @elkRepairCaps.
  ///
  /// In en, this message translates to:
  /// **'ELK REPAIR'**
  String get elkRepairCaps;

  /// No description provided for @pickASlot.
  ///
  /// In en, this message translates to:
  /// **'Pick a slot'**
  String get pickASlot;

  /// No description provided for @cleanPlanCaps.
  ///
  /// In en, this message translates to:
  /// **'CLEAN PLAN'**
  String get cleanPlanCaps;

  /// No description provided for @elkCleanCaps.
  ///
  /// In en, this message translates to:
  /// **'ELKCLEAN'**
  String get elkCleanCaps;

  /// No description provided for @loyalty.
  ///
  /// In en, this message translates to:
  /// **'Loyalty'**
  String get loyalty;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @partnerAccount.
  ///
  /// In en, this message translates to:
  /// **'Partner account'**
  String get partnerAccount;

  /// No description provided for @forUsers.
  ///
  /// In en, this message translates to:
  /// **'For users'**
  String get forUsers;

  /// No description provided for @forSellers.
  ///
  /// In en, this message translates to:
  /// **'For sellers'**
  String get forSellers;

  /// No description provided for @currentlySellerMode.
  ///
  /// In en, this message translates to:
  /// **'Currently in Seller Mode'**
  String get currentlySellerMode;

  /// No description provided for @currentlyUserMode.
  ///
  /// In en, this message translates to:
  /// **'Currently in User Mode'**
  String get currentlyUserMode;

  /// No description provided for @switchToSellerPanel.
  ///
  /// In en, this message translates to:
  /// **'Switch to Seller Panel'**
  String get switchToSellerPanel;

  /// No description provided for @switchToUserPanel.
  ///
  /// In en, this message translates to:
  /// **'Switch to User Panel'**
  String get switchToUserPanel;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get currentLocation;

  /// No description provided for @chooseYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose your location'**
  String get chooseYourLocation;

  /// No description provided for @searchForAddress.
  ///
  /// In en, this message translates to:
  /// **'Search for an address'**
  String get searchForAddress;

  /// No description provided for @findStreetArea.
  ///
  /// In en, this message translates to:
  /// **'Find any street, area or landmark'**
  String get findStreetArea;

  /// No description provided for @useCurrentLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocationTitle;

  /// No description provided for @usesPhoneGps.
  ///
  /// In en, this message translates to:
  /// **'Uses your phone GPS'**
  String get usesPhoneGps;

  /// No description provided for @savedAddressesSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to use your saved addresses.'**
  String get savedAddressesSignIn;

  /// No description provided for @noSavedAddressesSearch.
  ///
  /// In en, this message translates to:
  /// **'No saved addresses yet — search for one below.'**
  String get noSavedAddressesSearch;

  /// No description provided for @savedAddressesTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved addresses'**
  String get savedAddressesTitle;

  /// No description provided for @searchAddress.
  ///
  /// In en, this message translates to:
  /// **'Search address'**
  String get searchAddress;

  /// No description provided for @streetAreaHint.
  ///
  /// In en, this message translates to:
  /// **'Street, area or landmark'**
  String get streetAreaHint;

  /// No description provided for @noMatchingPlaces.
  ///
  /// In en, this message translates to:
  /// **'No matching places.'**
  String get noMatchingPlaces;

  /// No description provided for @startTypingToFind.
  ///
  /// In en, this message translates to:
  /// **'Start typing to find an address.'**
  String get startTypingToFind;

  /// No description provided for @turnOnLocationServices.
  ///
  /// In en, this message translates to:
  /// **'Turn on location services to use this.'**
  String get turnOnLocationServices;

  /// No description provided for @locationPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Location permission is needed to detect your address.'**
  String get locationPermissionNeeded;

  /// No description provided for @rateDriver.
  ///
  /// In en, this message translates to:
  /// **'Rate {driver}'**
  String rateDriver(String driver);

  /// No description provided for @totalCaps.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get totalCaps;

  /// No description provided for @locating.
  ///
  /// In en, this message translates to:
  /// **'Locating…'**
  String get locating;

  /// No description provided for @setPickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Set pickup location'**
  String get setPickupLocation;

  /// No description provided for @setDropLocation.
  ///
  /// In en, this message translates to:
  /// **'Set drop location'**
  String get setDropLocation;

  /// No description provided for @setPickupAndDrop.
  ///
  /// In en, this message translates to:
  /// **'Set both the pickup and drop locations first.'**
  String get setPickupAndDrop;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'ml', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ml':
      return AppLocalizationsMl();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
