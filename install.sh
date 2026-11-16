#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: bash install.sh [--target codex|claude|both] [--home DIR] [--force]"
}
fail() { printf "Error: %s\n" "$*" >&2; exit 1; }
target=both
install_home=$HOME
force=false
while (($#)); do
  case "$1" in
    --target|--home)
      (($# >= 2)) || fail "Missing value for $1"
      if [[ $1 == --target ]]; then target=$2; else install_home=$2; fi
      shift 2 ;;
    --force) force=true; shift ;;
    --help|-h) usage; exit 0 ;;
    *) usage >&2; fail "Unknown option: $1" ;;
  esac
done
case "$target" in codex|claude|both) ;; *) fail "Invalid target: $target" ;; esac
[[ -d $install_home ]] || fail "Home directory must already exist: $install_home"
install_home=$(cd -- "$install_home" && pwd -P)
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
staging=$(mktemp -d)
trap 'rm -rf -- "$staging"' EXIT
sources=()
destinations=()
kinds=()
backups=()
stamp=$(date -u +%Y%m%dT%H%M%SZ)-$$

reject_symlinks() {
  local path=$1
  while [[ $path != / ]]; do
    [[ ! -L $path ]] || fail "Refusing symlink destination: $path"
    path=$(dirname -- "$path")
  done
}

prepare_target() {
  local app=$1 skills instructions src dst staged block skill backup planner_reference mentor_reference
  if [[ $app == codex ]]; then
    skills="$install_home/.agents/skills"
    instructions="$install_home/.codex/AGENTS.md"
    planner_reference="../.agents/skills/study-planner/SKILL.md"
    mentor_reference="../.agents/skills/engineering-mentor/SKILL.md"
  else
    skills="$install_home/.claude/skills"
    instructions="$install_home/.claude/CLAUDE.md"
    planner_reference="skills/study-planner/SKILL.md"
    mentor_reference="skills/engineering-mentor/SKILL.md"
  fi
  for skill in engineering-mentor study-planner; do
    src="$root/skills/$skill"
    dst="$skills/$skill"
    [[ -f $src/SKILL.md ]] || fail "Missing skill: $src"
    reject_symlinks "$(dirname -- "$dst")"
    if [[ -L $dst ]] && [[ $(readlink -- "$dst") == "$src" ]]; then
      continue
    fi
    if [[ -e $dst || -L $dst ]]; then
      [[ ! $dst -ef $src ]] || fail "Destination is the source directory: $dst"
      [[ $force == true ]] || fail "Existing skill destination: $dst. Use --force to back up and replace it with a link."
    fi
    backup="$install_home/.learning-modes-backups/$stamp/$app/$skill"
    reject_symlinks "$backup"
    [[ ! -e $backup ]] || fail "Backup already exists: $backup"
    sources+=("$src")
    destinations+=("$dst")
    kinds+=(link)
    backups+=("$backup")
  done
  # Retire old entrypoints without losing custom files or local data.
  for skill in learn-mode work-mode learning-system software-engineering-mentor; do
    dst="$skills/$skill"
    if [[ -e $dst || -L $dst ]]; then
      [[ $force == true ]] || fail "Legacy skill exists: $dst. Use --force to back up and retire it."
      backup="$install_home/.learning-modes-backups/$stamp/$app/$skill"
      reject_symlinks "$backup"
      [[ ! -e $backup && ! -L $backup ]] || fail "Backup already exists: $backup"
      sources+=("$dst")
      destinations+=("$dst")
      kinds+=(retire)
      backups+=("$backup")
    fi
  done
  reject_symlinks "$instructions"
  [[ ! -e $instructions || -f $instructions ]] || fail "Expected file: $instructions"
  staged="$staging/$app.instructions"
  local input="$staging/$app.input"
  if [[ -f $instructions ]]; then
    sed -e 's/^<!-- learning-modes:start -->$/<!-- engineering-learning-toolkit:start -->/' \
        -e 's/^<!-- learning-modes:end -->$/<!-- engineering-learning-toolkit:end -->/' \
        -e 's/^<!-- software-engineering-mentor:start -->$/<!-- engineering-learning-toolkit:start -->/' \
        -e 's/^<!-- software-engineering-mentor:end -->$/<!-- engineering-learning-toolkit:end -->/' \
        "$instructions" > "$input"
  fi
  block="$staging/$app.block"
  cat > "$block" <<BLOCK
<!-- engineering-learning-toolkit:start -->
# Engineering Learning Toolkit
For study goals, competency gaps, learning resources, or roadmaps, read and apply $planner_reference (relative to this file).
For guided engineering practice, implementation planning, or code and commit review, read and apply $mentor_reference (relative to this file).
Continue the mentor through the ongoing practice session; repeated activation commands are unnecessary. Preserve the mentoring intent and next step in compaction summaries.
<!-- engineering-learning-toolkit:end -->
BLOCK
  if [[ -f $instructions ]]; then
    # Validate markers before writing either target. Replace only the managed block.
    awk '
      $0 == "<!-- engineering-learning-toolkit:start -->" { if (inside || seen++) exit 1; inside=1 }
      $0 == "<!-- engineering-learning-toolkit:end -->" { if (!inside) exit 1; inside=0 }
      END { if (inside) exit 1 }
    ' "$input" || fail "Malformed managed block in $instructions"
    awk -v block="$block" '
      function emit() { while ((getline line < block) > 0) print line; close(block) }
      $0 == "<!-- engineering-learning-toolkit:start -->" { emit(); inside=1; seen=1; next }
      $0 == "<!-- engineering-learning-toolkit:end -->" { inside=0; next }
      !inside { print }
      END { if (!seen) { if (NR) print ""; emit() } }
    ' "$input" > "$staged"
  else
    cp -- "$block" "$staged"
  fi
  sources+=("$staged")
  destinations+=("$instructions")
  kinds+=(file)
  backups+=("$instructions.backup-$stamp")
}

