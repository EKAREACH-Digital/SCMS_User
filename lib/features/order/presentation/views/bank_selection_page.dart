import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_canteen_user_frontend/core/constants/images_constant.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';

class BankSelectionPage extends StatefulWidget {
  const BankSelectionPage({super.key});

  @override
  State<BankSelectionPage> createState() => _BankSelectionPageState();
}

enum BankOption { bakong, aba, acleda }

class _BankSelectionPageState extends State<BankSelectionPage> {
  BankOption? _selectedBank;

  void _continue() {
    final selectedBank = _selectedBank;
    if (selectedBank == null) return;
    context.pop(selectedBank);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        title: const Text('Choose Your Bank'),
        backgroundColor: context.bgColor,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
        children: [
          Text(
            'Select a bank to continue with PayWay.',
            style: TextStyle(color: context.mutedColor, fontSize: 14),
          ),
          const SizedBox(height: 20),
          _BankTile(
            title: 'Pay with Bakong',
            subtitle: 'Pay securely with Bakong',
            assetPath: ImageConst.bakong,
            selected: _selectedBank == BankOption.bakong,
            onTap: () => setState(() => _selectedBank = BankOption.bakong),
          ),
          const SizedBox(height: 12),
          _BankTile(
            title: 'ABA Bank',
            subtitle: 'Pay with ABA Mobile',
            assetPath: ImageConst.aba,
            selected: _selectedBank == BankOption.aba,
            onTap: () => setState(() => _selectedBank = BankOption.aba),
          ),
          const SizedBox(height: 12),
          _BankTile(
            title: 'ACLEDA Bank',
            subtitle: 'Pay with ACLEDA mobile banking',
            assetPath: ImageConst.acleda,
            selected: _selectedBank == BankOption.acleda,
            onTap: () => setState(() => _selectedBank = BankOption.acleda),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedBank == null ? null : _continue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                disabledBackgroundColor: context.borderColor,
                disabledForegroundColor: context.mutedColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BankTile extends StatelessWidget {
  const _BankTile({
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String assetPath;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.14)
                : context.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.primaryDark : context.borderColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.borderColor),
                ),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.account_balance_rounded,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: context.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(color: context.mutedColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
              _BankSelectionIndicator(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _BankSelectionIndicator extends StatelessWidget {
  const _BankSelectionIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryDark : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primaryDark : context.borderColor,
          width: 1.5,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
          : null,
    );
  }
}
