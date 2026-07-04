import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/location_picker_sheet.dart';
import 'porter_booking_flow.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _dk9  = Color(0xFF0C241D);
const _dk7  = Color(0xFF1A4A3C);
const _teal = Color(0xFF18927F);
const _tDk  = Color(0xFF0F6E60);
const _t05  = Color(0xFFE7F6F2);
const _i9   = Color(0xFF16271F);
const _i7   = Color(0xFF2A3B31);
const _i5   = Color(0xFF5E6E64);
const _i4   = Color(0xFF8C9890);
const _line = Color(0xFFE6EBE5);
const _red  = Color(0xFFE2554C);

// ─── Data ─────────────────────────────────────────────────────────────────────
const _vehicles = [
  (id: 'bike',  name: 'Bike',  svg: 'assets/icons/veh_bike.svg',  cap: 'Up to 5 kg',   eta: 12, price: 35,  badge: 'FASTEST'),
  (id: 'car',   name: 'Car',   svg: 'assets/icons/veh_car.svg',   cap: 'Up to 100 kg', eta: 18, price: 65,  badge: null),
  (id: 'truck', name: 'Truck', svg: 'assets/icons/veh_truck.svg', cap: 'Up to 3 Ton',  eta: 25, price: 180, badge: null),
];

const _addonDefs = [
  (id: 'helper',  label: 'Loading helper',   price: 30),
  (id: 'fragile', label: 'Fragile handling', price: 15),
  (id: 'insure',  label: 'Insurance',        price: 10),
];


// ─── Screen ───────────────────────────────────────────────────────────────────
class PorterScreen extends StatefulWidget {
  const PorterScreen({super.key, required this.onDone, this.onTrack});
  final VoidCallback onDone;
  final VoidCallback? onTrack;

  @override
  State<PorterScreen> createState() => _PorterScreenState();
}

class _PorterScreenState extends State<PorterScreen> {
  String _selVehicle = 'bike';
  final Set<String> _addons = {};
  String _pickup  = 'Dubai Marina, Block C';
  String _dropoff = 'Downtown Dubai, Tower 4';

  int get _baseFare  => _vehicles.firstWhere((v) => v.id == _selVehicle).price;
  int get _addonFare {
    int t = 0;
    for (final a in _addonDefs) {
      if (_addons.contains(a.id)) t += a.price;
    }
    return t;
  }
  int get _totalFare => _baseFare + _addonFare;

