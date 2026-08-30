import 'package:flutter/material.dart';

extension NavigationContext on BuildContext {
  /// Push a named route onto the navigation stack
  /// Usage: context.push(Routes.scanQrEntry)
  Future<dynamic> push(String routeName) {
    return Navigator.pushNamed(this, routeName);
  }

  /// Push and replace the current route
  /// Usage: context.pushReplacement(Routes.scanQrResult)
  Future<dynamic> pushReplacement(String routeName) {
    return Navigator.pushReplacementNamed(this, routeName);
  }

  /// Push until the predicate returns true
  /// Usage: context.pushUntil((route) => route.isFirst)
  void pushUntil(RoutePredicate predicate) {
    Navigator.pushNamedAndRemoveUntil(this, predicate as String, predicate);
  }

  /// Pop the current route
  void pop<T extends Object?>([T? result]) {
    Navigator.pop(this, result);
  }
}
