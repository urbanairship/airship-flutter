import 'dart:convert';
import 'package:flutter/material.dart';

/// Utility class for handling Airship Custom Views
class CustomViewUtils {
  /// Parses custom view route and extracts the view name and properties
  static CustomViewRoute? parseCustomViewRoute(String? routeName) {
    if (routeName == null || !routeName.startsWith('/custom/')) {
      return null;
    }

    try {
      final uri = Uri.parse(routeName);
      final viewName = uri.pathSegments.last;

      // Decode properties from query parameter
      Map<String, dynamic> properties = {};
      final encodedProps = uri.queryParameters['props'];
      if (encodedProps != null) {
        try {
          final decodedBytes = base64.decode(encodedProps);
          final jsonString = utf8.decode(decodedBytes);
          properties = json.decode(jsonString) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('Failed to decode properties: $e');
        }
      }

      return CustomViewRoute(viewName: viewName, properties: properties);
    } catch (e) {
      debugPrint('Failed to parse custom view route: $e');
      return null;
    }
  }

  /// Helper to create a route handler for custom views
  static Route<dynamic>? generateCustomViewRoute(
    RouteSettings settings,
    Map<String, Widget Function(Map<String, dynamic>)> customViews,
  ) {
    final customRoute = parseCustomViewRoute(settings.name);
    if (customRoute == null) {
      return null;
    }

    final viewBuilder = customViews[customRoute.viewName];
    if (viewBuilder == null) {
      debugPrint('No custom view registered for: ${customRoute.viewName}');
      return null;
    }

    return MaterialPageRoute(
      builder: (context) => Scaffold(
        backgroundColor: Colors.transparent,
        body: viewBuilder(customRoute.properties),
      ),
    );
  }
}

/// Represents a parsed custom view route
class CustomViewRoute {
  final String viewName;
  final Map<String, dynamic> properties;

  const CustomViewRoute({
    required this.viewName,
    required this.properties,
  });
}