  Future<void> _openLocationPicker(bool isPickup) async {
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

  @override
  Widget build(BuildContext context) {
    final top    = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F0),
      body: Stack(children: [
        Column(children: [
          _buildHeader(top),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 96 + bottom),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Map + route card (route overlaps map by 26px; stack grows with card)
                Stack(children: [
                  Positioned(top: 0, left: 0, right: 0, height: 170, child: _buildMap()),
                  Column(children: [
                    const SizedBox(height: 144),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: _buildRouteCard(),
                    ),
                  ]),
                ]),
                // Package details
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                  child: _buildPackageCard(),
                ),
                // Vehicles
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Select Vehicle', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900, color: _i9, letterSpacing: -0.3)),
                    const SizedBox(height: 2),
                    Text('Pricing updates with your choice', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: _i4)),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                  child: Column(children: _vehicles.map((v) => Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: _buildVehicleCard(v),
                  )).toList()),
                ),
                // Add-ons
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                  child: Text('Add-ons', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900, color: _i9, letterSpacing: -0.3)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                  child: Wrap(spacing: 9, runSpacing: 9, children: _addonDefs.map((a) => _buildAddon(a)).toList()),
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ]),
        // Footer
        Positioned(bottom: 0, left: 0, right: 0, child: _buildFooter(bottom)),
      ]),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(double top) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, top, 0, 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.9, -0.5),
          end: Alignment(-0.3, 1.2),
          colors: [_dk7, _dk9],
        ),
      ),
      child: Column(children: [
        // Status bar row
        SizedBox(
          height: 46,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('15:59', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
              Row(children: [
                const Icon(Icons.signal_cellular_alt, color: Colors.white, size: 17),
                const SizedBox(width: 7),
                const Icon(Icons.wifi, color: Colors.white, size: 16),
                const SizedBox(width: 7),
                const Icon(Icons.battery_full, color: Colors.white, size: 17),
              ]),
            ]),
          ),
        ),
        // App bar
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
          child: Row(children: [
            // Back button
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 22),
              ),
            ),
            const SizedBox(width: 14),
            Text('Porter & Logistics', style: GoogleFonts.nunito(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3)),
            const Spacer(),
            // ELK Logo
            SvgPicture.asset('assets/icons/elk_logo.svg', height: 24),
          ]),
        ),
      ]),
    );
  }

  // ─── Map (170px) ──────────────────────────────────────────────────────────

  Widget _buildMap() {
    return SizedBox(
      height: 170,
      child: Stack(children: [
        CustomPaint(painter: _PorterMapPainter(), child: const SizedBox.expand()),
        // ETA pill
        Positioned(
          left: 16, bottom: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), boxShadow: const [BoxShadow(color: Color(0x1A143228), blurRadius: 26, offset: Offset(0, 10))]),
            child: Row(children: [
              Container(width: 7, height: 7, decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle)),
              const SizedBox(width: 7),
              Text('18 min · 4.2 km', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 13, color: _i9)),
            ]),
          ),
        ),
      ]),
    );
  }

  // ─── Route card (overlaps map) ────────────────────────────────────────────

  Widget _buildRouteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
        boxShadow: const [BoxShadow(color: Color(0x0F143228), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Dot rail
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(children: [
            Container(width: 11, height: 11, decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle)),
            Container(width: 2, height: 26, color: const Color(0xFFD9E0DB), margin: const EdgeInsets.symmetric(vertical: 3)),
            Container(width: 11, height: 11, decoration: const BoxDecoration(color: _red, shape: BoxShape.circle)),
          ]),
        ),
        const SizedBox(width: 13),
        // Addresses
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: () => _openLocationPicker(true),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('PICKUP LOCATION', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: _i4, letterSpacing: 0.2)),
              const SizedBox(height: 2),
              Text(_pickup, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w500, color: _i9, height: 1.3)),
            ]),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => _openLocationPicker(false),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('DROP LOCATION', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: _i4, letterSpacing: 0.2)),
              const SizedBox(height: 2),
              Text(_dropoff, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w500, color: _i9, height: 1.3)),
            ]),
          ),
        ])),
        const SizedBox(width: 13),
        // Edit button
        GestureDetector(
          onTap: () => _openLocationPicker(true),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: _t05, borderRadius: BorderRadius.circular(11)),
            child: const Icon(Icons.edit_outlined, color: _tDk, size: 17),
          ),
        ),
      ]),
    );
  }

  // ─── Package details card ─────────────────────────────────────────────────

  Widget _buildPackageCard() {
    const rows = [
      ('Package Type', 'Electronics', true),
      ('Weight', '2.5 kg', false),
      ('Distance', '4.2 km', false),
      ('Estimated Time', '18 mins', false),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
        boxShadow: const [BoxShadow(color: Color(0x0F143228), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final (key, val, isChip) = e.value;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              border: e.key > 0 ? const Border(top: BorderSide(color: _line)) : null,
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(key, style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w600, color: _i5)),
              isChip
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: _t05, borderRadius: BorderRadius.circular(999)),
                      child: Text(val, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: _tDk)),
                    )
                  : Text(val, style: GoogleFonts.plusJakartaSans(fontSize: 14.5, fontWeight: FontWeight.w800, color: _i9)),
            ]),
          );
        }).toList(),
      ),
    );
  }

  // ─── Vehicle card ─────────────────────────────────────────────────────────

  Widget _buildVehicleCard(({String id, String name, String svg, String cap, int eta, int price, String? badge}) v) {
    final sel = _selVehicle == v.id;
    return GestureDetector(
      onTap: () => setState(() => _selVehicle = v.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: sel ? null : Colors.white,
          gradient: sel ? const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [_t05, Colors.white]) : null,
          border: Border.all(color: sel ? _teal : _line, width: 2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(children: [
          SvgPicture.asset(v.svg, width: 80, height: 52),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(v.name, style: GoogleFonts.nunito(fontSize: 16.5, fontWeight: FontWeight.w900, color: _i9, letterSpacing: -0.2)),
              if (v.badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFFEF3C9), borderRadius: BorderRadius.circular(6)),
                  child: Text(v.badge!, style: GoogleFonts.nunito(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF9A7400), letterSpacing: 0.4)),
                ),
              ],
            ]),
            const SizedBox(height: 3),
            Text(v.cap, style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: _i4)),
            const SizedBox(height: 3),
            Row(children: [
              const Icon(Icons.schedule_rounded, size: 12, color: _i4),
              const SizedBox(width: 5),
              Text('${v.eta} min arrival', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: _i4)),
            ]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('AED ${v.price}', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900, color: _i9)),
            const SizedBox(height: 9),
            // Radio button
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: sel ? _teal : const Color(0xFFCFD8D2), width: 2),
                color: sel ? _teal.withValues(alpha: 0.1) : Colors.transparent,
              ),
              child: sel ? Center(child: Container(width: 11, height: 11, decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle))) : null,
            ),
          ]),
        ]),
      ),
    );
  }

  // ─── Add-on chip ──────────────────────────────────────────────────────────

  Widget _buildAddon(({String id, String label, int price}) a) {
    final on = _addons.contains(a.id);
    return GestureDetector(
      onTap: () => setState(() {
        if (on) { _addons.remove(a.id); } else { _addons.add(a.id); }
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: on ? _t05 : Colors.white,
          border: Border.all(color: on ? _teal : _line, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          // Checkbox
          Container(
            width: 18, height: 18,
            decoration: BoxDecoration(
              color: on ? _teal : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: on ? _teal : const Color(0xFFCFD8D2), width: 1.6),
            ),
            child: on ? const Icon(Icons.check_rounded, size: 11, color: Colors.white) : null,
          ),
          const SizedBox(width: 8),
          Text(a.label, style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w800, color: on ? _tDk : _i7)),
          const SizedBox(width: 6),
          Text('+AED ${a.price}', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: on ? _tDk : _i4)),
        ]),
      ),
    );
  }

  // ─── Footer ───────────────────────────────────────────────────────────────

  Widget _buildFooter(double bottom) {
    return Container(
      padding: EdgeInsets.fromLTRB(18, 12, 18, 12 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _line)),
        boxShadow: [BoxShadow(color: Color(0x14102818), blurRadius: 18, offset: Offset(0, -6))],
      ),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Estimated Fare', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: _i4)),
          const SizedBox(height: 1),
          Text('AED $_totalFare', style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w900, color: _i9, letterSpacing: -0.5)),
        ]),
        const SizedBox(width: 14),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PorterBookingFlow(
                  pickup: _pickup,
                  dropoff: _dropoff,
                  vehicleName: _vehicles.firstWhere((v) => v.id == _selVehicle).name,
                  fare: _totalFare,
                  onTrack: widget.onTrack,
                ),
              ),
            ),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_teal, _tDk]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Color(0x520A5A42), blurRadius: 22, offset: Offset(0, 10))],
              ),
              child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Book Porter', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
              ])),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── Porter map painter ────────────────────────────────────────────────────────

