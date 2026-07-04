import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Design tokens (from elk_porter_booking_flow.html) ────────────────────────
const _headerDark = Color(0xFF0B3B36);
const _green = Color(0xFF0F6E56);
const _mint = Color(0xFFE1F5EE);
const _mintLogo = Color(0xFF5DCAA5);
const _gold = Color(0xFFF0B429);
const _dropPin = Color(0xFFD85A30);
const _surface1 = Color(0xFFF4F3EE);
const _surface2 = Colors.white;
const _chipIdle = Color(0xFFF1EFE8);
const _border = Color(0xFFE5E3DB);
const _borderStrong = Color(0xFFC9C7BE);
const _ink = Color(0xFF1E2421);
const _txt2 = Color(0xFF4E554F);
const _muted = Color(0xFF888780);

TextStyle _t({double sz = 13, FontWeight w = FontWeight.w500, Color c = _ink, double h = 1.35}) =>
    GoogleFonts.inter(fontSize: sz, fontWeight: w, color: c, height: h);

String _aed(double n) => 'AED ${n.toStringAsFixed(2)}';

const _slots = ['9:00 – 10:00', '11:00 – 12:00', '2:00 – 3:00 pm', '4:00 – 5:00 pm'];
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

enum _Sn { schedule, payment, card, processing, success }

// ─── Flow ─────────────────────────────────────────────────────────────────────
class PorterBookingFlow extends StatefulWidget {
  const PorterBookingFlow({
    super.key,
    required this.pickup,
    required this.dropoff,
    required this.vehicleName,
    required this.fare,
    this.onTrack,
  });

  final String pickup, dropoff, vehicleName;
  final int fare;
  final VoidCallback? onTrack;

  @override
  State<PorterBookingFlow> createState() => _PorterBookingFlowState();
}

class _PorterBookingFlowState extends State<PorterBookingFlow> {
  _Sn _screen = _Sn.schedule;

  // schedule
  bool _later = false;
  DateTime? _date;
  int _slot = -1;

  // payment
  String _pay = 'wallet';

  // card form
  final _numCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  // success
  String _trackingId = '';

  double get _serviceFee => 3.5;
  double get _vat => (widget.fare + _serviceFee) * 0.05;
  double get _total => widget.fare + _serviceFee + _vat;

