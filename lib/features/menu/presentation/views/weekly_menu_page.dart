import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/menu/domain/entities/weekly_menu.dart';
import 'package:smart_canteen_user_frontend/features/menu/presentation/viewmodels/weekly_menu_viewmodel.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

/// Read-only view of the published weekly menu: what the canteen is serving on
/// each day, split by meal. Ordering still happens on the Menu tab — this
/// answers "what's on this week", not "buy this now".
class WeeklyMenuPage extends StatefulWidget {
  const WeeklyMenuPage({super.key});

  @override
  State<WeeklyMenuPage> createState() => _WeeklyMenuPageState();
}

class _WeeklyMenuPageState extends State<WeeklyMenuPage> {
  late int _day = WeeklyMenuViewModel.todayIndex();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  // GET /menus — weekly schedule scoped to the student's school.
  Future<void> _load() => context.read<WeeklyMenuViewModel>().load(
    schoolId: context.read<AuthViewModel>().user?.schoolId,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<WeeklyMenuViewModel>();
    final weekly = state.data;

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(title: Text(l10n.weeklyMenuTitle), elevation: 0),
      body: SafeArea(
        child: state.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : state.error != null
            ? _Message(
                icon: Icons.cloud_off_rounded,
                title: l10n.weeklyMenuErrorTitle,
                body: state.error!,
                onRetry: _load,
              )
            : weekly == null
            ? _Message(
                icon: Icons.event_busy_rounded,
                title: l10n.weeklyMenuEmptyTitle,
                body: l10n.weeklyMenuEmptyBody,
                onRetry: _load,
              )
            : _WeekBody(
                weekly: weekly,
                day: _day,
                onDayChanged: (d) {
                  HapticFeedback.selectionClick();
                  setState(() => _day = d);
                },
                showAllWeekNote: state.hasNoDaySchedule,
                entries: state.entriesForDay(_day),
              ),
      ),
    );
  }
}

// Week view

class _WeekBody extends StatelessWidget {
  const _WeekBody({
    required this.weekly,
    required this.day,
    required this.onDayChanged,
    required this.showAllWeekNote,
    required this.entries,
  });

  final WeeklyMenu weekly;
  final int day;
  final ValueChanged<int> onDayChanged;
  final bool showAllWeekNote;
  final Map<MealSlot, List<MenuEntry>> entries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEmpty = entries.values.every((l) => l.isEmpty);

    return Column(
      children: [
        _MenuHeader(menu: weekly),
        _DayStrip(selected: day, onChanged: onDayChanged),
        if (showAllWeekNote)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: _Note(text: l10n.weeklyMenuAllWeekNote),
          ),
        Expanded(
          child: isEmpty
              ? Center(
                  child: Text(
                    l10n.weeklyMenuNothingToday,
                    style: AppFonts.heading3.copyWith(
                      color: context.mutedColor,
                      fontSize: 13.5,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    for (final slot in MealSlot.values)
                      if (entries[slot]!.isNotEmpty) ...[
                        _SlotHeading(slot: slot, count: entries[slot]!.length),
                        const SizedBox(height: 8),
                        for (final e in entries[slot]!)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _DishTile(entry: e),
                          ),
                        const SizedBox(height: 10),
                      ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader({required this.menu});
  final WeeklyMenu menu;

  static String _fmt(DateTime d) =>
      '${d.day} ${const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1]}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu.name,
                  style: AppFonts.heading1.copyWith(
                    fontSize: 17,
                    fontWeight: AppFonts.bold,
                    color: context.textColor,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_fmt(menu.validFrom)} – ${_fmt(menu.validTo)}',
                  style: AppFonts.heading4.copyWith(
                    fontSize: 12.5,
                    color: context.mutedColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mon–Sun selector. Today is marked so the week has an anchor.
class _DayStrip extends StatelessWidget {
  const _DayStrip({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = [
      l10n.dayMon,
      l10n.dayTue,
      l10n.dayWed,
      l10n.dayThu,
      l10n.dayFri,
      l10n.daySat,
      l10n.daySun,
    ];
    final today = WeeklyMenuViewModel.todayIndex();

    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isSelected = i == selected;
          final isToday = i == today;
          return GestureDetector(
            onTap: () => onChanged(i),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : context.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : isToday
                      ? AppColors.primary.withValues(alpha: 0.45)
                      : context.borderColor,
                  width: isToday && !isSelected ? 1.4 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    labels[i],
                    style: AppFonts.heading3.copyWith(
                      fontSize: 13,
                      fontWeight: AppFonts.bold,
                      color: isSelected ? Colors.white : context.textColor,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(height: 3),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SlotHeading extends StatelessWidget {
  const _SlotHeading({required this.slot, required this.count});

  final MealSlot slot;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = switch (slot) {
      MealSlot.breakfast => l10n.slotBreakfast,
      MealSlot.lunch => l10n.slotLunch,
      MealSlot.dinner => l10n.slotDinner,
    };
    return Row(
      children: [
        Text(
          label,
          style: AppFonts.heading3.copyWith(
            fontSize: 13,
            fontWeight: AppFonts.bold,
            color: context.textColor,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: AppFonts.heading5.copyWith(
              fontSize: 11,
              fontWeight: AppFonts.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _DishTile extends StatelessWidget {
  const _DishTile({required this.entry});
  final MenuEntry entry;

  @override
  Widget build(BuildContext context) {
    final item = entry.item;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 48,
              height: 48,
              child: item.imageUrl != null
                  ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _DishPlaceholder(),
                      loadingBuilder: (context, child, progress) =>
                          progress == null ? child : const _DishPlaceholder(),
                    )
                  : const _DishPlaceholder(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.heading3.copyWith(
                    fontSize: 13.5,
                    fontWeight: AppFonts.bold,
                    color: context.textColor,
                  ),
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.heading5.copyWith(
                      fontSize: 11.5,
                      color: context.mutedColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '\$${item.price.toStringAsFixed(2)}',
            style: AppFonts.heading3.copyWith(
              fontWeight: AppFonts.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DishPlaceholder extends StatelessWidget {
  const _DishPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.10),
      child: const Icon(
        Icons.restaurant_rounded,
        size: 20,
        color: AppColors.primary,
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 15,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppFonts.heading5.copyWith(
                fontSize: 11.5,
                color: context.mutedColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.body,
    required this.onRetry,
  });

  final IconData icon;
  final String title;
  final String body;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppFonts.heading2.copyWith(
                fontWeight: AppFonts.bold,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: AppFonts.heading3.copyWith(
                color: context.mutedColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            TextButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
          ],
        ),
      ),
    );
  }
}
