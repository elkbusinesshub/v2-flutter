import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/location_picker_sheet.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _t7  = Color(0xFF137A6D);
const _t6  = Color(0xFF18927F);
const _t5  = Color(0xFF21A892);
const _t4  = Color(0xFF3BBFA9);
const _t05 = Color(0xFFE7F6F2);
const _i9  = Color(0xFF15241F);
const _i7  = Color(0xFF27382F);
const _i5  = Color(0xFF5E6E66);
const _i4  = Color(0xFF8C9890);
const _ln  = Color(0xFFECEFEA);
const _red = Color(0xFFE2554C);

// ─── Ride data ────────────────────────────────────────────────────────────────
const _rides = [
  (id: 'auto',    name: 'Auto',    car: 'assets/icons/car_auto.svg',    sub: 'Budget auto-rickshaw rides',       eta: 4, seats: 3, price: 8,  cancel: 6.0,  badge: 'FASTER',  badgeY: false),
  (id: 'economy', name: 'Economy', car: 'assets/icons/car_sedan.svg',   sub: 'Affordable everyday cars',         eta: 5, seats: 4, price: 15, cancel: 10.0, badge: null,      badgeY: false),
  (id: 'premium', name: 'Premium', car: 'assets/icons/car_premium.svg', sub: 'Top-rated premium cars',           eta: 6, seats: 4, price: 28, cancel: 15.0, badge: 'POPULAR', badgeY: true),
  (id: 'xl',      name: 'ELK XL', car: 'assets/icons/car_van.svg',     sub: 'For families, groups & big bags',  eta: 7, seats: 6, price: 35, cancel: 15.0, badge: null,      badgeY: false),
];

typedef _RideRec = ({String id, String name, String car, String sub, int eta, int seats, int price, double cancel, String? badge, bool badgeY});

// ─── TaxiScreen ───────────────────────────────────────────────────────────────
class TaxiScreen extends StatefulWidget {
  const TaxiScreen({super.key, required this.onTrackRide});
  final VoidCallback onTrackRide;

  @override
  State<TaxiScreen> createState() => _TaxiScreenState();
}

class _TaxiScreenState extends State<TaxiScreen> {
  String _sel  = 'auto';
  String _sort = 'rec';
  bool _showDetail = false;
  String _detailId = 'auto';
  String _pickup  = 'Dubai Marina · Gate 3';
  String _dropoff = 'Downtown Dubai · Burj Khalifa';

  Future<void> _pickLocation(bool isPickup) async {
    final picked = await showLocationPicker(
      context,
      title: isPickup ? 'Choose pickup location' : 'Choose drop-off location',
    );
    if (picked == null) return;
    setState(() {
      if (isPickup) {
        _pickup = picked.address;
      } else {
        _dropoff = picked.address;
      }
    });
  }

  List<_RideRec> get _sorted {
    final list = [..._rides];
    if (_sort == 'fast')  list.sort((a, b) => a.eta.compareTo(b.eta));
    if (_sort == 'cheap') list.sort((a, b) => a.price.compareTo(b.price));
    return list;
  }

  _RideRec get _selRide => _rides.firstWhere((r) => r.id == _sel);
  _RideRec get _detailRide => _rides.firstWhere((r) => r.id == _detailId);

