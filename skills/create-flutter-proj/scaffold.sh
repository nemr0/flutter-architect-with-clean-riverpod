#!/usr/bin/env bash
# clean-riverpod Flutter scaffolder.
#
#   scaffold.sh new   <app_name> <org> "<modules>" ["App Title"] [--no-skills]
#   scaffold.sh add   "<modules>"          # run in project root
#   scaffold.sh adopt [--no-skills]        # existing project: memory + hook + skills only
#   scaffold.sh list                       # print modules
#
# <modules> is comma/space separated. `core` is always included; dependencies
# are pulled in automatically (auth -> network,storage).
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SKILL_DIR/modules"
ORDER=(core storage network auth hive flavors logging assets ui_kit)

die() { echo "error: $*" >&2; exit 1; }

resolve_modules() { # expands deps, returns ORDER-sorted unique list
  local want=" core $(echo "$1" | tr ',' ' ') " changed=1 m r
  while [ $changed = 1 ]; do
    changed=0
    for m in $want; do
      [ -d "$MODULES_DIR/$m" ] || die "unknown module '$m' (see: scaffold.sh list)"
      [ -f "$MODULES_DIR/$m/requires" ] || continue
      for r in $(cat "$MODULES_DIR/$m/requires"); do
        case "$want" in *" $r "*) ;; *) want="$want$r "; changed=1 ;; esac
      done
    done
  done
  for m in "${ORDER[@]}"; do case "$want" in *" $m "*) echo "$m" ;; esac; done
}

app_name() { awk '/^name:/{print $2; exit}' pubspec.yaml; }

