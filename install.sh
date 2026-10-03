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
  local app=$1 skills instructions src dst staged block skill backup reference native_commands
  if [[ $app == codex ]]; then
    skills="$install_home/.agents/skills"
    instructions="$install_home/.codex/AGENTS.md"
    reference="Read and apply ../.agents/skills/learning-system/SKILL.md (relative to this AGENTS.md file)."
    native_commands='Codex also accepts native $learn-mode and $work-mode skill mentions.'
  else
    skills="$install_home/.claude/skills"
    instructions="$install_home/.claude/CLAUDE.md"
    reference="@skills/learning-system/SKILL.md"
    native_commands=""
  fi
  for skill in learn-mode work-mode learning-system; do
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
  reject_symlinks "$instructions"
  [[ ! -e $instructions || -f $instructions ]] || fail "Expected file: $instructions"
  staged="$staging/$app.instructions"
  block="$staging/$app.block"
  cat > "$block" <<BLOCK
<!-- learning-modes:start -->
# Learning and working modes
At the start of a fresh conversation, default to Learning Mode.

$reference

Keep the current conversation mode until I explicitly switch. Recognize /learn-mode or LEARNING MODE and /work-mode or WORKING MODE. $native_commands
Do not reset the mode because a task changes or a skill reloads. Preserve the current mode in compaction summaries.
<!-- learning-modes:end -->
BLOCK
  if [[ -f $instructions ]]; then
    # Validate markers before writing either target. Replace only the managed block.
    awk '
      $0 == "<!-- learning-modes:start -->" { if (inside || seen++) exit 1; inside=1 }
      $0 == "<!-- learning-modes:end -->" { if (!inside) exit 1; inside=0 }
      END { if (inside) exit 1 }
    ' "$instructions" || fail "Malformed managed block in $instructions"
    awk -v block="$block" '
      function emit() { while ((getline line < block) > 0) print line; close(block) }
      $0 == "<!-- learning-modes:start -->" { emit(); inside=1; seen=1; next }
      $0 == "<!-- learning-modes:end -->" { inside=0; next }
      !inside { print }
      END { if (!seen) { if (NR) print ""; emit() } }
    ' "$instructions" > "$staged"
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

for ((i=0; i<${#sources[@]}; i++)); do
  src=${sources[i]}
  dst=${destinations[i]}
  if [[ ${kinds[i]} == link ]]; then
    mkdir -p -- "$(dirname -- "$dst")"
    if [[ -e $dst || -L $dst ]]; then
      backup=${backups[i]}
      mkdir -p -- "$(dirname -- "$backup")"
      mv -- "$dst" "$backup"
      printf "Backed up %s to %s\n" "$dst" "$backup"
    fi
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
printf "Done. Start a new conversation to load the skills and default mode.\n"
