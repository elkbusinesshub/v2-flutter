import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

// ── design tokens ──────────────────────────────────────────────────────────
const _dark9 = Color(0xFF0C241D);
const _dark7 = Color(0xFF1A4A3C);
const _tDp = Color(0xFF0F6E60);
const _t050 = Color(0xFFE7F6F2);
const _yd = Color(0xFFE6B500);
const _y050 = Color(0xFFFEF6D8);
const _ink9 = Color(0xFF16271F);
const _ink7 = Color(0xFF2A3B31);
const _ink5 = Color(0xFF5E6E64);
const _ink4 = Color(0xFF8C9890);
const _bg = Color(0xFFF1F4EE);
const _line = Color(0xFFE6EBE5);
const _chip = Color(0xFFEFF2EC);

// ── svg illustrations ─────────────────────────────────────────────────────────
const _svgDefs =
    '<defs>'
    '<linearGradient id="gWood" x1="0" y1="0" x2="1" y2="1">'
    '<stop offset="0" stop-color="#DBA262"/><stop offset="1" stop-color="#9C6A2E"/></linearGradient>'
    '<linearGradient id="gStraw" x1="0" y1="0" x2="0" y2="1">'
    '<stop offset="0" stop-color="#F0CE7A"/><stop offset="1" stop-color="#CC9433"/></linearGradient>'
    '<linearGradient id="gYel" x1="0" y1="0" x2="0" y2="1">'
    '<stop offset="0" stop-color="#FBDA4E"/><stop offset="1" stop-color="#E9B71C"/></linearGradient>'
    '<linearGradient id="gTealI" x1="0" y1="0" x2="0" y2="1">'
    '<stop offset="0" stop-color="#2FB29C"/><stop offset="1" stop-color="#137A6D"/></linearGradient>'
    '</defs>';

String _svg(String body) =>
    '<svg viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">$_svgDefs$body</svg>';

const _svgBroom =
    '<path d="M36 8 L21 25" stroke="url(#gWood)" stroke-width="5" stroke-linecap="round"/>'
    '<path d="M22 23 L26 27" stroke="#137A6D" stroke-width="6" stroke-linecap="round"/>'
    '<path d="M21 25 L9 39 Q17 44 29 37 Z" fill="url(#gStraw)"/>'
    '<path d="M14 30 L11 38M18 28 L17 40M22 28 L24 39M25 30 L29 36"'
    ' stroke="#A9772A" stroke-width="1.2" stroke-linecap="round" opacity=".7"/>';

const _svgTaxi =
    '<rect x="20" y="11" width="9" height="5" rx="1.3" fill="#15241F"/>'
    '<path d="M9 31c0-1 .5-2.4 1.3-3.3l3.2-6.3c.8-1.6 2.3-2.4 4-2.4h12.9'
    'c1.7 0 3.2.8 4 2.4l3.2 6.3c.8.9 1.3 2.3 1.3 3.3v6c0 1.1-.9 2-2 2H11'
    'c-1.1 0-2-.9-2-2v-6Z" fill="url(#gYel)"/>'
    '<path d="M14.4 21.6 12.6 26h22.8l-1.8-4.4c-.5-1-1.3-1.6-2.4-1.6H16.8'
    'c-1.1 0-1.9.6-2.4 1.6Z" fill="#2C3A44"/>'
    '<rect x="9" y="29" width="30" height="3" fill="#15241F"/>'
    '<rect x="9" y="29" width="5" height="3" fill="#F6CE19"/>'
    '<rect x="19" y="29" width="5" height="3" fill="#F6CE19"/>'
    '<rect x="29" y="29" width="5" height="3" fill="#F6CE19"/>'
    '<circle cx="16" cy="37" r="3.4" fill="#15241F"/>'
    '<circle cx="32" cy="37" r="3.4" fill="#15241F"/>'
    '<ellipse cx="38" cy="27" rx="1.6" ry="2" fill="#FCEFB0"/>';

