import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/elkrep_colors.dart';
import '../../core/widgets/location_picker_sheet.dart';
import '../../data/datasources/elkrep_data.dart';

// ─── Home-screen design tokens ───────────────────────────────────────────────
const _rBg   = Color(0xFFF1F4F0);
const _rTile = Color(0xFFFBFCFA);
const _rLine = Color(0xFFE6EBE5);
const _rDk7  = Color(0xFF1C4A3C);
const _rDk9  = Color(0xFF0E261F);
const _rTDk  = Color(0xFF0F6E60);
const _rTBr  = Color(0xFF3FD2B4);
const _rYel  = Color(0xFFF6CE19);
const _rYDk  = Color(0xFFE6B500);
const _rI9   = Color(0xFF16271F);
const _rI7   = Color(0xFF2A3B31);
const _rI5   = Color(0xFF5E6E64);
const _rI4   = Color(0xFF8C9890);

// 6 trade tiles: (repairCategory id, display label, SVG asset path)
const _trades = [
  ('ac',  'AC & Cooling',  'assets/icons/ic_ac.svg'),
  ('plm', 'Plumbing',      'assets/icons/ic_plumb.svg'),
  ('elc', 'Electrical',    'assets/icons/ic_elec.svg'),
  ('cpt', 'Carpentry',     'assets/icons/ic_carpentry.svg'),
  ('pnt', 'Painting',      'assets/icons/ic_paint.svg'),
  ('gen', 'Handyman',      'assets/icons/ic_handyman.svg'),
];

