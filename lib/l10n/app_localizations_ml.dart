// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get appTitle => 'ELK Business Hub';

  @override
  String get commonContinue => 'തുടരുക';

  @override
  String get commonCancel => 'റദ്ദാക്കുക';

  @override
  String get commonDelete => 'ഇല്ലാതാക്കുക';

  @override
  String get deleteListing => 'ഈ ലിസ്റ്റിംഗ് ഇല്ലാതാക്കണോ?';

  @override
  String get pauseListing => 'താൽക്കാലികമായി നിർത്തുക';

  @override
  String get resumeListing => 'വീണ്ടും തുടങ്ങുക';

  @override
  String get photos => 'ഫോട്ടോകൾ';

  @override
  String get draftSaved => 'ഡ്രാഫ്റ്റ് സേവ് ചെയ്തു';

  @override
  String get fillRequiredFields => 'ആദ്യം വിഭാഗം, തലക്കെട്ട്, വില നൽകുക.';

  @override
  String get addPhoto => 'ഫോട്ടോ ചേർക്കുക';

  @override
  String photosAdded(int count) {
    return '$count ചേർത്തു';
  }

  @override
  String get markCompleted => 'പൂർത്തിയായി അടയാളപ്പെടുത്തുക';

  @override
  String needAttention(int count) {
    return '$count ശ്രദ്ധ വേണം';
  }

  @override
  String get placeOrder => 'ഓർഡർ ചെയ്യുക';

  @override
  String orderPlaced(String code) {
    return 'ഓർഡർ ചെയ്തു · $code';
  }

  @override
  String get commonRetry => 'വീണ്ടും ശ്രമിക്കുക';

  @override
  String get commonSave => 'സേവ് ചെയ്യുക';

  @override
  String get commonDone => 'പൂർത്തിയായി';

  @override
  String get commonNext => 'അടുത്തത്';

  @override
  String get commonBack => 'തിരികെ';

  @override
  String get commonClose => 'അടയ്ക്കുക';

  @override
  String get commonConfirm => 'സ്ഥിരീകരിക്കുക';

  @override
  String get commonSkip => 'ഒഴിവാക്കുക';

  @override
  String get commonSearch => 'തിരയുക';

  @override
  String get commonSeeAll => 'എല്ലാം കാണുക';

  @override
  String get commonApply => 'പ്രയോഗിക്കുക';

  @override
  String get commonClear => 'മായ്ക്കുക';

  @override
  String get commonRemove => 'നീക്കം ചെയ്യുക';

  @override
  String get commonEdit => 'എഡിറ്റ് ചെയ്യുക';

  @override
  String get commonYes => 'അതെ';

  @override
  String get commonNo => 'ഇല്ല';

  @override
  String get commonOk => 'ശരി';

  @override
  String get errorGeneric => 'എന്തോ കുഴപ്പം സംഭവിച്ചു';

  @override
  String get errorTimeout =>
      'അഭ്യർത്ഥനയ്ക്ക് സമയപരിധി കഴിഞ്ഞു. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get errorNoInternet =>
      'ഇന്റർനെറ്റ് കണക്ഷൻ ഇല്ല. നിങ്ങളുടെ നെറ്റ്‌വർക്ക് പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get errorCancelled => 'അഭ്യർത്ഥന റദ്ദാക്കി.';

  @override
  String get errorInsecureConnection => 'സുരക്ഷിതമായ കണക്ഷൻ സ്ഥാപിക്കാനായില്ല.';

  @override
  String get errorUnknown =>
      'എന്തോ കുഴപ്പം സംഭവിച്ചു. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get errorValidation =>
      'നിങ്ങൾ നൽകിയ വിവരങ്ങൾ പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get errorSessionExpired =>
      'നിങ്ങളുടെ സെഷൻ കാലഹരണപ്പെട്ടു. ദയവായി വീണ്ടും ലോഗിൻ ചെയ്യുക.';

  @override
  String get errorForbidden => 'അത് ചെയ്യാൻ നിങ്ങൾക്ക് അനുമതിയില്ല.';

  @override
  String get errorNotFound => 'ആവശ്യപ്പെട്ട വിവരം കണ്ടെത്തിയില്ല.';

  @override
  String get errorTooManyRequests =>
      'വളരെയധികം ശ്രമങ്ങൾ. അൽപ്പം കാത്തിരുന്ന് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get errorServer =>
      'ഞങ്ങളുടെ ഭാഗത്ത് എന്തോ കുഴപ്പം സംഭവിച്ചു. ദയവായി പിന്നീട് ശ്രമിക്കുക.';

  @override
  String get signInRequired =>
      'തുടരാൻ നിങ്ങളുടെ മൊബൈൽ നമ്പർ ഉപയോഗിച്ച് സൈൻ ഇൻ ചെയ്യുക.';

  @override
  String get signIn => 'സൈൻ ഇൻ';

  @override
  String get registerBusinessPrompt =>
      'ബുക്കിംഗുകൾ ലഭിച്ചു തുടങ്ങാൻ നിങ്ങളുടെ ബിസിനസ്സ് രജിസ്റ്റർ ചെയ്യുക.';

  @override
  String get becomeProvider => 'ദാതാവാകുക';

  @override
  String get languageTitle => 'നിങ്ങളുടെ ഭാഷ തിരഞ്ഞെടുക്കുക';

  @override
  String get languageSubtitle =>
      'ക്രമീകരണങ്ങളിൽ നിന്ന് ഇത് എപ്പോൾ വേണമെങ്കിലും മാറ്റാം.';

  @override
  String get languageSaveFailed =>
      'നിങ്ങളുടെ ഭാഷ സേവ് ചെയ്യാനായില്ല. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get commonOr => 'അല്ലെങ്കിൽ';

  @override
  String get getStarted => 'ആരംഭിക്കുക';

  @override
  String get byContinuingYouAgree => 'തുടരുന്നതിലൂടെ നിങ്ങൾ ഞങ്ങളുടെ ';

  @override
  String get termsAndConditions => 'നിബന്ധനകൾ അംഗീകരിക്കുന്നു';

  @override
  String get verified => 'പരിശോധിച്ചത്';

  @override
  String get navHome => 'ഹോം';

  @override
  String get navBookings => 'ബുക്കിംഗുകൾ';

  @override
  String get navWallet => 'വാലറ്റ്';

  @override
  String get navProfile => 'പ്രൊഫൈൽ';

  @override
  String get onboardServicesTitle => 'നിങ്ങളുടെ എല്ലാ സേവനങ്ങളും ഒരൊറ്റ ആപ്പിൽ';

  @override
  String get onboardServicesBody =>
      'നിങ്ങളുടെ നഗരത്തിലെ പരിശോധിച്ച ദാതാക്കളിൽ നിന്ന് യാത്ര, ക്ലീനിംഗ്, വാടക എന്നിവയും അതിലധികവും ബുക്ക് ചെയ്യുക. വേഗത്തിലും വിശ്വസനീയമായും.';

  @override
  String get onboardTrackingTitle => 'തത്സമയ ട്രാക്കിംഗും ചാറ്റും';

  @override
  String get onboardTrackingBody =>
      'മാപ്പിൽ നിങ്ങളുടെ ദാതാവിനെ തത്സമയം കാണുകയും സുഗമവും സുതാര്യവുമായ അനുഭവത്തിനായി അവരുമായി നേരിട്ട് ചാറ്റ് ചെയ്യുകയും ചെയ്യുക.';

  @override
  String get onboardPaymentsTitle => 'സുരക്ഷിത പേയ്‌മെന്റുകളും റിവാർഡുകളും';

  @override
  String get onboardPaymentsBody =>
      'വാലറ്റ്, കാർഡ് അല്ലെങ്കിൽ പണം ഉപയോഗിച്ച് സുരക്ഷിതമായി പണമടയ്ക്കുക, ഓരോ ബുക്കിംഗിനും റിവാർഡ് പോയിന്റുകൾ നേടുക.';

  @override
  String get splashSettingUp => 'നിങ്ങളുടെ നഗരം സജ്ജമാക്കുന്നു';

  @override
  String get splashFindingPros => 'വിശ്വസ്ത വിദഗ്ധരെ കണ്ടെത്തുന്നു';

  @override
  String get splashAlmostThere => 'ഏതാണ്ട് പൂർത്തിയായി';

  @override
  String get authWelcomeBack => 'വീണ്ടും സ്വാഗതം';

  @override
  String get authSignInPrompt =>
      'തുടരാൻ നിങ്ങളുടെ മൊബൈൽ നമ്പർ ഉപയോഗിച്ച് സൈൻ ഇൻ ചെയ്യുക';

  @override
  String get authMobileNumber => 'മൊബൈൽ നമ്പർ';

  @override
  String get authSendOtp => 'OTP അയയ്ക്കുക';

  @override
  String get authContinueAsGuest => 'അതിഥിയായി തുടരുക';

  @override
  String get authVerifyTitle => 'നിങ്ങളുടെ നമ്പർ പരിശോധിക്കുക';

  @override
  String get authOtpSentTo => 'ഞങ്ങൾ 6 അക്ക കോഡ് അയച്ചിരിക്കുന്നു ';

  @override
  String get authVerifyContinue => 'പരിശോധിച്ച് തുടരുക';

  @override
  String get authResendCode => 'കോഡ് വീണ്ടും അയയ്ക്കുക';

  @override
  String authResendIn(String seconds) {
    return '00:$seconds-ൽ കോഡ് വീണ്ടും അയയ്ക്കും';
  }

  @override
  String get homeBestSellersTag => 'മികച്ച വിൽപ്പനക്കാർ';

  @override
  String get homeBestSellersRest => 'നിങ്ങൾക്ക് സമീപം';

  @override
  String get homeBestSellersSub =>
      'ഏറ്റവും കൂടുതൽ സേവ് ചെയ്തതും കണ്ടതുമായ ലിസ്റ്റിംഗുകൾ';

  @override
  String get homeDealsTag => 'ഓഫറുകൾ';

  @override
  String get homeDealsRest => 'നിങ്ങൾക്കായി';

  @override
  String get homeDealsSub =>
      'നിങ്ങൾക്ക് സമീപമുള്ള വിൽപ്പനക്കാരിൽ നിന്ന് കൂടുതൽ';

  @override
  String get homeServiceAt => 'സേവനം ഇവിടെ';

  @override
  String get homeSelectLocation => 'സ്ഥലം തിരഞ്ഞെടുക്കുക';

  @override
  String get homeServices => 'സേവനങ്ങൾ';

  @override
  String get homeBadgeFast => 'വേഗം';

  @override
  String get homeBadgeNew => 'പുതിയത്';

  @override
  String get homeBadgeTwentyOff => '20% കിഴിവ്';

  @override
  String get homeNoSellerAds => 'ഇതുവരെ വിൽപ്പനക്കാരുടെ പരസ്യങ്ങളില്ല';

  @override
  String get homeMoreListingsSoon =>
      'വിൽപ്പനക്കാർ പോസ്റ്റ് ചെയ്യുമ്പോൾ കൂടുതൽ ലിസ്റ്റിംഗുകൾ ഇവിടെ കാണാം.';

  @override
  String get promoFirstBookingTitle => 'നിങ്ങളുടെ ആദ്യ ബുക്കിംഗിന്\n20% കിഴിവ്';

  @override
  String get promoFirstBookingBody =>
      'പുതിയ അംഗങ്ങൾക്ക് എല്ലാ സേവനങ്ങളിലും പ്രത്യേക കിഴിവ് ലഭിക്കും.';

  @override
  String get promoClaimOffer => 'ഓഫർ നേടുക';

  @override
  String get promoFreeRidesTitle => 'എല്ലാ ആഴ്ചയും\nസൗജന്യ യാത്ര';

  @override
  String get promoFreeRidesBody =>
      'അംഗങ്ങൾക്ക് പ്രതിവാര ആനുകൂല്യങ്ങളും മുൻഗണനാ പിന്തുണയും കുറഞ്ഞ ഫീസും ലഭിക്കും.';

  @override
  String get promoJoinNow => 'ഇപ്പോൾ ചേരുക';

  @override
  String get profileSignOut => 'സൈൻ ഔട്ട്';

  @override
  String get profileSignOutConfirm => 'നിങ്ങൾക്ക് ഉറപ്പായും സൈൻ ഔട്ട് ചെയ്യണോ?';

  @override
  String get profileUpdated => 'പ്രൊഫൈൽ അപ്ഡേറ്റ് ചെയ്തു';

  @override
  String get profileEdit => 'പ്രൊഫൈൽ എഡിറ്റ് ചെയ്യുക';

  @override
  String get profileRewardPoints => 'റിവാർഡ് പോയിന്റുകൾ';

  @override
  String get profileRating => 'റേറ്റിംഗ്';

  @override
  String get profileMyAccount => 'എന്റെ അക്കൗണ്ട്';

  @override
  String get profileOffersRewards => 'ഓഫറുകളും റിവാർഡുകളും';

  @override
  String get profileNotifications => 'അറിയിപ്പുകൾ';

  @override
  String get profileSavedAddresses => 'സേവ് ചെയ്ത വിലാസങ്ങൾ';

  @override
  String get profileLanguage => 'ഭാഷ';

  @override
  String get profileRateService => 'ഒരു സേവനം റേറ്റ് ചെയ്യുക';

  @override
  String get profileProviderTools => 'ദാതാവിനുള്ള ടൂളുകൾ';

  @override
  String get profileProviderDashboard => 'ദാതാവിന്റെ ഡാഷ്‌ബോർഡ്';

  @override
  String get profileSupport => 'പിന്തുണ';

  @override
  String get profileHelpSupport => 'സഹായവും പിന്തുണയും';

  @override
  String get profileAbout => 'ELK Business Hub-നെക്കുറിച്ച്';

  @override
  String get profileTermsPrivacy => 'നിബന്ധനകളും സ്വകാര്യതാ നയവും';

  @override
  String get profileGuestTitle => 'നിങ്ങൾ അതിഥിയായി ബ്രൗസ് ചെയ്യുന്നു';

  @override
  String get profileGuestBody =>
      'നിങ്ങളുടെ പ്രൊഫൈൽ, ബുക്കിംഗുകൾ, റിവാർഡുകൾ കാണാൻ മൊബൈൽ നമ്പർ ഉപയോഗിച്ച് സൈൻ ഇൻ ചെയ്യുക.';

  @override
  String get profileNameRequired => 'ദയവായി നിങ്ങളുടെ പേര് നൽകുക.';

  @override
  String get profileNameTooLong => 'പേര് 100 അക്ഷരങ്ങളിൽ കൂടരുത്.';

  @override
  String get profileEmailInvalid => 'സാധുവായ ഇമെയിൽ വിലാസം നൽകുക.';

  @override
  String get profileNameLabel => 'പേര്';

  @override
  String get profileEmailLabel => 'ഇമെയിൽ (നിർബന്ധമല്ല)';

  @override
  String get walletToppedUp => 'വാലറ്റിൽ പണം ചേർത്തു';

  @override
  String get walletWithdrawSuccess => 'പിൻവലിക്കൽ വിജയകരം';

  @override
  String get walletStillLoading =>
      'വാലറ്റ് ലോഡ് ചെയ്യുന്നു. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get walletAddMoneyTitle => 'വാലറ്റിൽ പണം ചേർക്കുക';

  @override
  String get walletWithdrawTitle => 'ബാങ്കിലേക്ക് പിൻവലിക്കുക';

  @override
  String get walletAddMoney => 'പണം ചേർക്കുക';

  @override
  String get walletWithdraw => 'പിൻവലിക്കുക';

  @override
  String get walletAmountTooSmall => '0-യിൽ കൂടുതലുള്ള തുക നൽകുക';

  @override
  String get walletAmountTooLarge => 'തുക ₹1,000,000-ൽ കൂടരുത്';

  @override
  String get walletSignInPrompt =>
      'നിങ്ങളുടെ ELK വാലറ്റും റിവാർഡ് പോയിന്റുകളും ഉപയോഗിക്കാൻ സൈൻ ഇൻ ചെയ്യുക.';

  @override
  String get walletAvailableBalance => 'ലഭ്യമായ ബാലൻസ്';

  @override
  String get walletTransactionHistory => 'ഇടപാട് ചരിത്രം';

  @override
  String get statusConfirmed => 'സ്ഥിരീകരിച്ചു';

  @override
  String get statusPendingVendor => 'വെണ്ടറുടെ കാത്തിരിപ്പ്';

  @override
  String get statusCompleted => 'പൂർത്തിയായി';

  @override
  String get statusCancelled => 'റദ്ദാക്കി';

  @override
  String get statusUnknown => 'അജ്ഞാതം';

  @override
  String get myBookingsTitle => 'എന്റെ ബുക്കിംഗുകൾ';

  @override
  String get bookingsSignInPrompt =>
      'നിങ്ങൾ ബുക്ക് ചെയ്ത സേവനങ്ങൾ കാണാൻ സൈൻ ഇൻ ചെയ്യുക.';

  @override
  String get tabUpcoming => 'വരാനിരിക്കുന്നത്';

  @override
  String get emptyUpcomingTitle => 'വരാനിരിക്കുന്ന ബുക്കിംഗുകളില്ല';

  @override
  String get emptyUpcomingBody => 'ഒരു സേവനം ബുക്ക് ചെയ്യുക, അത് ഇവിടെ കാണാം.';

  @override
  String get emptyCompletedTitle => 'ഇതുവരെ ഒന്നും പൂർത്തിയായിട്ടില്ല';

  @override
  String get emptyCompletedBody => 'പൂർത്തിയായ ബുക്കിംഗുകൾ ഇവിടെ കാണാം.';

  @override
  String get emptyCancelledTitle => 'റദ്ദാക്കിയ ബുക്കിംഗുകളില്ല';

  @override
  String get emptyCancelledBody => 'റദ്ദാക്കലുകൾ ഇവിടെ കാണാം.';

  @override
  String get bookingDetailsTitle => 'ബുക്കിംഗ് വിശദാംശങ്ങൾ';

  @override
  String get sectionStatus => 'നില';

  @override
  String get sectionScheduleAddress => 'സമയവും വിലാസവും';

  @override
  String get labelDateTime => 'തീയതിയും സമയവും';

  @override
  String get labelServiceAddress => 'സേവന വിലാസം';

  @override
  String get sectionVendor => 'വെണ്ടർ';

  @override
  String get vendorContactUnavailable =>
      'വെണ്ടറുടെ ബന്ധപ്പെടൽ വിവരം ഇതുവരെ ലഭ്യമല്ല';

  @override
  String get callAction => 'വിളിക്കുക';

  @override
  String get sectionPayment => 'പേയ്‌മെന്റ്';

  @override
  String get lineService => 'സേവനം';

  @override
  String get totalPaid => 'ആകെ അടച്ചത്';

  @override
  String get totalCancelled => 'ആകെ (റദ്ദാക്കി)';

  @override
  String get bookingId => 'ബുക്കിംഗ് ഐഡി';

  @override
  String get copyAction => 'പകർത്തുക';

  @override
  String get cancelIsFreeNote =>
      'വരാനിരിക്കുന്ന ബുക്കിംഗ് റദ്ദാക്കുന്നത് സൗജന്യമാണ്, നിങ്ങളുടെ സ്ലോട്ട് ഉടൻ ഒഴിയും.';

  @override
  String get rebookThisService => 'ഈ സേവനം വീണ്ടും ബുക്ക് ചെയ്യുക';

  @override
  String get ratedStar => 'റേറ്റ് ചെയ്തു ★';

  @override
  String get rateAction => 'റേറ്റ് ചെയ്യുക';

  @override
  String get rebookAction => 'വീണ്ടും ബുക്ക് ചെയ്യുക';

  @override
  String get trackOrder => 'ഓർഡർ ട്രാക്ക് ചെയ്യുക';

  @override
  String get cancelling => 'റദ്ദാക്കുന്നു…';

  @override
  String get cancelBooking => 'ബുക്കിംഗ് റദ്ദാക്കുക';

  @override
  String get cancelBookingQuestion => 'ഈ ബുക്കിംഗ് റദ്ദാക്കണോ?';

  @override
  String get whyCancelling => 'നിങ്ങൾ എന്തുകൊണ്ട് റദ്ദാക്കുന്നു?';

  @override
  String get cancelReasonPlans => 'പദ്ധതി മാറി';

  @override
  String get cancelReasonAlternative => 'മറ്റൊരു ഓപ്ഷൻ കണ്ടെത്തി';

  @override
  String get cancelReasonWrongTime => 'തെറ്റായ തീയതി/സമയം';

  @override
  String get cancelReasonExpensive => 'വളരെ ചെലവേറിയത്';

  @override
  String get cancelReasonOther => 'മറ്റുള്ളവ';

  @override
  String get cancellingIsFreePrefix => 'റദ്ദാക്കൽ സൗജന്യമാണ് — ';

  @override
  String get cancellingIsFreeSuffix => ' ഈ ബുക്കിംഗിന് ഈടാക്കില്ല.';

  @override
  String get keepBooking => 'ബുക്കിംഗ് നിലനിർത്തുക';

  @override
  String get rebookHint => 'സേവനങ്ങൾ ടാബിൽ നിന്ന് സേവനം വീണ്ടും തിരഞ്ഞെടുക്കുക';

  @override
  String get copiedBookingId => 'ബുക്കിംഗ് ഐഡി പകർത്തി';

  @override
  String get cancelledNothingCharged => 'റദ്ദാക്കി — ഒന്നും ഈടാക്കിയില്ല';

  @override
  String get viewDetails => 'വിശദാംശങ്ങൾ കാണുക';

  @override
  String get bookingCancelledToast => 'ബുക്കിംഗ് റദ്ദാക്കി';

  @override
  String get timelineBooked => 'ബുക്ക് ചെയ്തു';

  @override
  String get timelineBookedSub => 'ഓർഡർ നൽകി';

  @override
  String get timelineConfirmedSub => 'വെണ്ടർ സ്വീകരിച്ചു';

  @override
  String get timelineInProgress => 'പുരോഗമിക്കുന്നു';

  @override
  String get timelineInProgressSub => 'അന്നത്തെ ദിവസം';

  @override
  String get timelineCompletedSub => 'സേവനം പൂർത്തിയായി';

  @override
  String get timelineRefundIssued => 'റീഫണ്ട് ELK വാലറ്റിലേക്ക് നൽകി';

  @override
  String get bookingNotScheduled => 'സമയം നിശ്ചയിച്ചിട്ടില്ല';

  @override
  String get dateToday => 'ഇന്ന്';

  @override
  String get dateTomorrow => 'നാളെ';

  @override
  String get dateYesterday => 'ഇന്നലെ';

  @override
  String walletRewardPoints(int points) {
    return '$points റിവാർഡ് പോയിന്റുകൾ';
  }

  @override
  String vendorSpecialist(String service) {
    return '$service വിദഗ്ധൻ';
  }

  @override
  String get svcTaxiRides => 'ടാക്സിയും യാത്രയും';

  @override
  String get svcCleaning => 'ക്ലീനിംഗ്';

  @override
  String get svcCarRental => 'കാർ വാടക';

  @override
  String get svcRepair => 'റിപ്പയർ';

  @override
  String get svcPorterMovers => 'പോർട്ടറും മൂവേഴ്‌സും';

  @override
  String get svcEconomyTaxi => 'ഇക്കോണമി ടാക്സി';

  @override
  String get svcPremiumTaxi => 'പ്രീമിയം ടാക്സി';

  @override
  String get svcAuto => 'ഓട്ടോ';

  @override
  String get svcXlVan => 'XL വാൻ';

  @override
  String get svcPgStay => 'പിജി താമസം';

  @override
  String get svcMensHostel => 'പുരുഷ ഹോസ്റ്റൽ';

  @override
  String get svcWomensHostel => 'വനിതാ ഹോസ്റ്റൽ';

  @override
  String get svcHomestay => 'ഹോംസ്റ്റേ';

  @override
  String get svcHomeCleaning => 'വീട് ക്ലീനിംഗ്';

  @override
  String get svcDeepCleaning => 'ഡീപ് ക്ലീനിംഗ്';

  @override
  String get svcSofaUpholstery => 'സോഫയും അപ്ഹോൾസ്റ്ററിയും';

  @override
  String get svcKitchenCleaning => 'അടുക്കള ക്ലീനിംഗ്';

  @override
  String get svcBathroomCleaning => 'ബാത്ത്റൂം ക്ലീനിംഗ്';

  @override
  String get svcCarpetRug => 'കാർപ്പറ്റും റഗ്ഗും';

  @override
  String get svcLaundryIron => 'ലോൺഡ്രിയും ഇസ്തിരിയും';

  @override
  String get svcWashFold => 'കഴുകി മടക്കൽ';

  @override
  String get svcWaterTank => 'വാട്ടർ ടാങ്ക്';

  @override
  String get svcSedan => 'സെഡാൻ';

  @override
  String get svcSuv => 'എസ്‌യുവി';

  @override
  String get svcLuxury => 'ലക്ഷ്വറി';

  @override
  String get svcVan => 'വാൻ';

  @override
  String get svcAcCooling => 'എസിയും കൂളിംഗും';

  @override
  String get svcPlumbing => 'പ്ലംബിംഗ്';

  @override
  String get svcElectrical => 'ഇലക്ട്രിക്കൽ';

  @override
  String get svcCarpentry => 'ആശാരിപ്പണി';

  @override
  String get svcPainting => 'പെയിന്റിംഗ്';

  @override
  String get svcHandyman => 'ഹാൻഡിമാൻ';

  @override
  String get svcBikeDelivery => 'ബൈക്ക് ഡെലിവറി';

  @override
  String get svcMiniTruck => 'മിനി ട്രക്ക്';

  @override
  String get svcHouseShifting => 'വീട് മാറ്റം';

  @override
  String get svcMoversPackers => 'മൂവേഴ്‌സ് & പാക്കേഴ്‌സ്';

  @override
  String get svcSearchHint => 'സേവനങ്ങൾ തിരയുക… (ഉദാ. എസി, ടാക്സി)';

  @override
  String get rideBlurbAuto => 'ബജറ്റ് ഓട്ടോ റിക്ഷ യാത്ര';

  @override
  String get rideBlurbEconomy => 'ദിവസേനയുള്ള താങ്ങാവുന്ന കാറുകൾ';

  @override
  String get rideBlurbPremium => 'ഉയർന്ന റേറ്റിംഗുള്ള പ്രീമിയം കാറുകൾ';

  @override
  String get rideBlurbXl => 'കുടുംബങ്ങൾക്കും ഗ്രൂപ്പുകൾക്കും വലിയ ബാഗുകൾക്കും';

  @override
  String get rideBlurbAutoShort => 'ബജറ്റ് റിക്ഷ യാത്ര';

  @override
  String get rideBlurbEconomyShort => 'ദിവസേനയുള്ള താങ്ങാവുന്ന യാത്ര';

  @override
  String get rideBlurbPremiumShort => 'കൂടുതൽ ഇടം, മികച്ച ഡ്രൈവർമാർ';

  @override
  String get taxiSignInPrompt =>
      'യാത്ര ബുക്ക് ചെയ്യാൻ മൊബൈൽ നമ്പർ ഉപയോഗിച്ച് സൈൻ ഇൻ ചെയ്യുക.';

  @override
  String get taxiBookARide => 'യാത്ര ബുക്ക് ചെയ്യുക';

  @override
  String get taxiNoRideTypes => 'ഇപ്പോൾ യാത്രാ വിഭാഗങ്ങളൊന്നും ലഭ്യമല്ല.';

  @override
  String get taxiChooseRide => 'നിങ്ങളുടെ യാത്ര തിരഞ്ഞെടുക്കുക';

  @override
  String get taxiPickup => 'പിക്കപ്പ്';

  @override
  String get taxiDropoff => 'ഡ്രോപ്പ്-ഓഫ്';

  @override
  String get sortRecommended => 'ശുപാർശ ചെയ്തത്';

  @override
  String get sortFaster => 'വേഗതയേറിയത്';

  @override
  String get sortCheaper => 'വിലകുറഞ്ഞത്';

  @override
  String get payCash => 'പണം';

  @override
  String get payCard => 'ക്രെഡിറ്റ് / ഡെബിറ്റ് കാർഡ്';

  @override
  String get payElkWallet => 'ELK വാലറ്റ്';

  @override
  String get payApplePay => 'Apple Pay';

  @override
  String get payApplePayGooglePay => 'Apple Pay / Google Pay';

  @override
  String get payCashSub => 'എത്തുമ്പോൾ ഡ്രൈവർക്ക് പണം നൽകാൻ സ്ഥിരീകരിക്കുക';

  @override
  String get payCardSub => 'വിസ, മാസ്റ്റർകാർഡ് എന്നിവയും';

  @override
  String get payWalletSub => 'നിങ്ങളുടെ ELK വാലറ്റ് ബാലൻസിൽ നിന്ന് പണമടയ്ക്കുക';

  @override
  String get payApplePaySub => 'വേഗതയേറിയതും സുരക്ഷിതവുമായ ചെക്ക്ഔട്ട്';

  @override
  String get changeAction => 'മാറ്റുക';

  @override
  String get bookPrefix => 'ബുക്ക് ചെയ്യുക ';

  @override
  String get fare => 'നിരക്ക്';

  @override
  String get cancellationFee => 'റദ്ദാക്കൽ';

  @override
  String get seats => 'സീറ്റുകൾ';

  @override
  String get fareEstimateNote =>
      'ആകെ നിരക്ക് ദൂരവും സമയവും അടിസ്ഥാനമാക്കിയുള്ള ഏകദേശ കണക്കാണ്. ചെക്ക്ഔട്ടിൽ സർചാർജ്, പീക്ക് വില അല്ലെങ്കിൽ ടോൾ ചേർത്തേക്കാം.';

  @override
  String get choosePickupLocation => 'പിക്കപ്പ് സ്ഥലം തിരഞ്ഞെടുക്കുക';

  @override
  String get chooseDropoffLocation => 'ഡ്രോപ്പ്-ഓഫ് സ്ഥലം തിരഞ്ഞെടുക്കുക';

  @override
  String get fareBase => 'അടിസ്ഥാന നിരക്ക്';

  @override
  String get fareBookingFee => 'ബുക്കിംഗ് ഫീസ്';

  @override
  String get assigningDriver => 'ഡ്രൈവറെ നിയോഗിക്കുന്നു…';

  @override
  String get detailsOnTheWay => 'വിവരങ്ങൾ വരുന്നു';

  @override
  String get couldNotBookRide => 'യാത്ര ബുക്ക് ചെയ്യാനായില്ല.';

  @override
  String get findingDriver => 'ഡ്രൈവറെ കണ്ടെത്തുന്നു';

  @override
  String get lookingForDrivers => 'സമീപത്തുള്ള ഡ്രൈവർമാരെ തിരയുന്നു';

  @override
  String get driverAssigned => 'ഡ്രൈവറെ നിയോഗിച്ചു';

  @override
  String get completePaymentNote =>
      'ബുക്കിംഗ് സ്ഥിരീകരിക്കാൻ പേയ്‌മെന്റ് പൂർത്തിയാക്കുക. തൊട്ടുപിന്നാലെ ട്രിപ്പ് OTP ലഭിക്കും.';

  @override
  String get proceedToPayment => 'പേയ്‌മെന്റിലേക്ക് പോകുക';

  @override
  String get amountDue => 'അടയ്ക്കേണ്ട തുക';

  @override
  String get total => 'ആകെ';

  @override
  String get selectPaymentMethod => 'പേയ്‌മെന്റ് രീതി തിരഞ്ഞെടുക്കുക';

  @override
  String get paymentsSecured =>
      'പേയ്‌മെന്റുകൾ 256-ബിറ്റ് എൻക്രിപ്ഷനിൽ സുരക്ഷിതം';

  @override
  String get cardYourName => 'നിങ്ങളുടെ പേര്';

  @override
  String get cardDetails => 'കാർഡ് വിവരങ്ങൾ';

  @override
  String get cardHolder => 'കാർഡ് ഉടമ';

  @override
  String get cardExpires => 'കാലാവധി';

  @override
  String get cardNumber => 'കാർഡ് നമ്പർ';

  @override
  String get cardExpiry => 'കാലാവധി';

  @override
  String get cardCvv => 'സിവിവി';

  @override
  String get cardholderName => 'കാർഡ് ഉടമയുടെ പേര്';

  @override
  String get cardAsShown => 'കാർഡിൽ കാണിച്ചിരിക്കുന്നത് പോലെ';

  @override
  String get saveCardForFuture => 'ഭാവി പേയ്‌മെന്റുകൾക്കായി കാർഡ് സേവ് ചെയ്യുക';

  @override
  String get otpBeingPrepared => 'നിങ്ങളുടെ OTP തയ്യാറാക്കുന്നു';

  @override
  String get driverOnTheWay => 'ഡ്രൈവർ വരുന്നു';

  @override
  String get shareOtpToStart => 'യാത്ര ആരംഭിക്കാൻ ഈ OTP പങ്കിടുക';

  @override
  String get safety => 'സുരക്ഷ';

  @override
  String get shareTrip => 'യാത്ര പങ്കിടുക';

  @override
  String get driverArrivedStartTrip => 'ഡ്രൈവർ എത്തി · യാത്ര തുടങ്ങുക';

  @override
  String get couldNotStartTrip => 'യാത്ര ആരംഭിക്കാനായില്ല.';

  @override
  String get tripInProgress => 'യാത്ര പുരോഗമിക്കുന്നു';

  @override
  String get headingTo => 'പോകുന്നത്';

  @override
  String get completeTrip => 'യാത്ര പൂർത്തിയാക്കുക';

  @override
  String get couldNotCompleteTrip => 'യാത്ര പൂർത്തിയാക്കാനായില്ല.';

  @override
  String get distance => 'ദൂരം';

  @override
  String get duration => 'സമയം';

  @override
  String get farePaid => 'നിരക്ക് · അടച്ചു';

  @override
  String get addATip => 'ടിപ്പ് ചേർക്കുക';

  @override
  String get noTip => 'ടിപ്പ് ഇല്ല';

  @override
  String get finishTrip => 'യാത്ര അവസാനിപ്പിക്കുക';

  @override
  String get couldNotSubmitRating => 'നിങ്ങളുടെ റേറ്റിംഗ് അയയ്ക്കാനായില്ല.';

  @override
  String get allDoneThanks => 'പൂർത്തിയായി — യാത്രയ്ക്ക് നന്ദി!';

  @override
  String get trip => 'യാത്ര';

  @override
  String get driver => 'ഡ്രൈവർ';

  @override
  String get tip => 'ടിപ്പ്';

  @override
  String get transactionId => 'ഇടപാട് ഐഡി';

  @override
  String get receiptDownloaded => 'രസീത് ഡൗൺലോഡ് ചെയ്തു';

  @override
  String get download => 'ഡൗൺലോഡ്';

  @override
  String get bookAnotherTrip => 'മറ്റൊരു യാത്ര ബുക്ക് ചെയ്യുക';

  @override
  String svcNoMatch(String query) {
    return '\"$query\" എന്നതിന് സേവനങ്ങളൊന്നും പൊരുത്തപ്പെടുന്നില്ല.\n\"എസി\", \"ടാക്സി\" അല്ലെങ്കിൽ \"ക്ലീൻ\" ശ്രമിക്കുക.';
  }

  @override
  String rideSeats(int seats) {
    return '$seats സീറ്റുകൾ';
  }

  @override
  String fareDistance(String km) {
    return 'ദൂരം ($km കി.മീ)';
  }

  @override
  String fareTime(int minutes) {
    return 'സമയം ($minutes മിനിറ്റ്)';
  }

  @override
  String tipWillBeCharged(String amount, String method) {
    return '$amount നിങ്ങളുടെ $method-ൽ നിന്ന് ഈടാക്കും';
  }

  @override
  String totalVia(String method) {
    return '$method വഴി ആകെ';
  }

  @override
  String get addServiceAddress => 'സേവന വിലാസം ചേർക്കുക';

  @override
  String get cleanSignInPrompt =>
      'ക്ലീനിംഗ് സേവനങ്ങൾ ബുക്ക് ചെയ്യാൻ മൊബൈൽ നമ്പർ ഉപയോഗിച്ച് സൈൻ ഇൻ ചെയ്യുക.';

  @override
  String get topOffers => 'മികച്ച ഓഫറുകൾ';

  @override
  String get goodAfternoon => 'നമസ്കാരം';

  @override
  String get cleanSearchHint => '\"ഡീപ് ക്ലീൻ\", \"ടാങ്ക്\" തിരയുക…';

  @override
  String get playUnlockDeals => 'കളിച്ച് സമ്മർ ഡീലുകൾ നേടൂ!';

  @override
  String get getWaterTankCleaning => 'വാട്ടർ ടാങ്ക് ക്ലീനിംഗ് നേടൂ ';

  @override
  String get whatNeedsCleaning => 'എന്താണ് വൃത്തിയാക്കേണ്ടത്?';

  @override
  String get codeLabel => 'കോഡ്: ';

  @override
  String get ecoFriendlyProducts =>
      'പരിസ്ഥിതി സൗഹൃദ, കുട്ടികൾക്ക് സുരക്ഷിതമായ ഉൽപ്പന്നങ്ങൾ';

  @override
  String get trainedCleaners => 'പരിശീലനം ലഭിച്ച യൂണിഫോം ധരിച്ച ക്ലീനർമാർ';

  @override
  String get fromLabel => 'മുതൽ';

  @override
  String get howWeDoIt => 'ഞങ്ങൾ എങ്ങനെ ചെയ്യുന്നു';

  @override
  String get hygieneAfterService => 'സേവനത്തിന് ശേഷമുള്ള ശുചിത്വ നിലവാരം';

  @override
  String get beforeLabel => 'മുമ്പ്';

  @override
  String get afterLabTested => 'ശേഷം · ലാബ് പരിശോധിച്ചത്';

  @override
  String get elkCleanCrew => 'ELKclean ടീം';

  @override
  String get crewBlurb =>
      'യൂണിഫോം · ഇക്കോ കിറ്റ് · 1,200+ ക്ലീനുകളിൽ നിന്ന് 4.9';

  @override
  String get priceCaps => 'വില';

  @override
  String get yourCleanPlan => 'നിങ്ങളുടെ ക്ലീൻ പ്ലാൻ';

  @override
  String get addPromoCode => 'പ്രോമോ കോഡ് ചേർക്കുക';

  @override
  String get subtotal => 'ഉപ ആകെത്തുക';

  @override
  String get ecoSuppliesSetup => 'ഇക്കോ സാമഗ്രികളും സജ്ജീകരണവും';

  @override
  String get selectDate => 'തീയതി തിരഞ്ഞെടുക്കുക';

  @override
  String get arrivalWindow => 'എത്തുന്ന സമയം';

  @override
  String get fillsFast => 'വേഗം നിറയും';

  @override
  String get available => 'ലഭ്യമാണ്';

  @override
  String get crewArrivalNote =>
      'നിങ്ങളുടെ ടീം 2 മണിക്കൂർ ഇടവേളയിൽ എല്ലാ സാമഗ്രികളുമായി എത്തും. അന്നേ ദിവസം ലൈവ് ട്രാക്കിംഗ് ലിങ്ക് അയയ്ക്കും.';

  @override
  String get serviceAddress => 'സേവന വിലാസം';

  @override
  String get savedPlaces => 'സേവ് ചെയ്ത സ്ഥലങ്ങൾ';

  @override
  String get noSavedAddresses =>
      'ഇതുവരെ സേവ് ചെയ്ത വിലാസങ്ങളില്ല — താഴെ ചേർക്കുക.';

  @override
  String get addNewAddress => 'പുതിയ വിലാസം ചേർക്കുക';

  @override
  String get addServiceAddressFirst => 'ദയവായി ആദ്യം സേവന വിലാസം ചേർക്കുക.';

  @override
  String get reviewConfirm => 'അവലോകനവും സ്ഥിരീകരണവും';

  @override
  String get whenLabel => 'എപ്പോൾ';

  @override
  String get whereLabel => 'എവിടെ';

  @override
  String get contactLabel => 'ബന്ധപ്പെടുക';

  @override
  String get verifiedAccount => 'പരിശോധിച്ച അക്കൗണ്ട്';

  @override
  String get orderSummary => 'ഓർഡർ സംഗ്രഹം';

  @override
  String get totalToPay => 'അടയ്ക്കേണ്ട ആകെ തുക';

  @override
  String get recleanGuarantee =>
      'സന്തുഷ്ടനല്ലേ? 48 മണിക്കൂറിനുള്ളിൽ സൗജന്യമായി വീണ്ടും വൃത്തിയാക്കും. 2 മണിക്കൂർ മുമ്പ് വരെ സൗജന്യ റദ്ദാക്കൽ.';

  @override
  String get payCardBrands => 'വിസ, മാസ്റ്റർകാർഡ്, അമെക്സ്';

  @override
  String get payOneTapCheckout => 'ഒറ്റ ടാപ്പിൽ സുരക്ഷിത ചെക്ക്ഔട്ട്';

  @override
  String get chooseMethod => 'രീതി തിരഞ്ഞെടുക്കുക';

  @override
  String get nameOnCard => 'കാർഡിലെ പേര്';

  @override
  String get saveCardFasterCheckout =>
      'വേഗത്തിലുള്ള ചെക്ക്ഔട്ടിനായി കാർഡ് സേവ് ചെയ്യുക';

  @override
  String get processing => 'പ്രോസസ് ചെയ്യുന്നു…';

  @override
  String get paymentFailed =>
      'പേയ്‌മെന്റ് പരാജയപ്പെട്ടു. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get paidLabel => 'അടച്ചു';

  @override
  String get paidCaps => 'അടച്ചു';

  @override
  String get trackMyClean => 'എന്റെ ക്ലീൻ ട്രാക്ക് ചെയ്യുക';

  @override
  String get noServicesYet => 'ഇതുവരെ സേവനങ്ങളില്ല';

  @override
  String get browseCleaningBlurb =>
      'ക്ലീനിംഗ് സേവനങ്ങൾ കണ്ട് നിങ്ങളുടെ പ്ലാൻ ഉണ്ടാക്കുക.';

  @override
  String get browseServices => 'സേവനങ്ങൾ കാണുക';

  @override
  String paySecurely(String amount) {
    return '$amount സുരക്ഷിതമായി അടയ്ക്കുക';
  }

  @override
  String servicesAdded(int count) {
    return '$count സേവനങ്ങൾ ചേർത്തു';
  }

  @override
  String get repairSignInPrompt =>
      'റിപ്പയർ ബുക്ക് ചെയ്യാൻ മൊബൈൽ നമ്പർ ഉപയോഗിച്ച് സൈൻ ഇൻ ചെയ്യുക.';

  @override
  String get repairSearchHint => '\"എസി സർവീസ്\", \"ലീക്ക്\" തിരയുക…';

  @override
  String get summerReady => 'വേനലിന് തയ്യാർ';

  @override
  String get whatNeedsFixing => 'എന്താണ് ശരിയാക്കേണ്ടത്?';

  @override
  String get whatsIncluded => 'എന്തൊക്കെ ഉൾപ്പെടുന്നു';

  @override
  String get topRatedCrew => 'മികച്ച റേറ്റിംഗുള്ള ടീം';

  @override
  String get techCrewBlurb =>
      'ബുക്കിംഗിന് ശേഷം നിയോഗിക്കും · 800+ ജോലികളിൽ ശരാശരി 4.9';

  @override
  String get yourWorkOrder => 'നിങ്ങളുടെ വർക്ക് ഓർഡർ';

  @override
  String get visitInspectionFee => 'സന്ദർശന, പരിശോധനാ ഫീസ്';

  @override
  String get techArrivalNote =>
      'നിങ്ങളുടെ ടെക്നീഷ്യൻ 2 മണിക്കൂർ ഇടവേളയിൽ എത്തും. അന്നേ ദിവസം ലൈവ് ട്രാക്കിംഗ് ലിങ്ക് ലഭിക്കും.';

  @override
  String get chargedAfterComplete =>
      'ജോലി പൂർത്തിയായെന്ന് സ്ഥിരീകരിച്ച ശേഷം മാത്രമേ ഈടാക്കൂ. 2 മണിക്കൂർ മുമ്പ് വരെ സൗജന്യ റദ്ദാക്കൽ.';

  @override
  String get trackMyBooking => 'എന്റെ ബുക്കിംഗ് ട്രാക്ക് ചെയ്യുക';

  @override
  String get browseTradesBlurb => 'ട്രേഡുകൾ കണ്ട് ശരിയാക്കേണ്ടത് ചേർക്കുക.';

  @override
  String get rentalSignInPrompt =>
      'കാർ വാടകയ്ക്കെടുക്കാൻ മൊബൈൽ നമ്പർ ഉപയോഗിച്ച് സൈൻ ഇൻ ചെയ്യുക.';

  @override
  String get carsAvailable => 'കാറുകൾ ലഭ്യമാണ്';

  @override
  String get sortPrice => 'അടുക്കുക: വില';

  @override
  String get noCarsInCategory => 'ഈ വിഭാഗത്തിൽ ഇപ്പോൾ കാറുകളില്ല.';

  @override
  String get bookNow => 'ഇപ്പോൾ ബുക്ക് ചെയ്യുക';

  @override
  String get porterSignInPrompt =>
      'പാഴ്‌സൽ അയയ്ക്കാൻ മൊബൈൽ നമ്പർ ഉപയോഗിച്ച് സൈൻ ഇൻ ചെയ്യുക.';

  @override
  String get selectVehicle => 'വാഹനം തിരഞ്ഞെടുക്കുക';

  @override
  String get pricingUpdates => 'നിങ്ങളുടെ തിരഞ്ഞെടുപ്പിനനുസരിച്ച് വില മാറും';

  @override
  String get addOns => 'അധിക സേവനങ്ങൾ';

  @override
  String get porterLogistics => 'പോർട്ടറും ലോജിസ്റ്റിക്സും';

  @override
  String get pickupLocation => 'പിക്കപ്പ് സ്ഥലം';

  @override
  String get dropLocation => 'ഡ്രോപ്പ് സ്ഥലം';

  @override
  String get packageType => 'പാഴ്‌സൽ തരം';

  @override
  String get packageElectronics => 'ഇലക്ട്രോണിക്സ്';

  @override
  String get weight => 'ഭാരം';

  @override
  String get estimatedTime => 'ഏകദേശ സമയം';

  @override
  String get estimatedFare => 'ഏകദേശ നിരക്ക്';

  @override
  String get bookPorter => 'പോർട്ടർ ബുക്ക് ചെയ്യുക';

  @override
  String get couldNotBookDelivery => 'ഡെലിവറി ബുക്ക് ചെയ്യാനായില്ല.';

  @override
  String get stepSchedule => 'സമയം';

  @override
  String get pickUpNow => 'ഇപ്പോൾ പിക്കപ്പ്';

  @override
  String get scheduleForLater => 'പിന്നീടേക്ക് ക്രമീകരിക്കുക';

  @override
  String get pickupDate => 'പിക്കപ്പ് തീയതി';

  @override
  String get selectDateAction => 'തീയതി തിരഞ്ഞെടുക്കുക';

  @override
  String get pickupWindow => 'പിക്കപ്പ് സമയം';

  @override
  String get estTime => 'ഏകദേശ സമയം';

  @override
  String get continueToPayment => 'പേയ്‌മെന്റിലേക്ക് തുടരുക';

  @override
  String get payCardBrandsShort => 'വിസ, മാസ്റ്റർകാർഡ്';

  @override
  String get payCashOnDelivery => 'ഡെലിവറിയിൽ പണം';

  @override
  String get deliveryFare => 'ഡെലിവറി നിരക്ക്';

  @override
  String get serviceFee => 'സേവന ഫീസ്';

  @override
  String get gstFivePercent => 'ജിഎസ്ടി (5%)';

  @override
  String get continueToCardDetails => 'കാർഡ് വിവരങ്ങളിലേക്ക് തുടരുക';

  @override
  String get amount => 'തുക';

  @override
  String get confirmAndPay => 'സ്ഥിരീകരിച്ച് പണമടയ്ക്കുക';

  @override
  String get completeCardDetails =>
      'ദയവായി എല്ലാ കാർഡ് വിവരങ്ങളും പൂരിപ്പിക്കുക';

  @override
  String get paymentsSecuredByElk =>
      'പേയ്‌മെന്റുകൾ ELK ഗേറ്റ്‌വേ വഴി സുരക്ഷിതം';

  @override
  String get processingPayment => 'പേയ്‌മെന്റ് പ്രോസസ് ചെയ്യുന്നു';

  @override
  String get confirmingWithBank =>
      'നിങ്ങളുടെ ബാങ്കുമായി സ്ഥിരീകരിക്കുന്നു, ഈ സ്ക്രീൻ അടയ്ക്കരുത്';

  @override
  String get bookingConfirmed => 'ബുക്കിംഗ് സ്ഥിരീകരിച്ചു';

  @override
  String get porterNotified => 'നിങ്ങളുടെ പോർട്ടറെ അറിയിച്ചു';

  @override
  String get trackingId => 'ട്രാക്കിംഗ് ഐഡി';

  @override
  String get vehicle => 'വാഹനം';

  @override
  String get arrival => 'എത്തിച്ചേരൽ';

  @override
  String get amountPaid => 'അടച്ച തുക';

  @override
  String get receiptSentToEmail => 'രസീത് നിങ്ങളുടെ ഇമെയിലിലേക്ക് അയച്ചു';

  @override
  String get viewReceipt => 'രസീത് കാണുക →';

  @override
  String get stepTripDetails => 'യാത്രാ വിവരങ്ങൾ';

  @override
  String get stepPickupDelivery => 'പിക്കപ്പും ഡെലിവറിയും';

  @override
  String get stepExtrasProtection => 'അധികവും സംരക്ഷണവും';

  @override
  String get stepLocation => 'സ്ഥലം';

  @override
  String get stepExtras => 'അധികം';

  @override
  String get stepReview => 'അവലോകനം';

  @override
  String get stepPay => 'പണമടയ്ക്കുക';

  @override
  String get yourAccount => 'നിങ്ങളുടെ അക്കൗണ്ട്';

  @override
  String get branch => 'ബ്രാഞ്ച്';

  @override
  String get securedByElkPay => 'ELK Pay വഴി സുരക്ഷിതം · 256-ബിറ്റ് എൻക്രിപ്ഷൻ';

  @override
  String get totalSoFar => 'ഇതുവരെയുള്ള ആകെ';

  @override
  String get whenDoYouNeedIt => 'നിങ്ങൾക്ക് എപ്പോൾ വേണം?';

  @override
  String get pickPlanAndDates =>
      'നിങ്ങളുടെ വാടക പ്ലാനും യാത്രാ തീയതികളും തിരഞ്ഞെടുക്കുക';

  @override
  String get rateDaily => 'ദിവസേന';

  @override
  String get rateWeekly => 'പ്രതിവാരം · 15% കിഴിവ്';

  @override
  String get rateMonthly => 'പ്രതിമാസം · 30% കിഴിവ്';

  @override
  String get pickupDateTime => 'പിക്കപ്പ് തീയതിയും സമയവും';

  @override
  String get whenRentalBegins => 'നിങ്ങളുടെ വാടക എപ്പോൾ തുടങ്ങുന്നു';

  @override
  String get returnDateTime => 'മടക്ക തീയതിയും സമയവും';

  @override
  String get whenRentalEnds => 'നിങ്ങളുടെ വാടക എപ്പോൾ അവസാനിക്കുന്നു';

  @override
  String get rentalLength => 'വാടക കാലയളവ്';

  @override
  String get rentalBillingNote =>
      'വാടക പൂർണ്ണ ദിവസങ്ങളായാണ് ഈടാക്കുന്നത്. 59 മിനിറ്റിലധികം വൈകി കാർ തിരികെ നൽകിയാൽ ഒരു ദിവസം അധികം ഈടാക്കും.';

  @override
  String get howGetYourCar => 'നിങ്ങളുടെ കാർ എങ്ങനെ ലഭിക്കണം?';

  @override
  String get collectOrDelivered =>
      'സ്വയം എടുക്കുക അല്ലെങ്കിൽ വിലാസത്തിൽ എത്തിക്കാം';

  @override
  String get selfPickup => 'സ്വയം എടുക്കുക';

  @override
  String get collectFromBranch => 'ELK ബ്രാഞ്ചിൽ നിന്ന് എടുക്കുക';

  @override
  String get free => 'സൗജന്യം';

  @override
  String get carDelivery => 'കാർ ഡെലിവറി';

  @override
  String get weBringIt => 'ഞങ്ങൾ നിങ്ങളുടെ വിലാസത്തിൽ എത്തിക്കും';

  @override
  String get chooseBranch => 'ബ്രാഞ്ച് തിരഞ്ഞെടുക്കുക';

  @override
  String get mapPreviewHint =>
      'മാപ്പ് പ്രിവ്യൂ · ദിശകൾ തുറക്കാൻ ടാപ്പ് ചെയ്യുക';

  @override
  String get deliveryAddress => 'ഡെലിവറി വിലാസം';

  @override
  String get deliveryAddressHint => 'ഉദാ. കോറമംഗല, ബെംഗളൂരു';

  @override
  String get buildingVillaNo => 'ബിൽഡിംഗ് / വില്ല നമ്പർ';

  @override
  String get driverDirections => 'ഡ്രൈവർക്കുള്ള നിർദ്ദേശങ്ങൾ (നിർബന്ധമല്ല)';

  @override
  String get driverDirectionsHint =>
      'ഗേറ്റ് കോഡ്, ലാൻഡ്‌മാർക്ക്, പാർക്കിംഗ് കുറിപ്പുകൾ…';

  @override
  String get locationCaptured => 'സ്ഥലം രേഖപ്പെടുത്തി';

  @override
  String get useCurrentLocation => 'എന്റെ നിലവിലെ സ്ഥലം ഉപയോഗിക്കുക';

  @override
  String get deliveryFeeNote =>
      'ഡെലിവറി ഫീസ് ₹25 · പിക്കപ്പ് സമയത്തിന്റെ 2 മണിക്കൂറിനുള്ളിൽ കാർ എത്തും.';

  @override
  String get enhanceYourTrip => 'നിങ്ങളുടെ യാത്ര മെച്ചപ്പെടുത്തുക';

  @override
  String get optionalAddOns =>
      'ഓപ്ഷണൽ ആഡ്-ഓണുകൾ — യാത്രയ്ക്ക് അനുയോജ്യമായവ തിരഞ്ഞെടുക്കുക';

  @override
  String get reviewYourBooking => 'നിങ്ങളുടെ ബുക്കിംഗ് അവലോകനം ചെയ്യുക';

  @override
  String get doubleCheckBeforePay => 'പണമടയ്ക്കും മുമ്പ് എല്ലാം പരിശോധിക്കുക';

  @override
  String get bookingAsYourself => 'നിങ്ങൾക്കായി തന്നെ ബുക്ക് ചെയ്യുന്നു';

  @override
  String get tripDates => 'യാത്രാ തീയതികൾ';

  @override
  String get priceBreakdown => 'വില വിശദാംശം';

  @override
  String get deliveryFee => 'ഡെലിവറി ഫീസ്';

  @override
  String get promoCodeHint => 'പ്രോമോ കോഡ് — ELK10 പരീക്ഷിക്കുക';

  @override
  String get totalInclGst => 'ആകെ (5% ജിഎസ്ടി ഉൾപ്പെടെ)';

  @override
  String get iAgreeToThe => 'ഞാൻ അംഗീകരിക്കുന്നു ';

  @override
  String get rentalTerms => 'വാടക നിബന്ധനകൾ';

  @override
  String get enterPromoFirst => 'ആദ്യം പ്രോമോ കോഡ് നൽകുക';

  @override
  String get promoNotValid => 'ആ കോഡ് സാധുവല്ല';

  @override
  String get cashOnPickup => 'പിക്കപ്പിൽ പണം';

  @override
  String get chooseHowToPay => 'നിങ്ങൾ എങ്ങനെ പണമടയ്ക്കണമെന്ന് തിരഞ്ഞെടുക്കുക';

  @override
  String get cardLabel => 'കാർഡ്';

  @override
  String get saveCardNextTime =>
      'അടുത്ത തവണ വേഗത്തിലുള്ള ചെക്ക്ഔട്ടിനായി ഈ കാർഡ് സേവ് ചെയ്യുക';

  @override
  String get payWithDigitalWallet =>
      'നിങ്ങളുടെ ഡിജിറ്റൽ വാലറ്റ് ഉപയോഗിച്ച് പണമടയ്ക്കുക';

  @override
  String get walletRedirectNote =>
      'ഈ പേയ്‌മെന്റ് സുരക്ഷിതമായി പൂർത്തിയാക്കാൻ നിങ്ങളെ റീഡയറക്ട് ചെയ്യും, ശേഷം ELK Business Hub-ലേക്ക് തിരികെ വരും.';

  @override
  String get cashAtBranchNote =>
      'ബ്രാഞ്ച് കൗണ്ടറിൽ കാർ എടുക്കുമ്പോൾ മുഴുവൻ തുകയും പണമായി അടയ്ക്കുക.';

  @override
  String get cashToDriverNote =>
      'കാർ എത്തിക്കുമ്പോൾ ഞങ്ങളുടെ ഡ്രൈവർക്ക് മുഴുവൻ തുകയും പണമായി നൽകുക.';

  @override
  String get processingYourPayment =>
      'നിങ്ങളുടെ പേയ്‌മെന്റ് പ്രോസസ് ചെയ്യുന്നു…';

  @override
  String get dontCloseScreen => 'ദയവായി ഈ സ്ക്രീൻ അടയ്ക്കരുത്';

  @override
  String get bookingConfirmedBang => 'ബുക്കിംഗ് സ്ഥിരീകരിച്ചു!';

  @override
  String get deliveredToAddress => 'നിങ്ങളുടെ വിലാസത്തിൽ എത്തിക്കും';

  @override
  String get showThisAtPickup => 'പിക്കപ്പിൽ ഇത് കാണിക്കുക';

  @override
  String get viewEReceipt => 'ഇ-രസീത് കാണുക';

  @override
  String payAmount(String amount) {
    return '$amount അടയ്ക്കുക';
  }

  @override
  String confirmAndPayAmount(String amount) {
    return 'സ്ഥിരീകരിച്ച് $amount അടയ്ക്കുക';
  }

  @override
  String branchSelfPickup(String branch) {
    return '$branch (സ്വയം എടുക്കുക)';
  }

  @override
  String daysCount(int days) {
    return '$days ദിവസം';
  }

  @override
  String get payUpiSub => 'GPay, PhonePe, Paytm എന്നിവയും';

  @override
  String get payCardBrandsIn => 'വിസ, മാസ്റ്റർകാർഡ്, റുപേ';

  @override
  String get payNetBanking => 'നെറ്റ് ബാങ്കിംഗ്';

  @override
  String get payAllMajorBanks => 'എല്ലാ പ്രധാന ബാങ്കുകളും';

  @override
  String get couldNotScheduleVisit => 'സന്ദർശനം ക്രമീകരിക്കാനായില്ല.';

  @override
  String get allStays => 'എല്ലാ താമസ സ്ഥലങ്ങളും';

  @override
  String get chipAll => 'എല്ലാം';

  @override
  String get chipSingle => 'സിംഗിൾ';

  @override
  String get chipDouble => 'ഡബിൾ';

  @override
  String get chipFoodIncl => 'ഭക്ഷണം ഉൾപ്പെടെ';

  @override
  String get chipNearMetro => 'മെട്രോയ്ക്ക് സമീപം';

  @override
  String get staysInArea => 'കോറമംഗലയിലെ താമസ സ്ഥലങ്ങൾ';

  @override
  String get sortLabel => 'അടുക്കുക ';

  @override
  String get staySignInPrompt =>
      'ഈ താമസ സ്ഥലം കാണാൻ മൊബൈൽ നമ്പർ ഉപയോഗിച്ച് സൈൻ ഇൻ ചെയ്യുക.';

  @override
  String get stayBrowseSignInPrompt =>
      'താമസ സ്ഥലങ്ങൾ കാണാൻ മൊബൈൽ നമ്പർ ഉപയോഗിച്ച് സൈൻ ഇൻ ചെയ്യുക.';

  @override
  String get foodIncluded => 'ഭക്ഷണം ഉൾപ്പെടുന്നു';

  @override
  String get chooseSharing => 'ഷെയറിംഗ് തിരഞ്ഞെടുക്കുക';

  @override
  String get amenities => 'സൗകര്യങ്ങൾ';

  @override
  String get ratingsReviews => 'റേറ്റിംഗുകളും അവലോകനങ്ങളും';

  @override
  String get sampleStayReview =>
      '\"വൃത്തിയുള്ള മുറികൾ, മികച്ച ഭക്ഷണം, വളരെ സുരക്ഷിതം. വാർഡൻ സഹായകരമാണ്, യാത്രയ്ക്ക് സ്ഥലം അനുയോജ്യം.\" — പ്രിയ എസ്.';

  @override
  String get startingFrom => 'മുതൽ';

  @override
  String get visit => 'സന്ദർശനം';

  @override
  String get reserve => 'റിസർവ് ചെയ്യുക';

  @override
  String get bookYourStay => 'നിങ്ങളുടെ താമസം ബുക്ക് ചെയ്യുക';

  @override
  String get roomType => 'മുറി തരം';

  @override
  String get moveInDate => 'താമസം തുടങ്ങുന്ന തീയതി';

  @override
  String get durationCaps => 'കാലയളവ്';

  @override
  String get fullName => 'മുഴുവൻ പേര്';

  @override
  String get phoneNumber => 'ഫോൺ നമ്പർ';

  @override
  String get reviewAndPay => 'അവലോകനവും പേയ്‌മെന്റും';

  @override
  String get paymentSummary => 'പേയ്‌മെന്റ് സംഗ്രഹം';

  @override
  String get firstMonthRent => 'ആദ്യ മാസ വാടക';

  @override
  String get securityDeposit => 'സെക്യൂരിറ്റി ഡെപ്പോസിറ്റ്';

  @override
  String get refundableAtMoveOut => 'താമസം അവസാനിക്കുമ്പോൾ തിരികെ ലഭിക്കും';

  @override
  String get elkServiceFee => 'ELK സേവന ഫീസ്';

  @override
  String get couponElknew => 'കൂപ്പൺ ELKNEW';

  @override
  String get payableNow => 'ഇപ്പോൾ അടയ്ക്കേണ്ടത്';

  @override
  String get applyPrefix => 'പ്രയോഗിക്കുക ';

  @override
  String get saveFiveHundred => ' — ₹500 ലാഭിക്കുക';

  @override
  String get appliedCaps => 'പ്രയോഗിച്ചു';

  @override
  String get applyCaps => 'പ്രയോഗിക്കുക';

  @override
  String get stayPolicyNote =>
      'തുടരുന്നതിലൂടെ ELK-യുടെ താമസ നയവും റദ്ദാക്കൽ നിബന്ധനകളും അംഗീകരിക്കുന്നു. പരിശോധനയ്ക്ക് വിധേയമായി ഡെപ്പോസിറ്റ് പൂർണ്ണമായി തിരികെ ലഭിക്കും.';

  @override
  String get proceedToPay => 'പണമടയ്ക്കാൻ തുടരുക';

  @override
  String get amountPayable => 'അടയ്ക്കേണ്ട തുക';

  @override
  String get payUsing => 'ഇത് ഉപയോഗിച്ച് പണമടയ്ക്കുക';

  @override
  String get upiId => 'യുപിഐ ഐഡി';

  @override
  String get property => 'സ്വത്ത്';

  @override
  String get room => 'മുറി';

  @override
  String get moveIn => 'താമസം തുടങ്ങൽ';

  @override
  String get backToHome => 'ഹോമിലേക്ക് മടങ്ങുക';

  @override
  String get pgStays => 'പിജി താമസം';

  @override
  String get homestays => 'ഹോംസ്റ്റേകൾ';

  @override
  String get statusVisitBooked => 'സന്ദർശനം ബുക്ക് ചെയ്തു';

  @override
  String get statusPending => 'കാത്തിരിക്കുന്നു';

  @override
  String get chooseRoomFirst => 'ദയവായി ആദ്യം ഒരു മുറി തിരഞ്ഞെടുക്കുക.';

  @override
  String get whatAreYouLookingFor => 'നിങ്ങൾ എന്താണ് തിരയുന്നത്?';

  @override
  String get topRatedNearYou => 'നിങ്ങൾക്ക് സമീപം മികച്ച റേറ്റിംഗ്';

  @override
  String get goodMorning => 'സുപ്രഭാതം,';

  @override
  String get staySearchHint => 'പ്രദേശം, കോളേജ് അല്ലെങ്കിൽ പിജി തിരയുക';

  @override
  String get noStaysFound => 'താമസ സ്ഥലങ്ങളൊന്നും കണ്ടെത്തിയില്ല';

  @override
  String get underTwelveK => '₹12k-ൽ താഴെ';

  @override
  String get singleRoom => 'സിംഗിൾ റൂം';

  @override
  String get meals => 'ഭക്ഷണം';

  @override
  String get womensPg => 'വനിതാ പിജി';

  @override
  String get savedStays => 'സേവ് ചെയ്ത താമസം';

  @override
  String get noSavedStaysYet => 'ഇതുവരെ സേവ് ചെയ്ത താമസമില്ല';

  @override
  String get noSavedStaysBody =>
      'ഒരു താമസത്തിലെ ഹൃദയം അമർത്തിയാൽ അത് ഇവിടെ കാണാം.';

  @override
  String get savedStaysSignIn => 'സേവ് ചെയ്ത താമസം കാണാൻ സൈൻ ഇൻ ചെയ്യുക.';

  @override
  String get myStays => 'എന്റെ താമസം';

  @override
  String get noStaysHereYet => 'ഇവിടെ ഇതുവരെ താമസമില്ല';

  @override
  String get tabActive => 'സജീവം';

  @override
  String get tabRequests => 'അഭ്യർത്ഥനകൾ';

  @override
  String get tabPast => 'കഴിഞ്ഞവ';

  @override
  String get rent => 'വാടക';

  @override
  String visitScheduledFor(String date) {
    return '$date, വൈകിട്ട് 5 മണിക്ക് സന്ദർശനം';
  }

  @override
  String monthsCount(int months) {
    return '$months മാസം';
  }

  @override
  String get accept => 'സ്വീകരിക്കുക';

  @override
  String get accepted => 'സ്വീകരിച്ചു';

  @override
  String get acceptJob => 'ജോലി സ്വീകരിക്കുക';

  @override
  String get accountHolderName => 'അക്കൗണ്ട് ഉടമയുടെ പേര്';

  @override
  String get accountNumber => 'അക്കൗണ്ട് നമ്പർ';

  @override
  String get accountVerified => 'അക്കൗണ്ട് ••••4821 · പരിശോധിച്ചു';

  @override
  String get activeJobs => 'സജീവ ജോലികൾ';

  @override
  String get addAccountToWithdraw => 'വരുമാനം പിൻവലിക്കാൻ അക്കൗണ്ട് ചേർക്കുക';

  @override
  String get addAddress => 'വിലാസം ചേർക്കുക';

  @override
  String get addAnAddress => 'ഒരു വിലാസം ചേർക്കുക';

  @override
  String get addCommentOptional => 'അഭിപ്രായം ചേർക്കുക (നിർബന്ധമല്ല)';

  @override
  String get addedToActiveJobs => 'സജീവ ജോലികളിൽ ചേർത്തു';

  @override
  String get addedToYourActiveJobs => 'നിങ്ങളുടെ സജീവ ജോലികളിൽ ചേർത്തു';

  @override
  String get addPayoutFirst => 'ആദ്യം ഒരു പേഔട്ട് രീതി ചേർക്കുക';

  @override
  String get addressesSignInPrompt =>
      'ബുക്ക് ചെയ്യുന്ന വിലാസങ്ങൾ സേവ് ചെയ്യാൻ സൈൻ ഇൻ ചെയ്യുക.';

  @override
  String get addressLabelHint => 'ലേബൽ (വീട്, ഓഫീസ്…)';

  @override
  String get addressLineHint => 'കെട്ടിടം, തെരുവ്, പ്രദേശം';

  @override
  String get addressTooLong => 'വിലാസം 255 അക്ഷരങ്ങളിൽ കൂടരുത്';

  @override
  String get adSubmitted => 'പരസ്യം അവലോകനത്തിനായി സമർപ്പിച്ചു';

  @override
  String get allClear => 'എല്ലാം ശരി';

  @override
  String get amountToPay => 'അടയ്ക്കേണ്ട തുക';

  @override
  String get applicationReviewNote =>
      '24-48 മണിക്കൂറിനുള്ളിൽ ഞങ്ങൾ വിവരങ്ങൾ അവലോകനം ചെയ്ത് രേഖകൾ പരിശോധിക്കും. അക്കൗണ്ട് അംഗീകരിച്ചാൽ അറിയിപ്പ് ലഭിക്കും.';

  @override
  String get applicationSubmitted => 'അപേക്ഷ സമർപ്പിച്ചു!';

  @override
  String get asPrintedOnAccount =>
      'നിങ്ങളുടെ ബാങ്ക് അക്കൗണ്ടിൽ അച്ചടിച്ചിരിക്കുന്നത് പോലെ';

  @override
  String get availability => 'ലഭ്യത';

  @override
  String get availableNow => 'ഇപ്പോൾ ലഭ്യം';

  @override
  String get availableOffers => 'ലഭ്യമായ ഓഫറുകൾ';

  @override
  String get availableToWithdraw => 'പിൻവലിക്കാൻ ലഭ്യം';

  @override
  String get avgPerJob => 'ഒരു ജോലിക്ക് ശരാശരി';

  @override
  String get bankLinked => 'ബാങ്ക് ലിങ്ക് ചെയ്തു';

  @override
  String get bankName => 'ബാങ്കിന്റെ പേര്';

  @override
  String get booked => 'ബുക്ക് ചെയ്തു';

  @override
  String get bookingAccepted => 'ബുക്കിംഗ് സ്വീകരിച്ചു';

  @override
  String get bookingReference => 'ബുക്കിംഗ് റഫറൻസ്';

  @override
  String get bookingRequest => 'ബുക്കിംഗ് അഭ്യർത്ഥന';

  @override
  String get bookingSignInPrompt =>
      'ഈ സേവനം ബുക്ക് ചെയ്യാൻ മൊബൈൽ നമ്പർ ഉപയോഗിച്ച് സൈൻ ഇൻ ചെയ്യുക.';

  @override
  String get bookService => 'സേവനം ബുക്ക് ചെയ്യുക';

  @override
  String get businessName => 'ബിസിനസ്സിന്റെ പേര്';

  @override
  String get businessNameHint => 'ഉദാ. Royal Shine Co.';

  @override
  String get byAppointment => 'അപ്പോയിന്റ്മെന്റ് പ്രകാരം';

  @override
  String get cancelOrder => 'ഓർഡർ റദ്ദാക്കുക';

  @override
  String get cancelOrderConfirm => 'ഈ ഓർഡർ റദ്ദാക്കണമെന്ന് ഉറപ്പാണോ?';

  @override
  String get canNowWithdraw => 'ഇപ്പോൾ നിങ്ങൾക്ക് വരുമാനം പിൻവലിക്കാം';

  @override
  String get catPorter => 'പോർട്ടർ';

  @override
  String get catTaxiRide => 'ടാക്സി / യാത്ര';

  @override
  String get chat => 'ചാറ്റ്';

  @override
  String get chatSignInPrompt =>
      'സേവന ദാതാവിന് സന്ദേശം അയയ്ക്കാൻ സൈൻ ഇൻ ചെയ്യുക.';

  @override
  String get chatWithProvider => 'ദാതാവുമായി ചാറ്റ് ചെയ്യുക';

  @override
  String get chooseCategory => 'ഒരു വിഭാഗം തിരഞ്ഞെടുക്കുക';

  @override
  String get chooseServiceAddress => 'സേവന വിലാസം തിരഞ്ഞെടുക്കുക';

  @override
  String get claimOfferArrow => 'ഓഫർ നേടുക →';

  @override
  String get completedJobs => 'പൂർത്തിയായ ജോലികൾ';

  @override
  String get confirmWithdrawal => 'പിൻവലിക്കൽ സ്ഥിരീകരിക്കുക';

  @override
  String get contactNumber => 'ബന്ധപ്പെടാനുള്ള നമ്പർ';

  @override
  String get customer => 'ഉപഭോക്താവ്';

  @override
  String get customerHasBeenNotified => 'ഉപഭോക്താവിനെ അറിയിച്ചു';

  @override
  String get customerNotified => 'ഉപഭോക്താവിനെ അറിയിച്ചു';

  @override
  String get customersCanBook =>
      'ഉപഭോക്താക്കൾക്ക് ഇപ്പോൾ നിങ്ങളെ ബുക്ക് ചെയ്യാം';

  @override
  String get decline => 'നിരസിക്കുക';

  @override
  String get declined => 'നിരസിച്ചു';

  @override
  String get defaultCaps => 'ഡിഫോൾട്ട്';

  @override
  String get description => 'വിവരണം';

  @override
  String get descriptionHint =>
      'എന്തൊക്കെ ഉൾപ്പെടുന്നു, നിങ്ങളുടെ അനുഭവം, സേവന മേഖല എന്നിവ വിവരിക്കുക…';

  @override
  String get detailsForProfile =>
      'ഈ വിവരങ്ങൾ ഉപയോഗിച്ച് നിങ്ങളുടെ ദാതാവ് പ്രൊഫൈൽ സജ്ജമാക്കും.';

  @override
  String get done => 'പൂർത്തിയായി';

  @override
  String get earnings => 'വരുമാനം';

  @override
  String get enterAccountHolderName => 'അക്കൗണ്ട് ഉടമയുടെ പേര് നൽകുക';

  @override
  String get enterALabel => 'ഒരു ലേബൽ നൽകുക';

  @override
  String get enterTheAddress => 'വിലാസം നൽകുക';

  @override
  String get enterValidAccountNumber =>
      'സാധുവായ 9–18 അക്ക അക്കൗണ്ട് നമ്പർ നൽകുക';

  @override
  String get export => 'എക്സ്പോർട്ട്';

  @override
  String get fixedPrice => 'നിശ്ചിത വില';

  @override
  String get fundsArriveIn => '1–2 പ്രവൃത്തി ദിവസങ്ങൾക്കുള്ളിൽ പണം എത്തും';

  @override
  String get goesLiveIn24h => '24 മണിക്കൂറിനുള്ളിൽ ലൈവ് ആകും';

  @override
  String get guest => 'അതിഥി';

  @override
  String get howWasExperience => 'നിങ്ങളുടെ അനുഭവം എങ്ങനെയായിരുന്നു?';

  @override
  String get idDocument => 'ഐഡി രേഖ';

  @override
  String get idDocumentHint => 'സർക്കാർ നൽകിയ ഫോട്ടോ ഐഡി അപ്‌ലോഡ് ചെയ്യുക';

  @override
  String get inProgress => 'പുരോഗമിക്കുന്നു';

  @override
  String get inReview => 'അവലോകനത്തിൽ';

  @override
  String get labelTooLong => 'ലേബൽ 50 അക്ഷരങ്ങളിൽ കൂടരുത്';

  @override
  String get linkAccount => 'അക്കൗണ്ട് ലിങ്ക് ചെയ്യുക';

  @override
  String get linkBankAccount => 'ബാങ്ക് അക്കൗണ്ട് ലിങ്ക് ചെയ്യുക';

  @override
  String get listings => 'ലിസ്റ്റിംഗുകൾ';

  @override
  String get listingTitle => 'ലിസ്റ്റിംഗ് തലക്കെട്ട്';

  @override
  String get listingTitleHint => 'ഉദാ. ഡീപ് ഹോം ക്ലീനിംഗ് (3BHK)';

  @override
  String get liveUpdatesUnavailable =>
      'ലൈവ് അപ്‌ഡേറ്റുകൾ ലഭ്യമല്ല — പുതിയ മറുപടികൾ കാണാൻ ചാറ്റ് വീണ്ടും തുറക്കുക.';

  @override
  String get markAllRead => 'എല്ലാം വായിച്ചതായി അടയാളപ്പെടുത്തുക';

  @override
  String get markedAllRead => 'എല്ലാം വായിച്ചതായി അടയാളപ്പെടുത്തി';

  @override
  String get marking => 'അടയാളപ്പെടുത്തുന്നു…';

  @override
  String get myListings => 'എന്റെ ലിസ്റ്റിംഗുകൾ';

  @override
  String get mySchedule => 'എന്റെ ഷെഡ്യൂൾ';

  @override
  String get newRequest => 'പുതിയ അഭ്യർത്ഥന';

  @override
  String get newRequests => 'പുതിയ അഭ്യർത്ഥനകൾ';

  @override
  String get noActiveJobs => 'സജീവ ജോലികളില്ല';

  @override
  String get noBankLinked => 'ബാങ്ക് ലിങ്ക് ചെയ്തിട്ടില്ല';

  @override
  String get noBankLinkedYet => 'ഇതുവരെ ബാങ്ക് ലിങ്ക് ചെയ്തിട്ടില്ല';

  @override
  String get noEarningsYet => 'ഇതുവരെ വരുമാനമില്ല';

  @override
  String get noNewRequests => 'നിങ്ങൾക്ക് പുതിയ അഭ്യർത്ഥനകൾ ലഭിക്കില്ല';

  @override
  String get noNewRequestsNow => 'ഇപ്പോൾ പുതിയ അഭ്യർത്ഥനകളില്ല';

  @override
  String get noNotificationsYet => 'ഇതുവരെ അറിയിപ്പുകളില്ല';

  @override
  String get noOffersRunning =>
      'ഇപ്പോൾ ഓഫറുകളൊന്നുമില്ല — ഉടൻ വീണ്ടും നോക്കുക.';

  @override
  String get noOrdersRightNow => 'ഇപ്പോൾ ഇവിടെ ഓർഡറുകളില്ല';

  @override
  String get noReviewsYet => 'ഇതുവരെ അവലോകനങ്ങളില്ല';

  @override
  String get noSavedAddressesYet => 'ഇതുവരെ സേവ് ചെയ്ത വിലാസങ്ങളില്ല';

  @override
  String get nothingHereYet => 'ഇവിടെ ഇതുവരെ ഒന്നുമില്ല';

  @override
  String get nothingWaiting => 'കാത്തിരിക്കുന്നതൊന്നുമില്ല';

  @override
  String get notificationsSignInPrompt =>
      'ബുക്കിംഗ്, ഓഫർ അപ്‌ഡേറ്റുകൾ കാണാൻ സൈൻ ഇൻ ചെയ്യുക.';

  @override
  String get offersSignInPrompt =>
      'റിവാർഡ് പോയിന്റുകളും ഓഫറുകളും കാണാൻ സൈൻ ഇൻ ചെയ്യുക.';

  @override
  String get offline => 'ഓഫ്‌ലൈൻ';

  @override
  String get orderCancelled => 'ഓർഡർ റദ്ദാക്കി';

  @override
  String get orderId => 'ഓർഡർ ഐഡി';

  @override
  String get orders => 'ഓർഡറുകൾ';

  @override
  String get orderStatus => 'ഓർഡർ നില';

  @override
  String get paused => 'താൽക്കാലികമായി നിർത്തി';

  @override
  String get payoutMethod => 'പേഔട്ട് രീതി';

  @override
  String get perDay => 'ഒരു ദിവസത്തിന്';

  @override
  String get perHour => 'ഒരു മണിക്കൂറിന്';

  @override
  String get pickServiceType =>
      'നിങ്ങൾ ലിസ്റ്റ് ചെയ്യുന്ന സേവനത്തിന്റെയോ ഇനത്തിന്റെയോ തരം തിരഞ്ഞെടുക്കുക';

  @override
  String get post => 'പോസ്റ്റ്';

  @override
  String get postNewAd => 'പുതിയ പരസ്യം ഇടുക';

  @override
  String get price => 'വില';

  @override
  String get pricingType => 'വില തരം';

  @override
  String get promoTwentyOffFirstBooking => 'ആദ്യ ബുക്കിംഗിന് 20% കിഴിവ്';

  @override
  String get provider => 'ദാതാവ്';

  @override
  String get providerSignInPrompt =>
      'നിങ്ങളുടെ ദാതാവ് അക്കൗണ്ട് നിയന്ത്രിക്കാൻ സൈൻ ഇൻ ചെയ്യുക.';

  @override
  String get publishAd => 'പരസ്യം പ്രസിദ്ധീകരിക്കുക';

  @override
  String get quickActions => 'പെട്ടെന്നുള്ള പ്രവർത്തനങ്ങൾ';

  @override
  String get rateYourExperience => 'നിങ്ങളുടെ അനുഭവം റേറ്റ് ചെയ്യുക';

  @override
  String get recentBookings => 'സമീപകാല ബുക്കിംഗുകൾ';

  @override
  String get recentTransactions => 'സമീപകാല ഇടപാടുകൾ';

  @override
  String get removeAddress => 'വിലാസം നീക്കം ചെയ്യുക';

  @override
  String get rename => 'പേരുമാറ്റുക';

  @override
  String get renameAddress => 'വിലാസത്തിന്റെ പേരുമാറ്റുക';

  @override
  String get reviewSignInPrompt =>
      'ബുക്ക് ചെയ്ത സേവനങ്ങൾ റേറ്റ് ചെയ്യാൻ സൈൻ ഇൻ ചെയ്യുക.';

  @override
  String get saveDraft => 'ഡ്രാഫ്റ്റ് സേവ് ചെയ്യുക';

  @override
  String get selectDateTitle => 'തീയതി തിരഞ്ഞെടുക്കുക';

  @override
  String get selectTime => 'സമയം തിരഞ്ഞെടുക്കുക';

  @override
  String get serviceArea => 'സേവന മേഖല';

  @override
  String get serviceAreaHint => 'ഉദാ. ബെംഗളൂരു നഗരം';

  @override
  String get serviceCategory => 'സേവന വിഭാഗം';

  @override
  String get serviceSignInPrompt =>
      'ഈ സേവനം കാണാൻ മൊബൈൽ നമ്പർ ഉപയോഗിച്ച് സൈൻ ഇൻ ചെയ്യുക.';

  @override
  String get setAsDefault => 'ഡിഫോൾട്ടായി സജ്ജമാക്കുക';

  @override
  String get shareDetailsHint => 'നിങ്ങളുടെ അനുഭവത്തെക്കുറിച്ച് പങ്കിടുക...';

  @override
  String get statement => 'സ്റ്റേറ്റ്മെന്റ്';

  @override
  String get submitApplication => 'അപേക്ഷ സമർപ്പിക്കുക';

  @override
  String get submitReview => 'അവലോകനം സമർപ്പിക്കുക';

  @override
  String get tapChangeToChoose => 'വിലാസം തിരഞ്ഞെടുക്കാൻ മാറ്റുക അമർത്തുക';

  @override
  String get teamSize => 'ടീം വലുപ്പം';

  @override
  String get tellUsAboutBusiness => 'നിങ്ങളുടെ ബിസിനസ്സിനെക്കുറിച്ച് പറയുക';

  @override
  String get todayAtAGlance => 'ഇന്നത്തെ ചുരുക്കം';

  @override
  String get todaysBookings => 'ഇന്നത്തെ ബുക്കിംഗുകൾ';

  @override
  String get todaysEarnings => 'ഇന്നത്തെ വരുമാനം';

  @override
  String get todaysTimeSlots => 'ഇന്നത്തെ സമയ സ്ലോട്ടുകൾ';

  @override
  String get trackSignInPrompt => 'ഓർഡറുകൾ ട്രാക്ക് ചെയ്യാൻ സൈൻ ഇൻ ചെയ്യുക.';

  @override
  String get tradeLicense => 'ട്രേഡ് ലൈസൻസ്';

  @override
  String get tradeLicenseHint =>
      'ട്രേഡ് ലൈസൻസിന്റെ വ്യക്തമായ ഫോട്ടോ അല്ലെങ്കിൽ PDF അപ്‌ലോഡ് ചെയ്യുക';

  @override
  String get typeAMessage => 'സന്ദേശം ടൈപ്പ് ചെയ്യുക...';

  @override
  String get upload => 'അപ്‌ലോഡ്';

  @override
  String get uploadDocuments => 'ആവശ്യമായ രേഖകൾ അപ്‌ലോഡ് ചെയ്യുക';

  @override
  String get uploaded => 'അപ്‌ലോഡ് ചെയ്തു';

  @override
  String get verifiedProvidersBlurb =>
      'പരിശോധിച്ച ദാതാക്കൾക്ക് കൂടുതൽ ബുക്കിംഗുകളും ഉപഭോക്തൃ വിശ്വാസവും ലഭിക്കും.';

  @override
  String get viewOrders => 'ഓർഡറുകൾ കാണുക';

  @override
  String get weekdaysOnly => 'പ്രവൃത്തി ദിവസങ്ങളിൽ മാത്രം';

  @override
  String get whatWentWell => 'എന്താണ് നന്നായത്?';

  @override
  String get withdrawalRequested => 'പിൻവലിക്കൽ അഭ്യർത്ഥിച്ചു';

  @override
  String get withdrawEarnings => 'വരുമാനം പിൻവലിക്കുക';

  @override
  String get yesCancel => 'അതെ, റദ്ദാക്കുക';

  @override
  String get youAreOffline => 'നിങ്ങൾ ഓഫ്‌ലൈനാണ്';

  @override
  String get youAreOnline => 'നിങ്ങൾ ഓൺലൈനാണ്';

  @override
  String get youEarnAfterFee => 'നിങ്ങൾക്ക് ലഭിക്കുന്നത് (12% ഫീസിന് ശേഷം)';

  @override
  String get partnerDashboard => 'പാർട്ണർ ഡാഷ്‌ബോർഡ്';

  @override
  String get linkBankToGetPaid => 'പണം ലഭിക്കാൻ ബാങ്ക് ലിങ്ക് ചെയ്യുക';

  @override
  String get addAccountToTransfer =>
      'നിങ്ങളുടെ വരുമാനം അയയ്ക്കാൻ അക്കൗണ്ട് ചേർക്കുക';

  @override
  String get addBankAccount => 'ബാങ്ക് അക്കൗണ്ട് ചേർക്കുക';

  @override
  String get listServiceOrItem => 'ഒരു സേവനമോ ഇനമോ ലിസ്റ്റ് ചെയ്യുക';

  @override
  String get earningsThisWeek => 'ഈ ആഴ്ചത്തെ വരുമാനം';

  @override
  String get paymentConfirmed => 'പേയ്‌മെന്റ് സ്ഥിരീകരിച്ചു';

  @override
  String get searchVendorsHint => 'വെണ്ടർമാരെയോ സേവനങ്ങളെയോ തിരയുക…';

  @override
  String get email => 'ഇമെയിൽ';

  @override
  String get noSellersYet => 'ഇതുവരെ വിൽപ്പനക്കാരില്ല';

  @override
  String get listingsWillAppear =>
      'വിൽപ്പനക്കാർ പരസ്യങ്ങൾ ഇടുമ്പോൾ ലിസ്റ്റിംഗുകൾ ഇവിടെ കാണാം.';

  @override
  String get tapCardToViewVendor => 'വെണ്ടറെ കാണാൻ കാർഡിൽ ടാപ്പ് ചെയ്യുക';

  @override
  String get verifiedVendor => 'പരിശോധിച്ച വെണ്ടർ';

  @override
  String get aboutThisService => 'ഈ സേവനത്തെക്കുറിച്ച്';

  @override
  String get locationCoverage => 'സ്ഥലവും കവറേജും';

  @override
  String get contactVendor => 'വെണ്ടറുമായി ബന്ധപ്പെടുക';

  @override
  String get excellent => 'മികച്ചത്';

  @override
  String get sampleVendorReview =>
      '\"കുറ്റമറ്റ ജോലിയും വളരെ പ്രൊഫഷണൽ ടീമും. അതേ ആഴ്ച തന്നെ വീണ്ടും ബുക്ക് ചെയ്തു.\" — ലൈല എം.';

  @override
  String get workOrderCaps => 'വർക്ക് ഓർഡർ';

  @override
  String get elkRepairCaps => 'ELK REPAIR';

  @override
  String get pickASlot => 'ഒരു സ്ലോട്ട് തിരഞ്ഞെടുക്കുക';

  @override
  String get cleanPlanCaps => 'ക്ലീൻ പ്ലാൻ';

  @override
  String get elkCleanCaps => 'ELKCLEAN';

  @override
  String get loyalty => 'ലോയൽറ്റി';

  @override
  String get today => 'ഇന്ന്';

  @override
  String get balance => 'ബാലൻസ്';

  @override
  String get partnerAccount => 'പാർട്ണർ അക്കൗണ്ട്';

  @override
  String get forUsers => 'ഉപയോക്താക്കൾക്ക്';

  @override
  String get forSellers => 'വിൽപ്പനക്കാർക്ക്';

  @override
  String get currentlySellerMode => 'ഇപ്പോൾ സെല്ലർ മോഡിൽ';

  @override
  String get currentlyUserMode => 'ഇപ്പോൾ യൂസർ മോഡിൽ';

  @override
  String get switchToSellerPanel => 'സെല്ലർ പാനലിലേക്ക് മാറുക';

  @override
  String get switchToUserPanel => 'യൂസർ പാനലിലേക്ക് മാറുക';

  @override
  String get weekly => 'പ്രതിവാരം';

  @override
  String get monthly => 'പ്രതിമാസം';

  @override
  String get currentLocation => 'നിലവിലെ സ്ഥലം';

  @override
  String get chooseYourLocation => 'നിങ്ങളുടെ സ്ഥലം തിരഞ്ഞെടുക്കുക';

  @override
  String get searchForAddress => 'ഒരു വിലാസം തിരയുക';

  @override
  String get findStreetArea => 'ഏത് തെരുവോ പ്രദേശമോ ലാൻഡ്‌മാർക്കോ കണ്ടെത്തുക';

  @override
  String get useCurrentLocationTitle => 'നിലവിലെ സ്ഥലം ഉപയോഗിക്കുക';

  @override
  String get usesPhoneGps => 'നിങ്ങളുടെ ഫോൺ GPS ഉപയോഗിക്കുന്നു';

  @override
  String get savedAddressesSignIn =>
      'സേവ് ചെയ്ത വിലാസങ്ങൾ ഉപയോഗിക്കാൻ സൈൻ ഇൻ ചെയ്യുക.';

  @override
  String get noSavedAddressesSearch =>
      'ഇതുവരെ സേവ് ചെയ്ത വിലാസങ്ങളില്ല — താഴെ തിരയുക.';

  @override
  String get savedAddressesTitle => 'സേവ് ചെയ്ത വിലാസങ്ങൾ';

  @override
  String get searchAddress => 'വിലാസം തിരയുക';

  @override
  String get streetAreaHint => 'തെരുവ്, പ്രദേശം അല്ലെങ്കിൽ ലാൻഡ്‌മാർക്ക്';

  @override
  String get noMatchingPlaces => 'പൊരുത്തപ്പെടുന്ന സ്ഥലങ്ങളില്ല.';

  @override
  String get startTypingToFind => 'വിലാസം കണ്ടെത്താൻ ടൈപ്പ് ചെയ്യാൻ തുടങ്ങുക.';

  @override
  String get turnOnLocationServices =>
      'ഇത് ഉപയോഗിക്കാൻ ലൊക്കേഷൻ സേവനങ്ങൾ ഓണാക്കുക.';

  @override
  String get locationPermissionNeeded =>
      'നിങ്ങളുടെ വിലാസം കണ്ടെത്താൻ ലൊക്കേഷൻ അനുമതി ആവശ്യമാണ്.';

  @override
  String rateDriver(String driver) {
    return '$driver-നെ റേറ്റ് ചെയ്യുക';
  }

  @override
  String get totalCaps => 'ആകെ';

  @override
  String get locating => 'സ്ഥലം കണ്ടെത്തുന്നു…';

  @override
  String get setPickupLocation => 'പിക്കപ്പ് സ്ഥലം തിരഞ്ഞെടുക്കുക';

  @override
  String get setDropLocation => 'ഡ്രോപ്പ് സ്ഥലം തിരഞ്ഞെടുക്കുക';

  @override
  String get setPickupAndDrop =>
      'ആദ്യം പിക്കപ്പ്, ഡ്രോപ്പ് സ്ഥലങ്ങൾ രണ്ടും തിരഞ്ഞെടുക്കുക.';
}
