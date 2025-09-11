import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:nested_navigation_gorouter_example/beamer/screen_beam_location.dart';
import 'package:nested_navigation_gorouter_example/shared/widgets/scaffold_with_nested_navigation.dart';

/// Beamer-specific wrapper for nested navigation with bottom tabs
/// Demonstrates complex navigation patterns including:
/// - Multiple independent BeamerDelegates for each tab
/// - IndexedStack to preserve tab state
/// - Cross-tab navigation with state reset
class BeamerScaffoldWithBottomNavBar extends StatefulWidget {
  const BeamerScaffoldWithBottomNavBar({super.key});

  @override
  State<BeamerScaffoldWithBottomNavBar> createState() =>
      _BeamerScaffoldWithBottomNavBarState();
}

class _BeamerScaffoldWithBottomNavBarState
    extends State<BeamerScaffoldWithBottomNavBar> {
  /// Current active tab index (0 = Tab A, 1 = Tab B)
  late int _currentIndex;

  /// Independent BeamerDelegates for each tab
  /// Each delegate manages its own navigation stack independently
  final _routerDelegates = <BeamerDelegate>[];

  @override
  void initState() {
    super.initState();
    _routerDelegates.addAll([
      // Tab A BeamerDelegate - handles /a and /a/details routes
      BeamerDelegate(
        initialPath: '/a',
        // Independent tab configuration - crucial for proper tab isolation
        initializeFromParent: false, // Don't inherit parent state
        updateFromParent: false,     // Don't sync with parent updates
        updateParent: true,          // Allow back button to work properly
        locationBuilder: (routeInformation, _) {
          if (routeInformation.uri.toString().contains('/a')) {
            return ScreenBeamLocation(
              routeInformation,
              tabLabel: 'A',
              goHomeAResetB: goHomeAResetB,
            );
          }
          return NotFound(path: routeInformation.uri.toString());
        },
      ),
      // Tab B BeamerDelegate - handles /b and /b/details routes
      BeamerDelegate(
        initialPath: '/b',
        // Same independent configuration as Tab A
        initializeFromParent: false,
        updateFromParent: false,
        updateParent: true,
        locationBuilder: (routeInformation, _) {
          if (routeInformation.uri.toString().contains('/b')) {
            return ScreenBeamLocation(
              routeInformation,
              tabLabel: 'B',
              goHomeAResetB: goHomeAResetB,
            );
          }
          return NotFound(path: routeInformation.uri.toString());
        },
      ),
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync current tab index with the URL from parent Beamer
    final uriString = Beamer.of(context).configuration.uri.toString();
    _currentIndex = uriString.contains('/a') ? 0 : 1;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // IndexedStack preserves the state of each tab when switching
        // This is crucial for maintaining navigation history per tab
        final body = IndexedStack(
          index: _currentIndex,
          children: [
            // Tab A Beamer with unique key for proper state management
            Beamer(
              key: const ValueKey('tab_a'), // Essential for IndexedStack
              routerDelegate: _routerDelegates[0],
            ),
            // Tab B Beamer with unique key
            Beamer(
              key: const ValueKey('tab_b'), // Essential for IndexedStack
              routerDelegate: _routerDelegates[1],
            ),
          ],
        );

        // Responsive design: bottom nav bar for mobile, rail for desktop
        if (constraints.maxWidth < 450) {
          return ScaffoldWithNavigationBar(
            body: body,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              if (index != _currentIndex) {
                // Update current tab and refresh the selected delegate
                setState(() => _currentIndex = index);
                _routerDelegates[_currentIndex].update(rebuild: false);
              }
            },
          );
        } else {
          return ScaffoldWithNavigationRail(
            body: body,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              if (index != _currentIndex) {
                // Same logic for navigation rail
                setState(() => _currentIndex = index);
                _routerDelegates[_currentIndex].update(rebuild: false);
              }
            },
          );
        }
      },
    );
  }

  /// Complex cross-tab navigation: Reset Tab B and navigate to Tab A
  /// This demonstrates advanced navigation patterns where one tab can
  /// reset another tab's state and switch the active tab
  void goHomeAResetB() {
    // Step 1: Reset Tab B's navigation stack to its root
    // replaceRouteInformation: true ensures URL is updated
    _routerDelegates[1].beamToNamed('/b', replaceRouteInformation: true);

    // Step 2: Switch to Tab A
    setState(() {
      _currentIndex = 0;
    });

    // Step 3: Force Tab A to rebuild and sync with current state
    // This ensures proper synchronization after cross-tab navigation
    _routerDelegates[0].update(rebuild: true);
  }
}
