import '../../core/errors/api_exception.dart';
import '../../data/models/ad_models.dart';
import '../../data/models/notification_models.dart';
import '../../data/repositories/notifications_repository.dart';
import '../../data/repositories/marketplace_repository.dart';
import 'cubit/seller_listings_cubit.dart';
import 'cubit/seller_orders_cubit.dart';
import 'cubit/seller_business_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/seller_colors.dart';
import 'view/partner_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../data/datasources/seller_data.dart';
import '../account_switcher/account_switcher_sheet.dart';

enum _Tab { home, listings, drive, orders, wallet }

class SellerShell extends StatefulWidget {
  const SellerShell({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  State<SellerShell> createState() => _SellerShellState();
}

class _SellerShellState extends State<SellerShell> {
  AppLocalizations get l10n => AppLocalizations.of(context);

  _Tab _tab = _Tab.home;
  bool _bankLinked = false;

  void _go(_Tab t) => setState(() => _tab = t);

  void _openAccountSwitcher() {
    showAccountSwitcher(
      context,
      isSeller: true,
      onSwitchToSeller: () {},                  // already on seller panel
      onSwitchToUser: () => widget.onBack(),    // go back to main hub
    );
  }

  void _toast(String icon, String title, String sub, {bool gold = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: gold ? SellerColors.gold : SellerColors.teal500,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 19))),
          ),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white)),
            Text(sub, style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.7))),
          ])),
        ]),
        backgroundColor: SellerColors.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
        duration: const Duration(seconds: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );
  }

  // ─── App bar ─────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    final isHome = _tab == _Tab.home;
    final titles = {
      _Tab.listings: l10n.myListings,
      _Tab.drive: l10n.sellerDrive,
      _Tab.orders: l10n.orders,
      _Tab.wallet: l10n.navWallet,
    };
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment(1.3, 1.0),
          colors: [SellerColors.teal900, SellerColors.teal700, SellerColors.teal500],
          stops: [0, 0.55, 1],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      padding: EdgeInsets.fromLTRB(18, MediaQuery.of(context).padding.top + 14, 18, isHome ? 0 : 20),
      child: isHome ? _homeAppBar() : _titleAppBar(titles[_tab]!),
    );
  }

  Widget _homeAppBar() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.partnerDashboard, style: TextStyle(fontSize: 13, color: Color(0xFFBFE3DA), fontWeight: FontWeight.w500)),
          const SizedBox(height: 1),
          Row(children: [
            const Text('Bright Spark Services', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
            const SizedBox(width: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.verified, size: 12, color: Color(0xFFD6FFE9)),
                SizedBox(width: 4),
                Text(l10n.verified, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFD6FFE9), letterSpacing: 0.2)),
              ]),
            ),
          ]),
        ])),
        Row(children: [
          // Notification bell
          GestureDetector(
            onTap: () => _showNotifSheet(),
            child: Stack(clipBehavior: Clip.none, children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.13), shape: BoxShape.circle),
                child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 21),
              ),
              Positioned(top: 9, right: 10, child: Container(width: 9, height: 9, decoration: BoxDecoration(color: SellerColors.gold, border: Border.all(color: SellerColors.teal700, width: 2), shape: BoxShape.circle))),
            ]),
          ),
          const SizedBox(width: 10),
          // ELK ▼ account trigger (dark variant for teal bg)
          AccountTriggerPill(onTap: _openAccountSwitcher, dark: true),
        ]),
      ]),
      const SizedBox(height: 16),
      // Online toggle
      GestureDetector(
        onTap: () {
          // Writes through rather than flipping a local flag: a seller could
          // otherwise believe they were offline while the backend kept them
          // listed and taking work.
          final next = !_isOnline;
          context.read<SellerBusinessCubit>().setAvailable(next);
          _toast(
            next ? '🟢' : '⚪',
            next ? l10n.youAreOnline : l10n.youAreOffline,
            next ? l10n.customersCanBook : l10n.noNewRequests,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(
                color: _isOnline ? const Color(0xFF4FE6A8) : SellerColors.gold,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: (_isOnline ? const Color(0xFF4FE6A8) : SellerColors.gold).withValues(alpha: 0.35), blurRadius: 6, spreadRadius: 2)],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_isOnline ? l10n.youAreOnline : l10n.youAreOffline, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              Text(_isOnline ? 'Accepting new bookings' : 'Not receiving requests', style: const TextStyle(fontSize: 11.5, color: Color(0xFFBFE3DA))),
            ])),
            _OnlineSwitch(value: _isOnline),
          ]),
        ),
      ),
    ]);
  }

  Widget _titleAppBar(String title) {
    return Row(children: [
      GestureDetector(
        onTap: () => _go(_Tab.home),
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.13), shape: BoxShape.circle),
          child: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(child: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.2))),
      GestureDetector(
        onTap: () => _showNotifSheet(),
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.13), shape: BoxShape.circle),
          child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
        ),
      ),
    ]);
  }

  // ─── Bottom nav ──────────────────────────────────────────────────────────

  Widget _buildNav() {
    return Container(
      decoration: const BoxDecoration(
        color: SellerColors.card,
        border: Border(top: BorderSide(color: SellerColors.line)),
        boxShadow: [BoxShadow(color: Color(0x0F101828), blurRadius: 24, offset: Offset(0, -6))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(children: [
            _navItem(_Tab.home, Icons.home_outlined, Icons.home_rounded, l10n.navHome),
            _navItem(_Tab.listings, Icons.grid_view_outlined, Icons.grid_view_rounded, l10n.listings),
            _navItem(_Tab.drive, Icons.local_taxi_outlined, Icons.local_taxi_rounded, l10n.sellerDrive),
            // Centre elevated Post button
            SizedBox(
              width: 72,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Transform.translate(
                  offset: const Offset(0, -18),
                  child: GestureDetector(
                    onTap: () => _showPostSheet(),
                    child: Container(
                      width: 54, height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [SellerColors.teal500, SellerColors.teal600]),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [BoxShadow(color: Color(0x661E6B5E), blurRadius: 20, offset: Offset(0, 8))],
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -16),
                  child: Text(l10n.post, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: SellerColors.teal500)),
                ),
              ]),
            ),
            _navItem(_Tab.orders, Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, l10n.orders),
            _navItem(_Tab.wallet, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, l10n.navWallet),
          ]),
        ),
      ),
    );
  }

  Widget _navItem(_Tab t, IconData inactive, IconData active, String label) {
    final isOn = _tab == t;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _go(t),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(isOn ? active : inactive, size: 23, color: isOn ? SellerColors.teal500 : SellerColors.muted2),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10.5, fontWeight: isOn ? FontWeight.w700 : FontWeight.w600, color: isOn ? SellerColors.teal500 : SellerColors.muted2)),
        ]),
      ),
    );
  }

  /// Whether the seller is accepting work, as the server has it.
  bool get _isOnline => context.watch<SellerBusinessCubit>().state.isAvailable;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) => widget.onBack(),
      child: Scaffold(
        backgroundColor: SellerColors.bg,
        body: Column(children: [
          _buildAppBar(),
          Expanded(
            child: IndexedStack(
              index: _tab.index,
              children: [
                _homeScreen(),
                _listingsScreen(),
                // The partner persona: driving and delivering. Same account,
                // different work from selling a listing.
                const PartnerScreen(),
                _ordersScreen(),
                _walletScreen(),
              ],
            ),
          ),
        ]),
        bottomNavigationBar: _buildNav(),
      ),
    );
  }

  // ─── Dashboard ───────────────────────────────────────────────────────────

  Widget _homeScreen() {
    final orderState = context.watch<SellerOrdersCubit>().state;
    final newOrders = orderState.attentionOrders;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        if (!_bankLinked) ...[
          GestureDetector(
            onTap: () => _showBankSheet(),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFF8E6), Color(0xFFFDF0D0)]),
                border: Border.all(color: const Color(0xFFF3E2A6)),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 22, offset: Offset(0, 6))],
              ),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: SellerColors.gold, borderRadius: BorderRadius.circular(13)),
                  child: Center(child: Text('🏦', style: TextStyle(fontSize: 22))),
                ),
                SizedBox(width: 13),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10n.linkBankToGetPaid, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFF7A5E00))),
                  Text(l10n.addAccountToTransfer, style: TextStyle(fontSize: 12.5, color: Color(0xFF9A7D28))),
                  SizedBox(height: 6),
                  Row(children: [
                    Text(l10n.addBankAccount, style: TextStyle(color: Color(0xFFCAA20D), fontWeight: FontWeight.w800, fontSize: 13)),
                    SizedBox(width: 3),
                    Icon(Icons.arrow_forward, size: 13, color: Color(0xFFCAA20D)),
                  ]),
                ])),
              ]),
            ),
          ),
          const SizedBox(height: 22),
        ],
        _SectionTitle(text: l10n.quickActions),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showPostSheet(),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [SellerColors.teal600, SellerColors.teal500]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Color(0x3D1E6B5E), blurRadius: 20, offset: Offset(0, 8))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('➕', style: TextStyle(fontSize: 21)))),
                  const SizedBox(height: 9),
                  Text(l10n.postNewAd, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                  Text(l10n.listServiceOrItem, style: TextStyle(fontSize: 11.5, color: Color(0xFFBFE7DD))),
                ]),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => _go(_Tab.orders),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: SellerColors.card, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 22, offset: Offset(0, 6))]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 42, height: 42, decoration: BoxDecoration(color: SellerColors.tYellow, borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('📦', style: TextStyle(fontSize: 21)))),
                  const SizedBox(height: 9),
                  Text(l10n.viewOrders, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: SellerColors.ink)),
                  // Was a hardcoded "6 need attention" sitting above an empty
                  // Orders tab.
                  Text(l10n.needAttention(orderState.needsAttention),
                      style: const TextStyle(fontSize: 11.5, color: SellerColors.muted)),
                ]),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 22),
        _SectionTitle(text: l10n.todayAtAGlance),
        // const SizedBox(height: 12),
        // 2×2 stats
        GridView.count(
          crossAxisCount: 2, mainAxisSpacing: 20, crossAxisSpacing: 20,
          childAspectRatio: 1.55, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          children: [
            _StatCard(icon: '💰', bg: SellerColors.tMint, label: l10n.todaysEarnings, value: '₹0', delta: l10n.noEarningsYet, positive: null),
            _StatCard(icon: '🔥', bg: SellerColors.tYellow, label: l10n.newRequests, value: '0', delta: l10n.nothingWaiting, positive: null),
            _StatCard(icon: '📋', bg: SellerColors.tPurple, label: l10n.activeJobs, value: '0', delta: l10n.noActiveJobs, positive: null),
            _StatCard(icon: '⭐', bg: SellerColors.tPink, label: l10n.profileRating, value: '—', delta: l10n.noReviewsYet, positive: true),
          ],
        ),
        // Earnings chart
        // const SizedBox(height: 12),
        // Container(
        //   padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        //   decoration: BoxDecoration(color: SellerColors.card, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 22, offset: Offset(0, 6))]),
        //   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        //     Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        //       const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        //         Text('₹5,420', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: -0.6, color: SellerColors.ink)),
        //         Text(l10n.earningsThisWeek, style: TextStyle(fontSize: 12, color: SellerColors.muted, fontWeight: FontWeight.w600)),
        //       ]),
        //       Container(
        //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        //         decoration: BoxDecoration(color: SellerColors.green50, borderRadius: BorderRadius.circular(20)),
        //         child: const Text('▲ 12%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: SellerColors.green)),
        //       ),
        //     ]),
        //     const SizedBox(height: 14),
        //     SizedBox(
        //       height: 110,
        //       child: Row(
        //         crossAxisAlignment: CrossAxisAlignment.end,
        //         children: List.generate(barData.length, (i) => Expanded(
        //           child: Padding(
        //             padding: const EdgeInsets.symmetric(horizontal: 4),
        //             child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        //               Expanded(
        //                 child: Align(
        //                   alignment: Alignment.bottomCenter,
        //                   child: FractionallySizedBox(
        //                     heightFactor: barData[i] / 100,
        //                     child: Container(
        //                       decoration: BoxDecoration(
        //                         color: i == 5 ? null : SellerColors.teal50,
        //                         gradient: i == 5 ? const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [SellerColors.teal400, SellerColors.teal600]) : null,
        //                         borderRadius: const BorderRadius.vertical(top: Radius.circular(8), bottom: Radius.circular(4)),
        //                       ),
        //                     ),
        //                   ),
        //                 ),
        //               ),
        //               const SizedBox(height: 7),
        //               Text(barDays[i], style: const TextStyle(fontSize: 10.5, color: SellerColors.muted, fontWeight: FontWeight.w700)),
        //             ]),
        //           ),
        //         )),
        //       ),
        //     ),
        //   ]),
        // ),
        const SizedBox(height: 22),
        
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _SectionTitle(text: l10n.recentBookings),
          GestureDetector(onTap: () => _go(_Tab.orders), child: Text(l10n.commonSeeAll, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: SellerColors.teal500))),
        ]),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: SellerColors.card, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 22, offset: Offset(0, 6))]),
          child: newOrders.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 26),
                  child: Center(
                    child: Text(l10n.noOrdersRightNow,
                        style: const TextStyle(fontSize: 13, color: SellerColors.muted)),
                  ),
                )
              : Column(
                  children: newOrders
                      .asMap()
                      .entries
                      .map((e) => _OrderRow(
                            order: e.value,
                            isLast: e.key == newOrders.length - 1,
                            onTap: () => _showOrderSheet(e.value),
                          ))
                      .toList(),
                ),
        ),
      ],
    );
  }

  // ─── Listings ────────────────────────────────────────────────────────────

  Widget _listingsScreen() {
    return BlocConsumer<SellerListingsCubit, SellerListingsState>(
      listenWhen: (before, after) => after.errorMessage != null,
      listener: (context, state) => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.errorMessage!))),
      builder: (context, state) {
        // Counts come from the same list the rows do. The fixture panel showed
        // "All 5 / Active 3" above a permanently empty list.
        final tabs = <(AdStatus?, String)>[
          (null, l10n.chipAll),
          (AdStatus.active, l10n.tabActive),
          (AdStatus.draft, l10n.inReview),
          (AdStatus.paused, l10n.paused),
        ];

        return Column(children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
              children: tabs.map((t) {
                final on = state.tab == t.$1;
                return GestureDetector(
                  onTap: () => context.read<SellerListingsCubit>().selectTab(t.$1),
                  child: Container(
                    margin: const EdgeInsets.only(right: 9),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: on ? SellerColors.teal600 : SellerColors.card,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 6, offset: Offset(0, 2))],
                    ),
                    child: Text('${t.$2} ${state.countOf(t.$1)}',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: on ? Colors.white : SellerColors.ink2)),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(child: switch (state.status) {
            SellerListingsStatus.initial ||
            SellerListingsStatus.loading =>
              const Center(child: CircularProgressIndicator(color: SellerColors.teal600)),
            SellerListingsStatus.error => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(state.errorMessage ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: SellerColors.muted, fontSize: 14)),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.read<SellerListingsCubit>().load(),
                      child: Text(l10n.commonRetry),
                    ),
                  ]),
                ),
              ),
            SellerListingsStatus.success => state.visibleAds.isEmpty
                ? Center(child: Text(l10n.nothingHereYet, style: const TextStyle(color: SellerColors.muted, fontSize: 15)))
                : RefreshIndicator(
                    onRefresh: () => context.read<SellerListingsCubit>().load(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: state.visibleAds.length,
                      itemBuilder: (context, i) {
                        final ad = state.visibleAds[i];
                        return _AdCard(
                          ad: ad,
                          onTogglePause: () => context
                              .read<SellerListingsCubit>()
                              .setPaused(ad.id, ad.status != AdStatus.paused),
                          onDelete: () => _confirmDelete(ad),
                        );
                      },
                    ),
                  ),
          }),
        ]);
      },
    );
  }

  Future<void> _confirmDelete(AdModel ad) async {
    final cubit = context.read<SellerListingsCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteListing),
        content: Text(ad.title),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonDelete, style: const TextStyle(color: Color(0xFFD64545))),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await cubit.delete(ad.id);
  }

  // ─── Orders ──────────────────────────────────────────────────────────────

  Widget _ordersScreen() {
    return BlocConsumer<SellerOrdersCubit, SellerOrdersState>(
      listenWhen: (before, after) => after.errorMessage != null,
      listener: (context, state) => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.errorMessage!))),
      builder: (context, state) {
        final tabs = <(AdOrderStatus, String)>[
          (AdOrderStatus.newOrder, l10n.homeBadgeNew),
          (AdOrderStatus.inProgress, l10n.inProgress),
          (AdOrderStatus.completed, l10n.statusCompleted),
          (AdOrderStatus.cancelled, l10n.statusCancelled),
        ];

        return Column(children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
              children: tabs.map((t) {
                final on = state.tab == t.$1;
                final count = state.countOf(t.$1);
                return GestureDetector(
                  onTap: () => context.read<SellerOrdersCubit>().selectTab(t.$1),
                  child: Container(
                    margin: const EdgeInsets.only(right: 9),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: on ? SellerColors.teal600 : SellerColors.card,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 6, offset: Offset(0, 2))],
                    ),
                    // Counted from the loaded orders, so a tab never promises
                    // rows the list below cannot show.
                    child: Text(count > 0 ? '${t.$2} $count' : t.$2,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: on ? Colors.white : SellerColors.ink2)),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(child: switch (state.status) {
            SellerOrdersStatus.initial ||
            SellerOrdersStatus.loading =>
              const Center(child: CircularProgressIndicator(color: SellerColors.teal600)),
            SellerOrdersStatus.error => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(state.errorMessage ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: SellerColors.muted, fontSize: 14)),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.read<SellerOrdersCubit>().load(),
                      child: Text(l10n.commonRetry),
                    ),
                  ]),
                ),
              ),
            SellerOrdersStatus.success => state.visibleOrders.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('📭', style: TextStyle(fontSize: 46)),
                    const SizedBox(height: 12),
                    Text(l10n.allClear, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: SellerColors.ink2)),
                    Text(l10n.noOrdersRightNow, style: const TextStyle(fontSize: 13, color: SellerColors.muted)),
                  ]))
                : RefreshIndicator(
                    onRefresh: () => context.read<SellerOrdersCubit>().load(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: state.visibleOrders.length,
                      itemBuilder: (context, i) => Container(
                        decoration: BoxDecoration(color: SellerColors.card, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 22, offset: Offset(0, 6))]),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: _OrderRow(
                          order: state.visibleOrders[i],
                          isLast: true,
                          onTap: () => _showOrderSheet(state.visibleOrders[i]),
                        ),
                      ),
                    ),
                  ),
          }),
        ]);
      },
    );
  }

  // ─── Wallet ──────────────────────────────────────────────────────────────

  Widget _walletScreen() {
    final business = context.watch<SellerBusinessCubit>().state;
    final earnings = business.earnings;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        // Balance card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [SellerColors.teal700, SellerColors.teal500]),
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [BoxShadow(color: Color(0x4D155049), blurRadius: 34, offset: Offset(0, 12))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('💰', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text(l10n.walletAvailableBalance, style: TextStyle(fontSize: 13, color: Color(0xFFBFE7DD), fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 5),
            // Was hardcoded ₹0 with an invented "₹640 pending". These are the
            // seller's real earnings, from the same endpoint the provider
            // dashboard used before the two surfaces merged.
            Text(
              earnings == null ? '—' : '₹${earnings.totalEarnings}',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1),
            ),
            Text(
              earnings == null
                  ? 'Set up your business profile to track earnings'
                  : '${earnings.completedJobs} jobs · avg ₹${earnings.avgPerJob}',
              style: const TextStyle(fontSize: 12.5, color: Color(0xFFBFE7DD)),
            ),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showWithdrawSheet(),
                  child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('↑ ', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: SellerColors.teal700)), Text(l10n.walletWithdraw, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: SellerColors.teal700))]),
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(14)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('📄 ', style: TextStyle(fontSize: 13.5)), Text(l10n.statement, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white))]),
                ),
              ),
            ]),
          ]),
        ),
        const SizedBox(height: 22),
        _SectionTitle(text: l10n.payoutMethod),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showBankSheet(),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: SellerColors.card, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 22, offset: Offset(0, 6))]),
            child: Row(children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: _bankLinked ? SellerColors.blue50 : SellerColors.amber50, borderRadius: BorderRadius.circular(13)), child: Center(child: Text(_bankLinked ? '🏦' : '⚠️', style: const TextStyle(fontSize: 23)))),
              const SizedBox(width: 13),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_bankLinked ? 'HDFC Bank' : l10n.noBankLinked, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: SellerColors.ink)),
                Text(_bankLinked ? l10n.accountVerified : l10n.addAccountToWithdraw, style: const TextStyle(fontSize: 12.5, color: SellerColors.muted)),
              ])),
              Text(_bankLinked ? '✓' : '+ Add', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _bankLinked ? SellerColors.green : SellerColors.teal500)),
            ]),
          ),
        ),
        const SizedBox(height: 22),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _SectionTitle(text: l10n.recentTransactions),
          Text(l10n.export, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: SellerColors.teal500)),
        ]),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: SellerColors.card, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 22, offset: Offset(0, 6))]),
          child: Column(children: sellerTransactions.asMap().entries.map((e) => _TxnRow(txn: e.value, isLast: e.key == sellerTransactions.length - 1)).toList()),
        ),
      ],
    );
  }

  // ─── Sheets ──────────────────────────────────────────────────────────────

  void _showPostSheet() {
    int selectedCat = -1;
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final cubit = context.read<SellerListingsCubit>();
    // (label, emoji, tile colour, backend category slug)
    final cats = <(String, String, Color, String)>[
      (l10n.svcTaxiRides, '🚕', SellerColors.tBlue, 'taxi'),
      (l10n.svcCleaning, '🧹', SellerColors.tYellow, 'cleaning'),
      (l10n.svcCarRental, '🚗', SellerColors.tPurple, 'car_rental'),
      (l10n.svcRepair, '🔧', SellerColors.tPink, 'repairing'),
      (l10n.catPorter, '📦', SellerColors.tGreen, 'porter'),
      ('ELK Stay', '🏨', SellerColors.tMint, 'elkstay'),
    ];
    final pricingUnits = <String, String>{
      l10n.fixedPrice: '',
      l10n.perHour: '/ hour',
      l10n.perDay: '/ day',
      l10n.startingFrom: 'starting',
    };
    var pricingType = l10n.fixedPrice;
    final imageKeys = <String>[];
    var uploading = false;

    // Per-category detail. These keys must match the backend's schema in
    // ad-attributes.ts, which rejects anything it does not define rather than
    // silently dropping it.
    final durationCtrl = TextEditingController();
    final includesCtrl = TextEditingController();
    final warrantyCtrl = TextEditingController();
    final seatsCtrl = TextEditingController();
    final roomTypeCtrl = TextEditingController();
    final depositCtrl = TextEditingController();
    // "Not specified" maps to null so the key is left out entirely — better
    // than guessing a default the seller never chose.
    const transmissions = <String, String?>{
      'Not specified': null,
      'Automatic': 'AUTOMATIC',
      'Manual': 'MANUAL',
    };
    const fuels = <String, String?>{
      'Not specified': null,
      'Petrol': 'PETROL',
      'Diesel': 'DIESEL',
      'Electric': 'ELECTRIC',
      'Hybrid': 'HYBRID',
    };
    const stayTypes = <String, String?>{
      'Not specified': null,
      'PG': 'PG',
      "Men's hostel": 'MENS_HOSTEL',
      "Women's hostel": 'WOMENS_HOSTEL',
      'Homestay': 'HOMESTAY',
    };
    var transmission = 'Not specified';
    var fuel = 'Not specified';
    var stayType = 'Not specified';
    var furnished = false;

    /// What the seller filled in for the chosen category, omitting blanks.
    Map<String, dynamic> attributesFor(String slug) {
      String t(TextEditingController c) => c.text.trim();
      final includes = includesCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      return switch (slug) {
        'cleaning' => {
            if (t(durationCtrl).isNotEmpty) 'durationLabel': t(durationCtrl),
            if (includes.isNotEmpty) 'includes': includes,
          },
        'repairing' => {
            if (t(durationCtrl).isNotEmpty) 'durationLabel': t(durationCtrl),
            if (t(warrantyCtrl).isNotEmpty) 'warrantyLabel': t(warrantyCtrl),
          },
        'car_rental' => {
            if (int.tryParse(t(seatsCtrl)) != null) 'seats': int.parse(t(seatsCtrl)),
            if (transmissions[transmission] != null) 'transmission': transmissions[transmission],
            if (fuels[fuel] != null) 'fuel': fuels[fuel],
          },
        'elkstay' => {
            if (t(roomTypeCtrl).isNotEmpty) 'roomType': t(roomTypeCtrl),
            if (stayTypes[stayType] != null) 'stayType': stayTypes[stayType],
            if (int.tryParse(t(depositCtrl)) != null) 'depositAmount': int.parse(t(depositCtrl)),
            'furnished': furnished,
          },
        // Taxi and porter are still served by their own modules and take none.
        _ => const {},
      };
    }

    /// Validates, submits, and only then closes the sheet — a failure keeps
    /// everything the seller typed on screen.
    Future<void> submit(BuildContext ctx, AdStatus status) async {
      final title = titleCtrl.text.trim();
      final price = double.tryParse(priceCtrl.text.trim());
      if (selectedCat < 0 || title.isEmpty || price == null) {
        ScaffoldMessenger.of(ctx)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.fillRequiredFields)));
        return;
      }

      final slug = cats[selectedCat].$4;
      final ok = await cubit.create(
        title: title,
        categorySlug: slug,
        price: price,
        description: descCtrl.text.trim(),
        priceUnit: pricingUnits[pricingType],
        // The category's own emoji, so a listing without a photo shows
        // something recognisable rather than the column default.
        icon: cats[selectedCat].$2,
        status: status,
        imageKeys: imageKeys,
        attributes: attributesFor(slug),
      );
      if (!ctx.mounted) return;
      if (ok) {
        Navigator.pop(ctx);
        _toast(
          status == AdStatus.draft ? '📝' : '⏳',
          status == AdStatus.draft ? l10n.draftSaved : l10n.adSubmitted,
          status == AdStatus.draft ? '' : l10n.goesLiveIn24h,
          gold: true,
        );
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) => Container(
        height: MediaQuery.of(ctx).size.height * 0.95,
        decoration: const BoxDecoration(color: SellerColors.bg, borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
        child: Column(children: [
          const _SheetGrip(),
          _SheetHead(title: l10n.postNewAd, onClose: () => Navigator.pop(ctx)),
          Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(18, 0, 18, 0), children: [
            _FieldLabel(text: l10n.chooseCategory, required: true),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 11, crossAxisSpacing: 8, childAspectRatio: 0.95,
              children: List.generate(cats.length, (i) {
                final on = selectedCat == i;
                return GestureDetector(
                  onTap: () => setSt(() => selectedCat = i),
                  child: Column(children: [
                    Container(
                      width: double.infinity, height: 60,
                      decoration: BoxDecoration(color: cats[i].$3, borderRadius: BorderRadius.circular(18), border: on ? Border.all(color: SellerColors.teal500, width: 3) : null),
                      child: Center(child: Text(cats[i].$2, style: const TextStyle(fontSize: 27))),
                    ),
                    const SizedBox(height: 7),
                    Text(cats[i].$1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: SellerColors.ink2, height: 1.25)),
                  ]),
                );
              }),
            ),
            const SizedBox(height: 4),
            Text(l10n.pickServiceType, style: const TextStyle(fontSize: 11.5, color: SellerColors.muted)),
            const SizedBox(height: 16),
            _FieldLabel(text: l10n.listingTitle, required: true),
            const SizedBox(height: 8),
            _Input(hint: l10n.listingTitleHint, controller: titleCtrl),
            const SizedBox(height: 16),
            _FieldLabel(text: l10n.price, required: true),
            const SizedBox(height: 8),
            _Input(hint: '0.00', prefix: '₹', keyboardType: TextInputType.number, controller: priceCtrl),
            const SizedBox(height: 16),
            _FieldLabel(text: l10n.pricingType),
            const SizedBox(height: 8),
            _SelectBox(
              items: pricingUnits.keys.toList(),
              value: pricingType,
              onChanged: (v) => setSt(() => pricingType = v),
            ),
            const SizedBox(height: 16),
            _FieldLabel(text: l10n.description, required: true),
            const SizedBox(height: 8),
            _Input(hint: l10n.descriptionHint, maxLines: 4, controller: descCtrl),
            // Only the chosen category's extras appear — a cleaning ad has no
            // gearbox, and asking for one would be noise.
            ...switch (selectedCat < 0 ? '' : cats[selectedCat].$4) {
              'cleaning' => [
                  const SizedBox(height: 16),
                  const _FieldLabel(text: 'How long it takes'),
                  const SizedBox(height: 8),
                  _Input(hint: 'e.g. 2–3 hrs', controller: durationCtrl),
                  const SizedBox(height: 16),
                  const _FieldLabel(text: "What's included"),
                  const SizedBox(height: 8),
                  _Input(hint: 'Sofa, Carpet, Curtains', controller: includesCtrl),
                  const SizedBox(height: 4),
                  const Text('Separate each one with a comma',
                      style: TextStyle(fontSize: 11.5, color: SellerColors.muted)),
                ],
              'repairing' => [
                  const SizedBox(height: 16),
                  const _FieldLabel(text: 'How long it takes'),
                  const SizedBox(height: 8),
                  _Input(hint: 'e.g. 45–60 mins', controller: durationCtrl),
                  const SizedBox(height: 16),
                  const _FieldLabel(text: 'Warranty'),
                  const SizedBox(height: 8),
                  _Input(hint: 'e.g. 30 days on parts', controller: warrantyCtrl),
                ],
              'car_rental' => [
                  const SizedBox(height: 16),
                  const _FieldLabel(text: 'Seats'),
                  const SizedBox(height: 8),
                  _Input(hint: '5', keyboardType: TextInputType.number, controller: seatsCtrl),
                  const SizedBox(height: 16),
                  const _FieldLabel(text: 'Transmission'),
                  const SizedBox(height: 8),
                  _SelectBox(
                    items: transmissions.keys.toList(),
                    value: transmission,
                    onChanged: (v) => setSt(() => transmission = v),
                  ),
                  const SizedBox(height: 16),
                  const _FieldLabel(text: 'Fuel'),
                  const SizedBox(height: 8),
                  _SelectBox(
                    items: fuels.keys.toList(),
                    value: fuel,
                    onChanged: (v) => setSt(() => fuel = v),
                  ),
                ],
              'elkstay' => [
                  const SizedBox(height: 16),
                  const _FieldLabel(text: 'Room type'),
                  const SizedBox(height: 8),
                  _Input(hint: 'e.g. Single room', controller: roomTypeCtrl),
                  const SizedBox(height: 16),
                  const _FieldLabel(text: 'Property type'),
                  const SizedBox(height: 8),
                  _SelectBox(
                    items: stayTypes.keys.toList(),
                    value: stayType,
                    onChanged: (v) => setSt(() => stayType = v),
                  ),
                  const SizedBox(height: 16),
                  const _FieldLabel(text: 'Deposit'),
                  const SizedBox(height: 8),
                  _Input(
                    hint: '0',
                    prefix: '₹',
                    keyboardType: TextInputType.number,
                    controller: depositCtrl,
                  ),
                  const SizedBox(height: 4),
                  const Text('One-off, on top of the monthly rent above',
                      style: TextStyle(fontSize: 11.5, color: SellerColors.muted)),
                  const SizedBox(height: 16),
                  Row(children: [
                    const Expanded(child: _FieldLabel(text: 'Furnished')),
                    Switch(
                      value: furnished,
                      activeThumbColor: SellerColors.teal500,
                      onChanged: (v) => setSt(() => furnished = v),
                    ),
                  ]),
                ],
              _ => const <Widget>[],
            },
            const SizedBox(height: 16),
            _FieldLabel(text: l10n.photos),
            const SizedBox(height: 8),
            _PhotoRow(
              count: imageKeys.length,
              uploading: uploading,
              onAdd: () async {
                setSt(() => uploading = true);
                try {
                  final key = await _pickAndUploadPhoto();
                  if (key != null) imageKeys.add(key);
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text(friendlyErrorMessage(e))));
                  }
                }
                setSt(() => uploading = false);
              },
            ),
            const SizedBox(height: 16),
            _FieldLabel(text: l10n.serviceArea),
            const SizedBox(height: 8),
            _Input(initial: 'Bengaluru · Within 15 km'),
            const SizedBox(height: 24),
          ])),
          _SheetFoot(children: [
            Expanded(flex: 1, child: _SheetBtn(label: l10n.saveDraft, secondary: true, onTap: () => submit(ctx, AdStatus.draft))),
            const SizedBox(width: 11),
            Expanded(flex: 2, child: _SheetBtn(label: l10n.publishAd, onTap: () => submit(ctx, AdStatus.active))),
          ]),
        ]),
      )),
    );
  }

  /// Picks one photo and uploads it, returning its storage key. Null when the
  /// picker was dismissed.
  Future<String?> _pickAndUploadPhoto() async {
    // Resolved before the picker runs: the widget may be gone by the time the
    // user comes back from the gallery.
    final repository = context.read<MarketplaceRepository>();
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      // The backend downscales and re-encodes anyway; this just keeps the
      // upload itself small.
      maxWidth: 2000,
    );
    if (picked == null) return null;
    return repository.uploadImage(picked.path);
  }

  void _showBankSheet() {
    final nameCtrl = TextEditingController();
    final ibanCtrl = TextEditingController();
    String? ibanError;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(color: SellerColors.bg, borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const _SheetGrip(),
            _SheetHead(title: l10n.linkBankAccount, onClose: () => Navigator.pop(ctx)),
            Flexible(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(18, 0, 18, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(color: SellerColors.blue50, borderRadius: BorderRadius.circular(14)),
                child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('🔒', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 11),
                  Expanded(child: Text('Your details are encrypted. Payouts arrive 1–2 business days after a completed job.', style: TextStyle(fontSize: 12.5, color: Color(0xFF1D5A9E), fontWeight: FontWeight.w600))),
                ]),
              ),
              const SizedBox(height: 18),
              _FieldLabel(text: l10n.accountHolderName, required: true),
              const SizedBox(height: 8),
              TextField(controller: nameCtrl, decoration: _inputDeco(l10n.asPrintedOnAccount)),
              const SizedBox(height: 16),
              _FieldLabel(text: l10n.bankName, required: true),
              const SizedBox(height: 8),
              _SelectBox(items: const ['HDFC Bank', 'ICICI Bank', 'State Bank of India', 'Axis Bank', 'Kotak Mahindra Bank', 'Punjab National Bank']),
              const SizedBox(height: 16),
              _FieldLabel(text: l10n.accountNumber, required: true),
              const SizedBox(height: 8),
              TextField(
                controller: ibanCtrl,
                decoration: _inputDeco('e.g. 50100123456789').copyWith(
                  errorText: ibanError,
                  suffixIcon: ibanCtrl.text.isNotEmpty ? const Icon(Icons.credit_card, color: SellerColors.teal500) : null,
                ),
                onChanged: (v) => setSt(() { ibanError = null; }),
              ),
              const SizedBox(height: 6),
              const Text('9–18 digits, as printed on your passbook or cheque', style: TextStyle(fontSize: 11.5, color: SellerColors.muted)),
              const SizedBox(height: 24),
            ]))),
            _SheetFoot(children: [
              _SheetBtn(label: l10n.linkAccount, onTap: () {
                final account = ibanCtrl.text.replaceAll(' ', '');
                if (nameCtrl.text.trim().isEmpty) { setSt(() => ibanError = l10n.enterAccountHolderName); return; }
                // Indian account numbers are 9–18 digits; length varies by bank.
                if (!RegExp(r'^\d{9,18}$').hasMatch(account)) {
                  setSt(() => ibanError = l10n.enterValidAccountNumber);
                  return;
                }
                setState(() => _bankLinked = true);
                Navigator.pop(ctx);
                Future.delayed(const Duration(milliseconds: 250), () => _toast('🏦', l10n.bankLinked, l10n.canNowWithdraw));
              }),
            ]),
          ]),
        ),
      )),
    );
  }

  void _showWithdrawSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: SellerColors.bg, borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const _SheetGrip(),
          _SheetHead(title: l10n.withdrawEarnings, onClose: () => Navigator.pop(ctx)),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: SellerColors.card, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 22, offset: Offset(0, 6))]),
                child: Column(children: [
                  const Text('💰', style: TextStyle(fontSize: 30)),
                  const SizedBox(height: 8),
                  Text(l10n.availableToWithdraw, style: const TextStyle(fontSize: 13, color: SellerColors.muted, fontWeight: FontWeight.w700)),
                  Text('₹0', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: SellerColors.teal600, letterSpacing: -0.5)),
                ]),
              ),
              const SizedBox(height: 16),
              _FieldLabel(text: l10n.amount),
              const SizedBox(height: 8),
              _Input(hint: '0', prefix: '₹', keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              if (!_bankLinked)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: SellerColors.card, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 10, offset: Offset(0, 4))]),
                  child: Row(children: [
                    Container(width: 48, height: 48, decoration: BoxDecoration(color: SellerColors.amber50, borderRadius: BorderRadius.circular(13)), child: const Center(child: Text('🏦', style: TextStyle(fontSize: 23)))),
                    const SizedBox(width: 13),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l10n.noBankLinkedYet, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: SellerColors.ink)),
                      Text(l10n.addPayoutFirst, style: const TextStyle(fontSize: 12.5, color: SellerColors.muted)),
                    ])),
                    GestureDetector(
                      onTap: () { Navigator.pop(ctx); Future.delayed(const Duration(milliseconds: 250), () => _showBankSheet()); },
                      child: const Text('Add →', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: SellerColors.teal500)),
                    ),
                  ]),
                ),
              const SizedBox(height: 24),
            ]),
          ),
          _SheetFoot(children: [
            _SheetBtn(label: l10n.confirmWithdrawal, onTap: () {
              Navigator.pop(ctx);
              Future.delayed(const Duration(milliseconds: 250), () => _toast('💸', l10n.withdrawalRequested, l10n.fundsArriveIn));
            }),
          ]),
        ]),
      ),
    );
  }

  void _showNotifSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(color: SellerColors.bg, borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
          child: Column(children: [
            const _SheetGrip(),
            _SheetHead(title: l10n.profileNotifications, onClose: () => Navigator.pop(ctx)),
            Expanded(
              // The seller's notifications are the same per-user feed the app
              // already has — order events raised by the backend land here, so
              // there is no separate seller feed to build.
              child: FutureBuilder<List<NotificationModel>>(
                future: context.read<NotificationsRepository>().getNotifications(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: SellerColors.teal600),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          friendlyErrorMessage(snapshot.error!),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: SellerColors.muted),
                        ),
                      ),
                    );
                  }
                  final items = snapshot.data ?? const <NotificationModel>[];
                  if (items.isEmpty) {
                    return Center(
                      child: Text(l10n.noNotificationsYet,
                          style: const TextStyle(fontSize: 13, color: SellerColors.muted)),
                    );
                  }
                  return ListView.builder(
                    controller: ctrl,
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final n = items[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 11),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: SellerColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: n.isUnread
                              ? const Border(left: BorderSide(color: SellerColors.teal500, width: 4))
                              : null,
                          boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 22, offset: Offset(0, 6))],
                        ),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(color: Color(n.colorHex), borderRadius: BorderRadius.circular(13)),
                            child: Center(child: Text(n.icon, style: const TextStyle(fontSize: 21))),
                          ),
                          const SizedBox(width: 13),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(n.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: SellerColors.ink)),
                            const SizedBox(height: 2),
                            Text(n.message, style: const TextStyle(fontSize: 12.5, color: SellerColors.ink2, height: 1.4)),
                            const SizedBox(height: 5),
                            Text(n.time, style: const TextStyle(fontSize: 11, color: SellerColors.muted2, fontWeight: FontWeight.w600)),
                          ])),
                        ]),
                      );
                    },
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _showOrderSheet(AdOrderModel order) {
    final cubit = context.read<SellerOrdersCubit>();
    final (badgeLabel, badgeColor, badgeBg) = switch (order.status) {
      AdOrderStatus.newOrder => (l10n.newRequest, SellerColors.amber, SellerColors.amber50),
      AdOrderStatus.inProgress => (l10n.inProgress, SellerColors.blue, SellerColors.blue50),
      AdOrderStatus.completed => (l10n.statusCompleted, SellerColors.green, SellerColors.green50),
      AdOrderStatus.cancelled => (l10n.statusCancelled, SellerColors.red, SellerColors.red50),
    };

    Future<void> move(BuildContext ctx, AdOrderStatus next) async {
      Navigator.pop(ctx);
      await cubit.setStatus(order.id, next);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: SellerColors.bg, borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const _SheetGrip(),
          _SheetHead(title: l10n.bookingRequest, onClose: () => Navigator.pop(ctx)),
          Flexible(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(18, 0, 18, 0), child: Column(children: [
            Container(
              padding: const EdgeInsets.all(18),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(color: SellerColors.card, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 22, offset: Offset(0, 6))]),
              child: Column(children: [
                Container(width: 62, height: 62, decoration: BoxDecoration(color: SellerColors.bg, borderRadius: BorderRadius.circular(20)), child: Center(child: Text(order.icon, style: const TextStyle(fontSize: 30)))),
                const SizedBox(height: 11),
                Text(order.serviceName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: SellerColors.ink)),
                Text(order.amountLabel, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: SellerColors.teal600, letterSpacing: -0.5)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(20)),
                  child: Text(badgeLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: badgeColor)),
                ),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: SellerColors.card, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 22, offset: Offset(0, 6))]),
              child: Column(children: [
                _OdRow(icon: '🎫', label: l10n.orderId, value: order.code),
                _OdRow(icon: '👤', label: l10n.customer, value: order.customerName),
                if (order.customerPhone.isNotEmpty)
                  _OdRow(icon: '📞', label: l10n.contactLabel, value: order.customerPhone),
                _OdRow(icon: '📅', label: l10n.stepSchedule, value: order.whenLabel),
                if (order.addressText.isNotEmpty)
                  _OdRow(icon: '📍', label: l10n.stepLocation, value: order.addressText),
                if (order.note != null && order.note!.isNotEmpty)
                  _OdRow(icon: '📝', label: l10n.description, value: order.note!),
                // The seller's cut. Deliberately not a payout figure — nothing
                // moves money yet, so this is the fee arithmetic only.
                _OdRow(
                  icon: '💵',
                  label: l10n.youEarnAfterFee,
                  value: '₹${(order.amount * 0.88).toStringAsFixed(0)}',
                  valueColor: SellerColors.green,
                  isLast: true,
                ),
              ]),
            ),
            const SizedBox(height: 24),
          ]))),
          // The actions mirror the backend's transition table: a new order can
          // be accepted or declined, one in progress can be completed, and a
          // finished one offers nothing.
          if (order.status == AdOrderStatus.newOrder)
            _SheetFoot(children: [
              Expanded(
                flex: 1,
                child: _SheetBtn(
                  label: l10n.decline,
                  danger: true,
                  onTap: () => move(ctx, AdOrderStatus.cancelled),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                flex: 2,
                child: _SheetBtn(
                  label: l10n.acceptJob,
                  onTap: () => move(ctx, AdOrderStatus.inProgress),
                ),
              ),
            ])
          else if (order.status == AdOrderStatus.inProgress)
            _SheetFoot(children: [
              Expanded(
                child: _SheetBtn(
                  label: l10n.markCompleted,
                  onTap: () => move(ctx, AdOrderStatus.completed),
                ),
              ),
            ])
          else
            const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

// ─── Private helper widgets ───────────────────────────────────────────────────

class _OnlineSwitch extends StatelessWidget {
  const _OnlineSwitch({required this.value});
  final bool value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 52, height: 30,
      decoration: BoxDecoration(
        color: value ? const Color(0xFF3DDB96) : Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          top: 3, left: value ? 25 : 3,
          child: Container(width: 24, height: 24, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 5, offset: const Offset(0, 2))])),
        ),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.bg, required this.label, required this.value, required this.delta, this.positive});
  final String icon, label, value, delta;
  final Color bg;
  final bool? positive;

  @override
  Widget build(BuildContext context) {
    final deltaColor = positive == true ? SellerColors.green : positive == false ? SellerColors.red : SellerColors.blue;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: SellerColors.card, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 22, offset: Offset(0, 6))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11)), child: Center(child: Text(icon, style: const TextStyle(fontSize: 19)))),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 12, color: SellerColors.muted, fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: SellerColors.ink)),
        const SizedBox(height: 5),
        Text(delta, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: deltaColor)),
      ]),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order, required this.isLast, required this.onTap});
  final AdOrderModel order;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, fg, bg) = switch (order.status) {
      AdOrderStatus.newOrder => (l10n.homeBadgeNew, SellerColors.amber, SellerColors.amber50),
      AdOrderStatus.inProgress => (l10n.inProgress, SellerColors.blue, SellerColors.blue50),
      AdOrderStatus.completed => (l10n.done, SellerColors.green, SellerColors.green50),
      AdOrderStatus.cancelled => (l10n.statusCancelled, SellerColors.red, SellerColors.red50),
    };
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: SellerColors.line))),
        child: Row(children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: SellerColors.bg, borderRadius: BorderRadius.circular(14)), child: Center(child: Text(order.icon, style: const TextStyle(fontSize: 23)))),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(order.serviceName, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: SellerColors.ink)),
            const SizedBox(height: 2),
            Row(children: [
              const Text('👤 ', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Text(
                  '${order.customerName} · ${order.whenLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: SellerColors.muted),
                ),
              ),
            ]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(order.amountLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: SellerColors.ink)),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
              child: Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: fg)),
            ),
          ]),
        ]),
      ),
    );
  }
}

