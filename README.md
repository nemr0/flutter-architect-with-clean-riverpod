# flutter-architect-with-clean-riverpod

Two Claude Code skills that create and maintain Flutter apps on one
architecture: **clean-riverpod**. That means layered data / domain /
presentation, Riverpod-generated view models, and a single error path.

| Skill | Command | Does |
|---|---|---|
| `create-flutter-proj` | `/create-flutter-proj` | Picks modules, scaffolds the app, installs the official dart-lang + flutter agent skills, writes a self-updating `CLAUDE.md`. Ends green: analyzer clean, tests passing. |
| `edit-flutter-proj` | `/edit-flutter-proj` | The architecture rules, recipes (endpoint, view model, screen, service, cache), `add` for more modules, `adopt` for existing apps, `verify.sh`. |

## The architecture

```
presentation ──▶ domain ◀── data
 screens (HookConsumerWidget, @RoutePage)
   └─ use_x_observer hook ── useEffectsStream + ref.watch
        └─ XVm (@riverpod, AppEffectsMixin + RunLoadMixin)
             └─ XRepository (domain interface) ◀─ XRepositoryImpl (data)
                  └─ retrofit API ─ DTO (freezed+json) ─ mapper ─ domain model (freezed)
```

- **One error path.** Everything thrown below a view model becomes an
  `AppError` (`AppError.fromException`, with one branch per SDK). Its
  message is already localized. View models never try/catch: `guard()` in
  `build()`, `runLoad()` in actions.
- **State vs effects.** State is the notifier's `AsyncValue<T>`. One-shot UI
  such as navigation, dialogs and snackbars goes out as `emit(AppEffect…)`,
  and a single `dispatch` function turns it into widgets. View models never
  touch `BuildContext`.
- **Global loading.** `runLoad` toggles `loadingStateProvider`, and
  `ContainerWithLoading` shows the overlay.
- **Freezed everywhere, with explicit flags.** DTOs use `@freezed` plus JSON.
  Domain models use `@Freezed(copyWith: false, toJson: false, fromJson: false, …)`.
  Hive caches use `*Cache` with JSON off.
- **Codegen.** riverpod_generator, freezed, json_serializable, retrofit,
  auto_route, slang, flutter_gen, hive_ce, all with pinned versions that
  co-resolve.

## Modules (the picker)

`core` is always included. Optional modules:

| id | Adds |
|---|---|
| `network` | dio + retrofit, `BaseResponse<T>`, DioException → AppError, example endpoint |
| `auth` | secure token storage, bearer + single-flight refresh interceptor, force-logout event (pulls in `network`, `storage`) |
| `storage` | `KeyValueStorage` over shared_preferences + flutter_secure_storage |
| `hive` | hive_ce boxes, `@GenerateAdapters` registry |
| `flavors` | dev/staging/prod via `.env.<flavor>` + `--dart-define`, `Environment`, Makefile |
| `logging` | ISpect inspector: logs, Riverpod/Dio/navigation (non-prod only) |
| `assets` | flutter_gen `Assets.*`, flutter_svg, lottie |
| `ui_kit` | BaseScreen, Button variants, PrimaryTextfield + Validators, confirm dialog/sheet |

Modules plug into each other at `// @marker` comments, so you can add one
later with `scaffold.sh add "<ids>"`.

## Project memory

Each project gets a `CLAUDE.md` covering what the app is, its features,
data sources, decisions and gotchas. A Stop hook
(`.claude/hooks/memory-check.sh`) blocks a Claude session from ending when
hand-written files in `lib/`, `test/`, `assets/` or `pubspec.yaml` changed
after `CLAUDE.md` did, so the memory stays current. Generated files are
ignored.

## Install

Install both skills for your user with the [`skills`](https://www.npmjs.com/package/skills) CLI:

```bash
npx skills add nemr0/flutter-architect-with-clean-riverpod -g -a claude-code -s '*' -y
```

Then, in Claude Code: `/create-flutter-proj` for a new app, or
`/edit-flutter-proj` inside an existing one.

Update to the latest version:

```bash
npx skills update -g -y
```

Remove:

```bash
npx skills remove -g create-flutter-proj edit-flutter-proj -y
```

Install both skills, not just one: `edit-flutter-proj` calls
`create-flutter-proj/scaffold.sh` from the sibling directory. For other
agents, change `-a claude-code` (or pass `-a '*'`). Drop `-g` to install into
the current project instead.

## Requirements

- Flutter 3.38+ (tested on 3.47.4 / Dart 3.13), `python3`, `perl`, `node`
  (for `npx skills`).
- macOS: accept the Xcode license (`sudo xcodebuild -license accept`).
  Without it, `git` and `flutter test` fail for modules that pull in
  `path_provider`.
- Generated projects pin `sdk: ^3.11.0` on purpose. At language 3.13,
  freezed 3.2.5 emits code the compiler rejects.

## License

MIT — see [LICENSE](LICENSE).