copy_files() { # module -> copies files/ into cwd, substituting placeholders
  local m=$1 src="$MODULES_DIR/$1/files" app title f rel
  [ -d "$src" ] || return 0
  app=$(app_name); title=${APP_TITLE:-$app}
  (cd "$src" && find . -type f) | while read -r f; do
    rel=${f#./}
    if [ -n "${NO_CLOBBER:-}" ] && [ -e "$rel" ]; then
      echo "   skip existing $rel (merge by hand from $src/$rel)"; continue
    fi
    mkdir -p "$(dirname "$rel")"
    sed -e "s/__APP__/$app/g" -e "s/__APP_TITLE__/$title/g" "$src/$rel" > "$rel"
  done
}

apply_patches() { # module -> inserts snippets above `// @marker` lines
  local p="$MODULES_DIR/$1/patches"
  [ -f "$p" ] || return 0
  APP=$(app_name) python3 - "$p" <<'PY'
# Patch file format — a header line, then the text to insert:
#   @@ <path> <marker>    insert text above the `// <marker>` (or `# <marker>`) line
#   @@ <path> <marker>!   replace the line right after the marker line
#   @@ <path> +           append to the end of the file
#   @@? ...               same, but skip silently when <path> doesn't exist
#                         (patches into another optional module's files)
# Markers stay in place so later `add` runs can patch again; re-runs are no-ops.
import os, re, sys
app = os.environ["APP"]
blocks, cur = [], None
for line in open(sys.argv[1]).read().replace("__APP__", app).splitlines(keepends=True):
    m = re.match(r"^@@(\??) (\S+) (\S+)\s*$", line)
    if m:
        cur = [m.group(1) == "?", m.group(2), m.group(3), ""]; blocks.append(cur)
    elif cur is not None:
        cur[3] += line
for optional, path, marker, text in blocks:
    if not os.path.exists(path):
        if optional: continue
        sys.exit(f"patch: {path} missing — apply by hand:\n{text}")
    src = open(path).read()
    if text.strip() and text.strip() in src:  # idempotent re-run
        continue
    if marker == "+":
        src = src.rstrip("\n") + "\n" + text
    else:
        replace = marker.endswith("!")
        name = marker.rstrip("!")
        hit = re.search(r"^[ \t]*(//|#) " + re.escape(name) + r"\b.*\n", src, re.M)
        if not hit:
            sys.exit(f"patch: marker '{name}' not found in {path} — apply by hand:\n{text}")
        if replace:
            nxt = src.index("\n", hit.end()) + 1
            src = src[:hit.end()] + text + src[nxt:]
        else:
            src = src[:hit.start()] + text + src[hit.start():]
    open(path, "w").write(src)
PY
}

add_deps() { # module -> flutter pub add from deps.txt
  local d="$MODULES_DIR/$1/deps.txt" line deps=() dev=()
  [ -f "$d" ] || return 0
  while IFS= read -r line; do
    case "$line" in ''|\#*) continue ;; dev:*) dev+=("${line#dev:}") ;; *) deps+=("$line") ;; esac
  done < "$d"
  [ ${#deps[@]} -eq 0 ] || flutter pub add "${deps[@]}"
  [ ${#dev[@]} -eq 0 ] || flutter pub add "${dev[@]/#/dev:}"
}

install_modules() {
  local mods=("$@") m
  for m in "${mods[@]}"; do echo "==> files: $m"; copy_files "$m"; done
  for m in "${mods[@]}"; do apply_patches "$m"; done
  for m in "${mods[@]}"; do echo "==> deps: $m"; add_deps "$m"; done
  mkdir -p .claude
  touch .claude/modules.txt
  { cat .claude/modules.txt; printf '%s\n' "${mods[@]}"; } | awk 'NF && !seen[$0]++' > .claude/modules.tmp
  mv .claude/modules.tmp .claude/modules.txt
}

install_memory() { # CLAUDE.md (if missing) + Stop hook
  local app title mods
  app=$(app_name); title=${APP_TITLE:-$app}
  mods=$(tr '\n' ' ' < .claude/modules.txt 2>/dev/null || true)
  mkdir -p .claude/hooks
  # verify.sh ships in the sibling edit-flutter-proj skill; a project copy
  # keeps the project runnable wherever the skills were installed.
  cp "$SKILL_DIR/../edit-flutter-proj/verify.sh" .claude/verify.sh 2>/dev/null ||
    echo "NOTE: edit-flutter-proj not installed next to this skill — no .claude/verify.sh"
  cp "$SKILL_DIR/project/memory-check.sh" .claude/hooks/memory-check.sh
  chmod +x .claude/hooks/memory-check.sh
  if [ -f .claude/settings.json ]; then
    grep -q memory-check.sh .claude/settings.json ||
      echo "NOTE: merge the Stop hook from $SKILL_DIR/project/settings.json into .claude/settings.json by hand"
  else
    cp "$SKILL_DIR/project/settings.json" .claude/settings.json
  fi
  if [ ! -f CLAUDE.md ]; then
    sed -e "s/__APP__/$app/g" -e "s/__APP_TITLE__/$title/g" \
        -e "s/__MODULES__/${mods:-none (adopted project)}/" -e "s/__DATE__/$(date +%F)/" \
        "$SKILL_DIR/project/CLAUDE.md.tmpl" > CLAUDE.md
  fi
}

install_flutter_skills() { # dart-lang + flutter official skills, exposed to Claude Code
  # Non-fatal: the app is fine without them; re-run `scaffold.sh adopt` later.
  local repo
  for repo in dart-lang/skills flutter/agent-plugins; do
    npx -y skills add "$repo" --skill '*' --agent universal --yes >.claude/skills-install.log 2>&1 ||
      { echo "WARN: skills install from $repo failed:"; grep -iE 'fail|error' .claude/skills-install.log | head -3; }
  done
  rm -f .claude/skills-install.log
  [ -d .agents/skills ] || return 0
  # `--agent universal` writes to .agents/skills, which Claude Code doesn't scan.
  mkdir -p .claude/skills
  local s
  for s in .agents/skills/*/; do
    s=${s%/}; s=${s##*/}
    [ -e ".claude/skills/$s" ] || ln -s "../../.agents/skills/$s" ".claude/skills/$s"
  done
  echo "==> linked $(ls .agents/skills | wc -l | tr -d ' ') dart/flutter skills into .claude/skills"
}

codegen_and_check() {
  flutter pub run build_runner build
  flutter analyze
  flutter test
}

cmd=${1:-}; shift || true
skills=1 args=()
for a in "$@"; do if [ "$a" = --no-skills ]; then skills=0; else args+=("$a"); fi; done
set -- "${args[@]+"${args[@]}"}"

case "$cmd" in
  list)
    for m in "${ORDER[@]}"; do printf '%-9s %s\n' "$m" "$(head -1 "$MODULES_DIR/$m/about" 2>/dev/null)"; done ;;
  new)
    name=${1:?app_name}; org=${2:?org}; APP_TITLE=${4:-$name}; export APP_TITLE
    mods=($(resolve_modules "${3:-}"))
    [ -e "$name" ] && die "$name already exists"
    flutter create --org "$org" --project-name "$name" --platforms ios,android "$name"
    cd "$name"
    rm -f test/widget_test.dart
    # Language 3.13 makes freezed 3.2.5 emit `final` ctor params the compiler
    # rejects. 3.11 is known-good; raise it with the codegen stack.
    sed -i '' -E 's/^  sdk: .*/  sdk: ^3.11.0/' pubspec.yaml
    # Anchor for modules that add to the `flutter:` section (assets, fonts).
    perl -0pi -e 's/^  uses-material-design: true\n/  uses-material-design: true\n  # \@flutter-section\n/m' pubspec.yaml
    install_modules "${mods[@]}"
    install_memory
    [ $skills = 1 ] && install_flutter_skills
    git init -q 2>/dev/null || true
    codegen_and_check
    echo; echo "Created $name with modules: ${mods[*]}" ;;
  add)
    [ -f pubspec.yaml ] || die "run from the project root"
    APP_TITLE=$(sed -n '1s/^# \(.*\) — project memory$/\1/p' CLAUDE.md 2>/dev/null); export APP_TITLE
    have=$(cat .claude/modules.txt 2>/dev/null || true)
    new=()
    for m in $(resolve_modules "${1:?modules}"); do
      grep -qx "$m" <<<"$have" || new+=("$m")
    done
    [ ${#new[@]} -eq 0 ] && { echo "nothing to add"; exit 0; }
    grep -qx core <<<"$have" || [ " ${new[*]} " = " core " ] ||
      echo "WARN: this project wasn't scaffolded with core — patches may not find their markers"
    NO_CLOBBER=1 install_modules "${new[@]}"
    codegen_and_check
    echo; echo "Added: ${new[*]}" ;;
  adopt)
    [ -f pubspec.yaml ] || die "run from the project root"
    install_memory
    [ $skills = 1 ] && install_flutter_skills
    echo "Adopted. Now fill CLAUDE.md from the codebase." ;;
  *) sed -n '2,10p' "$0"; exit 1 ;;
esac
