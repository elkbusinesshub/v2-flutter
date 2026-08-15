import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/app_preferences.dart';
import '../../../core/widgets/state_views.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/models/stay_models.dart';
import '../../../data/repositories/marketplace_repository.dart';
import '../explore/cubit/elkstay_explore_cubit.dart';
import '../home/cubit/elkstay_home_cubit.dart';
import '../home/view/elkstay_home_screen.dart';
import '../favorites/cubit/stay_favorites_cubit.dart';
import '../favorites/view/stay_favorites_screen.dart';
import '../stay_detail/cubit/stay_detail_cubit.dart';

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
List<_PMD> _pmdsFor(AppLocalizations l10n) => [
  (
    id: 'upi',
    label: 'UPI',
    sub: l10n.payUpiSub,
    icon: Icons.account_balance_rounded,
  ),
  (
    id: 'card',
    label: l10n.payCard,
    sub: l10n.payCardBrandsIn,
    icon: Icons.credit_card_rounded,
  ),
  (
    id: 'wallet',
    label: l10n.payElkWallet,
    sub: 'Balance ₹1,250',
    icon: Icons.account_balance_wallet_rounded,
  ),
  (
    id: 'bank',
    label: l10n.payNetBanking,
    sub: l10n.payAllMajorBanks,
    icon: Icons.location_city_rounded,
  ),
];

// ─── Utility ─────────────────────────────────────────────────────────────────
String _fmt(int n) => n.toString().replaceAllMapped(
  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
  (m) => '${m[1]},',
);