  @override
  void dispose() {
    _numCtrl.dispose();
    _expCtrl.dispose();
    _cvvCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  int get _railStep => switch (_screen) {
        _Sn.schedule => 0,
        _Sn.payment || _Sn.card || _Sn.processing => 1,
        _Sn.success => 2,
      };

  void _back() {
    switch (_screen) {
      case _Sn.schedule:
        Navigator.pop(context);
      case _Sn.payment:
        setState(() => _screen = _Sn.schedule);
      case _Sn.card:
        setState(() => _screen = _Sn.payment);
      case _Sn.processing:
        break; // don't interrupt
      case _Sn.success:
        Navigator.pop(context);
    }
  }

  void _startProcessing() {
    setState(() => _screen = _Sn.processing);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      final rng = math.Random();
      final letters = String.fromCharCodes(
          List.generate(2, (_) => 65 + rng.nextInt(26)));
      setState(() {
        _screen = _Sn.success;
        _trackingId = 'ELK-${1000 + rng.nextInt(8999)}-$letters';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) => _back(),
      child: Scaffold(
        backgroundColor: _surface2,
        body: Column(children: [
          _appBar(),
          _rail(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
              child: SingleChildScrollView(
                key: ValueKey(_screen),
                padding: EdgeInsets.fromLTRB(16, 4, 16, bottom + 20),
                child: switch (_screen) {
                  _Sn.schedule => _scheduleScreen(),
                  _Sn.payment => _paymentScreen(),
                  _Sn.card => _cardScreen(),
                  _Sn.processing => _processingScreen(),
                  _Sn.success => _successScreen(),
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ─── app bar ────────────────────────────────────────────────────────────
  Widget _appBar() {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: _headerDark,
      padding: EdgeInsets.fromLTRB(16, top + 12, 16, 14),
      child: Row(children: [
        GestureDetector(
          onTap: _back,
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Text('Book porter', style: _t(sz: 15, c: Colors.white)),
        const Spacer(),
        Text.rich(TextSpan(children: [
          TextSpan(text: 'EL', style: _t(sz: 16, c: _mintLogo)),
          TextSpan(text: '.', style: _t(sz: 16, c: Colors.white)),
          TextSpan(text: 'K', style: _t(sz: 16, c: _gold)),
        ])),
      ]),
    );
  }

  // ─── step rail ──────────────────────────────────────────────────────────
  Widget _rail() {
    Widget dot(int i) {
      final done = i < _railStep;
      final active = i == _railStep;
      return Container(
        width: 22, height: 22,
        decoration: BoxDecoration(
          color: done || active ? _green : _chipIdle,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: done
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : Text('${i + 1}',
                  style: _t(sz: 11, c: active ? Colors.white : _muted)),
        ),
      );
    }

    Widget seg(bool done) => Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            color: done ? _green : _chipIdle,
          ),
        );

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
        child: Row(children: [
          dot(0),
          seg(_railStep > 0),
          dot(1),
          seg(_railStep > 1),
          dot(2),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Schedule', style: _t(sz: 11, c: _muted)),
          Text('Payment', style: _t(sz: 11, c: _muted)),
          Text('Confirm', style: _t(sz: 11, c: _muted)),
        ]),
      ),
    ]);
  }

  // ═══ SCHEDULE ═════════════════════════════════════════════════════════════
  Widget _scheduleScreen() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // now / later tabs
      Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: _surface1, borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          _schedTab('Pick up now', false),
          _schedTab('Schedule for later', true),
        ]),
      ),
      if (_later) ...[
        const SizedBox(height: 16),
        Text('Pickup date', style: _t(sz: 12, c: _muted)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: _date ?? DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 30)),
            );
            if (d != null) setState(() => _date = d);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _date == null ? 'Select date' : '${_date!.day} ${_months[_date!.month - 1]} ${_date!.year}',
              style: _t(sz: 13, c: _date == null ? _muted : _ink),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text('Pickup window', style: _t(sz: 12, c: _muted)),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 4.4,
          children: List.generate(_slots.length, (i) {
            final on = _slot == i;
            return GestureDetector(
              onTap: () => setState(() => _slot = i),
              child: Container(
                decoration: BoxDecoration(
                  color: on ? _green : Colors.transparent,
                  border: Border.all(color: on ? _green : _border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(_slots[i], style: _t(sz: 13, c: on ? Colors.white : _ink)),
                ),
              ),
            );
          }),
        ),
      ],
      const SizedBox(height: 16),
      // locations
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: _surface1, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(
              padding: EdgeInsets.only(top: 3),
              child: Icon(Icons.circle, size: 12, color: _green),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Pickup location', style: _t(sz: 11, c: _muted)),
                const SizedBox(height: 2),
                Text(widget.pickup, style: _t(sz: 13)),
              ]),
            ),
          ]),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(Icons.location_on, size: 14, color: _dropPin),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Drop location', style: _t(sz: 11, c: _muted)),
                const SizedBox(height: 2),
                Text(widget.dropoff, style: _t(sz: 13)),
              ]),
            ),
          ]),
        ]),
      ),
      const SizedBox(height: 14),
      Row(children: [
        _statTile('Distance', '4.2 km'),
        const SizedBox(width: 8),
        _statTile('Est. time', '18 mins'),
      ]),
      const SizedBox(height: 16),
      _cta('Continue to payment', () => setState(() => _screen = _Sn.payment)),
    ]);
  }

  Widget _schedTab(String label, bool later) {
    final on = _later == later;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _later = later),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: on ? _green : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: Text(label, style: _t(sz: 13, c: on ? Colors.white : _txt2))),
        ),
      ),
    );
  }

  Widget _statTile(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: _surface1, borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Text(label, style: _t(sz: 11, c: _muted)),
          const SizedBox(height: 2),
          Text(value, style: _t(sz: 14)),
        ]),
      ),
    );
  }

  // ═══ PAYMENT ═════════════════════════════════════════════════════════════
  Widget _paymentScreen() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 10),
        child: Text('Select payment method', style: _t(sz: 13, c: _txt2)),
      ),
      _payOpt('wallet', Icons.account_balance_wallet_outlined, 'ELK wallet', sub: 'Balance AED 120.00'),
      _payOpt('card', Icons.credit_card, 'Credit or debit card', sub: 'Visa, Mastercard'),
      _payOpt('apple', Icons.apple, 'Apple Pay'),
      _payOpt('cash', Icons.payments_outlined, 'Cash on delivery'),
      const SizedBox(height: 8),
      // breakdown
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: _surface1, borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          _feeRow('Delivery fare', _aed(widget.fare.toDouble())),
          const SizedBox(height: 6),
          _feeRow('Service fee', _aed(_serviceFee)),
          const SizedBox(height: 6),
          _feeRow('VAT (5%)', _aed(_vat)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: _border, height: 1),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Total', style: _t(sz: 14)),
            Text(_aed(_total), style: _t(sz: 14)),
          ]),
        ]),
      ),
      const SizedBox(height: 16),
      _cta(
        _pay == 'card' ? 'Continue to card details' : 'Pay ${_aed(_total)}',
        () => _pay == 'card' ? setState(() => _screen = _Sn.card) : _startProcessing(),
      ),
    ]);
  }

  Widget _payOpt(String id, IconData icon, String label, {String? sub}) {
    final on = _pay == id;
    return GestureDetector(
      onTap: () => setState(() => _pay = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: on ? _mint : Colors.transparent,
          border: Border.all(color: on ? _green : _border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: on ? _green : _txt2),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: _t(sz: 13)),
              if (sub != null) ...[
                const SizedBox(height: 2),
                Text(sub, style: _t(sz: 11, c: _muted)),
              ],
            ]),
          ),
          Container(
            width: 16, height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: on ? _green : Colors.transparent,
              border: Border.all(color: on ? _green : _borderStrong, width: 2),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _feeRow(String label, String value) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: _t(sz: 12, c: _txt2)),
      Text(value, style: _t(sz: 12, c: _txt2)),
    ]);
  }

  // ═══ CARD DETAILS ════════════════════════════════════════════════════════
  Widget _cardScreen() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 14),
        child: Row(children: [
          const Icon(Icons.verified_user_outlined, size: 15, color: _green),
          const SizedBox(width: 6),
          Text('256-bit encrypted secure payment', style: _t(sz: 11, c: _muted)),
        ]),
      ),
      _field('Card number', _numCtrl, '4242 4242 4242 4242'),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _field('Expiry', _expCtrl, 'MM / YY')),
        const SizedBox(width: 10),
        Expanded(child: _field('CVV', _cvvCtrl, '•••')),
      ]),
      const SizedBox(height: 12),
      _field('Name on card', _nameCtrl, 'As shown on card'),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: _surface1, borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Amount', style: _t(sz: 14)),
          Text(_aed(_total), style: _t(sz: 14)),
        ]),
      ),
      const SizedBox(height: 16),
      _cta('Confirm and pay', () {
        final digits = _numCtrl.text.replaceAll(RegExp(r'\D'), '');
        if (digits.length < 16 || _expCtrl.text.isEmpty || _cvvCtrl.text.length < 3 || _nameCtrl.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please complete all card details')),
          );
          return;
        }
        _startProcessing();
      }),
      const SizedBox(height: 10),
      Center(child: Text('Payments secured by ELK gateway', style: _t(sz: 11, c: _muted))),
    ]);
  }

  Widget _field(String label, TextEditingController ctrl, String hint) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: _t(sz: 12, c: _muted)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        style: _t(sz: 13),
        cursorColor: _green,
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: _t(sz: 13, c: _muted),
          filled: false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _green, width: 1.5),
          ),
        ),
      ),
    ]);
  }

  // ═══ PROCESSING ══════════════════════════════════════════════════════════
  Widget _processingScreen() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 48),
      child: Column(children: [
        const SizedBox(
          width: 44, height: 44,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: _green,
            backgroundColor: _mint,
          ),
        ),
        const SizedBox(height: 18),
        Text('Processing payment', style: _t(sz: 14)),
        const SizedBox(height: 4),
        Text('Confirming with your bank, do not close this screen',
            textAlign: TextAlign.center, style: _t(sz: 12, c: _muted)),
      ]),
    );
  }

  // ═══ SUCCESS ═════════════════════════════════════════════════════════════
  Widget _successScreen() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(children: [
        Container(
          width: 52, height: 52,
          decoration: const BoxDecoration(color: _mint, shape: BoxShape.circle),
          child: const Icon(Icons.check, size: 26, color: _green),
        ),
        const SizedBox(height: 14),
        Text('Booking confirmed', style: _t(sz: 16)),
        const SizedBox(height: 4),
        Text('Your porter has been notified', style: _t(sz: 12, c: _muted)),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: _surface1, borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            _detailRow('Tracking ID', _trackingId, mono: true),
            const SizedBox(height: 8),
            _detailRow('Rider', 'Farhan A. · ${widget.vehicleName}'),
            const SizedBox(height: 8),
            _detailRow('Arrival', '12 mins'),
            const SizedBox(height: 8),
            _detailRow('Amount paid', _aed(_total), bold: true),
          ]),
        ),
        const SizedBox(height: 14),
        _cta('Track delivery →', () {
          Navigator.pop(context);
          widget.onTrack?.call();
        }),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Receipt sent to your email')),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: _borderStrong),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text('View receipt →', style: _t(sz: 14, c: _txt2))),
          ),
        ),
      ]),
    );
  }

  Widget _detailRow(String label, String value, {bool mono = false, bool bold = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: _t(sz: 12, c: _muted)),
      Text(
        value,
        style: mono
            ? GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w500, color: _ink)
            : _t(sz: 12, w: bold ? FontWeight.w600 : FontWeight.w500),
      ),
    ]);
  }

  // ─── shared CTA ───────────────────────────────────────────────────────────
  Widget _cta(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(10)),
        child: Center(child: Text(label, style: _t(sz: 14, c: Colors.white))),
      ),
    );
  }
}
