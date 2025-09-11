import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

import '../shared/widgets/details_screen.dart';
import '../shared/widgets/root_screen.dart';
import '../shared/widgets/scaffold_with_nested_navigation.dart';

/// Global navigator keys for GoRouter navigation management
/// Each key maintains its own navigation stack independently
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorAKey = GlobalKey<NavigatorState>(debugLabel: 'shellA');
final _shellNavigatorBKey = GlobalKey<NavigatorState>(debugLabel: 'shellB');

/// GoRouter configuration with nested navigation support
/// Demonstrates StatefulShellRoute.indexedStack for tab-based navigation
final goRouter = GoRouter(
  initialLocation: '/a', // Start with tab A
  // Root navigator key - required for proper hot reload behavior
  // Known issue: https://github.com/flutter/flutter/issues/113757#issuecomment-1518421380
  // Still necessary to prevent navigator from popping to root on hot reload
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true, // Enable debug logging for development
  routes: [
    /// StatefulShellRoute with IndexedStack for tab navigation
    /// Based on official GoRouter example for stateful navigation
    /// Reference: https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart
    StatefulShellRoute.indexedStack(
      // Builder creates the main scaffold with navigation shell
      builder: (context, state, navigationShell) {
        return GoRouterNestedNavigation(navigationShell: navigationShell);
      },
      // Define navigation branches (tabs) with independent navigation stacks
      branches: [
        /// Tab A branch - handles /a and /a/details routes
        StatefulShellBranch(
          navigatorKey: _shellNavigatorAKey, // Independent navigator for tab A
          routes: [
            GoRoute(
              path: '/a', // Root route for tab A
              pageBuilder: (context, state) => NoTransitionPage(
                child: RootScreen(
                  label: 'A',
                  // Navigate to details using GoRouter context extension
                  onDetailsPressed: () => context.go('/a/details'),
                ),
              ),
              // Nested routes within tab A
              routes: [
                GoRoute(
                  path: 'details', // Relative path: /a/details
                  builder: (context, state) => const DetailsScreen(label: 'A'),
                ),
              ],
            ),
          ],
        ),
        /// Tab B branch - handles /b and /b/details routes with reset functionality
        StatefulShellBranch(
          navigatorKey: _shellNavigatorBKey, // Independent navigator for tab B
          routes: [
            GoRoute(
              path: '/b', // Root route for tab B
              pageBuilder: (context, state) => NoTransitionPage(
                child: RootScreen(
                  label: 'B',
                  onDetailsPressed: () => context.go('/b/details'),
                ),
              ),
              // Nested routes within tab B
              routes: [
                GoRoute(
                  path: 'details', // Relative path: /b/details
                  builder: (context, state) => DetailsScreen(
                    label: 'B',
                    /// Complex cross-tab navigation with state reset
                    /// Demonstrates advanced GoRouter navigation patterns
                    onResetPressed: () {
                      // Get the navigation shell to control tab switching
                      final navigationShell =
                          StatefulNavigationShell.of(context);
                      // Step 1: Reset tab B to its initial location
                      navigationShell.goBranch(1, initialLocation: true);
                      // Step 2: Switch to tab A after frame completion
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        navigationShell.goBranch(0);
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

/// Entry point for the GoRouter navigation example
/// Demonstrates StatefulShellRoute with nested navigation
void main() {
  // Remove '#' from URLs on web for cleaner URLs
  usePathUrlStrategy();
  runApp(const MyApp());
}

/// Main application widget using GoRouter for navigation
/// Uses MaterialApp.router with GoRouter configuration
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // GoRouter configuration with StatefulShellRoute
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
    );
  }
}

/// GoRouter-specific wrapper for nested navigation with responsive design
/// Handles the main scaffold containing tab navigation
class GoRouterNestedNavigation extends StatelessWidget {
  const GoRouterNestedNavigation({
    Key? key,
    required this.navigationShell,
  }) : super(key: key ?? const ValueKey<String>('GoRouterNestedNavigation'));

  /// StatefulNavigationShell provided by GoRouter's StatefulShellRoute
  /// Manages navigation state between different tabs
  final StatefulNavigationShell navigationShell;

  /// Navigate to a specific tab branch
  /// Implements common bottom navigation pattern where tapping active tab
  /// navigates to initial location (root of that tab)
  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // Reset to initial location if tapping the currently active tab
      // This provides expected UX behavior for bottom navigation
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Responsive design: adapt navigation UI based on screen size
    return LayoutBuilder(builder: (context, constraints) {
      // Mobile layout: bottom navigation bar
      if (constraints.maxWidth < 450) {
        return ScaffoldWithNavigationBar(
          body: navigationShell, // Contains the current tab's content
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _goBranch,
        );
      } else {
        // Desktop/tablet layout: left navigation rail
        return ScaffoldWithNavigationRail(
          body: navigationShell,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _goBranch,
        );
      }
    });
  }
}
