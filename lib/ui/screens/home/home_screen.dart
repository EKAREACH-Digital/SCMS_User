import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../topup/topup_screen.dart';
import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/order/order_repository.dart';
import '../../../data/repositories/wallet/wallet_repository.dart';
import '../../../model/user/user.dart';
import '../../../models/cart_model.dart';
import '../../../models/food_item.dart';
import '../../../theme/app_theme.dart';
import '../../../ui/states/balance_state.dart';
import '../../../ui/states/menu_state.dart';
import '../../../ui/states/order_history_state.dart';
import '../../../ui/states/notification_prefs_state.dart';
import '../alerts/view_model/notification_view_model.dart';
import '../../../ui/states/user_profile_state.dart';
import '../../../ui/utils/async_value.dart';
import '../../../ui/utils/currency_formatter.dart';
import '../../widgets/cart_bar.dart';
import '../../widgets/payment_success_dialog.dart';
import '../../widgets/smart_canteen_widgets.dart';
import '../shell/app_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BalanceState>().fetchBalance();
        context.read<MenuState>().load();
        context.read<OrderHistoryState>().loadFromBackend(
              context.read<OrderRepository>(),
              context.read<WalletRepository>(),
            );
        _loadProfile();
        context.read<NotificationViewModel>().refreshUnreadCount();
      }
    });
  }

  /// Pulls the real signed-in user from the backend so the header greeting
  /// shows their actual name/school instead of the placeholder default. Runs on
  /// every landing so it's correct even when onboarding was skipped.
  Future<void> _loadProfile() async {
    final authRepo = context.read<AuthRepository>();
    final profileState = context.read<UserProfileState>();
    final notificationPrefs = context.read<NotificationPrefsState>();
    try {
      final user = User.fromDto(await authRepo.getProfile());
      if (!mounted) return;
      profileState.setFromUser(
        id: user.id,
        name: user.fullName,
        email: user.email,
        schoolName: user.schoolName,
        canUseEmailPassword: user.canUseEmailPassword,
      );
      notificationPrefs.setFromUser(
        userId: user.id,
        orderUpdates: user.notifyOrderUpdates,
        promotions: user.notifyPromotions,
        systemAlerts: user.notifySystemAlerts,
      );
    } catch (_) {
      // Keep whatever the header already shows if the fetch fails.
    }
  }

  static const _filterLabels = [
    'All', 'Breakfast', 'Lunch', 'Dinner', 'Snacks', 'Drinks', 'Desserts',
  ];
  static const _filterCats = [
    '', 'breakfast', 'lunch', 'dinner', 'snacks', 'drinks', 'desserts',
  ];

  List<FoodItem> _filteredItems(List<FoodItem> all) {
    final cat = _filterCats[_selectedFilter];
    final items =
        cat.isEmpty ? all : all.where((f) => f.category == cat).toList();
    return items.take(4).toList();
  }

  void _showTopUpSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TopUpSheet(parentContext: context),
    );
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartProvider.of(context);

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _Header(
                    greeting: _greeting,
                    cartCount: cart.totalItems,
                    onCartTap: () =>
                        Navigator.pushNamed(context, '/order-summary'),
                    onNotifTap: () {},
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _BalanceCard(
                      onTopUp: _showTopUpSheet,
                      onQr: () {
                        HapticFeedback.mediumImpact();
                        AppShellScope.maybeOf(context)?.setTab(2);
                      },
                      onHistory: () =>
                          AppShellScope.maybeOf(context)?.setTab(3),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _SectionHeader(title: 'Meal Passes'),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _MealPassRow(
                      onTap: () => AppShellScope.maybeOf(context)?.setTab(2),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const _PromoBanner(),
                  ),
                  const SizedBox(height: 32),
                  _MenuSection(
                    selectedFilter: _selectedFilter,
                    onFilterChanged: (i) => setState(() => _selectedFilter = i),
                    filteredItems: _filteredItems(
                      switch (context.watch<MenuState>().items) {
                        AsyncData<List<FoodItem>>(:final data) => data,
                        _ => const <FoodItem>[],
                      },
                    ),
                    filterLabels: _filterLabels,
                    onViewAll: () => AppShellScope.maybeOf(context)?.setTab(1),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            CartBar(
              onViewCart: () => Navigator.pushNamed(context, '/order-summary'),
              // Checkout happens on the order-summary screen (pick session,
              // place the real order, pay, then get the QR coupon).
              onCheckout: () => Navigator.pushNamed(context, '/order-summary'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────────

class _Header extends StatefulWidget {
  const _Header({
    required this.greeting,
    required this.cartCount,
    required this.onCartTap,
    required this.onNotifTap,
  });

  final String greeting;
  final int cartCount;
  final VoidCallback onCartTap;
  final VoidCallback onNotifTap;

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showProfileMenu() async {
    HapticFeedback.selectionClick();
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final offset = box.localToGlobal(Offset.zero);
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + 20,
        offset.dy + 70,
        offset.dx + 200,
        offset.dy + 200,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: const [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 20, color: AppTheme.green),
              SizedBox(width: 12),
              Text('My Profile'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings_outlined, size: 20, color: AppTheme.green),
              SizedBox(width: 12),
              Text('Settings'),
            ],
          ),
        ),
      ],
    );
    if (!mounted) return;
    if (selected == 'profile') {
      AppShellScope.maybeOf(context)?.setTab(4);
    } else if (selected == 'settings') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings — coming soon'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProfileState>();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.green.withValues(alpha: 0.08), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Row(
          children: [
            // Interactive avatar — tap to open quick menu
            GestureDetector(
              onTap: _showProfileMenu,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.green.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: ClipOval(
                  child: user.photo != null
                      ? Image.file(
                          user.photo!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Text(
                          user.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.greeting,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: context.mutedColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: context.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                _ActionIcon(
                  icon: Icons.notifications_outlined,
                  onTap: widget.onNotifTap,
                ),
                if (context.watch<NotificationViewModel>().unreadBadge > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE53935)
                                .withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${context.watch<NotificationViewModel>().unreadBadge}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Stack(
              clipBehavior: Clip.none,
              children: [
                _ActionIcon(
                  icon: Icons.shopping_bag_outlined,
                  onTap: widget.onCartTap,
                ),
                if (widget.cartCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFE53935,
                            ).withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${widget.cartCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

class _ActionIcon extends StatefulWidget {
  const _ActionIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_ActionIcon> createState() => _ActionIconState();
}

class _ActionIconState extends State<_ActionIcon> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 80),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            splashColor: AppTheme.green.withValues(alpha: 0.12),
            highlightColor: AppTheme.green.withValues(alpha: 0.06),
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: () {
              setState(() => _isPressed = false);
              HapticFeedback.selectionClick();
              widget.onTap();
            },
            child: Icon(widget.icon, size: 20, color: context.textColor),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: context.textColor,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.commonViewAll,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.green,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppTheme.green,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _BalanceCard extends StatefulWidget {
  const _BalanceCard({
    required this.onTopUp,
    required this.onQr,
    required this.onHistory,
  });

  final VoidCallback onTopUp;
  final VoidCallback onQr;
  final VoidCallback onHistory;

  @override
  State<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<_BalanceCard> {
  bool _hidden = false;

  void _toggleHidden() {
    HapticFeedback.selectionClick();
    setState(() => _hidden = !_hidden);
  }

  @override
  Widget build(BuildContext context) {
    final balanceUsd = context.watch<BalanceState>().balanceUsd;
    final String khrText;
    final String usdText;
    double? balanceData;
    if (balanceUsd case AsyncData<double>(:final data)) {
      balanceData = data;
      khrText = CurrencyFormatter.usdToKhr(data);
      usdText = '≈ ${CurrencyFormatter.formatUSD(data)} USD';
    } else if (balanceUsd is AsyncError) {
      // No wallet yet (or the balance failed to load) — show a zero balance
      // rather than an error; a new user simply has no money yet.
      balanceData = 0;
      khrText = CurrencyFormatter.usdToKhr(0);
      usdText = '≈ ${CurrencyFormatter.formatUSD(0)} USD';
    } else {
      khrText = '···';
      usdText = 'Loading…';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.balanceCardGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.42),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -28,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            right: 44,
            bottom: -18,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.walletMyWallet,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.homeScholarBadge,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const _ActiveBadge(),
                  const SizedBox(width: 8),
                  // Hide / unhide balance toggle
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _toggleHidden,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          _hidden
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              // Animated number counter — smoothly tweens to the new balance
              _hidden
                  ? const Text(
                      '៛ • • • • • •',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    )
                  : balanceData != null
                  ? TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: balanceData),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeInOut,
                      builder: (context, value, _) => Text(
                        CurrencyFormatter.usdToKhr(value),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    )
                  : Text(
                      khrText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
              const SizedBox(height: 5),
              Text(
                _hidden ? '≈ ••••• USD' : usdText,
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _BalanceBtn(
                      label: 'Top Up',
                      icon: Icons.add_rounded,
                      isPrimary: true,
                      onTap: widget.onTopUp,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _BalanceBtn(
                      label: 'QR Pay',
                      icon: Icons.qr_code_2,
                      isPrimary: false,
                      onTap: widget.onQr,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _BalanceBtn(
                      label: 'History',
                      icon: Icons.receipt_long_rounded,
                      isPrimary: false,
                      onTap: widget.onHistory,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Compact USD / KHR segmented toggle (light surface — used in top-up sheet).
class _CurrencyToggle extends StatelessWidget {
  const _CurrencyToggle({required this.showUsd, required this.onChanged});

  final bool showUsd;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segment('USD', showUsd, () => onChanged(true)),
          _segment('Riel', !showUsd, () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _segment(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppTheme.green : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.green.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppTheme.green,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

// Pulsing "Active" status badge with a soft green glow.
class _ActiveBadge extends StatefulWidget {
  const _ActiveBadge();

  @override
  State<_ActiveBadge> createState() => _ActiveBadgeState();
}

class _ActiveBadgeState extends State<_ActiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);
    _glow = Tween<double>(
      begin: 0.2,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF69F0AE).withValues(alpha: _glow.value),
                blurRadius: 10,
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.circle, color: Color(0xFF69F0AE), size: 7),
              const SizedBox(width: 5),
              Text(
                AppLocalizations.of(context)!.commonActive,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BalanceBtn extends StatefulWidget {
  const _BalanceBtn({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  State<_BalanceBtn> createState() => _BalanceBtnState();
}

class _BalanceBtnState extends State<_BalanceBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.isPrimary;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isPrimary
                ? Colors.white
                : Colors.white.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(12),
            border: isPrimary
                ? null
                : Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon slides slightly when pressed
              AnimatedSlide(
                offset: _pressed ? const Offset(0.18, 0) : Offset.zero,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Icon(
                  widget.icon,
                  size: 15,
                  color: isPrimary ? const Color(0xFF2E7D32) : Colors.white,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? const Color(0xFF2E7D32) : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealPassCard extends StatefulWidget {
  const _MealPassCard({
    required this.title,
    required this.time,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String title;
  final String time;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_MealPassCard> createState() => _MealPassCardState();
}

class _MealPassCardState extends State<_MealPassCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: widget.isActive ? null : context.cardColor,
            gradient: widget.isActive
                ? const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.isActive
                    ? AppTheme.green.withValues(alpha: 0.35)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.isActive
                          ? Colors.white.withValues(alpha: 0.25)
                          : AppTheme.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: widget.isActive
                          ? [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      widget.icon,
                      size: 20,
                      color: widget.isActive ? Colors.white : AppTheme.green,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.qr_code_2,
                    size: 18,
                    color: widget.isActive
                        ? Colors.white60
                        : context.mutedColor,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: widget.isActive ? Colors.white : context.textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.time,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: widget.isActive ? Colors.white70 : context.mutedColor,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? Colors.white.withValues(alpha: 0.2)
                      : context.surfaceColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: widget.isActive ? Colors.white : AppTheme.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.isActive ? 'Active' : 'Upcoming',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: widget.isActive
                            ? Colors.white
                            : context.mutedColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealPassRow extends StatelessWidget {
  const _MealPassRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MealPassCard(
            title: 'Breakfast',
            time: '7:00 – 9:00 AM',
            icon: Icons.wb_sunny_rounded,
            isActive: true,
            onTap: onTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MealPassCard(
            title: 'Lunch',
            time: '11:00 AM – 1:00 PM',
            icon: Icons.lunch_dining_rounded,
            isActive: false,
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}

class _PromoBanner extends StatefulWidget {
  const _PromoBanner();

  @override
  State<_PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<_PromoBanner>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _entranceController;
  late Animation<double> _entranceFade;
  late Animation<Offset> _entranceSlide;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _entranceFade = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeInOut,
    );
    _entranceSlide =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _entranceFade,
      child: SlideTransition(
        position: _entranceSlide,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.green.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // ── Sharp food photo (revealed on the right) ─────────────────
                Positioned.fill(
                  child: Image.asset(
                    'asset/foods/exlusive.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const ColoredBox(color: Color(0xFF2E7D32)),
                  ),
                ),
                // ── Blurred copy, faded out left→right (blur 4 → 0) ──────────
                Positioned.fill(
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (rect) => const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.white, Colors.transparent],
                      stops: [0.35, 1.0],
                    ).createShader(rect),
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Image.asset(
                        'asset/foods/exlusive.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const ColoredBox(color: Color(0xFF2E7D32)),
                      ),
                    ),
                  ),
                ),
                // ── Green gradient overlay (dark TL → light BR) ──────────────
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1B5E20).withValues(alpha: 0.92),
                          const Color(0xFF43A047).withValues(alpha: 0.72),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                // ── Content ──────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pill-shaped EXCLUSIVE badge with star (gently pulsing)
                      ScaleTransition(
                        scale: Tween<double>(begin: 1.0, end: 1.06).animate(
                          CurvedAnimation(
                            parent: _iconController,
                            curve: Curves.easeInOut,
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        child: AnimatedBuilder(
                          animation: _iconController,
                          builder: (context, child) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(
                                    alpha: 0.12 + 0.22 * _iconController.value,
                                  ),
                                  blurRadius: 8,
                                  spreadRadius: 0.5,
                                ),
                              ],
                            ),
                            child: child,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.white,
                                size: 13,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                AppLocalizations.of(context)!.homePromoExclusive,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Headline
                      Text(
                        AppLocalizations.of(context)!.homePromoTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          height: 1.2,
                          letterSpacing: -0.3,
                          shadows: [
                            Shadow(
                              color: Color(0x66000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Subtext
                      Text(
                        AppLocalizations.of(context)!.homePromoBody,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Pill-shaped Claim Now button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .homeCouponApplied),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: const Color(0xFF1B5E20),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.homeClaimNow,
                                style: const TextStyle(
                                  color: Color(0xFF1B5E20),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Color(0xFF1B5E20),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuFilterChip extends StatefulWidget {
  const _MenuFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_MenuFilterChip> createState() => _MenuFilterChipState();
}

class _MenuFilterChipState extends State<_MenuFilterChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppTheme.green : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.isSelected ? AppTheme.green : context.borderColor,
              width: widget.isSelected ? 0 : 1.2,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.green.withValues(alpha: 0.32),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.isSelected ? Colors.white : context.mutedColor,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.filteredItems,
    required this.filterLabels,
    required this.onViewAll,
  });

  final int selectedFilter;
  final ValueChanged<int> onFilterChanged;
  final List<FoodItem> filteredItems;
  final List<String> filterLabels;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _SectionHeader(
            title: "Today's Menu",
            actionLabel: AppLocalizations.of(context)!.commonViewAll,
            onAction: onViewAll,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: filterLabels.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _MenuFilterChip(
              label: filterLabels[i],
              isSelected: selectedFilter == i,
              onTap: () => onFilterChanged(i),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
              childAspectRatio: 0.68,
            ),
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              return _FoodCard(
                item: item,
                onAdd: () => CartProvider.of(context).add(item),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FoodCard extends StatefulWidget {
  const _FoodCard({required this.item, required this.onAdd});

  final FoodItem item;
  final VoidCallback onAdd;

  @override
  State<_FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<_FoodCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: _FoodThumbnail(item: widget.item),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFFFB74D,
                          ).withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              widget.item.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: context.textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${widget.item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppTheme.green,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: widget.onAdd,
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.green,
                          borderRadius: BorderRadius.circular(11),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.green.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppLocalizations.of(context)!.commonAdd,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FoodThumbnail extends StatelessWidget {
  const _FoodThumbnail({required this.item});

  final FoodItem item;

  @override
  Widget build(BuildContext context) {
    final url = item.imageUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _placeholder(),
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    if (item.imagePath != null) {
      return Image.asset(
        item.imagePath!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    final idx = item.colorSeed % kFoodGradients.length;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: kFoodGradients[idx],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          kFoodIcons[idx % kFoodIcons.length],
          color: AppTheme.green,
          size: 52,
        ),
      ),
    );
  }
}

class _TopUpAmountTile extends StatelessWidget {
  const _TopUpAmountTile({required this.amount, required this.onTap});

  final String amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderColor),
        ),
        alignment: Alignment.center,
        child: Text(
          amount,
          style: const TextStyle(
            color: AppTheme.green,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _TopUpSheet extends StatefulWidget {
  const _TopUpSheet({required this.parentContext});

  final BuildContext parentContext;

  @override
  State<_TopUpSheet> createState() => _TopUpSheetState();
}

// USD ↔ KHR exchange rate (matches CurrencyFormatter's default).
const double _kRielRate = 4000.0;

class _TopUpSheetState extends State<_TopUpSheet> {
  final _customController = TextEditingController();
  bool _showCustom = false;
  bool _usd = true; // true → USD, false → Cambodian Riel
  String? _error;

  // Preset amounts, stored in USD as the base unit.
  static const _presetsUsd = [5.0, 10.0, 20.0, 50.0];

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  String _label(double usd) =>
      _usd ? '\$${usd.toStringAsFixed(2)}' : CurrencyFormatter.usdToKhr(usd);

  void _setCurrency(bool usd) {
    if (_usd == usd) return;
    HapticFeedback.selectionClick();
    setState(() {
      _usd = usd;
      _error = null;
    });
  }

  // Close this sheet, then open payment-method selection.
  // [amountUsd] is always in USD; [label] is shown in the chosen currency.
  void _proceed(double amountUsd, String label) {
    Navigator.pop(context);
    showModalBottomSheet<void>(
      context: widget.parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TopUpPaymentSheet(
        amount: amountUsd,
        label: label,
        onConfirm: (method) =>
            _doTopUp(widget.parentContext, amountUsd, label, method),
      ),
    );
  }

  void _toggleCustom() {
    HapticFeedback.selectionClick();
    setState(() => _showCustom = !_showCustom);
  }

  void _submitCustom() {
    final raw = _customController.text.trim().replaceAll(
      RegExp(r'[^0-9.]'),
      '',
    );
    final entered = double.tryParse(raw);
    if (entered == null || entered <= 0) {
      setState(() => _error = 'Please enter a valid amount');
      return;
    }
    // Normalise the entered value to USD.
    final usd = _usd ? entered : entered / _kRielRate;
    if (usd > 1000) {
      setState(
        () => _error = _usd
            ? 'Maximum top-up is \$1,000'
            : 'Maximum top-up is ៛4,000,000',
      );
      return;
    }
    setState(() => _error = null);
    _proceed(usd, _label(usd));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Lift the sheet above the keyboard when the custom field is focused.
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.walletTopUpBalance,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context)!.walletTopUpPrompt,
              style: TextStyle(color: context.mutedColor, fontSize: 13),
            ),
            const SizedBox(height: 18),
            // Currency option — USD or Cambodian Riel
            _CurrencyToggle(showUsd: _usd, onChanged: _setCurrency),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.8,
              children: _presetsUsd.map((usd) {
                final label = _usd
                    ? '\$${usd.toStringAsFixed(0)}'
                    : CurrencyFormatter.usdToKhr(usd);
                return _TopUpAmountTile(
                  amount: label,
                  onTap: () => _proceed(usd, _label(usd)),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Custom amount — reveals an input field on tap.
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: _showCustom
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _toggleCustom,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.green,
                    side: const BorderSide(color: AppTheme.green, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: Text(
                    AppLocalizations.of(context)!.walletEnterCustomAmount,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _customController,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    onSubmitted: (_) => _submitCustom(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: _usd
                          ? const Icon(
                              Icons.attach_money_rounded,
                              color: AppTheme.green,
                            )
                          : const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18),
                              child: Text(
                                '៛',
                                style: TextStyle(
                                  color: AppTheme.green,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      hintText: _usd
                          ? 'Enter amount in USD'
                          : 'Enter amount in Riel',
                      errorText: _error,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: context.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppTheme.green,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SmartCanteenButton(
                    label: 'Continue',
                    onPressed: _submitCustom,
                    radius: 14,
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

// ── Top-up payment method selection ───────────────────────────────────────────

class _TopUpMethod {
  const _TopUpMethod({
    required this.name,
    required this.tagline,
    required this.code,
    required this.logo,
    required this.brandColor,
  });

  final String name;
  final String tagline;
  final String code;
  final String logo;
  final Color brandColor;
}

const _kTopUpMethods = [
  _TopUpMethod(
    name: 'Bakong',
    tagline: 'Secure QR payment via NBC Bakong',
    code: 'Bakong',
    logo: 'asset/payment method/bakong.png',
    brandColor: Color(0xFFC62828),
  ),
  _TopUpMethod(
    name: 'ABA Pay',
    tagline: 'Instant transfer via ABA Mobile',
    code: 'ABA',
    logo: 'asset/payment method/aba.png',
    brandColor: Color(0xFF1565C0),
  ),
  _TopUpMethod(
    name: 'ACLEDA',
    tagline: 'Secure payment via ACLEDA iTech',
    code: 'ACLEDA',
    logo: 'asset/payment method/acleda.png',
    brandColor: Color(0xFF1A237E),
  ),
];

class _TopUpPaymentSheet extends StatefulWidget {
  const _TopUpPaymentSheet({
    required this.amount,
    required this.label,
    required this.onConfirm,
  });

  final double amount;
  final String label;
  final void Function(_TopUpMethod method) onConfirm;

  @override
  State<_TopUpPaymentSheet> createState() => _TopUpPaymentSheetState();
}

class _TopUpPaymentSheetState extends State<_TopUpPaymentSheet> {
  int? _selected;

  void _pick(int index) {
    if (_selected == index) return;
    HapticFeedback.selectionClick();
    setState(() => _selected = index);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.walletChoosePaymentMethod,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: context.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.walletChoosePaymentPrompt,
                    style: TextStyle(fontSize: 12.5, color: context.mutedColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Top-up amount summary
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.green.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.green.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 17,
                      color: AppTheme.green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context)!.walletTopUpAmount,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: context.mutedColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\$${widget.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.green,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < _kTopUpMethods.length; i++) ...[
              _TopUpMethodCard(
                method: _kTopUpMethods[i],
                selected: _selected == i,
                onTap: () => _pick(i),
              ),
              if (i < _kTopUpMethods.length - 1) const SizedBox(height: 10),
            ],
            const SizedBox(height: 24),
            AnimatedOpacity(
              opacity: _selected != null ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: _selected == null,
                child: SmartCanteenButton(
                  label: 'Confirm Top Up',
                  radius: 14,
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onConfirm(_kTopUpMethods[_selected!]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopUpMethodCard extends StatefulWidget {
  const _TopUpMethodCard({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final _TopUpMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_TopUpMethodCard> createState() => _TopUpMethodCardState();
}

class _TopUpMethodCardState extends State<_TopUpMethodCard> {
  bool _pressing = false;

  double get _scale {
    if (_pressing) return 0.965;
    return widget.selected ? 1.02 : 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.method;
    final sel = widget.selected;

    return AnimatedScale(
      scale: _scale,
      duration: Duration(milliseconds: _pressing ? 80 : 280),
      curve: _pressing ? Curves.easeOut : Curves.easeOutBack,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressing = true),
        onTapUp: (_) => setState(() => _pressing = false),
        onTapCancel: () => setState(() => _pressing = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: sel
                ? AppTheme.green.withValues(alpha: 0.04)
                : context.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: sel ? AppTheme.green : context.borderColor,
              width: sel ? 2.0 : 1.2,
            ),
            boxShadow: sel
                ? [
                    BoxShadow(
                      color: AppTheme.green.withValues(alpha: 0.16),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Rounded logo from asset/payment method/
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: m.brandColor.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    m.logo,
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.account_balance_rounded,
                      color: m.brandColor,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: sel ? AppTheme.green : context.textColor,
                      ),
                      child: Text(m.name),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      m.tagline,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: context.mutedColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: sel
                    ? Container(
                        key: const ValueKey('check'),
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: AppTheme.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                      )
                    : Container(
                        key: const ValueKey('arrow'),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: context.surfaceColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: context.mutedColor,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Top-up async helpers ──────────────────────────────────────────────────────

Future<void> _doTopUp(
  BuildContext ctx,
  double amount,
  String label,
  _TopUpMethod method,
) async {
  // ABA is a real gateway payment: hand off to the PayWay screen, which opens
  // a session on the backend and waits for the bank to confirm. The other
  // methods still use the direct wallet credit until they're integrated.
  if (method.code == 'ABA') {
    HapticFeedback.selectionClick();
    await Navigator.of(ctx).pushNamed(TopUpScreen.routeName, arguments: amount);
    if (ctx.mounted) {
      // The screen credits via the backend, so pull the authoritative balance.
      await ctx.read<BalanceState>().fetchBalance();
    }
    return;
  }

  HapticFeedback.mediumImpact();
  showDialog<void>(
    context: ctx,
    barrierDismissible: false,
    builder: (_) => _ProcessingDialog(amountLabel: label),
  );

  bool success = true;
  try {
    await ctx.read<BalanceState>().topUp(amount, method: method.name);
  } catch (_) {
    success = false;
  }

  if (!ctx.mounted) return;
  Navigator.of(ctx).pop(); // dismiss processing dialog
  if (!ctx.mounted) return;

  ctx.read<OrderHistoryState>().addOrder(
    OrderRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _formatNow(),
      items: 'Wallet Top-up via ${method.name}',
      total: amount,
      status: success ? 'Completed' : 'Failed',
      createdAt: DateTime.now(),
      type: 'deposit',
      logoAsset: method.logo,
    ),
  );

  if (success) {
    // Hand off from the processing dialog straight to the success modal.
    PaymentSuccessDialog.show(
      ctx,
      processingDuration: Duration.zero,
      amount: amount,
      title: 'Top-up Successful!',
      message: '\$${amount.toStringAsFixed(2)} added via ${method.name}',
      buttonLabel: 'Continue',
      onDismiss: () {},
    );
  } else {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFE53935),
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppLocalizations.of(ctx)!.walletTopUpFailed,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatNow() {
  final dt = DateTime.now();
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final m = dt.minute.toString().padLeft(2, '0');
  final period = dt.hour >= 12 ? 'PM' : 'AM';
  return 'Today, $h:$m $period';
}

// ── Processing dialog ─────────────────────────────────────────────────────────

class _ProcessingDialog extends StatefulWidget {
  const _ProcessingDialog({required this.amountLabel});

  final String amountLabel;

  @override
  State<_ProcessingDialog> createState() => _ProcessingDialogState();
}

class _ProcessingDialogState extends State<_ProcessingDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 0.88,
      end: 1.12,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _scale,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.green.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: AppTheme.green,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              color: AppTheme.green,
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Processing ${widget.amountLabel}…',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.commonPleaseWait,
            style: TextStyle(fontSize: 12, color: context.mutedColor),
          ),
        ],
      ),
    );
  }
}
