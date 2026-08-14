import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/widgets/live_map_view.dart';
import '../../../data/models/ad_models.dart';
import '../../../data/repositories/marketplace_repository.dart';
import '../../../l10n/app_localizations.dart';

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

// The seven vendor illustrations that lived here were only referenced by the
// removed fixture list; _svg()/_svgDefs stay, since the vendor card still
// renders whatever illustration a real listing supplies.

// ── vendor data ─────────────────────────────────────────────────────────────
class _Vendor {
  _Vendor({
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
    this.lat,
    this.lng,
    this.emoji = '🛍️',
    this.wishlistCount = 0,
    this.viewCount = 0,
    this.isWishlisted = false,
  });

  final String id, vendor, title, cat, ill, badge, desc, addr, phone;

  /// Centre of [addr]. Null when the backend has no coordinate for the
  /// locality, in which case the coverage map is hidden.
  final double? lat, lng;

  /// Shown when [ill] is empty — real ads carry an emoji, not an SVG.
  final String emoji;

  /// The two numbers the ranking is built on. [wishlistCount] and
  /// [isWishlisted] are mutable because saving updates them in place: the same
  /// ad appears in the rails, in search results and on the detail screen, and
  /// all three have to agree after a tap.
  int wishlistCount;
  bool isWishlisted;
  final int viewCount;
  final bool badgeDark;
  final int price, oldPrice;
  final double rating;
  final String jobs, eta;
  final LinearGradient grad;
  final Color radialGlow;
  final List<String> incl;
}

/// Presentation palette for the cards — the backend supplies no colours, so
/// these cycle by position. Not data.
const _cardGrads = <LinearGradient>[
  LinearGradient(colors: [Color(0xFF0F6E60), Color(0xFF15887A)]),
  LinearGradient(colors: [Color(0xFFE6B500), Color(0xFFF6CE19)]),
  LinearGradient(colors: [Color(0xFF1A4A3C), Color(0xFF2A7A66)]),
  LinearGradient(colors: [Color(0xFF7A4FCF), Color(0xFF9B6FE8)]),
];

/// Maps a marketplace ad onto the card model this screen was built around.
///
/// Fields the backend does not track — star rating, jobs-done, ETA, a
/// discounted "was" price, an inclusions list, a public phone number — are
/// left empty rather than invented, and every render site guards for that.
_Vendor _vendorFrom(AdModel ad, int index) {
  final grad = _cardGrads[index % _cardGrads.length];
  return _Vendor(
    id: ad.id,
    vendor: ad.sellerName,
    title: ad.title,
    cat: ad.categorySlug,
    ill: '',
    emoji: ad.icon,
    grad: grad,
    radialGlow: grad.colors.last,
    badge: ad.categorySlug.replaceAll('_', ' '),
    badgeDark: false,
    price: ad.price.round(),
    oldPrice: 0,
    rating: 0,
    jobs: '',
    eta: '',
    desc: ad.description,
    incl: const [],
    addr: ad.location,
    phone: '',
    lat: ad.lat,
    lng: ad.lng,
    wishlistCount: ad.wishlistCount,
    viewCount: ad.viewCount,
    isWishlisted: ad.isWishlisted,
  );
}

// ── internal screens enum ────────────────────────────────────────────────────
enum _Sn { list, detail }

// ── screen ───────────────────────────────────────────────────────────────────
class BestSellersScreen extends StatefulWidget {
  const BestSellersScreen({super.key});

  @override
  State<BestSellersScreen> createState() => _State();
}

