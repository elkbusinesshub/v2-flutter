import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

// ── design tokens ──────────────────────────────────────────────────────────
const _t7  = Color(0xFF0F6E60);
const _t6  = Color(0xFF137A6D);
const _t5  = Color(0xFF18927F);
const _t05 = Color(0xFFE7F6F2);
const _y05 = Color(0xFFFEF6D8);
const _r05 = Color(0xFFFDECEA);
const _g05 = Color(0xFFE7F6EC);
const _red = Color(0xFFE2554C);
const _grn = Color(0xFF1F9D57);
const _yam = Color(0xFF9A7400);
const _ink9 = Color(0xFF16271F);
const _ink7 = Color(0xFF2A3B31);
const _ink5 = Color(0xFF5E6E64);
const _ink4 = Color(0xFF8C9890);
const _bg   = Color(0xFFF1F4EE);
const _line = Color(0xFFE6EBE5);
const _chip = Color(0xFFEFF2EC);

// ── header gradient ────────────────────────────────────────────────────────
const _hGrad = LinearGradient(
  begin: Alignment(0.8, -1),
  end:   Alignment(-0.3, 1),
  colors: [_t5, _t7],
);

// ── internal screens ───────────────────────────────────────────────────────
enum _Sn { list, detail }

// ── booking model ──────────────────────────────────────────────────────────
class _BK {
  _BK({
    required this.id,
    required this.title,
    required this.vendor,
    required this.cat,
    required this.ill,
    required this.status,
    required this.date,
    required this.time,
    required this.addr,
    required this.svc,
    required this.fee,
    required this.vat,
    required this.total,
    required this.method,
    this.rated = false,
  });

  final String id, title, vendor, cat, addr;
  final IconData ill;
  final int svc, fee, vat, total;
  String status, date, time, method;
  bool rated;
}

// ── status style ───────────────────────────────────────────────────────────
typedef _SS = ({String label, Color fg, Color bg});
_SS _ss(String s) => switch (s) {
  'confirmed' => (label: 'Confirmed',      fg: _t7,  bg: _t05),
  'pending'   => (label: 'Pending vendor', fg: _yam, bg: _y05),
  'completed' => (label: 'Completed',      fg: _grn, bg: _g05),
  'cancelled' => (label: 'Cancelled',      fg: _red, bg: _r05),
  _           => (label: 'Unknown',        fg: _ink4, bg: _chip),
};

// ── tab → statuses ─────────────────────────────────────────────────────────
const _tabSt = {
  'upcoming':  {'confirmed', 'pending'},
  'completed': {'completed'},
  'cancelled': {'cancelled'},
};

// ═══════════════════════════════════════════════════════════════════════════
// SCREEN
// ═══════════════════════════════════════════════════════════════════════════
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});
  @override
  State<MyBookingsScreen> createState() => _State();
}

class _State extends State<MyBookingsScreen> {
  // ── nav ──────────────────────────────────────────────────────────────────
  final List<_Sn> _stack = [_Sn.list];
  _Sn get _sn => _stack.last;
  void _push(_Sn s) => setState(() => _stack.add(s));
  void _pop() {
    if (_stack.length > 1) {
      setState(() => _stack.removeLast());
    } else {
      Navigator.of(context).maybePop();
    }
  }

