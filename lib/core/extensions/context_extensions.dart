import 'package:flutter/material.dart';

extension NavigationContext on BuildContext {
  /// Push a named route onto the navigation stack
  /// Usage: context.push(Routes.scanQrEntry)
  Future<dynamic> push(String routeName, {Object? arguments}) {
    return Navigator.pushNamed(this, routeName, arguments: arguments);
  }

  /// Push and replace the current route
  /// Usage: context.pushReplacement(Routes.scanQrResult)
  Future<dynamic> pushReplacement(String routeName, {Object? arguments}) {
    return Navigator.pushReplacementNamed(
      this,
      routeName,
      arguments: arguments,
    );
  }

  /// Push a named route and remove routes below it until [predicate] matches.
  /// Usage: context.pushUntil(Routes.root, (route) => route.isFirst)
  /// Usage: context.pushUntil(Routes.loginScreen, (route) => false)
  Future<dynamic> pushUntil(
    String routeName,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil(
      this,
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  /// Pop the current route
  /// Usage: context.pop()
  void pop<T extends Object?>([T? result]) {
    Navigator.pop(this, result);
  }
}