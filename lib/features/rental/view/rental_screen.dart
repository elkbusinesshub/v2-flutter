import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/state_views.dart';
import '../../../data/models/rental_models.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../data/repositories/marketplace_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../cubit/rental_booking_cubit.dart';
import '../cubit/rental_cubit.dart';
import 'rental_booking_flow.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _dk9  = Color(0xFF0C241D);
const _dk7  = Color(0xFF1A4A3C);
const _teal = Color(0xFF18927F);
const _tDk  = Color(0xFF0F6E60);
const _yel  = Color(0xFFF6CE19);
const _yDk  = Color(0xFF3A2C00);
const _i9   = Color(0xFF16271F);
const _i7   = Color(0xFF2A3B31);
const _i5   = Color(0xFF5E6E64);
const _i4   = Color(0xFF8C9890);
const _bg   = Color(0xFFF1F4F0);
const _line = Color(0xFFE6EBE5);
const _chip = Color(0xFFEFF2EE);

// ─── Data ─────────────────────────────────────────────────────────────────────

List<({String id, String label, int mult, String unit})> _periodsFor(
  AppLocalizations l10n,
) => [
      (id: 'day', label: l10n.rateDaily, mult: 1, unit: '/day'),
      (id: 'week', label: l10n.weekly, mult: 6, unit: '/week'),
      (id: 'month', label: l10n.monthly, mult: 22, unit: '/month'),
    ];

List<({String id, String label})> _catsFor(AppLocalizations l10n) => [
      (id: 'all', label: l10n.chipAll),
      (id: 'sedan', label: l10n.svcSedan),
      (id: 'suv', label: l10n.svcSuv),
      (id: 'luxury', label: l10n.svcLuxury),
    ];

// ─── RentalScreen ───────────────────────────────────────────────────────────
class RentalScreen extends StatefulWidget {
  const RentalScreen({super.key});

  @override
  State<RentalScreen> createState() => _RentalScreenState();
}