  // ── data ─────────────────────────────────────────────────────────────────
  final List<_BK> _bks = [
    _BK(id: 'ELK-7F3KQ', title: 'Deep Home Clean', vendor: 'Royal Shine', cat: 'Cleaning',   ill: Icons.cleaning_services_rounded, status: 'confirmed', date: 'Today',       time: '11:00 AM',    addr: 'Tower 3, Apt 1204, Al Reem Island', svc: 72,  fee: 5,  vat: 4,  total: 81,  method: 'Card ••• 1111'),
    _BK(id: 'ELK-2M9PL', title: 'Airport Transfer', vendor: 'SpeedRide',   cat: 'Taxi/Ride',  ill: Icons.local_taxi_rounded,         status: 'pending',   date: 'Tomorrow',    time: '6:30 AM',     addr: 'Pickup: Marina Gate 3',             svc: 12,  fee: 2,  vat: 1,  total: 15,  method: 'ELK Wallet'),
    _BK(id: 'ELK-5KD1A', title: 'AC Repair',        vendor: 'Express Fix', cat: 'Repair',     ill: Icons.build_rounded,              status: 'confirmed', date: 'Sat 5 Jul',   time: '2:00 PM',     addr: 'Villa 22, Al Reem Island',          svc: 40,  fee: 5,  vat: 2,  total: 47,  method: 'Card ••• 1111'),
    _BK(id: 'ELK-8QW3E', title: 'Elite ELK Stay',   vendor: 'Elite Res.',  cat: 'ELK Stay',   ill: Icons.apartment_rounded,          status: 'completed', date: '20–24 Jun',   time: 'Check-in 2 PM', addr: 'Downtown, Tower 4',               svc: 840, fee: 20, vat: 20, total: 880, method: 'Card ••• 1111', rated: false),
    _BK(id: 'ELK-3RT7Y', title: 'Porter Move',      vendor: 'QuickMove',   cat: 'Porter',     ill: Icons.inventory_2_rounded,        status: 'completed', date: '28 Jun',      time: '10:00 AM',    addr: 'Marina → Downtown',                 svc: 58,  fee: 5,  vat: 2,  total: 65,  method: 'Cash',         rated: true),
    _BK(id: 'ELK-9ZC4U', title: 'Toyota Camry',     vendor: 'ELK Rentals', cat: 'Car Rental', ill: Icons.directions_car_rounded,     status: 'cancelled', date: '15 Jun',      time: 'Full day',    addr: 'Pickup: Business Bay',              svc: 199, fee: 0,  vat: 0,  total: 199, method: 'Refunded to Wallet'),
  ];

  // ── tab + current ─────────────────────────────────────────────────────────
  String _tab = 'upcoming';
  late _BK _cur = _bks.first;

  List<_BK> get _vis => _bks.where((b) => (_tabSt[_tab] ?? {}).contains(b.status)).toList();
  int _cnt(String t) => _bks.where((b) => (_tabSt[t] ?? {}).contains(b.status)).length;

