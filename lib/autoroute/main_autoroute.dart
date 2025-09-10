// AutoRoute - Package de navigation avancé pour Flutter
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
// Fichier généré automatiquement par AutoRoute contenant les définitions de routes
import 'package:nested_navigation_gorouter_example/autoroute/main_autoroute.gr.dart';
import 'package:nested_navigation_gorouter_example/shared/widgets/details_screen.dart';
import 'package:nested_navigation_gorouter_example/shared/widgets/scaffold_with_nested_navigation.dart';

void main() {
  // Supprime le '#' des URLs sur le web pour des URLs plus propres
  // Au lieu de: myapp.com/#/section/a → myapp.com/section/a
  usePathUrlStrategy();
  runApp(NestedNavigationApp());
}

/// Widget racine de l'application utilisant AutoRoute pour la navigation
class NestedNavigationApp extends StatelessWidget {
  NestedNavigationApp({super.key});

  // Instance du routeur personnalisé qui gère toute la navigation de l'app
  final nestedRouter = NestedRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // Configuration du routeur AutoRoute - remplace le système de navigation par défaut
      routerConfig: nestedRouter.config(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
    );
  }
}

/// Configuration du routeur AutoRoute avec annotation pour la génération de code
@AutoRouterConfig()
class NestedRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        // Route racine de l'application (/)
        AutoRoute(
          path: '/',
          initial: true, // Cette route est la route par défaut au démarrage
          page: HostRoute.page, // Page qui contient la navigation par onglets
          children: [
            // Section A avec navigation imbriquée
            AutoRoute(
              path: 'a', // URL: /a
              page: SectionAWrapperRoute.page, // Wrapper qui gère la navigation interne
              children: [
                // Page principale de la section A
                AutoRoute(
                  path: '', // URL: /a (chemin vide = route par défaut de la section)
                  page: SectionARoute.page,
                  initial: true, // Route par défaut quand on arrive sur /a
                ),
                // Page de détails de la section A
                AutoRoute(
                  path: 'details', // URL: /a/details
                  page: DetailsARoute.page,
                ),
              ],
            ),
            // Section B avec navigation imbriquée (même structure que A)
            AutoRoute(
              path: 'b', // URL: /b
              page: SectionBWrapperRoute.page,
              children: [
                // Page principale de la section B
                AutoRoute(
                  path: '', // URL: /b
                  page: SectionBRoute.page,
                  initial: true,
                ),
                // Page de détails de la section B
                AutoRoute(
                  path: 'details', // URL: /b/details
                  page: DetailsBRoute.page,
                ),
              ],
            ),
          ],
        ),
      ];
}

/// Écran principal qui gère la navigation par onglets
@RoutePage()
class HostScreen extends StatelessWidget {
  const HostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // AutoTabsRouter gère automatiquement la navigation entre onglets
    // Il maintient l'état de chaque onglet séparément (navigation imbriquée)
    return AutoTabsRouter(
      // Définit les routes des onglets disponibles
      routes: [
        SectionAWrapperRoute(), // Onglet A
        SectionBWrapperRoute(), // Onglet B
      ],
      // Builder appelé à chaque changement d'onglet
      builder: (context, child) {
        // Récupère l'instance du routeur d'onglets pour contrôler la navigation
        final tabsRouter = AutoTabsRouter.of(context);
        
        // LayoutBuilder permet d'adapter l'UI selon la taille de l'écran
        return LayoutBuilder(
          builder: (context, constraints) {
            // Sur mobile (largeur < 450px) : barre de navigation en bas
            if (constraints.maxWidth < 450) {
              return ScaffoldWithNavigationBar(
                body: child, // Contenu de l'onglet actuel
                selectedIndex: tabsRouter.activeIndex, // Index de l'onglet actif
                onDestinationSelected: (index) {
                  tabsRouter.setActiveIndex(
                    index,
                    // notify: false si on tape sur l'onglet déjà actif
                    // Cela permet de revenir à la page racine de l'onglet
                    notify: index != tabsRouter.activeIndex,
                  );
                },
              );
            } else {
              // Sur desktop/tablette : rail de navigation à gauche
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

/// Wrapper pour la Section A - Gère la navigation imbriquée à l'intérieur de l'onglet A
/// Ce wrapper est essentiel pour permettre la navigation entre SectionAScreen et DetailsAScreen
/// tout en maintenant l'état de l'onglet A séparément de l'onglet B
@RoutePage()
class SectionAWrapperScreen extends StatelessWidget {
  const SectionAWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // AutoRouter() crée un nouveau contexte de navigation pour les routes enfants
    // Il affiche automatiquement la route enfant appropriée selon l'URL
    return const AutoRouter();
  }
}

/// Wrapper pour la Section B - Même principe que SectionAWrapperScreen
/// Permet la navigation imbriquée indépendante dans l'onglet B
@RoutePage()
class SectionBWrapperScreen extends StatelessWidget {
  const SectionBWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Chaque wrapper maintient sa propre pile de navigation
    // Quand on navigue dans l'onglet B, l'onglet A garde son état
    return const AutoRouter();
  }
}

/// Écran principal de la Section A - Page racine de l'onglet A
@RoutePage()
class SectionAScreen extends StatelessWidget {
  const SectionAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Section A"),
        // Désactive le bouton retour automatique car c'est la page racine
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
              // Navigation vers la page de détails de la section A
              // context.pushRoute() ajoute une nouvelle page à la pile de navigation
              // L'URL devient: /a/details
              onPressed: () => context.pushRoute(DetailsARoute()),
              child: const Text("Show Details"),
            ),
          ],
        ),
      ),
    );
  }
}

/// Écran principal de la Section B - Page racine de l'onglet B
@RoutePage()
class SectionBScreen extends StatelessWidget {
  const SectionBScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Section B"),
        // Pas de bouton retour car c'est la page racine de l'onglet B
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
              // Navigation vers les détails de la section B
              // URL résultante: /b/details
              onPressed: () => context.pushRoute(DetailsBRoute()),
              child: const Text("Show Details"),
            ),
          ],
        ),
      ),
    );
  }
}

/// Écran de détails pour la Section A
@RoutePage()
class DetailsAScreen extends StatelessWidget {
  const DetailsAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Utilise le widget DetailsScreen partagé avec le label "A"
    // Ce widget contient la logique commune d'affichage des détails
    return DetailsScreen(
      label: "A",
    );
  }
}

/// Écran de détails pour la Section B avec fonctionnalité de reset
@RoutePage()
class DetailsBScreen extends StatelessWidget {
  const DetailsBScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DetailsScreen(
      label: "B",
      // Callback personnalisé pour démontrer la navigation complexe
      onResetPressed: () {
        // Exemple de navigation complexe : reset + changement d'onglet
        
        // 1. Récupère le routeur d'onglets depuis le contexte
        final tabsRouter = AutoTabsRouter.of(context);

        // 2. Revient à la page racine de l'onglet actuel (Section B)
        //    popUntilRoot() supprime toutes les pages de la pile jusqu'à la racine
        context.router.popUntilRoot();

        // 3. Change vers l'onglet A (index 0)
        //    Cela démontre comment naviguer entre onglets programmatiquement
        tabsRouter.setActiveIndex(0);
      },
    );
  }
}
