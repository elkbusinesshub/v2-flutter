// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'ELK Business Hub';

  @override
  String get commonContinue => 'जारी रखें';

  @override
  String get commonCancel => 'रद्द करें';

  @override
  String get commonDelete => 'मिटाएँ';

  @override
  String get deleteListing => 'यह लिस्टिंग हटाएँ?';

  @override
  String get pauseListing => 'रोकें';

  @override
  String get resumeListing => 'फिर शुरू करें';

  @override
  String get photos => 'तस्वीरें';

  @override
  String get draftSaved => 'ड्राफ़्ट सहेजा गया';

  @override
  String get fillRequiredFields => 'पहले श्रेणी, शीर्षक और कीमत भरें।';

  @override
  String get addPhoto => 'तस्वीर जोड़ें';

  @override
  String photosAdded(int count) {
    return '$count जोड़ी गईं';
  }

  @override
  String get markCompleted => 'पूर्ण चिह्नित करें';

  @override
  String needAttention(int count) {
    return '$count पर ध्यान दें';
  }

  @override
  String get placeOrder => 'ऑर्डर करें';

  @override
  String orderPlaced(String code) {
    return 'ऑर्डर हो गया · $code';
  }

  @override
  String get commonRetry => 'फिर कोशिश करें';

  @override
  String get commonSave => 'सहेजें';

  @override
  String get commonDone => 'हो गया';

  @override
  String get commonNext => 'आगे';

  @override
  String get commonBack => 'वापस';

  @override
  String get commonClose => 'बंद करें';

  @override
  String get commonConfirm => 'पुष्टि करें';

  @override
  String get commonSkip => 'छोड़ें';

  @override
  String get commonSearch => 'खोजें';

  @override
  String get commonSeeAll => 'सभी देखें';

  @override
  String get commonApply => 'लागू करें';

  @override
  String get commonClear => 'साफ़ करें';

  @override
  String get commonRemove => 'हटाएँ';

  @override
  String get commonEdit => 'संपादित करें';

  @override
  String get commonYes => 'हाँ';

  @override
  String get commonNo => 'नहीं';

  @override
  String get commonOk => 'ठीक है';

  @override
  String get errorGeneric => 'कुछ गड़बड़ हो गई';

  @override
  String get errorTimeout =>
      'अनुरोध का समय समाप्त हो गया। कृपया फिर कोशिश करें।';

  @override
  String get errorNoInternet =>
      'इंटरनेट कनेक्शन नहीं है। कृपया अपना नेटवर्क जाँचें और फिर कोशिश करें।';

  @override
  String get errorCancelled => 'अनुरोध रद्द कर दिया गया।';

  @override
  String get errorInsecureConnection => 'सुरक्षित कनेक्शन नहीं बन सका।';

  @override
  String get errorUnknown => 'कुछ गड़बड़ हो गई। कृपया फिर कोशिश करें।';

  @override
  String get errorValidation => 'कृपया अपनी जानकारी जाँचें और फिर कोशिश करें।';

  @override
  String get errorSessionExpired =>
      'आपका सत्र समाप्त हो गया है। कृपया फिर से लॉग इन करें।';

  @override
  String get errorForbidden => 'आपके पास ऐसा करने की अनुमति नहीं है।';

  @override
  String get errorNotFound => 'अनुरोधित जानकारी नहीं मिली।';

  @override
  String get errorTooManyRequests =>
      'बहुत अधिक प्रयास। कृपया थोड़ी देर बाद कोशिश करें।';

  @override
  String get errorServer =>
      'हमारी ओर से कुछ गड़बड़ हो गई। कृपया बाद में कोशिश करें।';

  @override
  String get signInRequired =>
      'जारी रखने के लिए अपने मोबाइल नंबर से साइन इन करें।';

  @override
  String get signIn => 'साइन इन करें';

  @override
  String get registerBusinessPrompt =>
      'बुकिंग पाना शुरू करने के लिए अपना व्यवसाय पंजीकृत करें।';

  @override
  String get becomeProvider => 'प्रदाता बनें';

  @override
  String get languageTitle => 'अपनी भाषा चुनें';

  @override
  String get languageSubtitle => 'आप इसे कभी भी सेटिंग्स से बदल सकते हैं।';

  @override
  String get languageSaveFailed =>
      'आपकी भाषा सहेजी नहीं जा सकी। कृपया फिर कोशिश करें।';

  @override
  String get commonOr => 'या';

  @override
  String get getStarted => 'शुरू करें';

  @override
  String get byContinuingYouAgree => 'जारी रखने पर आप हमारी ';

  @override
  String get termsAndConditions => 'शर्तों से सहमत होते हैं';

  @override
  String get verified => 'सत्यापित';

  @override
  String get navHome => 'होम';

  @override
  String get navBookings => 'बुकिंग';

  @override
  String get navWallet => 'वॉलेट';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get onboardServicesTitle => 'आपकी सारी सेवाएँ, एक ऐप में';

  @override
  String get onboardServicesBody =>
      'अपने शहर के सत्यापित प्रदाताओं से सवारी, सफ़ाई, किराया और बहुत कुछ बुक करें। तेज़, भरोसेमंद, विश्वसनीय।';

  @override
  String get onboardTrackingTitle => 'लाइव ट्रैकिंग और चैट';

  @override
  String get onboardTrackingBody =>
      'मानचित्र पर अपने प्रदाता को लाइव देखें और सहज, पारदर्शी अनुभव के लिए उनसे सीधे चैट करें।';

  @override
  String get onboardPaymentsTitle => 'सुरक्षित भुगतान और रिवॉर्ड';

  @override
  String get onboardPaymentsBody =>
      'अपने वॉलेट, कार्ड या नकद से सुरक्षित भुगतान करें और हर बुकिंग पर रिवॉर्ड पॉइंट कमाएँ।';

  @override
  String get splashSettingUp => 'आपका शहर तैयार किया जा रहा है';

  @override
  String get splashFindingPros => 'भरोसेमंद पेशेवर ढूँढ़े जा रहे हैं';

  @override
  String get splashAlmostThere => 'बस थोड़ा और';

  @override
  String get authWelcomeBack => 'वापसी पर स्वागत है';

  @override
  String get authSignInPrompt =>
      'जारी रखने के लिए अपने मोबाइल नंबर से साइन इन करें';

  @override
  String get authMobileNumber => 'मोबाइल नंबर';

  @override
  String get authSendOtp => 'OTP भेजें';

  @override
  String get authContinueAsGuest => 'अतिथि के रूप में जारी रखें';

  @override
  String get authVerifyTitle => 'अपना नंबर सत्यापित करें';

  @override
  String get authOtpSentTo => 'हमने 6 अंकों का कोड भेजा है ';

  @override
  String get authVerifyContinue => 'सत्यापित करें और जारी रखें';

  @override
  String get authResendCode => 'कोड फिर भेजें';

  @override
  String authResendIn(String seconds) {
    return '00:$seconds में कोड फिर भेजें';
  }

  @override
  String get homeBestSellersTag => 'बेस्ट सेलर';

  @override
  String get homeBestSellersRest => 'आपके पास';

  @override
  String get homeBestSellersSub => 'सबसे ज़्यादा सहेजी और देखी गई लिस्टिंग';

  @override
  String get homeDealsTag => 'डील';

  @override
  String get homeDealsRest => 'आपके लिए';

  @override
  String get homeDealsSub => 'आपके पास के विक्रेताओं से और';

  @override
  String get homeServiceAt => 'सेवा यहाँ';

  @override
  String get homeSelectLocation => 'स्थान चुनें';

  @override
  String get homeServices => 'सेवाएँ';

  @override
  String get homeBadgeFast => 'तेज़';

  @override
  String get homeBadgeNew => 'नया';

  @override
  String get homeBadgeTwentyOff => '20% छूट';

  @override
  String get homeNoSellerAds => 'अभी कोई विक्रेता विज्ञापन नहीं';

  @override
  String get homeMoreListingsSoon =>
      'विक्रेताओं के पोस्ट करने पर यहाँ और लिस्टिंग दिखेंगी।';

  @override
  String get promoFirstBookingTitle => 'आपकी पहली बुकिंग पर\n20% छूट';

  @override
  String get promoFirstBookingBody =>
      'नए सदस्यों को हर सेवा पर विशेष छूट मिलती है।';

  @override
  String get promoClaimOffer => 'ऑफ़र लें';

  @override
  String get promoFreeRidesTitle => 'हर हफ़्ते\nमुफ़्त सवारी';

  @override
  String get promoFreeRidesBody =>
      'सदस्यों को साप्ताहिक लाभ, प्राथमिक सहायता और कम शुल्क मिलते हैं।';

  @override
  String get promoJoinNow => 'अभी जुड़ें';

  @override
  String get profileSignOut => 'साइन आउट';

  @override
  String get profileSignOutConfirm => 'क्या आप वाकई साइन आउट करना चाहते हैं?';

  @override
  String get profileUpdated => 'प्रोफ़ाइल अपडेट हो गई';

  @override
  String get profileEdit => 'प्रोफ़ाइल संपादित करें';

  @override
  String get profileRewardPoints => 'रिवॉर्ड पॉइंट';

  @override
  String get profileRating => 'रेटिंग';

  @override
  String get profileMyAccount => 'मेरा खाता';

  @override
  String get profileOffersRewards => 'ऑफ़र और रिवॉर्ड';

  @override
  String get profileNotifications => 'सूचनाएँ';

  @override
  String get profileSavedAddresses => 'सहेजे गए पते';

  @override
  String get profileLanguage => 'भाषा';

  @override
  String get profileRateService => 'सेवा को रेट करें';

  @override
  String get profileProviderTools => 'प्रदाता टूल';

  @override
  String get profileProviderDashboard => 'प्रदाता डैशबोर्ड';

  @override
  String get profileSupport => 'सहायता';

  @override
  String get profileHelpSupport => 'मदद और सहायता';

  @override
  String get profileAbout => 'ELK Business Hub के बारे में';

  @override
  String get profileTermsPrivacy => 'शर्तें और गोपनीयता नीति';

  @override
  String get profileGuestTitle => 'आप अतिथि के रूप में देख रहे हैं';

  @override
  String get profileGuestBody =>
      'अपनी प्रोफ़ाइल, बुकिंग और रिवॉर्ड देखने के लिए मोबाइल नंबर से साइन इन करें।';

  @override
  String get profileNameRequired => 'कृपया अपना नाम दर्ज करें।';

  @override
  String get profileNameTooLong => 'नाम 100 अक्षरों से अधिक नहीं होना चाहिए।';

  @override
  String get profileEmailInvalid => 'कृपया मान्य ईमेल पता दर्ज करें।';

  @override
  String get profileNameLabel => 'नाम';

  @override
  String get profileEmailLabel => 'ईमेल (वैकल्पिक)';

  @override
  String get walletToppedUp => 'वॉलेट में पैसे जुड़ गए';

  @override
  String get walletWithdrawSuccess => 'निकासी सफल';

  @override
  String get walletStillLoading =>
      'वॉलेट अभी लोड हो रहा है। कृपया फिर कोशिश करें।';

  @override
  String get walletAddMoneyTitle => 'वॉलेट में पैसे जोड़ें';

  @override
  String get walletWithdrawTitle => 'बैंक में निकालें';

  @override
  String get walletAddMoney => 'पैसे जोड़ें';

  @override
  String get walletWithdraw => 'निकालें';

  @override
  String get walletAmountTooSmall => '0 से बड़ी राशि दर्ज करें';

  @override
  String get walletAmountTooLarge => 'राशि ₹1,000,000 से अधिक नहीं हो सकती';

  @override
  String get walletSignInPrompt =>
      'अपना ELK वॉलेट और रिवॉर्ड पॉइंट इस्तेमाल करने के लिए साइन इन करें।';

  @override
  String get walletAvailableBalance => 'उपलब्ध शेष';

  @override
  String get walletTransactionHistory => 'लेन-देन का इतिहास';

  @override
  String get statusConfirmed => 'पुष्ट';

  @override
  String get statusPendingVendor => 'विक्रेता की प्रतीक्षा';

  @override
  String get statusCompleted => 'पूर्ण';

  @override
  String get statusCancelled => 'रद्द';

  @override
  String get statusUnknown => 'अज्ञात';

  @override
  String get myBookingsTitle => 'मेरी बुकिंग';

  @override
  String get bookingsSignInPrompt =>
      'आपने जो सेवाएँ बुक की हैं उन्हें देखने के लिए साइन इन करें।';

  @override
  String get tabUpcoming => 'आगामी';

  @override
  String get emptyUpcomingTitle => 'कोई आगामी बुकिंग नहीं';

  @override
  String get emptyUpcomingBody => 'कोई सेवा बुक करें, वह यहाँ दिखेगी।';

  @override
  String get emptyCompletedTitle => 'अभी कुछ पूरा नहीं हुआ';

  @override
  String get emptyCompletedBody => 'आपकी पूरी हुई बुकिंग यहाँ दिखेंगी।';

  @override
  String get emptyCancelledTitle => 'कोई रद्द बुकिंग नहीं';

  @override
  String get emptyCancelledBody => 'रद्द की गई बुकिंग यहाँ दिखेंगी।';

  @override
  String get bookingDetailsTitle => 'बुकिंग विवरण';

  @override
  String get sectionStatus => 'स्थिति';

  @override
  String get sectionScheduleAddress => 'समय और पता';

  @override
  String get labelDateTime => 'तारीख़ और समय';

  @override
  String get labelServiceAddress => 'सेवा का पता';

  @override
  String get sectionVendor => 'विक्रेता';

  @override
  String get vendorContactUnavailable =>
      'विक्रेता का संपर्क अभी उपलब्ध नहीं है';

  @override
  String get callAction => 'कॉल';

  @override
  String get sectionPayment => 'भुगतान';

  @override
  String get lineService => 'सेवा';

  @override
  String get totalPaid => 'कुल भुगतान';

  @override
  String get totalCancelled => 'कुल (रद्द)';

  @override
  String get bookingId => 'बुकिंग आईडी';

  @override
  String get copyAction => 'कॉपी';

  @override
  String get cancelIsFreeNote =>
      'आगामी बुकिंग रद्द करना मुफ़्त है और आपका स्लॉट तुरंत खाली हो जाता है।';

  @override
  String get rebookThisService => 'यह सेवा फिर बुक करें';

  @override
  String get ratedStar => 'रेट किया ★';

  @override
  String get rateAction => 'रेट करें';

  @override
  String get rebookAction => 'फिर बुक करें';

  @override
  String get trackOrder => 'ऑर्डर ट्रैक करें';

  @override
  String get cancelling => 'रद्द किया जा रहा है…';

  @override
  String get cancelBooking => 'बुकिंग रद्द करें';

  @override
  String get cancelBookingQuestion => 'यह बुकिंग रद्द करें?';

  @override
  String get whyCancelling => 'आप क्यों रद्द कर रहे हैं?';

  @override
  String get cancelReasonPlans => 'योजना बदल गई';

  @override
  String get cancelReasonAlternative => 'दूसरा विकल्प मिल गया';

  @override
  String get cancelReasonWrongTime => 'ग़लत तारीख़/समय';

  @override
  String get cancelReasonExpensive => 'बहुत महँगा';

  @override
  String get cancelReasonOther => 'अन्य';

  @override
  String get cancellingIsFreePrefix => 'रद्द करना मुफ़्त है — ';

  @override
  String get cancellingIsFreeSuffix => ' इस बुकिंग के लिए नहीं लिया जाएगा।';

  @override
  String get keepBooking => 'बुकिंग रखें';

  @override
  String get rebookHint => 'सेवाएँ टैब से सेवा फिर चुनें';

  @override
  String get copiedBookingId => 'बुकिंग आईडी कॉपी हो गई';

  @override
  String get cancelledNothingCharged => 'रद्द — कोई शुल्क नहीं लिया गया';

  @override
  String get viewDetails => 'विवरण देखें';

  @override
  String get bookingCancelledToast => 'बुकिंग रद्द हो गई';

  @override
  String get timelineBooked => 'बुक हुआ';

  @override
  String get timelineBookedSub => 'ऑर्डर दिया गया';

  @override
  String get timelineConfirmedSub => 'विक्रेता ने स्वीकार किया';

  @override
  String get timelineInProgress => 'चल रहा है';

  @override
  String get timelineInProgressSub => 'उसी दिन';

  @override
  String get timelineCompletedSub => 'सेवा पूरी हुई';

  @override
  String get timelineRefundIssued => 'रिफ़ंड ELK वॉलेट में भेजा गया';

  @override
  String get bookingNotScheduled => 'समय तय नहीं';

  @override
  String get dateToday => 'आज';

  @override
  String get dateTomorrow => 'कल';

  @override
  String get dateYesterday => 'कल';

  @override
  String walletRewardPoints(int points) {
    return '$points रिवॉर्ड पॉइंट';
  }

  @override
  String vendorSpecialist(String service) {
    return '$service विशेषज्ञ';
  }

  @override
  String get svcTaxiRides => 'टैक्सी और सवारी';

  @override
  String get svcCleaning => 'सफ़ाई';

  @override
  String get svcCarRental => 'कार किराया';

  @override
  String get svcRepair => 'मरम्मत';

  @override
  String get svcPorterMovers => 'पोर्टर और मूवर्स';

  @override
  String get svcEconomyTaxi => 'इकॉनमी टैक्सी';

  @override
  String get svcPremiumTaxi => 'प्रीमियम टैक्सी';

  @override
  String get svcAuto => 'ऑटो';

  @override
  String get svcXlVan => 'XL वैन';

  @override
  String get svcPgStay => 'पीजी ठहराव';

  @override
  String get svcMensHostel => 'पुरुष हॉस्टल';

  @override
  String get svcWomensHostel => 'महिला हॉस्टल';

  @override
  String get svcHomestay => 'होमस्टे';

  @override
  String get svcHomeCleaning => 'घर की सफ़ाई';

  @override
  String get svcDeepCleaning => 'गहरी सफ़ाई';

  @override
  String get svcSofaUpholstery => 'सोफ़ा और अपहोल्स्ट्री';

  @override
  String get svcKitchenCleaning => 'रसोई की सफ़ाई';

  @override
  String get svcBathroomCleaning => 'बाथरूम की सफ़ाई';

  @override
  String get svcCarpetRug => 'कालीन और दरी';

  @override
  String get svcLaundryIron => 'कपड़े धुलाई और इस्त्री';

  @override
  String get svcWashFold => 'धुलाई और तह';

  @override
  String get svcWaterTank => 'पानी की टंकी';

  @override
  String get svcSedan => 'सेडान';

  @override
  String get svcSuv => 'एसयूवी';

  @override
  String get svcLuxury => 'लक्ज़री';

  @override
  String get svcVan => 'वैन';

  @override
  String get svcAcCooling => 'एसी और कूलिंग';

  @override
  String get svcPlumbing => 'प्लंबिंग';

  @override
  String get svcElectrical => 'बिजली का काम';

  @override
  String get svcCarpentry => 'बढ़ईगीरी';

  @override
  String get svcPainting => 'पेंटिंग';

  @override
  String get svcHandyman => 'हैंडीमैन';

  @override
  String get svcBikeDelivery => 'बाइक डिलीवरी';

  @override
  String get svcMiniTruck => 'मिनी ट्रक';

  @override
  String get svcHouseShifting => 'घर शिफ़्टिंग';

  @override
  String get svcMoversPackers => 'मूवर्स और पैकर्स';

  @override
  String get svcSearchHint => 'सेवाएँ खोजें… (जैसे एसी, टैक्सी)';

  @override
  String get rideBlurbAuto => 'किफ़ायती ऑटो-रिक्शा सवारी';

  @override
  String get rideBlurbEconomy => 'रोज़ के लिए किफ़ायती कारें';

  @override
  String get rideBlurbPremium => 'शीर्ष रेटेड प्रीमियम कारें';

  @override
  String get rideBlurbXl => 'परिवार, समूह और बड़े सामान के लिए';

  @override
  String get rideBlurbAutoShort => 'किफ़ायती रिक्शा सवारी';

  @override
  String get rideBlurbEconomyShort => 'रोज़ की किफ़ायती सवारी';

  @override
  String get rideBlurbPremiumShort => 'ज़्यादा जगह, बेहतरीन ड्राइवर';

  @override
  String get taxiSignInPrompt =>
      'सवारी बुक करने के लिए मोबाइल नंबर से साइन इन करें।';

  @override
  String get taxiBookARide => 'सवारी बुक करें';

  @override
  String get taxiNoRideTypes => 'अभी कोई राइड श्रेणी उपलब्ध नहीं है।';

  @override
  String get taxiChooseRide => 'अपनी सवारी चुनें';

  @override
  String get taxiPickup => 'पिकअप';

  @override
  String get taxiDropoff => 'ड्रॉप-ऑफ़';

  @override
  String get sortRecommended => 'सुझाया गया';

  @override
  String get sortFaster => 'तेज़';

  @override
  String get sortCheaper => 'सस्ता';

  @override
  String get payCash => 'नकद';

  @override
  String get payCard => 'क्रेडिट / डेबिट कार्ड';

  @override
  String get payElkWallet => 'ELK वॉलेट';

  @override
  String get payApplePay => 'Apple Pay';

  @override
  String get payApplePayGooglePay => 'Apple Pay / Google Pay';

  @override
  String get payCashSub => 'पहुँचने पर ड्राइवर को भुगतान की पुष्टि करें';

  @override
  String get payCardSub => 'वीज़ा, मास्टरकार्ड और अन्य';

  @override
  String get payWalletSub => 'अपने ELK वॉलेट बैलेंस से भुगतान करें';

  @override
  String get payApplePaySub => 'तेज़ और सुरक्षित चेकआउट';

  @override
  String get changeAction => 'बदलें';

  @override
  String get bookPrefix => 'बुक करें ';

  @override
  String get fare => 'किराया';

  @override
  String get cancellationFee => 'रद्दीकरण';

  @override
  String get seats => 'सीटें';

  @override
  String get fareEstimateNote =>
      'कुल किराया दूरी और समय के आधार पर अनुमानित है। चेकआउट पर अधिभार, पीक प्राइसिंग या टोल शुल्क जुड़ सकते हैं।';

  @override
  String get choosePickupLocation => 'पिकअप स्थान चुनें';

  @override
  String get chooseDropoffLocation => 'ड्रॉप-ऑफ़ स्थान चुनें';

  @override
  String get fareBase => 'आधार किराया';

  @override
  String get fareBookingFee => 'बुकिंग शुल्क';

  @override
  String get assigningDriver => 'ड्राइवर तय किया जा रहा है…';

  @override
  String get detailsOnTheWay => 'विवरण आ रहा है';

  @override
  String get couldNotBookRide => 'सवारी बुक नहीं हो सकी।';

  @override
  String get findingDriver => 'ड्राइवर ढूँढ़ रहे हैं';

  @override
  String get lookingForDrivers => 'आस-पास के ड्राइवर ढूँढ़ रहे हैं';

  @override
  String get driverAssigned => 'ड्राइवर तय हो गया';

  @override
  String get completePaymentNote =>
      'बुकिंग की पुष्टि के लिए भुगतान पूरा करें। इसके तुरंत बाद आपका ट्रिप OTP मिलेगा।';

  @override
  String get proceedToPayment => 'भुगतान पर जाएँ';

  @override
  String get amountDue => 'देय राशि';

  @override
  String get total => 'कुल';

  @override
  String get selectPaymentMethod => 'भुगतान का तरीका चुनें';

  @override
  String get paymentsSecured => 'भुगतान 256-बिट एन्क्रिप्शन से सुरक्षित';

  @override
  String get cardYourName => 'आपका नाम';

  @override
  String get cardDetails => 'कार्ड विवरण';

  @override
  String get cardHolder => 'कार्ड धारक';

  @override
  String get cardExpires => 'समाप्ति';

  @override
  String get cardNumber => 'कार्ड नंबर';

  @override
  String get cardExpiry => 'समाप्ति';

  @override
  String get cardCvv => 'सीवीवी';

  @override
  String get cardholderName => 'कार्डधारक का नाम';

  @override
  String get cardAsShown => 'जैसा कार्ड पर लिखा है';

  @override
  String get saveCardForFuture => 'भविष्य के भुगतान के लिए कार्ड सहेजें';

  @override
  String get otpBeingPrepared => 'आपका OTP तैयार किया जा रहा है';

  @override
  String get driverOnTheWay => 'ड्राइवर रास्ते में है';

  @override
  String get shareOtpToStart => 'यात्रा शुरू करने के लिए यह OTP बताएँ';

  @override
  String get safety => 'सुरक्षा';

  @override
  String get shareTrip => 'यात्रा साझा करें';

  @override
  String get driverArrivedStartTrip => 'ड्राइवर आ गया · यात्रा शुरू करें';

  @override
  String get couldNotStartTrip => 'यात्रा शुरू नहीं हो सकी।';

  @override
  String get tripInProgress => 'यात्रा चल रही है';

  @override
  String get headingTo => 'जा रहे हैं';

  @override
  String get completeTrip => 'यात्रा पूरी करें';

  @override
  String get couldNotCompleteTrip => 'यात्रा पूरी नहीं हो सकी।';

  @override
  String get distance => 'दूरी';

  @override
  String get duration => 'अवधि';

  @override
  String get farePaid => 'किराया · भुगतान';

  @override
  String get addATip => 'टिप जोड़ें';

  @override
  String get noTip => 'कोई टिप नहीं';

  @override
  String get finishTrip => 'यात्रा समाप्त करें';

  @override
  String get couldNotSubmitRating => 'आपकी रेटिंग नहीं भेजी जा सकी।';

  @override
  String get allDoneThanks => 'हो गया — सवारी के लिए धन्यवाद!';

  @override
  String get trip => 'यात्रा';

  @override
  String get driver => 'ड्राइवर';

  @override
  String get tip => 'टिप';

  @override
  String get transactionId => 'लेन-देन आईडी';

  @override
  String get receiptDownloaded => 'रसीद डाउनलोड हो गई';

  @override
  String get download => 'डाउनलोड';

  @override
  String get bookAnotherTrip => 'एक और यात्रा बुक करें';

  @override
  String svcNoMatch(String query) {
    return '\"$query\" से कोई सेवा मेल नहीं खाती।\n\"एसी\", \"टैक्सी\" या \"सफ़ाई\" आज़माएँ।';
  }

  @override
  String rideSeats(int seats) {
    return '$seats सीटें';
  }

  @override
  String fareDistance(String km) {
    return 'दूरी ($km किमी)';
  }

  @override
  String fareTime(int minutes) {
    return 'समय ($minutes मिनट)';
  }

  @override
  String tipWillBeCharged(String amount, String method) {
    return '$amount आपके $method से लिया जाएगा';
  }

  @override
  String totalVia(String method) {
    return '$method से कुल';
  }

  @override
  String get addServiceAddress => 'सेवा का पता जोड़ें';

  @override
  String get cleanSignInPrompt =>
      'सफ़ाई सेवाएँ बुक करने के लिए मोबाइल नंबर से साइन इन करें।';

  @override
  String get topOffers => 'बेहतरीन ऑफ़र';

  @override
  String get goodAfternoon => 'नमस्कार';

  @override
  String get cleanSearchHint => '\"डीप क्लीन\", \"टंकी\" खोजें…';

  @override
  String get playUnlockDeals => 'खेलें और समर डील पाएँ!';

  @override
  String get getWaterTankCleaning => 'पानी की टंकी की सफ़ाई पाएँ ';

  @override
  String get whatNeedsCleaning => 'क्या साफ़ करना है?';

  @override
  String get codeLabel => 'कोड: ';

  @override
  String get ecoFriendlyProducts =>
      'पर्यावरण-अनुकूल, बच्चों के लिए सुरक्षित उत्पाद';

  @override
  String get trainedCleaners => 'प्रशिक्षित और वर्दीधारी सफ़ाईकर्मी';

  @override
  String get fromLabel => 'से';

  @override
  String get howWeDoIt => 'हम कैसे करते हैं';

  @override
  String get hygieneAfterService => 'सेवा के बाद स्वच्छता स्तर';

  @override
  String get beforeLabel => 'पहले';

  @override
  String get afterLabTested => 'बाद · लैब-परीक्षित';

  @override
  String get elkCleanCrew => 'ELKclean टीम';

  @override
  String get crewBlurb => 'वर्दीधारी · इको किट · 1,200+ सफ़ाई से 4.9';

  @override
  String get priceCaps => 'कीमत';

  @override
  String get yourCleanPlan => 'आपकी सफ़ाई योजना';

  @override
  String get addPromoCode => 'प्रोमो कोड जोड़ें';

  @override
  String get subtotal => 'उप-योग';

  @override
  String get ecoSuppliesSetup => 'इको सामग्री और सेटअप';

  @override
  String get selectDate => 'तारीख़ चुनें';

  @override
  String get arrivalWindow => 'आने का समय';

  @override
  String get fillsFast => 'जल्दी भर जाता है';

  @override
  String get available => 'उपलब्ध';

  @override
  String get crewArrivalNote =>
      'आपकी टीम 2 घंटे की अवधि में सारी सामग्री के साथ आएगी। उस दिन लाइव ट्रैकिंग लिंक भेजा जाएगा।';

  @override
  String get serviceAddress => 'सेवा का पता';

  @override
  String get savedPlaces => 'सहेजे गए स्थान';

  @override
  String get noSavedAddresses => 'अभी कोई सहेजा पता नहीं — नीचे जोड़ें।';

  @override
  String get addNewAddress => 'नया पता जोड़ें';

  @override
  String get addServiceAddressFirst => 'कृपया पहले सेवा का पता जोड़ें।';

  @override
  String get reviewConfirm => 'समीक्षा और पुष्टि';

  @override
  String get whenLabel => 'कब';

  @override
  String get whereLabel => 'कहाँ';

  @override
  String get contactLabel => 'संपर्क';

  @override
  String get verifiedAccount => 'सत्यापित खाता';

  @override
  String get orderSummary => 'ऑर्डर सारांश';

  @override
  String get totalToPay => 'कुल देय';

  @override
  String get recleanGuarantee =>
      'खुश नहीं? हम 48 घंटे में मुफ़्त दोबारा सफ़ाई करेंगे। 2 घंटे पहले तक मुफ़्त रद्दीकरण।';

  @override
  String get payCardBrands => 'वीज़ा, मास्टरकार्ड, एमेक्स';

  @override
  String get payOneTapCheckout => 'एक टैप में सुरक्षित चेकआउट';

  @override
  String get chooseMethod => 'तरीका चुनें';

  @override
  String get nameOnCard => 'कार्ड पर नाम';

  @override
  String get saveCardFasterCheckout => 'तेज़ चेकआउट के लिए कार्ड सहेजें';

  @override
  String get processing => 'प्रोसेस हो रहा है…';

  @override
  String get paymentFailed => 'भुगतान विफल। कृपया फिर कोशिश करें।';

  @override
  String get paidLabel => 'भुगतान किया';

  @override
  String get paidCaps => 'भुगतान';

  @override
  String get trackMyClean => 'मेरी सफ़ाई ट्रैक करें';

  @override
  String get noServicesYet => 'अभी कोई सेवा नहीं';

  @override
  String get browseCleaningBlurb => 'सफ़ाई सेवाएँ देखें और अपनी योजना बनाएँ।';

  @override
  String get browseServices => 'सेवाएँ देखें';

  @override
  String paySecurely(String amount) {
    return '$amount सुरक्षित भुगतान करें';
  }

  @override
  String servicesAdded(int count) {
    return '$count सेवाएँ जोड़ी गईं';
  }

  @override
  String get repairSignInPrompt =>
      'मरम्मत बुक करने के लिए मोबाइल नंबर से साइन इन करें।';

  @override
  String get repairSearchHint => '\"एसी सर्विस\", \"लीक\" खोजें…';

  @override
  String get summerReady => 'गर्मी के लिए तैयार';

  @override
  String get whatNeedsFixing => 'क्या ठीक करना है?';

  @override
  String get whatsIncluded => 'इसमें क्या शामिल है';

  @override
  String get topRatedCrew => 'शीर्ष रेटेड टीम';

  @override
  String get techCrewBlurb => 'बुकिंग के बाद तय · 800+ कामों से औसत 4.9';

  @override
  String get yourWorkOrder => 'आपका वर्क ऑर्डर';

  @override
  String get visitInspectionFee => 'विज़िट और निरीक्षण शुल्क';

  @override
  String get techArrivalNote =>
      'आपका तकनीशियन 2 घंटे की अवधि में आएगा। उस दिन आपको लाइव ट्रैकिंग लिंक मिलेगा।';

  @override
  String get chargedAfterComplete =>
      'काम पूरा होने की पुष्टि के बाद ही शुल्क लिया जाता है। 2 घंटे पहले तक मुफ़्त रद्दीकरण।';

  @override
  String get trackMyBooking => 'मेरी बुकिंग ट्रैक करें';

  @override
  String get browseTradesBlurb => 'सेवाएँ देखें और जो ठीक करना है वह जोड़ें।';

  @override
  String get rentalSignInPrompt =>
      'कार किराए पर लेने के लिए मोबाइल नंबर से साइन इन करें।';

  @override
  String get carsAvailable => 'कारें उपलब्ध';

  @override
  String get sortPrice => 'क्रम: कीमत';

  @override
  String get noCarsInCategory => 'इस श्रेणी में अभी कोई कार नहीं है।';

  @override
  String get bookNow => 'अभी बुक करें';

  @override
  String get porterSignInPrompt =>
      'पैकेज भेजने के लिए मोबाइल नंबर से साइन इन करें।';

  @override
  String get selectVehicle => 'वाहन चुनें';

  @override
  String get pricingUpdates => 'आपकी पसंद के अनुसार कीमत बदलती है';

  @override
  String get addOns => 'अतिरिक्त';

  @override
  String get porterLogistics => 'पोर्टर और लॉजिस्टिक्स';

  @override
  String get pickupLocation => 'पिकअप स्थान';

  @override
  String get dropLocation => 'ड्रॉप स्थान';

  @override
  String get packageType => 'पैकेज का प्रकार';

  @override
  String get packageElectronics => 'इलेक्ट्रॉनिक्स';

  @override
  String get weight => 'वज़न';

  @override
  String get estimatedTime => 'अनुमानित समय';

  @override
  String get estimatedFare => 'अनुमानित किराया';

  @override
  String get bookPorter => 'पोर्टर बुक करें';

  @override
  String get couldNotBookDelivery => 'डिलीवरी बुक नहीं हो सकी।';

  @override
  String get stepSchedule => 'समय';

  @override
  String get pickUpNow => 'अभी पिकअप';

  @override
  String get scheduleForLater => 'बाद के लिए तय करें';

  @override
  String get pickupDate => 'पिकअप की तारीख़';

  @override
  String get selectDateAction => 'तारीख़ चुनें';

  @override
  String get pickupWindow => 'पिकअप का समय';

  @override
  String get estTime => 'अनु. समय';

  @override
  String get continueToPayment => 'भुगतान पर जाएँ';

  @override
  String get payCardBrandsShort => 'वीज़ा, मास्टरकार्ड';

  @override
  String get payCashOnDelivery => 'डिलीवरी पर नकद';

  @override
  String get deliveryFare => 'डिलीवरी किराया';

  @override
  String get serviceFee => 'सेवा शुल्क';

  @override
  String get gstFivePercent => 'जीएसटी (5%)';

  @override
  String get continueToCardDetails => 'कार्ड विवरण पर जाएँ';

  @override
  String get amount => 'राशि';

  @override
  String get confirmAndPay => 'पुष्टि करें और भुगतान करें';

  @override
  String get completeCardDetails => 'कृपया कार्ड के सभी विवरण भरें';

  @override
  String get paymentsSecuredByElk => 'भुगतान ELK गेटवे से सुरक्षित';

  @override
  String get processingPayment => 'भुगतान हो रहा है';

  @override
  String get confirmingWithBank =>
      'आपके बैंक से पुष्टि हो रही है, यह स्क्रीन बंद न करें';

  @override
  String get bookingConfirmed => 'बुकिंग पक्की हुई';

  @override
  String get porterNotified => 'आपके पोर्टर को सूचित कर दिया गया है';

  @override
  String get trackingId => 'ट्रैकिंग आईडी';

  @override
  String get vehicle => 'वाहन';

  @override
  String get arrival => 'आगमन';

  @override
  String get amountPaid => 'भुगतान की गई राशि';

  @override
  String get receiptSentToEmail => 'रसीद आपके ईमेल पर भेजी गई';

  @override
  String get viewReceipt => 'रसीद देखें →';

  @override
  String get stepTripDetails => 'यात्रा विवरण';

  @override
  String get stepPickupDelivery => 'पिकअप और डिलीवरी';

  @override
  String get stepExtrasProtection => 'अतिरिक्त और सुरक्षा';

  @override
  String get stepLocation => 'स्थान';

  @override
  String get stepExtras => 'अतिरिक्त';

  @override
  String get stepReview => 'समीक्षा';

  @override
  String get stepPay => 'भुगतान';

  @override
  String get yourAccount => 'आपका खाता';

  @override
  String get branch => 'शाखा';

  @override
  String get securedByElkPay => 'ELK Pay से सुरक्षित · 256-बिट एन्क्रिप्शन';

  @override
  String get totalSoFar => 'अब तक कुल';

  @override
  String get whenDoYouNeedIt => 'आपको कब चाहिए?';

  @override
  String get pickPlanAndDates =>
      'अपना किराया प्लान और यात्रा की तारीख़ें चुनें';

  @override
  String get rateDaily => 'दैनिक';

  @override
  String get rateWeekly => 'साप्ताहिक · 15% छूट';

  @override
  String get rateMonthly => 'मासिक · 30% छूट';

  @override
  String get pickupDateTime => 'पिकअप की तारीख़ और समय';

  @override
  String get whenRentalBegins => 'आपका किराया कब शुरू होता है';

  @override
  String get returnDateTime => 'वापसी की तारीख़ और समय';

  @override
  String get whenRentalEnds => 'आपका किराया कब खत्म होता है';

  @override
  String get rentalLength => 'किराए की अवधि';

  @override
  String get rentalBillingNote =>
      'किराया पूरे दिनों में लिया जाता है। कार 59 मिनट से ज़्यादा देर से लौटाने पर एक अतिरिक्त दिन लगेगा।';

  @override
  String get howGetYourCar => 'आप अपनी कार कैसे लेना चाहेंगे?';

  @override
  String get collectOrDelivered => 'खुद लें या अपने पते पर मँगवाएँ';

  @override
  String get selfPickup => 'खुद लें';

  @override
  String get collectFromBranch => 'ELK शाखा से लें';

  @override
  String get free => 'मुफ़्त';

  @override
  String get carDelivery => 'कार डिलीवरी';

  @override
  String get weBringIt => 'हम इसे आपके पते पर लाते हैं';

  @override
  String get chooseBranch => 'शाखा चुनें';

  @override
  String get mapPreviewHint =>
      'मानचित्र पूर्वावलोकन · दिशा-निर्देश के लिए टैप करें';

  @override
  String get deliveryAddress => 'डिलीवरी का पता';

  @override
  String get deliveryAddressHint => 'जैसे कोरमंगला, बेंगलुरु';

  @override
  String get buildingVillaNo => 'बिल्डिंग / विला नं.';

  @override
  String get driverDirections => 'ड्राइवर के लिए निर्देश (वैकल्पिक)';

  @override
  String get driverDirectionsHint => 'गेट कोड, लैंडमार्क, पार्किंग नोट…';

  @override
  String get locationCaptured => 'स्थान ले लिया गया';

  @override
  String get useCurrentLocation => 'मेरा वर्तमान स्थान इस्तेमाल करें';

  @override
  String get deliveryFeeNote =>
      'डिलीवरी शुल्क ₹25 · कार आपके पिकअप समय के 2 घंटे में आती है।';

  @override
  String get enhanceYourTrip => 'अपनी यात्रा बेहतर बनाएँ';

  @override
  String get optionalAddOns =>
      'वैकल्पिक अतिरिक्त — जो आपकी यात्रा के लिए सही हो चुनें';

  @override
  String get reviewYourBooking => 'अपनी बुकिंग देखें';

  @override
  String get doubleCheckBeforePay => 'भुगतान से पहले सब कुछ जाँच लें';

  @override
  String get bookingAsYourself => 'आप अपने लिए बुक कर रहे हैं';

  @override
  String get tripDates => 'यात्रा की तारीख़ें';

  @override
  String get priceBreakdown => 'कीमत का विवरण';

  @override
  String get deliveryFee => 'डिलीवरी शुल्क';

  @override
  String get promoCodeHint => 'प्रोमो कोड — ELK10 आज़माएँ';

  @override
  String get totalInclGst => 'कुल (5% जीएसटी सहित)';

  @override
  String get iAgreeToThe => 'मैं सहमत हूँ ';

  @override
  String get rentalTerms => 'किराए की शर्तें';

  @override
  String get enterPromoFirst => 'पहले प्रोमो कोड दर्ज करें';

  @override
  String get promoNotValid => 'यह कोड मान्य नहीं है';

  @override
  String get cashOnPickup => 'पिकअप पर नकद';

  @override
  String get chooseHowToPay => 'चुनें कि आप कैसे भुगतान करना चाहते हैं';

  @override
  String get cardLabel => 'कार्ड';

  @override
  String get saveCardNextTime => 'अगली बार तेज़ चेकआउट के लिए यह कार्ड सहेजें';

  @override
  String get payWithDigitalWallet => 'अपने डिजिटल वॉलेट से भुगतान करें';

  @override
  String get walletRedirectNote =>
      'भुगतान सुरक्षित रूप से पूरा करने के लिए आपको भेजा जाएगा, फिर ELK Business Hub पर वापस लाया जाएगा।';

  @override
  String get cashAtBranchNote =>
      'शाखा काउंटर पर कार लेते समय पूरी राशि नकद भुगतान करें।';

  @override
  String get cashToDriverNote =>
      'कार डिलीवर होने पर हमारे ड्राइवर को पूरी राशि नकद भुगतान करें।';

  @override
  String get processingYourPayment => 'आपका भुगतान हो रहा है…';

  @override
  String get dontCloseScreen => 'कृपया यह स्क्रीन बंद न करें';

  @override
  String get bookingConfirmedBang => 'बुकिंग पक्की हुई!';

  @override
  String get deliveredToAddress => 'आपके पते पर डिलीवर';

  @override
  String get showThisAtPickup => 'पिकअप पर यह दिखाएँ';

  @override
  String get viewEReceipt => 'ई-रसीद देखें';

  @override
  String payAmount(String amount) {
    return '$amount भुगतान करें';
  }

  @override
  String confirmAndPayAmount(String amount) {
    return 'पुष्टि करें और $amount भुगतान करें';
  }

  @override
  String branchSelfPickup(String branch) {
    return '$branch (खुद लें)';
  }

  @override
  String daysCount(int days) {
    return '$days दिन';
  }

  @override
  String get payUpiSub => 'GPay, PhonePe, Paytm और अन्य';

  @override
  String get payCardBrandsIn => 'वीज़ा, मास्टरकार्ड, रुपे';

  @override
  String get payNetBanking => 'नेट बैंकिंग';

  @override
  String get payAllMajorBanks => 'सभी प्रमुख बैंक';

  @override
  String get couldNotScheduleVisit => 'विज़िट तय नहीं हो सकी।';

  @override
  String get allStays => 'सभी ठहराव';

  @override
  String get chipAll => 'सभी';

  @override
  String get chipSingle => 'सिंगल';

  @override
  String get chipDouble => 'डबल';

  @override
  String get chipFoodIncl => 'भोजन सहित';

  @override
  String get chipNearMetro => 'मेट्रो के पास';

  @override
  String get staysInArea => 'कोरमंगला में ठहराव';

  @override
  String get sortLabel => 'क्रम ';

  @override
  String get staySignInPrompt =>
      'यह ठहराव देखने के लिए मोबाइल नंबर से साइन इन करें।';

  @override
  String get stayBrowseSignInPrompt =>
      'ठहराव देखने के लिए मोबाइल नंबर से साइन इन करें।';

  @override
  String get foodIncluded => 'भोजन शामिल';

  @override
  String get chooseSharing => 'शेयरिंग चुनें';

  @override
  String get amenities => 'सुविधाएँ';

  @override
  String get ratingsReviews => 'रेटिंग और समीक्षाएँ';

  @override
  String get sampleStayReview =>
      '\"साफ़ कमरे, बढ़िया खाना और बहुत सुरक्षित। वार्डन मददगार हैं और आने-जाने के लिए जगह एकदम सही है।\" — प्रिया एस.';

  @override
  String get startingFrom => 'से शुरू';

  @override
  String get visit => 'विज़िट';

  @override
  String get reserve => 'आरक्षित करें';

  @override
  String get bookYourStay => 'अपना ठहराव बुक करें';

  @override
  String get roomType => 'कमरे का प्रकार';

  @override
  String get moveInDate => 'आने की तारीख़';

  @override
  String get durationCaps => 'अवधि';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get phoneNumber => 'फ़ोन नंबर';

  @override
  String get reviewAndPay => 'समीक्षा और भुगतान';

  @override
  String get paymentSummary => 'भुगतान सारांश';

  @override
  String get firstMonthRent => 'पहले महीने का किराया';

  @override
  String get securityDeposit => 'सिक्योरिटी डिपॉज़िट';

  @override
  String get refundableAtMoveOut => 'जाते समय वापसी योग्य';

  @override
  String get elkServiceFee => 'ELK सेवा शुल्क';

  @override
  String get couponElknew => 'कूपन ELKNEW';

  @override
  String get payableNow => 'अभी देय';

  @override
  String get applyPrefix => 'लागू करें ';

  @override
  String get saveFiveHundred => ' — ₹500 बचाएँ';

  @override
  String get appliedCaps => 'लागू';

  @override
  String get applyCaps => 'लागू करें';

  @override
  String get stayPolicyNote =>
      'जारी रखने पर आप ELK की ठहराव नीति और रद्दीकरण शर्तों से सहमत होते हैं। निरीक्षण के अधीन डिपॉज़िट पूरी तरह वापसी योग्य है।';

  @override
  String get proceedToPay => 'भुगतान पर जाएँ';

  @override
  String get amountPayable => 'देय राशि';

  @override
  String get payUsing => 'इससे भुगतान करें';

  @override
  String get upiId => 'यूपीआई आईडी';

  @override
  String get property => 'संपत्ति';

  @override
  String get room => 'कमरा';

  @override
  String get moveIn => 'आने की तारीख़';

  @override
  String get backToHome => 'होम पर वापस';

  @override
  String get pgStays => 'पीजी ठहराव';

  @override
  String get homestays => 'होमस्टे';

  @override
  String get statusVisitBooked => 'विज़िट बुक हुई';

  @override
  String get statusPending => 'लंबित';

  @override
  String get chooseRoomFirst => 'कृपया पहले कमरे का विकल्प चुनें।';

  @override
  String get whatAreYouLookingFor => 'आप क्या ढूँढ़ रहे हैं?';

  @override
  String get topRatedNearYou => 'आपके पास शीर्ष रेटेड';

  @override
  String get goodMorning => 'सुप्रभात,';

  @override
  String get staySearchHint => 'क्षेत्र, कॉलेज या पीजी खोजें';

  @override
  String get noStaysFound => 'कोई ठहराव नहीं मिला';

  @override
  String get underTwelveK => '₹12 हज़ार से कम';

  @override
  String get singleRoom => 'सिंगल कमरा';

  @override
  String get meals => 'भोजन';

  @override
  String get womensPg => 'महिला पीजी';

  @override
  String get savedStays => 'सहेजे गए ठहराव';

  @override
  String get noSavedStaysYet => 'अभी कोई सहेजा गया ठहराव नहीं';

  @override
  String get noSavedStaysBody => 'किसी ठहराव पर दिल दबाएँ ताकि वह यहाँ रहे।';

  @override
  String get savedStaysSignIn =>
      'अपने सहेजे गए ठहराव देखने के लिए साइन इन करें।';

  @override
  String get myStays => 'मेरे ठहराव';

  @override
  String get noStaysHereYet => 'अभी यहाँ कोई ठहराव नहीं';

  @override
  String get tabActive => 'सक्रिय';

  @override
  String get tabRequests => 'अनुरोध';

  @override
  String get tabPast => 'पिछले';

  @override
  String get rent => 'किराया';

  @override
  String visitScheduledFor(String date) {
    return '$date, शाम 5 बजे विज़िट तय';
  }

  @override
  String monthsCount(int months) {
    return '$months महीने';
  }

  @override
  String get accept => 'स्वीकारें';

  @override
  String get accepted => 'स्वीकृत';

  @override
  String get acceptJob => 'काम स्वीकारें';

  @override
  String get accountHolderName => 'खाताधारक का नाम';

  @override
  String get accountNumber => 'खाता संख्या';

  @override
  String get accountVerified => 'खाता ••••4821 · सत्यापित';

  @override
  String get activeJobs => 'सक्रिय काम';

  @override
  String get addAccountToWithdraw => 'कमाई निकालने के लिए अपना खाता जोड़ें';

  @override
  String get addAddress => 'पता जोड़ें';

  @override
  String get addAnAddress => 'एक पता जोड़ें';

  @override
  String get addCommentOptional => 'टिप्पणी जोड़ें (वैकल्पिक)';

  @override
  String get addedToActiveJobs => 'सक्रिय कामों में जोड़ा गया';

  @override
  String get addedToYourActiveJobs => 'आपके सक्रिय कामों में जोड़ा गया';

  @override
  String get addPayoutFirst => 'पहले भुगतान का तरीका जोड़ें';

  @override
  String get addressesSignInPrompt =>
      'बुकिंग के पते सहेजने के लिए साइन इन करें।';

  @override
  String get addressLabelHint => 'लेबल (घर, ऑफ़िस…)';

  @override
  String get addressLineHint => 'बिल्डिंग, गली, क्षेत्र';

  @override
  String get addressTooLong => 'पता 255 अक्षरों से अधिक नहीं होना चाहिए';

  @override
  String get adSubmitted => 'विज्ञापन समीक्षा के लिए भेजा गया';

  @override
  String get allClear => 'सब ठीक है';

  @override
  String get amountToPay => 'देय राशि';

  @override
  String get applicationReviewNote =>
      'हम आपके विवरण की समीक्षा करेंगे और 24-48 घंटों में दस्तावेज़ सत्यापित करेंगे। खाता स्वीकृत होने पर आपको सूचना मिलेगी।';

  @override
  String get applicationSubmitted => 'आवेदन जमा हुआ!';

  @override
  String get asPrintedOnAccount => 'जैसा आपके बैंक खाते पर छपा है';

  @override
  String get availability => 'उपलब्धता';

  @override
  String get availableNow => 'अभी उपलब्ध';

  @override
  String get availableOffers => 'उपलब्ध ऑफ़र';

  @override
  String get availableToWithdraw => 'निकालने के लिए उपलब्ध';

  @override
  String get avgPerJob => 'प्रति काम औसत';

  @override
  String get bankLinked => 'बैंक जुड़ गया';

  @override
  String get bankName => 'बैंक का नाम';

  @override
  String get booked => 'बुक';

  @override
  String get bookingAccepted => 'बुकिंग स्वीकृत';

  @override
  String get bookingReference => 'बुकिंग संदर्भ';

  @override
  String get bookingRequest => 'बुकिंग अनुरोध';

  @override
  String get bookingSignInPrompt =>
      'यह सेवा बुक करने के लिए मोबाइल नंबर से साइन इन करें।';

  @override
  String get bookService => 'सेवा बुक करें';

  @override
  String get businessName => 'व्यवसाय का नाम';

  @override
  String get businessNameHint => 'जैसे Royal Shine Co.';

  @override
  String get byAppointment => 'अपॉइंटमेंट से';

  @override
  String get cancelOrder => 'ऑर्डर रद्द करें';

  @override
  String get cancelOrderConfirm => 'क्या आप वाकई यह ऑर्डर रद्द करना चाहते हैं?';

  @override
  String get canNowWithdraw => 'अब आप अपनी कमाई निकाल सकते हैं';

  @override
  String get catPorter => 'पोर्टर';

  @override
  String get catTaxiRide => 'टैक्सी / सवारी';

  @override
  String get chat => 'चैट';

  @override
  String get chatSignInPrompt =>
      'अपने सेवा प्रदाता को संदेश भेजने के लिए साइन इन करें।';

  @override
  String get chatWithProvider => 'प्रदाता से चैट करें';

  @override
  String get chooseCategory => 'श्रेणी चुनें';

  @override
  String get chooseServiceAddress => 'सेवा का पता चुनें';

  @override
  String get claimOfferArrow => 'ऑफ़र लें →';

  @override
  String get completedJobs => 'पूरे किए काम';

  @override
  String get confirmWithdrawal => 'निकासी की पुष्टि करें';

  @override
  String get contactNumber => 'संपर्क नंबर';

  @override
  String get customer => 'ग्राहक';

  @override
  String get customerHasBeenNotified => 'ग्राहक को सूचित कर दिया गया है';

  @override
  String get customerNotified => 'ग्राहक को सूचित किया';

  @override
  String get customersCanBook => 'ग्राहक अब आपको बुक कर सकते हैं';

  @override
  String get decline => 'अस्वीकारें';

  @override
  String get declined => 'अस्वीकृत';

  @override
  String get defaultCaps => 'डिफ़ॉल्ट';

  @override
  String get description => 'विवरण';

  @override
  String get descriptionHint =>
      'बताएँ कि क्या शामिल है, आपका अनुभव, सेवा क्षेत्र…';

  @override
  String get detailsForProfile =>
      'हम इन विवरणों से आपकी प्रदाता प्रोफ़ाइल बनाएँगे।';

  @override
  String get done => 'हो गया';

  @override
  String get earnings => 'कमाई';

  @override
  String get enterAccountHolderName => 'खाताधारक का नाम दर्ज करें';

  @override
  String get enterALabel => 'एक लेबल दर्ज करें';

  @override
  String get enterTheAddress => 'पता दर्ज करें';

  @override
  String get enterValidAccountNumber =>
      'मान्य 9–18 अंकों का खाता नंबर दर्ज करें';

  @override
  String get export => 'निर्यात';

  @override
  String get fixedPrice => 'निश्चित कीमत';

  @override
  String get fundsArriveIn => 'राशि 1–2 कार्यदिवसों में आएगी';

  @override
  String get goesLiveIn24h => '24 घंटों में लाइव होगा';

  @override
  String get guest => 'अतिथि';

  @override
  String get howWasExperience => 'आपका अनुभव कैसा रहा?';

  @override
  String get idDocument => 'पहचान दस्तावेज़';

  @override
  String get idDocumentHint => 'सरकारी फ़ोटो पहचान पत्र अपलोड करें';

  @override
  String get inProgress => 'चल रहा है';

  @override
  String get inReview => 'समीक्षा में';

  @override
  String get labelTooLong => 'लेबल 50 अक्षरों से अधिक नहीं होना चाहिए';

  @override
  String get linkAccount => 'खाता जोड़ें';

  @override
  String get linkBankAccount => 'बैंक खाता जोड़ें';

  @override
  String get listings => 'लिस्टिंग';

  @override
  String get listingTitle => 'लिस्टिंग का शीर्षक';

  @override
  String get listingTitleHint => 'जैसे गहरी घर सफ़ाई (3BHK)';

  @override
  String get liveUpdatesUnavailable =>
      'लाइव अपडेट उपलब्ध नहीं — नए जवाब देखने के लिए चैट फिर खोलें।';

  @override
  String get markAllRead => 'सभी पढ़ा हुआ चिह्नित करें';

  @override
  String get markedAllRead => 'सभी पढ़ा हुआ चिह्नित';

  @override
  String get marking => 'चिह्नित हो रहा है…';

  @override
  String get myListings => 'मेरी लिस्टिंग';

  @override
  String get mySchedule => 'मेरा शेड्यूल';

  @override
  String get newRequest => 'नया अनुरोध';

  @override
  String get newRequests => 'नए अनुरोध';

  @override
  String get noActiveJobs => 'कोई सक्रिय काम नहीं';

  @override
  String get noBankLinked => 'कोई बैंक नहीं जुड़ा';

  @override
  String get noBankLinkedYet => 'अभी कोई बैंक नहीं जुड़ा';

  @override
  String get noEarningsYet => 'अभी कोई कमाई नहीं';

  @override
  String get noNewRequests => 'आपको नए अनुरोध नहीं मिलेंगे';

  @override
  String get noNewRequestsNow => 'अभी कोई नया अनुरोध नहीं';

  @override
  String get noNotificationsYet => 'अभी कोई सूचना नहीं';

  @override
  String get noOffersRunning => 'अभी कोई ऑफ़र नहीं चल रहा — जल्द देखें।';

  @override
  String get noOrdersRightNow => 'अभी यहाँ कोई ऑर्डर नहीं';

  @override
  String get noReviewsYet => 'अभी कोई समीक्षा नहीं';

  @override
  String get noSavedAddressesYet => 'अभी कोई सहेजा पता नहीं';

  @override
  String get nothingHereYet => 'अभी यहाँ कुछ नहीं';

  @override
  String get nothingWaiting => 'कुछ भी लंबित नहीं';

  @override
  String get notificationsSignInPrompt =>
      'अपनी बुकिंग और ऑफ़र अपडेट देखने के लिए साइन इन करें।';

  @override
  String get offersSignInPrompt =>
      'अपने रिवॉर्ड पॉइंट और ऑफ़र देखने के लिए साइन इन करें।';

  @override
  String get offline => 'ऑफ़लाइन';

  @override
  String get orderCancelled => 'ऑर्डर रद्द हुआ';

  @override
  String get orderId => 'ऑर्डर आईडी';

  @override
  String get orders => 'ऑर्डर';

  @override
  String get orderStatus => 'ऑर्डर की स्थिति';

  @override
  String get paused => 'रोका गया';

  @override
  String get payoutMethod => 'भुगतान का तरीका';

  @override
  String get perDay => 'प्रति दिन';

  @override
  String get perHour => 'प्रति घंटा';

  @override
  String get pickServiceType =>
      'आप जो सेवा या वस्तु सूचीबद्ध कर रहे हैं उसका प्रकार चुनें';

  @override
  String get post => 'पोस्ट';

  @override
  String get postNewAd => 'नया विज्ञापन डालें';

  @override
  String get price => 'कीमत';

  @override
  String get pricingType => 'कीमत का प्रकार';

  @override
  String get promoTwentyOffFirstBooking => 'पहली बुकिंग पर 20% छूट';

  @override
  String get provider => 'प्रदाता';

  @override
  String get providerSignInPrompt =>
      'अपना प्रदाता खाता प्रबंधित करने के लिए साइन इन करें।';

  @override
  String get publishAd => 'विज्ञापन प्रकाशित करें';

  @override
  String get quickActions => 'त्वरित क्रियाएँ';

  @override
  String get rateYourExperience => 'अपना अनुभव रेट करें';

  @override
  String get recentBookings => 'हाल की बुकिंग';

  @override
  String get recentTransactions => 'हाल के लेन-देन';

  @override
  String get removeAddress => 'पता हटाएँ';

  @override
  String get rename => 'नाम बदलें';

  @override
  String get renameAddress => 'पते का नाम बदलें';

  @override
  String get reviewSignInPrompt =>
      'बुक की गई सेवाओं को रेट करने के लिए साइन इन करें।';

  @override
  String get saveDraft => 'ड्राफ़्ट सहेजें';

  @override
  String get selectDateTitle => 'तारीख़ चुनें';

  @override
  String get selectTime => 'समय चुनें';

  @override
  String get serviceArea => 'सेवा क्षेत्र';

  @override
  String get serviceAreaHint => 'जैसे बेंगलुरु शहर';

  @override
  String get serviceCategory => 'सेवा श्रेणी';

  @override
  String get serviceSignInPrompt =>
      'यह सेवा देखने के लिए मोबाइल नंबर से साइन इन करें।';

  @override
  String get setAsDefault => 'डिफ़ॉल्ट बनाएँ';

  @override
  String get shareDetailsHint => 'अपने अनुभव के बारे में बताएँ...';

  @override
  String get statement => 'विवरण';

  @override
  String get submitApplication => 'आवेदन जमा करें';

  @override
  String get submitReview => 'समीक्षा भेजें';

  @override
  String get tapChangeToChoose => 'अपना पता चुनने के लिए बदलें दबाएँ';

  @override
  String get teamSize => 'टीम का आकार';

  @override
  String get tellUsAboutBusiness => 'अपने व्यवसाय के बारे में बताएँ';

  @override
  String get todayAtAGlance => 'आज एक नज़र में';

  @override
  String get todaysBookings => 'आज की बुकिंग';

  @override
  String get todaysEarnings => 'आज की कमाई';

  @override
  String get todaysTimeSlots => 'आज के समय स्लॉट';

  @override
  String get trackSignInPrompt => 'अपने ऑर्डर ट्रैक करने के लिए साइन इन करें।';

  @override
  String get tradeLicense => 'व्यापार लाइसेंस';

  @override
  String get tradeLicenseHint =>
      'अपने व्यापार लाइसेंस की साफ़ फ़ोटो या PDF अपलोड करें';

  @override
  String get typeAMessage => 'संदेश लिखें...';

  @override
  String get upload => 'अपलोड';

  @override
  String get uploadDocuments => 'आवश्यक दस्तावेज़ अपलोड करें';

  @override
  String get uploaded => 'अपलोड हो गया';

  @override
  String get verifiedProvidersBlurb =>
      'सत्यापित प्रदाताओं को ज़्यादा बुकिंग और ग्राहक भरोसा मिलता है।';

  @override
  String get viewOrders => 'ऑर्डर देखें';

  @override
  String get weekdaysOnly => 'केवल कार्यदिवस';

  @override
  String get whatWentWell => 'क्या अच्छा रहा?';

  @override
  String get withdrawalRequested => 'निकासी का अनुरोध किया';

  @override
  String get withdrawEarnings => 'कमाई निकालें';

  @override
  String get yesCancel => 'हाँ, रद्द करें';

  @override
  String get youAreOffline => 'आप ऑफ़लाइन हैं';

  @override
  String get youAreOnline => 'आप ऑनलाइन हैं';

  @override
  String get youEarnAfterFee => 'आपकी कमाई (12% शुल्क के बाद)';

  @override
  String get partnerDashboard => 'पार्टनर डैशबोर्ड';

  @override
  String get linkBankToGetPaid => 'भुगतान पाने के लिए बैंक जोड़ें';

  @override
  String get addAccountToTransfer => 'खाता जोड़ें ताकि हम आपकी कमाई भेज सकें';

  @override
  String get addBankAccount => 'बैंक खाता जोड़ें';

  @override
  String get listServiceOrItem => 'सेवा या वस्तु सूचीबद्ध करें';

  @override
  String get earningsThisWeek => 'इस हफ़्ते की कमाई';

  @override
  String get paymentConfirmed => 'भुगतान की पुष्टि';

  @override
  String get searchVendorsHint => 'विक्रेता या सेवाएँ खोजें…';

  @override
  String get email => 'ईमेल';

  @override
  String get noSellersYet => 'अभी कोई विक्रेता नहीं';

  @override
  String get listingsWillAppear =>
      'विक्रेताओं के विज्ञापन डालने पर लिस्टिंग यहाँ दिखेंगी।';

  @override
  String get tapCardToViewVendor => 'विक्रेता देखने के लिए कार्ड दबाएँ';

  @override
  String get verifiedVendor => 'सत्यापित विक्रेता';

  @override
  String get aboutThisService => 'इस सेवा के बारे में';

  @override
  String get locationCoverage => 'स्थान और कवरेज';

  @override
  String get contactVendor => 'विक्रेता से संपर्क करें';

  @override
  String get excellent => 'बहुत बढ़िया';

  @override
  String get sampleVendorReview =>
      '\"बेदाग़ काम और बहुत पेशेवर टीम। उसी हफ़्ते फिर बुक किया।\" — लैला एम.';

  @override
  String get workOrderCaps => 'वर्क ऑर्डर';

  @override
  String get elkRepairCaps => 'ELK REPAIR';

  @override
  String get pickASlot => 'स्लॉट चुनें';

  @override
  String get cleanPlanCaps => 'सफ़ाई योजना';

  @override
  String get elkCleanCaps => 'ELKCLEAN';

  @override
  String get loyalty => 'लॉयल्टी';

  @override
  String get today => 'आज';

  @override
  String get balance => 'बैलेंस';

  @override
  String get partnerAccount => 'पार्टनर खाता';

  @override
  String get forUsers => 'उपयोगकर्ताओं के लिए';

  @override
  String get forSellers => 'विक्रेताओं के लिए';

  @override
  String get currentlySellerMode => 'अभी सेलर मोड में';

  @override
  String get currentlyUserMode => 'अभी यूज़र मोड में';

  @override
  String get switchToSellerPanel => 'सेलर पैनल पर जाएँ';

  @override
  String get switchToUserPanel => 'यूज़र पैनल पर जाएँ';

  @override
  String get weekly => 'साप्ताहिक';

  @override
  String get monthly => 'मासिक';

  @override
  String get currentLocation => 'वर्तमान स्थान';

  @override
  String get chooseYourLocation => 'अपना स्थान चुनें';

  @override
  String get searchForAddress => 'पता खोजें';

  @override
  String get findStreetArea => 'कोई भी गली, क्षेत्र या लैंडमार्क खोजें';

  @override
  String get useCurrentLocationTitle => 'वर्तमान स्थान इस्तेमाल करें';

  @override
  String get usesPhoneGps => 'आपके फ़ोन का GPS इस्तेमाल करता है';

  @override
  String get savedAddressesSignIn =>
      'सहेजे गए पते इस्तेमाल करने के लिए साइन इन करें।';

  @override
  String get noSavedAddressesSearch => 'अभी कोई सहेजा पता नहीं — नीचे खोजें।';

  @override
  String get savedAddressesTitle => 'सहेजे गए पते';

  @override
  String get searchAddress => 'पता खोजें';

  @override
  String get streetAreaHint => 'गली, क्षेत्र या लैंडमार्क';

  @override
  String get noMatchingPlaces => 'कोई मेल खाता स्थान नहीं।';

  @override
  String get startTypingToFind => 'पता ढूँढ़ने के लिए टाइप करना शुरू करें।';

  @override
  String get turnOnLocationServices =>
      'इसे इस्तेमाल करने के लिए लोकेशन सेवा चालू करें।';

  @override
  String get locationPermissionNeeded =>
      'आपका पता पहचानने के लिए लोकेशन अनुमति चाहिए।';

  @override
  String rateDriver(String driver) {
    return '$driver को रेट करें';
  }

  @override
  String get totalCaps => 'कुल';

  @override
  String get locating => 'स्थान पता किया जा रहा है…';

  @override
  String get setPickupLocation => 'पिकअप स्थान चुनें';

  @override
  String get setDropLocation => 'ड्रॉप स्थान चुनें';

  @override
  String get setPickupAndDrop => 'पहले पिकअप और ड्रॉप दोनों स्थान चुनें।';
}
