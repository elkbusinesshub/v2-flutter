import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/elkstay_colors.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../data/models/stay_models.dart';
import '../cubit/stay_bookings_cubit.dart';

class StayBookingsScreen extends StatefulWidget {
  const StayBookingsScreen({super.key});

  @override
  State<StayBookingsScreen> createState() => _StayBookingsScreenState();
}

class _StayBookingsScreenState extends State<StayBookingsScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<StayBookingsCubit>();
    if (cubit.state.status == StayBookingsStatus.initial) {
      cubit.loadBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElkStayColors.paper,
      body: SafeArea(
        child: BlocBuilder<StayBookingsCubit, StayBookingsState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 14),
                  child: Text(
                    'My stays',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: ElkStayColors.ink,
                    ),
                  ),
                ),
                _TabBar(activeTab: state.activeTab),
                const SizedBox(height: 4),
                Expanded(child: _buildBody(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, StayBookingsState state) {
    if (state.status == StayBookingsStatus.loading ||
        state.status == StayBookingsStatus.initial) {
      return const LoadingView();
    }
    if (state.status == StayBookingsStatus.error) {
      return ErrorRetryView(
        message: state.errorMessage ?? 'Something went wrong',
        onRetry: () => context.read<StayBookingsCubit>().loadBookings(),
      );
    }
    final items = state.visibleBookings;
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hotel_outlined, size: 48, color: ElkStayColors.muted.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            const Text(
              'No stays here yet',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ElkStayColors.muted),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _BookingCard(booking: items[i]),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.activeTab});

  final int activeTab;

  @override
  Widget build(BuildContext context) {
    const labels = ['Active', 'Requests', 'Past'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == activeTab;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => context.read<StayBookingsCubit>().setTab(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? ElkStayColors.pine : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: active ? ElkStayColors.pine : ElkStayColors.line,
                  ),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : ElkStayColors.muted,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final StayBookingModel booking;

  Color get _statusBg => switch (booking.status) {
        StayBookingStatus.confirmed => const Color(0xFFE1F0E9),
        StayBookingStatus.visitBooked => const Color(0xFFFBEBCF),
        _ => const Color(0xFFF3F4F6),
      };

  Color get _statusColor => switch (booking.status) {
        StayBookingStatus.confirmed => const Color(0xFF1A7A52),
        StayBookingStatus.visitBooked => ElkStayColors.honeyDeep,
        _ => ElkStayColors.muted,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ElkStayColors.line),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(booking.gradientStart), Color(booking.gradientEnd)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            booking.stayName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: ElkStayColors.ink,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: _statusBg,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            booking.status.label,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: _statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${booking.roomType} · ${booking.location}',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: ElkStayColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: ElkStayColors.line, style: BorderStyle.solid)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MetaCol(label: booking.primaryDateLabel, value: booking.primaryDate),
                _MetaCol(label: 'Rent', value: '₹${booking.rentPerMonth}/mo'),
                _MetaCol(label: booking.secondaryLabel, value: booking.secondaryValue),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaCol extends StatelessWidget {
  const _MetaCol({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 10, color: ElkStayColors.muted, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ElkStayColors.ink),
        ),
      ],
    );
  }
}
