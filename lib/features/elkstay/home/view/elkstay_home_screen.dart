import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/elkstay_colors.dart';
import '../../../../core/widgets/location_picker_sheet.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../data/models/stay_models.dart';
import '../cubit/elkstay_home_cubit.dart';

class ElkStayHomeScreen extends StatefulWidget {
  const ElkStayHomeScreen({
    super.key,
    required this.onCategoryTap,
    required this.onStayTap,
    required this.onBack,
  });

  final ValueChanged<StayCategoryType> onCategoryTap;
  final ValueChanged<String> onStayTap;
  final VoidCallback onBack;

  @override
  State<ElkStayHomeScreen> createState() => _ElkStayHomeScreenState();
}

class _ElkStayHomeScreenState extends State<ElkStayHomeScreen> {
  PickedLocation? _pickedLocation;

  @override
  void initState() {
    super.initState();
    context.read<ElkStayHomeCubit>().loadHomeData();
  }

  Future<void> _chooseLocation() async {
    final picked = await showLocationPicker(context, selectedId: _pickedLocation?.id);
    if (picked != null) setState(() => _pickedLocation = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElkStayColors.paper,
      body: BlocBuilder<ElkStayHomeCubit, ElkStayHomeState>(
        builder: (context, state) {
          if (state.status == ElkStayHomeStatus.loading ||
              state.status == ElkStayHomeStatus.initial) {
            return const LoadingView();
          }
          if (state.status == ElkStayHomeStatus.error || state.feed == null) {
            return ErrorRetryView(
              message: state.errorMessage ?? 'Something went wrong',
              onRetry: () => context.read<ElkStayHomeCubit>().loadHomeData(),
            );
          }

          final feed = state.feed!;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _Header(
                  feed: feed,
                  onBack: widget.onBack,
                  location: _pickedLocation?.address ?? feed.location,
                  onLocationTap: _chooseLocation,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _SectionLabel('What are you looking for?'),
                    const SizedBox(height: 12),
                    _CategoryGrid(
                      categories: feed.categories,
                      onTap: widget.onCategoryTap,
                    ),
                    const SizedBox(height: 24),
                    _SectionHeader(title: 'Top rated near you'),
                    const SizedBox(height: 12),
                    _TopRatedList(
                      stays: feed.topRated,
                      onTap: (stay) => widget.onStayTap(stay.id),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.feed,
    required this.onBack,
    required this.location,
    required this.onLocationTap,
  });

  final ElkStayHomeFeed feed;
  final VoidCallback onBack;
  final String location;
  final VoidCallback onLocationTap;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.5, -1),
            end: Alignment(0.8, 1),
            colors: [Color(0xFF1A4A3C), Color(0xFF0C241D)],
          ),
        ),
        child: Stack(children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.9, -1.0),
                    radius: 1.3,
                    colors: const [Color(0xBF0F6E60), Color(0x000F6E60)],
                    stops: const [0.0, 0.55],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, top + 14, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: onBack,
                      child: Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Good morning,',
                            style: TextStyle(fontSize: 13, color: Color(0xFFB7CCC2), fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${feed.userName} 👋',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF6CE19), Color(0xFFE08A1E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Center(
                        child: Text(
                          'A',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF3A2706)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Color(0xFFB7CCC2), size: 18),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          'Search area, college, or PG',
                          style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.6)),
                        ),
                      ),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.tune, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onLocationTap,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Color(0xFFF6CE19)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          location,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Color(0xFFB7CCC2), fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: Color(0xFFB7CCC2)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: ElkStayColors.ink,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ElkStayColors.ink),
        ),
        Text(
          'See all',
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: ElkStayColors.honeyDeep),
        ),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.categories, required this.onTap});

  final List<StayCategoryModel> categories;
  final ValueChanged<StayCategoryType> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 11,
      crossAxisSpacing: 11,
      childAspectRatio: 1.9,
      children: categories.map((cat) => _CategoryCard(cat: cat, onTap: onTap)).toList(),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.cat, required this.onTap});

  final StayCategoryModel cat;
  final ValueChanged<StayCategoryType> onTap;

  LinearGradient get _gradient => switch (cat.type) {
        StayCategoryType.pgStay => ElkStayColors.pgGradient,
        StayCategoryType.mensHostel => ElkStayColors.mensGradient,
        StayCategoryType.womensHostel => ElkStayColors.womensGradient,
        StayCategoryType.homestay => ElkStayColors.homestayGradient,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(cat.type),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: _gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(cat.emoji, style: const TextStyle(fontSize: 22)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${cat.count} nearby',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TopRatedList extends StatelessWidget {
  const _TopRatedList({required this.stays, required this.onTap});

  final List<StayModel> stays;
  final ValueChanged<StayModel> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 198,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: stays.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _StayCard(stay: stays[i], onTap: onTap),
      ),
    );
  }
}

class _StayCard extends StatelessWidget {
  const _StayCard({required this.stay, required this.onTap});

  final StayModel stay;
  final ValueChanged<StayModel> onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(stay),
      child: Container(
        width: 188,
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
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(stay.gradientStart), Color(stay.gradientEnd)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned(
                  top: 9,
                  left: 9,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      stay.badge,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                Positioned(
                  top: 9,
                  right: 9,
                  child: Container(
                    width: 27,
                    height: 27,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.favorite_outline, size: 14, color: ElkStayColors.honeyDeep),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stay.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: ElkStayColors.ink),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 11, color: ElkStayColors.muted),
                      const SizedBox(width: 2),
                      Text(
                        stay.location,
                        style: const TextStyle(fontSize: 11, color: ElkStayColors.muted, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${stay.pricePerMonth ~/ 1000}k/mo',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: ElkStayColors.pine,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 12, color: ElkStayColors.honey),
                          const SizedBox(width: 2),
                          Text(
                            '${stay.rating}',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: ElkStayColors.ink),
                          ),
                        ],
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
