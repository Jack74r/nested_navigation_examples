import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final routerDelegate = BeamerDelegate(
    initialPath: '/a',
    locationBuilder: RoutesLocationBuilder(
      routes: {
        '*': (context, state, data) => const ScaffoldWithBottomNavBar(),
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      routerDelegate: routerDelegate,
      routeInformationParser: BeamerParser(),
      backButtonDispatcher: BeamerBackButtonDispatcher(
        delegate: routerDelegate,
      ),
    );
  }
}

/// Location defining the pages for the first tab
class ALocation extends BeamLocation<BeamState> {
  ALocation(super.routeInformation);
  @override
  List<String> get pathPatterns => ['/*'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
          key: const ValueKey('a'),
          title: 'Tab A',
          type: BeamPageType.noTransition,
          child: RootScreen(
            label: 'A',
            detailsPath: '/a/details',
            onGoHomeA: ScaffoldWithBottomNavBar.of(context)?.goHomeAResetB,
          ),
        ),
        if (state.uri.pathSegments.length == 2)
          BeamPage(
            key: const ValueKey('a/details'),
            title: 'Details A',
            child: DetailsScreen(
              label: 'A',
              onGoHomeA: ScaffoldWithBottomNavBar.of(context)?.goHomeAResetB,
            ),
          ),
      ];
}

/// Location defining the pages for the second tab
class BLocation extends BeamLocation<BeamState> {
  BLocation(super.routeInformation);
  @override
  List<String> get pathPatterns => ['/*'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
          key: const ValueKey('b'),
          title: 'Tab B',
          type: BeamPageType.noTransition,
          child: RootScreen(
            label: 'B',
            detailsPath: '/b/details',
            onGoHomeA: ScaffoldWithBottomNavBar.of(context)?.goHomeAResetB,
          ),
        ),
        if (state.uri.pathSegments.length == 2)
          BeamPage(
            key: const ValueKey('b/details'),
            title: 'Details B',
            child: DetailsScreen(
              label: 'B',
              onGoHomeA: ScaffoldWithBottomNavBar.of(context)?.goHomeAResetB,
            ),
          ),
      ];
}

/// A widget class that shows the BottomNavigationBar and performs navigation
/// between tabs
class ScaffoldWithBottomNavBar extends StatefulWidget {
  const ScaffoldWithBottomNavBar({super.key});

  // Ajout d'un helper pour accéder au state depuis les enfants
  static _ScaffoldWithBottomNavBarState? of(BuildContext context) {
    return context.findAncestorStateOfType<_ScaffoldWithBottomNavBarState>();
  }

  @override
  State<ScaffoldWithBottomNavBar> createState() =>
      _ScaffoldWithBottomNavBarState();
}

class _ScaffoldWithBottomNavBarState extends State<ScaffoldWithBottomNavBar> {
  late int _currentIndex;

  final _routerDelegates = [
    BeamerDelegate(
      initialPath: '/a',
      locationBuilder: (routeInformation, _) {
        if (routeInformation.uri.toString().contains('/a')) {
          return ALocation(routeInformation);
        }
        return NotFound(path: routeInformation.uri.toString());
      },
    ),
    BeamerDelegate(
      initialPath: '/b',
      locationBuilder: (routeInformation, _) {
        if (routeInformation.uri.toString().contains('/b')) {
          return BLocation(routeInformation);
        }
        return NotFound(path: routeInformation.uri.toString());
      },
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uriString = Beamer.of(context).configuration.uri.toString();
    _currentIndex = uriString.contains('/a') ? 0 : 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          Beamer(
            routerDelegate: _routerDelegates[0],
          ),
          Beamer(
            routerDelegate: _routerDelegates[1],
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        destinations: const [
          NavigationDestination(label: 'Section A', icon: Icon(Icons.home)),
          NavigationDestination(label: 'Section B', icon: Icon(Icons.settings)),
        ],
        onDestinationSelected: (index) {
          if (index != _currentIndex) {
            setState(() => _currentIndex = index);
            _routerDelegates[_currentIndex].update(rebuild: false);
          }
        },
      ),
    );
  }

  // Méthode pour reset B et aller sur A
  void goHomeAResetB() {
    // Reset la navigation de B
    _routerDelegates[1].beamToNamed('/b');
    // Change l’onglet actif vers A
    setState(() {
      _currentIndex = 0;
    });
    // Optionnel: forcer le rebuild du delegate A
    _routerDelegates[0].update(rebuild: false);
  }
}

/// Widget for the root/initial pages in the bottom navigation bar.
class RootScreen extends StatelessWidget {
  /// Creates a RootScreen
  const RootScreen(
      {required this.label,
      required this.detailsPath,
      this.onGoHomeA,
      Key? key})
      : super(key: key);

  /// The label
  final String label;

  /// The path to the detail page
  final String detailsPath;

  /// Callback pour navigation inter-tabs
  final VoidCallback? onGoHomeA;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tab root - $label'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.abc),
        //     onPressed: () => Beamer.of(context, root: true).beamToNamed('/b'),
        //   ),
        // ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Screen $label',
                style: Theme.of(context).textTheme.titleLarge),
            const Padding(padding: EdgeInsets.all(4)),
            TextButton(
              onPressed: () => Beamer.of(context).beamToNamed(detailsPath),
              child: const Text('View details'),
            ),
          ],
        ),
      ),
    );
  }
}

/// The details screen for either the A or B screen.
class DetailsScreen extends StatefulWidget {
  /// Constructs a [DetailsScreen].
  const DetailsScreen({
    required this.label,
    this.onGoHomeA,
    Key? key,
  }) : super(key: key);

  /// The label to display in the center of the screen.
  final String label;

  /// Callback pour navigation inter-tabs
  final VoidCallback? onGoHomeA;

  @override
  State<StatefulWidget> createState() => DetailsScreenState();
}

/// The state for DetailsScreen
class DetailsScreenState extends State<DetailsScreen> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details Screen - ${widget.label}'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Details for ${widget.label} - Counter: $_counter',
                style: Theme.of(context).textTheme.titleLarge),
            const Padding(padding: EdgeInsets.all(4)),
            TextButton(
              onPressed: () {
                setState(() {
                  _counter++;
                });
              },
              child: const Text('Increment counter'),
            ),
            if (widget.label == "B")
              ElevatedButton(
                onPressed: () {
                  if (widget.onGoHomeA != null) {
                    widget.onGoHomeA!();
                  } else {
                    // Fallback: ancienne logique
                    Beamer.of(context, root: true).beamToNamed('/a');
                  }
                },
                child: const Text('Go home A (reset B)'),
              ),
          ],
        ),
      ),
    );
  }
}
