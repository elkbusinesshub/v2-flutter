import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/datasources/elkstay_dummy_data.dart';
import '../../../data/models/stay_models.dart';
import '../../../data/repositories/elkstay_repository.dart';
import '../home/cubit/elkstay_home_cubit.dart';
import '../home/view/elkstay_home_screen.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _d9 = Color(0xFF0C241D);
const _d7 = Color(0xFF1A4A3C);
const _tl = Color(0xFF18927F);
const _td = Color(0xFF0F6E60);
const _t5 = Color(0xFFE7F6F2);
const _yd = Color(0xFFE6B500);
const _y5 = Color(0xFFFEF6D8);
const _am = Color(0xFFE08A1E);
const _i9 = Color(0xFF16271F);
const _i7 = Color(0xFF2A3B31);
const _i5 = Color(0xFF5E6E64);
const _i4 = Color(0xFF8C9890);
const _bg = Color(0xFFF1F4EE);
const _ln = Color(0xFFE6EBE5);
const _ch = Color(0xFFEFF2EC);

TextStyle _pj({
  double sz = 14,
  FontWeight w = FontWeight.w600,
  Color c = _i9,
  double sp = 0,
  double h = 1.4,
}) => GoogleFonts.plusJakartaSans(
  fontSize: sz,
  fontWeight: w,
  color: c,
  letterSpacing: sp,
  height: h,
);

TextStyle _nu({
  double sz = 14,
  FontWeight w = FontWeight.w700,
  Color c = _i9,
  double sp = 0,
}) => GoogleFonts.nunito(
  fontSize: sz,
  fontWeight: w,
  color: c,
  letterSpacing: sp,
);

// ─── Room definitions ────────────────────────────────────────────────────────
typedef _RD = ({String kind, String sub, int price});
const List<_RD> _rds = [
  (kind: 'Single Sharing', sub: 'Private room · attached bath', price: 15000),
  (kind: 'Double Sharing', sub: '2 beds · shared bath', price: 11000),
  (kind: 'Triple Sharing', sub: '3 beds · economical', price: 8500),
];

const _dates = ['1 Jul', '5 Jul', '10 Jul', '15 Jul'];
const _durs = [3, 6, 11];

const _amenIcons = <String, IconData>{
  'wifi': Icons.wifi_rounded,
  'meals': Icons.restaurant_rounded,
  'laundry': Icons.local_laundry_service_rounded,
  'ac': Icons.ac_unit_rounded,
  'security': Icons.shield_rounded,
  'parking': Icons.local_parking_rounded,
  'backup': Icons.battery_charging_full_rounded,
};

// ─── Payment methods ─────────────────────────────────────────────────────────
typedef _PMD = ({String id, String label, String sub, IconData icon});
const List<_PMD> _pmds = [
  (
    id: 'upi',
    label: 'UPI',
    sub: 'GPay, PhonePe, Paytm & more',
    icon: Icons.account_balance_rounded,
  ),
  (
    id: 'card',
    label: 'Credit / Debit Card',
    sub: 'Visa, Mastercard, Rupay',
    icon: Icons.credit_card_rounded,
  ),
  (
    id: 'wallet',
    label: 'ELK Wallet',
    sub: 'Balance ₹1,250',
    icon: Icons.account_balance_wallet_rounded,
  ),
  (
    id: 'bank',
    label: 'Net Banking',
    sub: 'All major banks',
    icon: Icons.location_city_rounded,
  ),
];

// ─── Utility ─────────────────────────────────────────────────────────────────
String _fmt(int n) => n.toString().replaceAllMapped(
  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
  (m) => '${m[1]},',
);

enum _Sn { home, listings, detail, booking, checkout, payment, success }

// ═════════════════════════════════════════════════════════════════════════════
//  Shell
// ═════════════════════════════════════════════════════════════════════════════
class ElkStayShell extends StatefulWidget {
  const ElkStayShell({
    super.key,
    required this.onStayTap,
    required this.onBack,
  });
  final ValueChanged<String> onStayTap;
  final VoidCallback onBack;

