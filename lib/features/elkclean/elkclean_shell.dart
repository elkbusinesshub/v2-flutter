import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/elkclean_colors.dart';
import '../../core/widgets/location_picker_sheet.dart';
import '../../data/datasources/elkclean_data.dart';

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

// 8 cleaning service tiles: (category id, label, svg asset, badge text or null)
const _cleanTiles = [
  ('cln',  'Home Cleaning',    'assets/icons/ic_home_clean.svg',  null),
  ('deep', 'Deep Cleaning',    'assets/icons/ic_deep_clean.svg',  '40% Off'),
  ('tnk',  'Water Tank',       'assets/icons/ic_water_tank.svg',  null),
  ('sof',  'Sofa & Upholstery','assets/icons/ic_sofa.svg',        null),
  ('crp',  'Carpet & Rug',     'assets/icons/ic_carpet.svg',      null),
  ('kit',  'Kitchen Clean',    'assets/icons/ic_kitchen.svg',     null),
  ('bth',  'Bathroom Clean',   'assets/icons/ic_bath.svg',        null),
  ('lndr', 'Laundry & Iron',   'assets/icons/ic_laundry.svg',     null),
];

// 3 offer cards data
const _cleanOffers = [
  (bg1: Color(0xFFF6EFDD), bg2: Color(0xFFEFE2C4), title: 'Instant Tank Refresh',    disc: 'Up to 60% off', code: 'TANK60',  time: '60',   unit: 'MINUTES', svg: 'assets/icons/ic_water_tank.svg', cat: 'Water Tank'),
  (bg1: Color(0xFFFBE6EC), bg2: Color(0xFFF6CBD8), title: 'Sofa & Carpet Revival',   disc: 'Flat 50% off',  code: 'SOFA50',  time: '90',   unit: 'MINUTES', svg: 'assets/icons/ic_sofa.svg',       cat: 'Upholstery'),
  (bg1: Color(0xFFE3F4EF), bg2: Color(0xFFC7EBE0), title: 'Sparkling Deep Clean',    disc: 'AED 70 off',    code: 'DEEP70',  time: 'Same', unit: 'DAY',     svg: 'assets/icons/ic_deep_clean.svg', cat: 'Deep Clean'),
];

// ─── Internal models ──────────────────────────────────────────────────────────

enum _S { home, cat, detail, cart, sched, addr, checkout, pay, done }

class _CartItem {
  _CartItem({required this.code, required this.name, required this.price, this.qty = 1});
  static final _empty = _CartItem(code: '', name: '', price: 0, qty: 0);
  final String code, name;
  final int price;
  int qty;
}

// ─── Shell ───────────────────────────────────────────────────────────────────