class _State extends State<BestSellersScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);

  final List<_Sn> _stack = [_Sn.list];
  _Vendor? _cur;
  String _query = '';

  List<_Vendor> _vendors = const [];
  bool _loading = true;
  String? _loadError;

  /// Search runs against `GET /marketplace/ads`, not over [_vendors]: the rails
  /// hold only the top 30 sellers, so filtering them locally could never find
  /// anything outside that slice.
  List<_Vendor> _results = const [];
  bool _searching = false;
  String? _searchError;
  Timer? _debounce;

  /// Guards against an earlier, slower response overwriting a later one.
  int _searchSeq = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();

    final q = value.trim();
    // The backend rejects a one-character query (min length 2); below that
    // there is nothing to ask for.
    if (q.length < 2) {
      setState(() {
        _results = const [];
        _searching = false;
        _searchError = null;
      });
      return;
    }

    setState(() => _searching = true);
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(q));
  }

  Future<void> _search(String query) async {
    final seq = ++_searchSeq;
    try {
      final ads = await context.read<MarketplaceRepository>().listAds(
            query: query,
            limit: 50,
          );
      if (!mounted || seq != _searchSeq) return;
      setState(() {
        _results = [for (final (i, ad) in ads.indexed) _vendorFrom(ad, i)];
        _searching = false;
        _searchError = null;
      });
    } catch (e) {
      if (!mounted || seq != _searchSeq) return;
      setState(() {
        _searching = false;
        _searchError = friendlyErrorMessage(e);
      });
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final ads = await context.read<MarketplaceRepository>().topSellers(limit: 30);
      if (!mounted) return;
      setState(() {
        _vendors = [for (final (i, ad) in ads.indexed) _vendorFrom(ad, i)];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = friendlyErrorMessage(e);
      });
    }
  }

  /// Collects the two things an order needs — where and who to call — then
  /// places it. Kept deliberately small: anything else the seller needs is in
  /// the note field.
  Future<void> _openOrderSheet(_Vendor vendor) async {
    final addressCtrl = TextEditingController(text: vendor.addr);
    final phoneCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final repository = context.read<MarketplaceRepository>();
    var submitting = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            18,
            20,
            20 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              vendor.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: _ink9,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '₹${vendor.price}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: _tDp,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressCtrl,
              decoration: InputDecoration(
                labelText: l10n.stepLocation,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: l10n.phoneNumber,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.description,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _tDp,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: submitting
                    ? null
                    : () async {
                        final address = addressCtrl.text.trim();
                        final phone = phoneCtrl.text.trim();
                        if (address.isEmpty || phone.isEmpty) {
                          ScaffoldMessenger.of(ctx)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(content: Text(l10n.fillRequiredFields)),
                            );
                          return;
                        }
                        setSheet(() => submitting = true);
                        try {
                          final order = await repository.placeOrder(
                            vendor.id,
                            addressText: address,
                            contactPhone: phone,
                            note: noteCtrl.text.trim().isEmpty
                                ? null
                                : noteCtrl.text.trim(),
                          );
                          if (!ctx.mounted) return;
                          // Captured before the pop: the sheet's own messenger
                          // goes away with it, and the confirmation should
                          // outlive the sheet.
                          final messenger = ScaffoldMessenger.of(ctx);
                          Navigator.pop(ctx);
                          messenger
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(content: Text(l10n.orderPlaced(order.code))),
                            );
                        } catch (e) {
                          if (!ctx.mounted) return;
                          setSheet(() => submitting = false);
                          ScaffoldMessenger.of(ctx)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(content: Text(friendlyErrorMessage(e))),
                            );
                        }
                      },
                child: submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        l10n.placeOrder,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  /// Saves or unsaves an ad, updating every copy of it on screen.
  ///
  /// Optimistic, like the ElkStay stay-detail heart: the icon flips
  /// immediately and rolls back if the call fails, because waiting on a round
  /// trip to fill a heart reads as a broken button.
  Future<void> _toggleWishlist(_Vendor vendor) async {
    final wasSaved = vendor.isWishlisted;
    final wasCount = vendor.wishlistCount;

    _applyWishlist(
      vendor.id,
      saved: !wasSaved,
      count: wasSaved ? wasCount - 1 : wasCount + 1,
    );

    try {
      final result = await context
          .read<MarketplaceRepository>()
          .setWishlisted(vendor.id, wishlisted: !wasSaved);
      if (!mounted) return;
      // Trust the server's count over the guess — other people save too.
      _applyWishlist(
        vendor.id,
        saved: result.isWishlisted,
        count: result.wishlistCount,
      );
    } catch (e) {
      if (!mounted) return;
      _applyWishlist(vendor.id, saved: wasSaved, count: wasCount);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(friendlyErrorMessage(e))));
    }
  }

  /// The same ad can be on screen three times — in a rail, in search results
  /// and as the open detail page. All of them move together.
  void _applyWishlist(String id, {required bool saved, required int count}) {
    setState(() {
      for (final v in [..._vendors, ..._results, ?_cur]) {
        if (v.id == id) {
          v.isWishlisted = saved;
          v.wishlistCount = count;
        }
      }
    });
  }

  /// Opening an ad is what records a view, so the ranking reflects real
  /// interest. Failure is silent — the detail page still opens from the card
  /// we already have.
  Future<void> _openVendor(_Vendor v) async {
    _push(_Sn.detail, vendor: v);
    try {
      final fresh = await context.read<MarketplaceRepository>().getAd(v.id);
      if (!mounted) return;
      setState(() => _cur = _vendorFrom(fresh, 0));
    } catch (_) {
      // keep the card we already showed
    }
  }

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
    final q = _query.trim();

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _DarkHeader(title: l10n.homeBestSellersTag, top: top, onBack: _pop),
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
                      onChanged: _onQueryChanged,
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
                        hintText: l10n.searchVendorsHint,
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
            child: q.isNotEmpty ? _searchBody() : _railsBody(),
          ),
        ],
      ),
    );
  }

  // ── search results (flat grid) ───────────────────────────────────────────

  /// Search has its own loading and error states because it is a round trip,
  /// not a filter over what is already on screen.
  Widget _searchBody() {
    if (_searching) {
      return const Center(
        child: SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(strokeWidth: 2.2, color: _tDp),
        ),
      );
    }
    if (_searchError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _searchError!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _ink5,
            ),
          ),
        ),
      );
    }
    return _searchResults(_results);
  }

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
        onTap: () => _openVendor(results[i]),
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

  /// Shown until the marketplace backend exists — better than inventing
  /// vendors the user cannot actually book.
  Widget _emptyState() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏪', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(
                l10n.noSellersYet,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: _ink9,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.listingsWillAppear,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _ink5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _railsBody() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: _tDp));
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(_loadError!, textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: _ink5)),
            const SizedBox(height: 10),
            TextButton(onPressed: _load, child: Text(l10n.commonRetry)),
          ]),
        ),
      );
    }
    if (_vendors.isEmpty) return _emptyState();
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
            l10n.topRatedNearYou,
            sub: l10n.tapCardToViewVendor,
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
            onTap: () => _openVendor(vendors[i]),
          ),
        ),
      ),
    );
  }

  // ── detail screen ──────────────────────────────────────────────────────────
  Widget _detailScreen() {
    final v = _cur!;
    final top = MediaQuery.of(context).padding.top;
    // Ads carry no "was" price, so there is no discount to advertise.
    // Guarded rather than removed so a future sale price still works.
    final savePercent =
        v.oldPrice > v.price ? ((1 - v.price / v.oldPrice) * 100).round() : 0;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Scrollable content
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _DetailHero(
                  vendor: v,
                  top: top,
                  onBack: _pop,
                  onWishlistTap: () => _toggleWishlist(v),
                ),
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
                                // Engagement, not a star rating — the backend
                                // tracks saves and views, not reviews.
                                const Icon(Icons.favorite_rounded, size: 13, color: Color(0xFFE2554C)),
                                const SizedBox(width: 4),
                                Text(
                                  '${v.wishlistCount}',
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
                            text: l10n.verifiedVendor,
                            icon: Icons.check_circle_rounded,
                            fg: _tDp,
                            bg: _t050,
                          ),
                          _Pill(
                            text: '${v.viewCount} views',
                            fg: const Color(0xFF9A7400),
                            bg: _y050,
                          ),
                          // "jobs done" and an ETA have no source in an ad, so
                          // they are omitted rather than shown as blanks.
                          if (v.eta.isNotEmpty)
                            _Pill(text: '⏱ ${v.eta}', fg: _ink5, bg: _chip),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Pricing
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${v.price}',
                            style: GoogleFonts.nunito(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: _ink9,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (savePercent > 0) ...[
                          const SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '₹${v.oldPrice}',
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
                        ],
                      ),
                      const SizedBox(height: 22),
                      // About section
                      _SectionTitle(l10n.aboutThisService),
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
                      if (v.incl.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      // What's included — ads carry no inclusions list yet, so
                      // the section hides rather than showing an empty heading.
                      _SectionTitle(l10n.whatsIncluded),
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
                      ],
                      const SizedBox(height: 22),
                      // Location
                      _SectionTitle(l10n.locationCoverage),
                      const SizedBox(height: 12),
                      _LocationCard(addr: v.addr, lat: v.lat, lng: v.lng),
                      if (v.phone.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        _SectionTitle(l10n.contactVendor),
                        const SizedBox(height: 12),
                        _ContactSection(phone: v.phone),
                      ],
                      if (v.rating > 0) ...[
                        const SizedBox(height: 22),
                        _SectionTitle(l10n.ratingsReviews),
                        const SizedBox(height: 12),
                        _ReviewCard(rating: v.rating),
                      ],
                      const SizedBox(height: 26),
                      // The only way to actually order a listing. Without it
                      // the seller's Orders tab could never fill.
                      _OrderButton(onTap: () => _openOrderSheet(v)),
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
    required this.onWishlistTap,
  });

  final _Vendor vendor;
  final double top;
  final VoidCallback onBack;
  final VoidCallback onWishlistTap;

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
            child: GestureDetector(
              onTap: onWishlistTap,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(13),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.20)),
                ),
                child: Icon(
                  vendor.isWishlisted
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: vendor.isWishlisted
                      ? const Color(0xFFE2554C)
                      : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          // Center illustration
          Center(
            // Real ads carry an emoji, not an SVG illustration; SvgPicture
            // would throw on an empty string.
            child: vendor.ill.isEmpty
                ? Text(vendor.emoji, style: const TextStyle(fontSize: 76))
                : SvgPicture.string(_svg(vendor.ill), width: 130, height: 130),
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
                    // Illustration — emoji for a real ad, SVG for a fixture.
                    Center(
                      child: v.ill.isEmpty
                          ? Text(v.emoji, style: const TextStyle(fontSize: 34))
                          : SvgPicture.string(_svg(v.ill), width: 56, height: 56),
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
                        '₹${v.price}',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: _ink9,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        '₹${v.oldPrice}',
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
  const _LocationCard({required this.addr, this.lat, this.lng});
  final String addr;
  final double? lat, lng;

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
          // Real coverage map, when we know where the locality is. Used to be
          // a painted decoration showing the same invented streets for every ad.
          if (lat != null && lng != null)
            LiveMapView(
              points: [
                MapPoint(
                  lat: lat!,
                  lng: lng!,
                  kind: MapPointKind.place,
                  label: addr,
                ),
              ],
              height: 120,
              // Sits inside the scrolling detail sheet.
              interactive: false,
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

// ── contact section ───────────────────────────────────────────────────────────
class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.phone});
  final String phone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
            _CBtn(icon: Icons.phone_rounded, label: l10n.callAction, iconColor: _tDp),
            const SizedBox(width: 10),
            _CBtn(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'WhatsApp',
              iconColor: const Color(0xFF25D366),
            ),
            const SizedBox(width: 10),
            _CBtn(icon: Icons.email_outlined, label: l10n.email, iconColor: _tDp),
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
    final l10n = AppLocalizations.of(context);
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
                      Text(
                        l10n.excellent,
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
          Text(
            l10n.sampleVendorReview,
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

class _OrderButton extends StatelessWidget {
  const _OrderButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _tDp,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: onTap,
        child: Text(
          AppLocalizations.of(context).placeOrder,
          style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