if [[ $target == both ]]; then
  prepare_target codex
  prepare_target claude
else
  prepare_target "$target"
fi

# Validate all memory paths before changing any installation target.
memory="$install_home/.software-engineering-mentor"
for path in "$memory" "$memory/archive" "$memory/learning-profile.md" "$memory/progress.md" "$memory/archive/legacy-learning-modes.md"; do
  reject_symlinks "$path"
done
[[ ! -e $memory || -d $memory ]] || fail "Expected directory: $memory"
[[ ! -e $memory/archive || -d $memory/archive ]] || fail "Expected archive directory"
for name in learning-profile.md progress.md; do
  [[ -f $root/skills/engineering-mentor/assets/$name ]] || fail "Missing template: $name"
  [[ ! -e $memory/$name || -f $memory/$name ]] || fail "Expected memory file: $name"
done
legacy="$install_home/.learning-modes/progress.md"
if [[ -e $legacy ]]; then
  [[ -f $legacy ]] || fail "Expected legacy progress file: $legacy"
fi
mkdir -p -- "$memory/archive"
if [[ -f $legacy && ! -e $memory/archive/legacy-learning-modes.md ]]; then
  cp -p -- "$legacy" "$memory/archive/legacy-learning-modes.md"
fi
for name in learning-profile.md progress.md; do
  if [[ ! -e $memory/$name ]]; then
    cp -- "$root/skills/engineering-mentor/assets/$name" "$memory/$name"
  fi
done

for ((i=0; i<${#sources[@]}; i++)); do
  src=${sources[i]}
  dst=${destinations[i]}
  if [[ ${kinds[i]} == link || ${kinds[i]} == retire ]]; then
    mkdir -p -- "$(dirname -- "$dst")"
    if [[ -e $dst || -L $dst ]]; then
      backup=${backups[i]}
      mkdir -p -- "$(dirname -- "$backup")"
      mv -- "$dst" "$backup"
      printf "Backed up %s to %s\n" "$dst" "$backup"
    fi
    [[ ${kinds[i]} != retire ]] || continue
    ln -s -- "$src" "$dst"
    printf "Linked %s to %s\n" "$dst" "$src"
  else
    if [[ -f $dst ]] && cmp -s -- "$src" "$dst"; then continue; fi
    mkdir -p -- "$(dirname -- "$dst")"
    if [[ -f $dst ]]; then
      backup=${backups[i]}
      [[ ! -e $backup ]] || fail "Backup already exists: $backup"
      cp -p -- "$dst" "$backup"
      printf "Backed up %s to %s\n" "$dst" "$backup"
    fi
    cp -- "$src" "$dst"
    printf "Installed %s\n" "$dst"
  fi
done
printf "Done. Start a new conversation to load the learning toolkit.\n"
