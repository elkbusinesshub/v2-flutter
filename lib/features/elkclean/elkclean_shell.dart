import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/elkclean_colors.dart';
import '../../core/widgets/location_picker_sheet.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/elkclean_models.dart';
import '../../core/widgets/live_map_view.dart';
import '../../l10n/app_localizations.dart';
import 'cubit/elkclean_cubit.dart';

// ─── Cleaning home-screen design tokens ───────────────────────────────────────
const _hBg   = Color(0xFFF4F6F5);
const _hLine = Color(0xFFECEFEA);
const _hT7   = Color(0xFF0F6E60);
const _hT6   = Color(0xFF137A6D);
const _hT4   = Color(0xFF2FB29C);
const _hT05  = Color(0xFFE7F6F2);
const _hYel  = Color(0xFFF6CE19);
const _hYDk  = Color(0xFFE6B500);
const _hI9   = Color(0xFF15241F);
const _hI7   = Color(0xFF27382F);
const _hI5   = Color(0xFF5E6E66);
const _hI4   = Color(0xFF8C9890);

// Offer-card gradient palettes, cycled by index (visual only — the offer
// content comes from the backend).
const _offerPalettes = [
  (bg1: Color(0xFFF6EFDD), bg2: Color(0xFFEFE2C4)),
  (bg1: Color(0xFFFBE6EC), bg2: Color(0xFFF6CBD8)),
  (bg1: Color(0xFFE3F4EF), bg2: Color(0xFFC7EBE0)),
];

enum _S { home, cat, detail, cart, sched, addr, checkout, pay, done }

// ─── Shell ───────────────────────────────────────────────────────────────────

class ElkCleanShell extends StatefulWidget {
  const ElkCleanShell({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  State<ElkCleanShell> createState() => _ElkCleanShellState();
}

class _ElkCleanShellState extends State<ElkCleanShell> {
  AppLocalizations get l10n => AppLocalizations.of(context);

  final _hist = <_S>[_S.home];
  _S get _cur => _hist.last;

  CleanCategoryModel? _cat;
  CleanServiceModel? _svc;

  ElkCleanCubit get _cubit => context.read<ElkCleanCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.loadHome();
  }

  Future<void> _addAddress() async {
    final picked = await showLocationPicker(context, title: l10n.addServiceAddress);
    if (picked == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final error = await _cubit.addAddress(label: picked.label, line: picked.address);
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _go(_S s) {
    if (s == _S.sched) _cubit.loadBookingOptions();
    setState(() => _hist.add(s));
  }

  void _back() => _hist.length > 1 ? setState(() => _hist.removeLast()) : widget.onBack();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ElkCleanCubit>().state;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) => _back(),
      child: Scaffold(
        backgroundColor: ElkCleanColors.porcelain,
        body: switch (_cur) {
          _S.home     => _homeScreen(state),
          _S.cat      => _catScreen(state),
          _S.detail   => _detailScreen(state),
          _S.cart     => _cartScreen(state),
          _S.sched    => _schedScreen(state),
          _S.addr     => _addrScreen(state),
          _S.checkout => _checkoutScreen(state),
          _S.pay      => _payScreen(state),
          _S.done     => _doneScreen(state),
        },
      ),
    );
  }

  // ─── Home (new branded design) ────────────────────────────────────────────

