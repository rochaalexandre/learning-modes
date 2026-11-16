# Software Engineering Mentor

A practical mentor for Codex and Claude Code that develops independent reasoning through real software work across repositories. One skill supports roadmap planning, decomposition, design, pair programming, code and commit review, and technical communication.

The mentor starts with concrete examples, uses experiments and feedback, and introduces concepts and vocabulary in context. The learner implements by default; explicitly ask for implementation when you want the agent to edit code. Explanations remain available without completing an exercise. When an approach stops helping, the mentor switches to a smaller demonstration or hands-on debugging.

## Install and initialize

Requires Bash and standard Unix utilities; no runtime package dependencies.

```sh
git clone https://github.com/rochaalexandre/learning-modes.git
cd learning-modes
bash install.sh --target both
```

Use `--target codex` or `--target claude` for one agent. `--home DIR` selects an existing alternate home for testing or provisioning; it does not change the home resolved by a running agent.

| Agent | Skill link | Startup instructions |
|---|---|---|
| Codex | `~/.agents/skills/software-engineering-mentor` | `~/.codex/AGENTS.md` |
| Claude Code | `~/.claude/skills/software-engineering-mentor` | `~/.claude/CLAUDE.md` |

The installer links the skill to this checkout, adds a conditional mentor pointer to startup instructions, and initializes missing local memory files. Startup content outside the managed block is retained, with a backup when changed. Keep the checkout at a stable location and start a new conversation after installation.

For manual installation, place `skills/software-engineering-mentor/` in your agent's skills directory. The skill describes how to initialize memory if the installer was skipped.

## Use

Invoke `$software-engineering-mentor` in Codex or `/software-engineering-mentor` in Claude Code, followed by a request. The skill can also be selected for a mentoring request through its description and installed startup pointer.

```text
Help me plan one small feature before I implement it.
Review this commit and help me reason about the responsibilities in this class.
Show a smaller example of this execution flow, then let me experiment.
Help me turn this code concern into a precise review comment.
Plan a practical roadmap toward designing services.
Implement the agreed change and explain the important trade-off.
```

Open any project and bring a requirement, code change, or failing test. There is no mode to switch. Assistance adapts to your request and observed progress.

## Reusable files and personal memory

The version-controlled [skill](skills/software-engineering-mentor/SKILL.md), [memory guidance](skills/software-engineering-mentor/references/memory.md), and [templates](skills/software-engineering-mentor/assets/) contain reusable guidance and unassessed defaults.

Personal data lives only on your machine:

```text
~/.software-engineering-mentor/
├── learning-profile.md
├── progress.md
└── archive/
```

Edit `learning-profile.md` to change durable preferences. Installation and updates preserve existing files. Initial progress focuses on software planning and decomposition, software design, and technical communication. The mentor consolidates meaningful observations, recurring difficulties, and next needs automatically. Active progress stays within 120 lines with a few representative observations per focus. Completing an exercise is not mastery; evidence distinguishes independent work from guided work.

To reset a cycle, ask: “Start a fresh learning cycle focused on software design.” To change focus, explicitly name the new goals. The mentor saves and verifies the previous active file in `archive/` before starting the new cycle, preserving your profile. Finishing an exercise leaves the cycle active. Archives are consulted only for relevant new goals or requested history. Archiving does not imply mastery. Persistence requires local file access; if unavailable, the mentor reports that the update was not saved.

## Update and migrate

```sh
git pull --ff-only
bash install.sh --target both --force
```

Linked skill content updates with the checkout. Rerun installation to update startup instructions and migrate old installations. `--force` backs up conflicting skill destinations and retires old `learn-mode`, `work-mode`, and `learning-system` entries into `~/.learning-modes-backups/` before linking the new skill. Existing correct mentor links are unchanged. Backed-up links retain their original targets; old reusable instructions remain available in Git history. If you move the checkout, rerun installation from its new location with `--force`.

The installer replaces the previous `learning-modes` managed block and recognizes the new mentor block on later runs. Malformed or duplicate blocks stop installation before target changes. Manually added imports of the original `LearningSystem.md` or other mode instructions outside the managed block are preserved; inspect and remove those obsolete imports to avoid conflicting instructions.

Existing `~/.learning-modes/progress.md` stays untouched and is copied once to `~/.software-engineering-mentor/archive/legacy-learning-modes.md`. Existing mentor profiles, active progress, and archives are preserved even with `--force`. Legacy assessments remain history rather than becoming new mastery claims or active goals. Keep personal learning data outside this repository.

This evolves example-first teaching, engineering trade-offs, communication practice, cross-project memory, and backed-up symlink installation. It removes mode selection and retention, mandatory pre-implementation exercises, fixed assessment levels, the default delegation competency, and append-only reflections.

## Validate changes

```sh
bash -n install.sh
bash tests/install.sh
```

Tests use disposable homes for both agents and cover repeat installation, upgrades, data preservation, archival, malformed blocks, conflicts, and symlink refusal. Skill metadata uses the shared `SKILL.md` name and description format. Native agent discovery still needs a smoke test in a fresh session of each installed agent.
