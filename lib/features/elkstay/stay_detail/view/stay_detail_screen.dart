import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/elkstay_colors.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../data/models/stay_models.dart';
import '../cubit/stay_detail_cubit.dart';

class StayDetailScreen extends StatefulWidget {
  const StayDetailScreen({super.key, required this.stayId});

  final String stayId;

  @override
  State<StayDetailScreen> createState() => _StayDetailScreenState();
}

class _StayDetailScreenState extends State<StayDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StayDetailCubit>().loadDetail(widget.stayId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StayDetailCubit, StayDetailState>(
      builder: (context, state) {
        if (state.status == StayDetailStatus.loading ||
            state.status == StayDetailStatus.initial) {
          return const Scaffold(body: LoadingView());
        }
        if (state.status == StayDetailStatus.error || state.stay == null) {
          return Scaffold(
            body: ErrorRetryView(
              message: state.errorMessage ?? 'Something went wrong',
              onRetry: () =>
                  context.read<StayDetailCubit>().loadDetail(widget.stayId),
            ),
          );
        }
        return _DetailView(stay: state.stay!, isSaved: state.isSaved);
      },
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.stay, required this.isSaved});

  final StayModel stay;
  final bool isSaved;

  static const _amenityIcons = <String, IconData>{
    'wifi': Icons.wifi,
    'meals': Icons.restaurant,
    'laundry': Icons.local_laundry_service,
    'ac': Icons.ac_unit,
    'security': Icons.security,
    'parking': Icons.local_parking,
    'backup': Icons.battery_charging_full,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElkStayColors.paper,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _HeroSection(stay: stay, isSaved: isSaved),
                ),
                SliverToBoxAdapter(
                  child: _Sheet(stay: stay, amenityIcons: _amenityIcons),
                ),
              ],
            ),
          ),
          _CtaBar(stay: stay),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.stay, required this.isSaved});

  final StayModel stay;
  final bool isSaved;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(stay.gradientStart), Color(stay.gradientEnd)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 14,
            right: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _RoundBtn(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.of(context).pop(),
                ),
                _RoundBtn(
                  icon: isSaved ? Icons.favorite : Icons.favorite_outline,
                  iconColor: ElkStayColors.honeyDeep,
                  onTap: () => context.read<StayDetailCubit>().toggleSaved(),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final active = i == 0;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.icon, this.iconColor, required this.onTap});

  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, size: 17, color: iconColor ?? ElkStayColors.ink),
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.stay, required this.amenityIcons});

  final StayModel stay;
  final Map<String, IconData> amenityIcons;

  String get _categoryTag => switch (stay.categoryType) {
    StayCategoryType.pgStay => "Women's PG",
    StayCategoryType.mensHostel => "Men's Hostel",
    StayCategoryType.womensHostel => "Women's Hostel",
    StayCategoryType.homestay => 'Homestay',
  };

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -22),
      child: Container(
        decoration: const BoxDecoration(
          color: ElkStayColors.paper,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Tag(
                  label: _categoryTag,
                  bgColor: ElkStayColors.pineSoft,
                  textColor: ElkStayColors.pine,
                ),
                const SizedBox(width: 7),
                _Tag(
                  label: stay.roomType,
                  bgColor: const Color(0xFFFBEBCF),
                  textColor: ElkStayColors.honeyDeep,
                ),
                const SizedBox(width: 7),
                if (stay.isVerified)
                  _Tag(
                    label: 'Verified',
                    bgColor: const Color(0xFFE1F0E9),
                    textColor: const Color(0xFF1A7A52),
                    icon: Icons.verified,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              stay.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: ElkStayColors.ink,
                letterSpacing: -0.3,
                height: 1.12,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 14,
                  color: ElkStayColors.muted,
                ),
                const SizedBox(width: 4),
                Text(
                  stay.fullAddress,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ElkStayColors.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 9,
              crossAxisSpacing: 9,
              childAspectRatio: 3.6,
              children: stay.amenities.map((a) {
                final icon =
                    amenityIcons[a.iconKey] ?? Icons.check_circle_outline;
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ElkStayColors.line),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Icon(icon, size: 17, color: ElkStayColors.pine),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          a.label,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: ElkStayColors.ink,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Text(
              stay.description,
              style: const TextStyle(
                fontSize: 13,
                color: ElkStayColors.muted,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.bgColor,
    required this.textColor,
    this.icon,
  });

  final String label;
  final Color bgColor;
  final Color textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaBar extends StatelessWidget {
  const _CtaBar({required this.stay});

  final StayModel stay;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${stay.pricePerMonth.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: ElkStayColors.pine,
                  ),
                ),
                const Text(
                  'per month',
                  style: TextStyle(
                    fontSize: 11,
                    color: ElkStayColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: ElkStayColors.pine,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Schedule visit',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: ElkStayColors.honey,
                  foregroundColor: const Color(0xFF3A2706),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Request to book',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