  // ── toast ────────────────────────────────────────────────────────────────
  void _toast(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded, color: Color(0xFF3FD2B4), size: 18),
        const SizedBox(width: 9),
        Expanded(child: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700))),
      ]),
      backgroundColor: _ink9,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      duration: const Duration(milliseconds: 2200),
    ));
  }

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) => _pop(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(begin: const Offset(0.05, 0), end: Offset.zero).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOut),
            ),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(_sn),
          child: _sn == _Sn.list ? _listScreen() : _detailScreen(),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // LIST SCREEN
  // ═══════════════════════════════════════════════════════════════════════
  Widget _listScreen() {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        // header
        Container(
          decoration: const BoxDecoration(gradient: _hGrad),
          padding: EdgeInsets.fromLTRB(18, top + 8, 18, 16),
          child: Row(children: [
            GestureDetector(
              onTap: _pop,
              child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 13),
            Text('My Bookings', style: GoogleFonts.nunito(
              fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3,
            )),
            const Spacer(),
            SvgPicture.asset('assets/icons/elk_logo.svg', height: 23),
          ]),
        ),
        // tabs
        Container(
          color: _bg,
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
          child: Row(children: [
            for (final t in ['upcoming', 'completed', 'cancelled']) ...[
              Expanded(child: _Tab(label: _tabLabel(t), count: _cnt(t), active: _tab == t, onTap: () => setState(() => _tab = t))),
              if (t != 'cancelled') const SizedBox(width: 8),
            ],
          ]),
        ),
        // list
        Expanded(
          child: _vis.isEmpty
              ? _emptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                  itemCount: _vis.length,
                  itemBuilder: (_, i) {
                    final b = _vis[i];
                    return _Card(
                      bk: b,
                      onTap: () { _cur = b; _push(_Sn.detail); },
                      onCancel: (b.status == 'confirmed' || b.status == 'pending') ? () { _cur = b; _openCancel(); } : null,
                      onRate: b.status == 'completed' ? () { _cur = b; _openRate(); } : null,
                      onRebook: () { _cur = b; _rebook(); },
                    );
                  },
                ),
        ),
      ]),
    );
  }

  String _tabLabel(String t) => switch (t) {
    'upcoming'  => 'Upcoming',
    'completed' => 'Completed',
    _           => 'Cancelled',
  };

  Widget _emptyState() {
    final msgs = switch (_tab) {
      'upcoming'  => ('No upcoming bookings', 'Book a service and it will show up here.'),
      'completed' => ('Nothing completed yet', 'Your finished bookings will appear here.'),
      _           => ('No cancelled bookings', 'Cancellations will be listed here.'),
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80, height: 80,
            decoration: const BoxDecoration(color: _t05, shape: BoxShape.circle),
            child: const Icon(Icons.calendar_month_rounded, color: _t6, size: 34),
          ),
          const SizedBox(height: 16),
          Text(msgs.$1, style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w900, color: _ink9)),
          const SizedBox(height: 6),
          Text(msgs.$2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _ink4)),
        ]),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // DETAIL SCREEN
  // ═══════════════════════════════════════════════════════════════════════
  Widget _detailScreen() {
    final b = _cur;
    final top = MediaQuery.of(context).padding.top;
    final s = _ss(b.status);
    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        // header
        Container(
          decoration: const BoxDecoration(gradient: _hGrad),
          child: Column(children: [
            SizedBox(height: top),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: _pop,
                  child: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 13),
                Text('Booking details', style: GoogleFonts.nunito(
                  fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3,
                )),
                const Spacer(),
                SvgPicture.asset('assets/icons/elk_logo.svg', height: 23),
              ]),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 58, height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
                    ),
                    child: Icon(b.ill, color: Colors.white, size: 34),
                  ),
                  const SizedBox(width: 13),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(b.title, style: GoogleFonts.nunito(
                      fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3,
                    )),
                    const SizedBox(height: 2),
                    Text('by ${b.vendor} · ${b.cat}', style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white70,
                    )),
                  ])),
                ]),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(s.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: s.fg, letterSpacing: 0.2)),
                ),
              ]),
            ),
          ]),
        ),
        // scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _secTitle('Status'),
              const SizedBox(height: 10),
              _wCard(Padding(padding: const EdgeInsets.all(14), child: _Timeline(status: b.status))),
              const SizedBox(height: 20),
              _secTitle('Schedule & address'),
              const SizedBox(height: 10),
              _wCard(Column(children: [
                _InfoRow(icon: Icons.calendar_month_rounded, label: 'Date & time', value: '${b.date} · ${b.time}', first: true),
                _InfoRow(icon: Icons.location_on_rounded, label: 'Service address', value: b.addr),
              ])),
              const SizedBox(height: 20),
              _secTitle('Vendor'),
              const SizedBox(height: 10),
              _wCard(_InfoRow(
                icon: Icons.person_rounded,
                label: '${b.cat} specialist',
                value: b.vendor,
                first: true,
                trailing: GestureDetector(
                  onTap: () => _toast('Calling vendor…'),
                  child: const Text('Call', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: _t7)),
                ),
              )),
              const SizedBox(height: 20),
              _secTitle('Payment'),
              const SizedBox(height: 10),
              _wCard(Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  _brkLine('Service', b.svc),
                  if (b.fee > 0) _brkLine('ELK service fee', b.fee),
                  if (b.vat > 0) _brkLine('VAT (5%)', b.vat),
                  const SizedBox(height: 6),
                  Divider(height: 1.5, thickness: 1.5, color: _line),
                  const SizedBox(height: 11),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Total ${b.status == 'cancelled' ? '(refunded)' : 'paid'}',
                        style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900, color: _ink9)),
                    Text('AED ${b.total}',
                        style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900, color: _ink9)),
                  ]),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Paid via', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: _ink5)),
                    Text(b.method, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: _ink9)),
                  ]),
                ]),
              )),
              const SizedBox(height: 14),
              _wCard(Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Booking ID', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _ink4)),
                    const SizedBox(height: 2),
                    Text(b.id, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _ink9)),
                  ]),
                  GestureDetector(
                    onTap: () => _toast('Copied booking ID'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(color: _chip, borderRadius: BorderRadius.circular(999)),
                      child: const Text('Copy', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _ink5)),
                    ),
                  ),
                ]),
              )),
              if (b.status == 'confirmed' || b.status == 'pending') ...[
                const SizedBox(height: 14),
                const Text(
                  'Free cancellation up to 2 hours before your slot. Cancellations after that may incur a 50% charge.',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: _ink4, height: 1.5),
                ),
              ],
              const SizedBox(height: 24),
            ]),
          ),
        ),
        // footer
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          child: SafeArea(top: false, child: Row(children: [
            if (b.status == 'cancelled') ...[
              Expanded(child: _CtaBtn(label: 'Rebook this service', onTap: _rebook)),
            ] else if (b.status == 'completed') ...[
              Expanded(child: _CtaBtn(label: b.rated ? 'Rated ★' : 'Rate', outline: true, onTap: _openRate)),
              const SizedBox(width: 11),
              Expanded(child: _CtaBtn(label: 'Rebook', onTap: _rebook)),
            ] else ...[
              Expanded(child: _CtaBtn(label: 'Reschedule', outline: true, onTap: _openResched)),
              const SizedBox(width: 11),
              Expanded(child: _CtaBtn(label: 'Cancel booking', danger: true, onTap: _openCancel)),
            ],
          ])),
        ),
      ]),
    );
  }

  // ── shared widgets ────────────────────────────────────────────────────────
  Widget _secTitle(String t) => Text(t, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _ink9));
  Widget _wCard(Widget child) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: _line),
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [BoxShadow(color: Color(0x0F142818), blurRadius: 8, offset: Offset(0, 2))],
    ),
    child: child,
  );
  Widget _brkLine(String k, int v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(k, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: _ink5)),
      Text('AED $v', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: _ink9)),
    ]),
  );

  // ═══════════════════════════════════════════════════════════════════════
  // SHEETS
  // ═══════════════════════════════════════════════════════════════════════
  void _openCancel() async {
    String? reason;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, ss) {
        return _Sheet(children: [
          Text('Cancel this booking?', style: GoogleFonts.nunito(fontSize: 19, fontWeight: FontWeight.w900, color: _ink9)),
          const SizedBox(height: 4),
          Text('${_cur.title} · ${_cur.date}, ${_cur.time}',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _ink5)),
          const SizedBox(height: 16),
          const Text('Why are you cancelling?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _ink5)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final r in ['Changed my plans', 'Found another option', 'Wrong date/time', 'Too expensive', 'Other'])
              GestureDetector(
                onTap: () => ss(() => reason = r),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                  decoration: BoxDecoration(
                    color: reason == r ? _r05 : Colors.white,
                    border: Border.all(color: reason == r ? _red : _line, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(r, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: reason == r ? _red : _ink7)),
                ),
              ),
          ]),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(color: _t05, borderRadius: BorderRadius.circular(14)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.info_outline_rounded, size: 16, color: _t7),
              const SizedBox(width: 9),
              Expanded(child: Text.rich(
                TextSpan(children: [
                  const TextSpan(text: "You're within the free window — "),
                  TextSpan(text: 'full refund of AED ${_cur.total}', style: const TextStyle(fontWeight: FontWeight.w900)),
                  const TextSpan(text: ' to your ELK Wallet in 3–5 days.'),
                ]),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _t7),
              )),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _CtaBtn(label: 'Keep booking', outline: true, onTap: () => Navigator.of(ctx).pop(false))),
            const SizedBox(width: 11),
            Expanded(child: _CtaBtn(label: 'Cancel booking', danger: true, onTap: () => Navigator.of(ctx).pop(true))),
          ]),
        ]);
      }),
    );
    if (ok == true && mounted) {
      setState(() {
        _cur.status = 'cancelled';
        _cur.method = 'Refunded to Wallet';
      });
      _toast('Booking cancelled · refund on the way');
      if (_sn == _Sn.detail) _pop();
      setState(() => _tab = 'cancelled');
    }
  }

  void _openResched() async {
    String date = 'Tomorrow';
    String time = '11:00 AM';
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, ss) {
        return _Sheet(children: [
          Text('Reschedule', style: GoogleFonts.nunito(fontSize: 19, fontWeight: FontWeight.w900, color: _ink9)),
          const SizedBox(height: 4),
          const Text('Pick a new date and time slot.',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _ink5)),
          const SizedBox(height: 14),
          const Text('NEW DATE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _ink5)),
          const SizedBox(height: 7),
          Wrap(spacing: 9, runSpacing: 9, children: [
            for (final d in ['Tomorrow', 'Sat 5 Jul', 'Sun 6 Jul', 'Mon 7 Jul'])
              _Chip(label: d, active: date == d, onTap: () => ss(() => date = d)),
          ]),
          const SizedBox(height: 14),
          const Text('NEW TIME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _ink5)),
          const SizedBox(height: 7),
          Wrap(spacing: 9, runSpacing: 9, children: [
            for (final t in ['9:00 AM', '11:00 AM', '2:00 PM', '5:00 PM'])
              _Chip(label: t, active: time == t, onTap: () => ss(() => time = t)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _CtaBtn(label: 'Back', outline: true, onTap: () => Navigator.of(ctx).pop(false))),
            const SizedBox(width: 11),
            Expanded(child: _CtaBtn(label: 'Confirm change', onTap: () => Navigator.of(ctx).pop(true))),
          ]),
        ]);
      }),
    );
    if (ok == true && mounted) {
      setState(() { _cur.date = date; _cur.time = time; });
      _toast('Booking rescheduled');
    }
  }

  void _openRate() async {
    int stars = _cur.rated ? 5 : 0;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, ss) {
        return _Sheet(children: [
          Text('Rate your service', style: GoogleFonts.nunito(fontSize: 19, fontWeight: FontWeight.w900, color: _ink9)),
          const SizedBox(height: 4),
          Text('How was ${_cur.title} by ${_cur.vendor}?',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _ink5)),
          const SizedBox(height: 16),
          // stars
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (int i = 1; i <= 5; i++)
              GestureDetector(
                onTap: () => ss(() => stars = i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    i <= stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 38,
                    color: i <= stars ? const Color(0xFFF6CE19) : const Color(0xFFD7DDD8),
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 12),
          TextField(
            maxLines: 3,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Share a few words (optional)…',
              hintStyle: const TextStyle(color: _ink4, fontSize: 14, fontWeight: FontWeight.w600),
              contentPadding: const EdgeInsets.all(13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _line, width: 1.5)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _t6, width: 1.5)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _line, width: 1.5)),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _CtaBtn(label: 'Skip', outline: true, onTap: () => Navigator.of(ctx).pop())),
            const SizedBox(width: 11),
            Expanded(child: _CtaBtn(label: 'Submit review', onTap: () {
              if (stars == 0) { _toast('Tap a star to rate'); return; }
              setState(() => _cur.rated = true);
              Navigator.of(ctx).pop();
              _toast('Thanks for your review!');
            })),
          ]),
        ]);
      }),
    );
  }

  void _rebook() => _toast('Reopening service to rebook…');
}

