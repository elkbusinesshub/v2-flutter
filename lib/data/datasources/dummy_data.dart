/// Static "fixture" payloads that stand in for real backend responses.
///
/// Every repository pulls its data from here through [ApiClient], using the
/// exact same `fromJson` factories that would be used against a live API —
/// so swapping [ApiClient]'s internals for real HTTP calls (see `dio` usage)
/// requires no changes to the repositories or blocs.
library;

const dummyUserJson = {
  'id': 'u_1001',
  'name': 'Ahmed Al-Rashid',
  'phone': '+91 98765 43210',
  'avatarInitials': 'AR',
  'bookingsCount': 12,
  'rewardPoints': 150,
  'rating': 4.8,
};

const dummyLanguagesJson = [
  {'code': 'en', 'flag': '🇬🇧', 'name': 'English', 'nativeName': 'English (Default)'},
  {'code': 'hi', 'flag': '🇮🇳', 'name': 'Hindi', 'nativeName': 'हिन्दी'},
  {'code': 'ml', 'flag': '🇮🇳', 'name': 'Malayalam', 'nativeName': 'മലയാളം'},
  {'code': 'ta', 'flag': '🇮🇳', 'name': 'Tamil', 'nativeName': 'தமிழ்'},
];

const dummyHomeFeedJson = {
  'userName': 'Ahmed Al-Rashid',
  'location': 'Dubai',
  'promo': {
    'title': '20% OFF First Booking',
    'subtitle': 'New users get exclusive discount on all services',
    'ctaLabel': 'Claim Offer →',
    'tag': 'NEW',
    'icon': '🎁',
  },
  'categories': [
    {'id': 'taxi',      'name': 'Taxi / Ride', 'icon': '🚕', 'colorHex': 0xFFE0F7F5},
    {'id': 'elkstay',  'name': 'ELK Stay',   'icon': '🏨', 'colorHex': 0xFFE6EFEA},
    {'id': 'cleaning', 'name': 'Cleaning',   'icon': '🧹', 'colorHex': 0xFFFEF3C7},
    {'id': 'car_rental','name': 'Car Rental', 'icon': '🚗', 'colorHex': 0xFFEDE9FE},
    {'id': 'repair',   'name': 'Repair',     'icon': '🔧', 'colorHex': 0xFFFCE7F3},
    {'id': 'porter',   'name': 'Porter',     'icon': '📦', 'colorHex': 0xFFD1FAE5},
  ],
  'bestSellers': [
    {
      'id': 'p_royal_shine',
      'name': 'Royal Shine',
      'initials': 'RS',
      'category': 'Cleaning · AED 85',
      'priceLabel': 'AED 85',
      'rating': 4.9,
      'colorHex': 0xFF4BBFB0,
      'verified': true,
    },
    {
      'id': 'p_speedride',
      'name': 'SpeedRide',
      'initials': 'SP',
      'category': 'Taxi · From AED 12',
      'priceLabel': 'AED 12',
      'rating': 4.8,
      'colorHex': 0xFFF5C518,
      'verified': true,
    },
    {
      'id': 'p_execcars',
      'name': 'ExecCars',
      'initials': 'EX',
      'category': 'Rental · AED 199/d',
      'priceLabel': 'AED 199',
      'rating': 4.7,
      'colorHex': 0xFF6366F1,
      'verified': true,
    },
  ],
};

const dummyServiceGroupsJson = [
  {
    'title': 'Cleaning',
    'icon': '🧹',
    'items': [
      {'id': 'home_cleaning', 'name': 'Home Cleaning', 'icon': '🏠'},
      {'id': 'deep_cleaning', 'name': 'Deep Cleaning', 'icon': '✨'},
      {'id': 'furniture_clean', 'name': 'Furniture Clean', 'icon': '🛋️'},
    ],
  },
  {
    'title': 'Laundry',
    'icon': '👕',
    'items': [
      {'id': 'wash_fold', 'name': 'Wash & Fold', 'icon': '🧺'},
      {'id': 'dry_cleaning', 'name': 'Dry Cleaning', 'icon': '👔'},
      {'id': 'ironing', 'name': 'Ironing', 'icon': '🔥'},
    ],
  },
  {
    'title': 'AC Service',
    'icon': '❄️',
    'items': [
      {'id': 'ac_cleaning', 'name': 'AC Cleaning', 'icon': '🫧'},
      {'id': 'ac_repair', 'name': 'AC Repair', 'icon': '🔧'},
      {'id': 'ac_install', 'name': 'AC Install', 'icon': '⚙️'},
    ],
  },
  {
    'title': 'Repairing',
    'icon': '🔨',
    'items': [
      {'id': 'electrical', 'name': 'Electrical', 'icon': '⚡'},
      {'id': 'plumbing', 'name': 'Plumbing', 'icon': '🚿'},
      {'id': 'handyman', 'name': 'Handyman', 'icon': '🛠️'},
    ],
  },
];

