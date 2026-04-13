# AI Rules for Flutter Development

This document defines coding, architecture, and workflow rules for AI agents working on this Flutter codebase.

The project follows **Domain-Driven Design**, **Repository pattern**, and **Service-based business logic**.

---

# Token Efficiency Guidelines

When working with the codebase:

- **Minimize token usage**
- **Batch tool calls**
- **Avoid reading entire codebase**
- **Prefer targeted file reads**
- **Make minimal edits**
- **Avoid repeating previously read data**

---

# Developer Assumptions

Assume the user is a Senior Software Engineer who understands programming concepts.

---

# Flutter Development Standards

You are an expert Flutter developer building **maintainable, performant, modern applications**.

Supported platforms:

- Mobile
- Web
- Desktop

---

# Code Quality Rules

### Structure

- Separate **UI**, **business logic**, and **data access**
- Follow **SOLID principles**
- Prefer **composition over inheritance**

### Naming

| Type | Convention |
|-----|------|
Classes | `PascalCase`
Variables | `camelCase`
Functions | `camelCase`
Files | `snake_case`

Avoid abbreviations.

---

### Functions

Functions should:

- Have **one responsibility**
- Stay under **~20 lines**
- Be easily testable

---

### Error Handling

- Never fail silently
- Use `try/catch`
- Create custom exceptions when needed

---

### Logging

Use the `logging` package.

Never use `print`.

---

### Code comments

* **API Documentation:** Add documentation comments to all public APIs,
  including classes, constructors, methods, and top-level functions.
* **Comments:** Write clear comments for complex or non-obvious code. Avoid
  over-commenting.

---

# Dart Best Practices

### Null Safety

Always write **sound null-safe code**.

Avoid `!` unless absolutely guaranteed safe.

---

### Async Code

Use:

```
Future
async/await
Stream
```

Always handle errors.

---

### Modern Dart

Prefer:

- Pattern matching
- Records
- Exhaustive `switch`

---

### Arrow Functions

Use arrow syntax for short functions.

```
int square(int x) => x * x;
```

---

# Flutter Best Practices

### Widgets

- Prefer **StatelessWidget**
- Widgets must be **immutable**
- Break large widgets into **small private widgets**

---

### Performance

Avoid heavy work inside `build()`.

Use:

```
compute()
ListView.builder
SliverList
```

---

### Const Constructors

Use `const` whenever possible.

---

# Architecture Overview

The project follows:

**Domain-Driven Design + Repository Pattern**

Layers:

```
UI (widgets/screens)
    ↓
Services (business logic)
    ↓
Repositories (data access)
    ↓
Data Source (database/API)
```

---

# Folder Structure

Organize code by **domain**, not by technical layer.

```
lib/
├── main.dart
├── core/
│   ├── service_locator.dart
│   ├── database/
│   ├── router/
│   ├── models/
│   └── theme/
│
└── [domain-name]/
    ├── screens/
    ├── widgets/
    ├── services/
    └── repositories/
```

---

# Routing expectations

- Define every accessible screen in `lib/core/router/app_router.dart` so go_router mirrors the domain hierarchy.
- Prefer `context.push` for stackable flows and only use `context.go`/`router.go` when jumping to root-level screens; guard `router.pop()` with `canPop()` before falling back to an explicit `go` path.

---

# Dependency Injection

The project uses `get_it`.

All registrations happen in:

```
lib/core/service_locator.dart
```

Example:

```dart
getIt.registerLazySingleton<SomeRepository>(
  () => SomeRepository(getIt<DatabaseService>().someBox),
);

getIt.registerLazySingleton<SomeService>(
  () => SomeService(getIt<SomeRepository>()),
);
```

Access services with:

```dart
final service = getIt<SomeService>();
```

---

# Repositories

Repositories handle **data persistence**.

Responsibilities:

- Wrap data sources (database boxes, API clients)
- Provide CRUD operations
- Expose `box.listenable()` for reactive UI

Example:

```dart
class SomeRepository {
  final Box<SomeModel> _box;

  SomeRepository(this._box);

  Box<SomeModel> get box => _box;

  Future<void> save(SomeModel model) => _box.put(model.id, model);

  List<SomeModel> getAll() => _box.values.toList();
}
```

Repositories **must NOT contain business logic**.

---

# Services

Services contain **all business logic**.

Characteristics:

- Inject repositories via constructor
- May expose `ValueNotifier` for UI state
- Must not contain UI code

Example:

```dart
class SomeService {
  final SomeRepository _repository;
  final ValueNotifier<SomeModel?> currentItem = ValueNotifier(null);

  SomeService(this._repository);
}
```

---

# State Management

State is reactive using **watch_it**.

Two patterns are used.

---

### Pattern 1: Database Reactive UI

```
ValueListenableBuilder<Box<T>>
```

Example:

```dart
ValueListenableBuilder<Box<SomeModel>>(
  valueListenable: repo.box.listenable(),
  builder: (context, box, _) {
    final items = box.values.toList();
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) => SomeItemWidget(item: items[i]),
    );
  },
)
```

---

### Pattern 2: Service State

Services expose `ValueNotifier`.

Widgets observe them with `watch_it`.

Example:

```dart
final item = watchValue((SomeService s) => s.currentItem);
```

---

# Widgets

Widgets must be **dumb**.

Responsibilities:

- Render UI
- Forward events to services
- Watch reactive state

Widgets must NOT:

- Contain business logic
- Access repositories directly
- Perform heavy calculations

---

# Data Flow

### Write

```
User → Widget → Service → Repository → Data Source
```

### Read

```
UI → Repository → Data Source (memory)
```

UI automatically rebuilds via:

```
box.listenable()
ValueNotifier
```

---

# Testing

### Repository tests

Test CRUD logic using mocked data sources.

---

### Service tests

Test business logic using mocked repositories.

---

### Widget tests

Widgets receive mocked services.

---

# Code Generation

The project uses:

```
json_serializable
build_runner
```

Run after modifying generated files:

```
dart run build_runner build --delete-conflicting-outputs
```

---

# UI Guidelines

### Responsiveness

Use:

```
LayoutBuilder
MediaQuery
```

---

### Text Styling

Always use theme styles:

```
Theme.of(context).textTheme
```

---

# Layout Best Practices

Use:

| Widget | Purpose |
|------|------|
Expanded | Fill remaining space |
Flexible | Shrink/grow |
Wrap | Prevent overflow |
SingleChildScrollView | Scroll large content |
ListView.builder | Long lists |

---

# Openspec Workflow

1. Only generate or archive specs when manually prompted to.
2. Follow existing specs.
3. Specs are updated manually after stable releases.
4. When generating specs, always follow this template:
    ```md
    # <feature-name> Specification

    ## Purpose
    <brief purpose>

    ## Requirements

    ### Requirement: <short requirement>
    The system SHALL <behavior>.

    #### Scenario: <name>
    - GIVEN <context>
    - WHEN <action>
    - THEN <outcome>
    ```

# Key Rules Summary

1. Business logic lives in **services**
2. Data access goes through **repositories**
3. UI is **reactive**
4. Widgets are **dumb**
5. Code is organized by **domain**
6. Use **get_it** for DI
7. Use **watch_it / ValueNotifier** for state
