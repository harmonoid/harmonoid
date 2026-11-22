## All

### Miscellaneous

- DRY, KISS, SOLID as usual.
- Easy to understand & easy to debug code.
- Trade off performance for readability & consistency. List possible improvements in chat, which can later be included.

### Comments

- Trailing period only if multi-sentence comment.
- Avoid comments. If one is absolutely necessary, it should be a single line explaining **"why"** rather than **"what"**.
- Whenever an example is provided for some new implementation, do not mention it in the new implementation's comments. That example (in most cases) is completely unrelated to the new implementation & that information is trivial.
- Consistent commenting should be used.
  - Pick existing comment conventions from the codebase.
  - If an existing comment reads `// Refresh the list.`, a new comment for the same action should use the same wording.
    - Bad examples:
      - `// Reload the list.`: Different verb for the same action.
    - If you feel that the existing wording does not fit the new comment, you must choose a more universal wording for both (existing & new) comments.

### Docstrings

- Programming language-specific style for mentioning arguments, returns, references etc.
- Minimal content, which should only tell what the class is, what the attribute is, what the method does etc. It should not explain its side effects or internals.
  - Good
    - `Returns [foo]`
    - `Sets [foo]`
    - `Populates [foo], [bar] & [baz] based on [qux]`
    - `Minimum file size`
    - `[Session]`
    - `[Directory](s) added to [foo]`
    - `[Directory] used for [foo]`
  - Bad
    - `...this method does foo because bar uses this method which needs baz...`
    - `...we have used foo for achieving bar...`
- Use "Whether" when writing docstrings for boolean attributes or getters.
- Consistent docstrings should be used.
  - Pick existing docstring conventions from the codebase.
  - If a declaration documents with `{@template name}`, references should reuse it with `{@macro name}`.
    - Bad examples:
      - Rewriting the documentation at the reference: Duplicated documentation.
      - `{@macro other}`: Different template name.
    - If you feel that the existing convention does not fit the new declaration, you must choose a more universal convention for both (existing & new) declarations.

### Nomenclature

- Class names should start with a noun e.g. `Configuration`, `MediaLibrary`, `MediaPlayer`, `ThemeNotifier`, `LyricsNotifier` etc.
- Method names should start with a verb e.g. `get`, `set`, `build`, `create`, `run`, `show` etc.
- Common prefixes should be used. This makes ownership easy to identify. For example:
  - File paths/names:
    - `feature/media_library/albums/album_item.foo`, `feature/media_library/albums/album_screen.foo`, `feature/media_library/albums/albums_screen.foo`, `feature/media_library/albums/notifier/album_notifier.foo`, `feature/media_library/albums/models/album.foo`, `feature/media_library/albums/models/album_info.foo` where `album` is the common prefix.
  - Classes:
    - `AlbumItem`, `AlbumScreen`, `AlbumsScreen`, `AlbumNotifier` where `Album` is the common prefix.
    - `UserForm`, `UserDialog`, `UserScreen`, `UserNotifier`, `UserNotifierFactory` where `User` is the common prefix.
  - Identifiers:
    - `cachePath`, `cacheFile`, `cacheFileName`, where `cache` is the common prefix.
    - `resultPath`, `resultFile`, `resultFileName`, where `result` is the common prefix.
    - This should only be done when there is more than one similar entity (e.g. inside a method). If there were only one "cache" or "result", we would simply use `path`, `file`, `fileName` etc.
  - Constants:
    - `formatBool`, `formatInt`, `formatDouble`, `formatString` etc. where `format` is the common prefix.
    - `eventPlay`, `eventPause`, `eventSeek`, etc. where `event` is the common prefix.
- Consistent naming should be used.
  - Pick existing naming conventions from the codebase.
  - If a method named `compareInvoice(first, second)` exists, the new method should be called `compareAgreement(first, second)`.
    - Bad examples:
      - `matchAgreement(first, second)`: Different verb in method name.
      - `compareAgreement(originalAgreement, newAgreement)`: Different argument names.
    - If you feel that existing naming does not fit the new member, you must choose a more universal naming for both (existing & new) members.

### Logic

#### Writing Classes

Logic at the intermediate level belongs inside individual classes composed of methods & attributes. It should use a common pattern:

```
static compile-time constant attributes

static self instance attribute (if singleton)

static initialized boolean attribute (if singleton)

constructor

static initialization method (if singleton)

public getters

public attributes

public methods

private methods

private getters

private attributes
```