const _svgWrench =
    '<path d="M31 11a8 8 0 0 0-10 10.4L9 33.5a3.4 3.4 0 1 0 4.8 4.8'
    'l12.1-12.1A8 8 0 0 0 37 16l-4.3 4.3-4-.6-.6-4L32.5 11Z" fill="url(#gTealI)"/>'
    '<path d="M30 28l9 9a2.9 2.9 0 0 1-4 4l-9-9" fill="#0F6E60"/>'
    '<circle cx="13" cy="34.5" r="1.7" fill="#fff"/>';

const _svgSpray =
    '<rect x="17" y="20" width="15" height="19" rx="3.5" fill="url(#gTealI)"/>'
    '<rect x="20.5" y="14" width="8" height="6" fill="#0F6E60"/>'
    '<path d="M20.5 15.5 H34 V19 h-4" fill="none" stroke="#15241F" stroke-width="2.6"/>'
    '<path d="M37 10l4-2M38 14h5M37 18l4 2" stroke="#88C9BD" stroke-width="1.6" stroke-linecap="round"/>'
    '<rect x="20" y="26" width="9" height="7" rx="1.5" fill="#DFF3EF" opacity=".85"/>';

const _svgCar =
    '<path d="M10 27c0-.8.4-1.9 1-2.6l3-5c.8-1.3 2-2 3.5-2h13'
    'c1.5 0 2.7.7 3.5 2l3 5c.6.7 1 1.8 1 2.6v6c0 1.1-.9 2-2 2H12'
    'c-1.1 0-2-.9-2-2v-6Z" fill="url(#gYel)"/>'
    '<path d="M15.5 19.5 14 24h20l-1.5-4.5c-.4-1-1.2-1.5-2.2-1.5H17.7'
    'c-1 0-1.8.5-2.2 1.5Z" fill="#2C3A44"/>'
    '<circle cx="16" cy="35" r="3.2" fill="#15241F"/>'
    '<circle cx="32" cy="35" r="3.2" fill="#15241F"/>'
    '<ellipse cx="12.5" cy="28.5" rx="1.5" ry="1.8" fill="#FCEFB0"/>'
    '<ellipse cx="35.5" cy="28.5" rx="1.5" ry="1.8" fill="#FCEFB0"/>';

const _svgTruck =
    '<rect x="17" y="13" width="22" height="19" rx="1.5" fill="url(#gYel)"/>'
    '<path d="M8 21c0-.6.4-1 1-1h8v12H9c-.6 0-1-.4-1-1v-10Z" fill="url(#gTealI)"/>'
    '<rect x="10" y="22.5" width="5.5" height="4.5" rx="1" fill="#DFF3EF"/>'
    '<rect x="8" y="30" width="31" height="3" fill="#15241F"/>'
    '<circle cx="15" cy="36" r="3.2" fill="#15241F"/>'
    '<circle cx="31" cy="36" r="3.2" fill="#15241F"/>';

const _svgBld =
    '<path d="M8 14 24 7 40 14Z" fill="#fff"/>'
    '<rect x="10" y="14" width="28" height="26" rx="2" fill="#fff" opacity=".92"/>'
    '<rect x="14" y="18" width="5" height="5" rx="1" fill="#16402F"/>'
    '<rect x="21.5" y="18" width="5" height="5" rx="1" fill="#16402F"/>'
    '<rect x="29" y="18" width="5" height="5" rx="1" fill="#16402F"/>'
    '<rect x="14" y="26" width="5" height="5" rx="1" fill="#16402F"/>'
    '<rect x="29" y="26" width="5" height="5" rx="1" fill="#16402F"/>'
    '<rect x="21.5" y="32" width="6" height="8" rx="1" fill="#F6CE19"/>';

// ── vendor data ─────────────────────────────────────────────────────────────
class _Vendor {
  const _Vendor({
    required this.id,
    required this.vendor,
    required this.title,
    required this.cat,
    required this.ill,
    required this.grad,
    required this.radialGlow,
    required this.badge,
    required this.badgeDark,
    required this.price,
    required this.oldPrice,
    required this.rating,
    required this.jobs,
    required this.eta,
    required this.desc,
    required this.incl,
    required this.addr,
    required this.phone,
  });

