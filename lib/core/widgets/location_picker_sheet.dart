import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Theme tokens (matches app design language) ──────────────────────────────
const _teal7 = Color(0xFF137A6D);
const _teal6 = Color(0xFF18927F);
const _teal05 = Color(0xFFE7F6F2);
const _ink9 = Color(0xFF15241F);
const _ink5 = Color(0xFF5E6E66);
const _ink4 = Color(0xFF8C9890);
const _line = Color(0xFFECEFEA);

// ─── Models ───────────────────────────────────────────────────────────────────

class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.label,
    required this.address,
    required this.icon,
  });
  final String id;
  final String label;
  final String address;
  final IconData icon;
}

/// Result returned when the user picks a location.
class PickedLocation {
  const PickedLocation({required this.label, required this.address, this.id});
  final String label;
  final String address;

  /// Saved address id, or 'map' / 'current' for the action rows.
  final String? id;

  /// Short display name, e.g. for headers: "Apartment · Al Reem Island".
  String get short => label;
}

/// App-wide dummy saved addresses (until a real address book exists).
const elkSavedAddresses = <SavedAddress>[
  SavedAddress(
    id: 'apartment',
    label: 'Apartment',
    address: 'Tower 3, Apt 1204, Marina Bay, Al Reem Island',
    icon: Icons.home_rounded,
  ),
  SavedAddress(
    id: 'office',
    label: 'Office',
    address: 'Addax Tower, 12th floor, City of Lights, Al Reem',
    icon: Icons.work_outline_rounded,
  ),
  SavedAddress(
    id: 'villa',
    label: 'Family Villa',
    address: 'Villa 22, Street 9, Khalifa City A, Abu Dhabi',
    icon: Icons.villa_outlined,
  ),
];

/// Shows the themed location picker bottom sheet.
///
/// Returns the [PickedLocation] or null if dismissed.
Future<PickedLocation?> showLocationPicker(
  BuildContext context, {
  String? selectedId,
  String title = 'Choose your location',
}) {
  return showModalBottomSheet<PickedLocation>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _LocationPickerSheet(selectedId: selectedId, title: title),
  );
}

// ─── Sheet ────────────────────────────────────────────────────────────────────

class _LocationPickerSheet extends StatelessWidget {
  const _LocationPickerSheet({required this.selectedId, required this.title});

