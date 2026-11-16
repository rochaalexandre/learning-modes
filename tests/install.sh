#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT
test_home="$scratch/home with spaces"
mkdir -p -- "$test_home"
install() { bash "$root/install.sh" --home "$test_home" "$@" > "$scratch/output" 2>&1; }
fail() { printf 'FAIL: %s\n' "$*" >&2; cat "$scratch/output" >&2; exit 1; }
expect_failure() { if install "$@"; then fail "Expected installation failure"; fi; }

install --target both || fail "Fresh installation"
for app in .agents .claude; do
  [[ -L $test_home/$app/skills/software-engineering-mentor ]] || fail "Missing skill link"
done
memory="$test_home/.software-engineering-mentor"
[[ -d $memory/archive ]] || fail "Missing archive"
cmp "$memory/progress.md" "$root/skills/software-engineering-mentor/assets/progress.md"
printf 'Personal preference\n' > "$memory/learning-profile.md"
printf 'Active evidence\n' > "$memory/progress.md"
printf 'Historical evidence\n' > "$memory/archive/cycle.md"
cp "$test_home/.codex/AGENTS.md" "$scratch/startup"
install --target both --force || fail "Repeat installation"
cmp "$scratch/startup" "$test_home/.codex/AGENTS.md"
[[ $(cat "$memory/learning-profile.md") == 'Personal preference' ]] || fail "Profile overwritten"
[[ $(cat "$memory/progress.md") == 'Active evidence' ]] || fail "Progress overwritten"
[[ $(cat "$memory/archive/cycle.md") == 'Historical evidence' ]] || fail "Archive overwritten"

mkdir -p "$test_home/.learning-modes" "$test_home/.agents/skills/learn-mode"
printf 'Legacy evidence\n' > "$test_home/.learning-modes/progress.md"
printf 'Custom legacy instructions\n' > "$test_home/.agents/skills/learn-mode/custom.md"
cat > "$test_home/.codex/AGENTS.md" <<'BLOCK'
User instruction before
<!-- learning-modes:start -->
Old mode instructions
<!-- learning-modes:end -->
User instruction after
BLOCK
expect_failure --target both
[[ -f $test_home/.agents/skills/learn-mode/custom.md ]] || fail "Changed before preflight completed"
install --target both --force || fail "Legacy migration"
[[ ! -e $test_home/.agents/skills/learn-mode ]] || fail "Legacy skill still active"
[[ $(find "$test_home/.learning-modes-backups" -name custom.md | wc -l | tr -d ' ') == 1 ]] || fail "Missing legacy backup"
cmp "$test_home/.learning-modes/progress.md" "$memory/archive/legacy-learning-modes.md"
[[ $(cat "$memory/progress.md") == 'Active evidence' ]] || fail "Migration overwrote active memory"
[[ $(head -n 1 "$test_home/.codex/AGENTS.md") == 'User instruction before' ]] || fail "Lost unmanaged prefix"
[[ $(tail -n 1 "$test_home/.codex/AGENTS.md") == 'User instruction after' ]] || fail "Lost unmanaged suffix"
printf 'Later legacy edit\n' > "$test_home/.learning-modes/progress.md"
install --target both --force || fail "Migration rerun"
[[ $(cat "$memory/archive/legacy-learning-modes.md") == 'Legacy evidence' ]] || fail "Replaced legacy archive"

cp "$test_home/.codex/AGENTS.md" "$scratch/startup"
printf '<!-- software-engineering-mentor:start -->\n' > "$test_home/.claude/CLAUDE.md"
expect_failure --target both --force
cmp "$scratch/startup" "$test_home/.codex/AGENTS.md"
printf '<!-- learning-modes:start -->\n<!-- learning-modes:end -->\n<!-- software-engineering-mentor:start -->\n<!-- software-engineering-mentor:end -->\n' > "$test_home/.claude/CLAUDE.md"
expect_failure --target both --force
cmp "$scratch/startup" "$test_home/.codex/AGENTS.md"
rm "$test_home/.claude/CLAUDE.md"

mv "$memory/progress.md" "$scratch/personal-progress"
ln -s "$scratch/personal-progress" "$memory/progress.md"
expect_failure --target codex --force
[[ $(cat "$scratch/personal-progress") == 'Active evidence' ]] || fail "Modified symlink target"
rm "$memory/progress.md"
mv "$scratch/personal-progress" "$memory/progress.md"

test_home="$scratch/codex-only"
mkdir "$test_home"
install --target codex || fail "Codex-only installation"
[[ ! -e $test_home/.claude ]] || fail "Installed unselected agent"
rm "$test_home/.agents/skills/software-engineering-mentor"
mkdir "$test_home/.agents/skills/software-engineering-mentor"
printf 'Custom skill\n' > "$test_home/.agents/skills/software-engineering-mentor/custom.md"
expect_failure --target codex
install --target codex --force || fail "Conflict backup"
[[ $(find "$test_home/.learning-modes-backups" -name custom.md | wc -l | tr -d ' ') == 1 ]] || fail "Missing conflict backup"
expect_failure --target invalid
printf 'All installer tests passed.\n'
