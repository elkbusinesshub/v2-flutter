import 'package:flutter/material.dart';

import '../../core/theme/seller_colors.dart';

class SellerListing {
  const SellerListing({required this.title, required this.category, required this.emoji, required this.tileBg, required this.price, required this.unit, required this.status, this.views = 0, this.bookings = 0});
  final String title, category, emoji, price, unit, status;
  final Color tileBg;
  final int views, bookings;
}

class SellerOrder {
  const SellerOrder({required this.id, required this.customerName, required this.service, required this.emoji, required this.tileBg, required this.amount, required this.when, required this.status, this.address = '', this.phone = ''});
  final String id, customerName, service, emoji, amount, when, address, phone, status;
  final Color tileBg;
}

class SellerTransaction {
  const SellerTransaction({required this.title, required this.date, required this.amount, required this.isCredit});
  final String title, date, amount;
  final bool isCredit;
}

class SellerNotif {
  const SellerNotif({required this.icon, required this.tileBg, required this.title, required this.body, required this.time, this.unread = false, this.hasAction = false});
  final String icon, title, body, time;
  final Color tileBg;
  final bool unread, hasAction;
}

const sellerListings = [
  SellerListing(title: 'Deep Home Cleaning', category: 'Cleaning', emoji: '🧹', tileBg: SellerColors.tYellow, price: 'AED 180', unit: '/ visit', status: 'active', views: 842, bookings: 54),
  SellerListing(title: 'Toyota Corolla 2024', category: 'Car Rental', emoji: '🚗', tileBg: SellerColors.tPurple, price: 'AED 120', unit: '/ day', status: 'active', views: 1203, bookings: 88),
  SellerListing(title: 'AC Repair & Service', category: 'Repair', emoji: '🔧', tileBg: SellerColors.tPink, price: 'AED 90', unit: 'starting', status: 'active', views: 560, bookings: 31),
  SellerListing(title: 'Wedding Decor Package', category: 'Events', emoji: '🎪', tileBg: SellerColors.tBlue, price: 'AED 2,500', unit: 'starting', status: 'pending'),
  SellerListing(title: 'Furniture Movers', category: 'Porter', emoji: '📦', tileBg: SellerColors.tGreen, price: 'AED 250', unit: '/ job', status: 'paused', views: 340, bookings: 19),
];

const sellerOrders = [
  SellerOrder(id: '#8821', customerName: 'Sara M.', service: 'Deep Home Cleaning', emoji: '🧹', tileBg: SellerColors.tYellow, amount: 'AED 180', when: 'Today, 2:00 PM', address: 'Marina Heights, Tower 2', phone: '+971 50 •• ••72', status: 'new'),
  SellerOrder(id: '#8820', customerName: 'Rashid K.', service: 'AC Repair & Service', emoji: '🔧', tileBg: SellerColors.tPink, amount: 'AED 130', when: 'Today, 4:30 PM', address: 'JLT Cluster D', phone: '+971 55 •• ••18', status: 'new'),
  SellerOrder(id: '#8819', customerName: 'Lena P.', service: 'Toyota Corolla rental', emoji: '🚗', tileBg: SellerColors.tPurple, amount: 'AED 360', when: '3 days', address: 'Pickup: Business Bay', phone: '+971 52 •• ••05', status: 'new'),
  SellerOrder(id: '#8817', customerName: 'Omar A.', service: 'Deep Home Cleaning', emoji: '🧹', tileBg: SellerColors.tYellow, amount: 'AED 180', when: 'In progress', address: 'Downtown, Burj Views', status: 'progress'),
  SellerOrder(id: '#8816', customerName: 'Priya S.', service: 'Furniture Movers', emoji: '📦', tileBg: SellerColors.tGreen, amount: 'AED 250', when: 'In progress', address: 'Al Barsha 1', status: 'progress'),
  SellerOrder(id: '#8810', customerName: 'Hamad J.', service: 'AC Repair', emoji: '🔧', tileBg: SellerColors.tPink, amount: 'AED 90', when: 'Yesterday', status: 'completed'),
  SellerOrder(id: '#8809', customerName: 'Maria G.', service: 'Car Rental – 2 days', emoji: '🚗', tileBg: SellerColors.tPurple, amount: 'AED 240', when: '2 days ago', status: 'completed'),
  SellerOrder(id: '#8805', customerName: 'Ali R.', service: 'Deep Cleaning', emoji: '🧹', tileBg: SellerColors.tYellow, amount: 'AED 180', when: '3 days ago', status: 'completed'),
  SellerOrder(id: '#8801', customerName: 'Noor F.', service: 'Wedding Decor', emoji: '🎪', tileBg: SellerColors.tBlue, amount: 'AED 2,500', when: '1 week ago', status: 'completed'),
];

const sellerTransactions = [
  SellerTransaction(title: 'Booking #8810 – AC Repair', date: 'Today · 11:20 AM', amount: '90.00', isCredit: true),
  SellerTransaction(title: 'Booking #8809 – Car Rental', date: 'Yesterday', amount: '240.00', isCredit: true),
  SellerTransaction(title: 'Platform fee (12%)', date: 'Yesterday', amount: '28.80', isCredit: false),
  SellerTransaction(title: 'Booking #8805 – Cleaning', date: '3 days ago', amount: '180.00', isCredit: true),
  SellerTransaction(title: 'Withdrawal to bank', date: '5 days ago', amount: '1,500.00', isCredit: false),
];

const sellerNotifs = [
  SellerNotif(icon: '🔥', tileBg: SellerColors.tYellow, title: 'New booking request', body: 'Sara M. wants Deep Home Cleaning today at 2:00 PM – AED 180', time: '2 min ago', unread: true, hasAction: true),
  SellerNotif(icon: '💰', tileBg: SellerColors.tGreen, title: 'Payment received', body: 'AED 90 for booking #8810 has been added to your wallet', time: '1 hr ago', unread: true),
  SellerNotif(icon: '⭐', tileBg: SellerColors.tPink, title: 'New 5-star review', body: '"Excellent service, very professional!" – Hamad J.', time: '3 hrs ago', unread: true),
  SellerNotif(icon: '✅', tileBg: SellerColors.tMint, title: 'Listing approved', body: 'Your ad "AC Repair & Service" is now live and visible to customers', time: 'Yesterday'),
  SellerNotif(icon: '⏳', tileBg: SellerColors.tBlue, title: 'Listing under review', body: '"Wedding Decor Package" is being reviewed – usually takes 24 hrs', time: 'Yesterday'),
  SellerNotif(icon: '🏦', tileBg: SellerColors.tOrange, title: 'Action needed', body: 'Link your bank account to withdraw your AED 3,280 balance', time: '2 days ago'),
];

const barData = [40, 62, 48, 75, 58, 90, 82];
const barDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
