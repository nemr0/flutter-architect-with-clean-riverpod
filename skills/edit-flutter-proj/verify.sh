#!/usr/bin/env bash
# Codegen -> analyze (against a baseline) -> test. Run from the project root
# after ANY edit that touches an annotated file, i18n JSON, or pubspec assets.
#   verify.sh            verify; exits non-zero on regression
#   verify.sh --watch    build_runner watch, for iterating
#   verify.sh --accept   record the current analyze count as the baseline
set -uo pipefail
[ -f pubspec.yaml ] || { echo "run from the Flutter project root" >&2; exit 2; }

BASELINE=.claude/analyze-baseline.txt

if [ "${1:-}" = "--watch" ]; then
  exec flutter pub run build_runner watch --delete-conflicting-outputs
fi

fail=0

echo "==> build_runner"
# `dart run build_runner` fails version solving in a Flutter app — always
# `flutter pub run`. A stale .dart_tool can die with "InvalidOutputException
# ... Asset already exists" (slang output collision); one retry clears it.
if ! flutter pub run build_runner build --delete-conflicting-outputs 2>&1 | tail -3; then
  echo "==> build_runner failed, retrying once"
  flutter pub run build_runner build --delete-conflicting-outputs 2>&1 | tail -5 || fail=1
fi

if git rev-parse --git-dir >/dev/null 2>&1 &&
   ! git diff --quiet -- '*.g.dart' '*.freezed.dart' '*.gr.dart' '*.gen.dart'; then
  echo "==> generated files changed — commit them with the source:"
  git diff --name-only -- '*.g.dart' '*.freezed.dart' '*.gr.dart' '*.gen.dart'
fi

echo "==> flutter analyze"
analyze=$(flutter analyze 2>&1)
echo "$analyze" | tail -20
count=$(echo "$analyze" | grep -oE '[0-9]+ issues? found' | grep -oE '[0-9]+')
count=${count:-0}

if [ "${1:-}" = "--accept" ]; then
  mkdir -p .claude && echo "$count" > "$BASELINE"
  echo "==> analyze baseline set to $count"
else
  # No baseline file = a scaffolded project, which starts clean.
  baseline=$(cat "$BASELINE" 2>/dev/null || echo 0)
  echo "==> analyze: $count issue(s), baseline $baseline"
  if [ "$count" -gt "$baseline" ]; then
    echo "==> REGRESSION: $((count - baseline)) new issue(s). Fix them (never --accept to hide your own)."
    fail=1
  fi
fi

echo "==> flutter test"
flutter test 2>&1 | tail -10 || fail=1

[ $fail = 0 ] && echo "==> OK"
exit $fail
