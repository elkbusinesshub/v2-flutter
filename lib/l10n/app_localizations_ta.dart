// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'ELK Business Hub';

  @override
  String get commonContinue => 'தொடரவும்';

  @override
  String get commonCancel => 'ரத்து செய்';

  @override
  String get commonDelete => 'நீக்கு';

  @override
  String get deleteListing => 'இந்த பட்டியலை நீக்கவா?';

  @override
  String get pauseListing => 'இடைநிறுத்து';

  @override
  String get resumeListing => 'மீண்டும் தொடங்கு';

  @override
  String get photos => 'புகைப்படங்கள்';

  @override
  String get draftSaved => 'வரைவு சேமிக்கப்பட்டது';

  @override
  String get fillRequiredFields => 'முதலில் வகை, தலைப்பு, விலை நிரப்பவும்.';

  @override
  String get addPhoto => 'புகைப்படம் சேர்';

  @override
  String photosAdded(int count) {
    return '$count சேர்க்கப்பட்டது';
  }

  @override
  String get markCompleted => 'முடிந்ததாகக் குறி';

  @override
  String needAttention(int count) {
    return '$count கவனம் தேவை';
  }

  @override
  String get placeOrder => 'ஆர்டர் செய்';

  @override
  String orderPlaced(String code) {
    return 'ஆர்டர் செய்யப்பட்டது · $code';
  }

  @override
  String get commonRetry => 'மீண்டும் முயற்சி';

  @override
  String get commonSave => 'சேமி';

  @override
  String get commonDone => 'முடிந்தது';

  @override
  String get commonNext => 'அடுத்து';

  @override
  String get commonBack => 'பின்';

  @override
  String get commonClose => 'மூடு';

  @override
  String get commonConfirm => 'உறுதிப்படுத்து';

  @override
  String get commonSkip => 'தவிர்';

  @override
  String get commonSearch => 'தேடு';

  @override
  String get commonSeeAll => 'அனைத்தையும் பார்';

  @override
  String get commonApply => 'பயன்படுத்து';

  @override
  String get commonClear => 'அழி';

  @override
  String get commonRemove => 'அகற்று';

  @override
  String get commonEdit => 'திருத்து';

  @override
  String get commonYes => 'ஆம்';

  @override
  String get commonNo => 'இல்லை';

  @override
  String get commonOk => 'சரி';

  @override
  String get errorGeneric => 'ஏதோ தவறு நடந்தது';

  @override
  String get errorTimeout =>
      'கோரிக்கையின் நேரம் முடிந்தது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get errorNoInternet =>
      'இணைய இணைப்பு இல்லை. உங்கள் நெட்வொர்க்கைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get errorCancelled => 'கோரிக்கை ரத்து செய்யப்பட்டது.';

  @override
  String get errorInsecureConnection =>
      'பாதுகாப்பான இணைப்பை உருவாக்க முடியவில்லை.';

  @override
  String get errorUnknown => 'ஏதோ தவறு நடந்தது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get errorValidation =>
      'நீங்கள் அளித்த தகவலைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get errorSessionExpired =>
      'உங்கள் அமர்வு காலாவதியாகிவிட்டது. மீண்டும் உள்நுழையவும்.';

  @override
  String get errorForbidden => 'அதைச் செய்ய உங்களுக்கு அனுமதி இல்லை.';

  @override
  String get errorNotFound => 'கோரப்பட்ட தகவல் கிடைக்கவில்லை.';

  @override
  String get errorTooManyRequests =>
      'அதிக முயற்சிகள். சிறிது நேரம் கழித்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get errorServer =>
      'எங்கள் தரப்பில் ஏதோ தவறு நடந்தது. பின்னர் முயற்சிக்கவும்.';

  @override
  String get signInRequired =>
      'தொடர உங்கள் மொபைல் எண்ணைக் கொண்டு உள்நுழையவும்.';

  @override
  String get signIn => 'உள்நுழை';

  @override
  String get registerBusinessPrompt =>
      'முன்பதிவுகளைப் பெறத் தொடங்க உங்கள் வணிகத்தைப் பதிவு செய்யுங்கள்.';

  @override
  String get becomeProvider => 'சேவை வழங்குநராகுங்கள்';

  @override
  String get languageTitle => 'உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get languageSubtitle =>
      'அமைப்புகளிலிருந்து இதை எப்போது வேண்டுமானாலும் மாற்றலாம்.';

  @override
  String get languageSaveFailed =>
      'உங்கள் மொழியைச் சேமிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get commonOr => 'அல்லது';

  @override
  String get getStarted => 'தொடங்குங்கள்';

  @override
  String get byContinuingYouAgree => 'தொடர்வதன் மூலம் நீங்கள் எங்கள் ';

  @override
  String get termsAndConditions => 'விதிமுறைகளை ஏற்கிறீர்கள்';

  @override
  String get verified => 'சரிபார்க்கப்பட்டது';

  @override
  String get navHome => 'முகப்பு';

  @override
  String get navBookings => 'முன்பதிவுகள்';

  @override
  String get navWallet => 'வாலட்';

  @override
  String get navProfile => 'சுயவிவரம்';

  @override
  String get onboardServicesTitle => 'உங்கள் அனைத்து சேவைகளும், ஒரே செயலி';

  @override
  String get onboardServicesBody =>
      'உங்கள் நகரத்தின் சரிபார்க்கப்பட்ட வழங்குநர்களிடமிருந்து பயணம், சுத்தம், வாடகை மற்றும் பலவற்றை முன்பதிவு செய்யுங்கள். வேகமானது, நம்பகமானது.';

  @override
  String get onboardTrackingTitle => 'நேரலை கண்காணிப்பு மற்றும் அரட்டை';

  @override
  String get onboardTrackingBody =>
      'வரைபடத்தில் உங்கள் வழங்குநரை நேரலையில் பின்தொடர்ந்து, சுமூகமான அனுபவத்திற்காக அவர்களுடன் நேரடியாக அரட்டையடியுங்கள்.';

  @override
  String get onboardPaymentsTitle =>
      'பாதுகாப்பான கட்டணங்கள் மற்றும் வெகுமதிகள்';

  @override
  String get onboardPaymentsBody =>
      'உங்கள் வாலட், அட்டை அல்லது பணத்தில் பாதுகாப்பாகச் செலுத்தி, ஒவ்வொரு முன்பதிவுக்கும் வெகுமதிப் புள்ளிகளைப் பெறுங்கள்.';

  @override
  String get splashSettingUp => 'உங்கள் நகரம் தயாராகிறது';

  @override
  String get splashFindingPros => 'நம்பகமான நிபுணர்களைத் தேடுகிறோம்';

  @override
  String get splashAlmostThere => 'கிட்டத்தட்ட முடிந்தது';

  @override
  String get authWelcomeBack => 'மீண்டும் வரவேற்கிறோம்';

  @override
  String get authSignInPrompt =>
      'தொடர உங்கள் மொபைல் எண்ணைக் கொண்டு உள்நுழையவும்';

  @override
  String get authMobileNumber => 'மொபைல் எண்';

  @override
  String get authSendOtp => 'OTP அனுப்பு';

  @override
  String get authContinueAsGuest => 'விருந்தினராகத் தொடரவும்';

  @override
  String get authVerifyTitle => 'உங்கள் எண்ணைச் சரிபார்க்கவும்';

  @override
  String get authOtpSentTo => '6 இலக்கக் குறியீட்டை அனுப்பியுள்ளோம் ';

  @override
  String get authVerifyContinue => 'சரிபார்த்துத் தொடரவும்';

  @override
  String get authResendCode => 'குறியீட்டை மீண்டும் அனுப்பு';

  @override
  String authResendIn(String seconds) {
    return '00:$seconds இல் குறியீடு மீண்டும் அனுப்பப்படும்';
  }

  @override
  String get homeBestSellersTag => 'சிறந்த விற்பனையாளர்கள்';

  @override
  String get homeBestSellersRest => 'உங்களுக்கு அருகில்';

  @override
  String get homeBestSellersSub =>
      'அதிகம் சேமிக்கப்பட்ட மற்றும் பார்க்கப்பட்ட பட்டியல்கள்';

  @override
  String get homeDealsTag => 'சலுகைகள்';

  @override
  String get homeDealsRest => 'உங்களுக்காக';

  @override
  String get homeDealsSub =>
      'உங்கள் அருகிலுள்ள விற்பனையாளர்களிடமிருந்து மேலும்';

  @override
  String get homeServiceAt => 'சேவை இங்கே';

  @override
  String get homeSelectLocation => 'இடத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get homeServices => 'சேவைகள்';

  @override
  String get homeBadgeFast => 'வேகம்';

  @override
  String get homeBadgeNew => 'புதியது';

  @override
  String get homeBadgeTwentyOff => '20% தள்ளுபடி';

  @override
  String get homeNoSellerAds => 'இன்னும் விற்பனையாளர் விளம்பரங்கள் இல்லை';

  @override
  String get homeMoreListingsSoon =>
      'விற்பனையாளர்கள் பதிவிடும்போது மேலும் பட்டியல்கள் இங்கே தோன்றும்.';

  @override
  String get promoFirstBookingTitle =>
      'உங்கள் முதல் முன்பதிவுக்கு\n20% தள்ளுபடி';

  @override
  String get promoFirstBookingBody =>
      'புதிய உறுப்பினர்களுக்கு அனைத்து சேவைகளிலும் சிறப்புத் தள்ளுபடி.';

  @override
  String get promoClaimOffer => 'சலுகையைப் பெறு';

  @override
  String get promoFreeRidesTitle => 'ஒவ்வொரு வாரமும்\nஇலவசப் பயணம்';

  @override
  String get promoFreeRidesBody =>
      'உறுப்பினர்களுக்கு வாராந்திர சலுகைகள், முன்னுரிமை ஆதரவு மற்றும் குறைந்த கட்டணம்.';

  @override
  String get promoJoinNow => 'இப்போது சேருங்கள்';

  @override
  String get profileSignOut => 'வெளியேறு';

  @override
  String get profileSignOutConfirm => 'நிச்சயமாக வெளியேற விரும்புகிறீர்களா?';

  @override
  String get profileUpdated => 'சுயவிவரம் புதுப்பிக்கப்பட்டது';

  @override
  String get profileEdit => 'சுயவிவரத்தைத் திருத்து';

  @override
  String get profileRewardPoints => 'வெகுமதிப் புள்ளிகள்';

  @override
  String get profileRating => 'மதிப்பீடு';

  @override
  String get profileMyAccount => 'என் கணக்கு';

  @override
  String get profileOffersRewards => 'சலுகைகள் & வெகுமதிகள்';

  @override
  String get profileNotifications => 'அறிவிப்புகள்';

  @override
  String get profileSavedAddresses => 'சேமித்த முகவரிகள்';

  @override
  String get profileLanguage => 'மொழி';

  @override
  String get profileRateService => 'சேவையை மதிப்பிடு';

  @override
  String get profileProviderTools => 'வழங்குநர் கருவிகள்';

  @override
  String get profileProviderDashboard => 'வழங்குநர் டாஷ்போர்டு';

  @override
  String get profileSupport => 'ஆதரவு';

  @override
  String get profileHelpSupport => 'உதவி & ஆதரவு';

  @override
  String get profileAbout => 'ELK Business Hub பற்றி';

  @override
  String get profileTermsPrivacy => 'விதிமுறைகள் & தனியுரிமைக் கொள்கை';

  @override
  String get profileGuestTitle => 'நீங்கள் விருந்தினராக உலாவுகிறீர்கள்';

  @override
  String get profileGuestBody =>
      'உங்கள் சுயவிவரம், முன்பதிவுகள், வெகுமதிகளைக் காண மொபைல் எண்ணைக் கொண்டு உள்நுழையவும்.';

  @override
  String get profileNameRequired => 'உங்கள் பெயரை உள்ளிடவும்.';

  @override
  String get profileNameTooLong =>
      'பெயர் 100 எழுத்துகளுக்கு மிகாமல் இருக்க வேண்டும்.';

  @override
  String get profileEmailInvalid => 'சரியான மின்னஞ்சல் முகவரியை உள்ளிடவும்.';

  @override
  String get profileNameLabel => 'பெயர்';

  @override
  String get profileEmailLabel => 'மின்னஞ்சல் (விருப்பம்)';

  @override
  String get walletToppedUp => 'வாலட்டில் பணம் சேர்க்கப்பட்டது';

  @override
  String get walletWithdrawSuccess => 'பணம் எடுப்பு வெற்றி';

  @override
  String get walletStillLoading =>
      'வாலட் ஏற்றப்படுகிறது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get walletAddMoneyTitle => 'வாலட்டில் பணம் சேர்';

  @override
  String get walletWithdrawTitle => 'வங்கிக்கு எடு';

  @override
  String get walletAddMoney => 'பணம் சேர்';

  @override
  String get walletWithdraw => 'எடு';

  @override
  String get walletAmountTooSmall => '0 ஐ விட அதிக தொகையை உள்ளிடவும்';

  @override
  String get walletAmountTooLarge => 'தொகை ₹1,000,000 ஐ மிஞ்சக்கூடாது';

  @override
  String get walletSignInPrompt =>
      'உங்கள் ELK வாலட் மற்றும் வெகுமதிப் புள்ளிகளைப் பயன்படுத்த உள்நுழையவும்.';

  @override
  String get walletAvailableBalance => 'கிடைக்கும் இருப்பு';

  @override
  String get walletTransactionHistory => 'பரிவர்த்தனை வரலாறு';

  @override
  String get statusConfirmed => 'உறுதி';

  @override
  String get statusPendingVendor => 'விற்பனையாளர் நிலுவை';

  @override
  String get statusCompleted => 'முடிந்தது';

  @override
  String get statusCancelled => 'ரத்து';

  @override
  String get statusUnknown => 'தெரியவில்லை';

  @override
  String get myBookingsTitle => 'என் முன்பதிவுகள்';

  @override
  String get bookingsSignInPrompt =>
      'நீங்கள் முன்பதிவு செய்த சேவைகளைக் காண உள்நுழையவும்.';

  @override
  String get tabUpcoming => 'வரவிருப்பவை';

  @override
  String get emptyUpcomingTitle => 'வரவிருக்கும் முன்பதிவுகள் இல்லை';

  @override
  String get emptyUpcomingBody =>
      'ஒரு சேவையை முன்பதிவு செய்யுங்கள், அது இங்கே தோன்றும்.';

  @override
  String get emptyCompletedTitle => 'இதுவரை எதுவும் முடியவில்லை';

  @override
  String get emptyCompletedBody => 'முடிந்த முன்பதிவுகள் இங்கே தோன்றும்.';

  @override
  String get emptyCancelledTitle => 'ரத்து செய்யப்பட்ட முன்பதிவுகள் இல்லை';

  @override
  String get emptyCancelledBody => 'ரத்துகள் இங்கே பட்டியலிடப்படும்.';

  @override
  String get bookingDetailsTitle => 'முன்பதிவு விவரங்கள்';

  @override
  String get sectionStatus => 'நிலை';

  @override
  String get sectionScheduleAddress => 'நேரம் & முகவரி';

  @override
  String get labelDateTime => 'தேதி & நேரம்';

  @override
  String get labelServiceAddress => 'சேவை முகவரி';

  @override
  String get sectionVendor => 'விற்பனையாளர்';

  @override
  String get vendorContactUnavailable =>
      'விற்பனையாளர் தொடர்பு இன்னும் கிடைக்கவில்லை';

  @override
  String get callAction => 'அழை';

  @override
  String get sectionPayment => 'கட்டணம்';

  @override
  String get lineService => 'சேவை';

  @override
  String get totalPaid => 'மொத்தம் செலுத்தியது';

  @override
  String get totalCancelled => 'மொத்தம் (ரத்து)';

  @override
  String get bookingId => 'முன்பதிவு ஐடி';

  @override
  String get copyAction => 'நகலெடு';

  @override
  String get cancelIsFreeNote =>
      'வரவிருக்கும் முன்பதிவை ரத்து செய்வது இலவசம், உங்கள் நேரம் உடனே விடுவிக்கப்படும்.';

  @override
  String get rebookThisService => 'இந்தச் சேவையை மீண்டும் முன்பதிவு செய்';

  @override
  String get ratedStar => 'மதிப்பிட்டது ★';

  @override
  String get rateAction => 'மதிப்பிடு';

  @override
  String get rebookAction => 'மீண்டும் முன்பதிவு';

  @override
  String get trackOrder => 'ஆர்டரைக் கண்காணி';

  @override
  String get cancelling => 'ரத்து செய்யப்படுகிறது…';

  @override
  String get cancelBooking => 'முன்பதிவை ரத்து செய்';

  @override
  String get cancelBookingQuestion => 'இந்த முன்பதிவை ரத்து செய்யவா?';

  @override
  String get whyCancelling => 'ஏன் ரத்து செய்கிறீர்கள்?';

  @override
  String get cancelReasonPlans => 'திட்டம் மாறியது';

  @override
  String get cancelReasonAlternative => 'வேறு வழி கிடைத்தது';

  @override
  String get cancelReasonWrongTime => 'தவறான தேதி/நேரம்';

  @override
  String get cancelReasonExpensive => 'மிகவும் விலை உயர்ந்தது';

  @override
  String get cancelReasonOther => 'மற்றவை';

  @override
  String get cancellingIsFreePrefix => 'ரத்து செய்வது இலவசம் — ';

  @override
  String get cancellingIsFreeSuffix => ' இந்த முன்பதிவுக்கு வசூலிக்கப்படாது.';

  @override
  String get keepBooking => 'முன்பதிவை வைத்திரு';

  @override
  String get rebookHint =>
      'சேவைகள் தாவலிலிருந்து சேவையை மீண்டும் தேர்ந்தெடுக்கவும்';

  @override
  String get copiedBookingId => 'முன்பதிவு ஐடி நகலெடுக்கப்பட்டது';

  @override
  String get cancelledNothingCharged => 'ரத்து — எதுவும் வசூலிக்கப்படவில்லை';

  @override
  String get viewDetails => 'விவரங்களைப் பார்';

  @override
  String get bookingCancelledToast => 'முன்பதிவு ரத்து செய்யப்பட்டது';

  @override
  String get timelineBooked => 'முன்பதிவு';

  @override
  String get timelineBookedSub => 'ஆர்டர் செய்யப்பட்டது';

  @override
  String get timelineConfirmedSub => 'விற்பனையாளர் ஏற்றார்';

  @override
  String get timelineInProgress => 'நடைபெறுகிறது';

  @override
  String get timelineInProgressSub => 'அந்த நாளில்';

  @override
  String get timelineCompletedSub => 'சேவை முடிந்தது';

  @override
  String get timelineRefundIssued =>
      'பணம் ELK வாலட்டுக்குத் திரும்ப அளிக்கப்பட்டது';

  @override
  String get bookingNotScheduled => 'நேரம் நிர்ணயிக்கப்படவில்லை';

  @override
  String get dateToday => 'இன்று';

  @override
  String get dateTomorrow => 'நாளை';

  @override
  String get dateYesterday => 'நேற்று';

  @override
  String walletRewardPoints(int points) {
    return '$points வெகுமதிப் புள்ளிகள்';
  }

  @override
  String vendorSpecialist(String service) {
    return '$service நிபுணர்';
  }

  @override
  String get svcTaxiRides => 'டாக்சி & பயணம்';

  @override
  String get svcCleaning => 'சுத்தம்';

  @override
  String get svcCarRental => 'கார் வாடகை';

  @override
  String get svcRepair => 'பழுதுபார்ப்பு';

  @override
  String get svcPorterMovers => 'போர்ட்டர் & மூவர்ஸ்';

  @override
  String get svcEconomyTaxi => 'எக்கானமி டாக்சி';

  @override
  String get svcPremiumTaxi => 'பிரீமியம் டாக்சி';

  @override
  String get svcAuto => 'ஆட்டோ';

  @override
  String get svcXlVan => 'XL வேன்';

  @override
  String get svcPgStay => 'பிஜி தங்குமிடம்';

  @override
  String get svcMensHostel => 'ஆண்கள் விடுதி';

  @override
  String get svcWomensHostel => 'பெண்கள் விடுதி';

  @override
  String get svcHomestay => 'ஹோம்ஸ்டே';

  @override
  String get svcHomeCleaning => 'வீட்டு சுத்தம்';

  @override
  String get svcDeepCleaning => 'ஆழ்ந்த சுத்தம்';

  @override
  String get svcSofaUpholstery => 'சோஃபா & மெத்தை';

  @override
  String get svcKitchenCleaning => 'சமையலறை சுத்தம்';

  @override
  String get svcBathroomCleaning => 'குளியலறை சுத்தம்';

  @override
  String get svcCarpetRug => 'கம்பளம் & விரிப்பு';

  @override
  String get svcLaundryIron => 'சலவை & இஸ்திரி';

  @override
  String get svcWashFold => 'கழுவி மடி';

  @override
  String get svcWaterTank => 'தண்ணீர் தொட்டி';

  @override
  String get svcSedan => 'செடான்';

  @override
  String get svcSuv => 'எஸ்யூவி';

  @override
  String get svcLuxury => 'சொகுசு';

  @override
  String get svcVan => 'வேன்';

  @override
  String get svcAcCooling => 'ஏசி & குளிரூட்டல்';

  @override
  String get svcPlumbing => 'குழாய் பணி';

  @override
  String get svcElectrical => 'மின் வேலை';

  @override
  String get svcCarpentry => 'தச்சு வேலை';

  @override
  String get svcPainting => 'வண்ணம் பூசுதல்';

  @override
  String get svcHandyman => 'கைவினைஞர்';

  @override
  String get svcBikeDelivery => 'பைக் டெலிவரி';

  @override
  String get svcMiniTruck => 'மினி டிரக்';

  @override
  String get svcHouseShifting => 'வீடு மாற்றம்';

  @override
  String get svcMoversPackers => 'மூவர்ஸ் & பேக்கர்ஸ்';

  @override
  String get svcSearchHint => 'சேவைகளைத் தேடு… (எ.கா. ஏசி, டாக்சி)';

  @override
  String get rideBlurbAuto => 'மலிவான ஆட்டோ பயணம்';

  @override
  String get rideBlurbEconomy => 'தினசரி மலிவான கார்கள்';

  @override
  String get rideBlurbPremium => 'சிறந்த பிரீமியம் கார்கள்';

  @override
  String get rideBlurbXl => 'குடும்பம், குழு & பெரிய பைகளுக்கு';

  @override
  String get rideBlurbAutoShort => 'மலிவான ரிக்ஷா பயணம்';

  @override
  String get rideBlurbEconomyShort => 'தினசரி மலிவான பயணம்';

  @override
  String get rideBlurbPremiumShort => 'கூடுதல் இடம், சிறந்த ஓட்டுநர்கள்';

  @override
  String get taxiSignInPrompt =>
      'பயணத்தை முன்பதிவு செய்ய மொபைல் எண்ணைக் கொண்டு உள்நுழையவும்.';

  @override
  String get taxiBookARide => 'பயணத்தை முன்பதிவு செய்';

  @override
  String get taxiChooseRide => 'உங்கள் பயணத்தைத் தேர்ந்தெடுங்கள்';

  @override
  String get taxiPickup => 'பிக்அப்';

  @override
  String get taxiDropoff => 'இறங்கும் இடம்';

  @override
  String get sortRecommended => 'பரிந்துரைக்கப்பட்டது';

  @override
  String get sortFaster => 'வேகமானது';

  @override
  String get sortCheaper => 'மலிவானது';

  @override
  String get payCash => 'ரொக்கம்';

  @override
  String get payCard => 'கிரெடிட் / டெபிட் கார்டு';

  @override
  String get payElkWallet => 'ELK வாலட்';

  @override
  String get payApplePay => 'Apple Pay';

  @override
  String get payApplePayGooglePay => 'Apple Pay / Google Pay';

  @override
  String get payCashSub => 'வந்தவுடன் ஓட்டுநருக்குச் செலுத்த உறுதிப்படுத்தவும்';

  @override
  String get payCardSub => 'விசா, மாஸ்டர்கார்டு மற்றும் பல';

  @override
  String get payWalletSub => 'உங்கள் ELK வாலட் இருப்பிலிருந்து செலுத்துங்கள்';

  @override
  String get payApplePaySub => 'வேகமான & பாதுகாப்பான செக்அவுட்';

  @override
  String get changeAction => 'மாற்று';

  @override
  String get bookPrefix => 'முன்பதிவு ';

  @override
  String get fare => 'கட்டணம்';

  @override
  String get cancellationFee => 'ரத்து கட்டணம்';

  @override
  String get seats => 'இருக்கைகள்';

  @override
  String get fareEstimateNote =>
      'மொத்தக் கட்டணம் தூரம் மற்றும் நேரத்தின் அடிப்படையிலான மதிப்பீடு. செக்அவுட்டில் கூடுதல் கட்டணம், உச்ச விலை அல்லது சுங்கம் சேர்க்கப்படலாம்.';

  @override
  String get choosePickupLocation => 'பிக்அப் இடத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get chooseDropoffLocation => 'இறங்கும் இடத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get fareBase => 'அடிப்படைக் கட்டணம்';

  @override
  String get fareBookingFee => 'முன்பதிவுக் கட்டணம்';

  @override
  String get assigningDriver => 'ஓட்டுநர் நியமிக்கப்படுகிறார்…';

  @override
  String get detailsOnTheWay => 'விவரங்கள் வருகின்றன';

  @override
  String get couldNotBookRide => 'பயணத்தை முன்பதிவு செய்ய முடியவில்லை.';

  @override
  String get findingDriver => 'ஓட்டுநரைத் தேடுகிறோம்';

  @override
  String get lookingForDrivers => 'அருகிலுள்ள ஓட்டுநர்களைத் தேடுகிறோம்';

  @override
  String get driverAssigned => 'ஓட்டுநர் நியமிக்கப்பட்டார்';

  @override
  String get completePaymentNote =>
      'முன்பதிவை உறுதிப்படுத்த கட்டணத்தை முடிக்கவும். உடனே பயண OTP வழங்கப்படும்.';

  @override
  String get proceedToPayment => 'கட்டணத்திற்குச் செல்';

  @override
  String get amountDue => 'செலுத்த வேண்டிய தொகை';

  @override
  String get total => 'மொத்தம்';

  @override
  String get selectPaymentMethod => 'கட்டண முறையைத் தேர்ந்தெடுக்கவும்';

  @override
  String get paymentsSecured =>
      'கட்டணங்கள் 256-பிட் குறியாக்கத்தால் பாதுகாக்கப்படுகின்றன';

  @override
  String get cardYourName => 'உங்கள் பெயர்';

  @override
  String get cardDetails => 'அட்டை விவரங்கள்';

  @override
  String get cardHolder => 'அட்டை வைத்திருப்பவர்';

  @override
  String get cardExpires => 'காலாவதி';

  @override
  String get cardNumber => 'அட்டை எண்';

  @override
  String get cardExpiry => 'காலாவதி';

  @override
  String get cardCvv => 'சிவிவி';

  @override
  String get cardholderName => 'அட்டைதாரர் பெயர்';

  @override
  String get cardAsShown => 'அட்டையில் உள்ளது போல';

  @override
  String get saveCardForFuture => 'எதிர்கால கட்டணங்களுக்கு அட்டையைச் சேமி';

  @override
  String get otpBeingPrepared => 'உங்கள் OTP தயாராகிறது';

  @override
  String get driverOnTheWay => 'ஓட்டுநர் வழியில்';

  @override
  String get shareOtpToStart => 'பயணத்தைத் தொடங்க இந்த OTP-ஐப் பகிரவும்';

  @override
  String get safety => 'பாதுகாப்பு';

  @override
  String get shareTrip => 'பயணத்தைப் பகிர்';

  @override
  String get driverArrivedStartTrip => 'ஓட்டுநர் வந்தார் · பயணத்தைத் தொடங்கு';

  @override
  String get couldNotStartTrip => 'பயணத்தைத் தொடங்க முடியவில்லை.';

  @override
  String get tripInProgress => 'பயணம் நடைபெறுகிறது';

  @override
  String get headingTo => 'செல்லும் இடம்';

  @override
  String get completeTrip => 'பயணத்தை முடி';

  @override
  String get couldNotCompleteTrip => 'பயணத்தை முடிக்க முடியவில்லை.';

  @override
  String get distance => 'தூரம்';

  @override
  String get duration => 'கால அளவு';

  @override
  String get farePaid => 'கட்டணம் · செலுத்தப்பட்டது';

  @override
  String get addATip => 'டிப் சேர்';

  @override
  String get noTip => 'டிப் இல்லை';

  @override
  String get finishTrip => 'பயணத்தை முடி';

  @override
  String get couldNotSubmitRating =>
      'உங்கள் மதிப்பீட்டைச் சமர்ப்பிக்க முடியவில்லை.';

  @override
  String get allDoneThanks => 'முடிந்தது — பயணத்திற்கு நன்றி!';

  @override
  String get trip => 'பயணம்';

  @override
  String get driver => 'ஓட்டுநர்';

  @override
  String get tip => 'டிப்';

  @override
  String get transactionId => 'பரிவர்த்தனை ஐடி';

  @override
  String get receiptDownloaded => 'ரசீது பதிவிறக்கப்பட்டது';

  @override
  String get download => 'பதிவிறக்கு';

  @override
  String get bookAnotherTrip => 'மற்றொரு பயணத்தை முன்பதிவு செய்';

  @override
  String svcNoMatch(String query) {
    return '\"$query\" உடன் சேவைகள் எதுவும் பொருந்தவில்லை.\n\"ஏசி\", \"டாக்சி\" அல்லது \"சுத்தம்\" முயற்சிக்கவும்.';
  }

  @override
  String rideSeats(int seats) {
    return '$seats இருக்கைகள்';
  }

  @override
  String fareDistance(String km) {
    return 'தூரம் ($km கி.மீ)';
  }

  @override
  String fareTime(int minutes) {
    return 'நேரம் ($minutes நிமிடம்)';
  }

  @override
  String tipWillBeCharged(String amount, String method) {
    return '$amount உங்கள் $method இலிருந்து வசூலிக்கப்படும்';
  }

  @override
  String totalVia(String method) {
    return '$method வழியாக மொத்தம்';
  }

  @override
  String get addServiceAddress => 'சேவை முகவரியைச் சேர்';

  @override
  String get cleanSignInPrompt =>
      'சுத்தம் சேவைகளை முன்பதிவு செய்ய மொபைல் எண்ணைக் கொண்டு உள்நுழையவும்.';

  @override
  String get topOffers => 'சிறந்த சலுகைகள்';

  @override
  String get goodAfternoon => 'வணக்கம்';

  @override
  String get cleanSearchHint => '\"டீப் கிளீன்\", \"தொட்டி\" தேடு…';

  @override
  String get playUnlockDeals => 'விளையாடி கோடை சலுகைகளைப் பெறுங்கள்!';

  @override
  String get getWaterTankCleaning => 'தண்ணீர் தொட்டி சுத்தம் பெறுங்கள் ';

  @override
  String get whatNeedsCleaning => 'எதைச் சுத்தம் செய்ய வேண்டும்?';

  @override
  String get codeLabel => 'குறியீடு: ';

  @override
  String get ecoFriendlyProducts =>
      'சுற்றுச்சூழல் நட்பு, குழந்தைகளுக்குப் பாதுகாப்பான பொருட்கள்';

  @override
  String get trainedCleaners =>
      'பயிற்சி பெற்ற சீருடை அணிந்த சுத்தம் செய்பவர்கள்';

  @override
  String get fromLabel => 'முதல்';

  @override
  String get howWeDoIt => 'நாங்கள் எப்படிச் செய்கிறோம்';

  @override
  String get hygieneAfterService => 'சேவைக்குப் பிந்தைய சுகாதார நிலை';

  @override
  String get beforeLabel => 'முன்';

  @override
  String get afterLabTested => 'பின் · ஆய்வக சோதனை';

  @override
  String get elkCleanCrew => 'ELKclean குழு';

  @override
  String get crewBlurb =>
      'சீருடை · சுற்றுச்சூழல் கிட் · 1,200+ சுத்தங்களில் 4.9';

  @override
  String get priceCaps => 'விலை';

  @override
  String get yourCleanPlan => 'உங்கள் சுத்தத் திட்டம்';

  @override
  String get addPromoCode => 'புரோமோ குறியீட்டைச் சேர்';

  @override
  String get subtotal => 'துணை மொத்தம்';

  @override
  String get ecoSuppliesSetup => 'சுற்றுச்சூழல் பொருட்கள் & அமைப்பு';

  @override
  String get selectDate => 'தேதியைத் தேர்ந்தெடு';

  @override
  String get arrivalWindow => 'வரும் நேரம்';

  @override
  String get fillsFast => 'விரைவில் நிரம்பும்';

  @override
  String get available => 'கிடைக்கிறது';

  @override
  String get crewArrivalNote =>
      'உங்கள் குழு 2 மணி நேர இடைவெளியில் அனைத்துப் பொருட்களுடன் வரும். அன்று நேரலைக் கண்காணிப்பு இணைப்பு அனுப்பப்படும்.';

  @override
  String get serviceAddress => 'சேவை முகவரி';

  @override
  String get savedPlaces => 'சேமித்த இடங்கள்';

  @override
  String get noSavedAddresses =>
      'இதுவரை சேமித்த முகவரிகள் இல்லை — கீழே சேர்க்கவும்.';

  @override
  String get addNewAddress => 'புதிய முகவரியைச் சேர்';

  @override
  String get addServiceAddressFirst => 'முதலில் சேவை முகவரியைச் சேர்க்கவும்.';

  @override
  String get reviewConfirm => 'மதிப்பாய்வு & உறுதி';

  @override
  String get whenLabel => 'எப்போது';

  @override
  String get whereLabel => 'எங்கே';

  @override
  String get contactLabel => 'தொடர்பு';

  @override
  String get verifiedAccount => 'சரிபார்க்கப்பட்ட கணக்கு';

  @override
  String get orderSummary => 'ஆர்டர் சுருக்கம்';

  @override
  String get totalToPay => 'செலுத்த வேண்டிய மொத்தம்';

  @override
  String get recleanGuarantee =>
      'திருப்தி இல்லையா? 48 மணி நேரத்தில் இலவசமாக மீண்டும் சுத்தம் செய்வோம். 2 மணி நேரம் முன்பு வரை இலவச ரத்து.';

  @override
  String get payCardBrands => 'விசா, மாஸ்டர்கார்டு, அமெக்ஸ்';

  @override
  String get payOneTapCheckout => 'ஒரு தட்டில் பாதுகாப்பான செக்அவுட்';

  @override
  String get chooseMethod => 'முறையைத் தேர்ந்தெடு';

  @override
  String get nameOnCard => 'அட்டையில் உள்ள பெயர்';

  @override
  String get saveCardFasterCheckout => 'விரைவான செக்அவுட்டுக்கு அட்டையைச் சேமி';

  @override
  String get processing => 'செயலாக்கப்படுகிறது…';

  @override
  String get paymentFailed => 'கட்டணம் தோல்வி. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get paidLabel => 'செலுத்தப்பட்டது';

  @override
  String get paidCaps => 'செலுத்தப்பட்டது';

  @override
  String get trackMyClean => 'என் சுத்தத்தைக் கண்காணி';

  @override
  String get noServicesYet => 'இதுவரை சேவைகள் இல்லை';

  @override
  String get browseCleaningBlurb =>
      'சுத்தம் சேவைகளைப் பார்த்து உங்கள் திட்டத்தை உருவாக்குங்கள்.';

  @override
  String get browseServices => 'சேவைகளைப் பார்';

  @override
  String paySecurely(String amount) {
    return '$amount பாதுகாப்பாகச் செலுத்து';
  }

  @override
  String servicesAdded(int count) {
    return '$count சேவைகள் சேர்க்கப்பட்டன';
  }

  @override
  String get repairSignInPrompt =>
      'பழுதுபார்ப்பை முன்பதிவு செய்ய மொபைல் எண்ணைக் கொண்டு உள்நுழையவும்.';

  @override
  String get repairSearchHint => '\"ஏசி சேவை\", \"கசிவு\" தேடு…';

  @override
  String get summerReady => 'கோடைக்குத் தயார்';

  @override
  String get whatNeedsFixing => 'எதைச் சரிசெய்ய வேண்டும்?';

  @override
  String get whatsIncluded => 'என்ன அடங்கும்';

  @override
  String get topRatedCrew => 'சிறந்த மதிப்பீட்டுக் குழு';

  @override
  String get techCrewBlurb =>
      'முன்பதிவுக்குப் பின் நியமிக்கப்படும் · 800+ வேலைகளில் சராசரி 4.9';

  @override
  String get yourWorkOrder => 'உங்கள் பணி ஆணை';

  @override
  String get visitInspectionFee => 'வருகை & ஆய்வுக் கட்டணம்';

  @override
  String get techArrivalNote =>
      'உங்கள் தொழில்நுட்பர் 2 மணி நேர இடைவெளியில் வருவார். அன்று நேரலைக் கண்காணிப்பு இணைப்பு கிடைக்கும்.';

  @override
  String get chargedAfterComplete =>
      'வேலை முடிந்ததாக உறுதிசெய்யப்பட்ட பின்னரே கட்டணம். 2 மணி நேரம் முன்பு வரை இலவச ரத்து.';

  @override
  String get trackMyBooking => 'என் முன்பதிவைக் கண்காணி';

  @override
  String get browseTradesBlurb =>
      'சேவைகளைப் பார்த்து சரிசெய்ய வேண்டியதைச் சேர்க்கவும்.';

  @override
  String get rentalSignInPrompt =>
      'கார் வாடகைக்கு மொபைல் எண்ணைக் கொண்டு உள்நுழையவும்.';

  @override
  String get carsAvailable => 'கார்கள் கிடைக்கின்றன';

  @override
  String get sortPrice => 'வரிசை: விலை';

  @override
  String get noCarsInCategory => 'இந்தப் பிரிவில் இப்போது கார்கள் இல்லை.';

  @override
  String get bookNow => 'இப்போது முன்பதிவு செய்';

  @override
  String get porterSignInPrompt =>
      'பொருள் அனுப்ப மொபைல் எண்ணைக் கொண்டு உள்நுழையவும்.';

  @override
  String get selectVehicle => 'வாகனத்தைத் தேர்ந்தெடு';

  @override
  String get pricingUpdates => 'உங்கள் தேர்வுக்கேற்ப விலை மாறும்';

  @override
  String get addOns => 'கூடுதல் சேவைகள்';

  @override
  String get porterLogistics => 'போர்ட்டர் & லாஜிஸ்டிக்ஸ்';

  @override
  String get pickupLocation => 'பிக்அப் இடம்';

  @override
  String get dropLocation => 'இறங்கும் இடம்';

  @override
  String get packageType => 'பொருள் வகை';

  @override
  String get packageElectronics => 'மின்னணுப் பொருட்கள்';

  @override
  String get weight => 'எடை';

  @override
  String get estimatedTime => 'மதிப்பிடப்பட்ட நேரம்';

  @override
  String get estimatedFare => 'மதிப்பிடப்பட்ட கட்டணம்';

  @override
  String get bookPorter => 'போர்ட்டரை முன்பதிவு செய்';

  @override
  String get couldNotBookDelivery => 'டெலிவரியை முன்பதிவு செய்ய முடியவில்லை.';

  @override
  String get stepSchedule => 'நேரம்';

  @override
  String get pickUpNow => 'இப்போது பிக்அப்';

  @override
  String get scheduleForLater => 'பின்னர் திட்டமிடு';

  @override
  String get pickupDate => 'பிக்அப் தேதி';

  @override
  String get selectDateAction => 'தேதியைத் தேர்ந்தெடு';

  @override
  String get pickupWindow => 'பிக்அப் நேரம்';

  @override
  String get estTime => 'மதி. நேரம்';

  @override
  String get continueToPayment => 'கட்டணத்திற்குத் தொடரவும்';

  @override
  String get payCardBrandsShort => 'விசா, மாஸ்டர்கார்டு';

  @override
  String get payCashOnDelivery => 'டெலிவரியில் ரொக்கம்';

  @override
  String get deliveryFare => 'டெலிவரி கட்டணம்';

  @override
  String get serviceFee => 'சேவைக் கட்டணம்';

  @override
  String get gstFivePercent => 'ஜிஎஸ்டி (5%)';

  @override
  String get continueToCardDetails => 'அட்டை விவரங்களுக்குத் தொடரவும்';

  @override
  String get amount => 'தொகை';

  @override
  String get confirmAndPay => 'உறுதிசெய்து செலுத்து';

  @override
  String get completeCardDetails => 'அனைத்து அட்டை விவரங்களையும் நிரப்பவும்';

  @override
  String get paymentsSecuredByElk =>
      'கட்டணங்கள் ELK கேட்வே மூலம் பாதுகாக்கப்படுகின்றன';

  @override
  String get processingPayment => 'கட்டணம் செயலாக்கப்படுகிறது';

  @override
  String get confirmingWithBank =>
      'உங்கள் வங்கியுடன் உறுதிசெய்யப்படுகிறது, இந்தத் திரையை மூடாதீர்கள்';

  @override
  String get bookingConfirmed => 'முன்பதிவு உறுதி';

  @override
  String get porterNotified => 'உங்கள் போர்ட்டருக்குத் தெரிவிக்கப்பட்டது';

  @override
  String get trackingId => 'கண்காணிப்பு ஐடி';

  @override
  String get vehicle => 'வாகனம்';

  @override
  String get arrival => 'வருகை';

  @override
  String get amountPaid => 'செலுத்திய தொகை';

  @override
  String get receiptSentToEmail => 'ரசீது உங்கள் மின்னஞ்சலுக்கு அனுப்பப்பட்டது';

  @override
  String get viewReceipt => 'ரசீதைப் பார் →';

  @override
  String get stepTripDetails => 'பயண விவரங்கள்';

  @override
  String get stepPickupDelivery => 'பிக்அப் & டெலிவரி';

  @override
  String get stepExtrasProtection => 'கூடுதல் & பாதுகாப்பு';

  @override
  String get stepLocation => 'இடம்';

  @override
  String get stepExtras => 'கூடுதல்';

  @override
  String get stepReview => 'மதிப்பாய்வு';

  @override
  String get stepPay => 'செலுத்து';

  @override
  String get yourAccount => 'உங்கள் கணக்கு';

  @override
  String get branch => 'கிளை';

  @override
  String get securedByElkPay =>
      'ELK Pay மூலம் பாதுகாப்பு · 256-பிட் குறியாக்கம்';

  @override
  String get totalSoFar => 'இதுவரை மொத்தம்';

  @override
  String get whenDoYouNeedIt => 'உங்களுக்கு எப்போது வேண்டும்?';

  @override
  String get pickPlanAndDates =>
      'உங்கள் வாடகைத் திட்டம் மற்றும் பயணத் தேதிகளைத் தேர்ந்தெடுங்கள்';

  @override
  String get rateDaily => 'தினசரி';

  @override
  String get rateWeekly => 'வாராந்திரம் · 15% தள்ளுபடி';

  @override
  String get rateMonthly => 'மாதாந்திரம் · 30% தள்ளுபடி';

  @override
  String get pickupDateTime => 'பிக்அப் தேதி & நேரம்';

  @override
  String get whenRentalBegins => 'உங்கள் வாடகை எப்போது தொடங்குகிறது';

  @override
  String get returnDateTime => 'திரும்பும் தேதி & நேரம்';

  @override
  String get whenRentalEnds => 'உங்கள் வாடகை எப்போது முடிகிறது';

  @override
  String get rentalLength => 'வாடகைக் காலம்';

  @override
  String get rentalBillingNote =>
      'வாடகை முழு நாட்களாகக் கணக்கிடப்படும். 59 நிமிடங்களுக்கு மேல் தாமதமாகக் காரைத் திருப்பினால் ஒரு நாள் கூடுதல்.';

  @override
  String get howGetYourCar => 'உங்கள் காரை எப்படிப் பெற விரும்புகிறீர்கள்?';

  @override
  String get collectOrDelivered =>
      'நீங்களே எடுத்துக்கொள்ளுங்கள் அல்லது உங்கள் முகவரிக்கு வரவழையுங்கள்';

  @override
  String get selfPickup => 'நேரடி பிக்அப்';

  @override
  String get collectFromBranch => 'ELK கிளையிலிருந்து பெறுங்கள்';

  @override
  String get free => 'இலவசம்';

  @override
  String get carDelivery => 'கார் டெலிவரி';

  @override
  String get weBringIt => 'உங்கள் முகவரிக்கு நாங்கள் கொண்டு வருவோம்';

  @override
  String get chooseBranch => 'கிளையைத் தேர்ந்தெடு';

  @override
  String get mapPreviewHint => 'வரைபட முன்னோட்டம் · வழிகளுக்குத் தட்டவும்';

  @override
  String get deliveryAddress => 'டெலிவரி முகவரி';

  @override
  String get deliveryAddressHint => 'எ.கா. கோரமங்கலா, பெங்களூரு';

  @override
  String get buildingVillaNo => 'கட்டிடம் / வில்லா எண்';

  @override
  String get driverDirections => 'ஓட்டுநருக்கான வழிகாட்டுதல் (விருப்பம்)';

  @override
  String get driverDirectionsHint =>
      'கேட் குறியீடு, அடையாளம், நிறுத்தும் குறிப்புகள்…';

  @override
  String get locationCaptured => 'இடம் பதிவு செய்யப்பட்டது';

  @override
  String get useCurrentLocation => 'என் தற்போதைய இடத்தைப் பயன்படுத்து';

  @override
  String get deliveryFeeNote =>
      'டெலிவரி கட்டணம் ₹25 · உங்கள் பிக்அப் நேரத்தின் 2 மணி நேரத்தில் கார் வரும்.';

  @override
  String get enhanceYourTrip => 'உங்கள் பயணத்தை மேம்படுத்துங்கள்';

  @override
  String get optionalAddOns =>
      'விருப்ப கூடுதல் சேவைகள் — உங்கள் பயணத்திற்கு ஏற்றதைத் தேர்ந்தெடுங்கள்';

  @override
  String get reviewYourBooking => 'உங்கள் முன்பதிவை மதிப்பாய்வு செய்யுங்கள்';

  @override
  String get doubleCheckBeforePay => 'செலுத்தும் முன் அனைத்தையும் சரிபாருங்கள்';

  @override
  String get bookingAsYourself => 'உங்களுக்காகவே முன்பதிவு';

  @override
  String get tripDates => 'பயணத் தேதிகள்';

  @override
  String get priceBreakdown => 'விலை விவரம்';

  @override
  String get deliveryFee => 'டெலிவரி கட்டணம்';

  @override
  String get promoCodeHint => 'புரோமோ குறியீடு — ELK10 முயற்சிக்கவும்';

  @override
  String get totalInclGst => 'மொத்தம் (5% ஜிஎஸ்டி உட்பட)';

  @override
  String get iAgreeToThe => 'நான் ஏற்கிறேன் ';

  @override
  String get rentalTerms => 'வாடகை விதிமுறைகள்';

  @override
  String get enterPromoFirst => 'முதலில் புரோமோ குறியீட்டை உள்ளிடவும்';

  @override
  String get promoNotValid => 'அந்தக் குறியீடு செல்லாது';

  @override
  String get cashOnPickup => 'பிக்அப்பில் ரொக்கம்';

  @override
  String get chooseHowToPay =>
      'எப்படிச் செலுத்த விரும்புகிறீர்கள் என்பதைத் தேர்ந்தெடுங்கள்';

  @override
  String get cardLabel => 'அட்டை';

  @override
  String get saveCardNextTime =>
      'அடுத்த முறை விரைவான செக்அவுட்டுக்கு இந்த அட்டையைச் சேமி';

  @override
  String get payWithDigitalWallet => 'உங்கள் டிஜிட்டல் வாலட்டில் செலுத்துங்கள்';

  @override
  String get walletRedirectNote =>
      'இந்தக் கட்டணத்தைப் பாதுகாப்பாக முடிக்க நீங்கள் திருப்பி விடப்படுவீர்கள், பின்னர் ELK Business Hub-க்குத் திரும்புவீர்கள்.';

  @override
  String get cashAtBranchNote =>
      'கிளை கவுண்டரில் காரைப் பெறும்போது முழுத் தொகையையும் ரொக்கமாகச் செலுத்துங்கள்.';

  @override
  String get cashToDriverNote =>
      'கார் வழங்கப்படும்போது எங்கள் ஓட்டுநருக்கு முழுத் தொகையையும் ரொக்கமாகச் செலுத்துங்கள்.';

  @override
  String get processingYourPayment => 'உங்கள் கட்டணம் செயலாக்கப்படுகிறது…';

  @override
  String get dontCloseScreen => 'இந்தத் திரையை மூடாதீர்கள்';

  @override
  String get bookingConfirmedBang => 'முன்பதிவு உறுதி!';

  @override
  String get deliveredToAddress => 'உங்கள் முகவரிக்கு வழங்கப்படும்';

  @override
  String get showThisAtPickup => 'பிக்அப்பில் இதைக் காட்டுங்கள்';

  @override
  String get viewEReceipt => 'மின்-ரசீதைப் பார்';

  @override
  String payAmount(String amount) {
    return '$amount செலுத்து';
  }

  @override
  String confirmAndPayAmount(String amount) {
    return 'உறுதிசெய்து $amount செலுத்து';
  }

  @override
  String branchSelfPickup(String branch) {
    return '$branch (நேரடி பிக்அப்)';
  }

  @override
  String daysCount(int days) {
    return '$days நாட்கள்';
  }

  @override
  String get payUpiSub => 'GPay, PhonePe, Paytm மற்றும் பல';

  @override
  String get payCardBrandsIn => 'விசா, மாஸ்டர்கார்டு, ருபே';

  @override
  String get payNetBanking => 'நெட் பேங்கிங்';

  @override
  String get payAllMajorBanks => 'அனைத்து முக்கிய வங்கிகள்';

  @override
  String get couldNotScheduleVisit => 'வருகையை நிர்ணயிக்க முடியவில்லை.';

  @override
  String get allStays => 'அனைத்து தங்குமிடங்கள்';

  @override
  String get chipAll => 'அனைத்தும்';

  @override
  String get chipSingle => 'ஒற்றை';

  @override
  String get chipDouble => 'இரட்டை';

  @override
  String get chipFoodIncl => 'உணவு உட்பட';

  @override
  String get chipNearMetro => 'மெட்ரோ அருகில்';

  @override
  String get staysInArea => 'கோரமங்கலாவில் தங்குமிடங்கள்';

  @override
  String get sortLabel => 'வரிசை ';

  @override
  String get staySignInPrompt =>
      'இந்தத் தங்குமிடத்தைக் காண மொபைல் எண்ணைக் கொண்டு உள்நுழையவும்.';

  @override
  String get stayBrowseSignInPrompt =>
      'தங்குமிடங்களைப் பார்க்க மொபைல் எண்ணைக் கொண்டு உள்நுழையவும்.';

  @override
  String get foodIncluded => 'உணவு அடங்கும்';

  @override
  String get chooseSharing => 'பகிர்வைத் தேர்ந்தெடு';

  @override
  String get amenities => 'வசதிகள்';

  @override
  String get ratingsReviews => 'மதிப்பீடுகள் & விமர்சனங்கள்';

  @override
  String get sampleStayReview =>
      '\"சுத்தமான அறைகள், சிறந்த உணவு, மிகவும் பாதுகாப்பானது. வார்டன் உதவிகரமானவர், பயணத்திற்கு இடம் சிறந்தது.\" — பிரியா எஸ்.';

  @override
  String get startingFrom => 'இருந்து தொடங்கி';

  @override
  String get visit => 'வருகை';

  @override
  String get reserve => 'முன்பதிவு செய்';

  @override
  String get bookYourStay => 'உங்கள் தங்குமிடத்தை முன்பதிவு செய்';

  @override
  String get roomType => 'அறை வகை';

  @override
  String get moveInDate => 'குடியேறும் தேதி';

  @override
  String get durationCaps => 'கால அளவு';

  @override
  String get fullName => 'முழுப் பெயர்';

  @override
  String get phoneNumber => 'தொலைபேசி எண்';

  @override
  String get reviewAndPay => 'மதிப்பாய்வு & கட்டணம்';

  @override
  String get paymentSummary => 'கட்டணச் சுருக்கம்';

  @override
  String get firstMonthRent => 'முதல் மாத வாடகை';

  @override
  String get securityDeposit => 'பாதுகாப்பு வைப்புத்தொகை';

  @override
  String get refundableAtMoveOut => 'வெளியேறும்போது திரும்பப் பெறலாம்';

  @override
  String get elkServiceFee => 'ELK சேவைக் கட்டணம்';

  @override
  String get couponElknew => 'கூப்பன் ELKNEW';

  @override
  String get payableNow => 'இப்போது செலுத்த வேண்டியது';

  @override
  String get applyPrefix => 'பயன்படுத்து ';

  @override
  String get saveFiveHundred => ' — ₹500 சேமியுங்கள்';

  @override
  String get appliedCaps => 'பயன்படுத்தப்பட்டது';

  @override
  String get applyCaps => 'பயன்படுத்து';

  @override
  String get stayPolicyNote =>
      'தொடர்வதன் மூலம் ELK-இன் தங்குமிடக் கொள்கை மற்றும் ரத்து விதிகளை ஏற்கிறீர்கள். ஆய்வுக்கு உட்பட்டு வைப்புத்தொகை முழுமையாகத் திரும்பப் பெறலாம்.';

  @override
  String get proceedToPay => 'கட்டணத்திற்குச் செல்';

  @override
  String get amountPayable => 'செலுத்த வேண்டிய தொகை';

  @override
  String get payUsing => 'இதைக் கொண்டு செலுத்து';

  @override
  String get upiId => 'யுபிஐ ஐடி';

  @override
  String get property => 'சொத்து';

  @override
  String get room => 'அறை';

  @override
  String get moveIn => 'குடியேற்றம்';

  @override
  String get backToHome => 'முகப்புக்குத் திரும்பு';

  @override
  String get pgStays => 'பிஜி தங்குமிடங்கள்';

  @override
  String get homestays => 'ஹோம்ஸ்டேக்கள்';

  @override
  String get statusVisitBooked => 'வருகை முன்பதிவு';

  @override
  String get statusPending => 'நிலுவையில்';

  @override
  String get chooseRoomFirst => 'முதலில் அறை விருப்பத்தைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get whatAreYouLookingFor => 'நீங்கள் எதைத் தேடுகிறீர்கள்?';

  @override
  String get topRatedNearYou => 'உங்கள் அருகில் சிறந்த மதிப்பீடு';

  @override
  String get goodMorning => 'காலை வணக்கம்,';

  @override
  String get staySearchHint => 'பகுதி, கல்லூரி அல்லது பிஜி தேடு';

  @override
  String get noStaysFound => 'தங்குமிடங்கள் எதுவும் கிடைக்கவில்லை';

  @override
  String get underTwelveK => '₹12k க்குக் கீழ்';

  @override
  String get singleRoom => 'ஒற்றை அறை';

  @override
  String get meals => 'உணவு';

  @override
  String get womensPg => 'பெண்கள் பிஜி';

  @override
  String get savedStays => 'சேமித்த தங்குமிடங்கள்';

  @override
  String get noSavedStaysYet => 'இதுவரை சேமித்த தங்குமிடம் இல்லை';

  @override
  String get noSavedStaysBody =>
      'ஒரு தங்குமிடத்தில் இதயத்தை அழுத்தினால் அது இங்கே இருக்கும்.';

  @override
  String get savedStaysSignIn =>
      'சேமித்த தங்குமிடங்களைப் பார்க்க உள்நுழையவும்.';

  @override
  String get myStays => 'என் தங்குமிடங்கள்';

  @override
  String get noStaysHereYet => 'இங்கே இதுவரை தங்குமிடங்கள் இல்லை';

  @override
  String get tabActive => 'செயலில்';

  @override
  String get tabRequests => 'கோரிக்கைகள்';

  @override
  String get tabPast => 'கடந்தவை';

  @override
  String get rent => 'வாடகை';

  @override
  String visitScheduledFor(String date) {
    return '$date, மாலை 5 மணிக்கு வருகை';
  }

  @override
  String monthsCount(int months) {
    return '$months மாதங்கள்';
  }

  @override
  String get accept => 'ஏற்று';

  @override
  String get accepted => 'ஏற்கப்பட்டது';

  @override
  String get acceptJob => 'வேலையை ஏற்று';

  @override
  String get accountHolderName => 'கணக்கு வைத்திருப்பவர் பெயர்';

  @override
  String get accountNumber => 'கணக்கு எண்';

  @override
  String get accountVerified => 'கணக்கு ••••4821 · சரிபார்க்கப்பட்டது';

  @override
  String get activeJobs => 'செயலில் உள்ள வேலைகள்';

  @override
  String get addAccountToWithdraw => 'வருமானத்தை எடுக்க கணக்கைச் சேர்க்கவும்';

  @override
  String get addAddress => 'முகவரி சேர்';

  @override
  String get addAnAddress => 'ஒரு முகவரியைச் சேர்';

  @override
  String get addCommentOptional => 'கருத்து சேர் (விருப்பம்)';

  @override
  String get addedToActiveJobs => 'செயலில் உள்ள வேலைகளில் சேர்க்கப்பட்டது';

  @override
  String get addedToYourActiveJobs =>
      'உங்கள் செயலில் உள்ள வேலைகளில் சேர்க்கப்பட்டது';

  @override
  String get addPayoutFirst => 'முதலில் பணம் பெறும் முறையைச் சேர்க்கவும்';

  @override
  String get addressesSignInPrompt =>
      'முன்பதிவு முகவரிகளைச் சேமிக்க உள்நுழையவும்.';

  @override
  String get addressLabelHint => 'பெயர் (வீடு, அலுவலகம்…)';

  @override
  String get addressLineHint => 'கட்டிடம், தெரு, பகுதி';

  @override
  String get addressTooLong =>
      'முகவரி 255 எழுத்துகளுக்கு மிகாமல் இருக்க வேண்டும்';

  @override
  String get adSubmitted => 'விளம்பரம் மதிப்பாய்வுக்கு அனுப்பப்பட்டது';

  @override
  String get allClear => 'அனைத்தும் சரி';

  @override
  String get amountToPay => 'செலுத்த வேண்டிய தொகை';

  @override
  String get applicationReviewNote =>
      '24-48 மணி நேரத்தில் உங்கள் விவரங்களை மதிப்பாய்வு செய்து ஆவணங்களைச் சரிபார்ப்போம். கணக்கு அங்கீகரிக்கப்பட்டதும் அறிவிப்பு வரும்.';

  @override
  String get applicationSubmitted => 'விண்ணப்பம் சமர்ப்பிக்கப்பட்டது!';

  @override
  String get asPrintedOnAccount =>
      'உங்கள் வங்கிக் கணக்கில் அச்சிடப்பட்டுள்ளது போல';

  @override
  String get availability => 'கிடைக்கும் தன்மை';

  @override
  String get availableNow => 'இப்போது கிடைக்கும்';

  @override
  String get availableOffers => 'கிடைக்கும் சலுகைகள்';

  @override
  String get availableToWithdraw => 'எடுக்கக் கிடைக்கும்';

  @override
  String get avgPerJob => 'ஒரு வேலைக்குச் சராசரி';

  @override
  String get bankLinked => 'வங்கி இணைக்கப்பட்டது';

  @override
  String get bankName => 'வங்கியின் பெயர்';

  @override
  String get booked => 'முன்பதிவு';

  @override
  String get bookingAccepted => 'முன்பதிவு ஏற்கப்பட்டது';

  @override
  String get bookingReference => 'முன்பதிவு குறிப்பு';

  @override
  String get bookingRequest => 'முன்பதிவு கோரிக்கை';

  @override
  String get bookingSignInPrompt =>
      'இந்தச் சேவையை முன்பதிவு செய்ய மொபைல் எண்ணைக் கொண்டு உள்நுழையவும்.';

  @override
  String get bookService => 'சேவையை முன்பதிவு செய்';

  @override
  String get businessName => 'வணிகப் பெயர்';

  @override
  String get businessNameHint => 'எ.கா. Royal Shine Co.';

  @override
  String get byAppointment => 'சந்திப்பின் மூலம்';

  @override
  String get cancelOrder => 'ஆர்டரை ரத்து செய்';

  @override
  String get cancelOrderConfirm => 'இந்த ஆர்டரை ரத்து செய்ய விரும்புகிறீர்களா?';

  @override
  String get canNowWithdraw => 'இப்போது உங்கள் வருமானத்தை எடுக்கலாம்';

  @override
  String get catPorter => 'போர்ட்டர்';

  @override
  String get catTaxiRide => 'டாக்சி / பயணம்';

  @override
  String get chat => 'அரட்டை';

  @override
  String get chatSignInPrompt =>
      'சேவை வழங்குநருக்குச் செய்தி அனுப்ப உள்நுழையவும்.';

  @override
  String get chatWithProvider => 'வழங்குநருடன் அரட்டை';

  @override
  String get chooseCategory => 'ஒரு பிரிவைத் தேர்ந்தெடு';

  @override
  String get chooseServiceAddress => 'சேவை முகவரியைத் தேர்ந்தெடு';

  @override
  String get claimOfferArrow => 'சலுகையைப் பெறு →';

  @override
  String get completedJobs => 'முடிந்த வேலைகள்';

  @override
  String get confirmWithdrawal => 'பணம் எடுப்பை உறுதிசெய்';

  @override
  String get contactNumber => 'தொடர்பு எண்';

  @override
  String get customer => 'வாடிக்கையாளர்';

  @override
  String get customerHasBeenNotified => 'வாடிக்கையாளருக்குத் தெரிவிக்கப்பட்டது';

  @override
  String get customerNotified => 'வாடிக்கையாளருக்குத் தெரிவிக்கப்பட்டது';

  @override
  String get customersCanBook =>
      'வாடிக்கையாளர்கள் இப்போது உங்களை முன்பதிவு செய்யலாம்';

  @override
  String get decline => 'நிராகரி';

  @override
  String get declined => 'நிராகரிக்கப்பட்டது';

  @override
  String get defaultCaps => 'இயல்பு';

  @override
  String get description => 'விளக்கம்';

  @override
  String get descriptionHint =>
      'என்ன அடங்கும், உங்கள் அனுபவம், சேவைப் பகுதி ஆகியவற்றை விவரிக்கவும்…';

  @override
  String get detailsForProfile =>
      'இந்த விவரங்களைக் கொண்டு உங்கள் வழங்குநர் சுயவிவரத்தை அமைப்போம்.';

  @override
  String get done => 'முடிந்தது';

  @override
  String get earnings => 'வருமானம்';

  @override
  String get enterAccountHolderName => 'கணக்கு வைத்திருப்பவர் பெயரை உள்ளிடவும்';

  @override
  String get enterALabel => 'ஒரு பெயரை உள்ளிடவும்';

  @override
  String get enterTheAddress => 'முகவரியை உள்ளிடவும்';

  @override
  String get enterValidAccountNumber =>
      'சரியான 9–18 இலக்க கணக்கு எண்ணை உள்ளிடவும்';

  @override
  String get export => 'ஏற்றுமதி';

  @override
  String get fixedPrice => 'நிலையான விலை';

  @override
  String get fundsArriveIn => '1–2 வேலை நாட்களில் பணம் வரும்';

  @override
  String get goesLiveIn24h => '24 மணி நேரத்தில் நேரலைக்கு வரும்';

  @override
  String get guest => 'விருந்தினர்';

  @override
  String get howWasExperience => 'உங்கள் அனுபவம் எப்படி இருந்தது?';

  @override
  String get idDocument => 'அடையாள ஆவணம்';

  @override
  String get idDocumentHint =>
      'அரசு வழங்கிய புகைப்பட அடையாள அட்டையைப் பதிவேற்றவும்';

  @override
  String get inProgress => 'நடைபெறுகிறது';

  @override
  String get inReview => 'மதிப்பாய்வில்';

  @override
  String get labelTooLong => 'பெயர் 50 எழுத்துகளுக்கு மிகாமல் இருக்க வேண்டும்';

  @override
  String get linkAccount => 'கணக்கை இணை';

  @override
  String get linkBankAccount => 'வங்கிக் கணக்கை இணை';

  @override
  String get listings => 'பட்டியல்கள்';

  @override
  String get listingTitle => 'பட்டியல் தலைப்பு';

  @override
  String get listingTitleHint => 'எ.கா. ஆழ்ந்த வீட்டு சுத்தம் (3BHK)';

  @override
  String get liveUpdatesUnavailable =>
      'நேரலை புதுப்பிப்புகள் இல்லை — புதிய பதில்களைக் காண அரட்டையை மீண்டும் திறக்கவும்.';

  @override
  String get markAllRead => 'அனைத்தையும் படித்ததாகக் குறி';

  @override
  String get markedAllRead => 'அனைத்தும் படித்ததாகக் குறிக்கப்பட்டது';

  @override
  String get marking => 'குறிக்கப்படுகிறது…';

  @override
  String get myListings => 'என் பட்டியல்கள்';

  @override
  String get mySchedule => 'என் அட்டவணை';

  @override
  String get newRequest => 'புதிய கோரிக்கை';

  @override
  String get newRequests => 'புதிய கோரிக்கைகள்';

  @override
  String get noActiveJobs => 'செயலில் வேலைகள் இல்லை';

  @override
  String get noBankLinked => 'வங்கி இணைக்கப்படவில்லை';

  @override
  String get noBankLinkedYet => 'இதுவரை வங்கி இணைக்கப்படவில்லை';

  @override
  String get noEarningsYet => 'இதுவரை வருமானம் இல்லை';

  @override
  String get noNewRequests => 'உங்களுக்குப் புதிய கோரிக்கைகள் வராது';

  @override
  String get noNewRequestsNow => 'இப்போது புதிய கோரிக்கைகள் இல்லை';

  @override
  String get noNotificationsYet => 'இதுவரை அறிவிப்புகள் இல்லை';

  @override
  String get noOffersRunning =>
      'இப்போது சலுகைகள் இல்லை — விரைவில் மீண்டும் பாருங்கள்.';

  @override
  String get noOrdersRightNow => 'இப்போது இங்கே ஆர்டர்கள் இல்லை';

  @override
  String get noReviewsYet => 'இதுவரை விமர்சனங்கள் இல்லை';

  @override
  String get noSavedAddressesYet => 'இதுவரை சேமித்த முகவரிகள் இல்லை';

  @override
  String get nothingHereYet => 'இங்கே இதுவரை எதுவும் இல்லை';

  @override
  String get nothingWaiting => 'எதுவும் காத்திருக்கவில்லை';

  @override
  String get notificationsSignInPrompt =>
      'முன்பதிவு மற்றும் சலுகைப் புதுப்பிப்புகளைக் காண உள்நுழையவும்.';

  @override
  String get offersSignInPrompt =>
      'வெகுமதிப் புள்ளிகள் மற்றும் சலுகைகளைக் காண உள்நுழையவும்.';

  @override
  String get offline => 'ஆஃப்லைன்';

  @override
  String get orderCancelled => 'ஆர்டர் ரத்து செய்யப்பட்டது';

  @override
  String get orderId => 'ஆர்டர் ஐடி';

  @override
  String get orders => 'ஆர்டர்கள்';

  @override
  String get orderStatus => 'ஆர்டர் நிலை';

  @override
  String get paused => 'இடைநிறுத்தப்பட்டது';

  @override
  String get payoutMethod => 'பணம் பெறும் முறை';

  @override
  String get perDay => 'ஒரு நாளுக்கு';

  @override
  String get perHour => 'ஒரு மணி நேரத்திற்கு';

  @override
  String get pickServiceType =>
      'நீங்கள் பட்டியலிடும் சேவை அல்லது பொருள் வகையைத் தேர்ந்தெடுங்கள்';

  @override
  String get post => 'இடு';

  @override
  String get postNewAd => 'புதிய விளம்பரம் இடு';

  @override
  String get price => 'விலை';

  @override
  String get pricingType => 'விலை வகை';

  @override
  String get promoTwentyOffFirstBooking => 'முதல் முன்பதிவுக்கு 20% தள்ளுபடி';

  @override
  String get provider => 'வழங்குநர்';

  @override
  String get providerSignInPrompt =>
      'உங்கள் வழங்குநர் கணக்கை நிர்வகிக்க உள்நுழையவும்.';

  @override
  String get publishAd => 'விளம்பரத்தை வெளியிடு';

  @override
  String get quickActions => 'விரைவு செயல்கள்';

  @override
  String get rateYourExperience => 'உங்கள் அனுபவத்தை மதிப்பிடு';

  @override
  String get recentBookings => 'சமீபத்திய முன்பதிவுகள்';

  @override
  String get recentTransactions => 'சமீபத்திய பரிவர்த்தனைகள்';

  @override
  String get removeAddress => 'முகவரியை அகற்று';

  @override
  String get rename => 'பெயர் மாற்று';

  @override
  String get renameAddress => 'முகவரியின் பெயரை மாற்று';

  @override
  String get reviewSignInPrompt =>
      'முன்பதிவு செய்த சேவைகளை மதிப்பிட உள்நுழையவும்.';

  @override
  String get saveDraft => 'வரைவைச் சேமி';

  @override
  String get selectDateTitle => 'தேதியைத் தேர்ந்தெடு';

  @override
  String get selectTime => 'நேரத்தைத் தேர்ந்தெடு';

  @override
  String get serviceArea => 'சேவைப் பகுதி';

  @override
  String get serviceAreaHint => 'எ.கா. பெங்களூரு நகரம்';

  @override
  String get serviceCategory => 'சேவைப் பிரிவு';

  @override
  String get serviceSignInPrompt =>
      'இந்தச் சேவையைக் காண மொபைல் எண்ணைக் கொண்டு உள்நுழையவும்.';

  @override
  String get setAsDefault => 'இயல்பாக அமை';

  @override
  String get shareDetailsHint => 'உங்கள் அனுபவம் பற்றிப் பகிரவும்...';

  @override
  String get statement => 'அறிக்கை';

  @override
  String get submitApplication => 'விண்ணப்பத்தைச் சமர்ப்பி';

  @override
  String get submitReview => 'விமர்சனத்தைச் சமர்ப்பி';

  @override
  String get tapChangeToChoose =>
      'முகவரியைத் தேர்ந்தெடுக்க மாற்று என்பதைத் தட்டவும்';

  @override
  String get teamSize => 'குழு அளவு';

  @override
  String get tellUsAboutBusiness => 'உங்கள் வணிகம் பற்றிச் சொல்லுங்கள்';

  @override
  String get todayAtAGlance => 'இன்று ஒரு பார்வையில்';

  @override
  String get todaysBookings => 'இன்றைய முன்பதிவுகள்';

  @override
  String get todaysEarnings => 'இன்றைய வருமானம்';

  @override
  String get todaysTimeSlots => 'இன்றைய நேர இடங்கள்';

  @override
  String get trackSignInPrompt => 'உங்கள் ஆர்டர்களைக் கண்காணிக்க உள்நுழையவும்.';

  @override
  String get tradeLicense => 'வர்த்தக உரிமம்';

  @override
  String get tradeLicenseHint =>
      'வர்த்தக உரிமத்தின் தெளிவான புகைப்படம் அல்லது PDF ஐப் பதிவேற்றவும்';

  @override
  String get typeAMessage => 'செய்தியை உள்ளிடவும்...';

  @override
  String get upload => 'பதிவேற்று';

  @override
  String get uploadDocuments => 'தேவையான ஆவணங்களைப் பதிவேற்றவும்';

  @override
  String get uploaded => 'பதிவேற்றப்பட்டது';

  @override
  String get verifiedProvidersBlurb =>
      'சரிபார்க்கப்பட்ட வழங்குநர்களுக்கு அதிக முன்பதிவுகளும் நம்பிக்கையும் கிடைக்கும்.';

  @override
  String get viewOrders => 'ஆர்டர்களைப் பார்';

  @override
  String get weekdaysOnly => 'வேலை நாட்கள் மட்டும்';

  @override
  String get whatWentWell => 'எது நன்றாக இருந்தது?';

  @override
  String get withdrawalRequested => 'பணம் எடுப்பு கோரப்பட்டது';

  @override
  String get withdrawEarnings => 'வருமானத்தை எடு';

  @override
  String get yesCancel => 'ஆம், ரத்து செய்';

  @override
  String get youAreOffline => 'நீங்கள் ஆஃப்லைனில் உள்ளீர்கள்';

  @override
  String get youAreOnline => 'நீங்கள் ஆன்லைனில் உள்ளீர்கள்';

  @override
  String get youEarnAfterFee => 'நீங்கள் பெறுவது (12% கட்டணத்திற்குப் பின்)';

  @override
  String get partnerDashboard => 'கூட்டாளர் டாஷ்போர்டு';

  @override
  String get linkBankToGetPaid => 'பணம் பெற வங்கியை இணையுங்கள்';

  @override
  String get addAccountToTransfer =>
      'உங்கள் வருமானத்தை அனுப்ப கணக்கைச் சேர்க்கவும்';

  @override
  String get addBankAccount => 'வங்கிக் கணக்கைச் சேர்';

  @override
  String get listServiceOrItem => 'சேவை அல்லது பொருளைப் பட்டியலிடு';

  @override
  String get earningsThisWeek => 'இந்த வாரத்தின் வருமானம்';

  @override
  String get paymentConfirmed => 'கட்டணம் உறுதி';

  @override
  String get searchVendorsHint => 'விற்பனையாளர்கள் அல்லது சேவைகளைத் தேடு…';

  @override
  String get email => 'மின்னஞ்சல்';

  @override
  String get noSellersYet => 'இதுவரை விற்பனையாளர்கள் இல்லை';

  @override
  String get listingsWillAppear =>
      'விற்பனையாளர்கள் விளம்பரம் இட்டதும் பட்டியல்கள் இங்கே தோன்றும்.';

  @override
  String get tapCardToViewVendor => 'விற்பனையாளரைக் காண அட்டையைத் தட்டவும்';

  @override
  String get verifiedVendor => 'சரிபார்க்கப்பட்ட விற்பனையாளர்';

  @override
  String get aboutThisService => 'இந்தச் சேவை பற்றி';

  @override
  String get locationCoverage => 'இடம் & பரப்பளவு';

  @override
  String get contactVendor => 'விற்பனையாளரைத் தொடர்பு கொள்';

  @override
  String get excellent => 'சிறப்பானது';

  @override
  String get sampleVendorReview =>
      '\"குறையற்ற வேலை மற்றும் மிகவும் தொழில்முறை குழு. அதே வாரம் மீண்டும் முன்பதிவு செய்தேன்.\" — லைலா எம்.';

  @override
  String get workOrderCaps => 'பணி ஆணை';

  @override
  String get elkRepairCaps => 'ELK REPAIR';

  @override
  String get pickASlot => 'ஒரு நேரத்தைத் தேர்ந்தெடு';

  @override
  String get cleanPlanCaps => 'சுத்தத் திட்டம்';

  @override
  String get elkCleanCaps => 'ELKCLEAN';

  @override
  String get loyalty => 'விசுவாசம்';

  @override
  String get today => 'இன்று';

  @override
  String get balance => 'இருப்பு';

  @override
  String get partnerAccount => 'கூட்டாளர் கணக்கு';

  @override
  String get forUsers => 'பயனர்களுக்கு';

  @override
  String get forSellers => 'விற்பனையாளர்களுக்கு';

  @override
  String get currentlySellerMode => 'தற்போது விற்பனையாளர் பயன்முறையில்';

  @override
  String get currentlyUserMode => 'தற்போது பயனர் பயன்முறையில்';

  @override
  String get switchToSellerPanel => 'விற்பனையாளர் பலகைக்கு மாறு';

  @override
  String get switchToUserPanel => 'பயனர் பலகைக்கு மாறு';

  @override
  String get weekly => 'வாராந்திரம்';

  @override
  String get monthly => 'மாதாந்திரம்';

  @override
  String get currentLocation => 'தற்போதைய இடம்';

  @override
  String get chooseYourLocation => 'உங்கள் இடத்தைத் தேர்ந்தெடு';

  @override
  String get searchForAddress => 'முகவரியைத் தேடு';

  @override
  String get findStreetArea =>
      'எந்த தெரு, பகுதி அல்லது அடையாளத்தையும் கண்டறியவும்';

  @override
  String get useCurrentLocationTitle => 'தற்போதைய இடத்தைப் பயன்படுத்து';

  @override
  String get usesPhoneGps => 'உங்கள் தொலைபேசி GPS ஐப் பயன்படுத்துகிறது';

  @override
  String get savedAddressesSignIn =>
      'சேமித்த முகவரிகளைப் பயன்படுத்த உள்நுழையவும்.';

  @override
  String get noSavedAddressesSearch =>
      'இதுவரை சேமித்த முகவரிகள் இல்லை — கீழே தேடவும்.';

  @override
  String get savedAddressesTitle => 'சேமித்த முகவரிகள்';

  @override
  String get searchAddress => 'முகவரியைத் தேடு';

  @override
  String get streetAreaHint => 'தெரு, பகுதி அல்லது அடையாளம்';

  @override
  String get noMatchingPlaces => 'பொருந்தும் இடங்கள் இல்லை.';

  @override
  String get startTypingToFind =>
      'முகவரியைக் கண்டறிய தட்டச்சு செய்யத் தொடங்குங்கள்.';

  @override
  String get turnOnLocationServices =>
      'இதைப் பயன்படுத்த இருப்பிடச் சேவைகளை இயக்கவும்.';

  @override
  String get locationPermissionNeeded =>
      'உங்கள் முகவரியைக் கண்டறிய இருப்பிட அனுமதி தேவை.';

  @override
  String rateDriver(String driver) {
    return '$driver ஐ மதிப்பிடு';
  }

  @override
  String get totalCaps => 'மொத்தம்';

  @override
  String get locating => 'இடம் கண்டறியப்படுகிறது…';

  @override
  String get setPickupLocation => 'பிக்அப் இடத்தை அமைக்கவும்';

  @override
  String get setDropLocation => 'இறங்கும் இடத்தை அமைக்கவும்';

  @override
  String get setPickupAndDrop =>
      'முதலில் பிக்அப் மற்றும் இறங்கும் இடங்கள் இரண்டையும் அமைக்கவும்.';
}
