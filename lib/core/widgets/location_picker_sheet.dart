import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/location_models.dart';
import '../../data/models/place_models.dart';
import '../../data/repositories/locations_repository.dart';
import '../../data/repositories/places_repository.dart';
import '../errors/api_exception.dart';
import '../utils/app_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../location/current_location.dart';

// ─── Theme tokens (matches app design language) ──────────────────────────────
const _teal7 = Color(0xFF137A6D);
const _teal6 = Color(0xFF18927F);
const _teal05 = Color(0xFFE7F6F2);
const _ink9 = Color(0xFF15241F);
const _ink5 = Color(0xFF5E6E66);
const _ink4 = Color(0xFF8C9890);
const _line = Color(0xFFECEFEA);

/// How long the user must pause before a keystroke costs a Google call.
const _searchDebounce = Duration(milliseconds: 350);

// ─── Models ───────────────────────────────────────────────────────────────────

/// Result returned when the user picks a location.
///
/// [lat]/[lng] are present whenever the location came from the address book or
/// from geocoding; they are null only for a label the user typed by hand.
class PickedLocation {
  const PickedLocation({
    required this.label,
    required this.address,
    this.id,
    this.lat,
    this.lng,
    this.placeId,
  });

  final String label;
  final String address;

  /// Saved address id, or 'search' / 'current' for the action rows.
  final String? id;

  final double? lat;
  final double? lng;

  /// Google place id, when the location came from a search suggestion.
  final String? placeId;

  /// Short display name, e.g. for headers: "Apartment · Koramangala".
  String get short => label;
}

/// Shows the themed location picker bottom sheet.
///
/// Returns the [PickedLocation] or null if dismissed.
Future<PickedLocation?> showLocationPicker(
  BuildContext context, {
  String? selectedId,
  String? title,
}) {
  return showModalBottomSheet<PickedLocation>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _LocationPickerSheet(selectedId: selectedId, title: title),
  );
}

/// Picks a tile icon from the label, since the backend stores no icon.
IconData _iconForLabel(String label) {
  final l = label.toLowerCase();
  if (l.contains('home') || l.contains('apartment') || l.contains('flat')) {
    return Icons.home_rounded;
  }
  if (l.contains('office') || l.contains('work')) return Icons.work_outline_rounded;
  if (l.contains('villa') || l.contains('house')) return Icons.villa_outlined;
  return Icons.place_outlined;
}

// ─── Sheet ────────────────────────────────────────────────────────────────────

class _LocationPickerSheet extends StatefulWidget {
  const _LocationPickerSheet({required this.selectedId, required this.title});

  final String? selectedId;

  /// Screen-specific heading; falls back to the generic one at render time,
  /// where the translations exist.
  final String? title;

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  AppLocalizations get l10n => AppLocalizations.of(context);

  late final bool _isGuest;
  List<AddressModel>? _addresses;
  String? _loadError;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _isGuest = context.read<AppPreferences>().isGuest;
    if (!_isGuest) _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _loadError = null);
    try {
      final addresses = await context.read<LocationsRepository>().getAddresses();
      if (mounted) setState(() => _addresses = addresses);
    } catch (e) {
      if (mounted) setState(() => _loadError = friendlyErrorMessage(e));
    }
  }

  /// Reads device GPS, then names the coordinate via the backend.
  ///
  /// Permission is requested here rather than at startup so the prompt has
  /// obvious context — the user has just tapped "use current location".
  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      final place =
          await resolveCurrentLocation(context.read<PlacesRepository>());
      if (!mounted) return;
      Navigator.pop(
        context,
        PickedLocation(
          id: 'current',
          label: l10n.currentLocation,
          address: place.formattedAddress,
          lat: place.lat,
          lng: place.lng,
          placeId: place.placeId,
        ),
      );
    } on LocationUnavailable catch (e) {
      _fail(e.message);
    } catch (e) {
      _fail(friendlyErrorMessage(e));
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() => _locating = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openSearch() async {
    final nav = Navigator.of(context);
    final result = await nav.push<PickedLocation>(
      MaterialPageRoute(builder: (_) => const _PlaceSearchPage()),
    );
    if (result != null) nav.pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grip
          Center(
            child: Container(
              width: 42,
              height: 5,
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFD0D8D4),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Close button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _line, width: 1.5),
              ),
              child: const Icon(Icons.close, size: 18, color: _ink9),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            widget.title ?? l10n.chooseYourLocation,
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: _ink9,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 18),
          ..._savedSection(),
          const SizedBox(height: 14),
          _ActionCard(
            icon: Icons.search_rounded,
            title: l10n.searchForAddress,
            subtitle: l10n.findStreetArea,
            onTap: _openSearch,
          ),
          const SizedBox(height: 10),
          _ActionCard(
            icon: Icons.near_me_outlined,
            title: l10n.useCurrentLocationTitle,
            subtitle: l10n.usesPhoneGps,
            busy: _locating,
            onTap: _locating ? null : _useCurrentLocation,
          ),
        ],
      ),
    );
  }

  /// Saved addresses, or the state that stands in for them.
  ///
  /// Guests are told to sign in rather than shown an error: the address book
  /// is per-user, so there is nothing to load rather than something broken.
  List<Widget> _savedSection() {
    if (_isGuest) {
      return [
        _Notice(
          icon: Icons.lock_outline_rounded,
          text: l10n.savedAddressesSignIn,
        ),
      ];
    }
    if (_loadError != null) {
      return [
        _Notice(
          icon: Icons.wifi_off_rounded,
          text: _loadError!,
          actionLabel: l10n.commonRetry,
          onAction: _loadAddresses,
        ),
      ];
    }
    if (_addresses == null) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: _teal7),
            ),
          ),
        ),
      ];
    }
    if (_addresses!.isEmpty) {
      return [
        _Notice(
          icon: Icons.bookmark_border_rounded,
          text: l10n.noSavedAddressesSearch,
        ),
      ];
    }

    return [
      Text(
        l10n.savedAddressesTitle,
        style: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: _ink9,
          letterSpacing: -0.2,
        ),
      ),
      const SizedBox(height: 4),
      // Constrained so a long address book scrolls instead of overflowing the sheet.
      ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.34,
        ),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: _addresses!.length,
          separatorBuilder: (_, _) =>
              const Divider(color: _line, height: 1, indent: 52),
          itemBuilder: (_, i) {
            final address = _addresses![i];
            return _SavedAddressTile(
              address: address,
              selected: address.id == widget.selectedId,
              onTap: () => Navigator.pop(
                context,
                PickedLocation(
                  id: address.id,
                  label: address.label,
                  address: address.formattedAddress,
                  lat: address.lat,
                  lng: address.lng,
                ),
              ),
            );
          },
        ),
      ),
    ];
  }
}

