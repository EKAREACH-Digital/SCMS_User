import 'package:flutter/material.dart';

import '../../widgets/smart_canteen_navigation_bar.dart';
import '../digital_wallet/history_screen.dart';
import '../digital_wallet/qr_screen.dart';
import '../home/home_screen.dart';
import '../menu_browsing/menu_screen.dart';
import '../settings/settings_screen.dart';

/// Exposes [setTab] to any descendant inside the shell.
class AppShellScope extends InheritedWidget {
  const AppShellScope({
    super.key,
    required this.setTab,
    required super.child,
  });

  final void Function(int) setTab;

  static AppShellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppShellScope>();

  @override
  bool updateShouldNotify(AppShellScope old) => old.setTab != setTab;
}

/// Tab indices for [AppShell]'s pager. Kept in one place so call sites don't
/// pass bare integers that silently break if the tab order changes.
abstract final class AppTab {
  static const home = 0;
  static const menu = 1;
  static const qr = 2;
  static const history = 3;
  static const settings = 4;
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialTab = 0});

  static const routeName = '/home';

  /// Tab to open on. Lets other screens land the user on a specific tab
  /// *inside* the shell — pushing the tab's own route instead would build it
  /// standalone, without the navigation bar.
  final int initialTab;

  /// Returns to the shell on [tab], clearing whatever is stacked above it.
  static void goToTab(BuildContext context, int tab) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (_) => false,
      arguments: tab,
    );
  }

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index;
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _index = widget.initialTab;
    _controller = PageController(initialPage: widget.initialTab);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setTab(int index) {
    if (index == _index) return;
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return AppShellScope(
      setTab: _setTab,
      child: Scaffold(
        body: PageView(
          controller: _controller,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            HomeScreen(),
            MenuScreen(),
            QrScreen(),
            HistoryScreen(),
            SettingsScreen(),
          ],
        ),
        bottomNavigationBar: SmartCanteenNavigationBarButton(
          currentIndex: _index,
          onTap: _setTab,
        ),
      ),
    );
  }
}