const dummyServiceDetailJson = {
  'id': 'deep_home_cleaning',
  'title': 'Deep Home Cleaning',
  'badge': 'BEST DEAL',
  'providerName': 'Royal Shine Cleaning Co.',
  'providerInitials': 'RS',
  'providerExperience': '12 years experience',
  'rating': 4.9,
  'reviewCount': 284,
  'duration': '3-4 hrs',
  'teamSize': '2 People',
  'category': 'Cleaning',
  'bookings': '1.2k+',
  'included': ['Kitchen', 'Bathrooms', 'Bedrooms', 'Floors', '+3 more'],
  'description':
      'Professional deep cleaning service using eco-friendly products. Covers all rooms including kitchen, bathrooms, and living areas.',
  'price': 149.0,
  'priceUnit': '/ session',
};

const dummyBookingDetailsJson = {
  'serviceId': 'deep_home_cleaning',
  'serviceName': 'Deep Home Cleaning',
  'dates': [
    {'day': 18, 'weekday': 'Mon'},
    {'day': 19, 'weekday': 'Tue'},
    {'day': 20, 'weekday': 'Wed'},
    {'day': 21, 'weekday': 'Thu'},
    {'day': 22, 'weekday': 'Fri'},
  ],
  'timeSlots': [
    {'time': '08:00', 'available': false},
    {'time': '10:00', 'available': true},
    {'time': '12:00', 'available': true},
    {'time': '14:00', 'available': true},
    {'time': '16:00', 'available': true},
    {'time': '18:00', 'available': false},
  ],
  'address': 'Apt 4B, Marina Heights, Dubai Marina',
  'pricing': {
    'serviceFee': 149.0,
    'promoCode': 'ELK20',
    'promoDiscount': 30.0,
    'total': 119.0,
  },
};

const dummyRideTypesJson = [
  {'id': 'auto', 'emoji': '🛺', 'name': 'Auto', 'price': 8.0},
  {'id': 'economy', 'emoji': '🚗', 'name': 'Economy', 'price': 15.0},
  {'id': 'premium', 'emoji': '🚙', 'name': 'Premium', 'price': 28.0},
];

const dummyTaxiLocationJson = {
  'pickup': 'Dubai Marina · Gate 3',
  'drop': 'Downtown Dubai, Burj Khalifa',
  'etaMinutes': 14,
  'distanceKm': 8.2,
};

const dummyOrderTrackingJson = {
  'orderId': '#ELK-2025-04921',
  'serviceName': 'Deep Home Cleaning',
  'serviceIcon': '🧹',
  'providerName': 'Royal Shine',
  'statusLabel': 'Arriving in 12 mins',
  'steps': [
    {'name': 'Booking Confirmed', 'time': 'Today, 09:15 AM', 'status': 'done'},
    {'name': 'Provider Accepted', 'time': 'Today, 09:18 AM', 'status': 'done'},
    {'name': 'On The Way', 'time': 'ETA: 12 mins', 'status': 'active'},
    {'name': 'In Progress', 'time': '—', 'status': 'pending'},
    {'name': 'Completed', 'time': '—', 'status': 'pending'},
  ],
};

const dummyChatThreadJson = {
  'contactName': 'Royal Shine',
  'contactInitials': 'RS',
  'contactStatus': '● Online · Service Provider',
  'dateLabel': 'Today, 9:15 AM',
  'messages': [
    {
      'id': 'm1',
      'text':
          "Hello! I have confirmed your booking for today at 12:00 PM. I'll be there soon!",
      'time': '9:16 AM',
      'isOutgoing': false,
      'senderInitials': 'RS',
    },
    {
      'id': 'm2',
      'text':
          'Great! Please ring the doorbell when you arrive. The entrance is at Block B.',
      'time': '9:18 AM',
      'isOutgoing': true,
      'senderInitials': null,
    },
    {
      'id': 'm3',
      'text': "Noted! I'm currently on my way. Will arrive in about 12 minutes. 🚐",
      'time': '9:41 AM',
      'isOutgoing': false,
      'senderInitials': 'RS',
    },
    {
      'id': 'm4',
      'text': '👍 See you soon!',
      'time': '9:42 AM',
      'isOutgoing': true,
      'senderInitials': null,
    },
  ],
};

const dummyReviewTargetJson = {
  'providerName': 'Royal Shine Cleaning',
  'providerInitials': 'RS',
  'serviceName': 'Deep Home Cleaning',
  'durationLabel': '3.5 hrs',
  'quickTags': ['On Time', 'Professional', 'Thorough Job', 'Friendly', 'Great Value'],
  'rewardPoints': 15,
};