  Widget _homeScreen(ElkCleanState state) {
    if (state.feedStatus == CleanViewStatus.guest) {
      return SafeArea(
        child: SignInRequiredView(
          message: l10n.cleanSignInPrompt,
        ),
      );
    }
    if (state.feedStatus == CleanViewStatus.error) {
      return SafeArea(
        child: ErrorRetryView(
          message: state.feedError ?? l10n.errorGeneric,
          onRetry: _cubit.loadHome,
        ),
      );
    }
    final feed = state.feed;
    if (feed == null) return const LoadingView();
    final top = MediaQuery.of(context).padding.top;
    return ColoredBox(
      color: _hBg,
      child: SingleChildScrollView(
        child: Column(children: [
          _cleanHeader(top, feed.location),
          const SizedBox(height: 20),
          // Service grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: _cleanServiceGrid(feed.categories),
          ),
          const SizedBox(height: 24),
          // Top offers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(l10n.topOffers, style: GoogleFonts.nunito(fontSize: 19, fontWeight: FontWeight.w900, color: _hI9, letterSpacing: -0.3)),
              Text('See all ›', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: _hT7)),
            ]),
          ),
          const SizedBox(height: 14),
          _cleanOffersCarousel(feed.offers),
          const SizedBox(height: 16),
          // Trust strip
          _cleanTrustStrip(),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  // Teal gradient header with bubbles, greeting, search, centered deal text
  Widget _cleanHeader(double top, String location) {
    return Stack(children: [
      // Teal gradient
      Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(22, top, 22, 58), // 36px visible + 22px under sheet
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.9, -0.5),
            end: Alignment(-0.3, 1.2),
            colors: [_hT4, _hT7],
          ),
        ),
        child: Column(children: [
          // Greeting row + bell
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.goodAfternoon, style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.82))),
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.location_on, color: _hYel, size: 16),
                const SizedBox(width: 6),
                Text(location, style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3)),
                const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
              ]),
            ])),
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
              ),
              child: Stack(clipBehavior: Clip.none, children: [
                const Center(child: Icon(Icons.notifications_outlined, color: Colors.white, size: 20)),
                Positioned(top: 10, right: 11, child: Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: _hYel, shape: BoxShape.circle, border: Border.all(color: _hT6, width: 2)),
                )),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: const Color(0xFF083226).withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, 10))],
            ),
            child: Row(children: [
              const Icon(Icons.search_rounded, color: _hT6, size: 18),
              const SizedBox(width: 11),
              Text(l10n.cleanSearchHint, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: _hI4.withValues(alpha: 0.9))),
            ]),
          ),
          const SizedBox(height: 18),
          // Centred deal text
          Text(l10n.playUnlockDeals, textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 23, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.4)),
          const SizedBox(height: 5),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(l10n.getWaterTankCleaning, style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.92))),
            Text('₹90 off', style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w800, color: _hYel)),
            Text(' & more', style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.92))),
            const SizedBox(width: 5),
            const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 15),
          ]),
        ]),
      ),
      // Bubble decorations (white / yellow-tint circles)
      Positioned(right: -30, top: -30, child: Container(width: 120, height: 120, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.10), shape: BoxShape.circle))),
      Positioned(left: 24, top: top + 104, child: Container(width: 60, height: 60, decoration: BoxDecoration(color: const Color(0xFFF6CE19).withValues(alpha: 0.14), shape: BoxShape.circle))),
      Positioned(right: 60, top: top + 124, child: Container(width: 26, height: 26, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.10), shape: BoxShape.circle))),
      Positioned(left: 120, top: top + 74, child: Container(width: 16, height: 16, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.10), shape: BoxShape.circle))),
      // Spark stars
      Positioned(top: top + 74, right: 30, child: Text('✦', style: TextStyle(fontSize: 18, color: Colors.white.withValues(alpha: 0.5)))),
      Positioned(top: top + 154, left: 60, child: Text('✦', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)))),
      // Sheet rounded-top overlay
      Positioned(bottom: 0, left: 0, right: 0, child: Container(
        height: 30,
        decoration: const BoxDecoration(color: _hBg, borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      )),
    ]);
  }

  // 4-column grid, yellow badges
  Widget _cleanServiceGrid(List<CleanCategoryModel> categories) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l10n.whatNeedsCleaning, style: GoogleFonts.nunito(fontSize: 19, fontWeight: FontWeight.w900, color: _hI9, letterSpacing: -0.3)),
        Text('${categories.length} services', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: _hI4)),
      ]),
      const SizedBox(height: 14),
      LayoutBuilder(builder: (context, constraints) {
        const cols = 4;
        const hGap = 9.0;
        const vGap = 12.0;
        final w = (constraints.maxWidth - (cols - 1) * hGap) / cols;
        final rows = <Widget>[];
        for (int r = 0; r < ((categories.length + cols - 1) ~/ cols); r++) {
          if (r > 0) rows.add(const SizedBox(height: vGap));
          final items = <Widget>[];
          for (int c = 0; c < cols; c++) {
            if (c > 0) items.add(const SizedBox(width: hGap));
            final idx = r * cols + c;
            if (idx < categories.length) {
              items.add(SizedBox(width: w, child: _cleanTile(categories[idx], w)));
            } else {
              items.add(SizedBox(width: w));
            }
          }
          rows.add(Row(children: items));
        }
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(children: rows),
        );
      }),
    ]);
  }

  Widget _cleanTile(CleanCategoryModel cat, double w) {
    return GestureDetector(
      onTap: () {
        setState(() { _cat = cat; });
        _cubit.openCategory(cat);
        _go(_S.cat);
      },
      child: Column(children: [
        Stack(clipBehavior: Clip.none, children: [
          Container(
            width: w, height: w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _hLine, width: 1.5),
              boxShadow: const [BoxShadow(color: Color(0x0A143218), blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: Center(child: SvgPicture.asset(cat.svgAsset, width: 46, height: 46)),
          ),
          if (cat.badge != null)
            Positioned(
              top: -8, left: 0, right: 0,
              child: Center(child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _hYel,  // yellow badge (cleaning style)
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [BoxShadow(color: Color(0x2E000000), blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: Text(cat.badge!, style: GoogleFonts.nunito(fontSize: 9.5, fontWeight: FontWeight.w900, color: const Color(0xFF3A2C00))),
              )),
            ),
        ]),
        const SizedBox(height: 8),
        Text(cat.label, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: _hI7, letterSpacing: -0.1, height: 1.2)),
      ]),
    );
  }

  // Horizontal offers carousel
  Widget _cleanOffersCarousel(List<CleanOfferModel> offers) {
    return SizedBox(
      height: 192,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
        itemCount: offers.length,
        itemBuilder: (context, i) {
          final o = offers[i];
          final palette = _offerPalettes[i % _offerPalettes.length];
          return Container(
            width: 270,
            margin: EdgeInsets.only(right: i < offers.length - 1 ? 14 : 0),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [palette.bg1, palette.bg2], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [BoxShadow(color: Color(0x1A143228), blurRadius: 26, offset: Offset(0, 10))],
            ),
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned(right: -6, bottom: -6, child: Opacity(opacity: 0.88, child: SvgPicture.asset(o.svgAsset, width: 96, height: 96))),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(o.title, style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900, color: _hI9, letterSpacing: -0.3), maxLines: 2),
                const SizedBox(height: 9),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(color: _hT7, borderRadius: BorderRadius.circular(999)),
                  child: Text(o.discount, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Text(l10n.codeLabel, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: _hI5)),
                  Text(o.code, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: _hI9, decoration: TextDecoration.underline)),
                ]),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 6, 11, 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999), boxShadow: const [BoxShadow(color: Color(0x0A143228), blurRadius: 8, offset: Offset(0, 2))]),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    SvgPicture.asset(o.svgAsset, width: 20, height: 20),
                    const SizedBox(width: 6),
                    Text(o.category, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w800, color: _hI9)),
                  ]),
                ),
              ]),
              Positioned(right: 16, top: 62, child: Container(
                width: 62, height: 62,
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 14, offset: Offset(0, 6))]),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('⚡', style: TextStyle(fontSize: 12, color: _hYDk)),
                  Text(o.time, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900, color: _hT7, height: 1)),
                  Text(o.unit, style: GoogleFonts.plusJakartaSans(fontSize: 7, fontWeight: FontWeight.w800, color: _hI4, letterSpacing: 0.2)),
                ]),
              )),
            ]),
          );
        },
      ),
    );
  }

  // Trust strip (eco, trained, re-clean guarantee)
  Widget _cleanTrustStrip() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _hT05, borderRadius: BorderRadius.circular(18)),
      child: Column(children: [
        for (final (icon, text) in [
          (Icons.eco_outlined,       l10n.ecoFriendlyProducts),
          (Icons.verified_outlined,  l10n.trainedCleaners),
          (Icons.refresh_rounded,    '48-hour re-clean guarantee'),
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.5),
            child: Row(children: [
              Icon(icon, size: 20, color: _hT6),
              const SizedBox(width: 11),
              Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: _hI7)),
            ]),
          ),
      ]),
    );
  }

  // ─── Category ──────────────────────────────────────────────────────────────

  Widget _catScreen(ElkCleanState state) {
    final cat = _cat!;
    final services = state.services;
    return Column(children: [
      _CleanTopBar(title: cat.label, onBack: _back, cartCount: state.cartCount, onCartTap: () => _go(_S.cart)),
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        child: Container(
          decoration: BoxDecoration(color: ElkCleanColors.teal, borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
              child: Icon(cat.icon, size: 26, color: ElkCleanColors.citrus),
            ),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${cat.code} · ${services.length} services', style: const TextStyle(fontSize: 11, letterSpacing: 0.1, color: Color(0xFFA9E0DC), fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(cat.blurb, style: const TextStyle(fontSize: 14, color: Color(0xFFCFE6E4))),
            ]),
          ]),
        ),
      ),
      if (state.servicesStatus == CleanViewStatus.loading)
        const Expanded(child: LoadingView())
      else if (state.servicesStatus == CleanViewStatus.error)
        Expanded(
          child: ErrorRetryView(
            message: state.servicesError ?? l10n.errorGeneric,
            onRetry: () => _cubit.openCategory(cat),
          ),
        )
      else
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          itemCount: services.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final s = services[i];
            final qty = state.qtyOf(s.id);
            return GestureDetector(
              onTap: () { setState(() { _svc = s; }); _go(_S.detail); },
              child: Container(
                decoration: BoxDecoration(
                  color: ElkCleanColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ElkCleanColors.line, width: 1.5),
                ),
                padding: const EdgeInsets.all(15),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(s.code, style: const TextStyle(fontSize: 11, color: ElkCleanColors.teal, fontWeight: FontWeight.w700)),
                    if (s.tag != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: ElkCleanColors.citrusSoft, borderRadius: BorderRadius.circular(20)),
                        child: Text(s.tag!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: ElkCleanColors.ink)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 6),
                  Text(s.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ElkCleanColors.ink)),
                  const SizedBox(height: 4),
                  Text(s.description, style: const TextStyle(fontSize: 13, color: ElkCleanColors.sub, height: 1.4)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.schedule, size: 13, color: ElkCleanColors.sub),
                    const SizedBox(width: 5),
                    Text(s.duration, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: ElkCleanColors.sub)),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('·', style: TextStyle(color: ElkCleanColors.sub))),
                    const Icon(Icons.check, size: 13, color: ElkCleanColors.good),
                    const SizedBox(width: 4),
                    Text('${s.checklist.length}-point checklist', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: ElkCleanColors.sub)),
                  ]),
                  const SizedBox(height: 12),
                  const Divider(color: ElkCleanColors.line, thickness: 1, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹${s.price}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ElkCleanColors.teal)),
                      qty > 0
                          ? _CleanStepper(qty: qty, onInc: () => _cubit.incrementLine(s.id), onDec: () => _cubit.decrementLine(s.id))
                          : _CleanBtn(label: '+ Add', small: true, onTap: () => _cubit.addService(s)),
                    ],
                  ),
                ]),
              ),
            );
          },
        ),
      ),
      if (state.cart.isNotEmpty) _CartBar(count: state.cartCount, total: state.total, onTap: () => _go(_S.cart)),
    ]);
  }

  // ─── Detail ────────────────────────────────────────────────────────────────

  Widget _detailScreen(ElkCleanState state) {
    final s = _svc!;
    final cat = _cat!;
    return Column(children: [
      _CleanTopBar(title: '', onBack: _back, cartCount: state.cartCount, onCartTap: () => _go(_S.cart)),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Hero
            Container(
              decoration: BoxDecoration(color: ElkCleanColors.tealDeep, borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.all(24),
              clipBehavior: Clip.antiAlias,
              child: Stack(children: [
                Positioned(right: -24, bottom: -24, child: Icon(cat.icon, size: 150, color: Colors.white.withValues(alpha: 0.08))),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${s.code} · ${cat.label}', style: const TextStyle(fontSize: 11, letterSpacing: 0.1, color: Color(0xFF8FD4D0), fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text(s.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, height: 1.05)),
                  const SizedBox(height: 16),
                  Row(children: [
                    _MetaTile(label: l10n.fromLabel, val: '₹${s.price}'),
                    const SizedBox(width: 24),
                    _MetaTile(label: l10n.duration, val: s.duration),
                    const SizedBox(width: 24),
                    _MetaTile(label: l10n.profileRating, val: '4.9★'),
                  ]),
                ]),
              ]),
            ),

            // Process timeline (Water Tank only)
            if (s.steps != null) ...[
              const SizedBox(height: 20),
              Text(l10n.howWeDoIt, style: const TextStyle(fontSize: 10, color: ElkCleanColors.sub, letterSpacing: 0.18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              _ProcessTimeline(steps: s.steps!),
              const SizedBox(height: 16),
              // Hygiene gauge
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: ElkCleanColors.tealSoft, borderRadius: BorderRadius.circular(16)),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(l10n.hygieneAfterService, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: ElkCleanColors.ink)),
                    Text('99% safe', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: ElkCleanColors.good)),
                  ]),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 10,
                      color: Colors.white,
                      child: FractionallySizedBox(
                        widthFactor: 0.99,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [ElkCleanColors.teal, ElkCleanColors.good]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(l10n.beforeLabel, style: const TextStyle(fontSize: 11, color: ElkCleanColors.sub)),
                    Text(l10n.afterLabTested, style: const TextStyle(fontSize: 11, color: ElkCleanColors.sub)),
                  ]),
                ]),
              ),
            ],

            const SizedBox(height: 20),
            Text('Your ${s.checklist.length}-point checklist', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ElkCleanColors.ink)),
            const SizedBox(height: 12),
            for (final item in s.checklist)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(color: ElkCleanColors.citrusSoft, borderRadius: BorderRadius.circular(7)),
                    child: const Icon(Icons.check, size: 14, color: ElkCleanColors.citrus),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item, style: const TextStyle(fontSize: 14, color: ElkCleanColors.ink))),
                ]),
              ),

            const SizedBox(height: 16),
            // Crew row
            Container(
              decoration: BoxDecoration(color: ElkCleanColors.lineSoft, borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(color: ElkCleanColors.teal, borderRadius: BorderRadius.circular(14)),
                  child: const Center(child: Text('EC', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white))),
                ),
                const SizedBox(width: 13),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(l10n.elkCleanCrew, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ElkCleanColors.ink)),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified, size: 15, color: ElkCleanColors.good),
                  ]),
                  const SizedBox(height: 2),
                  Text(l10n.crewBlurb, style: const TextStyle(fontSize: 13, color: ElkCleanColors.sub)),
                ])),
              ]),
            ),
          ]),
        ),
      ),
      _CleanStickyBar(
        left: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.priceCaps, style: const TextStyle(fontSize: 10, color: ElkCleanColors.sub, letterSpacing: 0.1)),
          Text('₹${s.price}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ElkCleanColors.teal)),
        ]),
        right: _CleanBtn(label: '+ Add & continue', onTap: () { _cubit.addService(s); _go(_S.cart); }),
      ),
    ]);
  }

  // ─── Cart ──────────────────────────────────────────────────────────────────

  Widget _cartScreen(ElkCleanState state) {
    final cart = state.cart;
    return Column(children: [
      _CleanTopBar(title: l10n.yourCleanPlan, onBack: _back),
      Expanded(
        child: cart.isEmpty
            ? _EmptyCart(onBrowse: () { setState(() { _hist.clear(); _hist.add(_S.home); }); })
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                child: Column(children: [
                  Container(
                    decoration: BoxDecoration(color: ElkCleanColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: ElkCleanColors.line, width: 1.5)),
                    clipBehavior: Clip.antiAlias,
                    child: Column(children: [
                      Container(
                        color: ElkCleanColors.teal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(l10n.cleanPlanCaps, style: TextStyle(fontSize: 10, letterSpacing: 0.1, color: Color(0xFFA9E0DC), fontWeight: FontWeight.w700)),
                          Text('${cart.length} item(s)', style: const TextStyle(fontSize: 11, color: Colors.white)),
                        ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: List.generate(cart.length, (i) {
                            final item = cart[i];
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: i < cart.length - 1
                                  ? BoxDecoration(border: Border(bottom: BorderSide(color: ElkCleanColors.line.withValues(alpha: 0.7))))
                                  : null,
                              child: Row(children: [
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(item.service.code, style: const TextStyle(fontSize: 10, color: ElkCleanColors.teal, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 2),
                                  Text(item.service.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: ElkCleanColors.ink)),
                                  const SizedBox(height: 3),
                                  Text('₹${item.service.price}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ElkCleanColors.teal)),
                                ])),
                                _CleanStepper(qty: item.quantity, onInc: () => _cubit.incrementLine(item.service.id), onDec: () => _cubit.decrementLine(item.service.id)),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () => _cubit.removeLine(item.service.id),
                                  child: const Icon(Icons.delete_outline, size: 18, color: ElkCleanColors.sub),
                                ),
                              ]),
                            );
                          }),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  // Promo
                  Row(children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(color: ElkCleanColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: ElkCleanColors.line, width: 1.5)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        child: Row(children: [
                          const Icon(Icons.auto_awesome, size: 16, color: ElkCleanColors.citrus),
                          const SizedBox(width: 8),
                          Text(l10n.addPromoCode, style: TextStyle(color: ElkCleanColors.sub.withValues(alpha: 0.8), fontSize: 14)),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: ElkCleanColors.line, width: 1.5)),
                      child: TextButton(onPressed: () {}, child: Text(l10n.commonApply, style: const TextStyle(fontWeight: FontWeight.w700, color: ElkCleanColors.teal))),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(color: ElkCleanColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: ElkCleanColors.line, width: 1.5)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(children: [
                      _TotalRow(label: l10n.subtotal, value: '₹${state.subtotal}'),
                      _TotalRow(label: l10n.ecoSuppliesSetup, value: '₹${state.supplyFee}', muted: true),
                      Divider(color: ElkCleanColors.line.withValues(alpha: 0.7)),
                      _TotalRow(label: l10n.total, value: '₹${state.total}', bold: true),
                    ]),
                  ),
                ]),
              ),
      ),
      if (cart.isNotEmpty)
        _CleanStickyBar(
          left: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.totalCaps, style: TextStyle(fontSize: 10, color: ElkCleanColors.sub, letterSpacing: 0.1)),
            Text('₹${state.total}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ElkCleanColors.teal)),
          ]),
          right: _CleanBtn(label: 'Schedule clean →', onTap: () => _go(_S.sched)),
        ),
    ]);
  }

  // ─── Schedule ──────────────────────────────────────────────────────────────

  Widget _schedScreen(ElkCleanState state) {
    if (state.optionsStatus == CleanViewStatus.loading || state.optionsStatus == CleanViewStatus.initial) {
      return Column(children: [
        _CleanTopBar(title: l10n.pickASlot, onBack: _back),
        const Expanded(child: LoadingView()),
      ]);
    }
    if (state.optionsStatus == CleanViewStatus.error || state.options == null) {
      return Column(children: [
        _CleanTopBar(title: l10n.pickASlot, onBack: _back),
        Expanded(
          child: ErrorRetryView(
            message: state.optionsError ?? 'Something went wrong',
            onRetry: _cubit.loadBookingOptions,
          ),
        ),
      ]);
    }
    final options = state.options!;
    return Column(children: [
      _CleanTopBar(title: l10n.pickASlot, onBack: _back),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.selectDate, style: const TextStyle(fontSize: 10, color: ElkCleanColors.sub, letterSpacing: 0.18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: options.dates.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final d = options.dates[i];
                  final on = state.dateIndex == i;
                  return GestureDetector(
                    onTap: () => _cubit.selectDate(i),
                    child: Container(
                      width: 62,
                      decoration: BoxDecoration(
                        color: on ? ElkCleanColors.teal : ElkCleanColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: on ? ElkCleanColors.teal : ElkCleanColors.line, width: 1.5),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(d.weekday, style: TextStyle(fontSize: 10, color: on ? Colors.white.withValues(alpha: 0.8) : ElkCleanColors.sub, fontWeight: FontWeight.w700)),
                        Text('${d.day}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: on ? Colors.white : ElkCleanColors.ink)),
                        Text(d.monthLabel, style: TextStyle(fontSize: 11, color: on ? Colors.white.withValues(alpha: 0.7) : ElkCleanColors.sub)),
                      ]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 26),
            Text(l10n.arrivalWindow, style: const TextStyle(fontSize: 10, color: ElkCleanColors.sub, letterSpacing: 0.18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 11, mainAxisSpacing: 11, childAspectRatio: 1.8),
              itemCount: state.availableTimeSlots.length,
              itemBuilder: (context, i) {
                final t = state.availableTimeSlots[i];
                final on = state.timeSlot == t;
                return GestureDetector(
                  onTap: () => _cubit.selectTimeSlot(t),
                  child: Container(
                    decoration: BoxDecoration(
                      color: on ? ElkCleanColors.citrusSoft : ElkCleanColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: on ? ElkCleanColors.citrus : ElkCleanColors.line, width: 1.5),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(t, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: on ? ElkCleanColors.ink : ElkCleanColors.ink)),
                      Text(i == 0 ? l10n.fillsFast : l10n.available, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: i == 0 ? ElkCleanColors.citrus : ElkCleanColors.sub)),
                    ]),
                  ),
                );
              },
            ),
            const SizedBox(height: 22),
            Container(
              decoration: BoxDecoration(color: ElkCleanColors.lineSoft, borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.all(14),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.schedule, size: 18, color: ElkCleanColors.teal),
                const SizedBox(width: 10),
                Expanded(child: Text(l10n.crewArrivalNote, style: const TextStyle(fontSize: 13, color: ElkCleanColors.ink, height: 1.45))),
              ]),
            ),
          ]),
        ),
      ),
      _CleanStickyBar(right: _CleanBtn(full: true, label: 'Confirm slot →', onTap: () => _go(_S.addr))),
    ]);
  }

  // ─── Address ───────────────────────────────────────────────────────────────

  Widget _addrScreen(ElkCleanState state) {
    final addrs = state.options?.addresses ?? const <CleanAddressModel>[];
    return Column(children: [
      _CleanTopBar(title: l10n.serviceAddress, onBack: _back),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
          child: Column(children: [
            _AddressMap(
              address: state.selectedAddress ?? (addrs.isEmpty ? null : addrs.first),
              tint: ElkCleanColors.tealDeep,
              pin: ElkCleanColors.citrus,
            ),
            const SizedBox(height: 18),
            Align(alignment: Alignment.centerLeft, child: Text(l10n.savedPlaces, style: const TextStyle(fontSize: 10, color: ElkCleanColors.sub, letterSpacing: 0.18, fontWeight: FontWeight.w700))),
            const SizedBox(height: 12),
            if (addrs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(l10n.noSavedAddresses, style: const TextStyle(fontSize: 13, color: ElkCleanColors.sub)),
              ),
            for (final addr in addrs) ...[
              GestureDetector(
                onTap: () => _cubit.selectAddress(addr.id),
                child: Container(
                  decoration: BoxDecoration(
                    color: ElkCleanColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: state.addressId == addr.id ? ElkCleanColors.teal : ElkCleanColors.line, width: 1.5),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Row(children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(color: state.addressId == addr.id ? ElkCleanColors.teal : ElkCleanColors.lineSoft, borderRadius: BorderRadius.circular(12)),
                      child: Icon(addr.isDefault ? Icons.home : Icons.location_on, size: 20, color: state.addressId == addr.id ? Colors.white : ElkCleanColors.teal),
                    ),
                    const SizedBox(width: 13),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(addr.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ElkCleanColors.ink)),
                      const SizedBox(height: 2),
                      Text(addr.line, style: const TextStyle(fontSize: 13, color: ElkCleanColors.sub)),
                    ])),
                    if (state.addressId == addr.id) Container(width: 22, height: 22, decoration: const BoxDecoration(color: ElkCleanColors.teal, shape: BoxShape.circle), child: const Icon(Icons.check, size: 14, color: Colors.white)),
                  ]),
                ),
              ),
              const SizedBox(height: 11),
            ],
            TextButton.icon(
              onPressed: _addAddress,
              icon: const Icon(Icons.add, size: 17, color: ElkCleanColors.teal),
              label: Text(l10n.addNewAddress, style: const TextStyle(fontWeight: FontWeight.w700, color: ElkCleanColors.teal, fontSize: 14)),
              style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: ElkCleanColors.line, width: 1.5))),
            ),
          ]),
        ),
      ),
      _CleanStickyBar(right: _CleanBtn(full: true, label: 'Continue to checkout →', onTap: () {
        if (state.addressId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.addServiceAddressFirst)),
          );
          return;
        }
        _go(_S.checkout);
      })),
    ]);
  }

  // ─── Checkout ──────────────────────────────────────────────────────────────

  Widget _checkoutScreen(ElkCleanState state) {
    final d = state.selectedDate;
    final address = state.selectedAddress;
    return Column(children: [
      _CleanTopBar(title: l10n.reviewConfirm, onBack: _back),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
          child: Column(children: [
            _InfoRow(icon: Icons.calendar_today, label: l10n.whenLabel, value: d == null ? '—' : '${d.weekday}, ${d.day} ${d.monthLabel} · ${state.timeSlot ?? ''}', onEdit: () => _go(_S.sched)),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.location_on, label: l10n.whereLabel, value: address == null ? '—' : '${address.label} · ${address.line}', onEdit: () => _go(_S.addr)),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.person, label: l10n.contactLabel, value: l10n.verifiedAccount),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(color: ElkCleanColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: ElkCleanColors.line, width: 1.5)),
              clipBehavior: Clip.antiAlias,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(l10n.orderSummary, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: ElkCleanColors.ink)),
                    TextButton(onPressed: () => _go(_S.cart), child: Text(l10n.commonEdit, style: const TextStyle(color: ElkCleanColors.citrus, fontWeight: FontWeight.w700, fontSize: 13))),
                  ]),
                ),
                Divider(color: ElkCleanColors.line.withValues(alpha: 0.7), height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(children: [
                    ...state.cart.map((i) => _TotalRow(label: '${i.service.name} ×${i.quantity}', value: '₹${i.lineTotal}')),
                    _TotalRow(label: l10n.ecoSuppliesSetup, value: '₹${state.supplyFee}', muted: true),
                    Divider(color: ElkCleanColors.line.withValues(alpha: 0.7)),
                    _TotalRow(label: l10n.totalToPay, value: '₹${state.total}', bold: true),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(color: ElkCleanColors.citrusSoft, borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.all(14),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.shield, size: 20, color: ElkCleanColors.citrus),
                const SizedBox(width: 10),
                Expanded(child: Text(l10n.recleanGuarantee, style: const TextStyle(fontSize: 13, color: ElkCleanColors.ink, height: 1.4))),
              ]),
            ),
          ]),
        ),
      ),
      _CleanStickyBar(
        left: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.totalCaps, style: TextStyle(fontSize: 10, color: ElkCleanColors.sub, letterSpacing: 0.1)),
          Text('₹${state.total}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ElkCleanColors.teal)),
        ]),
        right: _CleanBtn(label: 'Proceed to pay →', onTap: () => _go(_S.pay)),
      ),
    ]);
  }

  // ─── Payment ───────────────────────────────────────────────────────────────

  Widget _payScreen(ElkCleanState state) {
    final pay = state.paymentMethod;
    final methods = [
      (id: 'card',   icon: Icons.credit_card,           label: l10n.payCard,      sub: l10n.payCardBrands),
      (id: 'apple',  icon: Icons.phone_iphone,           label: l10n.payApplePay,  sub: l10n.payOneTapCheckout),
      (id: 'wallet', icon: Icons.account_balance_wallet, label: l10n.payElkWallet, sub: 'Balance ₹0.00'),
    ];
    return Column(children: [
      _CleanTopBar(title: l10n.sectionPayment, onBack: _back),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.chooseMethod, style: const TextStyle(fontSize: 10, color: ElkCleanColors.sub, letterSpacing: 0.18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            for (final m in methods) ...[
              GestureDetector(
                onTap: () => _cubit.selectPaymentMethod(m.id),
                child: Container(
                  decoration: BoxDecoration(color: ElkCleanColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: pay == m.id ? ElkCleanColors.teal : ElkCleanColors.line, width: 1.5)),
                  padding: const EdgeInsets.all(15),
                  child: Row(children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(color: pay == m.id ? ElkCleanColors.teal : ElkCleanColors.lineSoft, borderRadius: BorderRadius.circular(12)),
                      child: Icon(m.icon, size: 20, color: pay == m.id ? Colors.white : ElkCleanColors.teal),
                    ),
                    const SizedBox(width: 13),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(m.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ElkCleanColors.ink)),
                      Text(m.sub, style: const TextStyle(fontSize: 12.5, color: ElkCleanColors.sub)),
                    ])),
                    Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: pay == m.id ? ElkCleanColors.teal : ElkCleanColors.line, width: 2)),
                      child: pay == m.id ? const Center(child: CircleAvatar(radius: 5, backgroundColor: ElkCleanColors.teal)) : null,
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 11),
            ],
            if (pay == 'card')
              Container(
                decoration: BoxDecoration(color: ElkCleanColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: ElkCleanColors.line, width: 1.5)),
                padding: const EdgeInsets.all(18),
                child: Column(children: [
                  Container(
                    height: 110,
                    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0A4548), Color(0xFF0F6E72)]), borderRadius: BorderRadius.all(Radius.circular(16))),
                    padding: const EdgeInsets.all(18),
                    child: Stack(children: [
                      Positioned(right: -20, top: -20, child: Container(width: 90, height: 90, decoration: BoxDecoration(shape: BoxShape.circle, color: ElkCleanColors.citrus.withValues(alpha: 0.25)))),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(l10n.elkCleanCaps, style: TextStyle(fontSize: 10, color: Color(0xFF8FD4D0), letterSpacing: 0.1, fontWeight: FontWeight.w700)),
                        Text('•••• •••• •••• 4821', style: TextStyle(fontSize: 17, color: Colors.white, letterSpacing: 0.12)),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('A. RESIDENT', style: TextStyle(fontSize: 11, color: Colors.white)),
                          Text('06 / 28', style: TextStyle(fontSize: 11, color: Colors.white)),
                        ]),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  _FieldBox(label: l10n.cardNumber, value: '4242 4242 4242 4821'),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _FieldBox(label: l10n.cardExpiry, value: '06 / 28')),
                    const SizedBox(width: 12),
                    Expanded(child: _FieldBox(label: l10n.cardCvv, value: '•••')),
                  ]),
                  const SizedBox(height: 12),
                  _FieldBox(label: l10n.nameOnCard, value: 'A. Resident'),
                  const SizedBox(height: 14),
                  Row(children: [
                    Container(width: 20, height: 20, decoration: BoxDecoration(color: ElkCleanColors.teal, borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.check, size: 13, color: Colors.white)),
                    const SizedBox(width: 9),
                    Text(l10n.saveCardFasterCheckout, style: const TextStyle(fontSize: 13.5, color: ElkCleanColors.ink)),
                  ]),
                ]),
              ),
            const SizedBox(height: 16),
            const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.shield, size: 15, color: ElkCleanColors.sub),
              SizedBox(width: 6),
              Text('256-bit encrypted · powered by ELK Pay', style: TextStyle(fontSize: 12.5, color: ElkCleanColors.sub)),
            ]),
          ]),
        ),
      ),
      _CleanStickyBar(right: _CleanBtn(
        full: true,
        citrus: true,
        label: state.isBooking ? l10n.processing : l10n.paySecurely('₹${state.total}'),
        onTap: () async {
          if (state.isBooking) return;
          final messenger = ScaffoldMessenger.of(context);
          final booked = await _cubit.confirmBooking();
          if (!mounted) return;
          if (booked) {
            _go(_S.done);
          } else {
            messenger.showSnackBar(SnackBar(
              content: Text(_cubit.state.bookingError ?? l10n.paymentFailed),
            ));
          }
        },
      )),
    ]);
  }

  // ─── Done ──────────────────────────────────────────────────────────────────

  Widget _doneScreen(ElkCleanState state) {
    final confirmation = state.confirmation;
    final d = state.selectedDate;
    return Container(
      color: ElkCleanColors.tealDeep,
      padding: EdgeInsets.fromLTRB(30, MediaQuery.of(context).padding.top + 30, 30, 40),
      child: Column(children: [
        const Spacer(),
        // Concentric rings
        Stack(alignment: Alignment.center, children: [
          for (int i = 4; i >= 0; i--)
            Container(
              width: 96.0 + i * 38,
              height: 96.0 + i * 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.06 + i * 0.02), width: 2),
              ),
            ),
          Container(
            width: 96, height: 96,
            decoration: const BoxDecoration(color: ElkCleanColors.citrus, shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome, size: 46, color: ElkCleanColors.ink),
          ),
        ]),
        const SizedBox(height: 24),
        const Text('Clean\nbooked.', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white, height: 1.05)),
        const SizedBox(height: 12),
        const Text("Your crew is assigned with all supplies. We'll send a tracking link before arrival.", textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Color(0xFFCFE6E4), height: 1.5)),
        const Spacer(),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(color: ElkCleanColors.card, borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.all(18),
          child: Stack(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('CLEAN REPORT #${confirmation?.code ?? ''}', style: const TextStyle(fontSize: 10, color: ElkCleanColors.citrus, letterSpacing: 0.1, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _TotalRow(label: l10n.whenLabel, value: d == null ? '—' : '${d.weekday} ${d.day} ${d.monthLabel}, ${confirmation?.timeSlot ?? state.timeSlot ?? ''}'),
              const SizedBox(height: 4),
              Divider(color: ElkCleanColors.line.withValues(alpha: 0.7)),
              _TotalRow(label: l10n.paidLabel, value: '₹${confirmation?.totalAmount ?? 0}', bold: true),
            ]),
            Positioned(
              top: 0, right: 0,
              child: Transform.rotate(
                angle: -0.21,
                child: Container(
                  decoration: BoxDecoration(border: Border.all(color: ElkCleanColors.good, width: 2), borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: Text(l10n.paidCaps, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: ElkCleanColors.good, letterSpacing: 0.1)),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 22),
        _CleanBtn(full: true, citrus: true, label: l10n.trackMyClean, onTap: widget.onBack),
        const SizedBox(height: 14),
        TextButton(
          onPressed: widget.onBack,
          child: Text(l10n.backToHome, style: TextStyle(color: Color(0xFFCFE6E4), fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

// ─── Process timeline (Water Tank) ───────────────────────────────────────────

class _ProcessTimeline extends StatelessWidget {
  const _ProcessTimeline({required this.steps});
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          SizedBox(
            width: 50,
            child: Column(children: [
              Container(
                width: 30, height: 30,
                decoration: const BoxDecoration(color: ElkCleanColors.teal, shape: BoxShape.circle),
                child: Center(child: Text('${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white))),
              ),
              const SizedBox(height: 6),
              Text(steps[i], textAlign: TextAlign.center, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: ElkCleanColors.ink, height: 1.1)),
            ]),
          ),
          if (i < steps.length - 1)
            Expanded(child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Container(height: 2, color: ElkCleanColors.line),
            )),
        ],
      ],
    );
  }
}

// ─── Private helpers ─────────────────────────────────────────────────────────

class _CleanTopBar extends StatelessWidget {
  const _CleanTopBar({required this.title, required this.onBack, this.cartCount = 0, this.onCartTap});
  final String title;
  final VoidCallback onBack;
  final int cartCount;
  final VoidCallback? onCartTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        child: Row(children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(border: Border.all(color: ElkCleanColors.line, width: 1.5), borderRadius: BorderRadius.circular(12), color: ElkCleanColors.card),
              child: const Icon(Icons.chevron_left, size: 20, color: ElkCleanColors.ink),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: ElkCleanColors.ink))),
          if (onCartTap != null)
            GestureDetector(
              onTap: onCartTap,
              child: Stack(clipBehavior: Clip.none, children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(border: Border.all(color: ElkCleanColors.line, width: 1.5), borderRadius: BorderRadius.circular(12), color: ElkCleanColors.card),
                  child: const Icon(Icons.shopping_bag_outlined, size: 20, color: ElkCleanColors.ink),
                ),
                if (cartCount > 0)
                  Positioned(
                    top: -4, right: -4,
                    child: Container(width: 18, height: 18, decoration: const BoxDecoration(color: ElkCleanColors.citrus, shape: BoxShape.circle), child: Center(child: Text('$cartCount', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: ElkCleanColors.ink)))),
                  ),
              ]),
            ),
        ]),
      ),
    );
  }
}

