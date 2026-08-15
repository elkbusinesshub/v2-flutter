import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Turns an emoji into a map marker.
///
/// Google Maps takes a bitmap, not a widget, so the glyph is painted onto a
/// canvas and handed over as PNG bytes. This is what lets the rider map show a
/// 🛺 where an auto is and a 🏍️ where a delivery bike is, the way Rapido does,
/// rather than the same coloured teardrop for every vehicle.
///
/// Results are cached per emoji and size: the bitmap is identical every time,
/// and rasterising once per marker would repaint on every camera move.
class EmojiMarker {
  const EmojiMarker._();

  static final Map<String, BitmapDescriptor> _cache = {};

  /// A round white chip with [emoji] centred on it.
  ///
  /// The chip matters: an emoji painted straight onto satellite imagery or a
  /// dark road becomes unreadable, and vehicles are exactly what a rider is
  /// trying to pick out at a glance.
  static Future<BitmapDescriptor> of(String emoji, {double size = 88}) async {
    final key = '$emoji@$size';
    final cached = _cache[key];
    if (cached != null) return cached;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final centre = Offset(size / 2, size / 2);
    final radius = size / 2;

    // Soft shadow, so the chip lifts off the map rather than merging with it.
    canvas.drawCircle(
      centre.translate(0, size * 0.03),
      radius * 0.86,
      Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(centre, radius * 0.86, Paint()..color = Colors.white);
    canvas.drawCircle(
      centre,
      radius * 0.86,
      Paint()
        ..color = const Color(0x1A000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size * 0.02,
    );

    final painter = TextPainter(
      text: TextSpan(text: emoji, style: TextStyle(fontSize: size * 0.5)),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(centre.dx - painter.width / 2, centre.dy - painter.height / 2),
    );

    final image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    // A failed encode is not worth blanking the map for — the caller falls
    // back to a default pin.
    if (bytes == null) return BitmapDescriptor.defaultMarker;

    final marker = BitmapDescriptor.bytes(bytes.buffer.asUint8List());
    _cache[key] = marker;
    return marker;
  }
}