const dummyPaymentMethodsJson = [
  {
    'id': 'wallet',
    'icon': '💳',
    'label': 'ELK Wallet',
    'subLabel': 'Balance: AED 240',
    'colorHex': 0xFFE0F7F5,
  },
  {
    'id': 'card',
    'icon': '💳',
    'label': 'Credit/Debit Card',
    'subLabel': '•••• •••• •••• 4821',
    'colorHex': 0xFFDBEAFE,
  },
  {
    'id': 'upi',
    'icon': '📱',
    'label': 'UPI / Digital Wallet',
    'subLabel': 'GPay, PhonePe, Paytm',
    'colorHex': 0xFFD1FAE5,
  },
  {
    'id': 'cash',
    'icon': '💵',
    'label': 'Cash on Delivery',
    'subLabel': 'Pay at service completion',
    'colorHex': 0xFFFEF3C7,
  },
];

const dummyWalletSummaryJson = {
  'balance': 240.50,
  'rewardPoints': 150,
  'transactions': [
    {
      'icon': '🧹',
      'title': 'Deep Home Cleaning',
      'date': '19 May 2026',
      'amount': 119.0,
      'isCredit': false,
      'colorHex': 0xFFE0F7F5,
    },
    {
      'icon': '💳',
      'title': 'Wallet Top-up',
      'date': '17 May 2026',
      'amount': 200.0,
      'isCredit': true,
      'colorHex': 0xFFD1FAE5,
    },
    {
      'icon': '🚕',
      'title': 'Taxi Ride · Economy',
      'date': '16 May 2026',
      'amount': 15.0,
      'isCredit': false,
      'colorHex': 0xFFDBEAFE,
    },
    {
      'icon': '🎁',
      'title': 'Referral Bonus',
      'date': '14 May 2026',
      'amount': 25.0,
      'isCredit': true,
      'colorHex': 0xFFFEF3C7,
    },
    {
      'icon': '🚗',
      'title': 'Car Rental · 3 Days',
      'date': '10 May 2026',
      'amount': 450.0,
      'isCredit': false,
      'colorHex': 0xFFEDE9FE,
    },
  ],
};

const dummyOffersJson = {
  'rewardPoints': 150,
  'rewardDiscountLabel': '≈ AED 15 discount available',
  'offers': [
    {
      'id': 'elk20',
      'tagLabel': 'FOR NEW USERS',
      'title': 'Welcome Offer',
      'description': 'Get 20% off your first booking on any service category',
      'code': 'ELK20',
      'expiry': 'Expires 31 May 2026',
      'discountLabel': '20%',
      'discountSubLabel': 'OFF',
      'gradientStartHex': 0xFF0D3D35,
      'gradientEndHex': 0xFF4BBFB0,
    },
    {
      'id': 'clean30',
      'tagLabel': 'CLEANING SPECIAL',
      'title': 'Flat AED 30 Off',
      'description': 'On deep cleaning or AC services booked this weekend',
      'code': 'CLEAN30',
      'expiry': 'Valid: Fri-Sun only',
      'discountLabel': 'AED',
      'discountSubLabel': '30',
      'gradientStartHex': 0xFF1A2E3D,
      'gradientEndHex': 0xFF4F46E5,
    },
  ],
};

const dummyNotificationsJson = [
  {
    'id': 'n1',
    'icon': '🧹',
    'colorHex': 0xFFE0F7F5,
    'title': 'Provider On The Way',
    'message': 'Royal Shine is heading to your location. ETA: 12 mins',
    'time': '2 min ago',
    'isUnread': true,
  },
  {
    'id': 'n2',
    'icon': '🎉',
    'colorHex': 0xFFFEF3C7,
    'title': 'Special Weekend Offer!',
    'message': 'Get AED 30 off on cleaning services this weekend. Use CLEAN30',
    'time': '1 hr ago',
    'isUnread': true,
  },
  {
    'id': 'n3',
    'icon': '✅',
    'colorHex': 0xFFD1FAE5,
    'title': 'Booking Confirmed',
    'message': 'Your Deep Cleaning booking #ELK-04921 is confirmed for 19 May',
    'time': '3 hrs ago',
    'isUnread': false,
  },
  {
    'id': 'n4',
    'icon': '💳',
    'colorHex': 0xFFDBEAFE,
    'title': 'Payment Successful',
    'message': 'AED 119 paid for Deep Home Cleaning. Receipt sent to email',
    'time': 'Yesterday',
    'isUnread': false,
  },
  {
    'id': 'n5',
    'icon': '⭐',
    'colorHex': 0xFFEDE9FE,
    'title': 'You Earned 15 Points!',
    'message': 'Thanks for rating your last service. Points added to wallet',
    'time': '2 days ago',
    'isUnread': false,
  },
];

