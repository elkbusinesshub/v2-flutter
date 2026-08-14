import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/elkstay_colors.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../data/models/stay_models.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/elkstay_explore_cubit.dart';

class ElkStayExploreScreen extends StatefulWidget {
  const ElkStayExploreScreen({super.key, required this.onStayTap});

  final ValueChanged<String> onStayTap;

  @override
  State<ElkStayExploreScreen> createState() => _ElkStayExploreScreenState();
}

class _ElkStayExploreScreenState extends State<ElkStayExploreScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<ElkStayExploreCubit>();
    if (cubit.state.status == ElkStayExploreStatus.initial) {
      cubit.loadStays();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElkStayColors.paper,
      body: SafeArea(
        child: BlocBuilder<ElkStayExploreCubit, ElkStayExploreState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ExploreHeader(state: state),
                _FilterChips(state: state),
                const SizedBox(height: 4),
                Expanded(
                  child: _buildBody(context, state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ElkStayExploreState state) {
    final l10n = AppLocalizations.of(context);
    if (state.status == ElkStayExploreStatus.loading ||
        state.status == ElkStayExploreStatus.initial) {
      return const LoadingView();
    }
    if (state.status == ElkStayExploreStatus.error) {
      return ErrorRetryView(
        message: state.errorMessage ?? l10n.errorGeneric,
        onRetry: () => context.read<ElkStayExploreCubit>().loadStays(),
      );
    }
    if (state.stays.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48, color: ElkStayColors.muted),
            const SizedBox(height: 12),
            Text(
              l10n.noStaysFound,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ElkStayColors.muted),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: state.stays.length,
      separatorBuilder: (_, _) => const SizedBox(height: 13),
      itemBuilder: (context, i) => _StayListCard(
        stay: state.stays[i],
        onTap: () => widget.onStayTap(state.stays[i].id),
      ),
    );
  }
}

class _ExploreHeader extends StatelessWidget {
  const _ExploreHeader({required this.state});
  final ElkStayExploreState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.titleLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: ElkStayColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${state.countLabel} verified stays',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: ElkStayColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: ElkStayColors.pineSoft,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.tune, color: ElkStayColors.pine, size: 17),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.state});
  final ElkStayExploreState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ElkStayExploreCubit>();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _Chip(
            label: l10n.verified,
            icon: Icons.verified,
            active: state.verifiedOnly,
            onTap: cubit.toggleVerified,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: l10n.underTwelveK,
            active: state.priceFilter,
            onTap: cubit.togglePriceFilter,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: l10n.singleRoom,
            active: state.singleRoomOnly,
            onTap: cubit.toggleSingleRoom,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: l10n.meals,
            active: state.mealsIncluded,
            onTap: cubit.toggleMeals,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.icon, required this.active, required this.onTap});

  final String label;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: active ? ElkStayColors.pine : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? ElkStayColors.pine : ElkStayColors.line,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: active ? Colors.white : ElkStayColors.muted),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : ElkStayColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StayListCard extends StatelessWidget {
  const _StayListCard({required this.stay, required this.onTap});

  final StayModel stay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ElkStayColors.line),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 118,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(stay.gradientStart), Color(stay.gradientEnd)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${stay.badge} · ${stay.roomType}',
                      style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.favorite_outline, size: 15, color: ElkStayColors.honeyDeep),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          stay.name,
                          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: ElkStayColors.ink),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 13, color: ElkStayColors.honey),
                          const SizedBox(width: 2),
                          Text('${stay.rating}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: ElkStayColors.muted),
                      const SizedBox(width: 3),
                      Text(
                        stay.fullAddress,
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: ElkStayColors.muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '₹${stay.pricePerMonth.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: ElkStayColors.pine,
                              ),
                            ),
                            const TextSpan(
                              text: ' /month',
                              style: TextStyle(fontSize: 11, color: ElkStayColors.muted, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      if (stay.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1F0E9),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified, size: 12, color: Color(0xFF1A7A52)),
                              const SizedBox(width: 3),
                              Text(
                                l10n.verified,
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF1A7A52)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
