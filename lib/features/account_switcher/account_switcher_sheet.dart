import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

// ─── Colors ──────────────────────────────────────────────────────────────────
const _userGrad1 = Color(0xFF21A892);
const _userGrad2 = Color(0xFF137A6D);
const _sellGrad1 = Color(0xFF1E6B5E);
const _sellGrad2 = Color(0xFF0C3431);
const _teal6     = Color(0xFF18927F);
const _teal7     = Color(0xFF137A6D);
const _teal05    = Color(0xFFE7F6F2);
const _ink       = Color(0xFF15241F);
const _ink5      = Color(0xFF5E6E66);
const _ink4      = Color(0xFF8C9890);
const _line      = Color(0xFFECEFEA);
const _green     = Color(0xFF1D9E6F);
const _green50   = Color(0xFFE3F6EE);

/// Trigger pill widget — place on the left of any search bar.
/// Looks like Upstock's `[up ▼]` brand indicator.
class AccountTriggerPill extends StatelessWidget {
  const AccountTriggerPill({super.key, required this.onTap, this.dark = false});

  final VoidCallback onTap;
  /// Use [dark] = true on dark/teal backgrounds (seller panel header).
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: dark ? Colors.white.withValues(alpha: 0.15) : _teal05,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.2) : _teal7.withValues(alpha: 0.15)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'ELK',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: dark ? Colors.white : _teal7,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 3),
          Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: dark ? Colors.white : _teal7),
        ]),
      ),
    );
  }
}

/// Show the account-switcher bottom sheet from any context.
void showAccountSwitcher(
  BuildContext context, {
  required bool isSeller,
  required VoidCallback onSwitchToUser,
  required VoidCallback onSwitchToSeller,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AccountSwitcherSheet(
      isSeller: isSeller,
      onSwitchToUser: onSwitchToUser,
      onSwitchToSeller: onSwitchToSeller,
    ),
  );
}

// ─── Sheet ────────────────────────────────────────────────────────────────────

class _AccountSwitcherSheet extends StatefulWidget {
  const _AccountSwitcherSheet({
    required this.isSeller,
    required this.onSwitchToUser,
    required this.onSwitchToSeller,
  });
  final bool isSeller;
  final VoidCallback onSwitchToUser;
  final VoidCallback onSwitchToSeller;

  @override
  State<_AccountSwitcherSheet> createState() => _AccountSwitcherSheetState();
}

class _AccountSwitcherSheetState extends State<_AccountSwitcherSheet> {
  late bool _sellerMode;

  @override
  void initState() {
    super.initState();
    _sellerMode = widget.isSeller;
  }

