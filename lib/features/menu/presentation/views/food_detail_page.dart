import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/widgets/quantity_selector.dart';
import 'package:smart_canteen_user_frontend/core/widgets/smart_canteen_button.dart';
import 'package:smart_canteen_user_frontend/core/widgets/smart_canteen_text_field.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/food_item.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/viewmodels/cart_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/views/widgets/food_detail/food_detail_hero_image.dart';

/// Full-screen food detail page.
///
/// Receives the [FoodItem] via GoRouter `extra`.
class FoodDetailPage extends StatefulWidget {
  const FoodDetailPage({super.key, required this.item});

  final FoodItem item;

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  final _noteController = TextEditingController();
  int _quantity = 1;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _addToCart() {
    HapticFeedback.mediumImpact();
    final cart = context.read<CartViewModel>();
    for (var i = 0; i < _quantity; i++) {
      cart.add(widget.item);
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _FoodDetailAppBar(item: item),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ItemNamePrice(item: item),
                      const SizedBox(height: 20),
                      _NoteField(controller: _noteController),
                      const SizedBox(height: 24),
                      _QuantityRow(
                        quantity: _quantity,
                        onIncrement: () => setState(() => _quantity++),
                        onDecrement: () {
                          if (_quantity > 1) setState(() => _quantity--);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _AddToCartBar(
              item: item,
              quantity: _quantity,
              onAddToCart: _addToCart,
            ),
          ),
        ],
      ),
    );
  }
}

// App bar with hero image

class _FoodDetailAppBar extends StatelessWidget {
  const _FoodDetailAppBar({required this.item});

  final FoodItem item;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: context.bgColor,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.cardColor.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
      ),
      title: Text(
        'All Food',
        style: AppFonts.heading3.copyWith(color: context.textColor),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: FoodDetailHeroImage(item: item),
      ),
    );
  }
}

// Name + price row

class _ItemNamePrice extends StatelessWidget {
  const _ItemNamePrice({required this.item});

  final FoodItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            item.name,
            style: AppFonts.heading1.copyWith(
              color: context.textColor,
              fontWeight: AppFonts.bold,
              fontSize: 22,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '\$${item.price.toStringAsFixed(2)}',
          style: AppFonts.heading1.copyWith(
            color: AppColors.primary,
            fontWeight: AppFonts.bold,
          ),
        ),
      ],
    );
  }
}

// Add note field

class _NoteField extends StatelessWidget {
  const _NoteField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SmartCanteenTextField(
      controller: controller,
      label: 'Add Note',
      hintText: 'Any special requests?',
      prefixIcon: const Icon(
        Icons.edit_note_rounded,
        color: AppColors.primary,
        size: 20,
      ),
    );
  }
}

// Quantity row

class _QuantityRow extends StatelessWidget {
  const _QuantityRow({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Quantity',
          style: AppFonts.heading2.copyWith(color: context.textColor),
        ),
        QuantitySelector(
          quantity: quantity,
          onIncrement: onIncrement,
          onDecrement: onDecrement,
          minQuantity: 1,
          size: 44,
        ),
      ],
    );
  }
}

// Sticky add-to-cart bar

class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({
    required this.item,
    required this.quantity,
    required this.onAddToCart,
  });

  final FoodItem item;
  final int quantity;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final total = item.price * quantity;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: context.cardColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SmartCanteenButton(
        label: 'Add to Cart  •  \$${total.toStringAsFixed(2)}',
        onPressed: onAddToCart,
      ),
    );
  }
}
