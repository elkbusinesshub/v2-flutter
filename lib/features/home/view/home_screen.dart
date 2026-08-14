import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/location_picker_sheet.dart';
import '../../../core/widgets/state_views.dart';
import '../../../data/models/ad_models.dart';
import '../../../data/models/home_models.dart';
import '../../../data/models/provider_models.dart';
import '../../../data/models/service_models.dart';
import '../../../l10n/app_localizations.dart';
import '../cubit/home_cubit.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _t7  = Color(0xFF137A6D);
const _t6  = Color(0xFF18927F);
const _t5  = Color(0xFF21A892);
const _y   = Color(0xFFF6CE19);
const _i9  = Color(0xFF15241F);
const _i7  = Color(0xFF27382F);
const _i5  = Color(0xFF5E6E66);
const _i4  = Color(0xFF8C9890);
const _crm = Color(0xFFF4F1E7);
const _ln  = Color(0xFFECEFEA);

// Icon asset map (category id → asset path)
const _icons = <String, String>{
  'taxi':      'assets/taxi/auto.png',
  'elkstay':   'assets/stay/elk stay.png',
  'cleaning':  'assets/cleaning/home cleaning.png',
  'car_rental':'assets/car rental/car rental main icon.png',
  'repair':    'assets/repair/repair main icon.png',
  'porter':    'assets/porter/truck.png',
};

// Font helpers
TextStyle _pj({double? size, FontWeight? weight, Color? color, double? height, double? spacing}) =>
    GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: weight, color: color, height: height, letterSpacing: spacing);

TextStyle _nu({double? size, FontWeight? weight, Color? color, double? height, double? spacing}) =>
    GoogleFonts.nunito(fontSize: size, fontWeight: weight, color: color, height: height, letterSpacing: spacing);