In general, singletons should be avoided in favor of dependency injection. However, singletons may be used if early object creation is helpful (HIGHLIGHT WHEN DONE) e.g. some async one-time initialization is required during launch, class is meant to be widely used/accessed by various parts of the code. Singletons are completely unacceptable inside packages or libraries, but still moderately tolerable inside the end-user app.

#### Writing Methods

Logic at the lowest level belongs inside individual methods. It should use a common pattern:

```
create identifiers

validations

pre-processing

operation foo
operation bar

post-processing

update instance attributes

notify listeners
```

```
set progress 0
notify listeners

timestamp = now

for (file in directory) {
  metadata = file to metadata
  add metadata in database

  if ((now - timestamp) > 5 seconds) {
    set progress p/q
    notify listeners
  }
}

set progress indeterminate
notify listeners

for (metadata in database) {
  file = metadata to file

  if (file not exists) {
    remove metadata from database
  }
}

set progress 1
notify listeners

```

Use newlines to separate parts of the procedure.

#### Organizing Various Units

Feature-based folder structure. A feature may use any other feature or may contain a sub-feature:

```
- features
  - feature_a
    - feature_b
      - ...
    - api
      - ...
    - db
      - ...
    - models
      - feature_a_p.foo
      - feature_a_q.foo
      - ...
    - state
      - feature_a_notifier.foo
      - feature_a_dialog_notifier.foo
      - ...
    - ui
      - feature_a_screen.foo
      - feature_a_item.foo
      - feature_a_dialog.foo
      - feature_a_panel.foo
      - ...
    - utils
      - constants.foo
      - rendering.foo
      - ...
  - feature_c
    - ...
```

At the same time, certain core parts of the codebase should remain outside the feature-level structure. These are components that are shared across multiple features or are too primitive & generic to belong to any particular feature. Such units should be highly decoupled & independent.

During development, as the codebase grows, organization of a certain part should be revisited. Refer **"Placement & Locality"** for more details.

#### Deciding Placement & Locality

Where a constant, method, or class should be declared is an extremely important design decision. The guiding principle should always be to place it where it logically "belongs".

##### Constants

1. Some constants are used in a class or its methods only. Declare them within the class as a static variable (to avoid "magic values"):

```
class XyzClient {
  static const String apiKey = "API_KEY_VALUE"
  static const String sharedSecret = "SHARED_SECRET_VALUE"
  ...
}
```

Note that "apiKey" & "sharedSecret" "belong" inside "XyzClient". Outside code can consume "XyzClient.apiKey" if required.

2. Some constants do not have a specific location where they belong. Declare them in a separate file e.g. `dimensions.foo`, `constants.foo` etc. where all the code can access them.

##### Methods

A method keeps a certain logic for a class. It is best kept within that class only. Refer **'Avoid "Utils" & "Helpers"'** for more details.

Avoid creating standalone global functions in separate files or static functions in classes. However, it may be done when the function is intended to be widely reused or accessed across different parts of the codebase (HIGHLIGHT WHEN DONE).

#### Using Mappers & Extensions

Converting, mapping, or extracting one type into another is an extremely common operation in any codebase. Classes and their methods should primarily encapsulate dense, context-specific, domain-specific logic.

Avoid polluting classes and their methods with repetitive mapping or transformation code. Keep such logic separate from the core class implementation. Many programming languages provide language-level constructs such as extension methods and getters to handle these operations cleanly. This also allows sharing this common mapping or transformation code.

#### Using Early Returns

Early returns should be used wherever possible:

```
if (not enabled) return
if (not supported platform) return
if (already done) return
if (launch count < launch count threshold) return
if ((now - install date) < install age threshold) return

request review
```

```
target file = ...

if (target file exists) return

response = ...

if (response status code not 200) return

write response into target file

notify listeners
```

#### Avoiding "Utils" & "Helpers"

Do not create standalone global functions for every piece of logic. It is extremely important to establish clear ownership & define where every piece of code belongs.

Failing to do so will eventually cause the codebase to crumble under its own weight. Over time, code will become scattered, unrelated responsibilities will end up grouped together, & previously distinct contexts will become unnecessarily coupled.

#### Avoiding Race Conditions & Handling Mutual Exclusions

Use locks, mutexes, or other synchronization primitives wherever applicable.

Classes often require asynchronous initialization, whereas constructors are inherently synchronous. In such cases, use appropriate synchronization mechanisms to ensure that other methods of the class wait until initialization is complete before proceeding.