class ElkCleanShell extends StatefulWidget {
  const ElkCleanShell({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  State<ElkCleanShell> createState() => _ElkCleanShellState();
}

class _ElkCleanShellState extends State<ElkCleanShell> {
  final _hist = <_S>[_S.home];
  _S get _cur => _hist.last;

  CleanCategory _cat = cleanCategories.first;
  CleanService? _svc;
  final _cart = <_CartItem>[];
  int _dateIdx = 2;
  String _time = '10:00';
  String _pay = 'card';
  int _addrIdx = 0;
  int _paidTotal = 0;
  final _addrs = <({String tag, String line, bool isHome})>[
    (tag: 'Home', line: 'Tower 3, Apt 1204, Al Reem Island', isHome: true),
    (tag: 'Villa', line: 'Khalifa City, Villa 22 (has tank)', isHome: false),
  ];

  Future<void> _addAddress() async {
    final picked = await showLocationPicker(context, title: 'Add service address');
    if (picked == null) return;
    setState(() {
      _addrs.add((tag: picked.label, line: picked.address, isHome: false));
      _addrIdx = _addrs.length - 1;
    });
  }

  void _go(_S s) => setState(() => _hist.add(s));
  void _back() => _hist.length > 1 ? setState(() => _hist.removeLast()) : widget.onBack();

  int _qty(String code) => _cart.firstWhere((i) => i.code == code, orElse: () => _CartItem._empty).qty;

  void _add(CleanService s) => setState(() {
        final i = _cart.indexWhere((c) => c.code == s.code);
        i >= 0 ? _cart[i].qty++ : _cart.add(_CartItem(code: s.code, name: s.name, price: s.price));
      });

  void _inc(String code) => setState(() {
        final i = _cart.indexWhere((c) => c.code == code);
        if (i >= 0) { _cart[i].qty++; }
      });

  void _dec(String code) => setState(() {
        final i = _cart.indexWhere((c) => c.code == code);
        if (i < 0) return;
        _cart[i].qty > 1 ? _cart[i].qty-- : _cart.removeAt(i);
      });

  void _remove(String code) => setState(() => _cart.removeWhere((c) => c.code == code));

  int get _sub => _cart.fold(0, (s, i) => s + i.price * i.qty);
  int get _total => _cart.isEmpty ? 0 : _sub + 10; // AED 10 supply fee

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const _dows = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _times = ['08:00', '10:00', '12:00', '14:00', '16:00', '18:00'];

  late final _days = List.generate(6, (i) {
    final d = DateTime(2026, 6, 19).add(Duration(days: i));
    return (dow: i == 0 ? 'TODAY' : _dows[d.weekday - 1], num: d.day, mon: _months[d.month - 1]);
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) => _back(),
      child: Scaffold(
        backgroundColor: ElkCleanColors.porcelain,
        body: switch (_cur) {
          _S.home     => _homeScreen(),
          _S.cat      => _catScreen(),
          _S.detail   => _detailScreen(),
          _S.cart     => _cartScreen(),
          _S.sched    => _schedScreen(),
          _S.addr     => _addrScreen(),
          _S.checkout => _checkoutScreen(),
          _S.pay      => _payScreen(),
          _S.done     => _doneScreen(),
        },
      ),
    );
  }

  // ─── Home (new branded design) ────────────────────────────────────────────

  Widget _homeScreen() {
    final top = MediaQuery.of(context).padding.top;
    return ColoredBox(
      color: _hBg,
      child: SingleChildScrollView(
        child: Column(children: [
          _cleanHeader(top),
          const SizedBox(height: 20),
          // Service grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: _cleanServiceGrid(),
          ),
          const SizedBox(height: 24),
          // Top offers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Top offers', style: GoogleFonts.nunito(fontSize: 19, fontWeight: FontWeight.w900, color: _hI9, letterSpacing: -0.3)),
              Text('See all ›', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: _hT7)),
            ]),
          ),
          const SizedBox(height: 14),
          _cleanOffersCarousel(),
          const SizedBox(height: 16),
          // Trust strip
          _cleanTrustStrip(),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  // Teal gradient header with bubbles, greeting, search, centered deal text
  Widget _cleanHeader(double top) {
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
              Text('Good afternoon', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.82))),
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.location_on, color: _hYel, size: 16),
                const SizedBox(width: 6),
                Text('Al Reem Island', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3)),
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
              Text('Search "deep clean", "tank"…', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: _hI4.withValues(alpha: 0.9))),
            ]),
          ),
          const SizedBox(height: 18),
          // Centred deal text
          Text('Play & Unlock Summer Deals!', textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 23, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.4)),
          const SizedBox(height: 5),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Get Water Tank Cleaning ', style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.92))),
            Text('AED 90 off', style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w800, color: _hYel)),
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

  // 4-column grid, 8 tiles, yellow badges
  Widget _cleanServiceGrid() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('What needs cleaning?', style: GoogleFonts.nunito(fontSize: 19, fontWeight: FontWeight.w900, color: _hI9, letterSpacing: -0.3)),
        Text('${_cleanTiles.length} services', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: _hI4)),
      ]),
      const SizedBox(height: 14),
      LayoutBuilder(builder: (context, constraints) {
        const cols = 4;
        const hGap = 9.0;
        const vGap = 12.0;
        final w = (constraints.maxWidth - (cols - 1) * hGap) / cols;
        final rows = <Widget>[];
        for (int r = 0; r < ((_cleanTiles.length + cols - 1) ~/ cols); r++) {
          if (r > 0) rows.add(const SizedBox(height: vGap));
          final items = <Widget>[];
          for (int c = 0; c < cols; c++) {
            if (c > 0) items.add(const SizedBox(width: hGap));
            final idx = r * cols + c;
            if (idx < _cleanTiles.length) {
              items.add(SizedBox(width: w, child: _cleanTile(_cleanTiles[idx], w)));
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

  Widget _cleanTile((String, String, String, String?) tile, double w) {
    final (id, label, svg, badge) = tile;
    return GestureDetector(
      onTap: () {
        final cat = cleanCategories.firstWhere((c) => c.id == id, orElse: () => cleanCategories.first);
        setState(() { _cat = cat; });
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
            child: Center(child: SvgPicture.asset(svg, width: 46, height: 46)),
          ),
          if (badge != null)
            Positioned(
              top: -8, left: 0, right: 0,
              child: Center(child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _hYel,  // yellow badge (cleaning style)
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [BoxShadow(color: Color(0x2E000000), blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: Text(badge, style: GoogleFonts.nunito(fontSize: 9.5, fontWeight: FontWeight.w900, color: const Color(0xFF3A2C00))),
              )),
            ),
        ]),
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: _hI7, letterSpacing: -0.1, height: 1.2)),
      ]),
    );
  }

  // Horizontal offers carousel
  Widget _cleanOffersCarousel() {
    return SizedBox(
      height: 192,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
        itemCount: _cleanOffers.length,
        itemBuilder: (context, i) {
          final o = _cleanOffers[i];
          return Container(
            width: 270,
            margin: EdgeInsets.only(right: i < _cleanOffers.length - 1 ? 14 : 0),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [o.bg1, o.bg2], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [BoxShadow(color: Color(0x1A143228), blurRadius: 26, offset: Offset(0, 10))],
            ),
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned(right: -6, bottom: -6, child: Opacity(opacity: 0.88, child: SvgPicture.asset(o.svg, width: 96, height: 96))),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(o.title, style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900, color: _hI9, letterSpacing: -0.3), maxLines: 2),
                const SizedBox(height: 9),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(color: _hT7, borderRadius: BorderRadius.circular(999)),
                  child: Text(o.disc, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Text('Code: ', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: _hI5)),
                  Text(o.code, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: _hI9, decoration: TextDecoration.underline)),
                ]),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 6, 11, 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999), boxShadow: const [BoxShadow(color: Color(0x0A143228), blurRadius: 8, offset: Offset(0, 2))]),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    SvgPicture.asset(o.svg, width: 20, height: 20),
                    const SizedBox(width: 6),
                    Text(o.cat, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w800, color: _hI9)),
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
          (Icons.eco_outlined,       'Eco-friendly, child-safe products'),
          (Icons.verified_outlined,  'Trained & uniformed cleaners'),
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

  Widget _catScreen() {
    final services = cleanServices[_cat.id] ?? [];
    return Column(children: [
      _CleanTopBar(title: _cat.label, onBack: _back, cartCount: _cart.length, onCartTap: () => _go(_S.cart)),
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        child: Container(
          decoration: BoxDecoration(color: ElkCleanColors.teal, borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
              child: Icon(_cat.icon, size: 26, color: ElkCleanColors.citrus),
            ),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${_cat.code} · ${services.length} services', style: const TextStyle(fontSize: 11, letterSpacing: 0.1, color: Color(0xFFA9E0DC), fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(_cat.blurb, style: const TextStyle(fontSize: 14, color: Color(0xFFCFE6E4))),
            ]),
          ]),
        ),
      ),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          itemCount: services.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final s = services[i];
            final qty = _qty(s.code);
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
                  Text(s.desc, style: const TextStyle(fontSize: 13, color: ElkCleanColors.sub, height: 1.4)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.schedule, size: 13, color: ElkCleanColors.sub),
                    const SizedBox(width: 5),
                    Text(s.dur, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: ElkCleanColors.sub)),
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
                      Text('AED ${s.price}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ElkCleanColors.teal)),
                      qty > 0
                          ? _CleanStepper(qty: qty, onInc: () => _inc(s.code), onDec: () => _dec(s.code))
                          : _CleanBtn(label: '+ Add', small: true, onTap: () => _add(s)),
                    ],
                  ),
                ]),
              ),
            );
          },
        ),
      ),
      if (_cart.isNotEmpty) _CartBar(count: _cart.length, total: _total, onTap: () => _go(_S.cart)),
    ]);
  }

  // ─── Detail ────────────────────────────────────────────────────────────────

  Widget _detailScreen() {
    final s = _svc!;
    return Column(children: [
      _CleanTopBar(title: '', onBack: _back, cartCount: _cart.length, onCartTap: () => _go(_S.cart)),
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
                Positioned(right: -24, bottom: -24, child: Icon(_cat.icon, size: 150, color: Colors.white.withValues(alpha: 0.08))),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${s.code} · ${_cat.label}', style: const TextStyle(fontSize: 11, letterSpacing: 0.1, color: Color(0xFF8FD4D0), fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text(s.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, height: 1.05)),
                  const SizedBox(height: 16),
                  Row(children: [
                    _MetaTile(label: 'From', val: 'AED ${s.price}'),
                    const SizedBox(width: 24),
                    _MetaTile(label: 'Duration', val: s.dur),
                    const SizedBox(width: 24),
                    const _MetaTile(label: 'Rating', val: '4.9★'),
                  ]),
                ]),
              ]),
            ),

            // Process timeline (Water Tank only)
            if (s.steps != null) ...[
              const SizedBox(height: 20),
              const Text('HOW WE DO IT', style: TextStyle(fontSize: 10, color: ElkCleanColors.sub, letterSpacing: 0.18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              _ProcessTimeline(steps: s.steps!),
              const SizedBox(height: 16),
              // Hygiene gauge
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: ElkCleanColors.tealSoft, borderRadius: BorderRadius.circular(16)),
                child: Column(children: [
                  const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Hygiene level after service', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: ElkCleanColors.ink)),
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
                  const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('before', style: TextStyle(fontSize: 11, color: ElkCleanColors.sub)),
                    Text('after · lab-tested', style: TextStyle(fontSize: 11, color: ElkCleanColors.sub)),
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
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text('ELKclean crew', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ElkCleanColors.ink)),
                    SizedBox(width: 6),
                    Icon(Icons.verified, size: 15, color: ElkCleanColors.good),
                  ]),
                  SizedBox(height: 2),
                  Text('Uniformed · eco kit · 4.9 from 1,200+ cleans', style: TextStyle(fontSize: 13, color: ElkCleanColors.sub)),
                ])),
              ]),
            ),
          ]),
        ),
      ),
      _CleanStickyBar(
        left: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('PRICE', style: TextStyle(fontSize: 10, color: ElkCleanColors.sub, letterSpacing: 0.1)),
          Text('AED ${s.price}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ElkCleanColors.teal)),
        ]),
        right: _CleanBtn(label: '+ Add & continue', onTap: () { _add(s); _go(_S.cart); }),
      ),
    ]);
  }

  // ─── Cart ──────────────────────────────────────────────────────────────────

  Widget _cartScreen() {
    return Column(children: [
      _CleanTopBar(title: 'Your clean plan', onBack: _back),
      Expanded(
        child: _cart.isEmpty
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
                          const Text('CLEAN PLAN #ELC-3391', style: TextStyle(fontSize: 10, letterSpacing: 0.1, color: Color(0xFFA9E0DC), fontWeight: FontWeight.w700)),
                          Text('${_cart.length} item(s)', style: const TextStyle(fontSize: 11, color: Colors.white)),
                        ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: List.generate(_cart.length, (i) {
                            final item = _cart[i];
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: i < _cart.length - 1
                                  ? BoxDecoration(border: Border(bottom: BorderSide(color: ElkCleanColors.line.withValues(alpha: 0.7))))
                                  : null,
                              child: Row(children: [
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(item.code, style: const TextStyle(fontSize: 10, color: ElkCleanColors.teal, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 2),
                                  Text(item.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: ElkCleanColors.ink)),
                                  const SizedBox(height: 3),
                                  Text('AED ${item.price}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ElkCleanColors.teal)),
                                ])),
                                _CleanStepper(qty: item.qty, onInc: () => _inc(item.code), onDec: () => _dec(item.code)),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () => _remove(item.code),
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
                          Text('Add promo code', style: TextStyle(color: ElkCleanColors.sub.withValues(alpha: 0.8), fontSize: 14)),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: ElkCleanColors.line, width: 1.5)),
                      child: TextButton(onPressed: () {}, child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w700, color: ElkCleanColors.teal))),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(color: ElkCleanColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: ElkCleanColors.line, width: 1.5)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(children: [
                      _TotalRow(label: 'Subtotal', value: 'AED $_sub'),
                      _TotalRow(label: 'Eco supplies & setup', value: 'AED 10', muted: true),
                      Divider(color: ElkCleanColors.line.withValues(alpha: 0.7)),
                      _TotalRow(label: 'Total', value: 'AED $_total', bold: true),
                    ]),
                  ),
                ]),
              ),
      ),
      if (_cart.isNotEmpty)
        _CleanStickyBar(
          left: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('TOTAL', style: TextStyle(fontSize: 10, color: ElkCleanColors.sub, letterSpacing: 0.1)),
            Text('AED $_total', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ElkCleanColors.teal)),
          ]),
          right: _CleanBtn(label: 'Schedule clean →', onTap: () => _go(_S.sched)),
        ),
    ]);
  }

  // ─── Schedule ──────────────────────────────────────────────────────────────

  Widget _schedScreen() {
    return Column(children: [
      _CleanTopBar(title: 'Pick a slot', onBack: _back),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('SELECT DATE', style: TextStyle(fontSize: 10, color: ElkCleanColors.sub, letterSpacing: 0.18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _days.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final d = _days[i];
                  final on = _dateIdx == i;
                  return GestureDetector(
                    onTap: () => setState(() => _dateIdx = i),
                    child: Container(
                      width: 62,
                      decoration: BoxDecoration(
                        color: on ? ElkCleanColors.teal : ElkCleanColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: on ? ElkCleanColors.teal : ElkCleanColors.line, width: 1.5),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(d.dow, style: TextStyle(fontSize: 10, color: on ? Colors.white.withValues(alpha: 0.8) : ElkCleanColors.sub, fontWeight: FontWeight.w700)),
                        Text('${d.num}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: on ? Colors.white : ElkCleanColors.ink)),
                        Text(d.mon, style: TextStyle(fontSize: 11, color: on ? Colors.white.withValues(alpha: 0.7) : ElkCleanColors.sub)),
                      ]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 26),
            const Text('ARRIVAL WINDOW', style: TextStyle(fontSize: 10, color: ElkCleanColors.sub, letterSpacing: 0.18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 11, mainAxisSpacing: 11, childAspectRatio: 1.8),
              itemCount: _times.length,
              itemBuilder: (context, i) {
                final t = _times[i];
                final on = _time == t;
                return GestureDetector(
                  onTap: () => setState(() => _time = t),
                  child: Container(
                    decoration: BoxDecoration(
                      color: on ? ElkCleanColors.citrusSoft : ElkCleanColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: on ? ElkCleanColors.citrus : ElkCleanColors.line, width: 1.5),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(t, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: on ? ElkCleanColors.ink : ElkCleanColors.ink)),
                      Text(i == 0 ? 'Fills fast' : 'Available', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: i == 0 ? ElkCleanColors.citrus : ElkCleanColors.sub)),
                    ]),
                  ),
                );
              },
            ),
            const SizedBox(height: 22),
            Container(
              decoration: BoxDecoration(color: ElkCleanColors.lineSoft, borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.all(14),
              child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.schedule, size: 18, color: ElkCleanColors.teal),
                SizedBox(width: 10),
                Expanded(child: Text("Your crew arrives within a 2-hour window with all supplies. Live tracking link sent on the day.", style: TextStyle(fontSize: 13, color: ElkCleanColors.ink, height: 1.45))),
              ]),
            ),
          ]),
        ),
      ),
      _CleanStickyBar(right: _CleanBtn(full: true, label: 'Confirm slot →', onTap: () => _go(_S.addr))),
    ]);
  }

  // ─── Address ───────────────────────────────────────────────────────────────

  Widget _addrScreen() {
    final addrs = _addrs;
    return Column(children: [
      _CleanTopBar(title: 'Service address', onBack: _back),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
          child: Column(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 150,
                child: Stack(fit: StackFit.expand, children: [
                  Container(color: ElkCleanColors.tealDeep),
                  CustomPaint(painter: _MapGridPainter()),
                  const Center(child: Icon(Icons.location_on, size: 40, color: ElkCleanColors.citrus)),
                ]),
              ),
            ),
            const SizedBox(height: 18),
            const Align(alignment: Alignment.centerLeft, child: Text('SAVED PLACES', style: TextStyle(fontSize: 10, color: ElkCleanColors.sub, letterSpacing: 0.18, fontWeight: FontWeight.w700))),
            const SizedBox(height: 12),
            for (int i = 0; i < addrs.length; i++) ...[
              GestureDetector(
                onTap: () => setState(() => _addrIdx = i),
                child: Container(
                  decoration: BoxDecoration(
                    color: ElkCleanColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _addrIdx == i ? ElkCleanColors.teal : ElkCleanColors.line, width: 1.5),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Row(children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(color: _addrIdx == i ? ElkCleanColors.teal : ElkCleanColors.lineSoft, borderRadius: BorderRadius.circular(12)),
                      child: Icon(addrs[i].isHome ? Icons.home : Icons.location_on, size: 20, color: _addrIdx == i ? Colors.white : ElkCleanColors.teal),
                    ),
                    const SizedBox(width: 13),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(addrs[i].tag, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ElkCleanColors.ink)),
                      const SizedBox(height: 2),
                      Text(addrs[i].line, style: const TextStyle(fontSize: 13, color: ElkCleanColors.sub)),
                    ])),
                    if (_addrIdx == i) Container(width: 22, height: 22, decoration: const BoxDecoration(color: ElkCleanColors.teal, shape: BoxShape.circle), child: const Icon(Icons.check, size: 14, color: Colors.white)),
                  ]),
                ),
              ),
              const SizedBox(height: 11),
            ],
            TextButton.icon(
              onPressed: _addAddress,
              icon: const Icon(Icons.add, size: 17, color: ElkCleanColors.teal),
              label: const Text('Add new address', style: TextStyle(fontWeight: FontWeight.w700, color: ElkCleanColors.teal, fontSize: 14)),
              style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: ElkCleanColors.line, width: 1.5))),
            ),
          ]),
        ),
      ),
      _CleanStickyBar(right: _CleanBtn(full: true, label: 'Continue to checkout →', onTap: () => _go(_S.checkout))),
    ]);
  }

  // ─── Checkout ──────────────────────────────────────────────────────────────

  Widget _checkoutScreen() {
    final d = _days[_dateIdx];
    return Column(children: [
      _CleanTopBar(title: 'Review & confirm', onBack: _back),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
          child: Column(children: [
            _InfoRow(icon: Icons.calendar_today, label: 'When', value: '${d.dow}, ${d.num} ${d.mon} · $_time', onEdit: () => _go(_S.sched)),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.location_on, label: 'Where', value: 'Home · Tower 3, Apt 1204, Al Reem', onEdit: () => _go(_S.addr)),
            const SizedBox(height: 12),
            const _InfoRow(icon: Icons.person, label: 'Contact', value: 'Verified · +971 5•••• 4821'),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(color: ElkCleanColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: ElkCleanColors.line, width: 1.5)),
              clipBehavior: Clip.antiAlias,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Order summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: ElkCleanColors.ink)),
                    TextButton(onPressed: () => _go(_S.cart), child: const Text('Edit', style: TextStyle(color: ElkCleanColors.citrus, fontWeight: FontWeight.w700, fontSize: 13))),
                  ]),
                ),
                Divider(color: ElkCleanColors.line.withValues(alpha: 0.7), height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(children: [
                    ..._cart.map((i) => _TotalRow(label: '${i.name} ×${i.qty}', value: 'AED ${i.price * i.qty}')),
                    _TotalRow(label: 'Eco supplies & setup', value: 'AED 10', muted: true),
                    Divider(color: ElkCleanColors.line.withValues(alpha: 0.7)),
                    _TotalRow(label: 'Total to pay', value: 'AED $_total', bold: true),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(color: ElkCleanColors.citrusSoft, borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.all(14),
              child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.shield, size: 20, color: ElkCleanColors.citrus),
                SizedBox(width: 10),
                Expanded(child: Text("Not happy? We re-clean free within 48 hours. Free cancellation up to 2h before.", style: TextStyle(fontSize: 13, color: ElkCleanColors.ink, height: 1.4))),
              ]),
            ),
          ]),
        ),
      ),
      _CleanStickyBar(
        left: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('TOTAL', style: TextStyle(fontSize: 10, color: ElkCleanColors.sub, letterSpacing: 0.1)),
          Text('AED $_total', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ElkCleanColors.teal)),
        ]),
        right: _CleanBtn(label: 'Proceed to pay →', onTap: () => _go(_S.pay)),
      ),
    ]);
  }

  // ─── Payment ───────────────────────────────────────────────────────────────

  Widget _payScreen() {
    const methods = [
      (id: 'card',   icon: Icons.credit_card,           label: 'Credit / Debit card', sub: 'Visa, Mastercard, Amex'),
      (id: 'apple',  icon: Icons.phone_iphone,           label: 'Apple Pay',           sub: 'One-tap secure checkout'),
      (id: 'wallet', icon: Icons.account_balance_wallet, label: 'ELK Wallet',          sub: 'Balance AED 0.00'),
    ];
    return Column(children: [
      _CleanTopBar(title: 'Payment', onBack: _back),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('CHOOSE METHOD', style: TextStyle(fontSize: 10, color: ElkCleanColors.sub, letterSpacing: 0.18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            for (final m in methods) ...[
              GestureDetector(
                onTap: () => setState(() => _pay = m.id),
                child: Container(
                  decoration: BoxDecoration(color: ElkCleanColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _pay == m.id ? ElkCleanColors.teal : ElkCleanColors.line, width: 1.5)),
                  padding: const EdgeInsets.all(15),
                  child: Row(children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(color: _pay == m.id ? ElkCleanColors.teal : ElkCleanColors.lineSoft, borderRadius: BorderRadius.circular(12)),
                      child: Icon(m.icon, size: 20, color: _pay == m.id ? Colors.white : ElkCleanColors.teal),
                    ),
                    const SizedBox(width: 13),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(m.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ElkCleanColors.ink)),
                      Text(m.sub, style: const TextStyle(fontSize: 12.5, color: ElkCleanColors.sub)),
                    ])),
                    Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _pay == m.id ? ElkCleanColors.teal : ElkCleanColors.line, width: 2)),
                      child: _pay == m.id ? const Center(child: CircleAvatar(radius: 5, backgroundColor: ElkCleanColors.teal)) : null,
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 11),
            ],
            if (_pay == 'card')
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
                      const Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('ELKCLEAN', style: TextStyle(fontSize: 10, color: Color(0xFF8FD4D0), letterSpacing: 0.1, fontWeight: FontWeight.w700)),
                        Text('•••• •••• •••• 4821', style: TextStyle(fontSize: 17, color: Colors.white, letterSpacing: 0.12)),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('A. RESIDENT', style: TextStyle(fontSize: 11, color: Colors.white)),
                          Text('06 / 28', style: TextStyle(fontSize: 11, color: Colors.white)),
                        ]),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  const _FieldBox(label: 'CARD NUMBER', value: '4242 4242 4242 4821'),
                  const SizedBox(height: 12),
                  const Row(children: [
                    Expanded(child: _FieldBox(label: 'EXPIRY', value: '06 / 28')),
                    SizedBox(width: 12),
                    Expanded(child: _FieldBox(label: 'CVV', value: '•••')),
                  ]),
                  const SizedBox(height: 12),
                  const _FieldBox(label: 'NAME ON CARD', value: 'A. Resident'),
                  const SizedBox(height: 14),
                  Row(children: [
                    Container(width: 20, height: 20, decoration: BoxDecoration(color: ElkCleanColors.teal, borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.check, size: 13, color: Colors.white)),
                    const SizedBox(width: 9),
                    const Text('Save card for faster checkout', style: TextStyle(fontSize: 13.5, color: ElkCleanColors.ink)),
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
      _CleanStickyBar(right: _CleanBtn(full: true, citrus: true, label: 'Pay AED $_total securely', onTap: () {
        setState(() { _paidTotal = _total; _cart.clear(); });
        _go(_S.done);
      })),
    ]);
  }

  // ─── Done ──────────────────────────────────────────────────────────────────

  Widget _doneScreen() {
    final d = _days[_dateIdx];
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
              const Text('CLEAN REPORT #ELC-3391', style: TextStyle(fontSize: 10, color: ElkCleanColors.citrus, letterSpacing: 0.1, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _TotalRow(label: 'When', value: '${d.dow} ${d.num} ${d.mon}, $_time'),
              const SizedBox(height: 4),
              Divider(color: ElkCleanColors.line.withValues(alpha: 0.7)),
              _TotalRow(label: 'Paid', value: 'AED $_paidTotal', bold: true),
            ]),
            Positioned(
              top: 0, right: 0,
              child: Transform.rotate(
                angle: -0.21,
                child: Container(
                  decoration: BoxDecoration(border: Border.all(color: ElkCleanColors.good, width: 2), borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: const Text('PAID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: ElkCleanColors.good, letterSpacing: 0.1)),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 22),
        _CleanBtn(full: true, citrus: true, label: 'Track my clean', onTap: widget.onBack),
        const SizedBox(height: 14),
        TextButton(
          onPressed: widget.onBack,
          child: const Text('Back to home', style: TextStyle(color: Color(0xFFCFE6E4), fontSize: 14, fontWeight: FontWeight.w600)),
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
          Text('$count service${count > 1 ? 's' : ''} added', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          const Spacer(),
          Text('AED $total', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ElkCleanColors.citrus)),
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
          const Text('No services yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ElkCleanColors.ink)),
          const SizedBox(height: 6),
          const Text('Browse cleaning services and build your plan.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: ElkCleanColors.sub)),
          const SizedBox(height: 18),
          _CleanBtn(label: 'Browse services', onTap: onBrowse),
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
          TextButton(onPressed: onEdit, child: const Text('Edit', style: TextStyle(color: ElkCleanColors.citrus, fontWeight: FontWeight.w700, fontSize: 13))),
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

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.12)..strokeWidth = 1;
    const step = 26.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
