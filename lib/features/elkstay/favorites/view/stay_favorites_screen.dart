import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/elkstay_colors.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../data/models/stay_models.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/stay_favorites_cubit.dart';

/// The stays a user has hearted, read back from `GET /elkstay/favorites`.
class StayFavoritesScreen extends StatefulWidget {
  const StayFavoritesScreen({
    super.key,
    required this.onBack,
    required this.onStayTap,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onStayTap;

  @override
  State<StayFavoritesScreen> createState() => _StayFavoritesScreenState();
}

class _StayFavoritesScreenState extends State<StayFavoritesScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<StayFavoritesCubit>();
    // Always refetch: a stay can be unsaved from its detail screen while this
    // list is still in the navigation stack behind it.
    cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: ElkStayColors.paper,
      appBar: AppBar(
        backgroundColor: ElkStayColors.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back_rounded, color: ElkStayColors.ink),
        ),
        title: Text(
          l10n.savedStays,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ElkStayColors.ink,
          ),
        ),
      ),
      body: BlocConsumer<StayFavoritesCubit, StayFavoritesState>(
        // A failed unsave puts the stay back in the list; the message explains
        // why it reappeared.
        listenWhen: (before, after) =>
            after.errorMessage != null &&
            after.status == StayFavoritesStatus.success,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        },
        builder: (context, state) => switch (state.status) {
          StayFavoritesStatus.initial ||
          StayFavoritesStatus.loading =>
            const LoadingView(),
          StayFavoritesStatus.guest =>
            SignInRequiredView(message: l10n.savedStaysSignIn),
          StayFavoritesStatus.error => ErrorRetryView(
              message: state.errorMessage ?? '',
              onRetry: () => context.read<StayFavoritesCubit>().load(),
            ),
          StayFavoritesStatus.success => state.stays.isEmpty
              ? EmptyStateView(
                  message: '${l10n.noSavedStaysYet}\n${l10n.noSavedStaysBody}',
                  icon: Icons.favorite_border_rounded,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: state.stays.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _SavedStayCard(
                    stay: state.stays[i],
                    onTap: () => widget.onStayTap(state.stays[i].id),
                    onRemove: () =>
                        context.read<StayFavoritesCubit>().remove(
                              state.stays[i].id,
                            ),
                  ),
                ),
        },
      ),
    );
  }
}

class _SavedStayCard extends StatelessWidget {
  const _SavedStayCard({
    required this.stay,
    required this.onTap,
    required this.onRemove,
  });

  final StayModel stay;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ElkStayColors.line),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stay.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: ElkStayColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stay.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ElkStayColors.muted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${stay.pricePerMonth}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: ElkStayColors.pine,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(
                Icons.favorite_rounded,
                color: Color(0xFFE2554C),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