### Object Oriented Programming

- Inheritance
  - Runtime polymorphism with Liskov substitution is incredibly powerful i.e. being able to swap implementations based on platform, user choice etc.
  - In most cases, composition should be preferred over inheritance.
  - Inherited implementations take a distinct prefix e.g.
    - `FileSystemMediaLibrary` or `NetworkMediaLibrary` can exist for `MediaLibrary`, where the media library has its own module with: `MediaLibraryDatabase`, `MediaLibraryNotifier` etc.

## Dart

### Miscellaneous

- Use pattern matching wherever it makes the code better.
- Exceptions & stacktraces are logged with `debugPrint` inside `catch` blocks:

```dart
try {
  ...
} catch (exception, stacktrace) {
  debugPrint(exception.toString());
  debugPrint(stacktrace.toString());
}
```

### Nomenclature

- All constants should begin with `k` e.g. `kDesktopMargin`, `kMobileMargin`, `kUserAgent`, `kApplicationId` etc.

### Logic

#### Writing Models

Models are `@freezed` value types, with `fromJson` where JSON is required:

```dart
@freezed
abstract class Foo with _$Foo {
  const factory Foo({
    required int bar,
  }) = _Foo;

  factory Foo.fromJson(Map<String, dynamic> json) => _$FooFromJson(json);
}
```

#### Using Mappers & Extensions

1. Mappers are solely for converting one type into another (mind the `to` prefix). They should be created as follows:

```dart
/// Mappers for [Foo].
extension FooMappers on Foo {
  /// Converts to path.
  String toPath() => // TODO

  /// Converts to label.
  String toLabel() => // TODO

  /// Converts to icon.
  IconData toIcon() => // TODO
}
```

2. Extensions are solely for declaring some easy-to-access getters, for simplifying code elsewhere. They should be created as follows:

```dart
/// Extensions for [Foo].
extension FooExtensions on Foo {
  bool get isEmpty => // TODO

  bool get isNotEmpty => // TODO

  bool get isFirst => // TODO

  bool get isLast => // TODO

  String getBestElement() {
    // TODO
  }
}
```

Singletons may be accessed from these.

#### Avoiding Race Conditions & Handling Mutual Exclusions

`Lock` from `package:synchronized` must be used:

```dart
class FileParser {
  static const Set<String> kSupportedFileTypes = {'JPG', 'PNG'};

  FileParser(this.filePath) {
    _lock.synchronized(() async {
      // TODO
    });
  }

  final String filePath;

  Future<void> dispose() {
    _ensureNotDisposed();
    _disposed = true;
    return _lock.synchronized(() async {
      // TODO
    });
  }

  Future<Map<String, List<String>>> getProperties() {
    return _lock.synchronized(() async {
      _ensureNotDisposed();
      // TODO
    });
  }

  void _ensureNotDisposed() {
    if (_disposed) {
      throw DisposedException();
    }
  }

  bool _disposed = false;

  final Lock _lock = Lock();
}
```

## Flutter

### Miscellaneous

- No `mounted` or `context.mounted` checks.
- Routing uses `package:go_router`.

### Logic

#### Writing Notifiers

Notifiers own mutable UI state, normal classes own logic or data.

Notifiers extend `ChangeNotifier`, live in `state` folders & are named `FooNotifier`. Operations are async methods that mutate, persist & end with `notifyListeners`. Widely shared notifiers need async setup during launch, so they use a private constructor with `instance`, `initialized` & `ensureInitialized`:

```dart
class FooNotifier extends ChangeNotifier {
  static const kDefaultFoo = ...;
  static const kPossibleFoos = [...];

  static late final FooNotifier instance;

  static bool initialized = false;

  FooNotifier._();

  static Future<void> ensureInitialized() async {
    if (initialized) return;
    initialized = true;
    instance = FooNotifier._();
  }

  Foo foo = ...;
  Bar bar = ...;

  Future<void> setFoo(Foo value) async {
    if (foo == value) return;
    foo = value;
    notifyListeners();
    await Configuration.instance.set(foo: value);
  }

  Future<void> _fetchBar() async {
    ...
  }
}
```

#### Writing UI

Screens are stateful `FooScreen` widgets. They own the `Scaffold`, consume notifiers through `Consumer` & split into `_buildDesktopLayout`, `_buildTabletLayout` & `_buildMobileLayout`, dispatched on `isDesktop`/`isTablet`/`isMobile`.