// ═══════════════════════════════════════════════════════════════════════════
// SUB-WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.count, required this.active, required this.onTap});
  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: active ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_t5, _t7]) : null,
          color: active ? null : _chip,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active ? [const BoxShadow(color: Color(0x480F6E60), blurRadius: 14, offset: Offset(0, 6))] : null,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(label, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w900, color: active ? Colors.white : _ink5)),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: active ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFDDE3DC),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: active ? Colors.white : _ink5)),
          ),
        ]),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.bk, required this.onTap, this.onCancel, this.onRate, required this.onRebook});
  final _BK bk;
  final VoidCallback onTap, onRebook;
  final VoidCallback? onCancel, onRate;

  @override
  Widget build(BuildContext context) {
    final s = _ss(bk.status);
    final isUpcoming = bk.status == 'confirmed' || bk.status == 'pending';
    final isCompleted = bk.status == 'completed';
    final isCancelled = bk.status == 'cancelled';

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x0F142818), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // top row (tappable for detail)
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: _t05, borderRadius: BorderRadius.circular(15)),
                child: Icon(bk.ill, color: _t6, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(bk.title, style: GoogleFonts.nunito(fontSize: 15.5, fontWeight: FontWeight.w900, color: _ink9, letterSpacing: -0.2), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 1),
                Text('by ${bk.vendor} · ${bk.cat}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _ink4), maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(999)),
                child: Text(s.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: s.fg, letterSpacing: 0.2)),
              ),
            ]),
          ),
        ),
        // meta row
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(children: [
              const Divider(height: 1, color: _line),
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.calendar_month_rounded, size: 14, color: _t6),
                const SizedBox(width: 4),
                Text(bk.date, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _ink5)),
                const SizedBox(width: 14),
                const Icon(Icons.schedule_rounded, size: 14, color: _t6),
                const SizedBox(width: 4),
                Text(bk.time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _ink5)),
                const Spacer(),
                Text('AED ${bk.total}', style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900, color: _ink9)),
              ]),
            ]),
          ),
        ),
        // refund note (cancelled)
        if (isCancelled)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(color: _g05, borderRadius: BorderRadius.circular(11)),
              child: Row(children: [
                const Icon(Icons.refresh_rounded, size: 14, color: _grn),
                const SizedBox(width: 7),
                Text('Refunded AED ${bk.total} to ELK Wallet',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _grn)),
              ]),
            ),
          ),
        // action buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: Row(children: [
            if (isUpcoming) ...[
              Expanded(child: _Btn(label: 'View details', onTap: onTap)),
              const SizedBox(width: 9),
              Expanded(child: _Btn(label: 'Cancel', danger: true, onTap: onCancel ?? () {})),
            ] else if (isCompleted) ...[
              Expanded(child: _Btn(label: bk.rated ? 'Rated ★' : 'Rate', onTap: onRate ?? () {})),
              const SizedBox(width: 9),
              Expanded(child: _Btn(label: 'Rebook', primary: true, onTap: onRebook)),
            ] else if (isCancelled) ...[
              Expanded(child: _Btn(label: 'Rebook', primary: true, onTap: onRebook)),
            ],
          ]),
        ),
      ]),
    );
  }
}

