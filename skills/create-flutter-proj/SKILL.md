---
name: create-flutter-proj
description: Create a new Flutter app on the clean-riverpod architecture — data/domain/presentation layers, AppError + guard/runLoad error handling, AppEffect one-shot UI effects, riverpod_generator + flutter_hooks state management, freezed models, slang i18n, auto_route — with a picker for optional modules (networking, auth session, storage, hive, flavors, debug inspector, assets codegen, UI kit). Installs the official dart-lang and flutter agent skills and a self-updating CLAUDE.md project memory. Use when asked to create, scaffold, start, or bootstrap a new Flutter project/app.
---

Scaffolds with `scaffold.sh` (next to this file), which ends green: codegen,
`flutter analyze` with no issues, tests passing. For changes after creation, use
`edit-flutter-proj`.

## 1. Gather inputs

From the arguments or the conversation: **app name** (snake_case package
name), **org** (reverse domain, e.g. `com.acme`), **display title**, and
**parent directory** (default: the current directory). Ask in one plain
chat message only for what's missing. Don't guess the org.

## 2. The picker

`core` is always installed: layers, freezed, riverpod_generator, hooks,
auto_route, slang, the AppError/guard/runLoad/AppEffect path, loading overlay,
error dialog/screen, light/dark theme tokens, and a sample home feature with tests.

Ask with **one AskUserQuestion call, two multiSelect questions**:

1. header `Data layer`, question "Which data-layer modules should the app include?"
   - `network`: Networking — dio + retrofit, `BaseResponse<T>`, DioException → AppError, example endpoint
   - `auth`: Auth session — secure token storage, bearer + single-flight refresh interceptor, force-logout event (adds network + storage)
   - `storage`: Local storage — `KeyValueStorage` over shared_preferences + flutter_secure_storage
   - `hive`: Hive cache — hive_ce boxes, `@GenerateAdapters` registry, `*Cache` models
2. header `Shell & UI`, question "Which app-shell and UI modules should the app include?"
   - `flavors`: Flavors — dev/staging/prod `.env.<flavor>` + `Environment` + Makefile
   - `logging`: Debug inspector — ISpect logs, Riverpod/Dio/navigation inspectors (non-prod only)
   - `assets`: Assets codegen — flutter_gen `Assets.*`, flutter_svg, lottie
   - `ui_kit`: UI kit — BaseScreen, Button variants, PrimaryTextfield + Validators, confirm dialog/sheet

Map the labels back to the ids in backticks. If the user answers "Other" with
free text, map what they wrote to module ids. If they want none, pass `""`.

## 3. Scaffold

```bash
cd <parent dir>
bash <this skill's directory>/scaffold.sh new <app_name> <org> "<ids, comma-separated>" "<Title>"
```

Use a 10-minute timeout. It runs `flutter create` (ios, android); writes the
module files; patches them together at `// @marker` comments; pins deps; installs
the dart-lang + flutter agent skills (`npx skills add … --agent universal`,
symlinked from `.agents/skills` into `.claude/skills` so Claude Code finds them);
writes `CLAUDE.md` plus the Stop hook that keeps it current; runs `git init`,
build_runner, analyze, and test. Pass `--no-skills` when offline.

If it fails partway, read the failing step's output, fix the cause (usually a
dep resolution or a missing marker), and re-run the remaining steps by hand
from inside the project (`scaffold.sh add` is idempotent for patches). Don't
delete the directory unless the user agrees.

## 4. Finish

1. Fill `CLAUDE.md` → "What this app is" from what the user told you.
2. Report: the path, the installed modules, analyze/test results, and the
   next command for each installed module (`make run FLAVOR=dev` with
   flavors; set `NETWORK_BASE_URL` in `.env.*`; with auth, replace the TODO
   endpoints in `auth_api.dart` and the TODO route in `session_redirect.dart`).

## Known environment traps

- `flutter test` fails with "Building assets for package:objective_c failed"
  when Xcode's license isn't accepted. It affects any module that pulls in
  `path_provider` (storage, auth, hive, logging). The user must run
  `sudo xcodebuild -license accept`; never run it for them. Analyze still works.
- `sdk: ^3.11.0` is pinned on purpose (freezed 3.2.5 + language 3.13 emits
  code the compiler rejects). Don't "fix" it.