Screens are split into smaller widgets to limit rebuilds & enable reuse. A widget holding frequently changing state subscribes itself through `ListenableBuilder` or `ValueListenableBuilder`, so the screen above never rebuilds for its changes.

```dart
class FooScreen extends StatefulWidget {
  const FooScreen({super.key});

  @override
  State<FooScreen> createState() => FooScreenState();
}

class FooScreenState extends State<FooScreen> {
  final TextEditingController _searchQueryController = TextEditingController();
  final ValueNotifier<bool> _elevatedNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    ...
  }

  @override
  void dispose() {
    _searchQueryController.dispose();
    _elevatedNotifier.dispose();
    super.dispose();
  }

  Widget _buildDesktopLayout(BuildContext context) {
    ...
  }

  Widget _buildTabletLayout(BuildContext context) {
    ...
  }

  Widget _buildMobileLayout(BuildContext context) {
    ...
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return _buildDesktopLayout(context);
    }
    if (isTablet) {
      return _buildTabletLayout(context);
    }
    if (isMobile) {
      return _buildMobileLayout(context);
    }
    throw UnimplementedError();
  }
}
```

#### Dependency Injection

Dependency injection through `package:provider` is preferred over singletons. Singletons exist only where early async initialization during launch requires them, & even then they are injected through providers:

```dart
return MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => FooNotifier.instance),
    ChangeNotifierProvider(create: (_) => BarNotifier()),
  ],
  child: ...,
);
```

State is read through `Consumer<FooNotifier>`, one-off calls through `context.read<FooNotifier>()`.

#### Organizing Various Units

Each feature lives in `lib/features/<feature>/` & mirrors this layout. Files carry the feature prefix:

```
- features
  - foo
    - bar
      - bar_item.dart
      - bar_screen.dart
    - api
      - foo_get.dart
    - database
      - database.dart
    - desktop
      - desktop_foo_header.dart
    - extensions
      - foo.dart
    - mappers
      - foo.dart
    - mobile
      - mobile_foo_header.dart
    - models
      - foo.dart
    - state
      - foo_notifier.dart
    - utils
      - foo_utils.dart
    - foo_item.dart
    - foo_screen.dart
```

- `bar/` is a sub-feature with the same layout inside.
- `api/` holds remote access.
- `database/` holds local access.
- `desktop/` holds desktop widgets.
- `extensions/` adds getters; may also live top-level in `lib/`.
- `mappers/` converts types; may also live top-level in `lib/`.
- `mobile/` holds mobile widgets.
- `models/` holds value types & enums.
- `state/` holds one or more notifiers.
- `utils/` holds helpers.

Shared state in `lib/state/<area>/` & shared services in `lib/core/` follow the same layout.

## Project

### Writing API Wrappers

- API wrappers live in `api/` folders as classes with a `call` method.
- Typed exceptions are thrown for callers, everything else is caught & logged:

```dart
class FooGet {
  Future<Foo?> call(...) async {
    try {
      ...
    } on FooException catch (exception, stacktrace) {
      ...
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }
}

class FooGetAccessException implements Exception {
  const FooGetAccessException();
}
```

### External Packages

- `external/` holds first-party package sources, consumed through path dependencies instead of pub.dev.
- `adaptive_layouts` supplies the shared UI pieces:
  - Screens should use `ContentScreen` or `SliverContentScreen`. `Scaffold` is used only if neither applies.
  - Scrolling collections should use `ScrollViewBuilder` for lists & grids.
  - Scroll controllers should come from `ScrollControllerMixin` or `ScrollControllerBuilder`. Raw `ScrollController` should never be created.
  - Tables should use `ListItemTable`.
  - Tappable text should use `TappableText`.
  - Secondary-press menus should use `ContextMenuListener`.

### Generated Code

- `scripts/` holds codegen, run manually when keys or strings change.
- `configuration_gen.py` builds `configuration.g.dart` from `configuration_keys.json`.
- `localization_gen.py` builds `values.g.dart` & `localization.g.dart` from `assets/localizations` JSON.

### Shared Utils

- `lib/utils/` holds helpers shared across features; files are added, changed & removed as needs evolve.
- Dialogs, file pickers, cover images & platform checks belong in `rendering.dart`.
- Reusable interaction widgets belong in `widgets.dart`.
- Heights, margins & tile sizes belong in `dimensions.dart`.
- App ID, version & URLs belong in `constants.dart`.
