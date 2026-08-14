import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_preferences.dart';

import '../../../data/models/rental_models.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/location/current_location.dart';
import '../../../core/widgets/live_map_view.dart';
import '../../../data/repositories/places_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../cubit/rental_booking_cubit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Design tokens (from ELK Car Rental flow HTML) ────────────────────────────
const _ink950 = Color(0xFF0E2A1C);
const _forest900 = Color(0xFF123420);
const _forest800 = Color(0xFF183D28);
const _teal700 = Color(0xFF1F7A50);
const _teal600 = Color(0xFF238055);
const _teal500 = Color(0xFF2FA06A);
const _mint300 = Color(0xFF8FEFC9);
const _mint100 = Color(0xFFDFF7EC);
const _gold500 = Color(0xFFF0C419);
const _gold600 = Color(0xFFDDAE0E);
const _sand50 = Color(0xFFF1F5EE);
const _sand100 = Color(0xFFE8EFE4);
const _ink800 = Color(0xFF16281F);
const _slate600 = Color(0xFF5C6B62);
const _slate500 = Color(0xFF788A80);
const _slate400 = Color(0xFF9CAA9C);
const _slate300 = Color(0xFFC4D0C0);
const _slate200 = Color(0xFFDDE6D9);
const _danger = Color(0xFFE1554F);

TextStyle _pop({double sz = 14, FontWeight w = FontWeight.w700, Color c = _ink800, double sp = 0}) =>
    GoogleFonts.poppins(fontSize: sz, fontWeight: w, color: c, letterSpacing: sp);

TextStyle _int({double sz = 13, FontWeight w = FontWeight.w500, Color c = _ink800, double h = 1.4}) =>
    GoogleFonts.inter(fontSize: sz, fontWeight: w, color: c, height: h);

// ─── Static data ──────────────────────────────────────────────────────────────
List<String> _stepTitlesFor(AppLocalizations l10n) => [
      l10n.stepTripDetails,
      l10n.stepPickupDelivery,
      l10n.stepExtrasProtection,
      l10n.reviewConfirm,
      l10n.sectionPayment,
    ];

List<String> _stepLabelsFor(AppLocalizations l10n) =>
    [l10n.trip, l10n.stepLocation, l10n.stepExtras, l10n.stepReview, l10n.stepPay];

const _rateMult = {'daily': 1.0, 'weekly': 0.85, 'monthly': 0.7};
const _deliveryFee = 25;
const _vatRate = 0.05;

/// Icons for the extras catalog, keyed by the backend's `key` field.
const _extraIcons = <String, IconData>{
  'protection': Icons.shield_outlined,
  'driver': Icons.person_add_alt_outlined,
  'seat': Icons.event_seat_outlined,
  'wifi': Icons.wifi_rounded,
};


String _fmtDate(DateTime d, AppLocalizations l10n) =>
    DateFormat('d MMM', l10n.localeName).format(d);
