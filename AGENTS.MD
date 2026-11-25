# These rules are mandatory & followed always.

## All

### Miscellaneous

- DRY, KISS, SOLID as usual.
- Easy to understand & easy to debug code.
- Trade off performance for readability & consistency. List possible improvements in chat, which can later be included.

### Comments

- Trailing period only if multi-sentence comment.
- Avoid comments. If one is absolutely necessary, it should be a single line explaining **"why"** rather than **"what"**.
- Whenever an example is provided for some new implementation, do not mention it in the new implementation's comments. That example (in most cases) is completely unrelated to the new implementation & that information is trivial.
- Consistent commenting should be used (same for docstrings).
  - Pick existing comment conventions from the codebase.
  - If an existing comment reads `// Refresh the list`, a new comment should use the same wording.
    - Bad examples:
      - `// Reload the list`: Different verb for the same action.
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

### Nomenclature

- Class names should start with a noun e.g. `Configuration`, `MediaLibrary`, `MediaPlayer`, `ThemeNotifier`, `LyricsNotifier` etc.
- Method names should start with a verb e.g. `get`, `fetch`, `set`, `build`, `create`, `run`, `show` etc.
  - `get` should be used when the result is returned directly.
  - `fetch` should be used when the result is used to modify `this`.
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

A method keeps a certain logic for a class. It is best kept within that class only. Refer **'Avoiding "Utils" & "Helpers"'** for more details.

Avoid creating standalone global functions or static functions. However, it may be done when the function is intended to be widely reused or accessed across different parts of the codebase (HIGHLIGHT WHEN DONE).

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

- Use explicit types instead of `var`.
- Omit the type for `final` locals.
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

Scan existing mappers & extensions before writing new logic.

1. Mappers are solely for converting one type into another (mind the `to` prefix).

- One file & one extension per type.
- e.g. `mappers/track.dart` holds `TrackMappers on Track`.
- Created as follows:

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

2. Extensions are solely for easy-to-access members, getters or small methods, simplifying code elsewhere.

- One file & one extension per type.
- e.g. `extensions/track.dart` holds `TrackExtensions on Track`.
- Created as follows:

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

Mutable UI state lives in `FooNotifier` classes under `state` folders. They extend `ChangeNotifier`, are documented with `{@template}` & `{@macro}`, & app-wide ones are singletons set up once via `instance`, `initialized` & `ensureInitialized`. Callbacks are exposed as `onXyz` matching widget slots, e.g. `onPressed`.

```dart
/// {@template foo_notifier}
///
/// FooNotifier
/// -----------
/// ...
///
/// {@endtemplate}
class FooNotifier extends ChangeNotifier {
  /// Singleton instance.
  static final FooNotifier instance = FooNotifier._();

  /// Whether the [instance] is initialized.
  static bool initialized = false;

  /// {@macro foo_notifier}
  FooNotifier._();

  /// Initializes the [instance].
  static Future<void> ensureInitialized() async {
    if (initialized) return;
    initialized = true;
  }

  Foo foo = ...;

  /// Sets [foo].
  Future<void> setFoo(Foo value) async {
    if (foo == value) return;
    foo = value;
    notifyListeners();
    await Configuration.instance.set(foo: value);
  }

  Future<void> _fetchBar() async {
    ...
  }

  Bar _bar = ...;
}
```

#### Writing UI

Screens are stateful `FooScreen` widgets. They own the `Scaffold`, consume notifiers through `Consumer` & split into `_buildDesktopLayout`, `_buildTabletLayout` & `_buildMobileLayout`, dispatched on `isDesktop`/`isTablet`/`isMobile`.

Screens are split into smaller widgets to reduce complexity, limit rebuilds & enable reuse.

Child widgets are named `ModuleRole`, e.g. `LoginForm`, & live next to their screen. Promote one to `widgets.dart` once reused & free of module state. Wire `notifier.onXyz` straight into matching slots, keeping widgets dumb whenever possible.

```dart
class FooScreen extends StatefulWidget {
  const FooScreen({super.key});

  @override
  State<FooScreen> createState() => FooScreenState();
}

class FooScreenState extends State<FooScreen> {
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

State is subscribed through `Consumer<FooNotifier>` & read once through `context.read<FooNotifier>()`.

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
- `extensions/` adds easy-to-access members, getters or small methods; shared ones live top-level in `lib/`.
- `mappers/` converts types; shared ones live top-level in `lib/`.
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

- Call through Supabase, body for `...` above:

```dart
final response = await Supabase.instance.client.functions.invoke(
  'foo-get',
  method: HttpMethod.get,
  queryParameters: {...},
);
if (response.status != 200) return null;
return Foo.fromJson(response.data);
```

- Use plain fetch where Supabase cannot e.g. streaming a response into a file, body for `...` above:

```dart
final client = http.Client();
try {
  final request = http.Request(
    'GET',
    Supabase.instance.client.functionUri('foo-get', {...}),
  );
  request.headers.addAll(Supabase.instance.client.functions.headers);
  final response = await client.send(request);
  if (response.statusCode != 200) return false;
  final sink = file.openWrite();
  try {
    await response.stream.pipe(sink);
  } finally {
    await sink.close();
  }
  return true;
} finally {
  client.close();
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

- Primary codegen is `build_runner` (`freezed`, `json_serializable`, `drift` etc.).
  - Run via `dart run build_runner build`.
- Secondary codegen is scripts in `scripts/`:
  - `configuration_gen.py` adds/removes configuration.
  - `localization_gen.py` adds/removes localization.

### Shared Utils

- `lib/utils/` holds shared code used across features & shrinks over time.
  - Pieces are moved into features or packages, per **'Avoiding "Utils" & "Helpers"'**.
  - Reusable rendering methods in `rendering.dart`.
  - Reusable widgets belong in `widgets.dart`.
  - Reusable dimensions belong in `dimensions.dart`.