// flat card action button (.ba)
class _Btn extends StatelessWidget {
  const _Btn({required this.label, required this.onTap, this.primary = false, this.danger = false});
  final String label;
  final VoidCallback onTap;
  final bool primary, danger;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          gradient: primary ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_t5, _t7]) : null,
          color: primary ? null : Colors.white,
          border: primary ? null : Border.all(color: danger ? const Color(0xFFF3D3CF) : _line, width: 1.5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: primary ? [const BoxShadow(color: Color(0x480F6E60), blurRadius: 14, offset: Offset(0, 6))] : null,
        ),
        child: Center(
          child: Text(label, style: GoogleFonts.nunito(
            fontSize: 13, fontWeight: FontWeight.w900,
            color: primary ? Colors.white : danger ? _red : _ink7,
          )),
        ),
      ),
    );
  }
}

// cta button (for detail footer and sheet rows)
class _CtaBtn extends StatelessWidget {
  const _CtaBtn({required this.label, required this.onTap, this.outline = false, this.danger = false});
  final String label;
  final VoidCallback onTap;
  final bool outline, danger;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: (!outline && !danger) ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_t5, _t7]) : null,
          color: (outline || danger) ? Colors.white : null,
          border: (outline || danger) ? Border.all(color: danger ? _red : _t6, width: 1.6) : null,
          borderRadius: BorderRadius.circular(15),
          boxShadow: (!outline && !danger) ? [const BoxShadow(color: Color(0x4D0F6E60), blurRadius: 18, offset: Offset(0, 8))] : null,
        ),
        child: Center(
          child: Text(label, style: GoogleFonts.nunito(
            fontSize: 15, fontWeight: FontWeight.w900,
            color: danger ? _red : outline ? _t7 : Colors.white,
          )),
        ),
      ),
    );
  }
}

