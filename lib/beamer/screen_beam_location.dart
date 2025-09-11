import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:nested_navigation_gorouter_example/shared/widgets/details_screen.dart';
import 'package:nested_navigation_gorouter_example/shared/widgets/root_screen.dart';

/// Generic BeamLocation for tab-based navigation
/// Handles routing for a single tab with its nested pages
/// Supports both root screen and details screen for each tab
class ScreenBeamLocation extends BeamLocation<BeamState> {
  ScreenBeamLocation(
    super.routeInformation, {
    required this.tabLabel,
    this.goHomeAResetB,
  });

  /// Label for this tab (e.g., 'A' or 'B')
  final String tabLabel;
  
  /// Callback for cross-tab navigation (only used in Tab B)
  /// Allows Tab B to reset itself and navigate to Tab A
  final VoidCallback? goHomeAResetB;

  /// Define the URL patterns this BeamLocation handles
  /// More specific patterns are better than wildcards for maintainability
  @override
  List<String> get pathPatterns => [
    '/${tabLabel.toLowerCase()}',           // Root tab route (e.g., /a, /b)
    '/${tabLabel.toLowerCase()}/details',   // Details route (e.g., /a/details, /b/details)
  ];

  /// Build the navigation stack for this tab based on current route
  /// Returns a list of BeamPage objects representing the current navigation stack
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    // Always include the root page for this tab
    final pages = <BeamPage>[
      BeamPage(
        key: ValueKey(tabLabel.toLowerCase()), // Unique key for Navigator optimization
        title: 'Tab $tabLabel',
        type: BeamPageType.noTransition, // No animation for tab root
        child: RootScreen(
          label: tabLabel,
          // Navigate to details when button is pressed
          onDetailsPressed: () =>
              Beamer.of(context).beamToNamed('/${tabLabel.toLowerCase()}/details'),
        ),
      ),
    ];

    // Conditionally add details page if URL contains 'details'
    // This is more robust than checking path segment length
    if (state.uri.pathSegments.contains('details')) {
      pages.add(
        BeamPage(
          key: ValueKey('${tabLabel.toLowerCase()}/details'), // Unique key
          title: 'Details $tabLabel',
          child: DetailsScreen(
            label: tabLabel,
            // Only Tab B has the reset functionality
            onResetPressed: tabLabel == 'B' ? goHomeAResetB : null,
          ),
        ),
      );
    }

    return pages;
  }
}
