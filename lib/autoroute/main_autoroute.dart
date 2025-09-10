// AutoRoute - Advanced navigation package for Flutter
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
// Auto-generated file by AutoRoute containing route definitions
import 'package:nested_navigation_gorouter_example/autoroute/main_autoroute.gr.dart';
import 'package:nested_navigation_gorouter_example/shared/widgets/details_screen.dart';
import 'package:nested_navigation_gorouter_example/shared/widgets/scaffold_with_nested_navigation.dart';

void main() {
  // Remove '#' from URLs on web for cleaner URLs
  usePathUrlStrategy();
  runApp(NestedNavigationApp());
}

/// Root application widget using AutoRoute for navigation
class NestedNavigationApp extends StatelessWidget {
  NestedNavigationApp({super.key});

  // Custom router instance that handles all app navigation
  final nestedRouter = NestedRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // AutoRoute router configuration
      routerConfig: nestedRouter.config(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
    );
  }
}

/// AutoRoute router configuration with code generation annotation
@AutoRouterConfig()
class NestedRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        // Root application route (/)
        AutoRoute(
          path: '/',
          initial: true, // Default route at startup
          page: HostRoute.page, // Page containing tab navigation
          children: [
            // Section A with nested navigation
            AutoRoute(
              path: 'a',
              page: SectionAWrapperRoute.page,
              children: [
                // Main page for section A
                AutoRoute(
                  path: '', // Default route for section A
                  page: SectionARoute.page,
                  initial: true,
                ),
                // Details page for section A
                AutoRoute(
                  path: 'details',
                  page: DetailsARoute.page,
                ),
              ],
            ),
            // Section B with nested navigation
            AutoRoute(
              path: 'b',
              page: SectionBWrapperRoute.page,
              children: [
                // Main page for section B
                AutoRoute(
                  path: '',
                  page: SectionBRoute.page,
                  initial: true,
                ),
                // Details page for section B
                AutoRoute(
                  path: 'details',
                  page: DetailsBRoute.page,
                ),
              ],
            ),
          ],
        ),
      ];
}

/// Main screen that handles tab navigation
@RoutePage()
class HostScreen extends StatelessWidget {
  const HostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // AutoTabsRouter automatically handles navigation between tabs
    // It maintains each tab's state separately (nested navigation)
    return AutoTabsRouter(
      // Define available tab routes
      routes: [
        SectionAWrapperRoute(),
        SectionBWrapperRoute(),
      ],
      // Builder called on each tab change
      builder: (context, child) {
        // Get tabs router instance to control navigation
        final tabsRouter = AutoTabsRouter.of(context);

        // LayoutBuilder adapts UI based on screen size
        return LayoutBuilder(
          builder: (context, constraints) {
            // Mobile: bottom navigation bar
            if (constraints.maxWidth < 450) {
              return ScaffoldWithNavigationBar(
                body: child,
                selectedIndex: tabsRouter.activeIndex,
                onDestinationSelected: (index) {
                  tabsRouter.setActiveIndex(
                    index,
                    // notify: false when tapping already active tab to go to root
                    notify: index != tabsRouter.activeIndex,
                  );
                },
              );
            } else {
              // Desktop/tablet: left navigation rail
              return ScaffoldWithNavigationRail(
                body: child,
                selectedIndex: tabsRouter.activeIndex,
                onDestinationSelected: (index) {
                  tabsRouter.setActiveIndex(
                    index,
                    notify: index != tabsRouter.activeIndex,
                  );
                },
              );
            }
          },
        );
      },
    );
  }
}

/// Wrapper for Section A - Handles nested navigation within tab A
@RoutePage()
class SectionAWrapperScreen extends StatelessWidget {
  const SectionAWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // AutoRouter() creates new navigation context for child routes
    return const AutoRouter();
  }
}

/// Wrapper for Section B - Handles nested navigation within tab B
@RoutePage()
class SectionBWrapperScreen extends StatelessWidget {
  const SectionBWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Each wrapper maintains its own navigation stack
    return const AutoRouter();
  }
}

/// Main screen for Section A
@RoutePage()
class SectionAScreen extends StatelessWidget {
  const SectionAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Section A"),
        // Disable automatic back button as this is the root page
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "This is the root screen for section A",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Padding(padding: EdgeInsets.all(4)),
            TextButton(
              // Navigate to section A details
              onPressed: () => context.pushRoute(DetailsARoute()),
              child: const Text("Show Details"),
            ),
          ],
        ),
      ),
    );
  }
}

/// Main screen for Section B
@RoutePage()
class SectionBScreen extends StatelessWidget {
  const SectionBScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Section B"),
        // No back button as this is the root page
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "This is the root screen for section B",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Padding(padding: EdgeInsets.all(4)),
            TextButton(
              // Navigate to section B details
              onPressed: () => context.pushRoute(DetailsBRoute()),
              child: const Text("Show Details"),
            ),
          ],
        ),
      ),
    );
  }
}

/// Details screen for Section A
@RoutePage()
class DetailsAScreen extends StatelessWidget {
  const DetailsAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Uses shared DetailsScreen widget
    return DetailsScreen(
      label: "A",
    );
  }
}

/// Details screen for Section B with reset functionality
@RoutePage()
class DetailsBScreen extends StatelessWidget {
  const DetailsBScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DetailsScreen(
      label: "B",
      // Custom callback demonstrating complex type-safe navigation
      onResetPressed: () {
        // Type-safe navigation to tab A with route B reset
        // Reset current tab B navigation stack
        context.router.popUntilRoot();

        // Navigate to Section A wrapper from root
        context.router.root.navigate(SectionAWrapperRoute());
      },
    );
  }
}