class _CleanBtn extends StatelessWidget {
  const _CleanBtn({required this.label, required this.onTap, this.small = false, this.full = false, this.citrus = false});
  final String label;
  final VoidCallback onTap;
  final bool small, full, citrus;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: full ? double.infinity : null,
        padding: EdgeInsets.symmetric(horizontal: small ? 14 : 18, vertical: small ? 9 : 14),
        decoration: BoxDecoration(
          color: citrus ? ElkCleanColors.citrus : ElkCleanColors.teal,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: small ? 13 : 15, fontWeight: FontWeight.w700, color: citrus ? ElkCleanColors.ink : Colors.white)),
      ),
    );
  }
}

class _CleanStepper extends StatelessWidget {
  const _CleanStepper({required this.qty, required this.onInc, required this.onDec});
  final int qty;
  final VoidCallback onInc, onDec;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: ElkCleanColors.lineSoft, borderRadius: BorderRadius.circular(11)),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(
          onTap: onDec,
          child: Container(width: 26, height: 26, decoration: BoxDecoration(color: ElkCleanColors.card, border: Border.all(color: ElkCleanColors.line), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.remove, size: 14, color: ElkCleanColors.ink)),
        ),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('$qty', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ElkCleanColors.ink))),
        GestureDetector(
          onTap: onInc,
          child: Container(width: 26, height: 26, decoration: BoxDecoration(color: ElkCleanColors.teal, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add, size: 14, color: Colors.white)),
        ),
      ]),
    );
  }
}