  @override
  Widget build(BuildContext context) {
    final top    = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        // ── Fixed map (behind everything) ──────────────────────────────────
        SizedBox(
          height: 340,
          child: CustomPaint(painter: _MapPainter(), child: const SizedBox.expand()),
        ),

        // ── Scrollable: transparent header space + white sheet ─────────────
        SingleChildScrollView(
          child: Column(children: [
            SizedBox(height: 310), // transparent — map shows through
            _buildSheet(),
            SizedBox(height: 120 + bottom),
          ]),
        ),

        // ── Map UI overlays ───────────────────────────────────────────────
        Positioned(
          top: top + 4, left: 18, right: 18,
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x1A143228), blurRadius: 26, offset: Offset(0, 10))]),
                child: const Icon(Icons.chevron_left_rounded, color: _i9, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.86),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [BoxShadow(color: Color(0x0F143228), blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: Text('Book a Ride', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 18, color: _i9)),
            ),
          ]),
        ),
        // ETA pill (bottom-left of map)
        Positioned(
          left: 18, top: 340 - 74,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x1A143228), blurRadius: 26, offset: Offset(0, 10))]),
            child: Row(children: [
              Container(width: 7, height: 7, decoration: const BoxDecoration(color: _t5, shape: BoxShape.circle)),
              const SizedBox(width: 7),
              Text('14 min · 8.2 km', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 14, color: _i9)),
            ]),
          ),
        ),
        // Recenter button (bottom-right of map)
        Positioned(
          right: 18, top: 340 - 74,
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x1A143228), blurRadius: 26, offset: Offset(0, 10))]),
            child: const Icon(Icons.gps_fixed_rounded, color: _t6, size: 20),
          ),
        ),

        // ── Detail sheet scrim ────────────────────────────────────────────
        if (_showDetail)
          GestureDetector(
            onTap: () => setState(() => _showDetail = false),
            child: Container(color: const Color(0xFF08140F).withValues(alpha: 0.42)),
          ),
        if (_showDetail)
          Positioned(bottom: 0, left: 0, right: 0, child: _buildDetailSheet()),

        // ── Sticky footer ─────────────────────────────────────────────────
        if (!_showDetail)
          Positioned(bottom: 0, left: 0, right: 0, child: _buildFooter(bottom)),
      ]),
    );
  }

  // ─── Sheet (white, rounded top) ───────────────────────────────────────────

  Widget _buildSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [BoxShadow(color: Color(0x1E102818), blurRadius: 30, offset: Offset(0, -10))],
      ),
      padding: const EdgeInsets.only(top: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Handle
        Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: const Color(0xFFE2E7E3), borderRadius: BorderRadius.circular(5)))),
        // Route card
        _buildRouteCard(),
        // Filter chips
        _buildChips(),
        // Section label
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 2),
          child: Text('Choose your ride', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900, color: _i9)),
        ),
        // Ride list
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
          child: Column(children: _sorted.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: _buildRideCard(r),
          )).toList()),
        ),
      ]),
    );
  }

  Widget _buildRouteCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 8, 18, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _ln),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0F143228), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(children: [
        // Dots + connector
        Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 10, height: 10, decoration: const BoxDecoration(color: _t5, shape: BoxShape.circle)),
          Container(width: 2, height: 14, color: const Color(0xFFD9E0DB)),
          Container(width: 10, height: 10, decoration: const BoxDecoration(color: _red, shape: BoxShape.circle)),
        ]),
        const SizedBox(width: 12),
        // Labels
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: () => _pickLocation(true),
            behavior: HitTestBehavior.opaque,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('PICKUP', style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w700, color: _i4, letterSpacing: 0.2)),
              Text(_pickup, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w500, color: _i9, height: 1.3)),
            ]),
          ),
          const SizedBox(height: 9),
          GestureDetector(
            onTap: () => _pickLocation(false),
            behavior: HitTestBehavior.opaque,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('DROP-OFF', style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w700, color: _i4, letterSpacing: 0.2)),
              Text(_dropoff, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w500, color: _i9, height: 1.3)),
            ]),
          ),
        ])),
        const SizedBox(width: 12),
        // Swap button
        GestureDetector(
          onTap: () => setState(() {
            final t = _pickup;
            _pickup = _dropoff;
            _dropoff = t;
          }),
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: _t05, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.swap_vert_rounded, color: _t6, size: 18),
          ),
        ),
      ]),
    );
  }

  Widget _buildChips() {
    const chips = [
      (id: 'rec',   label: 'Recommended', icon: Icons.star_outline_rounded),
      (id: 'fast',  label: 'Faster',      icon: Icons.schedule_rounded),
      (id: 'cheap', label: 'Cheaper',     icon: Icons.attach_money_rounded),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
      child: Row(children: chips.map((c) {
        final on = _sort == c.id;
        return Padding(
          padding: const EdgeInsets.only(right: 9),
          child: GestureDetector(
            onTap: () => setState(() => _sort = c.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: on ? _t05 : Colors.white,
                border: Border.all(color: on ? _t5 : _ln, width: 1.5),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(children: [
                Icon(c.icon, size: 15, color: on ? _t7 : _i5.withValues(alpha: 0.7)),
                const SizedBox(width: 6),
                Text(c.label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: on ? _t7 : _i5)),
              ]),
            ),
          ),
        );
      }).toList()),
    );
  }

  Widget _buildRideCard(_RideRec r) {
    final sel = _sel == r.id;
    return GestureDetector(
      onTap: () => setState(() => _sel = r.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: sel ? null : Colors.white,
          gradient: sel ? const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [_t05, Colors.white]) : null,
          border: Border.all(color: sel ? _t5 : _ln, width: 2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(children: [
          // Car SVG
          SvgPicture.asset(r.car, width: 78, height: 50),
          const SizedBox(width: 12),
          // Mid
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(r.name, style: GoogleFonts.nunito(fontSize: 16.5, fontWeight: FontWeight.w900, color: _i9, letterSpacing: -0.2)),
              if (r.badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: r.badgeY ? const Color(0xFFFEF3C9) : _t05,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(r.badge!, style: GoogleFonts.nunito(fontSize: 9.5, fontWeight: FontWeight.w900, color: r.badgeY ? const Color(0xFF9A7400) : _t7, letterSpacing: 0.4)),
                ),
              ],
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.schedule_rounded, size: 13, color: _i4),
              const SizedBox(width: 3),
              Text('${r.eta} min', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: _i4)),
              const SizedBox(width: 10),
              const Icon(Icons.person_outline_rounded, size: 13, color: _i4),
              const SizedBox(width: 3),
              Text('${r.seats}', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: _i4)),
            ]),
            const SizedBox(height: 3),
            Text(r.sub, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w600, color: _i4), overflow: TextOverflow.ellipsis),
          ])),
          // Right: info + price
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            GestureDetector(
              onTap: () => setState(() { _detailId = r.id; _showDetail = true; }),
              child: Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: sel ? _t4 : _ln, width: 1.4),
                ),
                child: Icon(Icons.info_outline_rounded, size: 14, color: sel ? _t6 : _i4),
              ),
            ),
            const SizedBox(height: 8),
            Text('AED ${r.price}', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900, color: _i9)),
          ]),
        ]),
      ),
    );
  }

  // ─── Footer ───────────────────────────────────────────────────────────────

  Widget _buildFooter(double bottom) {
    final r = _selRide;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(18, 10, 18, 12 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _ln)),
        boxShadow: [BoxShadow(color: Color(0x14102818), blurRadius: 18, offset: Offset(0, -6))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Payment row
        Row(children: [
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(color: const Color(0xFFE5F6EC), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.payments_outlined, size: 15, color: Color(0xFF1A9B53)),
          ),
          const SizedBox(width: 8),
          Text('Cash', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: _i9)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: _i4),
          const Spacer(),
          Text('Change', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: _t6)),
        ]),
        const SizedBox(height: 10),
        // CTA row
        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: widget.onTrackRide,
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_t5, _t7]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Color(0x520A5A42), blurRadius: 22, offset: Offset(0, 10))],
                ),
                child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Book ', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                  Text(r.name, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.20), borderRadius: BorderRadius.circular(9)),
                    child: Text('AED ${r.price}', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                ])),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Schedule button
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(color: _t05, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.calendar_today_rounded, color: _t7, size: 22),
          ),
        ]),
      ]),
    );
  }

  // ─── Detail sheet ─────────────────────────────────────────────────────────

  Widget _buildDetailSheet() {
    final r = _detailRide;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [BoxShadow(color: Color(0x33102818), blurRadius: 34, offset: Offset(0, -12))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Header with car illustration
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFFEFF2EE),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          padding: const EdgeInsets.only(top: 16, bottom: 10),
          child: Stack(children: [
            Column(children: [
              Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: const Color(0xFFD0D8D4), borderRadius: BorderRadius.circular(5)))),
              const SizedBox(height: 6),
              Center(child: SvgPicture.asset(r.car, width: 230, height: 150)),
            ]),
            Positioned(
              top: 14, right: 16,
              child: GestureDetector(
                onTap: () => setState(() => _showDetail = false),
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(color: const Color(0x1A14281E), borderRadius: BorderRadius.circular(17)),
                  child: const Icon(Icons.close_rounded, size: 18, color: _i7),
                ),
              ),
            ),
          ]),
        ),
        // Body
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 26),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.name, style: GoogleFonts.nunito(fontSize: 30, fontWeight: FontWeight.w900, color: _i9, letterSpacing: -0.5)),
            const SizedBox(height: 6),
            Text(r.sub, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: _i5)),
            const SizedBox(height: 22),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Fare', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: _i9)),
              Text('AED ${r.price}', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: _i9)),
            ]),
            _dotRow('Cancellation', 'AED ${r.cancel.toStringAsFixed(2)}'),
            _dotRow('Seats', '${r.seats}'),
            const SizedBox(height: 22),
            Text(
              'Total fare is an estimate based on distance and time. Surcharges, peak pricing, or toll fees may be added at checkout.',
              style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w500, color: _i4, height: 1.5),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _dotRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(children: [
        Text(key, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: _i7)),
        const SizedBox(width: 8),
        Expanded(child: CustomPaint(painter: _DotLinePainter(), child: const SizedBox(height: 16))),
        const SizedBox(width: 8),
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: _i9)),
      ]),
    );
  }
}

