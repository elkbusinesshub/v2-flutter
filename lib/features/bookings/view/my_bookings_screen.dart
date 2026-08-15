import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/state_views.dart';
import '../../../data/models/booking_models.dart';
import '../../../l10n/app_localizations.dart';
import '../cubit/my_bookings_cubit.dart';

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

// ── status style ───────────────────────────────────────────────────────────
typedef _SS = ({String label, Color fg, Color bg});
_SS _ss(String s, AppLocalizations l10n) => switch (s) {
  'confirmed' => (label: l10n.statusConfirmed,     fg: _t7,  bg: _t05),
  'pending'   => (label: l10n.statusPendingVendor, fg: _yam, bg: _y05),
  'completed' => (label: l10n.statusCompleted,     fg: _grn, bg: _g05),
  'cancelled' => (label: l10n.statusCancelled,     fg: _red, bg: _r05),
  _           => (label: l10n.statusUnknown,       fg: _ink4, bg: _chip),
};

String _aed(double v) =>
    '₹${v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2)}';

// ═══════════════════════════════════════════════════════════════════════════
// SCREEN
// ═══════════════════════════════════════════════════════════════════════════
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({
    super.key,
    required this.onRateTap,
    required this.onTrackTap,
  });

  /// Opens the rating screen for a completed booking; resolves to `true` once
  /// a review was actually submitted.
  final Future<bool> Function(String bookingId) onRateTap;

  /// Opens the tracking timeline for an upcoming booking.
  final void Function(String bookingId) onTrackTap;

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
  MyBookingsCubit get _cubit => context.read<MyBookingsCubit>();

  /// The detail screen tracks an id, not an instance — every reload rebuilds
  /// the models, so holding one would show a stale copy after a cancel.
  String? _curId;

  BookingListItemModel? _curOf(MyBookingsState state) =>
      state.bookings.where((b) => b.id == _curId).firstOrNull;

  /// Whether this tab was the visible one on the last dependency change.
  bool _wasVisible = false;

  @override
  void initState() {
    super.initState();
    _cubit.load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The bottom-nav branches live in an IndexedStack and stay mounted, so
    // initState runs once and the list would still show whatever it held when
    // the tab was first opened — a booking made afterwards never appeared.
    // go_router wraps each branch in TickerMode(enabled: isActive), which makes
    // this a dependency that flips exactly when the tab becomes visible.
    final visible = TickerMode.valuesOf(context).enabled;
    if (visible && !_wasVisible) {
      _cubit.load(refresh: true);
    }
    _wasVisible = visible;
  }

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
    return BlocBuilder<MyBookingsCubit, MyBookingsState>(
      builder: (context, state) {
        // The booking can vanish from under the detail screen (e.g. a reload
        // after cancelling), so fall back to the list rather than blank out.
        final current = _curOf(state);
        final showDetail = _sn == _Sn.detail && current != null;

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
              key: ValueKey(showDetail),
              child: showDetail ? _detailScreen(state, current) : _listScreen(state),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // LIST SCREEN
  // ═══════════════════════════════════════════════════════════════════════
  Widget _listScreen(MyBookingsState state) {
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
            Text(AppLocalizations.of(context).myBookingsTitle, style: GoogleFonts.nunito(
              fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3,
            )),
          ]),
        ),
        // tabs
        Container(
          color: _bg,
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
          child: Row(children: [
            for (final t in ['upcoming', 'completed', 'cancelled']) ...[
              Expanded(child: _Tab(
                label: _tabLabel(t),
                count: state.countFor(t),
                active: state.tab == t,
                onTap: () => _cubit.selectTab(t),
              )),
              if (t != 'cancelled') const SizedBox(width: 8),
            ],
          ]),
        ),
        // list
        Expanded(child: _listBody(state)),
      ]),
    );
  }

  Widget _listBody(MyBookingsState state) {
    switch (state.status) {
      case MyBookingsStatus.initial:
      case MyBookingsStatus.loading:
        return const LoadingView();
      case MyBookingsStatus.guest:
        return SignInRequiredView(
          message: AppLocalizations.of(context).bookingsSignInPrompt,
        );
      case MyBookingsStatus.error:
        return ErrorRetryView(
          message: state.errorMessage ??
              AppLocalizations.of(context).errorGeneric,
          onRetry: _cubit.load,
        );
      case MyBookingsStatus.loaded:
      case MyBookingsStatus.refreshing:
        final visible = state.visible;
        if (visible.isEmpty) return _emptyState(state.tab);
        return RefreshIndicator(
          onRefresh: () => _cubit.load(refresh: true),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            itemCount: visible.length,
            itemBuilder: (_, i) {
              final b = visible[i];
              return _Card(
                bk: b,
                rated: state.ratedIds.contains(b.id),
                cancelling: state.cancellingId == b.id,
                onTap: () { _curId = b.id; _push(_Sn.detail); },
                onCancel: b.isUpcoming ? () => _openCancel(b) : null,
                onRate: b.isCompleted ? () => _openRate(b) : null,
                onRebook: _rebook,
              );
            },
          ),
        );
    }
  }

  String _tabLabel(String t) {
    final l10n = AppLocalizations.of(context);
    return switch (t) {
      'upcoming'  => l10n.tabUpcoming,
      'completed' => l10n.statusCompleted,
      _           => l10n.statusCancelled,
    };
  }

  Widget _emptyState(String tab) {
    final l10n = AppLocalizations.of(context);
    final msgs = switch (tab) {
      'upcoming'  => (l10n.emptyUpcomingTitle, l10n.emptyUpcomingBody),
      'completed' => (l10n.emptyCompletedTitle, l10n.emptyCompletedBody),
      _           => (l10n.emptyCancelledTitle, l10n.emptyCancelledBody),
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
  Widget _detailScreen(MyBookingsState state, BookingListItemModel b) {
    final l10n = AppLocalizations.of(context);
    final top = MediaQuery.of(context).padding.top;
    final s = _ss(b.status, l10n);
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
                Text(l10n.bookingDetailsTitle, style: GoogleFonts.nunito(
                  fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3,
                )),
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
                    child: Center(child: Text(b.serviceIcon, style: const TextStyle(fontSize: 30))),
                  ),
                  const SizedBox(width: 13),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(b.serviceName, style: GoogleFonts.nunito(
                      fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3,
                    )),
                    const SizedBox(height: 2),
                    Text('by ${b.providerName}', style: const TextStyle(
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
              _secTitle(l10n.sectionStatus),
              const SizedBox(height: 10),
              _wCard(Padding(padding: const EdgeInsets.all(14), child: _Timeline(status: b.status))),
              const SizedBox(height: 20),
              _secTitle(l10n.sectionScheduleAddress),
              const SizedBox(height: 10),
              _wCard(Column(children: [
                _InfoRow(icon: Icons.calendar_month_rounded, label: l10n.labelDateTime, value: '${b.dateLabel()} · ${b.timeLabel}', first: true),
                _InfoRow(icon: Icons.location_on_rounded, label: l10n.labelServiceAddress, value: b.addressText),
              ])),
              const SizedBox(height: 20),
              _secTitle(l10n.sectionVendor),
              const SizedBox(height: 10),
              _wCard(_InfoRow(
                icon: Icons.person_rounded,
                label: l10n.vendorSpecialist(b.serviceName),
                value: b.providerName,
                first: true,
                trailing: GestureDetector(
                  onTap: () => _toast(l10n.vendorContactUnavailable),
                  child: Text(l10n.callAction, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: _t7)),
                ),
              )),
              const SizedBox(height: 20),
              _secTitle(l10n.sectionPayment),
              const SizedBox(height: 10),
              _wCard(Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  // The backend charges the service price flat — there is no
                  // separate ELK fee or GST line on a service booking.
                  _brkLine(l10n.lineService, b.total),
                  const SizedBox(height: 6),
                  Divider(height: 1.5, thickness: 1.5, color: _line),
                  const SizedBox(height: 11),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(b.isCancelled ? l10n.totalCancelled : l10n.totalPaid,
                        style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900, color: _ink9)),
                    Text(_aed(b.total),
                        style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900, color: _ink9)),
                  ]),
                ]),
              )),
              const SizedBox(height: 14),
              _wCard(Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l10n.bookingId, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _ink4)),
                    const SizedBox(height: 2),
                    Text(b.reference, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _ink9)),
                  ]),
                  GestureDetector(
                    onTap: () => _copyReference(b.reference),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(color: _chip, borderRadius: BorderRadius.circular(999)),
                      child: Text(l10n.copyAction, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _ink5)),
                    ),
                  ),
                ]),
              )),
              if (b.isUpcoming) ...[
                const SizedBox(height: 14),
                Text(
                  l10n.cancelIsFreeNote,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: _ink4, height: 1.5),
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
            if (b.isCancelled) ...[
              Expanded(child: _CtaBtn(label: l10n.rebookThisService, onTap: _rebook)),
            ] else if (b.isCompleted) ...[
              Expanded(child: _CtaBtn(
                label: state.ratedIds.contains(b.id) ? l10n.ratedStar : l10n.rateAction,
                outline: true,
                onTap: () => _openRate(b),
              )),
              const SizedBox(width: 11),
              Expanded(child: _CtaBtn(label: l10n.rebookAction, onTap: _rebook)),
            ] else ...[
              Expanded(child: _CtaBtn(
                label: l10n.trackOrder,
                outline: true,
                onTap: () => widget.onTrackTap(b.id),
              )),
              const SizedBox(width: 11),
              Expanded(child: _CtaBtn(
                label: state.cancellingId == b.id ? l10n.cancelling : l10n.cancelBooking,
                danger: true,
                onTap: () => _openCancel(b),
              )),
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
  Widget _brkLine(String k, double v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(k, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: _ink5)),
      Text(_aed(v), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: _ink9)),
    ]),
  );

  // ═══════════════════════════════════════════════════════════════════════
  // SHEETS
  // ═══════════════════════════════════════════════════════════════════════
  /// Cancellation reasons are collected for the user's benefit only —
  /// `POST /bookings/:id/cancel` takes no body, so nothing is sent upstream.
  void _openCancel(BookingListItemModel b) async {
    final l10n = AppLocalizations.of(context);
    String? reason;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, ss) {
        return _Sheet(children: [
          Text(l10n.cancelBookingQuestion, style: GoogleFonts.nunito(fontSize: 19, fontWeight: FontWeight.w900, color: _ink9)),
          const SizedBox(height: 4),
          Text('${b.serviceName} · ${b.dateLabel()}, ${b.timeLabel}',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _ink5)),
          const SizedBox(height: 16),
          Text(l10n.whyCancelling, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _ink5)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final r in [
              l10n.cancelReasonPlans,
              l10n.cancelReasonAlternative,
              l10n.cancelReasonWrongTime,
              l10n.cancelReasonExpensive,
              l10n.cancelReasonOther,
            ])
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
                  TextSpan(text: l10n.cancellingIsFreePrefix),
                  TextSpan(text: _aed(b.total), style: const TextStyle(fontWeight: FontWeight.w900)),
                  TextSpan(text: l10n.cancellingIsFreeSuffix),
                ]),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _t7),
              )),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _CtaBtn(label: l10n.keepBooking, outline: true, onTap: () => Navigator.of(ctx).pop(false))),
            const SizedBox(width: 11),
            Expanded(child: _CtaBtn(label: l10n.cancelBooking, danger: true, onTap: () => Navigator.of(ctx).pop(true))),
          ]),
        ]);
      }),
    );
    if (ok != true || !mounted) return;

    final message = await _cubit.cancelBooking(b.id);
    if (!mounted) return;
    _toast(message);
    // Only follow the booking into the Cancelled tab if it actually moved.
    if (_cubit.state.bookings.any((x) => x.id == b.id && x.isCancelled)) {
      if (_sn == _Sn.detail) _pop();
      _cubit.selectTab('cancelled');
    }
  }

  /// Hands off to the full rating screen (tags + reward points) rather than
  /// duplicating it in a sheet.
  void _openRate(BookingListItemModel b) async {
    final submitted = await widget.onRateTap(b.id);
    if (submitted && mounted) _cubit.markRated(b.id);
  }

  /// `GET /bookings` returns no `serviceId`, so there is nothing to deep-link
  /// back to — the user re-picks the service from the Services tab.
  void _rebook() =>
      _toast(AppLocalizations.of(context).rebookHint);

  void _copyReference(String reference) {
    Clipboard.setData(ClipboardData(text: reference));
    _toast(AppLocalizations.of(context).copiedBookingId);
  }
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
  const _Card({
    required this.bk,
    required this.rated,
    required this.cancelling,
    required this.onTap,
    this.onCancel,
    this.onRate,
    required this.onRebook,
  });
  final BookingListItemModel bk;
  final bool rated, cancelling;
  final VoidCallback onTap, onRebook;
  final VoidCallback? onCancel, onRate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = _ss(bk.status, l10n);
    final isUpcoming = bk.isUpcoming;
    final isCompleted = bk.isCompleted;
    final isCancelled = bk.isCancelled;

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
                child: Center(child: Text(bk.serviceIcon, style: const TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(bk.serviceName, style: GoogleFonts.nunito(fontSize: 15.5, fontWeight: FontWeight.w900, color: _ink9, letterSpacing: -0.2), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 1),
                Text('by ${bk.providerName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _ink4), maxLines: 1, overflow: TextOverflow.ellipsis),
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
                Text(bk.dateLabel(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _ink5)),
                const SizedBox(width: 14),
                const Icon(Icons.schedule_rounded, size: 14, color: _t6),
                const SizedBox(width: 4),
                Text(bk.timeLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _ink5)),
                const Spacer(),
                Text(_aed(bk.total), style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900, color: _ink9)),
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
                Text(l10n.cancelledNothingCharged,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _grn)),
              ]),
            ),
          ),
        // action buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: Row(children: [
            if (isUpcoming) ...[
              Expanded(child: _Btn(label: l10n.viewDetails, onTap: onTap)),
              const SizedBox(width: 9),
              Expanded(child: _Btn(label: cancelling ? l10n.cancelling : l10n.commonCancel, danger: true, onTap: onCancel ?? () {})),
            ] else if (isCompleted) ...[
              Expanded(child: _Btn(label: rated ? l10n.ratedStar : l10n.rateAction, onTap: onRate ?? () {})),
              const SizedBox(width: 9),
              Expanded(child: _Btn(label: l10n.rebookAction, primary: true, onTap: onRebook)),
            ] else if (isCancelled) ...[
              Expanded(child: _Btn(label: l10n.rebookAction, primary: true, onTap: onRebook)),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = [
      (l10n.timelineBooked,     l10n.timelineBookedSub),
      (l10n.statusConfirmed,    l10n.timelineConfirmedSub),
      (l10n.timelineInProgress, l10n.timelineInProgressSub),
      (l10n.statusCompleted,    l10n.timelineCompletedSub),
    ];

    if (status == 'cancelled') {
      return Column(children: [
        _TlRow(done: true, title: l10n.timelineBooked, sub: l10n.timelineBookedSub, hasLine: true, lineDone: false),
        _TlRow(done: false, cancelled: true, title: l10n.statusCancelled, sub: l10n.timelineRefundIssued, hasLine: false, lineDone: false),
      ]);
    }
    final reached = switch (status) {
      'completed' => 4,
      'confirmed' => 2,
      'pending'   => 1,
      _           => 0,
    };
    return Column(
      children: List.generate(steps.length, (i) {
        final (title, sub) = steps[i];
        return _TlRow(
          done: i < reached,
          title: title, sub: sub,
          hasLine: i < steps.length - 1,
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
