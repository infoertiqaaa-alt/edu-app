import 'package:flutter/material.dart';

/// Global navigator key used for session-expiry navigation triggered from the
/// network layer (outside the widget tree).
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