// ─── Saved address tile ───────────────────────────────────────────────────────

class _SavedAddressTile extends StatelessWidget {
  const _SavedAddressTile({
    required this.address,
    required this.selected,
    required this.onTap,
  });

  final AddressModel address;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _teal05,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(_iconForLabel(address.label), size: 19, color: _teal7),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: _ink9,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address.formattedAddress,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: _ink4,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (selected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: _teal6,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFCFD8D2), width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Address search page ──────────────────────────────────────────────────────

/// Live address autocomplete over `GET /places/search`.
///
/// Two round trips per pick: the list is predictions only, so the tapped
/// suggestion is resolved through `GET /places/:placeId` to get coordinates.
class _PlaceSearchPage extends StatefulWidget {
  const _PlaceSearchPage();

  @override
  State<_PlaceSearchPage> createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<_PlaceSearchPage> {
  AppLocalizations get l10n => AppLocalizations.of(context);

  final _controller = TextEditingController();
  Timer? _debounce;

  /// Guards against a slow earlier request overwriting a newer one's results.
  int _requestId = 0;

  List<PlaceSuggestion> _suggestions = const [];
  bool _searching = false;
  bool _resolving = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();
    // Matches the backend's minimum — a single letter matches half the country
    // and bills the same as a useful query.
    if (query.length < 2) {
      setState(() {
        _suggestions = const [];
        _searching = false;
        _error = null;
      });
      return;
    }
    setState(() => _searching = true);
    _debounce = Timer(_searchDebounce, () => _search(query));
  }

  Future<void> _search(String query) async {
    final id = ++_requestId;
    try {
      final results = await context.read<PlacesRepository>().search(query);
      if (!mounted || id != _requestId) return;
      setState(() {
        _suggestions = results;
        _searching = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _searching = false;
        _error = friendlyErrorMessage(e);
      });
    }
  }

  Future<void> _pick(PlaceSuggestion suggestion) async {
    setState(() => _resolving = true);
    try {
      final place = await context.read<PlacesRepository>().details(suggestion.placeId);
      if (!mounted) return;
      Navigator.pop(
        context,
        PickedLocation(
          id: 'search',
          label: place.name.isNotEmpty ? place.name : suggestion.title,
          address: place.formattedAddress,
          lat: place.lat,
          lng: place.lng,
          placeId: place.placeId,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _resolving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(friendlyErrorMessage(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        foregroundColor: _ink9,
        title: Text(
          l10n.searchAddress,
          style: GoogleFonts.nunito(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: _ink9,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: _ink9,
              ),
              decoration: InputDecoration(
                hintText: l10n.streetAreaHint,
                prefixIcon: const Icon(Icons.search_rounded, color: _ink4),
                filled: true,
                fillColor: const Color(0xFFF6F8F6),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (_searching || _resolving)
            const LinearProgressIndicator(minHeight: 2, color: _teal6),
          Expanded(child: _results()),
        ],
      ),
    );
  }

  Widget _results() {
    if (_error != null) {
      return _Notice(
        icon: Icons.wifi_off_rounded,
        text: _error!,
        actionLabel: l10n.commonRetry,
        onAction: () => _search(_controller.text.trim()),
      );
    }
    if (_suggestions.isEmpty) {
      final typed = _controller.text.trim().length >= 2;
      return _Notice(
        icon: typed ? Icons.search_off_rounded : Icons.travel_explore_rounded,
        text: typed && !_searching
            ? l10n.noMatchingPlaces
            : l10n.startTypingToFind,
      );
    }
    return ListView.separated(
      itemCount: _suggestions.length,
      separatorBuilder: (_, _) => const Divider(color: _line, height: 1, indent: 56),
      itemBuilder: (_, i) {
        final suggestion = _suggestions[i];
        return ListTile(
          // Tapping while a pick is resolving would race two navigations.
          onTap: _resolving ? null : () => _pick(suggestion),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _teal05,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.place_outlined, size: 19, color: _teal7),
          ),
          title: Text(
            suggestion.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: _ink9,
            ),
          ),
          subtitle: suggestion.secondaryText.isEmpty
              ? null
              : Text(
                  suggestion.secondaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _ink4,
                  ),
                ),
        );
      },
    );
  }
}

// ─── Small shared pieces ──────────────────────────────────────────────────────

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _ink4),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _ink5,
                height: 1.35,
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _teal7,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Action card (search / current location) ──────────────────────────────────

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.busy = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _line, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            if (busy)
              const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: _teal7),
              )
            else
              Icon(icon, size: 21, color: _teal7),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: _ink9,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: _ink4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 22, color: _ink4),
          ],
        ),
      ),
    );
  }
}