const dummyRentalCarsJson = [
  {
    'id': 'camry',
    'name': 'Toyota Camry',
    'type': 'Sedan',
    'transmission': 'Automatic',
    'seats': 5,
    'icon': '🚗',
    'pricePerDay': 199.0,
    'isBestDeal': true,
  },
  {
    'id': 'patrol',
    'name': 'Nissan Patrol',
    'type': 'SUV',
    'transmission': 'Automatic',
    'seats': 7,
    'icon': '🚙',
    'pricePerDay': 349.0,
    'isBestDeal': false,
  },
  {
    'id': 'eclass',
    'name': 'Mercedes E-Class',
    'type': 'Luxury',
    'transmission': 'Automatic',
    'seats': 4,
    'icon': '🚘',
    'pricePerDay': 599.0,
    'isBestDeal': false,
  },
];

const dummyPorterJson = {
  'vehicles': [
    {'id': 'bike', 'emoji': '🏍️', 'name': 'Bike', 'capacity': 'Up to 5kg'},
    {'id': 'van', 'emoji': '🚐', 'name': 'Van', 'capacity': 'Up to 500kg'},
    {'id': 'truck', 'emoji': '🚚', 'name': 'Truck', 'capacity': 'Up to 3 Ton'},
  ],
  'route': {
    'pickupLabel': 'Pickup Location',
    'pickupAddress': 'Dubai Marina, Block C',
    'dropLabel': 'Drop Location',
    'dropAddress': 'Downtown Dubai, Tower 4',
    'packageType': 'Electronics',
    'weight': '2.5 kg',
    'estimatedFare': 35.0,
    'distanceKm': 4.2,
    'etaMinutes': 18,
  },
};

const dummyProviderProfileJson = {
  'businessName': 'Royal Shine Co.',
  'modeLabel': '✓ VERIFIED',
  'isAvailable': true,
  'stats': [
    {'label': 'Active Orders', 'value': '8', 'trend': '▲ 2 new'},
    {'label': 'This Month', 'value': 'AED 2,840', 'trend': '▲ 12%'},
    {'label': 'Rating', 'value': '4.9★', 'trend': '284 reviews'},
  ],
  'requests': [
    {
      'id': 'r1',
      'serviceName': 'Deep Home Cleaning',
      'customerName': 'Ahmed Al-Rashid',
      'location': 'Dubai Marina',
      'time': 'Today 12:00 PM',
      'amount': 149.0,
      'status': 'pending',
    },
    {
      'id': 'r2',
      'serviceName': 'Kitchen Cleaning',
      'customerName': 'Sara Mohammed',
      'location': 'JBR',
      'time': 'Today 4:00 PM',
      'amount': 99.0,
      'status': 'accepted',
    },
  ],
};

const dummyProviderScheduleJson = {
  'todaysBookingsCount': 3,
  'days': [
    {'label': 'M', 'available': true, 'isToday': false},
    {'label': 'T', 'available': true, 'isToday': false},
    {'label': 'W', 'available': false, 'isToday': true},
    {'label': 'T', 'available': true, 'isToday': false},
    {'label': 'F', 'available': true, 'isToday': false},
    {'label': 'S', 'available': false, 'isToday': false},
    {'label': 'S', 'available': false, 'isToday': false},
  ],
  'slots': [
    {'timeRange': '09:00 – 12:00', 'status': 'active'},
    {'timeRange': '13:00 – 16:00', 'status': 'pending'},
    {'timeRange': '17:00 – 20:00', 'status': 'available'},
  ],
};

const dummyEarningsJson = {
  'totalEarnings': 2840.0,
  'monthLabel': 'May 2026',
  'trendLabel': '▲ 12% vs last month',
  'completedJobs': 38,
  'completedJobsTrend': '▲ 6 this week',
  'avgPerJob': 74.0,
  'avgPerJobTrend': '▲ AED 8',
  'transactions': [
    {
      'icon': '🧹',
      'title': 'Deep Cleaning · Ahmed A.',
      'date': 'Today 12:00 PM',
      'amount': 119.0,
      'isCredit': true,
      'colorHex': 0xFFE0F7F5,
    },
    {
      'icon': '💳',
      'title': 'Kitchen Cleaning · Sara M.',
      'date': 'Yesterday',
      'amount': 89.0,
      'isCredit': true,
      'colorHex': 0xFFD1FAE5,
    },
    {
      'icon': '❄️',
      'title': 'AC Service · Khalid R.',
      'date': '17 May',
      'amount': 149.0,
      'isCredit': true,
      'colorHex': 0xFFDBEAFE,
    },
    {
      'icon': '💳',
      'title': 'Withdrawal to Bank',
      'date': '15 May',
      'amount': 500.0,
      'isCredit': false,
      'colorHex': 0xFFEDE9FE,
    },
  ],
};
