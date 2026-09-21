---
name: edit-flutter-proj
description: Edit, extend, or refactor a Flutter app built on the clean-riverpod architecture — data/domain/presentation layers, AppError + guard/runLoad error path, AppEffect one-shot effects, riverpod_generator view models, flutter_hooks observers, freezed models, retrofit APIs, slang strings, auto_route. Use when adding a screen, endpoint, model, repository, view model, service, translation, asset, or cache entity; when adding an architecture module (auth, network, hive, flavors, logging, assets, ui_kit) to an existing project; or when adopting an existing Flutter project into this workflow. Keeps the project's CLAUDE.md memory current.
---

Paths are relative to the project root. `$SK` = the `create-flutter-proj`
skill directory, the sibling of this skill's directory (usually
`~/.claude/skills/create-flutter-proj`).

## 0. Every session

1. **Read `CLAUDE.md`** (the project memory) before touching code. No
   `CLAUDE.md`? The project was never adopted — run
   `bash $SK/scaffold.sh adopt`, then fill `CLAUDE.md` from the codebase
   (what the app is, features table, data sources) before the edit.
   If `analyze` isn't clean yet, record the baseline once:
   `bash .claude/verify.sh --accept`.
2. Read the nearest existing sibling of what you're about to write. In a
   codebase that follows these rules the sibling is the spec; this file is
   the tiebreaker.
3. **After the edit, update `CLAUDE.md`**: the Features table, Data sources,
   Decisions, Gotchas — whichever changed — and bump `Last synced`. A Stop
   hook blocks the session end until you do. Facts a future session needs,
   not a changelog.

House rules beat the generic dart/flutter skills in `.claude/skills/`:
auto_route not go_router, slang not gen-l10n, dio+retrofit not `http`,
riverpod_generator not hand-written notifiers, freezed not hand-written
`==`/`copyWith`. Use those skills for everything else (layout bugs, tests,
static analysis, pattern matching, docs).

Never hand-edit `*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `*.gen.dart`.
Change the annotated source and run the harness.

## Harness

```bash
bash .claude/verify.sh
```

(`adopt`/`new` copy it from this skill's `verify.sh`; missing → copy it.)
build_runner → `flutter analyze` (fails if issue count exceeds
`.claude/analyze-baseline.txt`, default 0) → `flutter test`. Lists changed
generated files so you commit them with the source. `--watch` for iterating.

## Add a module

Modules in the project: `.claude/modules.txt`. To add more, ask with
AskUserQuestion (multiSelect) offering only modules not yet installed, then:

```bash
bash $SK/scaffold.sh list            # what exists
bash $SK/scaffold.sh add "hive,logging"
```

`add` copies new files (never overwrites — it prints which to merge by
hand), patches `main.dart`/`app.dart`/`app_dio.dart`/`pubspec.yaml` at their
`// @marker` comments, adds deps, re-runs codegen/analyze/test. Keep those
marker comments; they are how later modules plug in. Record the module in
`CLAUDE.md`.

## Before you write — the ladder

Stop at the first rung that works: does it need to exist → does it already
exist here → stdlib → installed package → one line → minimum code. Here:

- "Already here" means `core/ui/atoms`, `core/ui/components`, `core/hooks`,
  `core/extensions`, `core/helpers`, the `RunLoadMixin`/`AppEffectsMixin`
  pair, an existing mapper extension, `BaseResponse<T>`.
- Check `pubspec.yaml` before adding a dependency.
- A screen with no async work needs no view model. A view model with one
  call needs no state class — `AsyncValue<T>` is the state.
- The abstract class in `domain/repositories/` is the data/domain boundary,
  not a speculative interface. Keep it; add no interfaces elsewhere.
- Never lazy about: the `AppError` path (`guard`/`runLoad`), auth
  interceptors, form validation, translated strings.

## Layers

```
lib/data/          data_sources/remote_data_source/api_source/{api,model,interceptors,providers}
                   data_sources/local_data_source/preference_source/{storage,providers,hive,model}
                   mapper/<feature>/ · repositories/<name>_repository_impl/ · util/error/
lib/domain/        model/ · repositories/ · services/ · event/
lib/presentation/  core/{gen,theme,routing,state,mixins,helpers,hooks,ui/{atoms,components,screens}}
                   <feature>/{screens,widgets,view_model,hooks}/
lib/services/      third-party SDK implementations (<vendor>_<name>_service.dart)
lib/flavors/       Environment
```