  @override
  State<ElkStayShell> createState() => _ElkStayShellState();
}

class _ElkStayShellState extends State<ElkStayShell> {
  late final ElkStayHomeCubit _homeCubit;
  late final List<StayModel> _allProps;

  final List<_Sn> _stack = [_Sn.home];
  _Sn get _cur => _stack.last;

  // listings
  String _listTitle = 'PG Stays';
  String _listChip = 'All';
  StayCategoryType? _listCat;

  // selected property
  late StayModel _prop;

  // booking flow
  _RD _room = _rds[1];
  String _movein = '1 Jul';
  int _months = 6;
  bool _coupon = false;

  // payment
  String _method = 'upi';
  bool _paying = false;

  // success
  String _bookingId = '';

  int get _fee => 499;
  int get _disc => _coupon ? 500 : 0;
  int get _total => _room.price + _room.price + _fee - _disc;

  @override
  void initState() {
    super.initState();
    _homeCubit = ElkStayHomeCubit(context.read<ElkStayRepository>());
    _allProps = elkStayStaysJson
        .map((j) => StayModel.fromJson(Map<String, dynamic>.from(j)))
        .toList();
    _prop = _allProps.first;
  }

  @override
  void dispose() {
    _homeCubit.close();
    super.dispose();
  }

  void _push(_Sn s) => setState(() => _stack.add(s));

  void _pop() {
    if (_stack.length > 1) {
      setState(() => _stack.removeLast());
    } else {
      widget.onBack();
    }
  }

  void _openListings(StayCategoryType? cat, String title) {
    setState(() {
      _listCat = cat;
      _listTitle = title;
      _listChip = 'All';
    });
    _push(_Sn.listings);
  }

  void _openDetail(String stayId) {
    final match =
        _allProps.where((p) => p.id == stayId).firstOrNull ?? _allProps.first;
    setState(() {
      _prop = match;
      _room = _rds[1];
    });
    _push(_Sn.detail);
  }

  List<StayModel> get _filtered => _listCat == null
      ? _allProps
      : _allProps.where((p) => p.categoryType == _listCat).toList();