class _PorterMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final W = size.width;
    final H = size.height;
    final sx = W / 392.0;
    final sy = H / 170.0;

    canvas.drawRect(Rect.fromLTWH(0, 0, W, H), Paint()..color = const Color(0xFFE9EEEA));

    // Parks
    canvas.drawRect(Rect.fromLTRB(-20*sx, 90*sy, 130*sx, H+10), Paint()..color = const Color(0xFFDCEBDD));
    canvas.drawRect(Rect.fromLTRB(250*sx, -10*sy, W+10, 80*sy),  Paint()..color = const Color(0xFFDCEBDD));

    // Water
    final water = Path()
      ..moveTo(0, 24*sy)
      ..quadraticBezierTo(120*sx, 50*sy, W, 18*sy)
      ..lineTo(W, 0)..lineTo(0, 0)..close();
    canvas.drawPath(water, Paint()..color = const Color(0xFFCFE6EC));

    // Roads
    final rp = Paint()..color = Colors.white..strokeWidth = 9*sx..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(-10*sx, 70*sy),  Offset(W+10, 86*sy), rp);
    canvas.drawLine(Offset(70*sx, -10*sy),  Offset(120*sx, H+10), rp);
    canvas.drawLine(Offset(300*sx, -10*sy), Offset(250*sx, H+10), rp);

    final op = Paint()..color = const Color(0xFFD7DED8)..strokeWidth = 2*sx..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(-10*sx, 70*sy),  Offset(W+10, 86*sy), op);
    canvas.drawLine(Offset(70*sx, -10*sy),  Offset(120*sx, H+10), op);
    canvas.drawLine(Offset(300*sx, -10*sy), Offset(250*sx, H+10), op);

    // Route: M84,128 C140,100 150,80 210,66 C260,56 290,52 312,50
    final route = Path()
      ..moveTo(84*sx, 128*sy)
      ..cubicTo(140*sx, 100*sy, 150*sx, 80*sy,  210*sx, 66*sy)
      ..cubicTo(260*sx, 56*sy,  290*sx, 52*sy,  312*sx, 50*sy);
    canvas.drawPath(route, Paint()..color = const Color(0xFF137A6D)..strokeWidth = 6*sx..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    canvas.drawPath(route, Paint()..color = const Color(0xFF37C9AD)..strokeWidth = 3*sx..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);

    // Pickup pin (84,128)
    canvas.drawCircle(Offset(84*sx, 128*sy), 10*sx, Paint()..color = const Color(0xFF18927F));
    canvas.drawCircle(Offset(84*sx, 128*sy), 4*sx,  Paint()..color = Colors.white);

    // Drop pin teardrop (312,50)
    final dx = 312*sx, dy = 50*sy, ps = sx;
    final pin = Path()
      ..moveTo(dx, dy - 20*ps)
      ..cubicTo(dx+9*ps, dy-20*ps, dx+15*ps, dy-14*ps, dx+15*ps, dy-6*ps)
      ..cubicTo(dx+15*ps, dy+2*ps, dx, dy+13*ps, dx, dy+13*ps)
      ..cubicTo(dx, dy+13*ps, dx-15*ps, dy+2*ps, dx-15*ps, dy-6*ps)
      ..cubicTo(dx-15*ps, dy-14*ps, dx-9*ps, dy-20*ps, dx, dy-20*ps)
      ..close();
    canvas.drawPath(pin, Paint()..color = const Color(0xFFE2554C));
    canvas.drawCircle(Offset(dx, dy-6*ps), 4.5*ps, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_) => false;
}