// 3 offer cards
const _repOffers = [
  (bg1: Color(0xFFFEF6D8), bg2: Color(0xFFF7E29F), title: 'Instant AC Refresh',  disc: 'Up to 60% off', code: 'AC60',     time: '60',   unit: 'MINUTES', svg: 'assets/icons/ic_ac.svg',        cat: 'AC & Cooling'),
  (bg1: Color(0xFFE2EEF4), bg2: Color(0xFFC7E0EC), title: 'Leak Fix Express',     disc: 'Flat 50% off',  code: 'LEAK50',   time: '90',   unit: 'MINUTES', svg: 'assets/icons/ic_plumb.svg',     cat: 'Plumbing'),
  (bg1: Color(0xFFE3F4EF), bg2: Color(0xFFC7EBE0), title: 'Full Home Repaint',    disc: 'AED 120 off',   code: 'PAINT120', time: 'Same', unit: 'DAY',     svg: 'assets/icons/ic_paint.svg',     cat: 'Painting'),
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

class ElkRepairShell extends StatefulWidget {
  const ElkRepairShell({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  State<ElkRepairShell> createState() => _ElkRepairShellState();
}

class _ElkRepairShellState extends State<ElkRepairShell> {
  final _hist = <_S>[_S.home];
  _S get _cur => _hist.last;

  RepairCategory _cat = repairCategories.first;
  RepairService? _svc;
  final _cart = <_CartItem>[];
  int _dateIdx = 2;
  String _time = '10:00';
  String _pay = 'card';
  int _addrIdx = 0;
  final _addrs = <({String tag, String line, bool isHome})>[
    (tag: 'Home', line: 'Tower 3, Apt 1204, Al Reem Island', isHome: true),
    (tag: 'Office', line: 'Marina Plaza, Office 18, Abu Dhabi', isHome: false),
  ];

  Future<void> _addAddress() async {
    final picked = await showLocationPicker(context, title: 'Add service address');
    if (picked == null) return;
    setState(() {
      _addrs.add((tag: picked.label, line: picked.address, isHome: false));
      _addrIdx = _addrs.length - 1;
    });
  }
  int _paidTotal = 0;

  void _go(_S s) => setState(() => _hist.add(s));
  void _back() => _hist.length > 1 ? setState(() => _hist.removeLast()) : widget.onBack();

  int _qty(String code) => _cart.firstWhere((i) => i.code == code, orElse: () => _CartItem._empty).qty;

  void _add(RepairService s) => setState(() {
        final i = _cart.indexWhere((c) => c.code == s.code);
        i >= 0 ? _cart[i].qty++ : _cart.add(_CartItem(code: s.code, name: s.name, price: s.price));
      });

  void _inc(String code) => setState(() {
        final i = _cart.indexWhere((c) => c.code == code);
        if (i >= 0) _cart[i].qty++;
      });

  void _dec(String code) => setState(() {
        final i = _cart.indexWhere((c) => c.code == code);
        if (i < 0) return;
        _cart[i].qty > 1 ? _cart[i].qty-- : _cart.removeAt(i);
      });

  void _remove(String code) => setState(() => _cart.removeWhere((c) => c.code == code));

  int get _sub => _cart.fold(0, (s, i) => s + i.price * i.qty);
  int get _total => _cart.isEmpty ? 0 : _sub + 15;

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
        backgroundColor: ElkRepColors.bone,
        body: switch (_cur) {
          _S.home    => _homeScreen(),
          _S.cat     => _catScreen(),
          _S.detail  => _detailScreen(),
          _S.cart    => _cartScreen(),
          _S.sched   => _schedScreen(),
          _S.addr    => _addrScreen(),
          _S.checkout => _checkoutScreen(),
          _S.pay     => _payScreen(),
          _S.done    => _doneScreen(),
        },
      ),
    );
  }

  // ─── Home ──────────────────────────────────────────────────────────────────

  // ─── Home (new branded design) ────────────────────────────────────────────

  Widget _homeScreen() {
    final top = MediaQuery.of(context).padding.top;
    return ColoredBox(
      color: _rBg,
      child: SingleChildScrollView(
        child: Column(children: [
          _repHeader(top),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: _repTradeGrid(),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Top offers', style: GoogleFonts.nunito(fontSize: 19, fontWeight: FontWeight.w900, color: _rI9, letterSpacing: -0.3)),
              Text('See all ›', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: _rTDk)),
            ]),
          ),
          const SizedBox(height: 14),
          _repOffersCarousel(),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  // Dark gradient header with ELK logo, search, deal promo, rounded sheet overlay
  Widget _repHeader(double top) {
    return Stack(children: [
      Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(22, top + 2, 22, 52), // 30px visible + 22px under sheet
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.88, -0.5),
            end: Alignment(-0.3, 1.2),
            colors: [_rDk7, _rDk9],
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ELK logo + bell
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('EL', style: GoogleFonts.nunito(fontSize: 30, fontWeight: FontWeight.w900, color: _rTBr, letterSpacing: -1.5, height: 0.85)),
              Padding(
                padding: const EdgeInsets.only(left: 3, right: 3, bottom: 3),
                child: Container(width: 7, height: 7, decoration: BoxDecoration(color: _rTBr, borderRadius: BorderRadius.circular(2))),
              ),
              Text('K', style: GoogleFonts.nunito(fontSize: 30, fontWeight: FontWeight.w900, color: _rYel, letterSpacing: -1.5, height: 0.85)),
            ]),
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Stack(clipBehavior: Clip.none, children: [
                const Center(child: Icon(Icons.notifications_outlined, color: Colors.white, size: 20)),
                Positioned(top: 10, right: 11, child: Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: _rYel, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF163E33), width: 2)),
                )),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          // Greeting + location
          Text('Good afternoon', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.78))),
          const SizedBox(height: 2),
          Row(children: [
            const Icon(Icons.location_on, color: _rYel, size: 16),
            const SizedBox(width: 6),
            Text('Al Reem Island', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3)),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
          ]),
          const SizedBox(height: 14),
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: const Color(0xFF08201A).withValues(alpha: 0.22), blurRadius: 24, offset: const Offset(0, 10))],
            ),
            child: Row(children: [
              const Icon(Icons.search_rounded, color: _rTDk, size: 18),
              const SizedBox(width: 11),
              Text('Search "AC service", "leak"…', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: _rI4.withValues(alpha: 0.9))),
            ]),
          ),
          const SizedBox(height: 18),
          // Deal promo
          Text('SUMMER READY', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w800, color: _rYel, letterSpacing: 1.2)),
          const SizedBox(height: 6),
          Text('AC Service\nfrom AED 89', style: GoogleFonts.nunito(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.6, height: 1.05)),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () { setState(() { _cat = repairCategories.first; }); _go(_S.cat); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              decoration: BoxDecoration(
                color: _rYel,
                borderRadius: BorderRadius.circular(13),
                boxShadow: const [BoxShadow(color: Color(0x6BD6B40C), blurRadius: 18, offset: Offset(0, 8))],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Book now', style: GoogleFonts.nunito(fontSize: 14.5, fontWeight: FontWeight.w900, color: const Color(0xFF3A2C00))),
                const SizedBox(width: 7),
                const Icon(Icons.arrow_forward_rounded, size: 15, color: Color(0xFF3A2C00)),
              ]),
            ),
          ),
        ]),
      ),
      // Decorative sparks
      Positioned(top: top + 128, left: 58, child: Text('✦', style: TextStyle(fontSize: 14, color: _rYel.withValues(alpha: 0.6)))),
      Positioned(top: top + 184, left: 182, child: Text('✦', style: TextStyle(fontSize: 10, color: _rYel.withValues(alpha: 0.5)))),
      // Sheet rounded-top overlay (covers bottom 28px → creates the sliding-sheet look)
      Positioned(bottom: 0, left: 0, right: 0, child: Container(
        height: 28,
        decoration: const BoxDecoration(
          color: _rBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      )),
    ]);
  }

  // 4-column trade grid (6 tiles: AC, Plumbing, Electrical, Carpentry, Painting, Handyman)
  Widget _repTradeGrid() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('What needs fixing?', style: GoogleFonts.nunito(fontSize: 19, fontWeight: FontWeight.w900, color: _rI9, letterSpacing: -0.3)),
        Text('${_trades.length} trades', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: _rI4)),
      ]),
      const SizedBox(height: 14),
      LayoutBuilder(builder: (context, constraints) {
        const cols = 4;
        const hGap = 9.0;
        const vGap = 12.0;
        final tileW = (constraints.maxWidth - (cols - 1) * hGap) / cols;
        final rows = <Widget>[];
        for (int r = 0; r < ((_trades.length + cols - 1) ~/ cols); r++) {
          if (r > 0) rows.add(const SizedBox(height: vGap));
          final items = <Widget>[];
          for (int c = 0; c < cols; c++) {
            if (c > 0) items.add(const SizedBox(width: hGap));
            final idx = r * cols + c;
            if (idx < _trades.length) {
              items.add(SizedBox(width: tileW, child: _repTradeTile(_trades[idx], tileW)));
            } else {
              items.add(SizedBox(width: tileW));
            }
          }
          rows.add(Row(children: items));
        }
        return Column(children: rows);
      }),
    ]);
  }

  Widget _repTradeTile((String, String, String) trade, double w) {
    final (id, label, svg) = trade;
    return GestureDetector(
      onTap: () {
        final cat = repairCategories.firstWhere((c) => c.id == id, orElse: () => repairCategories.first);
        setState(() { _cat = cat; });
        _go(_S.cat);
      },
      child: Container(
        height: w + 38,
        decoration: BoxDecoration(
          color: _rTile,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _rLine, width: 1.5),
          boxShadow: const [BoxShadow(color: Color(0x0A143218), blurRadius: 8, offset: Offset(0, 2))],
        ),
        padding: const EdgeInsets.fromLTRB(6, 12, 6, 10),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SvgPicture.asset(svg, width: 46, height: 46),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: _rI7, letterSpacing: -0.1, height: 1.2)),
        ]),
      ),
    );
  }

  // Horizontal offers carousel
  Widget _repOffersCarousel() {
    return SizedBox(
      height: 192,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
        itemCount: _repOffers.length,
        itemBuilder: (context, i) {
          final o = _repOffers[i];
          return Container(
            width: 270,
            margin: EdgeInsets.only(right: i < _repOffers.length - 1 ? 14 : 0),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [o.bg1, o.bg2], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [BoxShadow(color: Color(0x1A143228), blurRadius: 26, offset: Offset(0, 10))],
            ),
            child: Stack(clipBehavior: Clip.none, children: [
              // Decorative SVG art at bottom-right
              Positioned(right: -6, bottom: -6, child: Opacity(
                opacity: 0.88,
                child: SvgPicture.asset(o.svg, width: 96, height: 96),
              )),
              // Content
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(o.title, style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900, color: _rI9, letterSpacing: -0.3), maxLines: 2),
                const SizedBox(height: 9),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(color: _rTDk, borderRadius: BorderRadius.circular(999)),
                  child: Text(o.disc, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Text('Code: ', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: _rI5)),
                  Text(o.code, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: _rI9, decoration: TextDecoration.underline)),
                ]),
                const Spacer(),
                // Category tag pill
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 6, 11, 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999), boxShadow: const [BoxShadow(color: Color(0x0A143228), blurRadius: 8, offset: Offset(0, 2))]),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    SvgPicture.asset(o.svg, width: 20, height: 20),
                    const SizedBox(width: 6),
                    Text(o.cat, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w800, color: _rI9)),
                  ]),
                ),
              ]),
              // Time badge circle (right side)
              Positioned(right: 16, top: 62, child: Container(
                width: 62, height: 62,
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 14, offset: Offset(0, 6))]),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('⚡', style: TextStyle(fontSize: 12, color: _rYDk)),
                  Text(o.time, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900, color: _rTDk, height: 1)),
                  Text(o.unit, style: GoogleFonts.plusJakartaSans(fontSize: 7, fontWeight: FontWeight.w800, color: _rI4, letterSpacing: 0.2)),
                ]),
              )),
            ]),
          );
        },
      ),
    );
  }

  // ─── Category ──────────────────────────────────────────────────────────────

  Widget _catScreen() {
    final services = repairServices[_cat.id] ?? [];
    return Column(children: [
      _TopBar(title: _cat.label, onBack: _back, cartCount: _cart.length, onCartTap: () => _go(_S.cart)),
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        child: Container(
          decoration: BoxDecoration(color: ElkRepColors.pine, borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
              child: Icon(_cat.icon, size: 26, color: ElkRepColors.amber),
            ),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${_cat.code} · ${services.length} services', style: const TextStyle(fontSize: 11, letterSpacing: 0.1, color: Color(0xFF9DD0B6), fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(_cat.blurb, style: const TextStyle(fontSize: 14, color: Color(0xFFD8E2DA))),
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
                  color: ElkRepColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ElkRepColors.line, width: 1.5),
                ),
                padding: const EdgeInsets.all(15),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(s.code, style: const TextStyle(fontSize: 11, color: ElkRepColors.amber, fontWeight: FontWeight.w700)),
                    if (s.tag != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: ElkRepColors.amberSoft, borderRadius: BorderRadius.circular(20)),
                        child: Text(s.tag!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: ElkRepColors.pine)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 6),
                  Text(s.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ElkRepColors.ink)),
                  const SizedBox(height: 4),
                  Text(s.desc, style: const TextStyle(fontSize: 13, color: ElkRepColors.sub, height: 1.4)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.schedule, size: 13, color: ElkRepColors.sub),
                    const SizedBox(width: 5),
                    Text(s.dur, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: ElkRepColors.sub)),
                  ]),
                  const SizedBox(height: 12),
                  const Divider(color: ElkRepColors.line, thickness: 1, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('AED ${s.price}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ElkRepColors.pine)),
                      qty > 0
                          ? GestureDetector(
                              onTap: () {},
                              child: _Stepper(qty: qty, onInc: () => _inc(s.code), onDec: () => _dec(s.code)),
                            )
                          : _RepBtn(label: '+ Add', small: true, onTap: () => _add(s)),
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
      _TopBar(title: '', onBack: _back, cartCount: _cart.length, onCartTap: () => _go(_S.cart)),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Hero card
            Container(
              decoration: BoxDecoration(color: ElkRepColors.pineDeep, borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.all(24),
              clipBehavior: Clip.antiAlias,
              child: Stack(children: [
                Positioned(right: -24, bottom: -24, child: Icon(_cat.icon, size: 150, color: Colors.white.withValues(alpha: 0.08))),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${s.code} · ${_cat.label}', style: const TextStyle(fontSize: 11, letterSpacing: 0.1, color: ElkRepColors.amber, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text(s.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, height: 1.05)),
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
            const SizedBox(height: 20),
            const Text("What's included", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ElkRepColors.ink)),
            const SizedBox(height: 12),
            for (final item in [
              'On-site inspection & diagnosis',
              'Labour by certified technician',
              'Standard parts & consumables',
              'Clean-up after the job',
              '30-day workmanship warranty',
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(color: ElkRepColors.amberSoft, borderRadius: BorderRadius.circular(7)),
                    child: const Icon(Icons.check, size: 14, color: ElkRepColors.amber),
                  ),
                  const SizedBox(width: 10),
                  Text(item, style: const TextStyle(fontSize: 14, color: ElkRepColors.ink)),
                ]),
              ),
            const SizedBox(height: 16),
            // Technician
            Container(
              decoration: BoxDecoration(color: ElkRepColors.lineSoft, borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(color: ElkRepColors.pine, borderRadius: BorderRadius.circular(14)),
                  child: const Center(child: Text('RK', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white))),
                ),
                const SizedBox(width: 13),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text('Top-rated crew', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ElkRepColors.ink)),
                    SizedBox(width: 6),
                    Icon(Icons.verified, size: 15, color: ElkRepColors.good),
                  ]),
                  SizedBox(height: 2),
                  Text('Assigned after booking · avg 4.9 from 800+ jobs', style: TextStyle(fontSize: 13, color: ElkRepColors.sub)),
                ])),
              ]),
            ),
          ]),
        ),
      ),
      _StickyBar(
        left: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('PRICE', style: TextStyle(fontSize: 10, color: ElkRepColors.sub, letterSpacing: 0.1)),
          Text('AED ${s.price}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ElkRepColors.pine)),
        ]),
        right: _RepBtn(label: '+ Add & continue', onTap: () { _add(s); _go(_S.cart); }),
      ),
    ]);
  }

  // ─── Cart ──────────────────────────────────────────────────────────────────

  Widget _cartScreen() {
    return Column(children: [
      _TopBar(title: 'Your work order', onBack: _back),
      Expanded(
        child: _cart.isEmpty
            ? _EmptyCart(onBrowse: () { setState(() { _hist.clear(); _hist.add(_S.home); }); })
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                child: Column(children: [
                  // Ticket
                  Container(
                    decoration: BoxDecoration(
                      color: ElkRepColors.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: ElkRepColors.line, width: 1.5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(children: [
                      Container(
                        color: ElkRepColors.pine,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text('WORK ORDER #ELK-2487', style: TextStyle(fontSize: 10, letterSpacing: 0.1, color: Color(0xFF9DD0B6), fontWeight: FontWeight.w700)),
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
                                  ? BoxDecoration(border: Border(bottom: BorderSide(color: ElkRepColors.line.withValues(alpha: 0.7))))
                                  : null,
                              child: Row(children: [
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(item.code, style: const TextStyle(fontSize: 10, color: ElkRepColors.amber, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 2),
                                  Text(item.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: ElkRepColors.ink)),
                                  const SizedBox(height: 3),
                                  Text('AED ${item.price}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ElkRepColors.pine)),
                                ])),
                                _Stepper(qty: item.qty, onInc: () => _inc(item.code), onDec: () => _dec(item.code)),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () => _remove(item.code),
                                  child: const Icon(Icons.delete_outline, size: 18, color: ElkRepColors.sub),
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
                        decoration: BoxDecoration(color: ElkRepColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: ElkRepColors.line, width: 1.5)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        child: Row(children: [
                          const Icon(Icons.auto_awesome, size: 16, color: ElkRepColors.amber),
                          const SizedBox(width: 8),
                          Text('Add promo code', style: TextStyle(color: ElkRepColors.sub.withValues(alpha: 0.8), fontSize: 14)),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: ElkRepColors.line, width: 1.5)),
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w700, color: ElkRepColors.pine)),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  // Totals
                  Container(
                    decoration: BoxDecoration(color: ElkRepColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: ElkRepColors.line, width: 1.5)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(children: [
                      _TotalRow(label: 'Subtotal', value: 'AED $_sub'),
                      _TotalRow(label: 'Visit & inspection fee', value: 'AED 15', muted: true),
                      Divider(color: ElkRepColors.line.withValues(alpha: 0.7)),
                      _TotalRow(label: 'Total', value: 'AED $_total', bold: true),
                    ]),
                  ),
                ]),
              ),
      ),
      if (_cart.isNotEmpty)
        _StickyBar(
          left: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('TOTAL', style: TextStyle(fontSize: 10, color: ElkRepColors.sub, letterSpacing: 0.1)),
            Text('AED $_total', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ElkRepColors.pine)),
          ]),
          right: _RepBtn(label: 'Schedule visit →', onTap: () => _go(_S.sched)),
        ),
    ]);
  }

  // ─── Schedule ──────────────────────────────────────────────────────────────

  Widget _schedScreen() {
    return Column(children: [
      _TopBar(title: 'Pick a slot', onBack: _back),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('SELECT DATE', style: TextStyle(fontSize: 10, color: ElkRepColors.sub, letterSpacing: 0.18, fontWeight: FontWeight.w700)),
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
                        color: on ? ElkRepColors.pine : ElkRepColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: on ? ElkRepColors.pine : ElkRepColors.line, width: 1.5),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(d.dow, style: TextStyle(fontSize: 10, color: on ? Colors.white.withValues(alpha: 0.8) : ElkRepColors.sub, fontWeight: FontWeight.w700)),
                        Text('${d.num}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: on ? Colors.white : ElkRepColors.ink)),
                        Text(d.mon, style: TextStyle(fontSize: 11, color: on ? Colors.white.withValues(alpha: 0.7) : ElkRepColors.sub)),
                      ]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 26),
            const Text('ARRIVAL WINDOW', style: TextStyle(fontSize: 10, color: ElkRepColors.sub, letterSpacing: 0.18, fontWeight: FontWeight.w700)),
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
                      color: on ? ElkRepColors.amberSoft : ElkRepColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: on ? ElkRepColors.amber : ElkRepColors.line, width: 1.5),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(t, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: on ? ElkRepColors.pine : ElkRepColors.ink)),
                      Text(i == 0 ? 'Fills fast' : 'Available', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: i == 0 ? ElkRepColors.amber : ElkRepColors.sub)),
                    ]),
                  ),
                );
              },
            ),
            const SizedBox(height: 22),
            Container(
              decoration: BoxDecoration(color: ElkRepColors.lineSoft, borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.all(14),
              child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.schedule, size: 18, color: ElkRepColors.pine),
                SizedBox(width: 10),
                Expanded(child: Text("Your technician arrives within a 2-hour window. You'll get a live tracking link on the day.", style: TextStyle(fontSize: 13, color: ElkRepColors.ink, height: 1.45))),
              ]),
            ),
          ]),
        ),
      ),
      _StickyBar(right: _RepBtn(full: true, label: 'Confirm slot →', onTap: () => _go(_S.addr))),
    ]);
  }

  // ─── Address ───────────────────────────────────────────────────────────────

  Widget _addrScreen() {
    final addrs = _addrs;
    return Column(children: [
      _TopBar(title: 'Service address', onBack: _back),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
          child: Column(children: [
            // Map mock
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 150,
                child: Stack(fit: StackFit.expand, children: [
                  Container(color: ElkRepColors.pineDeep),
                  CustomPaint(painter: _MapGridPainter()),
                  const Center(child: Icon(Icons.location_on, size: 40, color: ElkRepColors.amber)),
                ]),
              ),
            ),
            const SizedBox(height: 18),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('SAVED PLACES', style: TextStyle(fontSize: 10, color: ElkRepColors.sub, letterSpacing: 0.18, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 12),
            for (int i = 0; i < addrs.length; i++) ...[
              GestureDetector(
                onTap: () => setState(() => _addrIdx = i),
                child: Container(
                  decoration: BoxDecoration(
                    color: ElkRepColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _addrIdx == i ? ElkRepColors.pine : ElkRepColors.line, width: 1.5),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Row(children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: _addrIdx == i ? ElkRepColors.pine : ElkRepColors.lineSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(addrs[i].isHome ? Icons.home : Icons.location_on, size: 20, color: _addrIdx == i ? Colors.white : ElkRepColors.pine),
                    ),
                    const SizedBox(width: 13),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(addrs[i].tag, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ElkRepColors.ink)),
                      const SizedBox(height: 2),
                      Text(addrs[i].line, style: const TextStyle(fontSize: 13, color: ElkRepColors.sub)),
                    ])),
                    if (_addrIdx == i)
                      Container(
                        width: 22, height: 22,
                        decoration: const BoxDecoration(color: ElkRepColors.pine, shape: BoxShape.circle),
                        child: const Icon(Icons.check, size: 14, color: Colors.white),
                      ),
                  ]),
                ),
              ),
              const SizedBox(height: 11),
            ],
            TextButton.icon(
              onPressed: _addAddress,
              icon: const Icon(Icons.add, size: 17, color: ElkRepColors.pine),
              label: const Text('Add new address', style: TextStyle(fontWeight: FontWeight.w700, color: ElkRepColors.pine, fontSize: 14)),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: ElkRepColors.line, width: 1.5)),
              ),
            ),
          ]),
        ),
      ),
      _StickyBar(right: _RepBtn(full: true, dark: true, label: 'Continue to checkout →', onTap: () => _go(_S.checkout))),
    ]);
  }

  // ─── Checkout ──────────────────────────────────────────────────────────────

  Widget _checkoutScreen() {
    final d = _days[_dateIdx];
    return Column(children: [
      _TopBar(title: 'Review & confirm', onBack: _back),
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
              decoration: BoxDecoration(color: ElkRepColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: ElkRepColors.line, width: 1.5)),
              clipBehavior: Clip.antiAlias,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Order summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: ElkRepColors.ink)),
                      TextButton(onPressed: () => _go(_S.cart), child: const Text('Edit', style: TextStyle(color: ElkRepColors.amber, fontWeight: FontWeight.w700, fontSize: 13))),
                    ],
                  ),
                ),
                Divider(color: ElkRepColors.line.withValues(alpha: 0.7), height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(children: [
                    ..._cart.map((i) => _TotalRow(label: '${i.name} ×${i.qty}', value: 'AED ${i.price * i.qty}')),
                    _TotalRow(label: 'Visit & inspection fee', value: 'AED 15', muted: true),
                    Divider(color: ElkRepColors.line.withValues(alpha: 0.7)),
                    _TotalRow(label: 'Total to pay', value: 'AED $_total', bold: true),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(color: ElkRepColors.amberSoft, borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.all(14),
              child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.shield, size: 20, color: ElkRepColors.amber),
                SizedBox(width: 10),
                Expanded(child: Text("You're only charged after the job is confirmed complete. Free cancellation up to 2h before.", style: TextStyle(fontSize: 13, color: ElkRepColors.pine, height: 1.4))),
              ]),
            ),
          ]),
        ),
      ),
      _StickyBar(
        left: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('TOTAL', style: TextStyle(fontSize: 10, color: ElkRepColors.sub, letterSpacing: 0.1)),
          Text('AED $_total', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ElkRepColors.pine)),
        ]),
        right: _RepBtn(label: 'Proceed to pay →', onTap: () => _go(_S.pay)),
      ),
    ]);
  }

  // ─── Payment ───────────────────────────────────────────────────────────────

  Widget _payScreen() {
    const methods = [
      (id: 'card',   icon: Icons.credit_card,            label: 'Credit / Debit card', sub: 'Visa, Mastercard, Amex'),
      (id: 'apple',  icon: Icons.phone_iphone,            label: 'Apple Pay',           sub: 'One-tap secure checkout'),
      (id: 'wallet', icon: Icons.account_balance_wallet,  label: 'ELK Wallet',          sub: 'Balance AED 0.00'),
    ];
    return Column(children: [
      _TopBar(title: 'Payment', onBack: _back),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('CHOOSE METHOD', style: TextStyle(fontSize: 10, color: ElkRepColors.sub, letterSpacing: 0.18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            for (final m in methods) ...[
              GestureDetector(
                onTap: () => setState(() => _pay = m.id),
                child: Container(
                  decoration: BoxDecoration(
                    color: ElkRepColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _pay == m.id ? ElkRepColors.pine : ElkRepColors.line, width: 1.5),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Row(children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(color: _pay == m.id ? ElkRepColors.pine : ElkRepColors.lineSoft, borderRadius: BorderRadius.circular(12)),
                      child: Icon(m.icon, size: 20, color: _pay == m.id ? Colors.white : ElkRepColors.pine),
                    ),
                    const SizedBox(width: 13),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(m.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ElkRepColors.ink)),
                      Text(m.sub, style: const TextStyle(fontSize: 12.5, color: ElkRepColors.sub)),
                    ])),
                    Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _pay == m.id ? ElkRepColors.pine : ElkRepColors.line, width: 2)),
                      child: _pay == m.id ? const Center(child: CircleAvatar(radius: 5, backgroundColor: ElkRepColors.pine)) : null,
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 11),
            ],
            if (_pay == 'card')
              Container(
                decoration: BoxDecoration(color: ElkRepColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: ElkRepColors.line, width: 1.5)),
                padding: const EdgeInsets.all(18),
                child: Column(children: [
                  // Card preview
                  Container(
                    height: 110,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF14271F), Color(0xFF1E3D30)]),
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ELK REPAIR', style: TextStyle(fontSize: 10, color: Color(0xFF9DD0B6), letterSpacing: 0.1, fontWeight: FontWeight.w700)),
                        Text('•••• •••• •••• 4821', style: TextStyle(fontSize: 17, color: Colors.white, letterSpacing: 0.12)),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('A. RESIDENT', style: TextStyle(fontSize: 11, color: Colors.white)),
                          Text('06 / 28', style: TextStyle(fontSize: 11, color: Colors.white)),
                        ]),
                      ],
                    ),
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
                    Container(width: 20, height: 20, decoration: BoxDecoration(color: ElkRepColors.pine, borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.check, size: 13, color: Colors.white)),
                    const SizedBox(width: 9),
                    const Text('Save card for faster checkout', style: TextStyle(fontSize: 13.5, color: ElkRepColors.ink)),
                  ]),
                ]),
              ),
            const SizedBox(height: 16),
            const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.shield, size: 15, color: ElkRepColors.sub),
              SizedBox(width: 6),
              Text('256-bit encrypted · powered by ELK Pay', style: TextStyle(fontSize: 12.5, color: ElkRepColors.sub)),
            ]),
          ]),
        ),
      ),
      _StickyBar(right: _RepBtn(full: true, label: 'Pay AED $_total securely', onTap: () {
        setState(() { _paidTotal = _total; _cart.clear(); });
        _go(_S.done);
      })),
    ]);
  }

  // ─── Done ──────────────────────────────────────────────────────────────────

  Widget _doneScreen() {
    final d = _days[_dateIdx];
    return Container(
      color: ElkRepColors.pineDeep,
      padding: EdgeInsets.fromLTRB(30, MediaQuery.of(context).padding.top + 30, 30, 40),
      child: Column(children: [
        const Spacer(),
        Container(
          width: 96, height: 96,
          decoration: const BoxDecoration(color: ElkRepColors.amber, shape: BoxShape.circle),
          child: const Icon(Icons.check, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 24),
        const Text('Booking\nconfirmed.', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white, height: 1.05)),
        const SizedBox(height: 12),
        const Text("Your technician is assigned. We'll send a tracking link before arrival.", textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Color(0xFFC9D6CD), height: 1.5)),
        const Spacer(),
        // Stamped ticket
        Container(
          width: double.infinity,
          decoration: BoxDecoration(color: ElkRepColors.card, borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.all(18),
          child: Stack(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('WORK ORDER #ELK-2487', style: TextStyle(fontSize: 10, color: ElkRepColors.amber, letterSpacing: 0.1, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _TotalRow(label: 'When', value: '${d.dow} ${d.num} ${d.mon}, $_time'),
              const SizedBox(height: 4),
              Divider(color: ElkRepColors.line.withValues(alpha: 0.7)),
              _TotalRow(label: 'Paid', value: 'AED $_paidTotal', bold: true),
            ]),
            Positioned(
              top: 0, right: 0,
              child: Transform.rotate(
                angle: -0.21,
                child: Container(
                  decoration: BoxDecoration(border: Border.all(color: ElkRepColors.good, width: 2), borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: const Text('PAID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: ElkRepColors.good, letterSpacing: 0.1)),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 22),
        _RepBtn(full: true, label: 'Track my booking', onTap: widget.onBack),
        const SizedBox(height: 14),
        TextButton(
          onPressed: widget.onBack,
          child: const Text('Back to home', style: TextStyle(color: Color(0xFFC9D6CD), fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

// ─── Private helpers ─────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onBack, this.cartCount = 0, this.onCartTap});
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
              decoration: BoxDecoration(border: Border.all(color: ElkRepColors.line, width: 1.5), borderRadius: BorderRadius.circular(11), color: ElkRepColors.card),
              child: const Icon(Icons.chevron_left, size: 20, color: ElkRepColors.ink),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: ElkRepColors.ink))),
          if (onCartTap != null)
            GestureDetector(
              onTap: onCartTap,
              child: Stack(clipBehavior: Clip.none, children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(border: Border.all(color: ElkRepColors.line, width: 1.5), borderRadius: BorderRadius.circular(11), color: ElkRepColors.card),
                  child: const Icon(Icons.shopping_bag_outlined, size: 20, color: ElkRepColors.ink),
                ),
                if (cartCount > 0)
                  Positioned(
                    top: -4, right: -4,
                    child: Container(
                      width: 18, height: 18,
                      decoration: const BoxDecoration(color: ElkRepColors.amber, shape: BoxShape.circle),
                      child: Center(child: Text('$cartCount', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white))),
                    ),
                  ),
              ]),
            ),
        ]),
      ),
    );
  }
}

class _RepBtn extends StatelessWidget {
  const _RepBtn({required this.label, required this.onTap, this.small = false, this.full = false, this.dark = false});
  final String label;
  final VoidCallback onTap;
  final bool small, full, dark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: full ? double.infinity : null,
        padding: EdgeInsets.symmetric(horizontal: small ? 14 : 18, vertical: small ? 9 : 14),
        decoration: BoxDecoration(
          color: dark ? ElkRepColors.pine : ElkRepColors.amber,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: small ? 13 : 15, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.qty, required this.onInc, required this.onDec});
  final int qty;
  final VoidCallback onInc, onDec;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: ElkRepColors.lineSoft, borderRadius: BorderRadius.circular(11)),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(
          onTap: onDec,
          child: Container(
            width: 26, height: 26,
            decoration: BoxDecoration(color: ElkRepColors.card, border: Border.all(color: ElkRepColors.line), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.remove, size: 14, color: ElkRepColors.ink),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('$qty', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ElkRepColors.ink)),
        ),
        GestureDetector(
          onTap: onInc,
          child: Container(
            width: 26, height: 26,
            decoration: BoxDecoration(color: ElkRepColors.pine, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.add, size: 14, color: Colors.white),
          ),
        ),
      ]),
    );
  }
}

