
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/app_localizations.dart';
import '../cubit/porter_cubit.dart';

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

String _aed(double n) => '₹${n.toStringAsFixed(2)}';


enum _Sn { schedule, payment, card, processing, success }

// ─── Flow ─────────────────────────────────────────────────────────────────────
class PorterBookingFlow extends StatefulWidget {
  const PorterBookingFlow({super.key, this.onTrack});

  final VoidCallback? onTrack;

  @override
  State<PorterBookingFlow> createState() => _PorterBookingFlowState();
}

class _PorterBookingFlowState extends State<PorterBookingFlow> {
  AppLocalizations get l10n => AppLocalizations.of(context);

  _Sn _screen = _Sn.schedule;

  PorterCubit get _cubit => context.read<PorterCubit>();

  /// Route, vehicle and pricing all live in the shared cubit.
  String get _pickup => _cubit.state.pickupAddress;
  String get _dropoff => _cubit.state.dropAddress;
  String get _vehicleName => _cubit.state.selectedVehicle?.name ?? '';
  double get _fare => _cubit.state.fareBeforeFees;
  List<String> get _slots => _cubit.state.page?.pickupWindows ?? const [];

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

  double get _serviceFee => _cubit.state.serviceFee;
  double get _vat => _cubit.state.vatAmount;
  double get _total => _cubit.state.totalAmount;

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

  /// Sends the chosen date + window to the cubit (both are required before
  /// the backend treats the delivery as scheduled).
  void _syncSchedule() {
    final date = _date;
    final slotValid = _slot >= 0 && _slot < _slots.length;
    if (date == null || !slotValid) return;
    final iso = '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    _cubit.setSchedule(date: iso, window: _slots[_slot]);
  }

  Future<void> _startProcessing() async {
    setState(() => _screen = _Sn.processing);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await _cubit.bookPorter();
    if (!mounted) return;
    if (!ok) {
      setState(() => _screen = _Sn.payment);
      messenger.showSnackBar(SnackBar(
        content: Text(_cubit.state.bookingError ?? l10n.couldNotBookDelivery),
      ));
      return;
    }
    setState(() {
      _screen = _Sn.success;
      _trackingId = _cubit.state.booking!.code;
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
        Text(l10n.bookPorter, style: _t(sz: 15, c: Colors.white)),
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
          Text(l10n.stepSchedule, style: _t(sz: 11, c: _muted)),
          Text(l10n.sectionPayment, style: _t(sz: 11, c: _muted)),
          Text(l10n.commonConfirm, style: _t(sz: 11, c: _muted)),
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
          _schedTab(l10n.pickUpNow, false),
          _schedTab(l10n.scheduleForLater, true),
        ]),
      ),
      if (_later) ...[
        const SizedBox(height: 16),
        Text(l10n.pickupDate, style: _t(sz: 12, c: _muted)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: _date ?? DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 30)),
            );
            if (d != null) {
              setState(() => _date = d);
              _syncSchedule();
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _date == null
                  ? l10n.selectDateAction
                  : DateFormat('d MMM yyyy', l10n.localeName).format(_date!),
              style: _t(sz: 13, c: _date == null ? _muted : _ink),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(l10n.pickupWindow, style: _t(sz: 12, c: _muted)),
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
              onTap: () {
                setState(() => _slot = i);
                _syncSchedule();
              },
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
                Text(l10n.pickupLocation, style: _t(sz: 11, c: _muted)),
                const SizedBox(height: 2),
                Text(_pickup, style: _t(sz: 13)),
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
                Text(l10n.dropLocation, style: _t(sz: 11, c: _muted)),
                const SizedBox(height: 2),
                Text(_dropoff, style: _t(sz: 13)),
              ]),
            ),
          ]),
        ]),
      ),
      const SizedBox(height: 14),
      Row(children: [
        _statTile(l10n.distance, '4.2 km'),
        const SizedBox(width: 8),
        _statTile(l10n.estTime, '18 mins'),
      ]),
      const SizedBox(height: 16),
      _cta(l10n.continueToPayment, () => setState(() => _screen = _Sn.payment)),
    ]);
  }

  Widget _schedTab(String label, bool later) {
    final on = _later == later;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _later = later);
          if (later) {
            _syncSchedule();
          } else {
            _cubit.clearSchedule();
          }
        },
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
        child: Text(l10n.selectPaymentMethod, style: _t(sz: 13, c: _txt2)),
      ),
      _payOpt('wallet', Icons.account_balance_wallet_outlined, l10n.payElkWallet, sub: 'Balance ₹120.00'),
      _payOpt('card', Icons.credit_card, l10n.payCard, sub: l10n.payCardBrandsShort),
      _payOpt('apple', Icons.apple, l10n.payApplePay),
      _payOpt('cash', Icons.payments_outlined, l10n.payCashOnDelivery),
      const SizedBox(height: 8),
      // breakdown
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: _surface1, borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          _feeRow(l10n.deliveryFare, _aed(_fare)),
          const SizedBox(height: 6),
          _feeRow(l10n.serviceFee, _aed(_serviceFee)),
          const SizedBox(height: 6),
          _feeRow(l10n.gstFivePercent, _aed(_vat)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: _border, height: 1),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(l10n.total, style: _t(sz: 14)),
            Text(_aed(_total), style: _t(sz: 14)),
          ]),
        ]),
      ),
      const SizedBox(height: 16),
      _cta(
        _pay == 'card' ? l10n.continueToCardDetails : l10n.payAmount(_aed(_total)),
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
      _field(l10n.cardNumber, _numCtrl, '4242 4242 4242 4242'),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _field(l10n.cardExpiry, _expCtrl, 'MM / YY')),
        const SizedBox(width: 10),
        Expanded(child: _field(l10n.cardCvv, _cvvCtrl, '•••')),
      ]),
      const SizedBox(height: 12),
      _field(l10n.nameOnCard, _nameCtrl, l10n.cardAsShown),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: _surface1, borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(l10n.amount, style: _t(sz: 14)),
          Text(_aed(_total), style: _t(sz: 14)),
        ]),
      ),
      const SizedBox(height: 16),
      _cta(l10n.confirmAndPay, () {
        final digits = _numCtrl.text.replaceAll(RegExp(r'\D'), '');
        if (digits.length < 16 || _expCtrl.text.isEmpty || _cvvCtrl.text.length < 3 || _nameCtrl.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.completeCardDetails)),
          );
          return;
        }
        _startProcessing();
      }),
      const SizedBox(height: 10),
      Center(child: Text(l10n.paymentsSecuredByElk, style: _t(sz: 11, c: _muted))),
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
        Text(l10n.processingPayment, style: _t(sz: 14)),
        const SizedBox(height: 4),
        Text(l10n.confirmingWithBank,
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
        Text(l10n.bookingConfirmed, style: _t(sz: 16)),
        const SizedBox(height: 4),
        Text(l10n.porterNotified, style: _t(sz: 12, c: _muted)),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: _surface1, borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            _detailRow(l10n.trackingId, _trackingId, mono: true),
            const SizedBox(height: 8),
            _detailRow(l10n.vehicle, _vehicleName),
            const SizedBox(height: 8),
            _detailRow(l10n.arrival, '12 mins'),
            const SizedBox(height: 8),
            _detailRow(l10n.amountPaid, _aed(_total), bold: true),
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
            SnackBar(content: Text(l10n.receiptSentToEmail)),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: _borderStrong),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(l10n.viewReceipt, style: _t(sz: 14, c: _txt2))),
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