  final String id, vendor, title, cat, ill, badge, desc, addr, phone;
  final bool badgeDark;
  final int price, oldPrice;
  final double rating;
  final String jobs, eta;
  final LinearGradient grad;
  final Color radialGlow;
  final List<String> incl;
}

const _vendors = <_Vendor>[
  _Vendor(
    id: 'royal',
    vendor: 'Royal Shine',
    title: 'Deep Home Clean',
    cat: 'Cleaning',
    ill: _svgBroom,
    grad: LinearGradient(
      colors: [Color(0xFF2FB29C), Color(0xFF137A6D)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    radialGlow: Color(0xFF3FD2B4),
    badge: '15% off',
    badgeDark: false,
    price: 72,
    oldPrice: 85,
    rating: 4.9,
    jobs: '1.2k',
    eta: '90 min',
    desc:
        'Professional deep cleaning by trained, uniformed staff using eco-friendly, child-safe products. Ideal for move-in/out or a thorough seasonal refresh.',
    incl: [
      'Kitchen & appliances degreased',
      'Bathrooms deep-sanitized',
      'Floors, windows & dusting',
      'Eco-friendly, child-safe products',
    ],
    addr: 'Serves Al Reem Island & Reem area · within 5 km',
    phone: '+971 50 123 4567',
  ),
  _Vendor(
    id: 'speed',
    vendor: 'SpeedRide',
    title: 'Airport Transfer',
    cat: 'Taxi',
    ill: _svgTaxi,
    grad: LinearGradient(
      colors: [Color(0xFFF6CE19), Color(0xFFE0A012)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    radialGlow: Color(0xFFFBE07A),
    badge: 'New',
    badgeDark: true,
    price: 12,
    oldPrice: 18,
    rating: 4.8,
    jobs: '5k',
    eta: '5 min',
    desc:
        'Reliable, on-time airport transfers with professional drivers. Includes flight tracking and complimentary wait time so you never rush.',
    incl: [
      'Meet & greet at terminal',
      'Live flight tracking',
      'Free 60-min wait',
      'Luggage assistance',
    ],
    addr: 'Pickup across Al Reem & Abu Dhabi city',
    phone: '+971 50 765 4321',
  ),
  _Vendor(
    id: 'express',
    vendor: 'Express Fix',
    title: 'AC Service & Fix',
    cat: 'Repair',
    ill: _svgWrench,
    grad: LinearGradient(
      colors: [Color(0xFFEE7CA0), Color(0xFFD14B77)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    radialGlow: Color(0xFFF7B6CC),
    badge: '30% off',
    badgeDark: false,
    price: 40,
    oldPrice: 58,
    rating: 4.7,
    jobs: '860',
    eta: '60 min',
    desc:
        'Certified technicians for AC servicing, gas refill, and quick fixes. Transparent pricing and a 30-day workmanship warranty on every job.',
    incl: [
      'Full AC inspection',
      'Filter clean & gas check',
      'Minor parts included',
      '30-day warranty',
    ],
    addr: 'Serves Al Reem Island · same-day slots',
    phone: '+971 50 998 2211',
  ),
  _Vendor(
    id: 'sparkle',
    vendor: 'Sparkle Crew',
    title: 'Sofa & Carpet Care',
    cat: 'Cleaning',
    ill: _svgSpray,
    grad: LinearGradient(
      colors: [Color(0xFF5FBF6E), Color(0xFF2E8B4A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    radialGlow: Color(0xFF8FD99A),
    badge: '10% off',
    badgeDark: false,
    price: 55,
    oldPrice: 62,
    rating: 4.8,
    jobs: '740',
    eta: '2 hrs',
    desc:
        'Steam-powered deep cleaning for sofas, carpets and mattresses. Removes stains, odours and dust mites with fabric-safe solutions.',
    incl: [
      'Steam & shampoo treatment',
      'Stain & odour removal',
      'Quick-dry finish',
      'Fabric-safe products',
    ],
    addr: 'Serves Al Reem Island & nearby towers',
    phone: '+971 50 442 8890',
  ),
  _Vendor(
    id: 'citycab',
    vendor: 'CityCab',
    title: 'City Ride 24/7',
    cat: 'Taxi',
    ill: _svgTaxi,
    grad: LinearGradient(
      colors: [Color(0xFF4FA3E3), Color(0xFF2568B2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    radialGlow: Color(0xFF7FC4F0),
    badge: 'Popular',
    badgeDark: true,
    price: 8,
    oldPrice: 10,
    rating: 4.6,
    jobs: '12k',
    eta: '3 min',
    desc:
        'Round-the-clock city rides with fixed, transparent fares. Clean cars, courteous drivers and quick pickups anywhere in the city.',
    incl: [
      'Fixed upfront fares',
      'Clean, AC vehicles',
      '24/7 availability',
      'Live trip tracking',
    ],
    addr: 'Pickup across Abu Dhabi city',
    phone: '+971 50 221 3344',
  ),
  _Vendor(
    id: 'handypro',
    vendor: 'HandyPro',
    title: 'Plumbing & Electrical',
    cat: 'Repair',
    ill: _svgWrench,
    grad: LinearGradient(
      colors: [Color(0xFF8E7CEE), Color(0xFF5B4BC9)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    radialGlow: Color(0xFFB3A6F7),
    badge: '20% off',
    badgeDark: false,
    price: 35,
    oldPrice: 45,
    rating: 4.8,
    jobs: '1.5k',
    eta: '45 min',
    desc:
        'Licensed plumbers and electricians for leaks, fittings, wiring and installations. Upfront quotes before any work begins.',
    incl: [
      'Licensed technicians',
      'Upfront quote',
      'Spare parts sourced',
      '30-day warranty',
    ],
    addr: 'Serves Al Reem & Al Maryah Island',
    phone: '+971 50 667 1122',
  ),
  _Vendor(
    id: 'driveeasy',
    vendor: 'DriveEasy',
    title: 'Daily Car Rental',
    cat: 'Car rental',
    ill: _svgCar,
    grad: LinearGradient(
      colors: [Color(0xFFE2972E), Color(0xFFC06D12)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    radialGlow: Color(0xFFF0B45C),
    badge: 'Hot',
    badgeDark: true,
    price: 89,
    oldPrice: 110,
    rating: 4.7,
    jobs: '2.3k',
    eta: '30 min',
    desc:
        'Well-maintained sedans and hatchbacks delivered to your door. Full insurance and unlimited city mileage included.',
    incl: [
      'Free doorstep delivery',
      'Full insurance cover',
      'Unlimited city mileage',
      '24/7 roadside assist',
    ],
    addr: 'Delivery across Al Reem & downtown',
    phone: '+971 50 889 5566',
  ),
  _Vendor(
    id: 'falcon',
    vendor: 'Falcon Rentals',
    title: 'Weekly SUV Deals',
    cat: 'Car rental',
    ill: _svgCar,
    grad: LinearGradient(
      colors: [Color(0xFF2FB29C), Color(0xFF137A6D)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    radialGlow: Color(0xFF3FD2B4),
    badge: '25% off',
    badgeDark: false,
    price: 480,
    oldPrice: 640,
    rating: 4.9,
    jobs: '980',
    eta: '1 hr',
    desc:
        'Premium SUVs on flexible weekly plans. Ideal for families and desert trips, with free swaps and priority support.',
    incl: [
      'Late-model SUVs',
      'Free vehicle swap',
      'Comprehensive insurance',
      'Priority support line',
    ],
    addr: 'Branches in Al Reem & airport',
    phone: '+971 50 773 2211',
  ),
  _Vendor(
    id: 'quickshift',
    vendor: 'QuickShift',
    title: 'House Shifting',
    cat: 'Porter',
    ill: _svgTruck,
    grad: LinearGradient(
      colors: [Color(0xFFEE7CA0), Color(0xFFD14B77)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    radialGlow: Color(0xFFF7B6CC),
    badge: '15% off',
    badgeDark: false,
    price: 150,
    oldPrice: 175,
    rating: 4.8,
    jobs: '620',
    eta: 'Same day',
    desc:
        'Full house and office moves with trained crew, packing materials and furniture assembly at the new place.',
    incl: [
      'Trained moving crew',
      'Packing materials included',
      'Furniture disassembly & setup',
      'Damage protection cover',
    ],
    addr: 'Moves within Abu Dhabi & Dubai',
    phone: '+971 50 334 7788',
  ),
  _Vendor(
    id: 'boxvan',
    vendor: 'BoxVan',
    title: 'Mini Truck & Driver',
    cat: 'Porter',
    ill: _svgTruck,
    grad: LinearGradient(
      colors: [Color(0xFF4FA3E3), Color(0xFF2568B2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    radialGlow: Color(0xFF7FC4F0),
    badge: 'New',
    badgeDark: true,
    price: 60,
    oldPrice: 75,
    rating: 4.5,
    jobs: '310',
    eta: '40 min',
    desc:
        'On-demand mini truck with driver for single-item and small moves. Pay by the hour, helper optional.',
    incl: [
      'Driver included',
      'Hourly billing',
      'Optional helper',
      'Straps & blankets provided',
    ],
    addr: 'Serves Al Reem Island · on demand',
    phone: '+971 50 556 9900',
  ),
  _Vendor(
    id: 'marina',
    vendor: 'ELK Stay Marina',
    title: 'Studio near Marina',
    cat: 'Stay',
    ill: _svgBld,
    grad: LinearGradient(
      colors: [Color(0xFF8E7CEE), Color(0xFF5B4BC9)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    radialGlow: Color(0xFFB3A6F7),
    badge: '20% off',
    badgeDark: false,
    price: 220,
    oldPrice: 275,
    rating: 4.7,
    jobs: '312',
    eta: 'Check-in 2pm',
    desc:
        'Fully furnished studio minutes from the marina. Weekly housekeeping, fast Wi-Fi and all bills included in the rate.',
    incl: [
      'All bills included',
      'Weekly housekeeping',
      'High-speed Wi-Fi',
      'Free cancellation 48h',
    ],
    addr: 'Marina Bay, Al Reem Island',
    phone: '+971 50 118 4455',
  ),
  _Vendor(
    id: 'reemres',
    vendor: 'Reem Residences',
    title: 'Furnished 1BR Stay',
    cat: 'Stay',
    ill: _svgBld,
    grad: LinearGradient(
      colors: [Color(0xFF5FBF6E), Color(0xFF2E8B4A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    radialGlow: Color(0xFF8FD99A),
    badge: 'Top pick',
    badgeDark: true,
    price: 310,
    oldPrice: 350,
    rating: 4.9,
    jobs: '540',
    eta: 'Check-in 3pm',
    desc:
        'Spacious one-bedroom apartment with balcony views, gym and pool access. Perfect for monthly and extended stays.',
    incl: [
      'Gym & pool access',
      'Balcony sea view',
      'Smart TV & workspace',
      'Monthly discounts',
    ],
    addr: 'Reem Central Park district',
    phone: '+971 50 990 2233',
  ),
];

// ── internal screens enum ────────────────────────────────────────────────────
enum _Sn { list, detail }

// ── screen ───────────────────────────────────────────────────────────────────
class BestSellersScreen extends StatefulWidget {
  const BestSellersScreen({super.key});

  @override
  State<BestSellersScreen> createState() => _State();
}

class _State extends State<BestSellersScreen> {
  final List<_Sn> _stack = [_Sn.list];
  _Vendor? _cur;
  String _query = '';

  void _push(_Sn screen, {_Vendor? vendor}) {
    setState(() {
      if (vendor != null) _cur = vendor;
      _stack.add(screen);
    });
  }

  void _pop() {
    if (_stack.length > 1) {
      setState(() => _stack.removeLast());
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) => _pop(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        ),
        child: switch (_stack.last) {
          _Sn.list => KeyedSubtree(
            key: const ValueKey('list'),
            child: _listScreen(),
          ),
          _Sn.detail => KeyedSubtree(
            key: ValueKey('detail-${_cur!.id}'),
            child: _detailScreen(),
          ),
        },
      ),
    );
  }

  // ── list screen ────────────────────────────────────────────────────────────
  Widget _listScreen() {
    final top = MediaQuery.of(context).padding.top;
    final q = _query.trim().toLowerCase();
    final results = q.isEmpty
        ? _vendors
        : _vendors
              .where(
                (v) =>
                    v.title.toLowerCase().contains(q) ||
                    v.vendor.toLowerCase().contains(q) ||
                    v.cat.toLowerCase().contains(q),
              )
              .toList();

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _DarkHeader(title: 'Best sellers', top: top, onBack: _pop),
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _line),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F142818),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, size: 19, color: _tDp),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _ink9,
                      ),
                      cursorColor: _tDp,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        hintText: 'Search vendors or services…',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _ink4.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: q.isNotEmpty ? _searchResults(results) : _railsBody(),
          ),
        ],
      ),
    );
  }

  // ── search results (flat grid) ───────────────────────────────────────────
  Widget _searchResults(List<_Vendor> results) {
    if (results.isEmpty) {
      return Center(
        child: Text(
          'No vendors found for "$_query"',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _ink4,
          ),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: results.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.88,
      ),
      itemBuilder: (context, i) => _VendorCard(
        vendor: results[i],
        onTap: () => _push(_Sn.detail, vendor: results[i]),
      ),
    );
  }

  // ── netflix-style rails ──────────────────────────────────────────────────
  static const _catTitles = <String, String>{
    'Cleaning': 'Cleaning specialists',
    'Taxi': 'Taxi & rides',
    'Repair': 'Repair & maintenance',
    'Car rental': 'Car rental',
    'Porter': 'Porter & movers',
    'Stay': 'Stays for you',
  };

  Widget _railsBody() {
    final topRated = [..._vendors]
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final cats = <String>[];
    for (final v in _vendors) {
      if (!cats.contains(v.cat)) cats.add(v.cat);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _railHeader(
            'Top rated near you',
            sub: 'Tap a card to view the vendor',
          ),
          _rail(topRated.take(6).toList()),
          for (final cat in cats) ...[
            const SizedBox(height: 20),
            _railHeader(_catTitles[cat] ?? cat),
            _rail(_vendors.where((v) => v.cat == cat).toList()),
          ],
        ],
      ),
    );
  }

  Widget _railHeader(String title, {String? sub}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: _ink9,
              letterSpacing: -0.3,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(
              sub,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: _ink4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _rail(List<_Vendor> vendors) {
    return SizedBox(
      height: 188,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: vendors.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) => SizedBox(
          width: 156,
          child: _VendorCard(
            vendor: vendors[i],
            onTap: () => _push(_Sn.detail, vendor: vendors[i]),
          ),
        ),
      ),
    );
  }

  // ── detail screen ──────────────────────────────────────────────────────────
  Widget _detailScreen() {
    final v = _cur!;
    final top = MediaQuery.of(context).padding.top;
    final savePercent = ((1 - v.price / v.oldPrice) * 100).round();

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Scrollable content
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _DetailHero(vendor: v, top: top, onBack: _pop),
              ),
              // White sheet content (rounded cap lives in the hero)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + rating
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  v.title,
                                  style: GoogleFonts.nunito(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w900,
                                    color: _ink9,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'by ${v.vendor} · ${v.cat}',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: _ink4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: _t050,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded, size: 14, color: _yd),
                                const SizedBox(width: 4),
                                Text(
                                  '${v.rating}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: _ink9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      // Chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Pill(
                            text: 'Verified vendor',
                            icon: Icons.check_circle_rounded,
                            fg: _tDp,
                            bg: _t050,
                          ),
                          _Pill(
                            text: '${v.jobs} jobs done',
                            fg: const Color(0xFF9A7400),
                            bg: _y050,
                          ),
                          _Pill(text: '⏱ ${v.eta}', fg: _ink5, bg: _chip),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Pricing
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'AED ${v.price}',
                            style: GoogleFonts.nunito(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: _ink9,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              'AED ${v.oldPrice}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _ink4,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7F6EC),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Save $savePercent%',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A8B4F),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      // About section
                      _SectionTitle('About this service'),
                      const SizedBox(height: 8),
                      Text(
                        v.desc,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: _ink7,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 22),
                      // What's included
                      _SectionTitle("What's included"),
                      const SizedBox(height: 12),
                      Column(
                        children: v.incl
                            .map(
                              (t) => Padding(
                                padding: const EdgeInsets.only(bottom: 9),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: _t050,
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: const Icon(
                                        Icons.check_rounded,
                                        size: 13,
                                        color: _tDp,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        t,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: _ink7,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 22),
                      // Location
                      _SectionTitle('Location & coverage'),
                      const SizedBox(height: 12),
                      _LocationCard(addr: v.addr),
                      const SizedBox(height: 22),
                      // Contact
                      _SectionTitle('Contact vendor'),
                      const SizedBox(height: 12),
                      _ContactSection(phone: v.phone),
                      const SizedBox(height: 22),
                      // Reviews
                      _SectionTitle('Ratings & reviews'),
                      const SizedBox(height: 12),
                      _ReviewCard(rating: v.rating),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── dark gradient header ─────────────────────────────────────────────────────
class _DarkHeader extends StatelessWidget {
  const _DarkHeader({
    required this.title,
    required this.top,
    required this.onBack,
  });

  final String title;
  final double top;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.6, -1),
          end: Alignment(-0.2, 1),
          colors: [_dark7, _dark9],
        ),
      ),
      padding: EdgeInsets.fromLTRB(18, top + 8, 18, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── detail hero ───────────────────────────────────────────────────────────────
class _DetailHero extends StatelessWidget {
  const _DetailHero({
    required this.vendor,
    required this.top,
    required this.onBack,
  });

  final _Vendor vendor;
  final double top;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: top + 240,
      child: Stack(
        children: [
          // Base gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: vendor.grad),
            ),
          ),
          // Radial glow from top-right
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.9, -1.0),
                    radius: 1.3,
                    colors: [vendor.radialGlow, const Color(0x00FFFFFF)],
                    stops: const [0.0, 0.55],
                  ),
                ),
              ),
            ),
          ),
          // Back button
          Positioned(
            top: top + 8,
            left: 18,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          // Wishlist button
          Positioned(
            top: top + 8,
            right: 18,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          // Center illustration
          Center(
            child: SvgPicture.string(_svg(vendor.ill), width: 130, height: 130),
          ),
          // Vendor name badge bottom-left
          Positioned(
            left: 20,
            bottom: 48,
            child: Text(
              vendor.vendor,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  const Shadow(
                    color: Color(0x55000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          // rounded sheet cap over the hero bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 24,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── vendor card (grid) ────────────────────────────────────────────────────────
class _VendorCard extends StatelessWidget {
  const _VendorCard({required this.vendor, required this.onTap});

  final _Vendor vendor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final v = vendor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _line),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A142818),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Cover
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: SizedBox(
                height: 100,
                child: Stack(
                  children: [
                    // Base gradient
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(gradient: v.grad),
                      ),
                    ),
                    // Radial glow from top-right
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: const Alignment(1.0, -1.0),
                              radius: 1.3,
                              colors: [v.radialGlow, const Color(0x00FFFFFF)],
                              stops: const [0.0, 0.55],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Badge
                    Positioned(
                      top: 9,
                      left: 9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: v.badgeDark ? _dark9 : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          v.badge,
                          style: GoogleFonts.nunito(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: v.badgeDark ? Colors.white : _tDp,
                          ),
                        ),
                      ),
                    ),
                    // Illustration
                    Center(
                      child: SvgPicture.string(
                        _svg(v.ill),
                        width: 56,
                        height: 56,
                      ),
                    ),
                    // Vendor name
                    Positioned(
                      left: 9,
                      bottom: 9,
                      child: Text(
                        v.vendor,
                        style: GoogleFonts.nunito(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [
                            const Shadow(
                              color: Color(0x44000000),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: _ink9,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: _ink4,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        v.eta,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _ink4,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.star_rounded, size: 13, color: _yd),
                      const SizedBox(width: 2),
                      Text(
                        '${v.rating}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _ink4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Text(
                        'AED ${v.price}',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: _ink9,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'AED ${v.oldPrice}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: _ink4,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── section title ─────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: GoogleFonts.nunito(
      fontSize: 16,
      fontWeight: FontWeight.w900,
      color: _ink9,
      letterSpacing: -0.3,
    ),
  );
}

// ── pill chip ─────────────────────────────────────────────────────────────────
class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    this.icon,
    required this.fg,
    required this.bg,
  });

  final String text;
  final IconData? icon;
  final Color fg, bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ── location card ─────────────────────────────────────────────────────────────
class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.addr});
  final String addr;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F142818),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Map placeholder
          Container(
            height: 120,
            color: const Color(0xFFE9EEEA),
            child: CustomPaint(
              size: const Size(double.infinity, 120),
              painter: _MapPainter(),
            ),
          ),
          // Address row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: Color(0xFFE2554C),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    addr,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _ink7,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── simple map painter ────────────────────────────────────────────────────────
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final W = size.width;
    final H = size.height;

    // Green patches
    canvas.drawRect(
      Rect.fromLTWH(-20, H * 0.5, W * 0.38, H * 0.7),
      Paint()..color = const Color(0xFFDCEBDD),
    );
    canvas.drawRect(
      Rect.fromLTWH(W * 0.64, -10, W * 0.46, H * 0.5),
      Paint()..color = const Color(0xFFDCEBDD),
    );

    // Road fill (white)
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(-10, H * 0.42), Offset(W + 10, H * 0.55), roadPaint);
    canvas.drawLine(Offset(W * 0.31, -10), Offset(W * 0.38, H + 10), roadPaint);
    canvas.drawLine(Offset(W * 0.64, -10), Offset(W * 0.64, H + 10), roadPaint);

    // Road edge lines
    final edgePaint = Paint()
      ..color = const Color(0xFFD7DED8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(-10, H * 0.42), Offset(W + 10, H * 0.55), edgePaint);
    canvas.drawLine(Offset(W * 0.31, -10), Offset(W * 0.38, H + 10), edgePaint);
    canvas.drawLine(Offset(W * 0.64, -10), Offset(W * 0.64, H + 10), edgePaint);

    // Pin
    final cx = W * 0.5;
    final cy = H * 0.5;
    final pinPath = Path()
      ..moveTo(cx, cy + 14)
      ..cubicTo(cx - 15, cy + 2, cx - 15, cy - 14, cx - 15, cy - 6)
      ..arcToPoint(Offset(cx + 15, cy - 6), radius: const Radius.circular(15))
      ..cubicTo(cx + 15, cy - 14, cx + 15, cy + 2, cx, cy + 14)
      ..close();
    canvas.drawPath(pinPath, Paint()..color = const Color(0xFFE2554C));
    canvas.drawCircle(Offset(cx, cy - 6), 4.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── contact section ───────────────────────────────────────────────────────────
class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.phone});
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Phone row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _line),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F142818),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.phone_rounded, size: 18, color: _tDp),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _ink9,
                  ),
                ),
              ),
              const Text(
                'Mon–Sun · 8am–9pm',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: _ink4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 11),
        // Call / WhatsApp / Email buttons
        Row(
          children: [
            _CBtn(icon: Icons.phone_rounded, label: 'Call', iconColor: _tDp),
            const SizedBox(width: 10),
            _CBtn(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'WhatsApp',
              iconColor: const Color(0xFF25D366),
            ),
            const SizedBox(width: 10),
            _CBtn(icon: Icons.email_outlined, label: 'Email', iconColor: _tDp),
          ],
        ),
      ],
    );
  }
}

class _CBtn extends StatelessWidget {
  const _CBtn({
    required this.icon,
    required this.label,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _line, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: _ink9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── review card ───────────────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F142818),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$rating',
                style: GoogleFonts.nunito(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: _ink9,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 13, color: _yd),
                      const SizedBox(width: 4),
                      const Text(
                        'Excellent',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _ink9,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '412 verified reviews',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: _ink4,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(color: _line, height: 24),
          const Text(
            '"Spotless work and very professional team. Booked again the same week." — Layla M.',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: _ink7,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
