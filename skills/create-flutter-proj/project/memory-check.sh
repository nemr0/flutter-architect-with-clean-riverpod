#!/usr/bin/env bash
# Stop hook: keeps CLAUDE.md (the project memory) in sync with the code.
# If hand-written source changed after CLAUDE.md was last written, block the
# stop once and tell Claude to update it. Generated files don't count.
input=$(cat)
echo "$input" | grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
[ -f CLAUDE.md ] || exit 0

changed=$(find lib test assets pubspec.yaml -type f -newer CLAUDE.md \
  ! -name '*.g.dart' ! -name '*.freezed.dart' ! -name '*.gr.dart' ! -name '*.gen.dart' \
  2>/dev/null | head -15 | tr '\n' ' ' | sed 's/["\\]//g')
[ -z "$changed" ] && exit 0

printf '{"decision":"block","reason":"Project memory is stale. These files changed after CLAUDE.md was last updated: %s. Update the matching CLAUDE.md sections (Features table, Data sources, Decisions, Gotchas) with what a future session needs to know, and bump the Last synced date. If nothing memory-worthy changed, just bump Last synced."}\n' "$changed"
