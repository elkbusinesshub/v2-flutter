import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/seller_colors.dart';
import '../../../core/widgets/state_views.dart';
import '../../../data/models/dispatch_models.dart';
import '../../../data/repositories/ride_repository.dart';
import '../../../data/repositories/porter_repository.dart';
import '../cubit/partner_cubit.dart';

/// The driving side of the seller panel: go on duty, take work, do the job.
///
/// One screen for both products. A ride and a delivery differ only in wording
/// and in whether "collected" means a passenger or a parcel, so branching the
/// whole screen on product would be two copies of the same thing.
class PartnerScreen extends StatefulWidget {
  const PartnerScreen({super.key});

  @override
  State<PartnerScreen> createState() => _PartnerScreenState();
}

class _PartnerScreenState extends State<PartnerScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PartnerCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PartnerCubit, PartnerState>(
      builder: (context, state) {
        if (state.status == PartnerStatus.loading ||
            state.status == PartnerStatus.initial) {
          return const LoadingView();
        }
        if (state.status == PartnerStatus.error) {
          return ErrorRetryView(
            message: state.errorMessage ?? 'Could not load your partner profile',
            onRetry: context.read<PartnerCubit>().load,
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _ServicePicker(state: state),
            const SizedBox(height: 14),
            if (!state.isRegistered)
              _RegisterCard(state: state)
            else ...[
              _DutyCard(state: state),
              const SizedBox(height: 14),
              if (state.activeJob != null)
                _ActiveJobCard(state: state)
              else if (state.isOnline)
                _OfferList(state: state)
              else
                const _OffDutyHint(),
            ],
          ],
        );
      },
    );
  }
}

/// Driving or delivering. Only shown once the partner runs both.
class _ServicePicker extends StatelessWidget {
  const _ServicePicker({required this.state});

  final PartnerState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PartnerCubit>();
    return Row(
      children: [
        for (final service in DriverService.values)
          Expanded(
            child: GestureDetector(
              onTap: () => cubit.selectService(service),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: state.service == service ? SellerColors.teal500 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SellerColors.teal50),
                ),
                child: Center(
                  child: Text(
                    service == DriverService.ride ? '🚕  Rides' : '📦  Deliveries',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: state.service == service ? Colors.white : SellerColors.ink,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// First run: there is no vehicle on file, so there is nothing to dispatch.
class _RegisterCard extends StatefulWidget {
  const _RegisterCard({required this.state});

  final PartnerState state;

  @override
  State<_RegisterCard> createState() => _RegisterCardState();
}

class _RegisterCardState extends State<_RegisterCard> {
  final _label = TextEditingController();
  final _plate = TextEditingController();
  String? _slug;
  List<({String slug, String name, String emoji})> _classes = const [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  @override
  void didUpdateWidget(_RegisterCard old) {
    super.didUpdateWidget(old);
    if (old.state.service != widget.state.service) {
      setState(() {
        _classes = const [];
        _slug = null;
      });
      _loadClasses();
    }
  }

  /// The classes a partner may sign up to run come from the live catalogue,
  /// so a vehicle nobody dispatches for cannot be chosen.
  Future<void> _loadClasses() async {
    final rides = context.read<RideRepository>();
    final porter = context.read<PorterRepository>();
    try {
      final classes = widget.state.service == DriverService.ride
          ? (await rides.getRideTypes())
              .map((t) => (slug: t.id, name: t.name, emoji: t.emoji))
              .toList()
          : (await porter.getPorterOptions())
              .vehicles
              .map((v) => (slug: v.id, name: v.name, emoji: v.emoji))
              .toList();
      if (!mounted) return;
      setState(() {
        _classes = classes;
        _slug = classes.firstOrNull?.slug;
      });
    } catch (_) {
      // Leave the picker empty; the retry is to reopen the tab.
    }
  }

  @override
  void dispose() {
    _label.dispose();
    _plate.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final slug = _slug;
    if (slug == null || _label.text.trim().isEmpty || _plate.text.trim().isEmpty) return;
    setState(() => _busy = true);
    final error = await context.read<PartnerCubit>().register(
          vehicleSlug: slug,
          vehicleLabel: _label.text.trim(),
          plateNumber: _plate.text.trim(),
        );
    if (!mounted) return;
    setState(() => _busy = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      children: [
        const Text(
          'Register your vehicle',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: SellerColors.ink),
        ),
        const SizedBox(height: 4),
        const Text(
          'Riders see this, and it decides which jobs reach you.',
          style: TextStyle(fontSize: 12.5, color: SellerColors.muted),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in _classes)
              ChoiceChip(
                selected: _slug == c.slug,
                label: Text('${c.emoji}  ${c.name}'),
                onSelected: (_) => setState(() => _slug = c.slug),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _label,
          decoration: const InputDecoration(
            labelText: 'Vehicle',
            hintText: 'Bajaj RE · Yellow',
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _plate,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'Number plate'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _busy || _slug == null ? null : _submit,
            child: Text(_busy ? 'Saving…' : 'Save vehicle'),
          ),
        ),
      ],
    );
  }
}

/// On duty or off, and proof the position is still going up.
class _DutyCard extends StatelessWidget {
  const _DutyCard({required this.state});

  final PartnerState state;

  @override
  Widget build(BuildContext context) {
    final profile = state.profile!;
    final cubit = context.read<PartnerCubit>();

    return _Card(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.vehicleLabel,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: SellerColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    profile.plateNumber,
                    style: const TextStyle(fontSize: 12.5, color: SellerColors.muted),
                  ),
                ],
              ),
            ),
            if (state.isTogglingDuty)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Switch(
                value: state.isOnline,
                onChanged: (value) async {
                  final error = await cubit.setOnline(value);
                  if (error != null && context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(error)));
                  }
                },
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          state.isOnline
              ? 'On duty — you can be sent jobs'
              : 'Off duty — nobody can reach you',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: state.isOnline ? SellerColors.teal500 : SellerColors.muted,
          ),
        ),
        // A partner who has gone silent stops being offered work, so whether
        // the heartbeat is landing is worth showing rather than hiding.
        if (state.isOnline && state.lastSentAt != null) ...[
          const SizedBox(height: 2),
          Text(
            'Location shared ${_ago(state.lastSentAt!)}',
            style: const TextStyle(fontSize: 11.5, color: SellerColors.muted2),
          ),
        ],
      ],
    );
  }

  static String _ago(DateTime at) {
    final seconds = DateTime.now().difference(at).inSeconds;
    if (seconds < 60) return 'just now';
    final minutes = seconds ~/ 60;
    return minutes == 1 ? 'a minute ago' : '$minutes minutes ago';
  }
}