class _CleanStickyBar extends StatelessWidget {
  const _CleanStickyBar({this.left, required this.right});
  final Widget? left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(18, 12, 18, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: ElkCleanColors.porcelain,
        border: const Border(top: BorderSide(color: ElkCleanColors.line)),
        boxShadow: [BoxShadow(color: ElkCleanColors.ink.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: ElkCleanColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: ElkCleanColors.line, width: 1.5)),
        child: left != null ? Row(children: [left!, const SizedBox(width: 14), Expanded(child: right)]) : right,
      ),
    );
  }
}

class _CartBar extends StatelessWidget {
  const _CartBar({required this.count, required this.total, required this.onTap});
  final int count, total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(color: ElkCleanColors.teal, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Text(AppLocalizations.of(context).servicesAdded(count), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          const Spacer(),
          Text('₹$total', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ElkCleanColors.citrus)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.white, size: 18),
        ]),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onBrowse});
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 70, height: 70, decoration: BoxDecoration(color: ElkCleanColors.lineSoft, borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.shopping_bag_outlined, size: 32, color: ElkCleanColors.sub)),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context).noServicesYet, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ElkCleanColors.ink)),
          const SizedBox(height: 6),
          Text(AppLocalizations.of(context).browseCleaningBlurb, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: ElkCleanColors.sub)),
          const SizedBox(height: 18),
          _CleanBtn(label: AppLocalizations.of(context).browseServices, onTap: onBrowse),
        ]),
      ),
    );
  }
}