`presentation → domain ← data`. Presentation imports `data/` only for a
generated repository provider and `data/util/error/app_error.dart`. Domain
imports nothing from `data/`. One type per file; file name = snake_case of
the type; nested models get their own directory
(`model/auth/response/login_response/login_response.dart`).

## The error path (one path, no exceptions)

1. Anything thrown below a view model becomes an `AppError` via
   `AppError.fromException` (`lib/data/util/error/app_error.dart`). New SDK?
   Add one `if (error is XException) return ...;` branch at
   `// @error-mappers` (or a mapper file like `dio_error_mapper.dart`). Its
   `message` is already localized from `t.commonExceptions`.
2. View models never try/catch. `build()` wraps with `guard(...)`
   (`core/helpers/normalize_to_app_error.dart`); actions use `runLoad`.
3. Failures reach the user through `emit(.errorDialog(error))` →
   `dispatch` → `showErrorDialog`, or through `state.when(error:)` →
   `ErrorScreen` for a failed body. `AppErrorType.cancel` is silent.

## Add an endpoint (network module)

1. **DTOs** — freezed + json_serializable, one dir each under
   `api_source/model/<feature>/{body,response}/<name>/<name>.dart`:
   ```dart
   @freezed
   abstract class LoginResponse with _$LoginResponse {
     const factory LoginResponse({
       required String token,
       @JsonKey(name: 'is_verified') required bool isVerified,
     }) = _LoginResponse;
     factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
   }
   ```
   `abstract class X with _$X` (freezed 3). `@JsonKey(name:)` keeps backend
   names out of Dart.
2. **API** — `api_source/api/<feature>_api/<feature>_api.dart`. Endpoint
   paths are top-level consts; methods return `BaseResponse<T>`; plain
   `Provider`, built from a `Ref`:
   ```dart
   const loginEndpoint = '/auth/login';
   final authApiProvider = Provider(AuthApi.new);

   @RestApi()
   abstract class AuthApi {
     factory AuthApi(Ref ref) => _AuthApi(ref.read(appDioProvider));
     @POST(loginEndpoint)
     Future<BaseResponse<LoginResponse>> login(@Body() LoginBody body);
   }
   ```
3. **Domain model** — `domain/model/<feature>/<name>/<name>.dart`:
   `@Freezed(copyWith: false, equal: true, toJson: false, fromJson: false, toStringOverride: true)`.
   Turn a flag on only when something calls it. Unions: `sealed class` +
   `const X._();`, matched with `switch`, not `.when`.
4. **Mapper** — `data/mapper/<feature>/<name>_mapper.dart`:
   `extension XResponseMapper on XResponse { X toX() => ... }`. Conversion
   lives here, never in the repository body or view model.
5. **Repository** — interface `domain/repositories/<name>_repository.dart`
   (abstract, `Future`s, domain types only); impl
   `data/repositories/<name>_repository_impl/<name>_repository_impl.dart`:
   ```dart
   @riverpod
   AuthRepository authRepository(Ref ref) =>
       AuthRepositoryImpl(ref.watch(authApiProvider), ref.watch(sessionProvider));
   ```
   The impl takes **resolved dependencies, never a `Ref`** (callers
   `ref.read` it, the auto-dispose provider dies right after, a stored
   `Ref` then throws `UnmountedRefException`) and is **stateless** (each
   `ref.read` builds a fresh impl).

## Add a view model

`presentation/<feature>/view_model/<name>_vm/<name>_vm.dart`:

```dart
@riverpod
class AccountVm extends _$AccountVm with AppEffectsMixin, RunLoadMixin {
  @override
  FutureOr<Account> build() => guard(ref.read(accountRepositoryProvider).getAccount);

  Future<void> save(Account a) => runLoad(
    action: () => ref.read(accountRepositoryProvider).save(a),
    apply: (s) => state = s,
    onSuccess: (_) => emit(.popAndShowSuccessSnackbar(t.account.saved)),
    onFailure: (e) => emit(.errorDialog(e)),
  );
}
```

- `runLoad` drives loading → data | error, normalizes to `AppError`, and
  toggles the global `loadingStateProvider` (the `ContainerWithLoading`
  overlay) unless `useLoadingProvider: false`.
- `emit` is for one-shot UI (navigate, dialog, snackbar) —
  `core/state/app_effect.dart`. Never fold navigation into state; never a
  `BuildContext` in a view model. New effect kind = new factory in
  `AppEffect` + new `case` in `core/hooks/effects_hooks/dispatch.dart`.