  bool get _switched => _sellerMode != widget.isSeller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).padding.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Grip
        Center(child: Container(width: 42, height: 5, margin: const EdgeInsets.only(top: 10), decoration: BoxDecoration(color: const Color(0xFFD0D8D4), borderRadius: BorderRadius.circular(5)))),
        // User info header
        _buildUserHeader(),
        const SizedBox(height: 22),
        // ─── Big Upstock-style sliding toggle ───
        _buildSlidingToggle(),
        const SizedBox(height: 22),
        // Mode-specific info panel
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: SlideTransition(position: Tween(begin: const Offset(0, 0.05), end: Offset.zero).animate(anim), child: child)),
          child: _sellerMode ? _buildSellerPanel() : _buildUserPanel(),
        ),
        const SizedBox(height: 20),
        // Action button
        _buildActionButton(),
      ]),
    );
  }

  // ─── User info header ─────────────────────────────────────────────────────

  Widget _buildUserHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Row(children: [
        // Avatar
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_userGrad1, _userGrad2], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(child: Text('A', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white))),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('Aarav Menon', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _ink, letterSpacing: -0.3)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFFFEF6D8), borderRadius: BorderRadius.circular(6)),
              child: const Text('⚡ PRO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF7A5600))),
            ),
          ]),
          const SizedBox(height: 3),
          const Text('ELK-2025-04921  ·  Bengaluru, India', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _ink4)),
        ])),
        // Close
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(width: 34, height: 34, decoration: BoxDecoration(color: const Color(0xFFF0F4F2), borderRadius: BorderRadius.circular(17)), child: const Icon(Icons.close, size: 16, color: _ink5)),
        ),
      ]),
    );
  }

  // ─── Sliding toggle (Upstock-style) ──────────────────────────────────────

  Widget _buildSlidingToggle() {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 70,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F2),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(children: [
        // Animated sliding pill
        AnimatedAlign(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          alignment: _sellerMode ? Alignment.centerRight : Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.5,
            heightFactor: 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _sellerMode ? [_sellGrad1, _sellGrad2] : [_userGrad1, _userGrad2],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: (_sellerMode ? _sellGrad2 : _userGrad2).withValues(alpha: 0.4),
                    blurRadius: 16, offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Labels (on top of the sliding pill so they're always visible)
        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _sellerMode = false),
              child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('ELK', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: !_sellerMode ? Colors.white : _ink4, letterSpacing: 0.2)),
                const SizedBox(height: 2),
                Text(l10n.forUsers, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: !_sellerMode ? Colors.white.withValues(alpha: 0.85) : _ink4)),
              ])),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _sellerMode = true),
              child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('ELK', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _sellerMode ? Colors.white : _ink4, letterSpacing: 0.2)),
                const SizedBox(height: 2),
                Text(l10n.forSellers, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _sellerMode ? Colors.white.withValues(alpha: 0.85) : _ink4)),
              ])),
            ),
          ),
        ]),
      ]),
    );
  }

  // ─── User panel info ──────────────────────────────────────────────────────

  Widget _buildUserPanel() {
    final l10n = AppLocalizations.of(context);
    return Column(key: const ValueKey('user'), crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Stats row
      Row(children: [
        _StatTile(value: '12', label: l10n.navBookings, icon: Icons.calendar_today_outlined, color: _teal7),
        const SizedBox(width: 10),
        _StatTile(value: '₹240', label: l10n.navWallet, icon: Icons.account_balance_wallet_outlined, color: const Color(0xFF1D9E6F)),
        const SizedBox(width: 10),
        _StatTile(value: '150 pts', label: l10n.loyalty, icon: Icons.star_outline_rounded, color: const Color(0xFFE09B1A)),
      ]),
      const SizedBox(height: 14),
      // Account highlights
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: _teal05, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          const Icon(Icons.verified_outlined, size: 18, color: _teal6),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.verifiedAccount, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: _teal7)),
            const SizedBox(height: 2),
            Text('aarav.menon@gmail.com  ·  4.8★ rating', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _ink5)),
          ])),
        ]),
      ),
    ]);
  }

  // ─── Seller panel info ────────────────────────────────────────────────────

  Widget _buildSellerPanel() {
    final l10n = AppLocalizations.of(context);
    return Column(key: const ValueKey('seller'), crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Stats row
      Row(children: [
        _StatTile(value: '₹840', label: l10n.today, icon: Icons.trending_up_rounded, color: _green),
        const SizedBox(width: 10),
        _StatTile(value: '4.9★', label: l10n.profileRating, icon: Icons.star_rounded, color: const Color(0xFFE09B1A)),
        const SizedBox(width: 10),
        _StatTile(value: '₹3,280', label: l10n.balance, icon: Icons.account_balance_outlined, color: _sellGrad1),
      ]),
      const SizedBox(height: 14),
      // Business highlight
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFDCF2EC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_sellGrad1, _sellGrad2]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('BS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Bright Spark Services', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: _ink)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: _green50, borderRadius: BorderRadius.circular(5)),
                child: const Text('✓ Verified', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: _green)),
              ),
            ]),
            const SizedBox(height: 2),
            // No provider stats endpoint feeds this sheet, so it states the role only
            // rather than inventing a review count.
            Text(l10n.partnerAccount, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _ink5)),
          ])),
        ]),
      ),
    ]);
  }

  // ─── Action button ────────────────────────────────────────────────────────

  Widget _buildActionButton() {
    final l10n = AppLocalizations.of(context);
    if (!_switched) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: const Color(0xFFF0F4F2), borderRadius: BorderRadius.circular(18)),
        child: Center(
          child: Text(
            _sellerMode ? l10n.currentlySellerMode : l10n.currentlyUserMode,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _ink4),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (_sellerMode) {
          widget.onSwitchToSeller();
        } else {
          widget.onSwitchToUser();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _sellerMode ? [_sellGrad1, _sellGrad2] : [_userGrad1, _userGrad2],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: (_sellerMode ? _sellGrad2 : _userGrad2).withValues(alpha: 0.38),
              blurRadius: 20, offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            _sellerMode ? l10n.switchToSellerPanel : l10n.switchToUserPanel,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.2),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
        ]),
      ),
    );
  }
}

// ─── Stat tile ────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label, required this.icon, required this.color});
  final String value, label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _line),
          boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 7),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: _ink, letterSpacing: -0.3)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: _ink4)),
        ]),
      ),
    );
  }
}