class _StickyBar extends StatelessWidget {
  const _StickyBar({this.left, required this.right});
  final Widget? left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(18, 12, 18, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: ElkRepColors.bone,
        border: const Border(top: BorderSide(color: ElkRepColors.line)),
        boxShadow: [BoxShadow(color: ElkRepColors.ink.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: ElkRepColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: ElkRepColors.line, width: 1.5)),
        child: left != null
            ? Row(children: [left!, const SizedBox(width: 14), Expanded(child: right)])
            : right,
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
        decoration: BoxDecoration(color: ElkRepColors.pine, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Text('$count service${count > 1 ? 's' : ''} added', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          const Spacer(),
          Text('AED $total', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ElkRepColors.amber)),
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
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(color: ElkRepColors.lineSoft, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.shopping_bag_outlined, size: 32, color: ElkRepColors.sub),
          ),
          const SizedBox(height: 16),
          const Text('No services yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ElkRepColors.ink)),
          const SizedBox(height: 6),
          const Text('Browse trades and add what needs fixing.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: ElkRepColors.sub)),
          const SizedBox(height: 18),
          _RepBtn(label: 'Browse services', dark: true, onTap: onBrowse),
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
      Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9DD0B6), letterSpacing: 0.08, fontWeight: FontWeight.w700)),
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
      decoration: BoxDecoration(color: ElkRepColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: ElkRepColors.line, width: 1.5)),
      padding: const EdgeInsets.all(15),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: ElkRepColors.lineSoft, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 19, color: ElkRepColors.pine),
        ),
        const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: ElkRepColors.sub, letterSpacing: 0.08, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: ElkRepColors.ink)),
        ])),
        if (onEdit != null)
          TextButton(onPressed: onEdit, child: const Text('Edit', style: TextStyle(color: ElkRepColors.amber, fontWeight: FontWeight.w700, fontSize: 13))),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: bold ? 15 : 13.5, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: muted ? ElkRepColors.sub : ElkRepColors.ink)),
          Text(value, style: TextStyle(fontSize: bold ? 17 : 14, fontWeight: bold ? FontWeight.w800 : FontWeight.w700, color: bold ? ElkRepColors.pine : muted ? ElkRepColors.sub : ElkRepColors.ink)),
        ],
      ),
    );
  }
}

class _FieldBox extends StatelessWidget {
  const _FieldBox({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 10, color: ElkRepColors.sub, letterSpacing: 0.08, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(color: ElkRepColors.bone, borderRadius: BorderRadius.circular(11), border: Border.all(color: ElkRepColors.line, width: 1.5)),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        child: Text(value, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: ElkRepColors.ink)),
      ),
    ]);
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1;
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