// ─── HomeScreen ───────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onPartnerTap,
    this.onSearchTap,
    this.onNotificationsTap,
    this.onCategoryTap,
    this.onSeeAllServices,
    this.onSeeAllBestSellers,
    this.onProviderTap,
    this.onPromoTap,
  });

  final VoidCallback? onPartnerTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationsTap;
  final ValueChanged<ServiceCategoryModel>? onCategoryTap;
  final VoidCallback? onSeeAllServices;
  final VoidCallback? onSeeAllBestSellers;
  final ValueChanged<ProviderModel>? onProviderTap;
  final VoidCallback? onPromoTap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _promoCtrl = PageController(viewportFraction: 0.88);
  int _promoDot = 0;
  PickedLocation? _pickedLocation;

  Future<void> _chooseLocation() async {
    final picked = await showLocationPicker(context, selectedId: _pickedLocation?.id);
    if (picked != null) setState(() => _pickedLocation = picked);
  }

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadHome();
    _promoCtrl.addListener(() {
      final p = (_promoCtrl.page ?? 0).round();
      if (p != _promoDot) setState(() => _promoDot = p);
    });
  }

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.status == HomeStatus.loading || state.status == HomeStatus.initial) {
            return const LoadingView();
          }
          if (state.status == HomeStatus.error || state.feed == null) {
            return ErrorRetryView(
              message: state.errorMessage ??
                  AppLocalizations.of(context).errorGeneric,
              onRetry: () => context.read<HomeCubit>().loadHome(),
            );
          }
          final feed = state.feed!;
          final l10n = AppLocalizations.of(context);
          final top = MediaQuery.of(context).padding.top;

          // Canopy: teal gradient that ends in a wave crossing the middle of
          // the first services row, so half the grid sits on teal, half on white.
          final waveTop = top + 238.0;
          final canopyH = waveTop + 34.0;

          return RefreshIndicator(
            color: _t5,
            onRefresh: () => context.read<HomeCubit>().loadHome(),
            child: CustomScrollView(
              slivers: [
                // ── Header + services in one box: services overlap the canopy ─
                SliverToBoxAdapter(
                  child: Stack(children: [
                    Positioned(
                      top: 0, left: 0, right: 0,
                      height: canopyH,
                      child: _buildCanopy(waveTop),
                    ),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _buildHeaderContent(feed, top),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
                        child: _buildServicesSection(feed.categories),
                      ),
                      const SizedBox(height: 28),
                    ]),
                  ]),
                ),
                  // Promo carousel (full width)
                  SliverToBoxAdapter(child: _buildPromoCarousel()),
                  // Best sellers heading
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(22, 28, 22, 0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildSectionHeading(
                          tag: l10n.homeBestSellersTag,
                          rest: l10n.homeBestSellersRest,
                          sub: l10n.homeBestSellersSub,
                          onArrow: widget.onSeeAllBestSellers,
                        ),
                      ]),
                    ),
                  ),
                  // Best sellers cards (full width)
                  SliverToBoxAdapter(child: _buildBestSellersList(feed.topSellers)),
                  // Deals heading + list
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(22, 28, 22, 0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildSectionHeading(
                          tag: l10n.homeDealsTag, tagTeal: true,
                          rest: l10n.homeDealsRest,
                          sub: l10n.homeDealsSub,
                        ),
                        const SizedBox(height: 14),
                      ]),
                    ),
                  ),
                  // Everything past the ranked rail — the same ads, no duplication.
                  SliverToBoxAdapter(child: _buildDealsList(feed.topSellers.skip(3).toList())),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            );
        },
      ),
    );
  }

  // ─── Full scrollable header (canopy + wave + content move with page) ───────

  Widget _buildCanopy(double waveTop) {
    return Stack(children: [
      // Gradient canopy fills the box
      Positioned.fill(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.88, -0.1),
              end: Alignment(-0.4, 1.0),
              colors: [Color(0xFF3BBFA9), _t5, _t7],
              stops: [0.0, 0.45, 1.0],
            ),
          ),
          child: Stack(children: [
            Positioned(right: -40, top: -46, child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.07), shape: BoxShape.circle),
            )),
            Positioned(left: 40, top: 120, child: Container(
              width: 90, height: 90,
              decoration: BoxDecoration(color: _y.withValues(alpha: 0.12), shape: BoxShape.circle),
            )),
          ]),
        ),
      ),
      // Wave divider — anchored at waveTop
      Positioned(
        top: waveTop, left: 0, right: 0,
        height: 34,
        child: CustomPaint(painter: _WavePainter()),
      ),
    ]);
  }

  // ─── Header content (text/widgets on top of the gradient) ────────────────

  Widget _buildHeaderContent(HomeFeedModel feed, double top) {
    return Padding(
      padding: EdgeInsets.fromLTRB(22, top + 14, 22, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Location row + bell
        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: _chooseLocation,
              behavior: HitTestBehavior.opaque,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(AppLocalizations.of(context).homeServiceAt, style: _pj(size: 11.5, weight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.8), spacing: 0.3)),
                const SizedBox(height: 2),
                Row(children: [
                  Flexible(
                    child: Text(
                      // The address, not the label — "Home" alone does not
                      // tell the user which address is selected.
                      _pickedLocation?.address.isNotEmpty == true
                          ? _pickedLocation!.address
                          : (feed.locationDisplay.isEmpty
                              ? AppLocalizations.of(context).homeSelectLocation
                              : feed.locationDisplay),
                      overflow: TextOverflow.ellipsis,
                      style: _nu(size: 19, weight: FontWeight.w800, color: Colors.white, spacing: -0.2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withValues(alpha: 0.9), size: 18),
                ]),
              ]),
            ),
          ),
          // Notification bell
          GestureDetector(
            onTap: widget.onNotificationsTap,
            child: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
              ),
              child: Stack(clipBehavior: Clip.none, children: [
                const Center(child: Icon(Icons.notifications_outlined, color: Colors.white, size: 19)),
                Positioned(top: 9, right: 10, child: Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: _y, shape: BoxShape.circle, border: Border.all(color: _t6, width: 2)),
                )),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        // Search bar
        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: widget.onSearchTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: const Color(0xFF083226).withValues(alpha: 0.16), blurRadius: 24, offset: const Offset(0, 10))],
                ),
                child: Row(children: [
                  const Icon(Icons.search_rounded, color: _t6, size: 18),
                  const SizedBox(width: 11),
                  Expanded(child: Text(
                    'Search for a service or provider…',
                    style: _pj(size: 14.5, weight: FontWeight.w600, color: _i4.withValues(alpha: 0.9)),
                    overflow: TextOverflow.ellipsis,
                  )),
                ]),
              ),
            ),
          ),
        ]),
      ]),
    );
  }

  // ─── Services — 4-col grid, SVG icons, exact badge positioning ───────────

  Widget _buildServicesSection(List<ServiceCategoryModel> categories) {
    final l10n = AppLocalizations.of(context);
    final badges = <String, (String, bool)>{
      'taxi':    (l10n.homeBadgeFast, true),
      'elkstay': (l10n.homeBadgeNew, false),
      'porter':  (l10n.homeBadgeTwentyOff, false),
    };
    const cols = 4;
    const hGap = 9.0;
    const vGap = 14.0;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l10n.homeServices, style: _nu(size: 18, weight: FontWeight.w900, color: Colors.white, spacing: -0.2)),
        GestureDetector(
          onTap: widget.onSeeAllServices,
          child: Row(children: [
            Text(l10n.commonSeeAll, style: _pj(size: 13, weight: FontWeight.w800, color: Colors.white.withValues(alpha: 0.9))),
            const SizedBox(width: 2),
            Icon(Icons.chevron_right_rounded, size: 15, color: Colors.white.withValues(alpha: 0.9)),
          ]),
        ),
      ]),
      const SizedBox(height: 14),
      // Build rows using LayoutBuilder so tiles are exactly 1:1
      LayoutBuilder(builder: (context, constraints) {
        final tileW = (constraints.maxWidth - (cols - 1) * hGap) / cols;
        final rows = <Widget>[];
        for (int r = 0; r < ((categories.length + cols - 1) ~/ cols); r++) {
          if (r > 0) rows.add(const SizedBox(height: vGap));
          final rowItems = <Widget>[];
          for (int c = 0; c < cols; c++) {
            if (c > 0) rowItems.add(const SizedBox(width: hGap));
            final idx = r * cols + c;
            if (idx < categories.length) {
              final cat = categories[idx];
              rowItems.add(SizedBox(width: tileW, child: _buildTile(cat, badges[cat.id], tileW)));
            } else {
              rowItems.add(SizedBox(width: tileW));
            }
          }
          rows.add(Row(children: rowItems));
        }
        return Padding(
          padding: const EdgeInsets.only(top: 8), // space for badge overhang on first row
          child: Column(children: rows),
        );
      }),
    ]);
  }

  Widget _buildTile(ServiceCategoryModel cat, (String, bool)? badge, double tileW) {
    final iconPath = _icons[cat.id];
    return GestureDetector(
      onTap: () => widget.onCategoryTap?.call(cat),
      child: Column(children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Square cream card — exactly 1:1
            Container(
              width: tileW, height: tileW,
              decoration: BoxDecoration(
                color: _crm,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
                boxShadow: const [BoxShadow(color: Color(0x0F143228), blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: Center(
                child: iconPath != null
                    ? Image.asset(iconPath, width: tileW * 0.52, height: tileW * 0.52, fit: BoxFit.contain)
                    : Text(cat.icon, style: TextStyle(fontSize: tileW * 0.38)),
              ),
            ),
            // Badge — centred, floats 7px above card top
            if (badge != null)
              Positioned(
                top: -7, left: 0, right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badge.$2 ? _y : _i9,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [BoxShadow(color: Color(0x2E000000), blurRadius: 8, offset: Offset(0, 4))],
                    ),
                    child: Text(
                      badge.$1,
                      style: _pj(size: 9, weight: FontWeight.w800, color: badge.$2 ? const Color(0xFF3A2C00) : Colors.white, spacing: 0.3),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          cat.name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _pj(size: 11.5, weight: FontWeight.w700, color: _i7, spacing: -0.1),
        ),
      ]),
    );
  }

  // ─── Promo carousel ───────────────────────────────────────────────────────

  Widget _buildPromoCarousel() {
    final l10n = AppLocalizations.of(context);
    final promos = [
      (tag: l10n.homeBadgeNew, title: l10n.promoFirstBookingTitle, body: l10n.promoFirstBookingBody, cta: l10n.promoClaimOffer, emoji: '🎁', c1: const Color(0xFF3BBFA9), c2: const Color(0xFF18927F)),
      (tag: 'ELK Pro', title: l10n.promoFreeRidesTitle, body: l10n.promoFreeRidesBody, cta: l10n.promoJoinNow, emoji: '⚡', c1: const Color(0xFF243630), c2: const Color(0xFF15241F)),
    ];
    return Column(children: [
      SizedBox(
        height: 224,
        child: PageView.builder(
          controller: _promoCtrl,
          padEnds: false,
          itemCount: promos.length,
          itemBuilder: (context, i) {
            final p = promos[i];
            return Padding(
              padding: EdgeInsets.only(left: i == 0 ? 22 : 7, right: i == promos.length - 1 ? 22 : 7),
              child: GestureDetector(
                onTap: widget.onPromoTap,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 22, 100, 22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: const Alignment(1, -0.5), end: const Alignment(-0.4, 1), colors: [p.c1, p.c2]),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [BoxShadow(color: Color(0x42084A3A), blurRadius: 30, offset: Offset(0, 14))],
                  ),
                  child: Stack(clipBehavior: Clip.none, children: [
                    Positioned(right: -80, bottom: -70, child: Container(
                      width: 190, height: 190,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle),
                    )),
                    Positioned(right: -68, top: 0, bottom: 0, child: Center(
                      child: Text(p.emoji, style: const TextStyle(fontSize: 66)),
                    )),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: _y, borderRadius: BorderRadius.circular(999)),
                        child: Text(p.tag, style: _pj(size: 10.5, weight: FontWeight.w800, color: const Color(0xFF3A2C00), spacing: 0.6)),
                      ),
                      const SizedBox(height: 12),
                      Text(p.title, style: _nu(size: 22, weight: FontWeight.w900, color: Colors.white, spacing: -0.4, height: 1.12)),
                      const SizedBox(height: 6),
                      Text(p.body, maxLines: 2, overflow: TextOverflow.ellipsis, style: _pj(size: 12.5, weight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.85), height: 1.45)),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x28000000), blurRadius: 14, offset: Offset(0, 6))]),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(p.cta, style: _pj(size: 13, weight: FontWeight.w800, color: _t7)),
                          const SizedBox(width: 7),
                          const Icon(Icons.arrow_forward_rounded, size: 15, color: _t7),
                        ]),
                      ),
                    ]),
                  ]),
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (int i = 0; i < promos.length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == _promoDot ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(color: i == _promoDot ? _t6 : const Color(0xFFD7DDD8), borderRadius: BorderRadius.circular(6)),
          ),
      ]),
    ]);
  }

  // ─── Section heading (Talabat-style) ──────────────────────────────────────

  Widget _buildSectionHeading({required String tag, bool tagTeal = false, required String rest, required String sub, VoidCallback? onArrow}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(9, 4, 9, 5),
            decoration: BoxDecoration(color: tagTeal ? _t6 : _i9, borderRadius: BorderRadius.circular(8)),
            child: Text(tag, style: _nu(size: 18, weight: FontWeight.w900, color: Colors.white, spacing: -0.3, height: 1)),
          ),
          const SizedBox(width: 8),
          Text(rest, style: _nu(size: 20, weight: FontWeight.w900, color: _i9, spacing: -0.4)),
        ]),
        const SizedBox(height: 3),
        Text(sub, style: _pj(size: 12.5, weight: FontWeight.w600, color: _i5)),
      ]),
      if (onArrow != null)
        GestureDetector(
          onTap: onArrow,
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: _ln), boxShadow: const [BoxShadow(color: Color(0x0F143228), blurRadius: 8, offset: Offset(0, 2))]),
            child: const Icon(Icons.arrow_forward_rounded, size: 16, color: _i9),
          ),
        ),
    ]);
  }

  // ─── Best sellers ─────────────────────────────────────────────────────────

  /// The engagement-ranked seller ads from the home feed. Each card shows the
  /// two numbers the ranking is built on, rather than a star rating the
  /// backend does not track or a discount that does not exist.
  Widget _buildBestSellersList(List<AdModel> ads) {
    if (ads.isEmpty) {
      return _buildEmptyRail(AppLocalizations.of(context).homeNoSellerAds);
    }

    const tints = [
      (Color(0xFFE7F6F2), Color(0xFFBFE9DF)),
      (Color(0xFFFEF6D8), Color(0xFFF6CE19)),
      (Color(0xFFFBE3EC), Color(0xFFF6C4D6)),
      (Color(0xFFECE6FB), Color(0xFFD6CBF5)),
    ];

    return SizedBox(
      height: 228,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 6),
        itemCount: ads.length,
        itemBuilder: (context, i) {
          final ad = ads[i];
          final tint = tints[i % tints.length];
          return GestureDetector(
            onTap: widget.onSeeAllBestSellers,
            child: Container(
              width: 160,
              margin: EdgeInsets.only(right: i < ads.length - 1 ? 14 : 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [tint.$1, tint.$2], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [BoxShadow(color: Color(0x0F143228), blurRadius: 8, offset: Offset(0, 2))],
                  ),
                  child: Stack(children: [
                    if (ad.imageUrls.isEmpty)
                      Center(child: Text(ad.icon, style: const TextStyle(fontSize: 60)))
                    else
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(
                          ad.imageUrls.first,
                          width: double.infinity, height: 130, fit: BoxFit.cover,
                          // A broken presigned URL must not blank the card.
                          errorBuilder: (_, _, _) =>
                              Center(child: Text(ad.icon, style: const TextStyle(fontSize: 60))),
                        ),
                      ),
                    if (ad.isWishlisted)
                      Positioned(top: 8, right: 8, child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.favorite, size: 13, color: Color(0xFFE2554C)),
                      )),
                    Positioned(left: 8, bottom: 8, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.28), borderRadius: BorderRadius.circular(9)),
                      child: Text(ad.sellerName, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: _nu(size: 12, weight: FontWeight.w900, color: Colors.white)),
                    )),
                  ]),
                ),
                const SizedBox(height: 10),
                Text(ad.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: _nu(size: 14.5, weight: FontWeight.w800, color: _i9, spacing: -0.2, height: 1.15)),
                const SizedBox(height: 5),
                Row(children: [
                  const Icon(Icons.favorite_border_rounded, size: 12, color: _i4),
                  const SizedBox(width: 3),
                  Text('${ad.wishlistCount}', style: _pj(size: 11.5, weight: FontWeight.w600, color: _i4)),
                  const SizedBox(width: 9),
                  const Icon(Icons.visibility_outlined, size: 12, color: _i4),
                  const SizedBox(width: 3),
                  Text('${ad.viewCount}', style: _pj(size: 11.5, weight: FontWeight.w600, color: _i4)),
                ]),
                const SizedBox(height: 7),
                Text(ad.priceLabel, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: _nu(size: 15, weight: FontWeight.w900, color: _i9)),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyRail(String message) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 6),
        child: Row(children: [
          const Icon(Icons.storefront_outlined, size: 18, color: _i4),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: _pj(size: 13, weight: FontWeight.w600, color: _i5))),
        ]),
      );

  // ─── Deals ────────────────────────────────────────────────────────────────

  /// The rest of the marketplace, below the ranked rail. Same card, real ads —
  /// no invented "30% off" badges, since ads carry no discount.
  Widget _buildDealsList(List<AdModel> ads) {
    if (ads.isEmpty) {
      return _buildEmptyRail(AppLocalizations.of(context).homeMoreListingsSoon);
    }

    const tints = [Color(0xFFE7F6F2), Color(0xFFFEF6D8), Color(0xFFECE6FB), Color(0xFFFBE3EC)];

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
      child: Column(
        children: [
          for (final (i, ad) in ads.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: widget.onSeeAllBestSellers,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _ln),
                    boxShadow: const [BoxShadow(color: Color(0x0A143228), blurRadius: 10, offset: Offset(0, 3))],
                  ),
                  child: Row(children: [
                    Container(
                      width: 58, height: 58,
                      decoration: BoxDecoration(color: tints[i % tints.length], borderRadius: BorderRadius.circular(14)),
                      child: Center(child: Text(ad.icon, style: const TextStyle(fontSize: 28))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(ad.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: _nu(size: 15, weight: FontWeight.w800, color: _i9, spacing: -0.2)),
                        const SizedBox(height: 3),
                        Text(ad.sellerName, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: _pj(size: 12, weight: FontWeight.w600, color: _i5)),
                        const SizedBox(height: 5),
                        Row(children: [
                          const Icon(Icons.favorite_border_rounded, size: 12, color: _i4),
                          const SizedBox(width: 3),
                          Text('${ad.wishlistCount}', style: _pj(size: 11.5, weight: FontWeight.w600, color: _i4)),
                          const SizedBox(width: 9),
                          const Icon(Icons.visibility_outlined, size: 12, color: _i4),
                          const SizedBox(width: 3),
                          Text('${ad.viewCount}', style: _pj(size: 11.5, weight: FontWeight.w600, color: _i4)),
                          const SizedBox(width: 9),
                          Expanded(child: Text(ad.priceLabel, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: _pj(size: 11.5, weight: FontWeight.w800, color: _i9))),
                        ]),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final W = size.width;
    final H = size.height;
    final s = W / 392.0;
    final path = Path()
      ..moveTo(0, H * 16 / 34)
      ..cubicTo(60 * s, H, 120 * s, H, 196 * s, H * 18 / 34)
      ..cubicTo(272 * s, H * 2 / 34, 332 * s, H * 2 / 34, W, H * 18 / 34)
      ..lineTo(W, H)
      ..lineTo(0, H)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_) => false;
}