class _OffDutyHint extends StatelessWidget {
  const _OffDutyHint();

  @override
  Widget build(BuildContext context) => const _Card(
        children: [
          Text('🌙', style: TextStyle(fontSize: 28)),
          SizedBox(height: 8),
          Text(
            'Go on duty to start receiving jobs',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: SellerColors.ink),
          ),
        ],
      );
}

/// Live offers. Every partner nearby sees the same ones.
class _OfferList extends StatelessWidget {
  const _OfferList({required this.state});

  final PartnerState state;

  @override
  Widget build(BuildContext context) {
    if (state.offers.isEmpty) {
      return const _Card(
        children: [
          SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: SellerColors.teal500),
          ),
          SizedBox(height: 12),
          Text(
            'Waiting for jobs nearby',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: SellerColors.ink),
          ),
          SizedBox(height: 2),
          Text(
            'You will be alerted the moment one comes in.',
            style: TextStyle(fontSize: 12, color: SellerColors.muted),
          ),
        ],
      );
    }

    final cubit = context.read<PartnerCubit>();
    return Column(
      children: [
        for (final offer in state.offers)
          _Card(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '₹${offer.fare.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: SellerColors.ink,
                      ),
                    ),
                  ),
                  Text(
                    '${offer.pickupDistanceKm.toStringAsFixed(1)} km away',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: SellerColors.teal500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _Leg(icon: '🟢', label: offer.pickupAddress),
              const SizedBox(height: 6),
              _Leg(icon: '🔴', label: offer.dropAddress),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => cubit.decline(offer.bookingId),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: state.acceptingId != null
                          ? null
                          : () async {
                              final error = await cubit.accept(offer);
                              if (error != null && context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text(error)));
                              }
                            },
                      child: Text(
                        state.acceptingId == offer.bookingId ? 'Accepting…' : 'Accept',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}

/// The job in hand: collect against the customer's code, then finish.
class _ActiveJobCard extends StatefulWidget {
  const _ActiveJobCard({required this.state});

  final PartnerState state;

  @override
  State<_ActiveJobCard> createState() => _ActiveJobCardState();
}

class _ActiveJobCardState extends State<_ActiveJobCard> {
  final _otp = TextEditingController();

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.state.activeJob!;
    final isRide = widget.state.service == DriverService.ride;
    final cubit = context.read<PartnerCubit>();

    return _Card(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                job.code,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: SellerColors.ink,
                ),
              ),
            ),
            Text(
              '₹${job.fare.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: SellerColors.teal500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _Leg(icon: '🟢', label: job.pickupAddress),
        const SizedBox(height: 6),
        _Leg(icon: '🔴', label: job.dropAddress),
        const SizedBox(height: 16),
        if (!job.isUnderWay) ...[
          Text(
            isRide
                ? 'Ask the rider for their 4-digit code'
                : 'Ask the sender for their 4-digit code',
            style: const TextStyle(fontSize: 12.5, color: SellerColors.muted),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _otp,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: const InputDecoration(labelText: 'Code', counterText: ''),
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: widget.state.isWorking
                  ? null
                  : () async {
                      final error = await cubit.startJob(_otp.text.trim());
                      if (!context.mounted) return;
                      if (error != null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(error)));
                      } else {
                        _otp.clear();
                      }
                    },
              child: Text(isRide ? 'Start trip' : 'Collect parcel'),
            ),
          ),
        ] else
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: widget.state.isWorking
                  ? null
                  : () async {
                      final error = await cubit.finishJob();
                      if (error != null && context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(error)));
                      }
                    },
              child: Text(isRide ? 'Complete trip' : 'Mark delivered'),
            ),
          ),
      ],
    );
  }
}

class _Leg extends StatelessWidget {
  const _Leg({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: SellerColors.ink2),
            ),
          ),
        ],
      );
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SellerColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 6)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );
}