String _fmtTime(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
String _money(num n) => '₹${n.round()}';

// ─── Flow screen ──────────────────────────────────────────────────────────────
class RentalBookingFlow extends StatefulWidget {
  const RentalBookingFlow({
    super.key,
    required this.carId,
    required this.carName,
    required this.dayRate,
    required this.carSvg,
    required this.seats,
    required this.trans,
    required this.fuel,
    this.badge,
  });

  /// Backend car id — every quote/booking request is keyed on it.
  final String carId;
  final String carName;
  final int dayRate;
  final String carSvg;
  final int seats;
  final String trans, fuel;
  final String? badge;

  @override
  State<RentalBookingFlow> createState() => _RentalBookingFlowState();
}

class _RentalBookingFlowState extends State<RentalBookingFlow>
    with SingleTickerProviderStateMixin {
  AppLocalizations get l10n => AppLocalizations.of(context);

  /// True while the GPS fix is being taken and reverse-geocoded.
  bool _locating = false;

  /// Fills the delivery address from the device's real position.
  ///
  /// This used to assign a hardcoded "Koramangala, Bengaluru" without reading
  /// GPS at all, so every user was told they were in Bengaluru.
  Future<void> _fillCurrentLocation() async {
    setState(() => _locating = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final place = await resolveCurrentLocation(context.read<PlacesRepository>());
      if (!mounted) return;
      setState(() {
        _addrCtrl.text = place.formattedAddress;
        _locating = false;
      });
      messenger.showSnackBar(SnackBar(content: Text(l10n.locationCaptured)));
    } on LocationUnavailable catch (e) {
      if (!mounted) return;
      setState(() => _locating = false);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _locating = false);
      messenger.showSnackBar(SnackBar(content: Text(friendlyErrorMessage(e))));
    }
  }
  List<String> get stepTitles => _stepTitlesFor(l10n);
  List<String> get stepLabels => _stepLabelsFor(l10n);

  int _step = 0;

  // step 1
  String _type = 'daily';
  late DateTime _pickupDate = DateTime.now().add(const Duration(days: 1));
  late DateTime _returnDate = DateTime.now().add(const Duration(days: 4));
  TimeOfDay _pickupTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _returnTime = const TimeOfDay(hour: 10, minute: 0);

  // step 2
  String _fulfil = 'pickup';
  final _addrCtrl = TextEditingController();
  final _bldgCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  RentalBookingCubit get _cubit => context.read<RentalBookingCubit>();

  /// The signed-in user's own name; the profile is the only source the rental
  /// flow has, and there is no stored phone to show alongside it.
  String get _renterName =>
      context.read<AppPreferences>().userName?.trim().isNotEmpty == true
          ? context.read<AppPreferences>().userName!.trim()
          : l10n.yourAccount;

  String get _renterInitials {
    final parts = _renterName.split(RegExp(r'\s+'));
    final first = parts.first.isNotEmpty ? parts.first[0] : '?';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  // step 4
  bool _agreed = false;
  final _promoCtrl = TextEditingController();
  ({String code, int pct})? _promo;
  String _promoMsg = '';
  bool _promoOk = false;

  // step 5
  String _pay = 'card';
  final _cardNumCtrl = TextEditingController();
  final _cardExpCtrl = TextEditingController();
  final _cardCvvCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  bool _saveCard = false;

  // overlays
  bool _processing = false;
  bool _success = false;
  String _code = '';
  List<bool> _qr = [];

  late final AnimationController _driveCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void initState() {
    super.initState();
    _cubit.loadOptions(widget.carId);
  }

  /// ISO-8601 instants the backend validates the trip window against.
  String _isoAt(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute)
          .toIso8601String();

  /// The quote/booking payload shared by pricing and confirmation.
  Map<String, dynamic> _tripRequest() => {
        'carId': widget.carId,
        'rentalType': _type,
        'pickupAt': _isoAt(_pickupDate, _pickupTime),
        'returnAt': _isoAt(_returnDate, _returnTime),
        'fulfilment': _fulfil,
        if (_fulfil == 'pickup') 'branchId': _cubit.state.selectedBranchId,
        if (_fulfil == 'delivery') ...{
          'deliveryAddress': _addrCtrl.text.trim(),
          'deliveryBuilding': _bldgCtrl.text.trim(),
          'deliveryNotes': _notesCtrl.text.trim(),
        },
      };

  @override
  void dispose() {
    _driveCtrl.dispose();
    _addrCtrl.dispose();
    _bldgCtrl.dispose();
    _notesCtrl.dispose();
    _promoCtrl.dispose();
    _cardNumCtrl.dispose();
    _cardExpCtrl.dispose();
    _cardCvvCtrl.dispose();
    _cardNameCtrl.dispose();
    super.dispose();
  }

  // ─── pricing ──────────────────────────────────────────────────────────────
  int get _days {
    final start = DateTime(_pickupDate.year, _pickupDate.month, _pickupDate.day, _pickupTime.hour, _pickupTime.minute);
    final end = DateTime(_returnDate.year, _returnDate.month, _returnDate.day, _returnTime.hour, _returnTime.minute);
    final d = (end.difference(start).inMinutes / (60 * 24)).ceil();
    return math.max(1, d);
  }

  int get _dailyRate => (widget.dayRate * _rateMult[_type]!).round();
  int get _rentalTotal => _dailyRate * _days;
  int get _delivery => _fulfil == 'delivery' ? _deliveryFee : 0;
  int get _extrasTotal {
    final state = _cubit.state;
    var t = 0;
    for (final e in state.extras) {
      if (state.selectedExtraKeys.contains(e.key)) t += (e.pricePerDay * _days).round();
    }
    return t;
  }

  /// Server-side pricing once the Review step has quoted; the local getters
  /// above mirror the same formula and cover the pre-quote steps.
  RentalBreakdown? get _serverBreakdown => _cubit.state.quote?.breakdown;

  int get _subtotal => _serverBreakdown?.subtotal ?? (_rentalTotal + _delivery + _extrasTotal);
  int get _promoDiscount =>
      _serverBreakdown?.promoDiscount ??
      (_promo == null ? 0 : (_subtotal * _promo!.pct / 100).round());
  int get _vat =>
      _serverBreakdown?.vatAmount ?? ((_subtotal - _promoDiscount) * _vatRate).round();
  int get _total => _serverBreakdown?.totalAmount ?? (_subtotal - _promoDiscount + _vat);

  String get _locationLabel => _fulfil == 'pickup'
      ? l10n.branchSelfPickup(_cubit.state.selectedBranch?.name ?? l10n.branch)
      : 'Delivery to ${_addrCtrl.text}';

  // ─── navigation ───────────────────────────────────────────────────────────
  void _back() {
    if (_success) return;
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  void _next() {
    if (_step == 3 && !_agreed) return;
    if (_step < 4) {
      // Entering Review: re-price the trip server-side.
      if (_step == 2) _cubit.refreshQuote(_tripRequest());
      setState(() => _step++);
    } else {
      _startPayment();
    }
  }

  Future<void> _startPayment() async {
    if (_pay == 'card') {
      final digits = _cardNumCtrl.text.replaceAll(RegExp(r'\D'), '');
      if (digits.length < 16 ||
          _cardExpCtrl.text.length < 5 ||
          _cardCvvCtrl.text.length < 3 ||
          _cardNameCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.completeCardDetails)),
        );
        return;
      }
    }
    setState(() => _processing = true);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await _cubit.confirmBooking({
      ..._tripRequest(),
      'paymentMethod': _pay,
      'agreedToTerms': _agreed,
    });
    if (!mounted) return;
    setState(() => _processing = false);
    if (!ok) {
      messenger.showSnackBar(SnackBar(
        content: Text(_cubit.state.bookingError ?? l10n.paymentFailed),
      ));
      return;
    }
    final rng = math.Random();
    setState(() {
      _success = true;
      _code = _cubit.state.booking!.code;
      // Decorative QR pattern for the ticket — the code above is the real one.
      _qr = List.generate(36, (_) => rng.nextDouble() > 0.52);
    });
  }

  // ─── build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) {
        if (_processing) return;
        if (_success) {
          Navigator.pop(context);
          return;
        }
        _back();
      },
      child: Scaffold(
        backgroundColor: _sand50,
        body: Stack(children: [
          Column(children: [
            _header(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0, 0.03), end: Offset.zero).animate(anim),
                    child: child,
                  ),
                ),
                child: SingleChildScrollView(
                  key: ValueKey(_step),
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
                  child: switch (_step) {
                    0 => _stepTrip(),
                    1 => _stepLocation(),
                    2 => _stepExtras(),
                    3 => _stepReview(),
                    _ => _stepPayment(),
                  },
                ),
              ),
            ),
            _footer(),
          ]),
          if (_processing) _processingOverlay(),
          if (_success) _successOverlay(),
        ]),
      ),
    );
  }

  // ─── header + road stepper ────────────────────────────────────────────────
  Widget _header() {
    final top = MediaQuery.of(context).padding.top;
    final pct = _step / (stepTitles.length - 1);

    return Container(
      padding: EdgeInsets.fromLTRB(20, top + 6, 20, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_ink950, _forest900, _forest800],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: Column(children: [
        Row(children: [
          GestureDetector(
            onTap: _back,
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('STEP ${_step + 1} OF ${stepTitles.length}',
                  style: _int(sz: 11, w: FontWeight.w600, c: _mint300).copyWith(letterSpacing: 0.4)),
              const SizedBox(height: 2),
              Text(stepTitles[_step], style: _pop(sz: 20, w: FontWeight.w700, c: Colors.white, sp: -0.2)),
            ]),
          ),
          Text.rich(TextSpan(children: [
            TextSpan(text: 'EL', style: _pop(sz: 16, w: FontWeight.w800, c: _mint300)),
            TextSpan(text: '.K', style: _pop(sz: 16, w: FontWeight.w800, c: _gold500)),
          ])),
        ]),
        const SizedBox(height: 18),
        // road stepper
        LayoutBuilder(builder: (context, cons) {
          final w = cons.maxWidth;
          return SizedBox(
            height: 26,
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned(
                top: 8, left: 0, right: 0, height: 10,
                child: CustomPaint(painter: _RoadTrackPainter()),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeInOut,
                top: 8, left: 0, height: 10,
                width: w * pct,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_teal500, _mint300]),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeInOut,
                top: -2, left: w * pct - 17,
                child: SvgPicture.asset(widget.carSvg, width: 34, height: 22),
              ),
            ]),
          );
        }),
        const SizedBox(height: 6),
        Row(
          children: List.generate(stepLabels.length, (i) {
            final on = i <= _step;
            return Expanded(
              child: Text(
                stepLabels[i],
                textAlign: i == 0 ? TextAlign.left : (i == stepLabels.length - 1 ? TextAlign.right : TextAlign.center),
                style: _int(sz: 10.5, w: FontWeight.w600, c: on ? Colors.white : Colors.white.withValues(alpha: 0.5)),
              ),
            );
          }),
        ),
      ]),
    );
  }

  // ─── footer CTA ───────────────────────────────────────────────────────────
  Widget _footer() {
    final bottom = MediaQuery.of(context).padding.bottom;
    final disabled = _step == 3 && !_agreed;
    final label = _step == 4 ? l10n.confirmAndPayAmount(_money(_total)) : l10n.commonContinue;

    return Container(
      padding: EdgeInsets.fromLTRB(18, 13, 18, bottom + 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _slate200)),
        boxShadow: [BoxShadow(color: Color(0x0F0E2A1C), blurRadius: 20, offset: Offset(0, -8))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (_step == 4) ...[
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.lock_outline_rounded, size: 12, color: _teal600),
            const SizedBox(width: 6),
            Text(l10n.securedByElkPay, style: _int(sz: 11, c: _slate500)),
          ]),
          const SizedBox(height: 11),
        ],
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.totalSoFar, style: _int(sz: 11, c: _slate500)),
              Text.rich(TextSpan(children: [
                TextSpan(text: _money(_total), style: _pop(sz: 19, w: FontWeight.w800)),
                TextSpan(text: ' · ${l10n.daysCount(_days)}', style: _int(sz: 12, w: FontWeight.w600, c: _slate500)),
              ])),
            ]),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: disabled ? null : _next,
            child: Opacity(
              opacity: disabled ? 0.45 : 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_teal500, _teal700]),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: disabled
                      ? null
                      : const [BoxShadow(color: Color(0x52238055), blurRadius: 22, offset: Offset(0, 10))],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(label, style: _pop(sz: 14.5, w: FontWeight.w700, c: Colors.white)),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 18),
                ]),
              ),
            ),
          ),
        ]),
      ]),
    );
  }

  // ─── shared: car summary card ─────────────────────────────────────────────
  Widget _carCard({required String meta, required String amt, required String unit}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: _cardDeco(),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: _mint100, borderRadius: BorderRadius.circular(13)),
          child: Center(child: SvgPicture.asset(widget.carSvg, width: 38, height: 26)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(widget.carName, style: _pop(sz: 15), overflow: TextOverflow.ellipsis)),
              if (widget.badge != null) ...[
                const SizedBox(width: 7),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_gold500, _gold600]),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(widget.badge!,
                      style: _int(sz: 9, w: FontWeight.w800, c: _ink950).copyWith(letterSpacing: 0.3)),
                ),
              ],
            ]),
            const SizedBox(height: 2),
            Text(meta, style: _int(sz: 12, c: _slate600)),
          ]),
        ),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(amt, style: _pop(sz: 15, c: _teal700)),
          Text(unit, style: _int(sz: 10.5, c: _slate500)),
        ]),
      ]),
    );
  }

  BoxDecoration _cardDeco() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x140E2A1C), blurRadius: 18, offset: Offset(0, 6))],
      );

  Widget _sectionHead(String title, String sub) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: _pop(sz: 18, sp: -0.2)),
      const SizedBox(height: 3),
      Text(sub, style: _int(sz: 13, c: _slate600)),
    ]);
  }

  // ═══ STEP 1 — Trip details ════════════════════════════════════════════════
  Widget _stepTrip() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _carCard(
        meta: '${widget.seats} Seats · ${widget.trans} · ${widget.fuel}',
        amt: _money(widget.dayRate),
        unit: '/day',
      ),
      const SizedBox(height: 18),
      _sectionHead(l10n.whenDoYouNeedIt, l10n.pickPlanAndDates),
      const SizedBox(height: 14),
      Row(children: [
        _pill(l10n.rateDaily, 'daily'),
        const SizedBox(width: 8),
        _pill(l10n.rateWeekly, 'weekly'),
        const SizedBox(width: 8),
        _pill(l10n.rateMonthly, 'monthly'),
      ]),
      const SizedBox(height: 14),
      _dateCard(
        icon: Icons.calendar_today_outlined,
        label: l10n.pickupDateTime,
        sub: l10n.whenRentalBegins,
        date: _pickupDate,
        time: _pickupTime,
        onDate: (d) => setState(() {
          _pickupDate = d;
          if (_returnDate.isBefore(_pickupDate)) _returnDate = _pickupDate;
        }),
        onTime: (t) => setState(() => _pickupTime = t),
      ),
      const SizedBox(height: 12),
      _dateCard(
        icon: Icons.event_repeat_outlined,
        label: l10n.returnDateTime,
        sub: l10n.whenRentalEnds,
        date: _returnDate,
        time: _returnTime,
        firstDate: _pickupDate,
        onDate: (d) => setState(() => _returnDate = d),
        onTime: (t) => setState(() => _returnTime = t),
      ),
      const SizedBox(height: 14),
      // duration strip
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_forest900, _ink950]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          const Icon(Icons.key_rounded, size: 18, color: _mint300),
          const SizedBox(width: 9),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.rentalLength, style: _int(sz: 12.5, c: Colors.white.withValues(alpha: 0.7))),
              Text(l10n.daysCount(_days), style: _pop(sz: 14.5, c: Colors.white)),
            ]),
          ),
          Text(_money(_rentalTotal), style: _pop(sz: 16, c: _gold500)),
        ]),
      ),
      const SizedBox(height: 12),
      _hint(l10n.rentalBillingNote),
    ]);
  }

  Widget _pill(String label, String type) {
    final on = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          decoration: BoxDecoration(
            color: on ? _teal600 : _sand100,
            border: Border.all(color: on ? _teal600 : _slate200),
            borderRadius: BorderRadius.circular(999),
            boxShadow: on ? const [BoxShadow(color: Color(0x47238055), blurRadius: 14, offset: Offset(0, 6))] : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _int(sz: 11.8, w: FontWeight.w600, c: on ? Colors.white : _ink800),
          ),
        ),
      ),
    );
  }

  Widget _dateCard({
    required IconData icon,
    required String label,
    required String sub,
    required DateTime date,
    required TimeOfDay time,
    DateTime? firstDate,
    required ValueChanged<DateTime> onDate,
    required ValueChanged<TimeOfDay> onTime,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDeco(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: _mint100, borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 17, color: _teal600),
          ),
          const SizedBox(width: 9),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: _int(sz: 13, w: FontWeight.w700)),
            Text(sub, style: _int(sz: 11.5, c: _slate500)),
          ]),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: _fieldBox(
              text: _fmtDate(date, l10n),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: firstDate ?? DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (d != null) onDate(d);
              },
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _fieldBox(
              text: _fmtTime(time),
              onTap: () async {
                final t = await showTimePicker(context: context, initialTime: time);
                if (t != null) onTime(t);
              },
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _fieldBox({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        decoration: BoxDecoration(
          color: _sand50,
          border: Border.all(color: _slate200, width: 1.5),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(text, style: _int(sz: 13.5, w: FontWeight.w600)),
      ),
    );
  }

  Widget _hint(String text) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
        padding: EdgeInsets.only(top: 1.5),
        child: Icon(Icons.info_outline_rounded, size: 13, color: _slate400),
      ),
      const SizedBox(width: 6),
      Expanded(child: Text(text, style: _int(sz: 11.5, c: _slate500))),
    ]);
  }

  // ═══ STEP 2 — Pickup or delivery ═════════════════════════════════════════
  Widget _stepLocation() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _carCard(
        meta: '$_days Days · ${_type[0].toUpperCase()}${_type.substring(1)} plan',
        amt: _money(_rentalTotal),
        unit: 'rental',
      ),
      const SizedBox(height: 18),
      _sectionHead(l10n.howGetYourCar, l10n.collectOrDelivered),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _fulfilCard('pickup', Icons.location_city_rounded, l10n.selfPickup, l10n.collectFromBranch, l10n.free, true)),
        const SizedBox(width: 11),
        Expanded(child: _fulfilCard('delivery', Icons.local_shipping_outlined, l10n.carDelivery, l10n.weBringIt, '+₹25', false)),
      ]),
      const SizedBox(height: 16),
      if (_fulfil == 'pickup') ...[
        Text(l10n.chooseBranch, style: _pop(sz: 15)),
        const SizedBox(height: 10),
        for (final b in _cubit.state.branches) ...[
          _branchCard(b),
          const SizedBox(height: 9),
        ],
        const SizedBox(height: 3),
        ?_branchMap(),
      ] else ...[
        _formField(l10n.deliveryAddress, _addrCtrl, hint: l10n.deliveryAddressHint),
        const SizedBox(height: 11),
        _formField(l10n.buildingVillaNo, _bldgCtrl, hint: 'Tower B, Apt 1204'),
        const SizedBox(height: 11),
        _formField(l10n.driverDirections, _notesCtrl, hint: l10n.driverDirectionsHint, lines: 2),
        const SizedBox(height: 11),
        GestureDetector(
          onTap: _locating ? null : _fillCurrentLocation,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: _sand100,
              border: Border.all(color: _slate200, width: 1.5),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (_locating)
                const SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(strokeWidth: 2, color: _teal700),
                )
              else
                const Icon(Icons.my_location_rounded, size: 15, color: _teal700),
              const SizedBox(width: 7),
              Text(
                _locating ? l10n.locating : l10n.useCurrentLocation,
                style: _int(sz: 12.5, w: FontWeight.w700, c: _teal700),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        _hint(l10n.deliveryFeeNote),
      ],
    ]);
  }

  Widget _fulfilCard(String id, IconData icon, String name, String desc, String tag, bool free) {
    final on = _fulfil == id;
    return GestureDetector(
      onTap: () => setState(() => _fulfil = id),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
        decoration: BoxDecoration(
          color: on ? _mint100 : Colors.white,
          border: Border.all(color: on ? _teal600 : _slate200, width: 1.8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x140E2A1C), blurRadius: 18, offset: Offset(0, 6))],
        ),
        child: Stack(clipBehavior: Clip.none, children: [
          if (on)
            Positioned(
              top: -8, right: -4,
              child: Container(
                width: 19, height: 19,
                decoration: const BoxDecoration(color: _teal600, shape: BoxShape.circle),
                child: const Icon(Icons.check, size: 11, color: Colors.white),
              ),
            ),
          Column(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: on ? _teal600 : _sand100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 21, color: on ? Colors.white : _teal600),
            ),
            const SizedBox(height: 10),
            Text(name, style: _pop(sz: 14)),
            const SizedBox(height: 3),
            Text(desc, textAlign: TextAlign.center, style: _int(sz: 11.3, c: _slate600, h: 1.3)),
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: free ? (on ? Colors.white.withValues(alpha: 0.65) : _mint100) : const Color(0xFFFDF1CE),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(tag, style: _int(sz: 10.5, w: FontWeight.w700, c: free ? _teal700 : const Color(0xFF8A6A0A))),
            ),
          ]),
        ]),
      ),
    );
  }

  /// Every branch on one map, with the chosen one framed.
  ///
  /// Null when no branch carries coordinates — an empty map is worse than no
  /// map, and this used to be a painted decoration that showed the same three
  /// invented streets whichever branch you picked.
  Widget? _branchMap() {
    final selected = _cubit.state.selectedBranch;
    final branches = selected != null ? [selected] : _cubit.state.branches;
    final points = [
      for (final b in branches)
        if (b.lat != null && b.lng != null)
          MapPoint(lat: b.lat!, lng: b.lng!, kind: MapPointKind.place, label: b.name),
    ];
    if (points.isEmpty) return null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _slate300, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        // Inside a scrolling form, so panning is off.
        LiveMapView(points: points, height: 96, interactive: false),
        Positioned(
          left: 8, bottom: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(l10n.mapPreviewHint, style: _int(sz: 10.5, w: FontWeight.w600, c: _forest900)),
          ),
        ),
      ]),
    );
  }

  Widget _branchCard(RentalBranchModel b) {
    final on = _cubit.state.selectedBranchId == b.id;
    return GestureDetector(
      onTap: () => _cubit.selectBranch(b.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: on ? _mint100 : Colors.white,
          border: Border.all(color: on ? _teal600 : _slate200, width: 1.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Container(
            width: 19, height: 19,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: on ? _teal600 : _slate400, width: 1.8),
            ),
            child: on
                ? Center(
                    child: Container(
                      width: 9, height: 9,
                      decoration: const BoxDecoration(color: _teal600, shape: BoxShape.circle),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 11),
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(color: _sand100, borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.location_on_outlined, size: 16, color: _teal600),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(b.name, style: _int(sz: 13, w: FontWeight.w700)),
              const SizedBox(height: 1),
              Text(b.address, style: _int(sz: 11.3, c: _slate500)),
            ]),
          ),
          Text(b.distance, style: _int(sz: 11.5, w: FontWeight.w700, c: _slate500)),
        ]),
      ),
    );
  }

  Widget _formField(String label, TextEditingController ctrl, {String? hint, int lines = 1}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: _int(sz: 12, w: FontWeight.w600, c: _slate600)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        maxLines: lines,
        style: _int(sz: 13.5, w: FontWeight.w600),
        cursorColor: _teal600,
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: _int(sz: 13.5, w: FontWeight.w500, c: _slate400),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: _slate200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: _teal500, width: 1.5),
          ),
        ),
      ),
    ]);
  }

  // ═══ STEP 3 — Extras ══════════════════════════════════════════════════════
  Widget _stepExtras() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _carCard(
        meta: '$_days Days · ${_fulfil == 'pickup' ? 'Self Pickup' : 'Delivery'}',
        amt: _money(_rentalTotal),
        unit: 'rental',
      ),
      const SizedBox(height: 18),
      _sectionHead(l10n.enhanceYourTrip, l10n.optionalAddOns),
      const SizedBox(height: 14),
      for (final e in _cubit.state.extras) ...[
        _extraCard(e),
        const SizedBox(height: 10),
      ],
    ]);
  }

  Widget _extraCard(RentalExtraModel e) {
    final on = _cubit.state.selectedExtraKeys.contains(e.key);
    return GestureDetector(
      onTap: () => _cubit.toggleExtra(e.key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(
          color: on ? _mint100 : Colors.white,
          border: Border.all(color: on ? _teal600 : _slate200, width: 1.8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x140E2A1C), blurRadius: 18, offset: Offset(0, 6))],
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: on ? _teal600 : _sand100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_extraIcons[e.key] ?? Icons.add_circle_outline, size: 18, color: on ? Colors.white : _teal600),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.name, style: _int(sz: 13.5, w: FontWeight.w700)),
              const SizedBox(height: 1),
              Text(e.description, style: _int(sz: 11.3, c: _slate500)),
            ]),
          ),
          Text.rich(TextSpan(children: [
            TextSpan(text: '+₹${e.pricePerDay}', style: _int(sz: 12.5, w: FontWeight.w700)),
            TextSpan(text: '/day', style: _int(sz: 12.5, c: _slate500)),
          ])),
          const SizedBox(width: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: 20, height: 20,
            decoration: BoxDecoration(
              color: on ? _teal600 : Colors.white,
              border: Border.all(color: on ? _teal600 : _slate400, width: 1.8),
              borderRadius: BorderRadius.circular(6),
            ),
            child: on ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
          ),
        ]),
      ),
    );
  }

  // ═══ STEP 4 — Review ══════════════════════════════════════════════════════
  Widget _stepReview() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHead(l10n.reviewYourBooking, l10n.doubleCheckBeforePay),
      const SizedBox(height: 14),
      // renter card
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: _cardDeco(),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_teal500, _forest900]),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(_renterInitials, style: _pop(sz: 14, c: Colors.white))),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // The signed-in user, not a stand-in — this card is the renter.
              Text(_renterName, style: _int(sz: 13.5, w: FontWeight.w700)),
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.verified_user_outlined, size: 12, color: _slate500),
                const SizedBox(width: 5),
                Text(l10n.bookingAsYourself, style: _int(sz: 11.5, c: _slate500)),
              ]),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: _mint100, borderRadius: BorderRadius.circular(999)),
            child: Row(children: [
              const Icon(Icons.check_rounded, size: 10, color: _teal700),
              const SizedBox(width: 4),
              Text(l10n.verified, style: _int(sz: 10.5, w: FontWeight.w700, c: _teal700)),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      // summary card
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: _cardDeco(),
        child: Column(children: [
          _summaryRow(Icons.calendar_today_outlined, l10n.tripDates,
              '${_fmtDate(_pickupDate, l10n)} ${_fmtTime(_pickupTime)} → ${_fmtDate(_returnDate, l10n)} ${_fmtTime(_returnTime)}'),
          const Divider(color: _sand100, height: 1),
          _summaryRow(Icons.location_on_outlined, l10n.stepLocation, _locationLabel),
        ]),
      ),
      const SizedBox(height: 12),
      // breakdown
      Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDeco(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.priceBreakdown, style: _pop(sz: 14.5)),
          const SizedBox(height: 9),
          _bRow('${_type[0].toUpperCase()}${_type.substring(1)} rate · $_days × ${_money(_dailyRate)}', _money(_rentalTotal)),
          if (_delivery > 0) _bRow(l10n.deliveryFee, _money(_delivery)),
          for (final e in _cubit.state.extras)
            if (_cubit.state.selectedExtraKeys.contains(e.key))
              _bRow(e.name, _money(e.pricePerDay * _days)),
          if (_promoDiscount > 0) _bRow('Promo ${_promo!.code} discount', '-${_money(_promoDiscount)}', discount: true),
          _bRow(l10n.gstFivePercent, _money(_vat)),
          const SizedBox(height: 13),
          // promo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _sand50,
              border: Border.all(color: _slate300, width: 1.5),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(children: [
              const Icon(Icons.local_offer_outlined, size: 16, color: _gold600),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _promoCtrl,
                  style: _int(sz: 12.5, w: FontWeight.w600),
                  cursorColor: _teal600,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    hintText: l10n.promoCodeHint,
                    hintStyle: _int(sz: 12.5, w: FontWeight.w500, c: _slate400),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _applyPromo,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                  decoration: BoxDecoration(color: _ink950, borderRadius: BorderRadius.circular(8)),
                  child: Text(l10n.commonApply, style: _int(sz: 12, w: FontWeight.w700, c: Colors.white)),
                ),
              ),
            ]),
          ),
          if (_promoMsg.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(_promoMsg, style: _int(sz: 11.5, w: FontWeight.w600, c: _promoOk ? _teal700 : _danger)),
          ],
          const Padding(padding: EdgeInsets.symmetric(vertical: 11), child: Divider(color: _sand100, height: 1)),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(l10n.totalInclGst, style: _pop(sz: 15.5, w: FontWeight.w800)),
            Text(_money(_total), style: _pop(sz: 15.5, w: FontWeight.w800, c: _teal700)),
          ]),
        ]),
      ),
      const SizedBox(height: 14),
      GestureDetector(
        onTap: () => setState(() => _agreed = !_agreed),
        behavior: HitTestBehavior.opaque,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: 20, height: 20,
            decoration: BoxDecoration(
              color: _agreed ? _teal600 : Colors.white,
              border: Border.all(color: _agreed ? _teal600 : _slate400, width: 1.8),
              borderRadius: BorderRadius.circular(6),
            ),
            child: _agreed ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(TextSpan(children: [
              TextSpan(text: l10n.iAgreeToThe, style: _int(sz: 12, c: _slate600)),
              TextSpan(
                  text: l10n.rentalTerms,
                  style: _int(sz: 12, w: FontWeight.w600, c: _teal700)
                      .copyWith(decoration: TextDecoration.underline)),
              TextSpan(text: ' and Cancellation Policy', style: _int(sz: 12, c: _slate600)),
            ])),
          ),
        ]),
      ),
    ]);
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(color: _sand100, borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, size: 15, color: _teal600),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: _int(sz: 11, c: _slate500)),
            const SizedBox(height: 1),
            Text(value, style: _int(sz: 13, w: FontWeight.w700)),
          ]),
        ),
      ]),
    );
  }

  Widget _bRow(String label, String value, {bool discount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(child: Text(label, style: _int(sz: 13, c: _slate600))),
        const SizedBox(width: 8),
        Text(value, style: _int(sz: 13, w: FontWeight.w600, c: discount ? _teal700 : _ink800)),
      ]),
    );
  }

  /// Validates the code by pricing the trip with it server-side, so the
  /// discount shown always matches what the booking will charge.
  Future<void> _applyPromo() async {
    final v = _promoCtrl.text.trim().toUpperCase();
    if (v.isEmpty) {
      setState(() {
        _promoMsg = l10n.enterPromoFirst;
        _promoOk = false;
      });
      return;
    }
    final error = await _cubit.applyPromo(v, _tripRequest());
    if (!mounted) return;
    final breakdown = _cubit.state.quote?.breakdown;
    setState(() {
      if (error == null && breakdown?.promoCode != null) {
        final pct = breakdown!.subtotal == 0
            ? 0
            : (breakdown.promoDiscount * 100 / breakdown.subtotal).round();
        _promo = (code: breakdown.promoCode!, pct: pct);
        _promoMsg = 'Promo applied — $pct% off your booking';
        _promoOk = true;
      } else {
        _promo = null;
        _promoMsg = error ?? l10n.promoNotValid;
        _promoOk = false;
      }
    });
  }

  // ═══ STEP 5 — Payment ═════════════════════════════════════════════════════
  Widget _stepPayment() {
    final cashLabel = _fulfil == 'pickup' ? l10n.cashOnPickup : l10n.payCashOnDelivery;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHead(l10n.sectionPayment, l10n.chooseHowToPay),
      const SizedBox(height: 14),
      Row(children: [
        _payMethod('card', Icons.credit_card_rounded, l10n.cardLabel),
        const SizedBox(width: 9),
        _payMethod('wallet', Icons.account_balance_wallet_outlined, l10n.navWallet),
        const SizedBox(width: 9),
        _payMethod('cash', Icons.payments_outlined, cashLabel),
      ]),
      const SizedBox(height: 16),
      if (_pay == 'card') ...[
        _cardVisual(),
        const SizedBox(height: 14),
        _formField(l10n.cardNumber, _cardNumCtrl, hint: '1234 5678 9012 3456'),
        const SizedBox(height: 11),
        Row(children: [
          Expanded(child: _formField(l10n.cardExpiry, _cardExpCtrl, hint: 'MM/YY')),
          const SizedBox(width: 10),
          Expanded(child: _formField(l10n.cardCvv, _cardCvvCtrl, hint: '•••')),
        ]),
        const SizedBox(height: 11),
        _formField(l10n.nameOnCard, _cardNameCtrl, hint: l10n.cardAsShown),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => setState(() => _saveCard = !_saveCard),
          behavior: HitTestBehavior.opaque,
          child: Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: _saveCard ? _teal600 : Colors.white,
                border: Border.all(color: _saveCard ? _teal600 : _slate400, width: 1.8),
                borderRadius: BorderRadius.circular(6),
              ),
              child: _saveCard ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(l10n.saveCardNextTime, style: _int(sz: 12, c: _slate600))),
          ]),
        ),
      ] else if (_pay == 'wallet')
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
          decoration: _cardDeco(),
          child: Column(children: [
            Container(
              width: 52, height: 52,
              decoration: const BoxDecoration(color: _mint100, shape: BoxShape.circle),
              child: const Icon(Icons.account_balance_wallet_outlined, size: 26, color: _teal600),
            ),
            const SizedBox(height: 14),
            Text(l10n.payWithDigitalWallet, style: _pop(sz: 14.5)),
            const SizedBox(height: 7),
            Text(
              l10n.walletRedirectNote,
              textAlign: TextAlign.center,
              style: _int(sz: 12, c: _slate500, h: 1.5),
            ),
          ]),
        )
      else
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(color: _sand100, borderRadius: BorderRadius.circular(11)),
          child: _hint(_fulfil == 'pickup'
              ? l10n.cashAtBranchNote
              : l10n.cashToDriverNote),
        ),
    ]);
  }

  Widget _payMethod(String id, IconData icon, String name) {
    final on = _pay == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _pay = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
          decoration: BoxDecoration(
            color: on ? _mint100 : Colors.white,
            border: Border.all(color: on ? _teal600 : _slate200, width: 1.8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: on ? _teal600 : _sand100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: on ? Colors.white : _teal600),
            ),
            const SizedBox(height: 7),
            Text(name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: _int(sz: 11.8, w: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }

  Widget _cardVisual() {
    final digits = _cardNumCtrl.text.replaceAll(RegExp(r'\D'), '');
    final masked = digits.padRight(16, '•').replaceAllMapped(RegExp(r'.{4}'), (m) => '${m[0]} ').trim();
    final name = _cardNameCtrl.text.trim().isEmpty ? l10n.cardYourName : _cardNameCtrl.text.toUpperCase();
    final exp = _cardExpCtrl.text.isEmpty ? 'MM/YY' : _cardExpCtrl.text;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_ink950, _forest900, _teal700],
          stops: [0.0, 0.55, 1.3],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0x470E2A1C), blurRadius: 28, offset: Offset(0, 14))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Icon(Icons.credit_card_rounded, color: Colors.white, size: 20),
          Text.rich(TextSpan(children: [
            TextSpan(text: 'EL', style: _pop(sz: 12, w: FontWeight.w800, c: _mint300)),
            TextSpan(text: '.K', style: _pop(sz: 12, w: FontWeight.w800, c: _gold500)),
            TextSpan(text: ' PAY', style: _pop(sz: 12, w: FontWeight.w800, c: Colors.white)),
          ])),
        ]),
        const SizedBox(height: 20),
        Text(masked, style: _pop(sz: 18, w: FontWeight.w600, c: Colors.white).copyWith(letterSpacing: 2.5)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.cardHolder, style: _int(sz: 8.5, c: Colors.white.withValues(alpha: 0.55)).copyWith(letterSpacing: 0.5)),
            const SizedBox(height: 3),
            Text(name, style: _int(sz: 12.5, w: FontWeight.w700, c: Colors.white).copyWith(letterSpacing: 0.5)),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.cardExpires, style: _int(sz: 8.5, c: Colors.white.withValues(alpha: 0.55)).copyWith(letterSpacing: 0.5)),
            const SizedBox(height: 3),
            Text(exp, style: _int(sz: 12.5, w: FontWeight.w700, c: Colors.white).copyWith(letterSpacing: 0.5)),
          ]),
        ]),
      ]),
    );
  }

  // ═══ Overlays ═════════════════════════════════════════════════════════════
  Widget _processingOverlay() {
    return Positioned.fill(
      child: Container(
        color: _sand50,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
            width: 220, height: 30,
            child: AnimatedBuilder(
              animation: _driveCtrl,
              builder: (context, _) {
                return Stack(children: [
                  Positioned(
                    top: 11, left: 0, right: 0, height: 8,
                    child: CustomPaint(painter: _RoadTrackPainter(dark: false)),
                  ),
                  Positioned(
                    left: _driveCtrl.value * (220 - 44),
                    top: 0,
                    child: SvgPicture.asset(widget.carSvg, width: 44, height: 28),
                  ),
                ]);
              },
            ),
          ),
          const SizedBox(height: 26),
          Text(l10n.processingYourPayment, style: _pop(sz: 15.5)),
          const SizedBox(height: 6),
          Text(l10n.dontCloseScreen, style: _int(sz: 12.5, c: _slate500)),
        ]),
      ),
    );
  }

  Widget _successOverlay() {
    return Positioned.fill(
      child: Container(
        color: _sand50,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 30, 28, 26),
            child: Column(children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.4, end: 1),
                duration: const Duration(milliseconds: 450),
                curve: Curves.elasticOut,
                builder: (_, v, child) => Transform.scale(scale: v, child: child),
                child: Container(
                  width: 74, height: 74,
                  decoration: const BoxDecoration(
                    color: _teal600,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Color(0x59238055), blurRadius: 26, offset: Offset(0, 14))],
                  ),
                  child: const Icon(Icons.check_rounded, size: 36, color: Colors.white),
                ),
              ),
              const SizedBox(height: 18),
              Text(l10n.bookingConfirmedBang, style: _pop(sz: 21, w: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Your ${widget.carName} is booked and ready to go.',
                  textAlign: TextAlign.center, style: _int(sz: 13, c: _slate600)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(color: _mint100, borderRadius: BorderRadius.circular(999)),
                child: Text(_code, style: _pop(sz: 13, c: _teal700).copyWith(letterSpacing: 1)),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: _cardDeco(),
                child: Column(children: [
                  _summaryRow(Icons.calendar_today_outlined, l10n.tripDates,
                      '${_fmtDate(_pickupDate, l10n)} → ${_fmtDate(_returnDate, l10n)}'),
                  const Divider(color: _sand100, height: 1),
                  _summaryRow(Icons.location_on_outlined, l10n.stepLocation,
                      _fulfil == 'pickup'
                          ? l10n.branchSelfPickup(_cubit.state.selectedBranch?.name ?? l10n.branch)
                          : l10n.deliveredToAddress),
                  const Divider(color: _sand100, height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(l10n.amountPaid, style: _pop(sz: 14.5, w: FontWeight.w800)),
                      Text(_money(_total), style: _pop(sz: 14.5, w: FontWeight.w800, c: _teal700)),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              // QR
              Container(
                width: 78, height: 78,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: _slate200, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: GridView.count(
                  crossAxisCount: 6,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  children: _qr
                      .map((on) => DecoratedBox(
                            decoration: BoxDecoration(
                              color: on ? _ink950 : Colors.transparent,
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),
              Text(l10n.showThisAtPickup, style: _int(sz: 11, w: FontWeight.w600, c: _slate500)),
              const SizedBox(height: 22),
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.receiptSentToEmail)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: _slate200, width: 1.8),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(child: Text(l10n.viewEReceipt, style: _pop(sz: 13.5))),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [_teal500, _teal700]),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [BoxShadow(color: Color(0x52238055), blurRadius: 22, offset: Offset(0, 10))],
                      ),
                      child: Center(child: Text(l10n.commonDone, style: _pop(sz: 13.5, c: Colors.white))),
                    ),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─── Painters ─────────────────────────────────────────────────────────────────

/// Dashed "road" track used by the stepper and the processing animation.
class _RoadTrackPainter extends CustomPainter {
  _RoadTrackPainter({this.dark = true});
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = dark ? Colors.white.withValues(alpha: 0.08) : _slate200;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(6)),
      bg,
    );
    final dash = Paint()..color = dark ? Colors.white.withValues(alpha: 0.22) : _slate300;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 10, size.height), dash);
      x += 20;
    }
  }

  @override
  bool shouldRepaint(covariant _RoadTrackPainter old) => old.dark != dark;
}

/// Small decorative map preview for the branch picker.
