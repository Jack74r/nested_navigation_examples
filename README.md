# Flutter Nested Navigation Examples

A comprehensive comparison of Flutter navigation packages for complex nested navigation scenarios. This project extends Andrea Bizzotto's original work by adding more packages and demonstrating complex use cases including bottom navigation, nested routes, and cross-tab navigation patterns.

## 🎯 Project Goals

- **Compare** three major Flutter navigation packages: GoRouter, Beamer, and AutoRoute
- **Demonstrate** complex navigation patterns including nested routes and cross-tab navigation
- **Showcase** real-world scenarios where navigation state management becomes challenging
- **Highlight** the strengths and limitations of each approach

## 📦 Packages & Versions

| Package | Version | Purpose |
|---------|---------|---------|
| [go_router](https://pub.dev/packages/go_router) | 16.2.1 | Declarative routing with nested navigation |
| [beamer](https://pub.dev/packages/beamer) | 1.7.0 | Location-based routing with nested beaming |
| [auto_route](https://pub.dev/packages/auto_route) | 10.1.2 | Code generation based routing |
| [auto_route_generator](https://pub.dev/packages/auto_route_generator) | 10.2.4 | Code generator for AutoRoute |

## 🏗️ Architecture Overview

Each implementation demonstrates the same navigation structure:

```mermaid
graph TD
    A[App Root] --> B[Bottom Navigation]
    B --> C[Section A]
    B --> D[Section B]
    C --> E[A Details]
    D --> F[B Details]
    F --> G[Reset B & Go to A]

```

## 🔄 Complex Navigation Flow

The key challenge demonstrated is the **cross-tab navigation with state reset**:

```mermaid
sequenceDiagram
    participant User
    participant SectionB
    participant BDetails
    participant SectionA
    
    User->>SectionB: Navigate to Section B
    User->>BDetails: Tap "View Details"
    Note over BDetails: User increments counter
    User->>BDetails: Tap "Reset B & Go to A"
    BDetails->>SectionB: Reset navigation stack
    BDetails->>SectionA: Navigate to Section A
    Note over SectionA: Section B state is reset
```

## 📱 Navigation Implementations

### 1. GoRouter Implementation

**Strengths:**
- ✅ Declarative route configuration
- ✅ Built-in support for nested navigation with `StatefulShellRoute`
- ✅ Good integration with Flutter's navigation system
- ✅ Type-safe navigation

**Challenges:**
- ⚠️ Complex cross-tab navigation requires workarounds
- ⚠️ Need `addPostFrameCallback` for proper state reset
- ⚠️ `pop()` and `go()` interactions can be tricky

**Key Implementation Details:**
```dart
// Complex navigation requiring post-frame callback
onResetPressed: () {
  final navigationShell = StatefulNavigationShell.of(context);
  navigationShell.goBranch(1, initialLocation: true);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    navigationShell.goBranch(0);
  });
}
```

### 2. Beamer Implementation

**Strengths:**
- ✅ Location-based routing concept
- ✅ Clean separation of navigation logic
- ✅ Good support for nested navigation
- ✅ Flexible route building

**Challenges:**
- ⚠️ Steeper learning curve
- ⚠️ More boilerplate code required
- ⚠️ Complex state management for cross-tab navigation

**Key Implementation Details:**
```dart
// Clean cross-tab navigation
void goHomeAResetB() {
  _routerDelegates[1].beamToNamed('/b'); // Reset B
  setState(() => _currentIndex = 0);      // Switch to A
  _routerDelegates[0].update(rebuild: false);
}
```

### 3. AutoRoute Implementation

**Strengths:**
- ✅ Code generation for type-safe navigation
- ✅ Excellent TypeScript-like route definitions
- ✅ Clean and intuitive API
- ✅ Best-in-class cross-tab navigation support

**Challenges:**
- ⚠️ Requires code generation step
- ⚠️ Build runner dependency
- ⚠️ Learning curve for annotations

**Key Implementation Details:**
```dart
// Elegant cross-tab navigation
onResetPressed: () {
  context.router.popUntilRoot();                    // Reset current stack
  context.router.root.navigate(SectionAWrapperRoute()); // Navigate to A
}
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >=3.0.0
- Dart SDK >=3.0.0

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd nested_navigation_examples
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate AutoRoute files:
```bash
dart run build_runner build
```

### Running the Examples

Each implementation can be run independently:

```bash
# GoRouter implementation
flutter run lib/gorouter/main_gorouter.dart

# Beamer implementation  
flutter run lib/beamer/main_beamer.dart

# AutoRoute implementation
flutter run lib/autoroute/main_autoroute.dart
```

## 🧪 Testing the Complex Navigation

To test the challenging cross-tab navigation scenario:

1. **Navigate to Section B** using bottom navigation
2. **Tap "View Details"** to go to B Details screen
3. **Increment the counter** several times to create state
4. **Tap "Reset B & Go to A"** button
5. **Verify** that:
   - You're now on Section A
   - Section B's navigation stack is reset
   - When you return to Section B, the counter is back to 0