- Dart dot-shorthands (`.data(x)`, `.errorDialog(e)`) are house style.
- `@Riverpod(keepAlive: true)` only for app-lifetime things (router,
  session); say why in a comment.

## Add a screen

1. `presentation/<feature>/screens/<name>_screen.dart`: `@RoutePage()`,
   `HookConsumerWidget`.
2. Register in `core/routing/app_router.dart`; `XRoute` is generated.
3. Observer hook `presentation/<feature>/hooks/use_<name>_observer.dart`:
   ```dart
   AsyncValue<Account> useAccountObserver(WidgetRef ref) {
     useEffectsStream(ref, accountVmProvider); // effects first
     return ref.watch(accountVmProvider);
   }
   ```
   Screens call the hook, never `effects` directly.
4. Wrap in `ContainerWithLoading`; compose from `core/ui/` (`BaseScreen`,
   `Button.primary`, `PrimaryTextfield` + `Validators` with ui_kit).
   Colors/text via `ref.colors` / `ref.textTheme` — no `Color(0x…)` or raw
   `TextStyle` in a screen. Spacing from `AppSpacings`.
5. Hooks are unconditional and top-of-build.

## Services, events, strings, assets, cache

- **Service** (a third-party SDK, not our REST API): interface
  `domain/services/<name>/<name>_service.dart`; impl
  `services/<name>/<vendor>_<name>_service.dart`; plain
  `Provider<XService>(VendorXService.new)`. Services may hold a `Ref`
  (non-auto-dispose provider). Keys come from `Environment`/dart-defines,
  never literals.
- **Global events** (auth module): `eventBus` in `domain/event/event_bus.dart`
  — only for signals with no widget-tree owner (force-logout). Everything
  else is a provider or an `AppEffect`.
- **Strings (slang)**: edit `assets/i18n/en.i18n.json` only; use
  `t.section.key` (import `core/gen/i18n/strings.g.dart`); `useTranslation()`
  in hook widgets for locale reactivity. Params: `"${name}"`.
- **Assets (assets module)**: drop into `assets/<group>/`, list the directory
  in `pubspec.yaml` if new, use `Assets.icons.logo.svg()`. No path strings.
- **Hive (hive module)**: `local_data_source/preference_source/model/<feature>/<name>_cache/<name>_cache.dart`,
  class suffixed `Cache`, freezed JSON off; append to
  `hive/hive_adapters.dart` `@GenerateAdapters([...])` (append only —
  order is type ids). Cache↔domain in `mapper/<feature>/<name>_cache_mapper.dart`.
- **Storage keys**: all in `storage/util/shared_pref_keys.dart`.

## Tests

View model tests: `ProviderContainer(overrides: [xRepositoryProvider.overrideWithValue(mock)])`,
listen to the provider, drive the notifier, assert `state` and collected
`effects` (see `test/home_vm_test.dart`). mocktail for doubles.

## Gotchas

- `dart run build_runner` fails version solving in a Flutter app — use
  `flutter pub run build_runner`.
- `sdk: ^3.11.0` in pubspec is deliberate: at language 3.13, freezed 3.2.5
  emits `final` constructor params the compiler rejects ("Can't have
  modifier 'final' here"). Raise it only together with freezed.
- riverpod_generator, freezed, auto_route_generator, retrofit_generator,
  hive_ce_generator each pin a narrow `analyzer`; bump them together.
- `auto_route` builds its first page asynchronously — widget tests need
  `pumpAndSettle()` before asserting.
- `flutter test` fails with "Building assets for package:objective_c
  failed" when Xcode's license isn't accepted (`path_provider_foundation`
  via hive/ispect/secure storage). Fix: `sudo xcodebuild -license accept`.
- The ISpect inspector only exists with `--dart-define=ISPECT_ENABLED=true`
  (`make run` passes it for non-prod flavors).
- Never give an overlay (loading, blocking sheet) its own `Scaffold`: it
  registers with the `ScaffoldMessenger`, and a snackbar emitted as the load
  finishes attaches to the overlay and vanishes with it. Use `Material`.
- `flutter create .` (e.g. adding a platform) re-adds `test/widget_test.dart`
  referencing `MyApp`. Delete it.
- `git`/`npx skills add` failing with "You have not agreed to the Xcode
  license agreements" is the same license issue: `/usr/bin/git` is an Xcode
  shim.