/// A real listing from `GET /marketplace/my-ads`, with the two actions the
/// seller can take on it.
class _AdCard extends StatelessWidget {
  const _AdCard({
    required this.ad,
    required this.onTogglePause,
    required this.onDelete,
  });

  final AdModel ad;
  final VoidCallback onTogglePause;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, fg) = switch (ad.status) {
      AdStatus.active => (l10n.tabActive, SellerColors.green),
      AdStatus.draft => (l10n.inReview, SellerColors.amber),
      AdStatus.paused => (l10n.paused, SellerColors.muted),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(color: SellerColors.card, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 22, offset: Offset(0, 6))]),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 118,
          color: SellerColors.bg,
          child: Stack(children: [
            // The first uploaded photo, or the emoji the ad carries until one
            // exists — the backend sends the emoji precisely for this.
            Positioned.fill(
              child: ad.imageUrls.isEmpty
                  ? Center(child: Text(ad.icon, style: const TextStyle(fontSize: 48)))
                  : Image.network(
                      ad.imageUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          Center(child: Text(ad.icon, style: const TextStyle(fontSize: 48))),
                    ),
            ),
            Positioned(
              top: 11, left: 11,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(20)),
                child: Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: fg)),
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 13, 15, 15),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ad.categorySlug.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: SellerColors.teal500, letterSpacing: 0.5)),
            const SizedBox(height: 3),
            Text(ad.title, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: SellerColors.ink, letterSpacing: -0.2)),
            const SizedBox(height: 2),
            Text(ad.priceLabel, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: SellerColors.ink)),
            const Divider(color: SellerColors.line, height: 22),
            Row(children: [
              const Text('👁 ', style: TextStyle(fontSize: 12)),
              Text('${ad.viewCount}', style: const TextStyle(fontSize: 12, color: SellerColors.muted, fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
              const Text('❤ ', style: TextStyle(fontSize: 12)),
              Text('${ad.wishlistCount}', style: const TextStyle(fontSize: 12, color: SellerColors.muted, fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton(
                onPressed: onTogglePause,
                child: Text(
                  ad.status == AdStatus.paused ? l10n.resumeListing : l10n.pauseListing,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: SellerColors.teal500),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 19, color: SellerColors.muted),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _TxnRow extends StatelessWidget {
  const _TxnRow({required this.txn, required this.isLast});
  final SellerTransaction txn;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: SellerColors.line))),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: txn.isCredit ? SellerColors.green50 : SellerColors.red50, borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(txn.isCredit ? '↑' : '↓', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: txn.isCredit ? SellerColors.green : SellerColors.red))),
        ),
        const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(txn.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: SellerColors.ink)),
          Text(txn.date, style: const TextStyle(fontSize: 11.5, color: SellerColors.muted)),
        ])),
        Text(
          '${txn.isCredit ? '+' : '-'}₹${txn.amount}',
          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: txn.isCredit ? SellerColors.green : SellerColors.ink2),
        ),
      ]),
    );
  }
}

