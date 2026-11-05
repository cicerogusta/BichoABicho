import 'package:flutter/widgets.dart';
import 'usage_analytics.dart';

/// Only pages count as screen views; dialogs never replace the visible page name.
class UsageNavigatorObserver extends NavigatorObserver {
  UsageNavigatorObserver(this.analytics);
  final UsageAnalytics analytics;
  final List<Route<dynamic>> _pages = [];
  void _report() {
    final name = _pages.isEmpty ? '/' : _pages.last.settings.name;
    final matches = UsageScreen.values.where((screen) => screen.name == name);
    analytics.routeScreen(matches.isEmpty ? null : matches.first);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute) {
      _pages.add(route);
      _report();
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_pages.remove(route)) _report();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_pages.remove(route)) _report();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index = oldRoute == null ? -1 : _pages.indexOf(oldRoute);
    if (index >= 0) {
      _pages.removeAt(index);
      if (newRoute is PageRoute) _pages.insert(index, newRoute);
    } else if (newRoute is PageRoute) {
      _pages.add(newRoute);
    }
    _report();
  }
}