  final String? selectedId;
  final String title;

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
            title,
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: _ink9,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 18),
          // Saved addresses
          Text(
            'Saved addresses',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: _ink9,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          for (int i = 0; i < elkSavedAddresses.length; i++) ...[
            _SavedAddressTile(
              addr: elkSavedAddresses[i],
              selected: elkSavedAddresses[i].id == selectedId,
              onTap: () => Navigator.pop(
                context,
                PickedLocation(
                  id: elkSavedAddresses[i].id,
                  label: elkSavedAddresses[i].label,
                  address: elkSavedAddresses[i].address,
                ),
              ),
            ),
            if (i < elkSavedAddresses.length - 1)
              const Divider(color: _line, height: 1, indent: 52),
          ],
          const SizedBox(height: 14),
          // Choose on map
          _ActionCard(
            icon: Icons.pin_drop_outlined,
            title: 'Choose a different location',
            subtitle: 'Pick a location on the map',
            onTap: () async {
              final nav = Navigator.of(context);
              final res = await nav.push<PickedLocation>(
                MaterialPageRoute(builder: (_) => const _MapPickPage()),
              );
              if (res != null) nav.pop(res);
            },
          ),
          const SizedBox(height: 10),
          // Current location
          _ActionCard(
            icon: Icons.near_me_outlined,
            title: 'Use current location',
            subtitle: 'Uses your phone GPS',
            onTap: () => Navigator.pop(
              context,
              const PickedLocation(
                id: 'current',
                label: 'Current location',
                address: 'Al Reem Island, Abu Dhabi',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Saved address tile ───────────────────────────────────────────────────────

class _SavedAddressTile extends StatelessWidget {
  const _SavedAddressTile({
    required this.addr,
    required this.selected,
    required this.onTap,
  });

  final SavedAddress addr;
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
              child: Icon(addr.icon, size: 19, color: _teal7),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    addr.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: _ink9,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    addr.address,
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

// ─── Map pick page (fake map, tap to move pin) ────────────────────────────────

class _MapPickPage extends StatefulWidget {
  const _MapPickPage();

  @override
  State<_MapPickPage> createState() => _MapPickPageState();
}

class _MapPickPageState extends State<_MapPickPage> {
  Offset? _pin; // null until first tap; defaults to centre

  String _areaFor(Offset p, Size size) {
    final left = p.dx < size.width / 2;
    final topHalf = p.dy < size.height / 2;
    if (left && topHalf) return 'Marina Bay, Al Reem Island';
    if (!left && topHalf) return 'City of Lights, Al Reem';
    if (left) return 'Shams Abu Dhabi, Al Reem';
    return 'Tamouh District, Al Reem Island';
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final pin = _pin ?? Offset(size.width / 2, size.height / 2 - 60);
        final area = _areaFor(pin, size);

        return Stack(children: [
          // Fake map
          Positioned.fill(
            child: GestureDetector(
              onTapUp: (d) => setState(() => _pin = d.localPosition),
              child: CustomPaint(painter: _PickMapPainter()),
            ),
          ),
          // Pin
          Positioned(
            left: pin.dx - 18,
            top: pin.dy - 36,
            child: const IgnorePointer(
              child: Icon(
                Icons.location_on,
                size: 36,
                color: Color(0xFFE2554C),
                shadows: [Shadow(color: Color(0x55000000), blurRadius: 8, offset: Offset(0, 3))],
              ),
            ),
          ),
          // Back button
          Positioned(
            top: top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 3))],
                ),
                child: const Icon(Icons.arrow_back, size: 20, color: _ink9),
              ),
            ),
          ),
          // Hint chip
          Positioned(
            top: top + 62,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2))],
                  ),
                  child: Text(
                    'Tap the map to move the pin',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: _ink5),
                  ),
                ),
              ),
            ),
          ),
          // Bottom confirm card
          Positioned(
            left: 16,
            right: 16,
            bottom: bottom + 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Color(0x28000000), blurRadius: 20, offset: Offset(0, 8))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.location_on, size: 18, color: _teal7),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      area,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: _ink9),
                    ),
                  ),
                ]),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => Navigator.pop(
                    context,
                    PickedLocation(id: 'map', label: 'Map location', address: area),
                  ),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_teal6, _teal7]),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        'Confirm location',
                        style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ]);
      }),
    );
  }
}

class _PickMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFE9EEEA));

    // Park patches
    final park = Paint()..color = const Color(0xFFDCEBDD);
    canvas.drawRect(Rect.fromLTWH(-20, h * 0.55, w * 0.42, h * 0.3), park);
    canvas.drawRect(Rect.fromLTWH(w * 0.6, h * 0.08, w * 0.5, h * 0.22), park);
    canvas.drawRect(Rect.fromLTWH(w * 0.1, h * 0.05, w * 0.25, h * 0.14), park);

    // Water
    final water = Path()
      ..moveTo(0, h * 0.82)
      ..quadraticBezierTo(w * 0.3, h * 0.75, w * 0.6, h * 0.85)
      ..quadraticBezierTo(w * 0.8, h * 0.92, w, h * 0.86)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(water, Paint()..color = const Color(0xFFCBE3F0));

    // Roads
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;
    final edge = Paint()
      ..color = const Color(0xFFD7DED8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final roads = [
      [Offset(-10, h * 0.3), Offset(w + 10, h * 0.42)],
      [Offset(w * 0.28, -10), Offset(w * 0.36, h + 10)],
      [Offset(w * 0.7, -10), Offset(w * 0.62, h * 0.8)],
      [Offset(-10, h * 0.62), Offset(w + 10, h * 0.55)],
    ];
    for (final r in roads) {
      canvas.drawLine(r[0], r[1], road);
      canvas.drawLine(r[0], r[1], edge);
    }

    // Building blocks
    final bld = Paint()..color = const Color(0xFFDFE6E0);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.08, h * 0.46, 46, 30), const Radius.circular(4)), bld);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.45, h * 0.18, 38, 26), const Radius.circular(4)), bld);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.78, h * 0.5, 42, 28), const Radius.circular(4)), bld);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.42, h * 0.66, 50, 24), const Radius.circular(4)), bld);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Action card (map / current location) ─────────────────────────────────────

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

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
                      color: _ink5,
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