class _OdRow extends StatelessWidget {
  const _OdRow({required this.icon, required this.label, required this.value, this.valueColor, this.isLast = false});
  final String icon, label, value;
  final Color? valueColor;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: isLast ? null : const BoxDecoration(border: Border(bottom: BorderSide(color: SellerColors.line))),
      child: Row(children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: SellerColors.bg, borderRadius: BorderRadius.circular(11)), child: Center(child: Text(icon, style: const TextStyle(fontSize: 17)))),
        const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 11.5, color: SellerColors.muted, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
          Text(value, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: valueColor ?? SellerColors.ink)),
        ])),
      ]),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: SellerColors.muted));
}

class _SheetGrip extends StatelessWidget {
  const _SheetGrip();
  @override
  Widget build(BuildContext context) => Container(width: 42, height: 5, margin: const EdgeInsets.only(top: 10), decoration: BoxDecoration(color: const Color(0xFFCFD6DC), borderRadius: BorderRadius.circular(5)));
}

class _SheetHead extends StatelessWidget {
  const _SheetHead({required this.title, required this.onClose});
  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
    child: Row(children: [
      Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3, color: SellerColors.ink))),
      GestureDetector(onTap: onClose, child: Container(width: 34, height: 34, decoration: BoxDecoration(color: const Color(0xFFE3E8EC), borderRadius: BorderRadius.circular(17)), child: const Icon(Icons.close, size: 17, color: SellerColors.ink2))),
    ]),
  );
}