class _RentalScreenState extends State<RentalScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);

  String _period = 'day';
  String _cat = 'all';

  @override
  void initState() {
    super.initState();
    context.read<RentalCubit>().loadCars();
  }

  /// Period chips are display-only (the backend prices per day and applies
  /// the rental-type multiplier at quote time).
  static const _periodToFilter = {'day': 'daily', 'week': 'weekly', 'month': 'monthly'};

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final periodMeta = _periodsFor(l10n).firstWhere((p) => p.id == _period);
    final state = context.watch<RentalCubit>().state;
    final list = state.cars;

    if (state.status == RentalStatus.guest) {
      return Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: SignInRequiredView(
            message: l10n.rentalSignInPrompt,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        _buildHeader(top),
        _buildFilterBar(),
        if (state.status == RentalStatus.loading || state.status == RentalStatus.initial)
          const Expanded(child: LoadingView())
        else if (state.status == RentalStatus.error)
          Expanded(
            child: ErrorRetryView(
              message: state.errorMessage ?? l10n.errorGeneric,
              onRetry: () => context.read<RentalCubit>().loadCars(),
            ),
          )
        else
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: '${list.length} ',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: _i9),
                      ),
                      TextSpan(
                        text: l10n.carsAvailable,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: _i5),
                      ),
                    ]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Row(children: [
                  Text(l10n.sortPrice, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: _tDk)),
                  const SizedBox(width: 5),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: _tDk),
                ]),
              ]),
              const SizedBox(height: 12),
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      l10n.noCarsInCategory,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: _i4),
                    ),
                  ),
                )
              else
                Column(
                  children: list
                      .map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _buildCarCard(c, periodMeta),
                          ))
                      .toList(),
                ),
            ]),
          ),
        ),
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
        child: Row(children: [
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
          Text(l10n.svcCarRental, style: GoogleFonts.nunito(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3)),
        ]),
      ),
    );
  }

  // ─── Filter bar ───────────────────────────────────────────────────────────

  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 12),
      child: Column(children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(children: _periodsFor(l10n).map((p) {
            final on = _period == p.id;
            return Padding(
              padding: const EdgeInsets.only(right: 9),
              child: GestureDetector(
                onTap: () {
                  setState(() => _period = p.id);
                  context.read<RentalCubit>().selectPeriod(
                        RentalPeriod.values.firstWhere(
                          (e) => e.id == _periodToFilter[p.id],
                        ),
                      );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                  decoration: BoxDecoration(
                    gradient: on ? const LinearGradient(colors: [_teal, _tDk]) : null,
                    color: on ? null : _chip,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: on ? const [BoxShadow(color: Color(0x4D0F6E60), blurRadius: 14, offset: Offset(0, 6))] : null,
                  ),
                  child: Text(p.label, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: on ? Colors.white : _i7)),
                ),
              ),
            );
          }).toList()),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(children: _catsFor(l10n).map((c) {
            final on = _cat == c.id;
            return Padding(
              padding: const EdgeInsets.only(right: 9),
              child: GestureDetector(
                onTap: () {
                  setState(() => _cat = c.id);
                  context.read<RentalCubit>().selectTypeFilter(c.id);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: on ? _i9 : _chip,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(c.label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: on ? Colors.white : _i7)),
                ),
              ),
            );
          }).toList()),
        ),
      ]),
    );
  }

  // ─── Car card ─────────────────────────────────────────────────────────────

  Widget _buildCarCard(RentalCarModel c, ({String id, String label, int mult, String unit}) periodMeta) {
    final price = (c.pricePerDay * periodMeta.mult).round();
    final isPremium = c.badge == 'PREMIUM';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Color(0x1A143228), blurRadius: 26, offset: Offset(0, 10))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 104, height: 78,
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFEAF6F2), Color(0xFFD6EEE6)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: SvgPicture.asset(c.svgAsset, width: 92, height: 60)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 8, runSpacing: 4, children: [
                Text(c.name, style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w900, color: _i9, letterSpacing: -0.3)),
                if (c.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isPremium ? _i9 : _yel,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(c.badge!, style: GoogleFonts.nunito(fontSize: 9.5, fontWeight: FontWeight.w900, color: isPremium ? Colors.white : _yDk, letterSpacing: 0.4)),
                  ),
              ]),
              const SizedBox(height: 8),
              Wrap(spacing: 12, runSpacing: 4, children: [
                _spec(Icons.person_outline_rounded, '${c.seats} Seats'),
                _spec(Icons.settings_outlined, c.transmission),
                _spec(Icons.local_gas_station_outlined, c.fuel),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.star_rounded, size: 13, color: Color(0xFFE6B500)),
                const SizedBox(width: 4),
                Text('${c.rating}', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: _i9)),
                Expanded(
                  child: Text(
                    ' · Free cancellation',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: _i4),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
            ]),
          ),
        ]),
        const SizedBox(height: 13),
        Container(
          padding: const EdgeInsets.only(top: 13),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: _line))),
          child: Row(children: [
            Expanded(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: '₹${price.toString()}', style: GoogleFonts.nunito(fontSize: 21, fontWeight: FontWeight.w900, color: _i9, letterSpacing: -0.5)),
                  TextSpan(text: ' ${periodMeta.unit}', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: _i4)),
                ]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => RentalBookingCubit(context.read<MarketplaceRepository>(), context.read<AppPreferences>()),
                    child: RentalBookingFlow(
                      carId: c.id,
                      carName: c.name,
                      dayRate: c.pricePerDay.round(),
                      carSvg: c.svgAsset,
                      seats: c.seats,
                      trans: c.transmission,
                      fuel: c.fuel,
                      badge: c.badge,
                    ),
                  ),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_teal, _tDk]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [BoxShadow(color: Color(0x4D0F6E60), blurRadius: 18, offset: Offset(0, 8))],
                ),
                child: Text(l10n.bookNow, style: GoogleFonts.nunito(fontSize: 14.5, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _spec(IconData icon, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: _tDk),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: _i4)),
    ]);
  }
}
