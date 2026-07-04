import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/account_switcher/account_switcher_sheet.dart';
import '../router/app_routes.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    (Icons.home_rounded,                  Icons.home_outlined,                  'Home'),
    (Icons.calendar_today_rounded,        Icons.calendar_today_outlined,         'Bookings'),
    (Icons.account_balance_wallet_rounded, Icons.account_balance_wallet_outlined, 'Wallet'),
    (Icons.person_rounded,                 Icons.person_outline,                  'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      floatingActionButton: _BookFab(
        onTap: () => showAccountSwitcher(
          context,
          isSeller: false,
          onSwitchToUser: () {},
          onSwitchToSeller: () => context.push(AppRoutes.sellerPanel),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _BottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

// ─── FAB ─────────────────────────────────────────────────────────────────────

class _BookFab extends StatelessWidget {
  const _BookFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58, height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF21A892), Color(0xFF137A6D)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
        boxShadow: const [BoxShadow(color: Color(0x660A5A42), blurRadius: 26, offset: Offset(0, 12))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}

// ─── Bottom nav ──────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _teal700 = Color(0xFF137A6D);
  static const _teal050 = Color(0xFFE7F6F2);
  static const _ink400  = Color(0xFF8C9890);
  static const _line    = Color(0xFFECEFEA);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.white],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _line),
          boxShadow: const [BoxShadow(color: Color(0x14143218), blurRadius: 18, offset: Offset(0, -2))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(MainShell._items.length, (i) {
            final (active, inactive, label) = MainShell._items[i];
            final isOn = currentIndex == i;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isOn ? _teal050 : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(isOn ? active : inactive, size: 22, color: isOn ? _teal700 : _ink400),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isOn ? FontWeight.w700 : FontWeight.w600,
                      color: isOn ? _teal700 : _ink400,
                    ),
                  ),
                ]),
              ),
            );
          }),
        ),
      ),
    );
  }
}