class _SheetFoot extends StatelessWidget {
  const _SheetFoot({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(18, 14, 18, MediaQuery.of(context).padding.bottom + 16),
    decoration: const BoxDecoration(color: SellerColors.card, border: Border(top: BorderSide(color: SellerColors.line))),
    child: Row(children: children),
  );
}

class _SheetBtn extends StatelessWidget {
  const _SheetBtn({required this.label, required this.onTap, this.secondary = false, this.danger = false});
  final String label;
  final VoidCallback onTap;
  final bool secondary, danger;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: danger ? SellerColors.red50 : secondary ? const Color(0xFFE3E8EC) : null,
        gradient: (!danger && !secondary) ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [SellerColors.teal600, SellerColors.teal500]) : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: (!danger && !secondary) ? const [BoxShadow(color: Color(0x3D1E6B5E), blurRadius: 20, offset: Offset(0, 8))] : null,
      ),
      child: Center(child: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: danger ? SellerColors.red : secondary ? SellerColors.ink2 : Colors.white))),
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, this.required = false});
  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(text: text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: SellerColors.ink2),
      children: required ? const [TextSpan(text: ' *', style: TextStyle(color: SellerColors.red))] : null,
    ),
  );
}

InputDecoration _inputDeco(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: SellerColors.muted, fontSize: 15),
  filled: true, fillColor: SellerColors.card,
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: SellerColors.line, width: 1.5)),
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: SellerColors.line, width: 1.5)),
  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: SellerColors.teal500, width: 1.5)),
  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
);