class _MetaTile extends StatelessWidget {
  const _MetaTile({required this.label, required this.val});
  final String label, val;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF8FD4D0), letterSpacing: 0.08, fontWeight: FontWeight.w700)),
      const SizedBox(height: 3),
      Text(val, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
    ]);
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value, this.onEdit});
  final IconData icon;
  final String label, value;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: ElkCleanColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: ElkCleanColors.line, width: 1.5)),
      padding: const EdgeInsets.all(15),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: ElkCleanColors.lineSoft, borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 19, color: ElkCleanColors.teal)),
        const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: ElkCleanColors.sub, letterSpacing: 0.08, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: ElkCleanColors.ink)),
        ])),
        if (onEdit != null)
          TextButton(onPressed: onEdit, child: Text(AppLocalizations.of(context).commonEdit, style: const TextStyle(color: ElkCleanColors.citrus, fontWeight: FontWeight.w700, fontSize: 13))),
      ]),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value, this.bold = false, this.muted = false});
  final String label, value;
  final bool bold, muted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: bold ? 15 : 13.5, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: muted ? ElkCleanColors.sub : ElkCleanColors.ink)),
        Text(value, style: TextStyle(fontSize: bold ? 17 : 14, fontWeight: FontWeight.w700, color: bold ? ElkCleanColors.teal : muted ? ElkCleanColors.sub : ElkCleanColors.ink)),
      ]),
    );
  }
}

