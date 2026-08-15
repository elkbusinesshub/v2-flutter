import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../data/models/dispatch_models.dart';
import 'api_config.dart';
import 'token_storage.dart';

/// Realtime dispatch — job offers to a partner, and trip updates to a rider.
///
/// Backend contract (`dispatch.gateway.ts`):
///  * namespace `/dispatch`, JWT in the handshake (`auth: { token }`)
///  * rooms are derived from the verified principal, so there is nothing to
///    join and nothing to abuse: a socket receives exactly the offers meant
///    for the account that opened it
///  * server → partner: `job:offer` (a chance at a job), `job:closed`
///    (somebody else took it)
///  * server → rider: `trip:accepted`, `trip:started`, `trip:completed`,
///    `trip:cancelled`, `trip:no_drivers`, and `driver:moved` while under way
///
/// Everything here is a notification of something already written over REST,
/// so a dropped connection degrades the screen to refresh-to-see rather than
/// losing work.
class DispatchSocket {
  DispatchSocket(this._tokenStorage);

  final TokenStorage _tokenStorage;

  io.Socket? _socket;

  final _offers = StreamController<JobOfferModel>.broadcast();
  final _closed = StreamController<String>.broadcast();
  final _trip = StreamController<TripEvent>.broadcast();
  final _connected = StreamController<bool>.broadcast();

  /// Jobs offered to this partner.
  Stream<JobOfferModel> get offers => _offers.stream;

  /// Booking ids that are no longer available — somebody accepted first.
  Stream<String> get closedOffers => _closed.stream;

  /// What is happening to a trip this account is on either side of.
  Stream<TripEvent> get tripEvents => _trip.stream;

  Stream<bool> get connectionChanges => _connected.stream;

  bool get isConnected => _socket?.connected ?? false;

  /// Opens the connection. Safe to call repeatedly.
  Future<void> connect() async {
    if (_socket != null) return;
    final token = await _tokenStorage.accessToken;
    if (token == null) return;

    final socket = io.io(
      '${ApiConfig.baseUrl}/dispatch',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableReconnection()
          .enableForceNew()
          .build(),
    );
    _socket = socket;

    socket.onConnect((_) => _connected.add(true));
    socket.onDisconnect((_) => _connected.add(false));

    socket.on('job:offer', (data) {
      if (data is Map) {
        _offers.add(JobOfferModel.fromJson(Map<String, dynamic>.from(data)));
      }
    });
    socket.on('job:closed', (data) {
      if (data is Map && data['bookingId'] is String) {
        _closed.add(data['bookingId'] as String);
      }
    });

    for (final event in TripEvent.kinds) {
      socket.on(event, (data) {
        if (data is Map) {
          _trip.add(TripEvent(event, Map<String, dynamic>.from(data)));
        }
      });
    }
  }

  Future<void> dispose() async {
    _socket?.dispose();
    _socket = null;
    await _offers.close();
    await _closed.close();
    await _trip.close();
    await _connected.close();
  }
}

/// One realtime update about a trip, tagged with which one it was.
class TripEvent {
  const TripEvent(this.name, this.payload);

  /// Every event the gateway emits into a trip room.
  static const kinds = [
    'trip:accepted',
    'trip:started',
    'trip:picked_up',
    'trip:completed',
    'trip:delivered',
    'trip:cancelled',
    'trip:no_drivers',
    'driver:moved',
  ];

  final String name;
  final Map<String, dynamic> payload;

  String get bookingId => (payload['bookingId'] as String?) ?? '';

  /// Where the partner is, on a `driver:moved`.
  double? get lat => (payload['lat'] as num?)?.toDouble();
  double? get lng => (payload['lng'] as num?)?.toDouble();
}