// timeline widget
class _Timeline extends StatelessWidget {
  const _Timeline({required this.status});
  final String status;

  static const _steps = [
    ('Booked',      'Order placed'),
    ('Confirmed',   'Vendor accepted'),
    ('In progress', 'On the day'),
    ('Completed',   'Service done'),
  ];

  @override
  Widget build(BuildContext context) {
    if (status == 'cancelled') {
      return Column(children: [
        _TlRow(done: true, title: 'Booked', sub: 'Order placed', hasLine: true, lineDone: false),
        _TlRow(done: false, cancelled: true, title: 'Cancelled', sub: 'Refund issued to ELK Wallet', hasLine: false, lineDone: false),
      ]);
    }
    final reached = switch (status) {
      'completed' => 4,
      'confirmed' => 2,
      'pending'   => 1,
      _           => 0,
    };
    return Column(
      children: List.generate(_steps.length, (i) {
        final (title, sub) = _steps[i];
        return _TlRow(
          done: i < reached,
          title: title, sub: sub,
          hasLine: i < _steps.length - 1,
          lineDone: i < reached - 1,
        );
      }),
    );
  }
}

class _TlRow extends StatelessWidget {
  const _TlRow({required this.done, required this.title, required this.sub, required this.hasLine, required this.lineDone, this.cancelled = false});
  final bool done, hasLine, lineDone, cancelled;
  final String title, sub;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: 22,
        child: Column(children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? _t6 : cancelled ? _red : Colors.white,
              border: Border.all(color: done ? _t6 : cancelled ? _red : _line, width: 2),
            ),
            child: done
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : cancelled
                    ? const Icon(Icons.close, size: 12, color: Colors.white)
                    : null,
          ),
          if (hasLine)
            Container(width: 2, height: 32, color: lineDone ? _t6 : _line, margin: const EdgeInsets.symmetric(vertical: 2)),
        ]),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Padding(
          padding: EdgeInsets.only(bottom: hasLine ? 0 : 0, top: 1),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: cancelled ? _red : _ink9)),
            const SizedBox(height: 1),
            Text(sub, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: _ink4)),
            SizedBox(height: hasLine ? 16 : 0),
          ]),
        ),
      ),
    ]);
  }
}

// info row (schedule/vendor cards)
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value, this.first = false, this.trailing});
  final IconData icon;
  final String label, value;
  final bool first;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        border: first ? null : Border(top: BorderSide(color: _line)),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: _t05, borderRadius: BorderRadius.circular(11)),
          child: Icon(icon, color: _t7, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _ink4)),
          const SizedBox(height: 1),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _ink9)),
        ])),
        ?trailing,
      ]),
    );
  }
}

// bottom sheet wrapper
class _Sheet extends StatelessWidget {
  const _Sheet({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final bot = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Color(0x33102818), blurRadius: 34, offset: Offset(0, -12))],
      ),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + bot),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(
          child: Container(
            width: 44, height: 5,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(color: const Color(0xFFE2E7E3), borderRadius: BorderRadius.circular(5)),
          ),
        ),
        ...children,
      ]),
    );
  }
}

// selection chip (reschedule sheet)
class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          color: active ? _t05 : Colors.white,
          border: Border.all(color: active ? _t6 : _line, width: 1.5),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: active ? _t7 : _ink7)),
      ),
    );
  }
}