class _FieldBox extends StatelessWidget {
  const _FieldBox({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 10, color: ElkCleanColors.sub, letterSpacing: 0.08, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(color: ElkCleanColors.porcelain, borderRadius: BorderRadius.circular(11), border: Border.all(color: ElkCleanColors.line, width: 1.5)),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        child: Text(value, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: ElkCleanColors.ink)),
      ),
    ]);
  }
}


/// The service address on a real map, or a tinted placeholder before one is
/// chosen. Replaces a painted grid that drew the same invented streets for
/// every user regardless of where they were.
class _AddressMap extends StatelessWidget {
  const _AddressMap({required this.address, required this.tint, required this.pin});

  final CleanAddressModel? address;
  final Color tint;
  final Color pin;

  @override
  Widget build(BuildContext context) {
    final placeholder = Stack(fit: StackFit.expand, children: [
      Container(color: tint),
      Center(child: Icon(Icons.location_on, size: 40, color: pin)),
    ]);

    final a = address;
    if (a == null || a.lat == null || a.lng == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(height: 150, child: placeholder),
      );
    }

    // The real Google map, not a static image: the Maps Static API is disabled
    // on the project, so the static-map image here always fell back to `placeholder`
    // and the user never saw their address on a map at all.
    return LiveMapView(
      points: [
        MapPoint(lat: a.lat!, lng: a.lng!, kind: MapPointKind.place, label: a.label),
      ],
      height: 150,
      // Sits inside a scrolling sheet, where a pannable map fights the scroll.
      interactive: false,
      borderRadius: BorderRadius.circular(18),
    );
  }
}
