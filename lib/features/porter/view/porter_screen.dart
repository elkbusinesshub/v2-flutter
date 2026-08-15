import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/state_views.dart';
import '../../../data/models/porter_models.dart';
import '../cubit/porter_cubit.dart';

import '../../../core/widgets/location_picker_sheet.dart';
import '../../../core/widgets/live_map_view.dart';
import '../../../core/location/current_location.dart';
import '../../../core/location/trip_point.dart';
import '../../../data/models/place_models.dart';
import '../../../data/repositories/places_repository.dart';
import '../../../l10n/app_localizations.dart';
import 'porter_booking_flow.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
/// Shown where the map goes until the route has an end we can place.
const _mapIdle = Color(0xFFE9EEEA);
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


// ─── Screen ───────────────────────────────────────────────────────────────────
class PorterScreen extends StatefulWidget {
  const PorterScreen({super.key, required this.onDone, this.onTrack});
  final VoidCallback onDone;
  final VoidCallback? onTrack;

  @override
  State<PorterScreen> createState() => _PorterScreenState();
}

class _PorterScreenState extends State<PorterScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);

  PorterCubit get _cubit => context.read<PorterCubit>();

  /// The measured route, once the map has fetched it. Null until then, and for
  /// a trip whose ends we have no coordinates for.
  MapRoute? _route;

  @override
  void initState() {
    super.initState();
    _cubit.loadOptions();
    _prefillPickupFromGps();
  }

  /// Best-effort: names the device's position as the pickup so the common case
  /// needs no typing. Silent on failure — the user picks manually, which is
  /// better than showing an address we did not measure.
  Future<void> _prefillPickupFromGps() async {
    if (_cubit.state.pickupAddress.isNotEmpty) return;
    try {
      final place = await resolveCurrentLocation(context.read<PlacesRepository>());
      if (!mounted || _cubit.state.pickupAddress.isNotEmpty) return;
      _cubit.setRoute(
        pickup: TripPoint(
          address: place.formattedAddress,
          lat: place.lat,
          lng: place.lng,
        ),
      );
    } catch (_) {
      // No permission, no signal, or guest — leave it for the picker.
    }
  }

  /// Shows the prompt rather than a blank line when an end is unset.
  String _routeText(String value, String placeholder) =>
      value.isEmpty ? placeholder : value;

  Future<void> _openLocationPicker(bool isPickup) async {
    final picked = await showLocationPicker(
      context,
      title: isPickup ? l10n.choosePickupLocation : l10n.chooseDropoffLocation,
    );
    if (picked == null) return;
    final point = TripPoint(
      address: picked.address,
      lat: picked.lat,
      lng: picked.lng,
    );
    setState(() {
      if (isPickup) {
        _cubit.setRoute(pickup: point);
      } else {
        _cubit.setRoute(drop: point);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final top    = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final state = context.watch<PorterCubit>().state;

    if (state.status == PorterStatus.guest) {
      return Scaffold(
        backgroundColor: const Color(0xFFF1F4F0),
        body: SafeArea(
          child: SignInRequiredView(
            message: l10n.porterSignInPrompt,
          ),
        ),
      );
    }
    if (state.status == PorterStatus.error) {
      return Scaffold(
        backgroundColor: const Color(0xFFF1F4F0),
        body: SafeArea(
          child: ErrorRetryView(
            message: state.errorMessage ?? l10n.errorGeneric,
            onRetry: _cubit.loadOptions,
          ),
        ),
      );
    }
    if (state.page == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF1F4F0),
        body: LoadingView(),
      );
    }

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
                    Text(l10n.selectVehicle, style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900, color: _i9, letterSpacing: -0.3)),
                    const SizedBox(height: 2),
                    Text(l10n.pricingUpdates, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: _i4)),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                  child: Column(children: state.page!.vehicles.map((v) => Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: _buildVehicleCard(v),
                  )).toList()),
                ),
                // Add-ons
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                  child: Text(l10n.addOns, style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900, color: _i9, letterSpacing: -0.3)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                  child: Wrap(spacing: 9, runSpacing: 9, children: state.page!.addons.map((a) => _buildAddon(a)).toList()),
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
            Text(l10n.porterLogistics, style: GoogleFonts.nunito(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3)),
          ]),
        ),
      ]),
    );
  }

  // ─── Map (170px) ──────────────────────────────────────────────────────────

  Widget _buildMap() {
    final state = _cubit.state;
    final points = [
      ?state.pickup.toMapPoint(MapPointKind.pickup),
      ?state.drop.toMapPoint(MapPointKind.drop),
    ];
    if (points.isEmpty) {
      return const SizedBox(height: 170, child: ColoredBox(color: _mapIdle));
    }

    return SizedBox(
      height: 170,
      child: Stack(children: [
        LiveMapView(
          points: points,
          height: 170,
          showRoute: points.length > 1,
          onRoute: (route) => setState(() => _route = route),
        ),
        // Distance + ETA pill. Hidden until the route is known: it used to read
        // "18 min · 4.2 km" for every trip in the country.
        if (_route != null)
          Positioned(
            left: 16, bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), boxShadow: const [BoxShadow(color: Color(0x1A143228), blurRadius: 26, offset: Offset(0, 10))]),
              child: Row(children: [
                Container(width: 7, height: 7, decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle)),
                const SizedBox(width: 7),
                Text('${_route!.durationLabel} · ${_route!.distanceLabel}',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 13, color: _i9)),
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
              Text(l10n.pickupLocation, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: _i4, letterSpacing: 0.2)),
              const SizedBox(height: 2),
              Text(_routeText(context.watch<PorterCubit>().state.pickupAddress, l10n.setPickupLocation), maxLines: 2, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w500, color: _i9, height: 1.3)),
            ]),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => _openLocationPicker(false),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.dropLocation, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: _i4, letterSpacing: 0.2)),
              const SizedBox(height: 2),
              Text(_routeText(context.watch<PorterCubit>().state.dropAddress, l10n.setDropLocation), maxLines: 2, overflow: TextOverflow.ellipsis,
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
    final rows = [
      (l10n.packageType, l10n.packageElectronics, true),
      (l10n.weight, '2.5 kg', false),
      (l10n.distance, '4.2 km', false),
      (l10n.estimatedTime, '18 mins', false),
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

  Widget _buildVehicleCard(PorterVehicleModel v) {
    final sel = context.watch<PorterCubit>().state.selectedVehicleId == v.id;
    return GestureDetector(
      onTap: () => _cubit.selectVehicle(v.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: sel ? null : Colors.white,
          gradient: sel ? const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [_t05, Colors.white]) : null,
          border: Border.all(color: sel ? _teal : _line, width: 2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(children: [
          SvgPicture.asset(v.svgAsset, width: 80, height: 52),
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
            Text(v.capacity, style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: _i4)),
            const SizedBox(height: 3),
            Row(children: [
              const Icon(Icons.schedule_rounded, size: 12, color: _i4),
              const SizedBox(width: 5),
              Text('${v.etaMinutes} min arrival', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: _i4)),
            ]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('₹${v.baseFare.toStringAsFixed(0)}', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900, color: _i9)),
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

  Widget _buildAddon(PorterAddonModel a) {
    final on = context.watch<PorterCubit>().state.selectedAddonIds.contains(a.id);
    return GestureDetector(
      onTap: () => _cubit.toggleAddon(a.id),
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
          Text('+₹${a.price}', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: on ? _tDk : _i4)),
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
          Text(l10n.estimatedFare, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: _i4)),
          const SizedBox(height: 1),
          Text('₹${context.watch<PorterCubit>().state.fareBeforeFees.toStringAsFixed(0)}',
              style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w900, color: _i9, letterSpacing: -0.5)),
        ]),
        const SizedBox(width: 14),
        Expanded(
          child: Builder(builder: (context) {
            final hasRoute = context.watch<PorterCubit>().state.hasRoute;
            return GestureDetector(
            onTap: hasRoute
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        // The flow continues the same booking, so it shares this cubit.
                        builder: (_) => BlocProvider.value(
                          value: _cubit,
                          child: PorterBookingFlow(onTrack: widget.onTrack),
                        ),
                      ),
                    )
                : () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.setPickupAndDrop)),
                    ),
            child: Opacity(
              opacity: hasRoute ? 1 : 0.5,
              child: Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_teal, _tDk]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Color(0x520A5A42), blurRadius: 22, offset: Offset(0, 10))],
              ),
              child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(l10n.bookPorter, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
              ])),
              ),
            ),
          );
          }),
        ),
      ]),
    );
  }
}

