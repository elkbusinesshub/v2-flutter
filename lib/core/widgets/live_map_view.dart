import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/models/place_models.dart';
import '../../data/repositories/places_repository.dart';
import '../theme/app_colors.dart';

/// What a point on the map represents. Decides its pin colour.
enum MapPointKind {
  /// Where the trip starts — a green dot, as every ride app draws it.
  pickup,

  /// Where it ends — a red pin.
  drop,

  /// The driver or courier currently moving.
  vehicle,

  /// A fixed place: a branch, a service address, a coverage centre.
  place,
}

/// One pin on a [LiveMapView].
class MapPoint {
  const MapPoint({
    required this.lat,
    required this.lng,
    required this.kind,
    this.label,
  });

  final double lat;
  final double lng;
  final MapPointKind kind;

  /// Shown in the marker's info window when tapped.
  final String? label;

  LatLng get latLng => LatLng(lat, lng);

  double get _hue => switch (kind) {
        MapPointKind.pickup => BitmapDescriptor.hueGreen,
        MapPointKind.drop => BitmapDescriptor.hueRed,
        MapPointKind.vehicle => BitmapDescriptor.hueAzure,
        MapPointKind.place => BitmapDescriptor.hueOrange,
      };
}

/// An interactive Google map — the real thing, pannable and zoomable.
///
/// Replaces the hand-painted `CustomPaint` "maps" that drew the same invented
/// streets for every user regardless of where they were.
///
/// With [showRoute] and at least two points it fetches the driving route from
/// the backend and draws it. If the backend has no route (Google found none, or
/// the Routes API is off) it falls back to a straight line between the first
/// and last point, so the map never looks broken.
class LiveMapView extends StatefulWidget {
  const LiveMapView({
    super.key,
    required this.points,
    required this.height,
    this.showRoute = false,
    this.interactive = true,
    this.borderRadius,
    this.zoom = 14,
    this.onRoute,
  });

  final List<MapPoint> points;
  final double height;

  /// Fetch and draw the driving route between the first and last point.
  final bool showRoute;

  /// False for the small preview maps, which sit inside scrolling lists where
  /// a pannable map would fight the scroll gesture.
  final bool interactive;

  final BorderRadius? borderRadius;

  /// Used only when there is a single point and so nothing to fit to.
  final double zoom;

  /// Called with the fetched route, for callers that show its distance or ETA.
  final ValueChanged<MapRoute?>? onRoute;

  @override
  State<LiveMapView> createState() => _LiveMapViewState();
}

class _LiveMapViewState extends State<LiveMapView> {
  GoogleMapController? _controller;
  List<LatLng> _routePoints = const [];

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  @override
  void didUpdateWidget(LiveMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_samePoints(oldWidget.points, widget.points) ||
        oldWidget.showRoute != widget.showRoute) {
      _loadRoute();
      _fitCamera();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  bool _samePoints(List<MapPoint> a, List<MapPoint> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].lat != b[i].lat || a[i].lng != b[i].lng) return false;
    }
    return true;
  }

  Future<void> _loadRoute() async {
    if (!widget.showRoute || widget.points.length < 2) {
      if (_routePoints.isNotEmpty) setState(() => _routePoints = const []);
      return;
    }

    final origin = widget.points.first;
    final dest = widget.points.last;
    // The straight line stands in until the real route arrives, and stays if it
    // never does — better than a map with pins and no connection between them.
    var line = [origin.latLng, dest.latLng];
    MapRoute? route;

    try {
      route = await context.read<PlacesRepository>().route(
            originLat: origin.lat,
            originLng: origin.lng,
            destLat: dest.lat,
            destLng: dest.lng,
          );
      if (route != null && route.points.length >= 2) {
        line = route.points.map((p) => LatLng(p.lat, p.lng)).toList();
      }
    } catch (_) {
      // Routes API disabled, offline, or the trip crosses no road — the
      // straight line already covers it.
    }

    if (!mounted) return;
    setState(() => _routePoints = line);
    widget.onRoute?.call(route);
    _fitCamera();
  }

  /// Frames every pin and the whole route, with room for the pin graphics.
  Future<void> _fitCamera() async {
    final controller = _controller;
    if (controller == null) return;

    final all = [
      ...widget.points.map((p) => p.latLng),
      ..._routePoints,
    ];
    if (all.isEmpty) return;
    if (all.length == 1) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(all.first, widget.zoom),
      );
      return;
    }

    var minLat = all.first.latitude, maxLat = all.first.latitude;
    var minLng = all.first.longitude, maxLng = all.first.longitude;
    for (final p in all) {
      minLat = p.latitude < minLat ? p.latitude : minLat;
      maxLat = p.latitude > maxLat ? p.latitude : maxLat;
      minLng = p.longitude < minLng ? p.longitude : minLng;
      maxLng = p.longitude > maxLng ? p.longitude : maxLng;
    }

    // Two points at the same coordinate make a zero-area bounds, which the SDK
    // rejects; nudge the corners apart.
    const epsilon = 0.0005;
    final bounds = LatLngBounds(
      southwest: LatLng(minLat - epsilon, minLng - epsilon),
      northeast: LatLng(maxLat + epsilon, maxLng + epsilon),
    );
    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 48));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) return SizedBox(height: widget.height);

    final map = GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.points.first.latLng,
        zoom: widget.zoom,
      ),
      markers: {
        for (final point in widget.points)
          Marker(
            markerId: MarkerId('${point.kind.name}:${point.lat},${point.lng}'),
            position: point.latLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(point._hue),
            infoWindow:
                point.label == null ? InfoWindow.noText : InfoWindow(title: point.label),
          ),
      },
      polylines: {
        if (_routePoints.length >= 2)
          Polyline(
            polylineId: const PolylineId('route'),
            points: _routePoints,
            color: AppColors.tealDark,
            width: 5,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
      },
      onMapCreated: (controller) {
        _controller = controller;
        _fitCamera();
      },
      // The chrome Google turns on by default belongs to a full-screen map
      // app, not to a panel inside a booking flow.
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      myLocationButtonEnabled: false,
      // Non-interactive maps disable gestures rather than using lite mode:
      // lite mode is Android-only and renders a static bitmap that the camera
      // fit below cannot animate.
      scrollGesturesEnabled: widget.interactive,
      zoomGesturesEnabled: widget.interactive,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
    );

    final sized = SizedBox(
      height: widget.height,
      width: double.infinity,
      child: ColoredBox(color: AppColors.grayLight, child: map),
    );

    final radius = widget.borderRadius;
    return radius == null ? sized : ClipRRect(borderRadius: radius, child: sized);
  }
}