  void _payNow() {
    setState(() => _paying = true);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      final rng = math.Random();
      _bookingId =
          'ELK-${List.generate(5, (_) => chars[rng.nextInt(chars.length)]).join()}';
      setState(() {
        _paying = false;
        _stack.add(_Sn.success);
      });
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) => _pop(),
      child: BlocProvider.value(
        value: _homeCubit,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: KeyedSubtree(key: ValueKey(_cur), child: _screen()),
        ),
      ),
    );
  }

  Widget _screen() => switch (_cur) {
    _Sn.home => _buildHome(),
    _Sn.listings => _buildListings(),
    _Sn.detail => _buildDetail(),
    _Sn.booking => _buildBooking(),
    _Sn.checkout => _buildCheckout(),
    _Sn.payment => _buildPayment(),
    _Sn.success => _buildSuccess(),
  };

  // ══════════════════════════════════════════════════════════════════════════
  //  HOME  (delegates to existing cubit-based home screen)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildHome() => Scaffold(
    backgroundColor: _bg,
    body: ElkStayHomeScreen(
      onCategoryTap: (cat) => _openListings(cat, cat.displayName),
      onStayTap: (id) => _openDetail(id),
      onBack: widget.onBack,
    ),
  );

  // ══════════════════════════════════════════════════════════════════════════
  //  LISTINGS
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildListings() {
    final props = _filtered;
    const chips = ['All', 'Single', 'Double', 'AC', 'Food incl.', 'Near metro'];

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // dark header
          _DarkHeader(title: _listTitle, onBack: _pop),
          // filter chips bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(0, 14, 0, 12),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                separatorBuilder: (_, _) => const SizedBox(width: 9),
                itemCount: chips.length,
                itemBuilder: (_, i) {
                  final on = _listChip == chips[i];
                  return GestureDetector(
                    onTap: () => setState(() => _listChip = chips[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: on ? _tl : _ch,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: on
                            ? [
                                BoxShadow(
                                  color: _td.withValues(alpha: 0.3),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        chips[i],
                        style: _nu(
                          sz: 13,
                          w: FontWeight.w800,
                          c: on ? Colors.white : _i7,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
              itemCount: props.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${props.length} ',
                                style: _pj(sz: 13, w: FontWeight.w800),
                              ),
                              TextSpan(
                                text: 'stays in Koramangala',
                                style: _pj(sz: 13, w: FontWeight.w800, c: _i5),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              'Sort ',
                              style: _pj(sz: 13, w: FontWeight.w800, c: _td),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: _td,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                return _ListingCard(
                  prop: props[i - 1],
                  onTap: () => _openDetail(props[i - 1].id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  DETAIL
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildDetail() {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // ── hero image
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 210,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(_prop.gradientStart),
                                  Color(_prop.gradientEnd),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.apartment_rounded,
                                size: 90,
                                color: Colors.white.withValues(alpha: 0.28),
                              ),
                            ),
                          ),
                        ),
                        // back + heart buttons
                        Positioned(
                          top: top + 10,
                          left: 14,
                          right: 14,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _RoundBtn(
                                icon: Icons.arrow_back_rounded,
                                onTap: _pop,
                              ),
                              _RoundBtn(
                                icon: Icons.favorite_border_rounded,
                                iconColor: _am,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                        // dots — sit above the rounded sheet cap
                        Positioned(
                          bottom: 34,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 0; i < 3; i++)
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  width: i == 0 ? 16 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: i == 0
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.45),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // rounded sheet cap over the hero bottom
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: 22,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: _bg,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ── content sheet
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // title row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _prop.name,
                                    style: _nu(
                                      sz: 21,
                                      w: FontWeight.w900,
                                      sp: -0.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_rounded,
                                        size: 14,
                                        color: _i4,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${_prop.location} · ${_prop.badge}',
                                          style: _pj(sz: 13, c: _i4),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: _t5,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: _yd,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_prop.rating}',
                                    style: _pj(sz: 13, w: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // quick tags
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _Tag(label: 'Verified', bg: _t5, tc: _td),
                            _Tag(label: 'Food included', bg: _y5, tc: _am),
                            _Tag(label: '0.4 km from metro', bg: _ch, tc: _i5),
                          ],
                        ),
                        // choose sharing
                        const SizedBox(height: 24),
                        Text(
                          'Choose sharing',
                          style: _nu(sz: 17, w: FontWeight.w900, sp: -0.3),
                        ),
                        const SizedBox(height: 12),
                        for (int i = 0; i < _rds.length; i++) ...[
                          _RoomTile(
                            r: _rds[i],
                            selected: _room.kind == _rds[i].kind,
                            onTap: () => setState(() => _room = _rds[i]),
                          ),
                          if (i < _rds.length - 1) const SizedBox(height: 10),
                        ],
                        // amenities
                        const SizedBox(height: 24),
                        Text(
                          'Amenities',
                          style: _nu(sz: 17, w: FontWeight.w900, sp: -0.3),
                        ),
                        const SizedBox(height: 14),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 2.9,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 10,
                          children: _prop.amenities.map((a) {
                            final ico =
                                _amenIcons[a.iconKey] ?? Icons.check_rounded;
                            return Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: _t5,
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: Icon(ico, size: 18, color: _td),
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: Text(
                                    a.label,
                                    style: _pj(
                                      sz: 13,
                                      w: FontWeight.w700,
                                      c: _i7,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        // ratings
                        const SizedBox(height: 24),
                        Text(
                          'Ratings & reviews',
                          style: _nu(sz: 17, w: FontWeight.w900, sp: -0.3),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _ln),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A143228),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_prop.rating}',
                                    style: _nu(
                                      sz: 26,
                                      w: FontWeight.w900,
                                      sp: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: List.generate(
                                          5,
                                          (i) => Icon(
                                            Icons.star_rounded,
                                            size: 13,
                                            color: i < _prop.rating.floor()
                                                ? _yd
                                                : _i4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '218 verified reviews',
                                        style: _pj(sz: 11.5, c: _i4),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Divider(color: _ln, height: 1),
                              const SizedBox(height: 12),
                              Text(
                                '"Clean rooms, great food and very safe. The warden is helpful and the location is perfect for commuting." — Priya S.',
                                style: _pj(sz: 12.5, c: _i7, h: 1.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── footer
          Container(
            padding: EdgeInsets.fromLTRB(
              18,
              12,
              18,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: _ln)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x12102818),
                  blurRadius: 18,
                  offset: Offset(0, -6),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Starting from', style: _pj(sz: 11.5, c: _i4)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '₹${_fmt(_room.price)}',
                          style: _nu(sz: 22, w: FontWeight.w900, sp: -0.5),
                        ),
                        Text(
                          '/mo',
                          style: _pj(sz: 12, c: _i4, w: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _CtaBtn(
                    label: 'Reserve',
                    icon: Icons.arrow_forward_rounded,
                    onTap: () => _push(_Sn.booking),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BOOKING
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildBooking() => Scaffold(
    backgroundColor: _bg,
    body: Column(
      children: [
        _DarkHeader(title: 'Book your stay', onBack: _pop),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              _PropSummaryCard(prop: _prop, room: _room),
              const SizedBox(height: 22),
              Text(
                'Room type',
                style: _nu(sz: 16, w: FontWeight.w900, sp: -0.3),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: _rds.map((r) {
                  final on = _room.kind == r.kind;
                  return _SelectChip(
                    label: r.kind.split(' ').first,
                    on: on,
                    onTap: () => setState(() => _room = r),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              Text(
                'MOVE-IN DATE',
                style: _pj(sz: 12, w: FontWeight.w800, c: _i5, sp: 0.2),
              ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: _dates.map((d) {
                  final on = _movein == d;
                  return _SelectChip(
                    label: d,
                    on: on,
                    onTap: () => setState(() => _movein = d),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              Text(
                'DURATION',
                style: _pj(sz: 12, w: FontWeight.w800, c: _i5, sp: 0.2),
              ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: _durs.map((m) {
                  final on = _months == m;
                  return _SelectChip(
                    label: '$m months',
                    on: on,
                    onTap: () => setState(() => _months = m),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              _FieldRow(label: 'FULL NAME', hint: 'Aarav Sharma'),
              const SizedBox(height: 14),
              _FieldRow(
                label: 'PHONE NUMBER',
                hint: '+91 98765 43210',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(
            18,
            12,
            18,
            MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: _ln)),
            boxShadow: [
              BoxShadow(
                color: Color(0x12102818),
                blurRadius: 18,
                offset: Offset(0, -6),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_room.kind, style: _pj(sz: 11.5, c: _i4)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹${_fmt(_room.price)}',
                        style: _nu(sz: 22, w: FontWeight.w900, sp: -0.5),
                      ),
                      Text(
                        '/mo',
                        style: _pj(sz: 12, c: _i4, w: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _CtaBtn(
                  label: 'Continue',
                  onTap: () => _push(_Sn.checkout),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ══════════════════════════════════════════════════════════════════════════
  //  CHECKOUT
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildCheckout() {
    final rent = _room.price;
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _DarkHeader(title: 'Review & pay', onBack: _pop),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                _PropSummaryCard(
                  prop: _prop,
                  room: _room,
                  subtitle:
                      '${_room.kind} · Move-in $_movein · $_months months',
                ),
                const SizedBox(height: 22),
                Text(
                  'Payment summary',
                  style: _nu(sz: 16, w: FontWeight.w900, sp: -0.3),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _ln),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A143228),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _PriceLine(k: 'First month rent', v: '₹${_fmt(rent)}'),
                      _PriceLine(
                        k: 'Security deposit',
                        kSub: 'Refundable at move-out',
                        v: '₹${_fmt(rent)}',
                      ),
                      _PriceLine(k: 'ELK service fee', v: '₹${_fmt(_fee)}'),
                      if (_coupon)
                        _PriceLine(
                          k: 'Coupon ELKNEW',
                          v: '-₹${_fmt(_disc)}',
                          isDisc: true,
                        ),
                      const SizedBox(height: 6),
                      Divider(color: _ln, height: 1),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payable now',
                            style: _nu(sz: 16, w: FontWeight.w900),
                          ),
                          Text(
                            '₹${_fmt(_total)}',
                            style: _nu(sz: 20, w: FontWeight.w900),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 13),
                // coupon
                GestureDetector(
                  onTap: () => setState(() => _coupon = !_coupon),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _coupon ? const Color(0xFFEAF7EE) : _t5,
                      border: Border.all(color: _tl),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_offer_outlined, size: 18, color: _td),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Apply ',
                                  style: _pj(
                                    sz: 13,
                                    w: FontWeight.w800,
                                    c: _td,
                                  ),
                                ),
                                TextSpan(
                                  text: 'ELKNEW',
                                  style: _pj(
                                    sz: 13,
                                    w: FontWeight.w900,
                                    c: _td,
                                  ),
                                ),
                                TextSpan(
                                  text: ' — save ₹500',
                                  style: _pj(sz: 13, c: _td),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          _coupon ? 'APPLIED' : 'APPLY',
                          style: _pj(sz: 12.5, w: FontWeight.w900, c: _td),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "By continuing you agree to ELK's stay policy and cancellation terms. "
                  "Deposit is fully refundable subject to inspection.",
                  style: _pj(sz: 11.5, c: _i4, h: 1.5),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              18,
              12,
              18,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: _ln)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x12102818),
                  blurRadius: 18,
                  offset: Offset(0, -6),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Payable now', style: _pj(sz: 11.5, c: _i4)),
                    Text(
                      '₹${_fmt(_total)}',
                      style: _nu(sz: 22, w: FontWeight.w900, sp: -0.5),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _CtaBtn(
                    label: 'Proceed to pay',
                    onTap: () => _push(_Sn.payment),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  PAYMENT
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPayment() => Scaffold(
    backgroundColor: _bg,
    body: Stack(
      children: [
        Column(
          children: [
            _DarkHeader(title: 'Payment', onBack: _pop),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  // amount hero
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        Text('Amount payable', style: _pj(sz: 12.5, c: _i4)),
                        const SizedBox(height: 2),
                        Text(
                          '₹${_fmt(_total)}',
                          style: _nu(sz: 34, w: FontWeight.w900, sp: -1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Pay using',
                    style: _nu(sz: 16, w: FontWeight.w900, sp: -0.3),
                  ),
                  const SizedBox(height: 12),
                  for (final pm in _pmds) ...[
                    _PayMethodTile(
                      pm: pm,
                      selected: _method == pm.id,
                      onTap: () => setState(() => _method = pm.id),
                    ),
                    const SizedBox(height: 11),
                  ],
                  // inline form
                  if (_method == 'upi')
                    _InlineFormBox(
                      children: [
                        _FormField(
                          label: 'UPI ID',
                          initial: 'aarav@okhdfcbank',
                        ),
                      ],
                    ),
                  if (_method == 'card')
                    _InlineFormBox(
                      children: [
                        _FormField(
                          label: 'CARD NUMBER',
                          initial: '4111 1111 1111 1111',
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _FormField(
                                label: 'EXPIRY',
                                initial: '08/28',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _FormField(label: 'CVV', initial: '123'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _FormField(
                          label: 'NAME ON CARD',
                          initial: 'Aarav Sharma',
                        ),
                      ],
                    ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_rounded, size: 14, color: _tl),
                      const SizedBox(width: 6),
                      Text(
                        '256-bit encrypted · Secured by ELK Pay',
                        style: _pj(sz: 11.5, c: _i4, w: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                18,
                12,
                18,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: _ln)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x12102818),
                    blurRadius: 18,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: _CtaBtn(label: 'Pay ₹${_fmt(_total)}', onTap: _payNow),
            ),
          ],
        ),
        // processing overlay
        if (_paying)
          Container(
            color: Colors.black.withValues(alpha: 0.48),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 26,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x30103020),
                      blurRadius: 48,
                      offset: Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 38,
                      height: 38,
                      child: CircularProgressIndicator(
                        color: _tl,
                        strokeWidth: 4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Processing payment…',
                      style: _pj(sz: 13.5, w: FontWeight.w800, c: _i7),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );

  // ══════════════════════════════════════════════════════════════════════════
  //  SUCCESS
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSuccess() => Scaffold(
    backgroundColor: _bg,
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ring
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.4, end: 1.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                builder: (_, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: const BoxDecoration(
                    color: _t5,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, size: 54, color: _tl),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Booking confirmed!',
                style: _nu(sz: 25, w: FontWeight.w900, sp: -0.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your stay at ${_prop.name} is reserved. The host will reach out shortly with check-in details.',
                style: _pj(sz: 13.5, c: _i5, h: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              // ticket
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _ln),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A143228),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _TicketRow(k: 'Property', v: _prop.name),
                    _TicketRow(k: 'Room', v: _room.kind),
                    _TicketRow(k: 'Move-in', v: '$_movein · $_months months'),
                    _TicketRow(k: 'Paid', v: '₹${_fmt(_total)}'),
                    _TicketRow(k: 'Booking ID', v: _bookingId),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _CtaBtn(
                label: 'Back to home',
                onTap: () => setState(() {
                  _stack.clear();
                  _stack.add(_Sn.home);
                  _coupon = false;
                }),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
//  Shared sub-widgets
// ═════════════════════════════════════════════════════════════════════════════

class _DarkHeader extends StatelessWidget {
  const _DarkHeader({required this.title, required this.onBack});
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.5, -1),
            end: Alignment(0.8, 1),
            colors: [_d7, _d9],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.9, -1.0),
                      radius: 1.3,
                      colors: [
                        _td.withValues(alpha: 0.75),
                        const Color(0x000F6E60),
                      ],
                      stops: const [0.0, 0.55],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14, top + 4, 18, 16),
              child: Row(
                children: [
                  _RoundBtn(icon: Icons.arrow_back_rounded, onTap: onBack),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.nunito(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SvgPicture.asset('assets/icons/elk_logo.svg', height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.icon, this.iconColor, required this.onTap});
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, size: 20, color: iconColor ?? Colors.white),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.bg, required this.tc});
  final String label;
  final Color bg, tc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: tc,
        ),
      ),
    );
  }
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({
    required this.r,
    required this.selected,
    required this.onTap,
  });
  final _RD r;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0F9F6) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _tl : _ln,
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.kind,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: _i9,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    r.sub,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: _i4,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '₹${_fmt(r.price)}',
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: _i9,
              ),
            ),
            Text(
              '/mo',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _i4,
              ),
            ),
            const SizedBox(width: 12),
            // radio dot
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? _tl : const Color(0xFFCFD8D2),
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: _tl,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectChip extends StatelessWidget {
  const _SelectChip({
    required this.label,
    required this.on,
    required this.onTap,
  });
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: on ? _t5 : Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: on ? _tl : _ln, width: on ? 1.5 : 1.5),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: on ? _td : _i7,
          ),
        ),
      ),
    );
  }
}

class _PropSummaryCard extends StatelessWidget {
  const _PropSummaryCard({
    required this.prop,
    required this.room,
    this.subtitle,
  });
  final StayModel prop;
  final _RD room;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final sub = subtitle ?? '${prop.badge} · ${prop.location}';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ln),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08143228),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // mini thumbnail
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(prop.gradientStart), Color(prop.gradientEnd)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.apartment_rounded,
              size: 28,
              color: Colors.white54,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prop.name,
                  style: GoogleFonts.nunito(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    color: _i9,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _i4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 12, color: _yd),
                    const SizedBox(width: 3),
                    Text(
                      '${prop.rating}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _i9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.prop, required this.onTap});
  final StayModel prop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _ln),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A143228),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // thumbnail
            Stack(
              children: [
                Container(
                  width: 104,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(prop.gradientStart),
                        Color(prop.gradientEnd),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.apartment_rounded,
                    size: 44,
                    color: Colors.white38,
                  ),
                ),
                Positioned(
                  top: 7,
                  left: 7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _d9,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      prop.badge,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prop.name,
                    style: GoogleFonts.nunito(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                      color: _i9,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 11,
                        color: _i4,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        prop.location,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: _i4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  // 3 amenity icons
                  Row(
                    children: [
                      for (final ico in [
                        Icons.wifi_rounded,
                        Icons.bed_rounded,
                        Icons.shield_rounded,
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(ico, size: 15, color: _td),
                        ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '₹${_fmt(prop.pricePerMonth)}',
                            style: GoogleFonts.nunito(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: _i9,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            '/mo',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: _i4,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 13, color: _yd),
                          const SizedBox(width: 3),
                          Text(
                            '${prop.rating}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: _i9,
                            ),
                          ),
                        ],
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

class _PriceLine extends StatelessWidget {
  const _PriceLine({
    required this.k,
    required this.v,
    this.kSub,
    this.isDisc = false,
  });
  final String k, v;
  final String? kSub;
  final bool isDisc;

  @override
  Widget build(BuildContext context) {
    final tc = isDisc ? _td : _i9;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  k,
                  style: _pj(
                    sz: 13.5,
                    c: isDisc ? _td : _i5,
                    w: FontWeight.w600,
                  ),
                ),
                if (kSub != null) ...[
                  const SizedBox(height: 1),
                  Text(kSub!, style: _pj(sz: 11, c: _i4)),
                ],
              ],
            ),
          ),
          Text(
            v,
            style: _nu(sz: 13.5, w: FontWeight.w800, c: tc),
          ),
        ],
      ),
    );
  }
}

class _PayMethodTile extends StatelessWidget {
  const _PayMethodTile({
    required this.pm,
    required this.selected,
    required this.onTap,
  });
  final _PMD pm;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0F9F6) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _tl : _ln,
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _t5,
                borderRadius: BorderRadius.circular(12),
              ),
              child: pm.id == 'upi'
                  ? Center(
                      child: Text(
                        'UPI',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: _td,
                        ),
                      ),
                    )
                  : Icon(pm.icon, size: 20, color: _td),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pm.label, style: _nu(sz: 15, w: FontWeight.w900)),
                  const SizedBox(height: 1),
                  Text(pm.sub, style: _pj(sz: 11.5, c: _i4)),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? _tl : const Color(0xFFCFD8D2),
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: _tl,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineFormBox extends StatelessWidget {
  const _InlineFormBox({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ln),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08143228),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({required this.label, required this.initial});
  final String label, initial;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _pj(sz: 12, w: FontWeight.w800, c: _i5, sp: 0.2),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: TextEditingController(text: initial),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _ln),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _ln),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _tl),
            ),
          ),
          style: _pj(sz: 14.5, w: FontWeight.w600),
        ),
      ],
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.label, required this.hint, this.keyboardType});
  final String label, hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _pj(sz: 12, w: FontWeight.w800, c: _i5, sp: 0.2),
        ),
        const SizedBox(height: 7),
        TextField(
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: _pj(sz: 14.5, c: _i4),
            isDense: true,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _ln),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _ln),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _tl),
            ),
            fillColor: Colors.white,
            filled: true,
          ),
          style: _pj(sz: 14.5, w: FontWeight.w600),
        ),
      ],
    );
  }
}

class _CtaBtn extends StatelessWidget {
  const _CtaBtn({required this.label, required this.onTap, this.icon});
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_tl, _td]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x330F6E60),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 16, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({required this.k, required this.v});
  final String k, v;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: _pj(sz: 13, c: _i4)),
          Flexible(
            child: Text(
              v,
              style: _pj(sz: 13, w: FontWeight.w800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