enum _Sn { home, listings, favorites, detail, booking, checkout, payment, success }

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
  AppLocalizations get l10n => AppLocalizations.of(context);

  late final ElkStayHomeCubit _homeCubit;
  late final ElkStayExploreCubit _exploreCubit;
  late final StayDetailCubit _detailCubit;
  late final StayFavoritesCubit _favoritesCubit;

  final List<_Sn> _stack = [_Sn.home];
  _Sn get _cur => _stack.last;

  // listings
  String? _listTitle;
  String _listChip = 'all';

  // booking flow
  int _dateIndex = 0;
  int _months = 6;
  bool _coupon = false;

  // payment
  String _method = 'upi';

  int get _fee => 499;
  int get _disc => _coupon ? 500 : 0;

  /// Coupon the backend validates when [_coupon] is on (seeded: ₹500 off).
  static const _couponCode = 'ELKNEW';

  /// Move-in options: the next four fortnight-ish dates, sent as ISO
  /// calendar dates and shown in the app's "1 Jul" style.
  late final List<DateTime> _moveInDates = List.generate(4, (i) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(Duration(days: 1 + i * 5));
  });

  String _dateLabel(DateTime d) =>
      DateFormat('d MMM', l10n.localeName).format(d);

  String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  StayRoomOption? get _room => _detailCubit.state.selectedRoomOption;

  int get _total {
    final price = _room?.pricePerMonth ?? 0;
    return price + price + _fee - _disc;
  }

  @override
  void initState() {
    super.initState();
    final marketplace = context.read<MarketplaceRepository>();
    final preferences = context.read<AppPreferences>();
    _homeCubit = ElkStayHomeCubit(marketplace, preferences);
    _exploreCubit = ElkStayExploreCubit(marketplace, preferences);
    _detailCubit = StayDetailCubit(marketplace, preferences);
    _favoritesCubit = StayFavoritesCubit(marketplace, preferences);
  }

  @override
  void dispose() {
    _homeCubit.close();
    _exploreCubit.close();
    _detailCubit.close();
    _favoritesCubit.close();
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
      _listTitle = title;
      _listChip = 'all';
    });
    _exploreCubit.loadStays(filter: cat);
    _push(_Sn.listings);
  }

  void _openDetail(String stayId) {
    _detailCubit.loadDetail(stayId);
    setState(() => _dateIndex = 0);
    _push(_Sn.detail);
  }

  /// Applies a listings chip. Only the chips the listing API supports change
  /// the query — see the docs' known limitations for the rest.
  void _applyListChip(String chip) {
    setState(() => _listChip = chip);
    switch (chip) {
      case 'single':
        _exploreCubit.setRoomType('single');
      case 'double':
        _exploreCubit.setRoomType('double');
      case 'meals':
        _exploreCubit.setRoomType(null);
        _exploreCubit.toggleMeals();
      default:
        _exploreCubit.setRoomType(null);
    }
  }

  Future<void> _payNow() async {
    final messenger = ScaffoldMessenger.of(context);
    final booking = await _detailCubit.requestToBook(
      moveInDate: _isoDate(_moveInDates[_dateIndex]),
      durationMonths: _months,
      paymentMethod: _method,
      couponCode: _coupon ? _couponCode : null,
    );
    if (!mounted) return;
    if (booking != null) {
      _push(_Sn.success);
    } else {
      messenger.showSnackBar(SnackBar(
        content: Text(_detailCubit.state.actionError ?? l10n.paymentFailed),
      ));
    }
  }

  Future<void> _scheduleVisit() async {
    final messenger = ScaffoldMessenger.of(context);
    // Default visit slot: the first offered move-in date at 5 PM.
    final date = _moveInDates.first;
    final visit = await _detailCubit.scheduleVisit(
      DateTime(date.year, date.month, date.day, 17).toIso8601String(),
    );
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(
      content: Text(visit != null
          ? l10n.visitScheduledFor(_dateLabel(date))
          : _detailCubit.state.actionError ?? l10n.couldNotScheduleVisit),
    ));
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) => _pop(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _homeCubit),
          BlocProvider.value(value: _exploreCubit),
          BlocProvider.value(value: _detailCubit),
          BlocProvider.value(value: _favoritesCubit),
        ],
        // Builder is load-bearing: every screen below reads the cubits with
        // context.watch, and the State's own context sits *above* the
        // MultiBlocProvider created here. Without it the lookup throws and the
        // screen renders as a blank grey error box.
        child: Builder(
          builder: (context) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: KeyedSubtree(key: ValueKey(_cur), child: _screen(context)),
          ),
        ),
      ),
    );
  }

  Widget _screen(BuildContext context) => switch (_cur) {
    _Sn.home => _buildHome(),
    _Sn.listings => _buildListings(context),
    _Sn.favorites => StayFavoritesScreen(onBack: _pop, onStayTap: _openDetail),
    _Sn.detail => _buildDetail(context),
    _Sn.booking => _buildBooking(context),
    _Sn.checkout => _buildCheckout(context),
    _Sn.payment => _buildPayment(context),
    _Sn.success => _buildSuccess(context),
  };

  // ══════════════════════════════════════════════════════════════════════════
  //  HOME  (delegates to existing cubit-based home screen)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildHome() => Scaffold(
    backgroundColor: _bg,
    body: ElkStayHomeScreen(
      onCategoryTap: (cat) => _openListings(cat, cat?.displayName ?? l10n.allStays),
      onStayTap: (id) => _openDetail(id),
      onBack: widget.onBack,
      onSavedTap: () => _push(_Sn.favorites),
    ),
  );

  // ══════════════════════════════════════════════════════════════════════════
  //  LISTINGS
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildListings(BuildContext context) {
    final exploreState = context.watch<ElkStayExploreCubit>().state;
    final props = exploreState.stays;
    // (id, label): the id drives the query, so translating the label cannot
    // change which filter a chip applies.
    final chips = <(String, String)>[
      ('all', l10n.chipAll),
      ('single', l10n.chipSingle),
      ('double', l10n.chipDouble),
      ('ac', 'AC'),
      ('meals', l10n.chipFoodIncl),
      ('metro', l10n.chipNearMetro),
    ];

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // dark header
          _DarkHeader(title: _listTitle ?? l10n.pgStays, onBack: _pop),
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
                  final on = _listChip == chips[i].$1;
                  return GestureDetector(
                    onTap: () => _applyListChip(chips[i].$1),
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
                        chips[i].$2,
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
                                text: l10n.staysInArea,
                                style: _pj(sz: 13, w: FontWeight.w800, c: _i5),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              l10n.sortLabel,
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
  Widget _buildDetail(BuildContext context) {
    final detailState = context.watch<StayDetailCubit>().state;
    if (detailState.status == StayDetailStatus.guest) {
      return Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: SignInRequiredView(
            message: l10n.staySignInPrompt,
          ),
        ),
      );
    }
    if (detailState.status == StayDetailStatus.error) {
      return Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: ErrorRetryView(
            message: detailState.errorMessage ?? l10n.errorGeneric,
            onRetry: () {
              final id = detailState.stay?.id;
              if (id != null) _detailCubit.loadDetail(id);
            },
          ),
        ),
      );
    }
    final stay = detailState.stay;
    if (stay == null) {
      return const Scaffold(backgroundColor: _bg, body: LoadingView());
    }
    final roomOptions = detailState.roomOptions;
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
                                  Color(stay.gradientStart),
                                  Color(stay.gradientEnd),
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
                                icon: detailState.isSaved
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                iconColor: _am,
                                onTap: _detailCubit.toggleSaved,
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
                                    stay.name,
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
                                          '${stay.location} · ${stay.badge}',
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
                                    '${stay.rating}',
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
                            _Tag(label: l10n.verified, bg: _t5, tc: _td),
                            _Tag(label: l10n.foodIncluded, bg: _y5, tc: _am),
                            _Tag(label: '0.4 km from metro', bg: _ch, tc: _i5),
                          ],
                        ),
                        // choose sharing
                        const SizedBox(height: 24),
                        Text(
                          l10n.chooseSharing,
                          style: _nu(sz: 17, w: FontWeight.w900, sp: -0.3),
                        ),
                        const SizedBox(height: 12),
                        for (int i = 0; i < roomOptions.length; i++) ...[
                          _RoomTile(
                            r: roomOptions[i],
                            selected: detailState.selectedRoomOptionId == roomOptions[i].id,
                            onTap: () => _detailCubit.selectRoomOption(roomOptions[i].id),
                          ),
                          if (i < roomOptions.length - 1) const SizedBox(height: 10),
                        ],
                        // amenities
                        const SizedBox(height: 24),
                        Text(
                          l10n.amenities,
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
                          children: stay.amenities.map((a) {
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
                          l10n.ratingsReviews,
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
                                    '${stay.rating}',
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
                                            color: i < stay.rating.floor()
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
                                l10n.sampleStayReview,
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
                    Text(l10n.startingFrom, style: _pj(sz: 11.5, c: _i4)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '₹${_fmt(detailState.selectedRoomOption?.pricePerMonth ?? stay.pricePerMonth)}',
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
                const SizedBox(width: 12),
                // Books a property visit (backend POST /elkstay/visits) —
                // shows up under the Requests tab of My Stays.
                OutlinedButton(
                  onPressed: detailState.isSubmitting ? null : _scheduleVisit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _td,
                    side: const BorderSide(color: _ln, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                  child: Text(l10n.visit, style: _nu(sz: 14, w: FontWeight.w900, c: _td)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _CtaBtn(
                    label: l10n.reserve,
                    icon: Icons.arrow_forward_rounded,
                    onTap: detailState.roomOptions.isEmpty
                        ? null
                        : () => _push(_Sn.booking),
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
  Widget _buildBooking(BuildContext context) {
    final detailState = context.watch<StayDetailCubit>().state;
    final stay = detailState.stay!;
    final room = detailState.selectedRoomOption!;
    final roomOptions = detailState.roomOptions;
    return Scaffold(
      backgroundColor: _bg,
    body: Column(
      children: [
        _DarkHeader(title: l10n.bookYourStay, onBack: _pop),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              _PropSummaryCard(prop: stay, room: room),
              const SizedBox(height: 22),
              Text(
                l10n.roomType,
                style: _nu(sz: 16, w: FontWeight.w900, sp: -0.3),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: roomOptions.map((r) {
                  final on = r.id == detailState.selectedRoomOptionId;
                  return _SelectChip(
                    label: r.kind.split(' ').first,
                    on: on,
                    onTap: () => _detailCubit.selectRoomOption(r.id),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.moveInDate,
                style: _pj(sz: 12, w: FontWeight.w800, c: _i5, sp: 0.2),
              ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: [
                  for (int i = 0; i < _moveInDates.length; i++)
                    _SelectChip(
                      label: _dateLabel(_moveInDates[i]),
                      on: _dateIndex == i,
                      onTap: () => setState(() => _dateIndex = i),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                l10n.durationCaps,
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
              _FieldRow(label: l10n.fullName, hint: 'Aarav Sharma'),
              const SizedBox(height: 14),
              _FieldRow(
                label: l10n.phoneNumber,
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
                  Text(room.kind, style: _pj(sz: 11.5, c: _i4)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹${_fmt(room.pricePerMonth)}',
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
                  label: l10n.commonContinue,
                  onTap: () => _push(_Sn.checkout),
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
  //  CHECKOUT
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildCheckout(BuildContext context) {
    final detailState = context.watch<StayDetailCubit>().state;
    final stay = detailState.stay!;
    final room = detailState.selectedRoomOption!;
    final rent = room.pricePerMonth;
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _DarkHeader(title: l10n.reviewAndPay, onBack: _pop),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                _PropSummaryCard(
                  prop: stay,
                  room: room,
                  subtitle:
                      '${room.kind} · Move-in ${_dateLabel(_moveInDates[_dateIndex])} · $_months months',
                ),
                const SizedBox(height: 22),
                Text(
                  l10n.paymentSummary,
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
                      _PriceLine(k: l10n.firstMonthRent, v: '₹${_fmt(rent)}'),
                      _PriceLine(
                        k: l10n.securityDeposit,
                        kSub: l10n.refundableAtMoveOut,
                        v: '₹${_fmt(rent)}',
                      ),
                      _PriceLine(k: l10n.elkServiceFee, v: '₹${_fmt(_fee)}'),
                      if (_coupon)
                        _PriceLine(
                          k: l10n.couponElknew,
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
                            l10n.payableNow,
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
                                  text: l10n.applyPrefix,
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
                                  text: l10n.saveFiveHundred,
                                  style: _pj(sz: 13, c: _td),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          _coupon ? l10n.appliedCaps : l10n.applyCaps,
                          style: _pj(sz: 12.5, w: FontWeight.w900, c: _td),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.stayPolicyNote,
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
                    Text(l10n.payableNow, style: _pj(sz: 11.5, c: _i4)),
                    Text(
                      '₹${_fmt(_total)}',
                      style: _nu(sz: 22, w: FontWeight.w900, sp: -0.5),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _CtaBtn(
                    label: l10n.proceedToPay,
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
  Widget _buildPayment(BuildContext context) {
    final detailState = context.watch<StayDetailCubit>().state;
    return Scaffold(
      backgroundColor: _bg,
    body: Stack(
      children: [
        Column(
          children: [
            _DarkHeader(title: l10n.sectionPayment, onBack: _pop),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  // amount hero
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        Text(l10n.amountPayable, style: _pj(sz: 12.5, c: _i4)),
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
                    l10n.payUsing,
                    style: _nu(sz: 16, w: FontWeight.w900, sp: -0.3),
                  ),
                  const SizedBox(height: 12),
                  for (final pm in _pmdsFor(l10n)) ...[
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
                          label: l10n.upiId,
                          initial: 'aarav@okhdfcbank',
                        ),
                      ],
                    ),
                  if (_method == 'card')
                    _InlineFormBox(
                      children: [
                        _FormField(
                          label: l10n.cardNumber,
                          initial: '4111 1111 1111 1111',
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _FormField(
                                label: l10n.cardExpiry,
                                initial: '08/28',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _FormField(label: l10n.cardCvv, initial: '123'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _FormField(
                          label: l10n.nameOnCard,
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
        if (detailState.isSubmitting)
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
                      l10n.processingPayment,
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
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SUCCESS
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSuccess(BuildContext context) {
    final detailState = context.watch<StayDetailCubit>().state;
    final stay = detailState.stay!;
    final room = detailState.selectedRoomOption!;
    final bookingCode = detailState.lastBooking?.code ?? '';
    return Scaffold(
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
                l10n.bookingConfirmedBang,
                style: _nu(sz: 25, w: FontWeight.w900, sp: -0.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your stay at ${stay.name} is reserved. The host will reach out shortly with check-in details.',
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
                    _TicketRow(k: l10n.property, v: stay.name),
                    _TicketRow(k: l10n.room, v: room.kind),
                    _TicketRow(k: l10n.moveIn, v: '${_dateLabel(_moveInDates[_dateIndex])} · ${l10n.monthsCount(_months)}'),
                    _TicketRow(k: l10n.paidLabel, v: '₹${_fmt(_total)}'),
                    _TicketRow(k: l10n.bookingId, v: bookingCode),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _CtaBtn(
                label: l10n.backToHome,
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
  final StayRoomOption r;
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
                    r.subtitle,
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
              '₹${_fmt(r.pricePerMonth)}',
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
  final StayRoomOption room;
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

  /// Null disables the button (e.g. a stay with no bookable rooms).
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
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