// ─── Map painter ──────────────────────────────────────────────────────────────

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final W = size.width;
    final H = size.height;
    final sx = W / 392.0;
    final sy = H / 340.0;

    // Base
    canvas.drawRect(Rect.fromLTWH(0, 0, W, H), Paint()..color = const Color(0xFFE9EEEA));

    // Parks
    canvas.drawRect(Rect.fromLTRB(-20 * sx, 180 * sy, 130 * sx, H + 20), Paint()..color = const Color(0xFFDCEBDD));
    canvas.drawRect(Rect.fromLTRB(250 * sx, -10 * sy, W + 20, 110 * sy), Paint()..color = const Color(0xFFDCEBDD));

    // Water
    final water = Path()
      ..moveTo(0, 40 * sy)
      ..quadraticBezierTo(120 * sx, 80 * sy, W, 30 * sy)
      ..lineTo(W, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(water, Paint()..color = const Color(0xFFCFE6EC));

    // Roads (white, thick)
    final rp = Paint()
      ..color = Colors.white
      ..strokeWidth = 10 * sx
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(-10 * sx, 120 * sy), Offset(W + 10, 150 * sy), rp);
    canvas.drawLine(Offset(60 * sx, -10 * sy), Offset(120 * sx, H + 10), rp);
    canvas.drawLine(Offset(300 * sx, -10 * sy), Offset(250 * sx, H + 10), rp);
    canvas.drawLine(Offset(-10 * sx, 250 * sy), Offset(W + 10, 235 * sy), rp);

    // Road outlines (thin gray)
    final op = Paint()
      ..color = const Color(0xFFD7DED8)
      ..strokeWidth = 2 * sx
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(-10 * sx, 120 * sy), Offset(W + 10, 150 * sy), op);
    canvas.drawLine(Offset(60 * sx, -10 * sy), Offset(120 * sx, H + 10), op);
    canvas.drawLine(Offset(300 * sx, -10 * sy), Offset(250 * sx, H + 10), op);
    canvas.drawLine(Offset(-10 * sx, 250 * sy), Offset(W + 10, 235 * sy), op);

    // Teal route: M96,250 C150,210 150,150 220,120 C270,100 300,96 318,92
    final route = Path()
      ..moveTo(96 * sx, 250 * sy)
      ..cubicTo(150 * sx, 210 * sy, 150 * sx, 150 * sy, 220 * sx, 120 * sy)
      ..cubicTo(270 * sx, 100 * sy, 300 * sx, 96 * sy, 318 * sx, 92 * sy);
    canvas.drawPath(route, Paint()
      ..color = const Color(0xFF137A6D)
      ..strokeWidth = 6 * sx
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round);
    canvas.drawPath(route, Paint()
      ..color = const Color(0xFF21A892)
      ..strokeWidth = 3 * sx
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    // Pickup pin (green circle at 96,250)
    canvas.drawCircle(Offset(96 * sx, 250 * sy), 11 * sx, Paint()..color = const Color(0xFF21A892));
    canvas.drawCircle(Offset(96 * sx, 250 * sy), 4.5 * sx, Paint()..color = Colors.white);

    // Drop pin (red teardrop at 318,92)
    final dx = 318 * sx, dy = 92 * sy, ps = sx;
    final pin = Path()
      ..moveTo(dx, dy - 22 * ps)
      ..cubicTo(dx + 10 * ps, dy - 22 * ps, dx + 16 * ps, dy - 15 * ps, dx + 16 * ps, dy - 7 * ps)
      ..cubicTo(dx + 16 * ps, dy + 2 * ps, dx, dy + 14 * ps, dx, dy + 14 * ps)
      ..cubicTo(dx, dy + 14 * ps, dx - 16 * ps, dy + 2 * ps, dx - 16 * ps, dy - 7 * ps)
      ..cubicTo(dx - 16 * ps, dy - 15 * ps, dx - 10 * ps, dy - 22 * ps, dx, dy - 22 * ps)
      ..close();
    canvas.drawPath(pin, Paint()..color = const Color(0xFFE2554C));
    canvas.drawCircle(Offset(dx, dy - 7 * ps), 5 * ps, Paint()..color = Colors.white);

    // Subtle bottom vignette
    final vignette = Rect.fromLTWH(0, 0, W, H);
    canvas.drawRect(vignette, Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter, end: const Alignment(0, -0.7),
        colors: [const Color(0xFF14281E).withValues(alpha: 0.05), Colors.transparent],
      ).createShader(vignette));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Dotted leader line ───────────────────────────────────────────────────────

class _DotLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD7DDD8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const dash = 4.0, gap = 5.0;
    double x = 0;
    final y = size.height / 2 - 3;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(math.min(x + dash, size.width), y), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
