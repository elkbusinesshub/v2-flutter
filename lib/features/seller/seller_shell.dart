import 'package:flutter/material.dart';

import '../../core/theme/seller_colors.dart';
import '../../data/datasources/seller_data.dart';
import '../account_switcher/account_switcher_sheet.dart';

enum _Tab { home, listings, orders, wallet }

class SellerShell extends StatefulWidget {
  const SellerShell({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  State<SellerShell> createState() => _SellerShellState();
}

class _SellerShellState extends State<SellerShell> {
  _Tab _tab = _Tab.home;
  bool _isOnline = true;
  bool _bankLinked = false;
  String _orderFilter = 'new';
  String _listingFilter = 'all';

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
    final titles = {_Tab.listings: 'My Listings', _Tab.orders: 'Orders', _Tab.wallet: 'Wallet'};
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
          const Text('Partner dashboard', style: TextStyle(fontSize: 13, color: Color(0xFFBFE3DA), fontWeight: FontWeight.w500)),
          const SizedBox(height: 1),
          Row(children: [
            const Text('Bright Spark Services', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
            const SizedBox(width: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(20)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.verified, size: 12, color: Color(0xFFD6FFE9)),
                SizedBox(width: 4),
                Text('Verified', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFD6FFE9), letterSpacing: 0.2)),
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
          setState(() => _isOnline = !_isOnline);
          _toast(
            _isOnline ? '🟢' : '⚪',
            _isOnline ? 'You are online' : 'You are offline',
            _isOnline ? 'Customers can book you now' : 'You won\'t get new requests',
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
              Text(_isOnline ? 'You\'re online' : 'You\'re offline', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
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
            _navItem(_Tab.home, Icons.home_outlined, Icons.home_rounded, 'Home'),
            _navItem(_Tab.listings, Icons.grid_view_outlined, Icons.grid_view_rounded, 'Listings'),
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
                  child: const Text('Post', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: SellerColors.teal500)),
                ),
              ]),
            ),
            _navItem(_Tab.orders, Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, 'Orders'),
            _navItem(_Tab.wallet, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, 'Wallet'),
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
    final newOrders = sellerOrders.where((o) => o.status == 'new' || o.status == 'progress').take(3).toList();
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
                  child: const Center(child: Text('🏦', style: TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 13),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Link your bank to get paid', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFF7A5E00))),
                  const Text('Add your IBAN so we can transfer your earnings', style: TextStyle(fontSize: 12.5, color: Color(0xFF9A7D28))),
                  const SizedBox(height: 6),
                  Row(children: const [
                    Text('Add bank account', style: TextStyle(color: Color(0xFFCAA20D), fontWeight: FontWeight.w800, fontSize: 13)),
                    SizedBox(width: 3),
                    Icon(Icons.arrow_forward, size: 13, color: Color(0xFFCAA20D)),
                  ]),
                ])),
              ]),
            ),
          ),
          const SizedBox(height: 22),
        ],
        _SectionTitle(text: 'Quick actions'),
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
                  const Text('Post a new ad', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                  const Text('List a service or item', style: TextStyle(fontSize: 11.5, color: Color(0xFFBFE7DD))),
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
                  const Text('View orders', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: SellerColors.ink)),
                  const Text('6 need attention', style: TextStyle(fontSize: 11.5, color: SellerColors.muted)),
                ]),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 22),
        _SectionTitle(text: 'Today at a glance'),
        // const SizedBox(height: 12),
        // 2×2 stats
        GridView.count(
          crossAxisCount: 2, mainAxisSpacing: 20, crossAxisSpacing: 20,
          childAspectRatio: 1.55, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          children: const [
            _StatCard(icon: '💰', bg: SellerColors.tMint, label: 'Today\'s earnings', value: 'AED 840', delta: '▲ 18% vs yesterday', positive: true),
            _StatCard(icon: '🔥', bg: SellerColors.tYellow, label: 'New requests', value: '6', delta: '3 awaiting reply', positive: true),
            _StatCard(icon: '📋', bg: SellerColors.tPurple, label: 'Active jobs', value: '4', delta: '2 in progress', positive: null),
            _StatCard(icon: '⭐', bg: SellerColors.tPink, label: 'Rating', value: '4.9', delta: 'From 312 reviews', positive: true),
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
        //         Text('AED 5,420', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: -0.6, color: SellerColors.ink)),
        //         Text('Earnings this week', style: TextStyle(fontSize: 12, color: SellerColors.muted, fontWeight: FontWeight.w600)),
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
          _SectionTitle(text: 'Recent bookings'),
          GestureDetector(onTap: () => _go(_Tab.orders), child: const Text('See all', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: SellerColors.teal500))),
        ]),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: SellerColors.card, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 22, offset: Offset(0, 6))]),
          child: Column(
            children: newOrders.asMap().entries.map((e) => _OrderRow(order: e.value, isLast: e.key == newOrders.length - 1, onTap: () => _showOrderSheet(e.value))).toList(),
          ),
        ),
      ],
    );
  }

  // ─── Listings ────────────────────────────────────────────────────────────

  Widget _listingsScreen() {
    final filters = [('all', 'All', 5), ('active', 'Active', 3), ('pending', 'In review', 1), ('paused', 'Paused', 1)];
    final filtered = sellerListings.where((l) => _listingFilter == 'all' || l.status == _listingFilter).toList();
    return Column(children: [
      // chips
      SizedBox(
        height: 48,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
          children: filters.map((f) {
            final on = _listingFilter == f.$1;
            return GestureDetector(
              onTap: () => setState(() => _listingFilter = f.$1),
              child: Container(
                margin: const EdgeInsets.only(right: 9),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: on ? SellerColors.teal600 : SellerColors.card,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 6, offset: Offset(0, 2))],
                ),
                child: Text('${f.$2} ${f.$3}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: on ? Colors.white : SellerColors.ink2)),
              ),
            );
          }).toList(),
        ),
      ),
      Expanded(
        child: filtered.isEmpty
            ? const Center(child: Text('Nothing here yet', style: TextStyle(color: SellerColors.muted, fontSize: 15)))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: filtered.length,
                itemBuilder: (context, i) => _ListingCard(listing: filtered[i]),
              ),
      ),
    ]);
  }

  // ─── Orders ──────────────────────────────────────────────────────────────

  Widget _ordersScreen() {
    final filters = [('new', 'New', 3), ('progress', 'In progress', 2), ('completed', 'Completed', 4), ('cancelled', 'Cancelled', 0)];
    final filtered = sellerOrders.where((o) => o.status == _orderFilter).toList();
    return Column(children: [
      SizedBox(
        height: 48,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
          children: filters.map((f) {
            final on = _orderFilter == f.$1;
            return GestureDetector(
              onTap: () => setState(() => _orderFilter = f.$1),
              child: Container(
                margin: const EdgeInsets.only(right: 9),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: on ? SellerColors.teal600 : SellerColors.card,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 6, offset: Offset(0, 2))],
                ),
                child: Text(f.$3 > 0 ? '${f.$2} ${f.$3}' : f.$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: on ? Colors.white : SellerColors.ink2)),
              ),
            );
          }).toList(),
        ),
      ),
      Expanded(
        child: filtered.isEmpty
            ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('📭', style: TextStyle(fontSize: 46)),
                SizedBox(height: 12),
                Text('All clear', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: SellerColors.ink2)),
                Text('No orders here right now', style: TextStyle(fontSize: 13, color: SellerColors.muted)),
              ]))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: filtered.length,
                itemBuilder: (context, i) => Container(
                  decoration: BoxDecoration(color: SellerColors.card, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 22, offset: Offset(0, 6))]),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: _OrderRow(order: filtered[i], isLast: true, onTap: () => _showOrderSheet(filtered[i])),
                ),
              ),
      ),
    ]);
  }

  // ─── Wallet ──────────────────────────────────────────────────────────────

  Widget _walletScreen() {
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
            const Row(children: [
              Text('💰', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text('Available balance', style: TextStyle(fontSize: 13, color: Color(0xFFBFE7DD), fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 5),
            const Text('AED 3,280', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1)),
            const Text('AED 640 pending · clears in 2 days', style: TextStyle(fontSize: 12.5, color: Color(0xFFBFE7DD))),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showWithdrawSheet(),
                  child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('↑ ', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: SellerColors.teal700)), Text('Withdraw', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: SellerColors.teal700))]),
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(14)),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('📄 ', style: TextStyle(fontSize: 13.5)), Text('Statement', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white))]),
                ),
              ),
            ]),
          ]),
        ),
        const SizedBox(height: 22),
        _SectionTitle(text: 'Payout method'),
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
                Text(_bankLinked ? 'Emirates NBD' : 'No bank linked', style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: SellerColors.ink)),
                Text(_bankLinked ? 'IBAN ••••4821 · Verified' : 'Add your IBAN to withdraw earnings', style: const TextStyle(fontSize: 12.5, color: SellerColors.muted)),
              ])),
              Text(_bankLinked ? '✓' : '+ Add', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _bankLinked ? SellerColors.green : SellerColors.teal500)),
            ]),
          ),
        ),
        const SizedBox(height: 22),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _SectionTitle(text: 'Recent transactions'),
          const Text('Export', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: SellerColors.teal500)),
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
    final cats = [('Taxi / Ride', '🚕', SellerColors.tBlue), ('Cleaning', '🧹', SellerColors.tYellow), ('Car Rental', '🚗', SellerColors.tPurple), ('Repair', '🔧', SellerColors.tPink), ('Porter', '📦', SellerColors.tGreen), ('ELK Stay', '🏨', SellerColors.tMint)];
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
          _SheetHead(title: 'Post a new ad', onClose: () => Navigator.pop(ctx)),
          Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(18, 0, 18, 0), children: [
            _FieldLabel(text: 'Choose a category', required: true),
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
            const Text('Pick the service or item type you\'re listing', style: TextStyle(fontSize: 11.5, color: SellerColors.muted)),
            const SizedBox(height: 16),
            _FieldLabel(text: 'Listing title', required: true),
            const SizedBox(height: 8),
            _Input(hint: 'e.g. Deep home cleaning (3BHK)'),
            const SizedBox(height: 16),
            _FieldLabel(text: 'Price', required: true),
            const SizedBox(height: 8),
            _Input(hint: '0.00', prefix: 'AED', keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _FieldLabel(text: 'Pricing type'),
            const SizedBox(height: 8),
            _SelectBox(items: const ['Fixed price', 'Per hour', 'Per day', 'Starting from']),
            const SizedBox(height: 16),
            _FieldLabel(text: 'Description', required: true),
            const SizedBox(height: 8),
            _Input(hint: 'Describe what\'s included, your experience, service area…', maxLines: 4),
            const SizedBox(height: 16),
            _FieldLabel(text: 'Service area'),
            const SizedBox(height: 8),
            _Input(initial: 'Dubai · Within 15 km'),
            const SizedBox(height: 16),
            _FieldLabel(text: 'Availability'),
            const SizedBox(height: 8),
            _SelectBox(items: const ['Available now', 'By appointment', 'Weekdays only']),
            const SizedBox(height: 24),
          ])),
          _SheetFoot(children: [
            Expanded(flex: 1, child: _SheetBtn(label: 'Save draft', secondary: true, onTap: () => Navigator.pop(ctx))),
            const SizedBox(width: 11),
            Expanded(flex: 2, child: _SheetBtn(label: 'Publish ad', onTap: () {
              Navigator.pop(ctx);
              Future.delayed(const Duration(milliseconds: 250), () => _toast('⏳', 'Ad submitted for review', 'Goes live within 24 hours', gold: true));
            })),
          ]),
        ]),
      )),
    );
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
            _SheetHead(title: 'Link bank account', onClose: () => Navigator.pop(ctx)),
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
              _FieldLabel(text: 'Account holder name', required: true),
              const SizedBox(height: 8),
              TextField(controller: nameCtrl, decoration: _inputDeco('As printed on your bank account')),
              const SizedBox(height: 16),
              _FieldLabel(text: 'Bank name', required: true),
              const SizedBox(height: 8),
              _SelectBox(items: const ['Emirates NBD', 'FAB', 'ADCB', 'Mashreq', 'RAKBANK', 'Dubai Islamic Bank']),
              const SizedBox(height: 16),
              _FieldLabel(text: 'IBAN', required: true),
              const SizedBox(height: 8),
              TextField(
                controller: ibanCtrl,
                decoration: _inputDeco('AE00 0000 0000 0000 0000 000').copyWith(
                  errorText: ibanError,
                  suffixIcon: ibanCtrl.text.isNotEmpty ? const Icon(Icons.credit_card, color: SellerColors.teal500) : null,
                ),
                onChanged: (v) => setSt(() { ibanError = null; }),
              ),
              const SizedBox(height: 6),
              const Text('UAE IBAN starts with AE and has 23 characters', style: TextStyle(fontSize: 11.5, color: SellerColors.muted)),
              const SizedBox(height: 24),
            ]))),
            _SheetFoot(children: [
              _SheetBtn(label: 'Link account', onTap: () {
                final iban = ibanCtrl.text.replaceAll(' ', '');
                if (nameCtrl.text.trim().isEmpty) { setSt(() => ibanError = 'Enter account holder name'); return; }
                if (!RegExp(r'^AE\d{21}$', caseSensitive: false).hasMatch(iban)) {
                  setSt(() => ibanError = 'Enter a valid 23-character UAE IBAN starting with AE');
                  return;
                }
                setState(() => _bankLinked = true);
                Navigator.pop(ctx);
                Future.delayed(const Duration(milliseconds: 250), () => _toast('🏦', 'Bank linked', 'You can now withdraw your earnings'));
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
          _SheetHead(title: 'Withdraw earnings', onClose: () => Navigator.pop(ctx)),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: SellerColors.card, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 22, offset: Offset(0, 6))]),
                child: const Column(children: [
                  Text('💰', style: TextStyle(fontSize: 30)),
                  SizedBox(height: 8),
                  Text('Available to withdraw', style: TextStyle(fontSize: 13, color: SellerColors.muted, fontWeight: FontWeight.w700)),
                  Text('AED 3,280', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: SellerColors.teal600, letterSpacing: -0.5)),
                ]),
              ),
              const SizedBox(height: 16),
              _FieldLabel(text: 'Amount'),
              const SizedBox(height: 8),
              _Input(initial: '3280', prefix: 'AED', keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              if (!_bankLinked)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: SellerColors.card, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 10, offset: Offset(0, 4))]),
                  child: Row(children: [
                    Container(width: 48, height: 48, decoration: BoxDecoration(color: SellerColors.amber50, borderRadius: BorderRadius.circular(13)), child: const Center(child: Text('🏦', style: TextStyle(fontSize: 23)))),
                    const SizedBox(width: 13),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('No bank linked yet', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: SellerColors.ink)),
                      Text('Add a payout method first', style: TextStyle(fontSize: 12.5, color: SellerColors.muted)),
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
            _SheetBtn(label: 'Confirm withdrawal', onTap: () {
              Navigator.pop(ctx);
              Future.delayed(const Duration(milliseconds: 250), () => _toast('💸', 'Withdrawal requested', 'Funds arrive in 1–2 business days'));
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
            _SheetHead(title: 'Notifications', onClose: () => Navigator.pop(ctx)),
            Expanded(
              child: ListView.builder(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                itemCount: sellerNotifs.length,
                itemBuilder: (_, i) {
                  final n = sellerNotifs[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 11),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: SellerColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: n.unread ? const Border(left: BorderSide(color: SellerColors.teal500, width: 4)) : null,
                      boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 22, offset: Offset(0, 6))],
                    ),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(width: 44, height: 44, decoration: BoxDecoration(color: n.tileBg, borderRadius: BorderRadius.circular(13)), child: Center(child: Text(n.icon, style: const TextStyle(fontSize: 21)))),
                      const SizedBox(width: 13),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(n.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: SellerColors.ink)),
                        const SizedBox(height: 2),
                        Text(n.body, style: const TextStyle(fontSize: 12.5, color: SellerColors.ink2, height: 1.4)),
                        const SizedBox(height: 5),
                        Text(n.time, style: const TextStyle(fontSize: 11, color: SellerColors.muted2, fontWeight: FontWeight.w600)),
                        if (n.hasAction) ...[
                          const SizedBox(height: 11),
                          Row(children: [
                            Expanded(child: GestureDetector(
                              onTap: () { Navigator.pop(ctx); _toast('✗', 'Declined', 'Customer notified'); },
                              child: Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: SellerColors.red50, borderRadius: BorderRadius.circular(11)), child: const Center(child: Text('Decline', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: SellerColors.red)))),
                            )),
                            const SizedBox(width: 8),
                            Expanded(child: GestureDetector(
                              onTap: () { Navigator.pop(ctx); _toast('✓', 'Accepted', 'Added to active jobs'); },
                              child: Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: SellerColors.teal600, borderRadius: BorderRadius.circular(11)), child: const Center(child: Text('Accept', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)))),
                            )),
                          ]),
                        ],
                      ])),
                    ]),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _showOrderSheet(SellerOrder order) {
    final isNew = order.status == 'new';
    final badgeColor = {'new': SellerColors.amber, 'progress': SellerColors.blue, 'completed': SellerColors.green}[order.status] ?? SellerColors.muted;
    final badgeBg = {'new': SellerColors.amber50, 'progress': SellerColors.blue50, 'completed': SellerColors.green50}[order.status] ?? SellerColors.bg;
    final badgeLabel = {'new': 'New request', 'progress': 'In progress', 'completed': 'Completed'}[order.status] ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: SellerColors.bg, borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const _SheetGrip(),
          _SheetHead(title: 'Booking request', onClose: () => Navigator.pop(ctx)),
          Flexible(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(18, 0, 18, 0), child: Column(children: [
            // Hero
            Container(
              padding: const EdgeInsets.all(18),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(color: SellerColors.card, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 22, offset: Offset(0, 6))]),
              child: Column(children: [
                Container(width: 62, height: 62, decoration: BoxDecoration(color: order.tileBg, borderRadius: BorderRadius.circular(20)), child: Center(child: Text(order.emoji, style: const TextStyle(fontSize: 30)))),
                const SizedBox(height: 11),
                Text(order.service, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: SellerColors.ink)),
                Text(order.amount, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: SellerColors.teal600, letterSpacing: -0.5)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(20)),
                  child: Text(badgeLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: badgeColor)),
                ),
              ]),
            ),
            // Details
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: SellerColors.card, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 22, offset: Offset(0, 6))]),
              child: Column(children: [
                _OdRow(icon: '🎫', label: 'Order ID', value: order.id),
                _OdRow(icon: '👤', label: 'Customer', value: order.customerName),
                if (order.phone.isNotEmpty) _OdRow(icon: '📞', label: 'Contact', value: order.phone),
                _OdRow(icon: '📅', label: 'Schedule', value: order.when),
                if (order.address.isNotEmpty) _OdRow(icon: '📍', label: 'Location', value: order.address),
                _OdRow(icon: '💵', label: 'You earn (after 12% fee)', value: 'AED ${(double.tryParse(order.amount.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0 * 0.88).toStringAsFixed(0)}', valueColor: SellerColors.green, isLast: true),
              ]),
            ),
            const SizedBox(height: 24),
          ]))),
          if (isNew) _SheetFoot(children: [
            Expanded(flex: 1, child: _SheetBtn(label: 'Decline', danger: true, onTap: () { Navigator.pop(ctx); _toast('✗', 'Declined', 'The customer has been notified'); })),
            const SizedBox(width: 11),
            Expanded(flex: 2, child: _SheetBtn(label: 'Accept job', onTap: () { Navigator.pop(ctx); _toast('✓', 'Booking accepted', 'Added to your active jobs'); })),
          ]),
          if (!isNew) const SizedBox(height: 24),
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
  final SellerOrder order;
  final bool isLast;
  final VoidCallback onTap;

  static const _badgeData = {
    'new': ('New', SellerColors.amber, SellerColors.amber50),
    'progress': ('In progress', SellerColors.blue, SellerColors.blue50),
    'completed': ('Done', SellerColors.green, SellerColors.green50),
    'cancelled': ('Cancelled', SellerColors.red, SellerColors.red50),
  };

  @override
  Widget build(BuildContext context) {
    final bd = _badgeData[order.status] ?? ('Unknown', SellerColors.muted, SellerColors.bg);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: SellerColors.line))),
        child: Row(children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: order.tileBg, borderRadius: BorderRadius.circular(14)), child: Center(child: Text(order.emoji, style: const TextStyle(fontSize: 23)))),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(order.service, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: SellerColors.ink)),
            const SizedBox(height: 2),
            Row(children: [
              const Text('👤 ', style: TextStyle(fontSize: 12)),
              Text('${order.customerName} · ${order.when}', style: const TextStyle(fontSize: 12, color: SellerColors.muted)),
            ]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(order.amount, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: SellerColors.ink)),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(color: bd.$3, borderRadius: BorderRadius.circular(20)),
              child: Text(bd.$1, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: bd.$2)),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.listing});
  final SellerListing listing;

  static const _statusData = {
    'active': ('Active', SellerColors.green, SellerColors.green50),
    'pending': ('In review', SellerColors.amber, SellerColors.amber50),
    'paused': ('Paused', SellerColors.muted, SellerColors.bg),
  };

  @override
  Widget build(BuildContext context) {
    final sd = _statusData[listing.status] ?? ('Unknown', SellerColors.muted, SellerColors.bg);
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(color: SellerColors.card, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 22, offset: Offset(0, 6))]),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 118,
          color: listing.tileBg,
          child: Stack(children: [
            Center(child: Text(listing.emoji, style: const TextStyle(fontSize: 48))),
            Positioned(
              top: 11, left: 11,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(20)),
                child: Text(sd.$1, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: sd.$2)),
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 13, 15, 15),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(listing.category.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: SellerColors.teal500, letterSpacing: 0.5)),
            const SizedBox(height: 3),
            Text(listing.title, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: SellerColors.ink, letterSpacing: -0.2)),
            const SizedBox(height: 2),
            Row(children: [
              Text(listing.price, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: SellerColors.ink)),
              Text(' ${listing.unit}', style: const TextStyle(fontSize: 12, color: SellerColors.muted, fontWeight: FontWeight.w600)),
            ]),
            const Divider(color: SellerColors.line, height: 22),
            Row(children: [
              const Text('👁 ', style: TextStyle(fontSize: 12)),
              Text('${listing.views} views', style: const TextStyle(fontSize: 12, color: SellerColors.muted, fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
              const Text('📅 ', style: TextStyle(fontSize: 12)),
              Text('${listing.bookings} bookings', style: const TextStyle(fontSize: 12, color: SellerColors.muted, fontWeight: FontWeight.w600)),
              const Spacer(),
              const Text('Edit ›', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: SellerColors.teal500)),
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
          '${txn.isCredit ? '+' : '-'}AED ${txn.amount}',
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
  const _Input({this.hint = '', this.initial, this.prefix, this.keyboardType, this.maxLines = 1});
  final String hint;
  final String? initial, prefix;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: initial != null ? TextEditingController(text: initial) : null,
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
  const _SelectBox({required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
    decoration: BoxDecoration(color: SellerColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: SellerColors.line, width: 1.5)),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: items.first,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: SellerColors.muted),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 15, color: SellerColors.ink)))).toList(),
        onChanged: (_) {},
      ),
    ),
  );
}