class _Input extends StatelessWidget {
  const _Input({
    this.hint = '',
    this.initial,
    this.prefix,
    this.keyboardType,
    this.maxLines = 1,
    this.controller,
  });
  final String hint;
  final String? initial, prefix;
  final TextInputType? keyboardType;
  final int maxLines;

  /// Supplied for the fields the sheet actually submits. Without one the
  /// TextField is display-only, which is all the rest of them need.
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:
          controller ?? (initial != null ? TextEditingController(text: initial) : null),
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: _inputDeco(hint).copyWith(
        prefixText: prefix != null ? '$prefix  ' : null,
        prefixStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: SellerColors.muted),
      ),
    );
  }
}

class _SelectBox extends StatelessWidget {
  const _SelectBox({required this.items, this.value, this.onChanged});
  final List<String> items;
  final String? value;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
    decoration: BoxDecoration(color: SellerColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: SellerColors.line, width: 1.5)),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value ?? items.first,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: SellerColors.muted),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 15, color: SellerColors.ink)))).toList(),
        onChanged: (v) {
          if (v != null) onChanged?.call(v);
        },
      ),
    ),
  );
}

/// Photo picker row for the post-ad sheet. Each tap uploads immediately via
/// `POST /uploads/image`; the returned keys travel with the listing when it is
/// saved, which is the only way the backend can attach them.
class _PhotoRow extends StatelessWidget {
  const _PhotoRow({required this.count, required this.uploading, required this.onAdd});

  final int count;
  final bool uploading;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(children: [
      GestureDetector(
        onTap: uploading ? null : onAdd,
        child: Container(
          width: 84,
          height: 72,
          decoration: BoxDecoration(
            color: SellerColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: SellerColors.line, width: 1.5),
          ),
          child: Center(
            child: uploading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: SellerColors.teal600),
                  )
                : const Icon(Icons.add_a_photo_outlined, color: SellerColors.muted, size: 22),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Text(
        count == 0 ? l10n.addPhoto : l10n.photosAdded(count),
        style: const TextStyle(fontSize: 12.5, color: SellerColors.muted, fontWeight: FontWeight.w600),
      ),
    ]);
  }
}
