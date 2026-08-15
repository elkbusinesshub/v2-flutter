// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ELK Business Hub';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get deleteListing => 'Delete this listing?';

  @override
  String get pauseListing => 'Pause';

  @override
  String get resumeListing => 'Resume';

  @override
  String get photos => 'Photos';

  @override
  String get draftSaved => 'Draft saved';

  @override
  String get fillRequiredFields => 'Fill in category, title and price first.';

  @override
  String get addPhoto => 'Add photo';

  @override
  String photosAdded(int count) {
    return '$count added';
  }

  @override
  String get markCompleted => 'Mark completed';

  @override
  String needAttention(int count) {
    return '$count need attention';
  }

  @override
  String get placeOrder => 'Place order';

  @override
  String orderPlaced(String code) {
    return 'Order placed · $code';
  }

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDone => 'Done';

  @override
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get commonClose => 'Close';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonSeeAll => 'See all';

  @override
  String get commonApply => 'Apply';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonOk => 'OK';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get errorTimeout => 'The request timed out. Please try again.';

  @override
  String get errorNoInternet =>
      'No internet connection. Please check your network and try again.';

  @override
  String get errorCancelled => 'The request was cancelled.';

  @override
  String get errorInsecureConnection =>
      'Could not establish a secure connection.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';

  @override
  String get errorValidation => 'Please check your input and try again.';

  @override
  String get errorSessionExpired =>
      'Your session has expired. Please log in again.';

  @override
  String get errorForbidden => 'You do not have permission to do that.';

  @override
  String get errorNotFound => 'The requested resource was not found.';

  @override
  String get errorTooManyRequests =>
      'Too many attempts. Please wait a moment and try again.';

  @override
  String get errorServer =>
      'Something went wrong on our side. Please try again later.';

  @override
  String get signInRequired => 'Sign in with your mobile number to continue.';

  @override
  String get signIn => 'Sign In';

  @override
  String get registerBusinessPrompt =>
      'Register your business to start receiving bookings.';

  @override
  String get becomeProvider => 'Become a Provider';

  @override
  String get languageTitle => 'Choose Your Language';

  @override
  String get languageSubtitle => 'You can change this anytime from settings.';

  @override
  String get languageSaveFailed =>
      'Could not save your language. Please try again.';

  @override
  String get commonOr => 'OR';

  @override
  String get getStarted => 'Get Started';

  @override
  String get byContinuingYouAgree => 'By continuing you agree to our ';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get verified => 'Verified';

  @override
  String get navHome => 'Home';

  @override
  String get navBookings => 'Bookings';

  @override
  String get navWallet => 'Wallet';

  @override
  String get navProfile => 'Profile';

  @override
  String get onboardServicesTitle => 'All Your Services, One App';

  @override
  String get onboardServicesBody =>
      'Book rides, cleaning, rentals, and more — from verified providers in your city. Fast, reliable, trusted.';

  @override
  String get onboardTrackingTitle => 'Real-Time Tracking & Chat';

  @override
  String get onboardTrackingBody =>
      'Follow your provider live on the map and chat directly with them for a smooth, transparent experience.';

  @override
  String get onboardPaymentsTitle => 'Secure Payments & Rewards';

  @override
  String get onboardPaymentsBody =>
      'Pay safely with your wallet, card, or cash, and earn reward points on every booking you make.';

  @override
  String get splashSettingUp => 'Setting up your city';

  @override
  String get splashFindingPros => 'Finding trusted pros';

  @override
  String get splashAlmostThere => 'Almost there';

  @override
  String get authWelcomeBack => 'Welcome Back';

  @override
  String get authSignInPrompt => 'Sign in with your mobile number to continue';

  @override
  String get authMobileNumber => 'Mobile Number';

  @override
  String get authSendOtp => 'Send OTP';

  @override
  String get authContinueAsGuest => 'Continue as Guest';

  @override
  String get authVerifyTitle => 'Verify Your Number';

  @override
  String get authOtpSentTo => 'We\'ve sent a 6-digit code to ';

  @override
  String get authVerifyContinue => 'Verify & Continue';

  @override
  String get authResendCode => 'Resend Code';

  @override
  String authResendIn(String seconds) {
    return 'Resend code in 00:$seconds';
  }

  @override
  String get homeBestSellersTag => 'Best sellers';

  @override
  String get homeBestSellersRest => 'near you';

  @override
  String get homeBestSellersSub => 'Most saved and most viewed listings';

  @override
  String get homeDealsTag => 'Deals';

  @override
  String get homeDealsRest => 'for you';

  @override
  String get homeDealsSub => 'More from sellers near you';

  @override
  String get homeServiceAt => 'Service at';

  @override
  String get homeSelectLocation => 'Select location';

  @override
  String get homeServices => 'Services';

  @override
  String get homeBadgeFast => 'Fast';

  @override
  String get homeBadgeNew => 'New';

  @override
  String get homeBadgeTwentyOff => '20% OFF';

  @override
  String get homeNoSellerAds => 'No seller ads yet';

  @override
  String get homeMoreListingsSoon =>
      'More listings will show up here as sellers post.';

  @override
  String get promoFirstBookingTitle => '20% off your\nfirst booking';

  @override
  String get promoFirstBookingBody =>
      'New members get an exclusive discount across every service.';

  @override
  String get promoClaimOffer => 'Claim offer';

  @override
  String get promoFreeRidesTitle => 'Free rides\nevery week';

  @override
  String get promoFreeRidesBody =>
      'Members unlock weekly perks, priority support and lower fees.';

  @override
  String get promoJoinNow => 'Join now';

  @override
  String get profileSignOut => 'Sign Out';

  @override
  String get profileSignOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get profileEdit => 'Edit Profile';

  @override
  String get profileRewardPoints => 'Reward Points';

  @override
  String get profileRating => 'Rating';

  @override
  String get profileMyAccount => 'My Account';

  @override
  String get profileOffersRewards => 'Offers & Rewards';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileSavedAddresses => 'Saved Addresses';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileRateService => 'Rate a Service';

  @override
  String get profileProviderTools => 'Provider Tools';

  @override
  String get profileProviderDashboard => 'Provider Dashboard';

  @override
  String get profileSupport => 'Support';

  @override
  String get profileHelpSupport => 'Help & Support';

  @override
  String get profileAbout => 'About ELK Business Hub';

  @override
  String get profileTermsPrivacy => 'Terms & Privacy Policy';

  @override
  String get profileGuestTitle => 'You\'re browsing as a guest';

  @override
  String get profileGuestBody =>
      'Sign in with your mobile number to view your profile, bookings, and rewards.';

  @override
  String get profileNameRequired => 'Please enter your name.';

  @override
  String get profileNameTooLong => 'Name must be 100 characters or fewer.';

  @override
  String get profileEmailInvalid => 'Please enter a valid email address.';

  @override
  String get profileNameLabel => 'Name';

  @override
  String get profileEmailLabel => 'Email (optional)';

  @override
  String get walletToppedUp => 'Wallet topped up';

  @override
  String get walletWithdrawSuccess => 'Withdrawal successful';

  @override
  String get walletStillLoading => 'Wallet is still loading. Please try again.';

  @override
  String get walletAddMoneyTitle => 'Add Money to Wallet';

  @override
  String get walletWithdrawTitle => 'Withdraw to Bank';

  @override
  String get walletAddMoney => 'Add Money';

  @override
  String get walletWithdraw => 'Withdraw';

  @override
  String get walletAmountTooSmall => 'Enter an amount greater than 0';

  @override
  String get walletAmountTooLarge => 'Amount cannot exceed ₹1,000,000';

  @override
  String get walletSignInPrompt =>
      'Sign in to use your ELK Wallet and reward points.';

  @override
  String get walletAvailableBalance => 'Available Balance';

  @override
  String get walletTransactionHistory => 'Transaction History';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusPendingVendor => 'Pending vendor';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusUnknown => 'Unknown';

  @override
  String get myBookingsTitle => 'My Bookings';

  @override
  String get bookingsSignInPrompt =>
      'Sign in to see the services you have booked.';

  @override
  String get tabUpcoming => 'Upcoming';

  @override
  String get emptyUpcomingTitle => 'No upcoming bookings';

  @override
  String get emptyUpcomingBody => 'Book a service and it will show up here.';

  @override
  String get emptyCompletedTitle => 'Nothing completed yet';

  @override
  String get emptyCompletedBody => 'Your finished bookings will appear here.';

  @override
  String get emptyCancelledTitle => 'No cancelled bookings';

  @override
  String get emptyCancelledBody => 'Cancellations will be listed here.';

  @override
  String get bookingDetailsTitle => 'Booking details';

  @override
  String get sectionStatus => 'Status';

  @override
  String get sectionScheduleAddress => 'Schedule & address';

  @override
  String get labelDateTime => 'Date & time';

  @override
  String get labelServiceAddress => 'Service address';

  @override
  String get sectionVendor => 'Vendor';

  @override
  String get vendorContactUnavailable => 'Vendor contact isn\'t available yet';

  @override
  String get callAction => 'Call';

  @override
  String get sectionPayment => 'Payment';

  @override
  String get lineService => 'Service';

  @override
  String get totalPaid => 'Total paid';

  @override
  String get totalCancelled => 'Total (cancelled)';

  @override
  String get bookingId => 'Booking ID';

  @override
  String get copyAction => 'Copy';

  @override
  String get cancelIsFreeNote =>
      'Cancelling an upcoming booking is free and frees your slot straight away.';

  @override
  String get rebookThisService => 'Rebook this service';

  @override
  String get ratedStar => 'Rated ★';

  @override
  String get rateAction => 'Rate';

  @override
  String get rebookAction => 'Rebook';

  @override
  String get trackOrder => 'Track order';

  @override
  String get cancelling => 'Cancelling…';

  @override
  String get cancelBooking => 'Cancel booking';

  @override
  String get cancelBookingQuestion => 'Cancel this booking?';

  @override
  String get whyCancelling => 'Why are you cancelling?';

  @override
  String get cancelReasonPlans => 'Changed my plans';

  @override
  String get cancelReasonAlternative => 'Found another option';

  @override
  String get cancelReasonWrongTime => 'Wrong date/time';

  @override
  String get cancelReasonExpensive => 'Too expensive';

  @override
  String get cancelReasonOther => 'Other';

  @override
  String get cancellingIsFreePrefix => 'Cancelling is free — ';

  @override
  String get cancellingIsFreeSuffix => ' will not be charged for this booking.';

  @override
  String get keepBooking => 'Keep booking';

  @override
  String get rebookHint => 'Pick the service again from the Services tab';

  @override
  String get copiedBookingId => 'Copied booking ID';

  @override
  String get cancelledNothingCharged => 'Cancelled — nothing was charged';

  @override
  String get viewDetails => 'View details';

  @override
  String get bookingCancelledToast => 'Booking cancelled';

  @override
  String get timelineBooked => 'Booked';

  @override
  String get timelineBookedSub => 'Order placed';

  @override
  String get timelineConfirmedSub => 'Vendor accepted';

  @override
  String get timelineInProgress => 'In progress';

  @override
  String get timelineInProgressSub => 'On the day';

  @override
  String get timelineCompletedSub => 'Service done';

  @override
  String get timelineRefundIssued => 'Refund issued to ELK Wallet';

  @override
  String get bookingNotScheduled => 'Not scheduled';

  @override
  String get dateToday => 'Today';

  @override
  String get dateTomorrow => 'Tomorrow';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String walletRewardPoints(int points) {
    return '$points Reward Points';
  }

  @override
  String vendorSpecialist(String service) {
    return '$service specialist';
  }

  @override
  String get svcTaxiRides => 'Taxi & Rides';

  @override
  String get svcCleaning => 'Cleaning';

  @override
  String get svcCarRental => 'Car Rental';

  @override
  String get svcRepair => 'Repair';

  @override
  String get svcPorterMovers => 'Porter & Movers';

  @override
  String get svcEconomyTaxi => 'Economy Taxi';

  @override
  String get svcPremiumTaxi => 'Premium Taxi';

  @override
  String get svcAuto => 'Auto';

  @override
  String get svcXlVan => 'XL Van';

  @override
  String get svcPgStay => 'PG Stay';

  @override
  String get svcMensHostel => 'Men\'s Hostel';

  @override
  String get svcWomensHostel => 'Women\'s Hostel';

  @override
  String get svcHomestay => 'Homestay';

  @override
  String get svcHomeCleaning => 'Home Cleaning';

  @override
  String get svcDeepCleaning => 'Deep Cleaning';

  @override
  String get svcSofaUpholstery => 'Sofa & Upholstery';

  @override
  String get svcKitchenCleaning => 'Kitchen Cleaning';

  @override
  String get svcBathroomCleaning => 'Bathroom Cleaning';

  @override
  String get svcCarpetRug => 'Carpet & Rug';

  @override
  String get svcLaundryIron => 'Laundry & Iron';

  @override
  String get svcWashFold => 'Wash & Fold';

  @override
  String get svcWaterTank => 'Water Tank';

  @override
  String get svcSedan => 'Sedan';

  @override
  String get svcSuv => 'SUV';

  @override
  String get svcLuxury => 'Luxury';

  @override
  String get svcVan => 'Van';

  @override
  String get svcAcCooling => 'AC & Cooling';

  @override
  String get svcPlumbing => 'Plumbing';

  @override
  String get svcElectrical => 'Electrical';

  @override
  String get svcCarpentry => 'Carpentry';

  @override
  String get svcPainting => 'Painting';

  @override
  String get svcHandyman => 'Handyman';

  @override
  String get svcBikeDelivery => 'Bike Delivery';

  @override
  String get svcMiniTruck => 'Mini Truck';

  @override
  String get svcHouseShifting => 'House Shifting';

  @override
  String get svcMoversPackers => 'Movers & Packers';

  @override
  String get svcSearchHint => 'Search services… (e.g. AC, taxi)';

  @override
  String get rideBlurbAuto => 'Budget auto-rickshaw rides';

  @override
  String get rideBlurbEconomy => 'Affordable everyday cars';

  @override
  String get rideBlurbPremium => 'Top-rated premium cars';

  @override
  String get rideBlurbXl => 'For families, groups & big bags';

  @override
  String get rideBlurbAutoShort => 'Budget rickshaw rides';

  @override
  String get rideBlurbEconomyShort => 'Affordable everyday rides';

  @override
  String get rideBlurbPremiumShort => 'Extra legroom, top-rated drivers';

  @override
  String get taxiSignInPrompt =>
      'Sign in with your mobile number to book a ride.';

  @override
  String get taxiBookARide => 'Book a Ride';

  @override
  String get taxiNoRideTypes => 'No ride classes are available right now.';

  @override
  String get taxiChooseRide => 'Choose your ride';

  @override
  String get taxiPickup => 'PICKUP';

  @override
  String get taxiDropoff => 'DROP-OFF';

  @override
  String get sortRecommended => 'Recommended';

  @override
  String get sortFaster => 'Faster';

  @override
  String get sortCheaper => 'Cheaper';

  @override
  String get payCash => 'Cash';

  @override
  String get payCard => 'Credit / Debit Card';

  @override
  String get payElkWallet => 'ELK Wallet';

  @override
  String get payApplePay => 'Apple Pay';

  @override
  String get payApplePayGooglePay => 'Apple Pay / Google Pay';

  @override
  String get payCashSub => 'Confirm to pay driver on arrival';

  @override
  String get payCardSub => 'Visa, Mastercard & more';

  @override
  String get payWalletSub => 'Pay from your ELK Wallet balance';

  @override
  String get payApplePaySub => 'Fast & secure checkout';

  @override
  String get changeAction => 'Change';

  @override
  String get bookPrefix => 'Book ';

  @override
  String get fare => 'Fare';

  @override
  String get cancellationFee => 'Cancellation';

  @override
  String get seats => 'Seats';

  @override
  String get fareEstimateNote =>
      'Total fare is an estimate based on distance and time. Surcharges, peak pricing, or toll fees may be added at checkout.';

  @override
  String get choosePickupLocation => 'Choose pickup location';

  @override
  String get chooseDropoffLocation => 'Choose drop-off location';

  @override
  String get fareBase => 'Base fare';

  @override
  String get fareBookingFee => 'Booking fee';

  @override
  String get assigningDriver => 'Assigning driver…';

  @override
  String get detailsOnTheWay => 'Details on the way';

  @override
  String get couldNotBookRide => 'Could not book the ride.';

  @override
  String get findingDriver => 'Finding Driver';

  @override
  String get lookingForDrivers => 'Looking for nearby drivers';

  @override
  String get driverAssigned => 'Driver Assigned';

  @override
  String get completePaymentNote =>
      'Complete payment to confirm your booking. Your trip OTP will be issued right after.';

  @override
  String get proceedToPayment => 'Proceed to Payment';

  @override
  String get amountDue => 'AMOUNT DUE';

  @override
  String get total => 'Total';

  @override
  String get selectPaymentMethod => 'Select payment method';

  @override
  String get paymentsSecured => 'Payments secured with 256-bit encryption';

  @override
  String get cardYourName => 'YOUR NAME';

  @override
  String get cardDetails => 'Card Details';

  @override
  String get cardHolder => 'CARD HOLDER';

  @override
  String get cardExpires => 'EXPIRES';

  @override
  String get cardNumber => 'Card Number';

  @override
  String get cardExpiry => 'Expiry';

  @override
  String get cardCvv => 'CVV';

  @override
  String get cardholderName => 'Cardholder Name';

  @override
  String get cardAsShown => 'As shown on card';

  @override
  String get saveCardForFuture => 'Save card for future payments';

  @override
  String get otpBeingPrepared => 'Your OTP is being prepared';

  @override
  String get driverOnTheWay => 'Driver On The Way';

  @override
  String get shareOtpToStart => 'Share this OTP to start your trip';

  @override
  String get safety => 'Safety';

  @override
  String get shareTrip => 'Share Trip';

  @override
  String get driverArrivedStartTrip => 'Driver Arrived · Start Trip';

  @override
  String get couldNotStartTrip => 'Could not start the trip.';

  @override
  String get tripInProgress => 'Trip in Progress';

  @override
  String get headingTo => 'HEADING TO';

  @override
  String get completeTrip => 'Complete Trip';

  @override
  String get couldNotCompleteTrip => 'Could not complete the trip.';

  @override
  String get distance => 'Distance';

  @override
  String get duration => 'Duration';

  @override
  String get farePaid => 'Fare · Paid';

  @override
  String get addATip => 'Add a tip';

  @override
  String get noTip => 'No tip';

  @override
  String get finishTrip => 'Finish Trip';

  @override
  String get couldNotSubmitRating => 'Could not submit your rating.';

  @override
  String get allDoneThanks => 'All Done — Thanks for Riding!';

  @override
  String get trip => 'Trip';

  @override
  String get driver => 'Driver';

  @override
  String get tip => 'Tip';

  @override
  String get transactionId => 'Transaction ID';

  @override
  String get receiptDownloaded => 'Receipt downloaded';

  @override
  String get download => 'Download';

  @override
  String get bookAnotherTrip => 'Book Another Trip';

  @override
  String svcNoMatch(String query) {
    return 'No services match \"$query\".\nTry \"AC\", \"taxi\" or \"clean\".';
  }

  @override
  String rideSeats(int seats) {
    return '$seats seats';
  }

  @override
  String fareDistance(String km) {
    return 'Distance ($km km)';
  }

  @override
  String fareTime(int minutes) {
    return 'Time ($minutes min)';
  }

  @override
  String tipWillBeCharged(String amount, String method) {
    return '$amount will be charged to your $method';
  }

  @override
  String totalVia(String method) {
    return 'Total via $method';
  }

  @override
  String get addServiceAddress => 'Add service address';

  @override
  String get cleanSignInPrompt =>
      'Sign in with your mobile number to book cleaning services.';

  @override
  String get topOffers => 'Top offers';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get cleanSearchHint => 'Search \"deep clean\", \"tank\"…';

  @override
  String get playUnlockDeals => 'Play & Unlock Summer Deals!';

  @override
  String get getWaterTankCleaning => 'Get Water Tank Cleaning ';

  @override
  String get whatNeedsCleaning => 'What needs cleaning?';

  @override
  String get codeLabel => 'Code: ';

  @override
  String get ecoFriendlyProducts => 'Eco-friendly, child-safe products';

  @override
  String get trainedCleaners => 'Trained & uniformed cleaners';

  @override
  String get fromLabel => 'From';

  @override
  String get howWeDoIt => 'HOW WE DO IT';

  @override
  String get hygieneAfterService => 'Hygiene level after service';

  @override
  String get beforeLabel => 'before';

  @override
  String get afterLabTested => 'after · lab-tested';

  @override
  String get elkCleanCrew => 'ELKclean crew';

  @override
  String get crewBlurb => 'Uniformed · eco kit · 4.9 from 1,200+ cleans';

  @override
  String get priceCaps => 'PRICE';

  @override
  String get yourCleanPlan => 'Your clean plan';

  @override
  String get addPromoCode => 'Add promo code';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get ecoSuppliesSetup => 'Eco supplies & setup';

  @override
  String get selectDate => 'SELECT DATE';

  @override
  String get arrivalWindow => 'ARRIVAL WINDOW';

  @override
  String get fillsFast => 'Fills fast';

  @override
  String get available => 'Available';

  @override
  String get crewArrivalNote =>
      'Your crew arrives within a 2-hour window with all supplies. Live tracking link sent on the day.';

  @override
  String get serviceAddress => 'Service address';

  @override
  String get savedPlaces => 'SAVED PLACES';

  @override
  String get noSavedAddresses => 'No saved addresses yet — add one below.';

  @override
  String get addNewAddress => 'Add new address';

  @override
  String get addServiceAddressFirst => 'Please add a service address first.';

  @override
  String get reviewConfirm => 'Review & confirm';

  @override
  String get whenLabel => 'When';

  @override
  String get whereLabel => 'Where';

  @override
  String get contactLabel => 'Contact';

  @override
  String get verifiedAccount => 'Verified account';

  @override
  String get orderSummary => 'Order summary';

  @override
  String get totalToPay => 'Total to pay';

  @override
  String get recleanGuarantee =>
      'Not happy? We re-clean free within 48 hours. Free cancellation up to 2h before.';

  @override
  String get payCardBrands => 'Visa, Mastercard, Amex';

  @override
  String get payOneTapCheckout => 'One-tap secure checkout';

  @override
  String get chooseMethod => 'CHOOSE METHOD';

  @override
  String get nameOnCard => 'NAME ON CARD';

  @override
  String get saveCardFasterCheckout => 'Save card for faster checkout';

  @override
  String get processing => 'Processing…';

  @override
  String get paymentFailed => 'Payment failed. Please try again.';

  @override
  String get paidLabel => 'Paid';

  @override
  String get paidCaps => 'PAID';

  @override
  String get trackMyClean => 'Track my clean';

  @override
  String get noServicesYet => 'No services yet';

  @override
  String get browseCleaningBlurb =>
      'Browse cleaning services and build your plan.';

  @override
  String get browseServices => 'Browse services';

  @override
  String paySecurely(String amount) {
    return 'Pay $amount securely';
  }

  @override
  String servicesAdded(int count) {
    return '$count services added';
  }

  @override
  String get repairSignInPrompt =>
      'Sign in with your mobile number to book a repair.';

  @override
  String get repairSearchHint => 'Search \"AC service\", \"leak\"…';

  @override
  String get summerReady => 'SUMMER READY';

  @override
  String get whatNeedsFixing => 'What needs fixing?';

  @override
  String get whatsIncluded => 'What\'s included';

  @override
  String get topRatedCrew => 'Top-rated crew';

  @override
  String get techCrewBlurb => 'Assigned after booking · avg 4.9 from 800+ jobs';

  @override
  String get yourWorkOrder => 'Your work order';

  @override
  String get visitInspectionFee => 'Visit & inspection fee';

  @override
  String get techArrivalNote =>
      'Your technician arrives within a 2-hour window. You\'ll get a live tracking link on the day.';

  @override
  String get chargedAfterComplete =>
      'You\'re only charged after the job is confirmed complete. Free cancellation up to 2h before.';

  @override
  String get trackMyBooking => 'Track my booking';

  @override
  String get browseTradesBlurb => 'Browse trades and add what needs fixing.';

  @override
  String get rentalSignInPrompt =>
      'Sign in with your mobile number to rent a car.';

  @override
  String get carsAvailable => 'cars available';

  @override
  String get sortPrice => 'Sort: Price';

  @override
  String get noCarsInCategory => 'No cars in this category right now.';

  @override
  String get bookNow => 'Book Now';

  @override
  String get porterSignInPrompt =>
      'Sign in with your mobile number to send a package.';

  @override
  String get selectVehicle => 'Select Vehicle';

  @override
  String get pricingUpdates => 'Pricing updates with your choice';

  @override
  String get addOns => 'Add-ons';

  @override
  String get porterLogistics => 'Porter & Logistics';

  @override
  String get pickupLocation => 'PICKUP LOCATION';

  @override
  String get dropLocation => 'DROP LOCATION';

  @override
  String get packageType => 'Package Type';

  @override
  String get packageElectronics => 'Electronics';

  @override
  String get weight => 'Weight';

  @override
  String get estimatedTime => 'Estimated Time';

  @override
  String get estimatedFare => 'Estimated Fare';

  @override
  String get bookPorter => 'Book Porter';

  @override
  String get couldNotBookDelivery => 'Could not book the delivery.';

  @override
  String get stepSchedule => 'Schedule';

  @override
  String get pickUpNow => 'Pick up now';

  @override
  String get scheduleForLater => 'Schedule for later';

  @override
  String get pickupDate => 'Pickup date';

  @override
  String get selectDateAction => 'Select date';

  @override
  String get pickupWindow => 'Pickup window';

  @override
  String get estTime => 'Est. time';

  @override
  String get continueToPayment => 'Continue to payment';

  @override
  String get payCardBrandsShort => 'Visa, Mastercard';

  @override
  String get payCashOnDelivery => 'Cash on delivery';

  @override
  String get deliveryFare => 'Delivery fare';

  @override
  String get serviceFee => 'Service fee';

  @override
  String get gstFivePercent => 'GST (5%)';

  @override
  String get continueToCardDetails => 'Continue to card details';

  @override
  String get amount => 'Amount';

  @override
  String get confirmAndPay => 'Confirm and pay';

  @override
  String get completeCardDetails => 'Please complete all card details';

  @override
  String get paymentsSecuredByElk => 'Payments secured by ELK gateway';

  @override
  String get processingPayment => 'Processing payment';

  @override
  String get confirmingWithBank =>
      'Confirming with your bank, do not close this screen';

  @override
  String get bookingConfirmed => 'Booking confirmed';

  @override
  String get porterNotified => 'Your porter has been notified';

  @override
  String get trackingId => 'Tracking ID';

  @override
  String get vehicle => 'Vehicle';

  @override
  String get arrival => 'Arrival';

  @override
  String get amountPaid => 'Amount paid';

  @override
  String get receiptSentToEmail => 'Receipt sent to your email';

  @override
  String get viewReceipt => 'View receipt →';

  @override
  String get stepTripDetails => 'Trip Details';

  @override
  String get stepPickupDelivery => 'Pickup & Delivery';

  @override
  String get stepExtrasProtection => 'Extras & Protection';

  @override
  String get stepLocation => 'Location';

  @override
  String get stepExtras => 'Extras';

  @override
  String get stepReview => 'Review';

  @override
  String get stepPay => 'Pay';

  @override
  String get yourAccount => 'Your account';

  @override
  String get branch => 'Branch';

  @override
  String get securedByElkPay => 'Secured by ELK Pay · 256-bit encryption';

  @override
  String get totalSoFar => 'Total so far';

  @override
  String get whenDoYouNeedIt => 'When do you need it?';

  @override
  String get pickPlanAndDates => 'Pick your rental plan and travel dates';

  @override
  String get rateDaily => 'Daily';

  @override
  String get rateWeekly => 'Weekly · 15% off';

  @override
  String get rateMonthly => 'Monthly · 30% off';

  @override
  String get pickupDateTime => 'Pick-up date & time';

  @override
  String get whenRentalBegins => 'When your rental begins';

  @override
  String get returnDateTime => 'Return date & time';

  @override
  String get whenRentalEnds => 'When your rental ends';

  @override
  String get rentalLength => 'Rental length';

  @override
  String get rentalBillingNote =>
      'Rentals are billed in full days. Return the car late by more than 59 minutes and an extra day applies.';

  @override
  String get howGetYourCar => 'How would you like to get your car?';

  @override
  String get collectOrDelivered =>
      'Collect it yourself or have it delivered to you';

  @override
  String get selfPickup => 'Self Pickup';

  @override
  String get collectFromBranch => 'Collect from an ELK branch';

  @override
  String get free => 'Free';

  @override
  String get carDelivery => 'Car Delivery';

  @override
  String get weBringIt => 'We bring it to your address';

  @override
  String get chooseBranch => 'Choose a branch';

  @override
  String get mapPreviewHint => 'Map preview · tap to open directions';

  @override
  String get deliveryAddress => 'Delivery address';

  @override
  String get deliveryAddressHint => 'e.g. Koramangala, Bengaluru';

  @override
  String get buildingVillaNo => 'Building / Villa No.';

  @override
  String get driverDirections => 'Directions for driver (optional)';

  @override
  String get driverDirectionsHint => 'Gate code, landmark, parking notes…';

  @override
  String get locationCaptured => 'Location captured';

  @override
  String get useCurrentLocation => 'Use my current location';

  @override
  String get deliveryFeeNote =>
      'Delivery fee ₹25 · car arrives within 2 hours of your pick-up time.';

  @override
  String get enhanceYourTrip => 'Enhance your trip';

  @override
  String get optionalAddOns =>
      'Optional add-ons — pick any that suit your journey';

  @override
  String get reviewYourBooking => 'Review your booking';

  @override
  String get doubleCheckBeforePay => 'Double-check everything before you pay';

  @override
  String get bookingAsYourself => 'Booking as yourself';

  @override
  String get tripDates => 'Trip dates';

  @override
  String get priceBreakdown => 'Price breakdown';

  @override
  String get deliveryFee => 'Delivery fee';

  @override
  String get promoCodeHint => 'Promo code — try ELK10';

  @override
  String get totalInclGst => 'Total (incl. 5% GST)';

  @override
  String get iAgreeToThe => 'I agree to the ';

  @override
  String get rentalTerms => 'Rental Terms & Conditions';

  @override
  String get enterPromoFirst => 'Enter a promo code first';

  @override
  String get promoNotValid => 'That code isn\'t valid';

  @override
  String get cashOnPickup => 'Cash on Pickup';

  @override
  String get chooseHowToPay => 'Choose how you\'d like to pay';

  @override
  String get cardLabel => 'Card';

  @override
  String get saveCardNextTime => 'Save this card for faster checkout next time';

  @override
  String get payWithDigitalWallet => 'Pay with your digital wallet';

  @override
  String get walletRedirectNote =>
      'You\'ll be redirected to complete this payment securely, then returned to ELK Business Hub.';

  @override
  String get cashAtBranchNote =>
      'Pay the full amount in cash when you collect the car at the branch counter.';

  @override
  String get cashToDriverNote =>
      'Pay the full amount in cash to our driver when the car is delivered.';

  @override
  String get processingYourPayment => 'Processing your payment…';

  @override
  String get dontCloseScreen => 'Please don\'t close this screen';

  @override
  String get bookingConfirmedBang => 'Booking Confirmed!';

  @override
  String get deliveredToAddress => 'Delivered to your address';

  @override
  String get showThisAtPickup => 'Show this at pickup';

  @override
  String get viewEReceipt => 'View E-Receipt';

  @override
  String payAmount(String amount) {
    return 'Pay $amount';
  }

  @override
  String confirmAndPayAmount(String amount) {
    return 'Confirm & Pay $amount';
  }

  @override
  String branchSelfPickup(String branch) {
    return '$branch (Self Pickup)';
  }

  @override
  String daysCount(int days) {
    return '$days days';
  }

  @override
  String get payUpiSub => 'GPay, PhonePe, Paytm & more';

  @override
  String get payCardBrandsIn => 'Visa, Mastercard, Rupay';

  @override
  String get payNetBanking => 'Net Banking';

  @override
  String get payAllMajorBanks => 'All major banks';

  @override
  String get couldNotScheduleVisit => 'Could not schedule the visit.';

  @override
  String get allStays => 'All stays';

  @override
  String get chipAll => 'All';

  @override
  String get chipSingle => 'Single';

  @override
  String get chipDouble => 'Double';

  @override
  String get chipFoodIncl => 'Food incl.';

  @override
  String get chipNearMetro => 'Near metro';

  @override
  String get staysInArea => 'stays in Koramangala';

  @override
  String get sortLabel => 'Sort ';

  @override
  String get staySignInPrompt =>
      'Sign in with your mobile number to view this stay.';

  @override
  String get stayBrowseSignInPrompt =>
      'Sign in with your mobile number to browse stays.';

  @override
  String get foodIncluded => 'Food included';

  @override
  String get chooseSharing => 'Choose sharing';

  @override
  String get amenities => 'Amenities';

  @override
  String get ratingsReviews => 'Ratings & reviews';

  @override
  String get sampleStayReview =>
      '\"Clean rooms, great food and very safe. The warden is helpful and the location is perfect for commuting.\" — Priya S.';

  @override
  String get startingFrom => 'Starting from';

  @override
  String get visit => 'Visit';

  @override
  String get reserve => 'Reserve';

  @override
  String get bookYourStay => 'Book your stay';

  @override
  String get roomType => 'Room type';

  @override
  String get moveInDate => 'MOVE-IN DATE';

  @override
  String get durationCaps => 'DURATION';

  @override
  String get fullName => 'FULL NAME';

  @override
  String get phoneNumber => 'PHONE NUMBER';

  @override
  String get reviewAndPay => 'Review & pay';

  @override
  String get paymentSummary => 'Payment summary';

  @override
  String get firstMonthRent => 'First month rent';

  @override
  String get securityDeposit => 'Security deposit';

  @override
  String get refundableAtMoveOut => 'Refundable at move-out';

  @override
  String get elkServiceFee => 'ELK service fee';

  @override
  String get couponElknew => 'Coupon ELKNEW';

  @override
  String get payableNow => 'Payable now';

  @override
  String get applyPrefix => 'Apply ';

  @override
  String get saveFiveHundred => ' — save ₹500';

  @override
  String get appliedCaps => 'APPLIED';

  @override
  String get applyCaps => 'APPLY';

  @override
  String get stayPolicyNote =>
      'By continuing you agree to ELK\'s stay policy and cancellation terms. Deposit is fully refundable subject to inspection.';

  @override
  String get proceedToPay => 'Proceed to pay';

  @override
  String get amountPayable => 'Amount payable';

  @override
  String get payUsing => 'Pay using';

  @override
  String get upiId => 'UPI ID';

  @override
  String get property => 'Property';

  @override
  String get room => 'Room';

  @override
  String get moveIn => 'Move-in';

  @override
  String get backToHome => 'Back to home';

  @override
  String get pgStays => 'PG Stays';

  @override
  String get homestays => 'Homestays';

  @override
  String get statusVisitBooked => 'Visit booked';

  @override
  String get statusPending => 'Pending';

  @override
  String get chooseRoomFirst => 'Please choose a room option first.';

  @override
  String get whatAreYouLookingFor => 'What are you looking for?';

  @override
  String get topRatedNearYou => 'Top rated near you';

  @override
  String get goodMorning => 'Good morning,';

  @override
  String get staySearchHint => 'Search area, college, or PG';

  @override
  String get noStaysFound => 'No stays found';

  @override
  String get underTwelveK => 'Under ₹12k';

  @override
  String get singleRoom => 'Single room';

  @override
  String get meals => 'Meals';

  @override
  String get womensPg => 'Women\'s PG';

  @override
  String get savedStays => 'Saved stays';

  @override
  String get noSavedStaysYet => 'No saved stays yet';

  @override
  String get noSavedStaysBody => 'Tap the heart on a stay to keep it here.';

  @override
  String get savedStaysSignIn => 'Sign in to see the stays you saved.';

  @override
  String get myStays => 'My stays';

  @override
  String get noStaysHereYet => 'No stays here yet';

  @override
  String get tabActive => 'Active';

  @override
  String get tabRequests => 'Requests';

  @override
  String get tabPast => 'Past';

  @override
  String get rent => 'Rent';

  @override
  String visitScheduledFor(String date) {
    return 'Visit scheduled for $date, 5 PM';
  }

  @override
  String monthsCount(int months) {
    return '$months months';
  }

  @override
  String get accept => 'Accept';

  @override
  String get accepted => 'Accepted';

  @override
  String get acceptJob => 'Accept job';

  @override
  String get accountHolderName => 'Account holder name';

  @override
  String get accountNumber => 'Account number';

  @override
  String get accountVerified => 'Account ••••4821 · Verified';

  @override
  String get activeJobs => 'Active jobs';

  @override
  String get addAccountToWithdraw => 'Add your account to withdraw earnings';

  @override
  String get addAddress => 'Add address';

  @override
  String get addAnAddress => 'Add an address';

  @override
  String get addCommentOptional => 'Add a comment (optional)';

  @override
  String get addedToActiveJobs => 'Added to active jobs';

  @override
  String get addedToYourActiveJobs => 'Added to your active jobs';

  @override
  String get addPayoutFirst => 'Add a payout method first';

  @override
  String get addressesSignInPrompt =>
      'Sign in to save the addresses you book to.';

  @override
  String get addressLabelHint => 'Label (Home, Office…)';

  @override
  String get addressLineHint => 'Building, street, area';

  @override
  String get addressTooLong => 'Address must be 255 characters or fewer';

  @override
  String get adSubmitted => 'Ad submitted for review';

  @override
  String get allClear => 'All clear';

  @override
  String get amountToPay => 'Amount to Pay';

  @override
  String get applicationReviewNote =>
      'We\'ll review your details and verify your documents within 24-48 hours. You\'ll get a notification once your provider account is approved.';

  @override
  String get applicationSubmitted => 'Application Submitted!';

  @override
  String get asPrintedOnAccount => 'As printed on your bank account';

  @override
  String get availability => 'Availability';

  @override
  String get availableNow => 'Available now';

  @override
  String get availableOffers => 'Available Offers';

  @override
  String get availableToWithdraw => 'Available to withdraw';

  @override
  String get avgPerJob => 'Avg per Job';

  @override
  String get bankLinked => 'Bank linked';

  @override
  String get bankName => 'Bank name';

  @override
  String get booked => 'Booked';

  @override
  String get bookingAccepted => 'Booking accepted';

  @override
  String get bookingReference => 'Booking Reference';

  @override
  String get bookingRequest => 'Booking request';

  @override
  String get bookingSignInPrompt =>
      'Sign in with your mobile number to book this service.';

  @override
  String get bookService => 'Book Service';

  @override
  String get businessName => 'Business Name';

  @override
  String get businessNameHint => 'e.g. Royal Shine Co.';

  @override
  String get byAppointment => 'By appointment';

  @override
  String get cancelOrder => 'Cancel Order';

  @override
  String get cancelOrderConfirm =>
      'Are you sure you want to cancel this order?';

  @override
  String get canNowWithdraw => 'You can now withdraw your earnings';

  @override
  String get catPorter => 'Porter';

  @override
  String get catTaxiRide => 'Taxi / Ride';

  @override
  String get chat => 'Chat';

  @override
  String get chatSignInPrompt => 'Sign in to message your service provider.';

  @override
  String get chatWithProvider => 'Chat with Provider';

  @override
  String get chooseCategory => 'Choose a category';

  @override
  String get chooseServiceAddress => 'Choose service address';

  @override
  String get claimOfferArrow => 'Claim Offer →';

  @override
  String get completedJobs => 'Completed Jobs';

  @override
  String get confirmWithdrawal => 'Confirm withdrawal';

  @override
  String get contactNumber => 'Contact Number';

  @override
  String get customer => 'Customer';

  @override
  String get customerHasBeenNotified => 'The customer has been notified';

  @override
  String get customerNotified => 'Customer notified';

  @override
  String get customersCanBook => 'Customers can book you now';

  @override
  String get decline => 'Decline';

  @override
  String get declined => 'Declined';

  @override
  String get defaultCaps => 'DEFAULT';

  @override
  String get description => 'Description';

  @override
  String get descriptionHint =>
      'Describe what\'s included, your experience, service area…';

  @override
  String get detailsForProfile =>
      'We\'ll use these details to set up your provider profile.';

  @override
  String get done => 'Done';

  @override
  String get earnings => 'Earnings';

  @override
  String get enterAccountHolderName => 'Enter account holder name';

  @override
  String get enterALabel => 'Enter a label';

  @override
  String get enterTheAddress => 'Enter the address';

  @override
  String get enterValidAccountNumber =>
      'Enter a valid 9–18 digit account number';

  @override
  String get export => 'Export';

  @override
  String get fixedPrice => 'Fixed price';

  @override
  String get fundsArriveIn => 'Funds arrive in 1–2 business days';

  @override
  String get goesLiveIn24h => 'Goes live within 24 hours';

  @override
  String get guest => 'Guest';

  @override
  String get howWasExperience => 'How was your experience?';

  @override
  String get idDocument => 'ID Document';

  @override
  String get idDocumentHint => 'Upload a government-issued photo ID';

  @override
  String get inProgress => 'In progress';

  @override
  String get inReview => 'In review';

  @override
  String get labelTooLong => 'Label must be 50 characters or fewer';

  @override
  String get linkAccount => 'Link account';

  @override
  String get linkBankAccount => 'Link bank account';

  @override
  String get listings => 'Listings';

  @override
  String get listingTitle => 'Listing title';

  @override
  String get listingTitleHint => 'e.g. Deep home cleaning (3BHK)';

  @override
  String get liveUpdatesUnavailable =>
      'Live updates unavailable — reopen the chat to see new replies.';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get markedAllRead => 'Marked all read';

  @override
  String get marking => 'Marking…';

  @override
  String get myListings => 'My Listings';

  @override
  String get mySchedule => 'My Schedule';

  @override
  String get newRequest => 'New request';

  @override
  String get newRequests => 'New Requests';

  @override
  String get noActiveJobs => 'No active jobs';

  @override
  String get noBankLinked => 'No bank linked';

  @override
  String get noBankLinkedYet => 'No bank linked yet';

  @override
  String get noEarningsYet => 'No earnings yet';

  @override
  String get noNewRequests => 'You won\'t get new requests';

  @override
  String get noNewRequestsNow => 'No new requests right now';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get noOffersRunning =>
      'No offers running right now — check back soon.';

  @override
  String get noOrdersRightNow => 'No orders here right now';

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String get noSavedAddressesYet => 'No saved addresses yet';

  @override
  String get nothingHereYet => 'Nothing here yet';

  @override
  String get nothingWaiting => 'Nothing waiting';

  @override
  String get notificationsSignInPrompt =>
      'Sign in to see your booking and offer updates.';

  @override
  String get offersSignInPrompt =>
      'Sign in to see your reward points and offers.';

  @override
  String get offline => 'Offline';

  @override
  String get orderCancelled => 'Order cancelled';

  @override
  String get orderId => 'Order ID';

  @override
  String get orders => 'Orders';

  @override
  String get orderStatus => 'Order Status';

  @override
  String get paused => 'Paused';

  @override
  String get payoutMethod => 'Payout method';

  @override
  String get perDay => 'Per day';

  @override
  String get perHour => 'Per hour';

  @override
  String get pickServiceType => 'Pick the service or item type you\'re listing';

  @override
  String get post => 'Post';

  @override
  String get postNewAd => 'Post a new ad';

  @override
  String get price => 'Price';

  @override
  String get pricingType => 'Pricing type';

  @override
  String get promoTwentyOffFirstBooking => '20% OFF First Booking';

  @override
  String get provider => 'Provider';

  @override
  String get providerSignInPrompt => 'Sign in to manage your provider account.';

  @override
  String get publishAd => 'Publish ad';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get rateYourExperience => 'Rate Your Experience';

  @override
  String get recentBookings => 'Recent bookings';

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String get removeAddress => 'Remove address';

  @override
  String get rename => 'Rename';

  @override
  String get renameAddress => 'Rename address';

  @override
  String get reviewSignInPrompt =>
      'Sign in to rate the services you have booked.';

  @override
  String get saveDraft => 'Save draft';

  @override
  String get selectDateTitle => 'Select Date';

  @override
  String get selectTime => 'Select Time';

  @override
  String get serviceArea => 'Service area';

  @override
  String get serviceAreaHint => 'e.g. Downtown Bengaluru';

  @override
  String get serviceCategory => 'Service Category';

  @override
  String get serviceSignInPrompt =>
      'Sign in with your mobile number to view this service.';

  @override
  String get setAsDefault => 'Set as default';

  @override
  String get shareDetailsHint => 'Share details about your experience...';

  @override
  String get statement => 'Statement';

  @override
  String get submitApplication => 'Submit Application';

  @override
  String get submitReview => 'Submit Review';

  @override
  String get tapChangeToChoose => 'Tap Change to choose your address';

  @override
  String get teamSize => 'Team Size';

  @override
  String get tellUsAboutBusiness => 'Tell us about your business';

  @override
  String get todayAtAGlance => 'Today at a glance';

  @override
  String get todaysBookings => 'Today\'s Bookings';

  @override
  String get todaysEarnings => 'Today\'s earnings';

  @override
  String get todaysTimeSlots => 'Today\'s Time Slots';

  @override
  String get trackSignInPrompt => 'Sign in to track your orders.';

  @override
  String get tradeLicense => 'Trade License';

  @override
  String get tradeLicenseHint =>
      'Upload a clear photo or PDF of your trade license';

  @override
  String get typeAMessage => 'Type a message...';

  @override
  String get upload => 'Upload';

  @override
  String get uploadDocuments => 'Upload required documents';

  @override
  String get uploaded => 'Uploaded';

  @override
  String get verifiedProvidersBlurb =>
      'Verified providers get more bookings and customer trust.';

  @override
  String get viewOrders => 'View orders';

  @override
  String get weekdaysOnly => 'Weekdays only';

  @override
  String get whatWentWell => 'What went well?';

  @override
  String get withdrawalRequested => 'Withdrawal requested';

  @override
  String get withdrawEarnings => 'Withdraw earnings';

  @override
  String get yesCancel => 'Yes, Cancel';

  @override
  String get youAreOffline => 'You\'re offline';

  @override
  String get youAreOnline => 'You\'re online';

  @override
  String get youEarnAfterFee => 'You earn (after 12% fee)';

  @override
  String get partnerDashboard => 'Partner dashboard';

  @override
  String get linkBankToGetPaid => 'Link your bank to get paid';

  @override
  String get addAccountToTransfer =>
      'Add your account so we can transfer your earnings';

  @override
  String get addBankAccount => 'Add bank account';

  @override
  String get listServiceOrItem => 'List a service or item';

  @override
  String get earningsThisWeek => 'Earnings this week';

  @override
  String get paymentConfirmed => 'Payment Confirmed';

  @override
  String get searchVendorsHint => 'Search vendors or services…';

  @override
  String get email => 'Email';

  @override
  String get noSellersYet => 'No sellers yet';

  @override
  String get listingsWillAppear =>
      'Listings will appear here once sellers start posting ads.';

  @override
  String get tapCardToViewVendor => 'Tap a card to view the vendor';

  @override
  String get verifiedVendor => 'Verified vendor';

  @override
  String get aboutThisService => 'About this service';

  @override
  String get locationCoverage => 'Location & coverage';

  @override
  String get contactVendor => 'Contact vendor';

  @override
  String get excellent => 'Excellent';

  @override
  String get sampleVendorReview =>
      '\"Spotless work and very professional team. Booked again the same week.\" — Layla M.';

  @override
  String get workOrderCaps => 'WORK ORDER';

  @override
  String get elkRepairCaps => 'ELK REPAIR';

  @override
  String get pickASlot => 'Pick a slot';

  @override
  String get cleanPlanCaps => 'CLEAN PLAN';

  @override
  String get elkCleanCaps => 'ELKCLEAN';

  @override
  String get loyalty => 'Loyalty';

  @override
  String get today => 'Today';

  @override
  String get balance => 'Balance';

  @override
  String get partnerAccount => 'Partner account';

  @override
  String get forUsers => 'For users';

  @override
  String get forSellers => 'For sellers';

  @override
  String get currentlySellerMode => 'Currently in Seller Mode';

  @override
  String get currentlyUserMode => 'Currently in User Mode';

  @override
  String get switchToSellerPanel => 'Switch to Seller Panel';

  @override
  String get switchToUserPanel => 'Switch to User Panel';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get currentLocation => 'Current location';

  @override
  String get chooseYourLocation => 'Choose your location';

  @override
  String get searchForAddress => 'Search for an address';

  @override
  String get findStreetArea => 'Find any street, area or landmark';

  @override
  String get useCurrentLocationTitle => 'Use current location';

  @override
  String get usesPhoneGps => 'Uses your phone GPS';

  @override
  String get savedAddressesSignIn => 'Sign in to use your saved addresses.';

  @override
  String get noSavedAddressesSearch =>
      'No saved addresses yet — search for one below.';

  @override
  String get savedAddressesTitle => 'Saved addresses';

  @override
  String get searchAddress => 'Search address';

  @override
  String get streetAreaHint => 'Street, area or landmark';

  @override
  String get noMatchingPlaces => 'No matching places.';

  @override
  String get startTypingToFind => 'Start typing to find an address.';

  @override
  String get turnOnLocationServices => 'Turn on location services to use this.';

  @override
  String get locationPermissionNeeded =>
      'Location permission is needed to detect your address.';

  @override
  String rateDriver(String driver) {
    return 'Rate $driver';
  }

  @override
  String get totalCaps => 'TOTAL';

  @override
  String get locating => 'Locating…';

  @override
  String get setPickupLocation => 'Set pickup location';

  @override
  String get setDropLocation => 'Set drop location';

  @override
  String get setPickupAndDrop =>
      'Set both the pickup and drop locations first.';
}
