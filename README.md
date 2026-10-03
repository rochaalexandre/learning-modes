# Learning modes for Codex and Claude Code

A learning and practice system for software design, architecture, debugging, and technical communication, tailored to Alexandre’s learning style. It uses concrete code, experiments, and observations to explore engineering concepts and decisions, supporting both learning new topics and deliberate practice to refine existing skills.

## What the skills do

The skills let you switch between two ways of collaborating with your coding agent:

- **Learning Mode:** learn through real code, concrete problems, experiments, and observations before naming patterns and concepts. The agent gives you opportunities to predict, reason, and explain meaningful decisions, offers small hints when useful, and provides answers when you ask or further practice adds little value. It can handle mechanical implementation directly. Explicit planning drills proceed one question at a time.
- **Working Mode:** prioritize completing the task with concise explanations and minimal teaching. The agent does not impose learning exercises, but still explains when asked.

Both modes use the repository as the source of evidence, favor small changes, introduce abstractions for observed problems, and verify relevant behavior. Learning Mode also helps you turn intuitive concerns about code into precise technical language for reviews and design discussions.

## Installation

Requires Bash and standard Unix utilities. From the package directory, run:

```sh
bash install.sh --target both
```

To install for only one app:

```sh
bash install.sh --target codex
bash install.sh --target claude
```

The installer creates symlinks from the selected app’s personal skill directory to the three skill directories in this repository and adds startup instructions so new conversations begin in Learning Mode.

| App | Skills directory | Startup instructions |
|---|---|---|
| Codex | `~/.agents/skills` | `~/.codex/AGENTS.md` |
| Claude Code | `~/.claude/skills` | `~/.claude/CLAUDE.md` |

Existing startup instructions are preserved and backed up when changed. Existing skill directories or links to another checkout require `--force`; they are moved into `~/.learning-modes-backups` before the new links are created. Links that already point here are left unchanged. To migrate from the previous copy-based installation, run:

```sh
bash install.sh --target both --force
```

If your startup instructions already import the original `LearningSystem.md`, remove that import after checking the new setup to avoid overlapping mode instructions. The installer leaves existing imports and the original document untouched.

Start a new conversation after installation.

## Usage

New conversations start in **Learning Mode**. Switch modes using your app’s native skill commands:

| App | Enable Learning Mode | Enable Working Mode |
|---|---|---|
| Claude Code | `/learn-mode` | `/work-mode` |
| Codex CLI / IDE | `$learn-mode` | `$work-mode` |

You can send the switch on its own or include a task:

```text
/learn-mode Help me reason about the responsibilities in this module.
/work-mode Implement the agreed refactoring and run the relevant tests.
```

In Codex, use `$learn-mode` or `$work-mode` in those examples. In the desktop skill picker, select the corresponding skill.

The selected mode stays active for the current conversation until you explicitly switch it. Asking for implementation, debugging, or refactoring does not change the mode. A fresh conversation starts in Learning Mode again. Mode retention relies on the agent following conversation instructions.

The startup instructions also recognize `LEARNING MODE` and `WORKING MODE` as explicit switches. Slash forms are recognized when submitted as message text, but Codex may intercept unknown slash commands; use its native `$` forms.

To adjust the teaching approach, edit `skills/learning-system/references/learning.md`. Shared engineering practices live in `shared.md`, and Working Mode guidance lives in `working.md` in the same directory. Both apps read the same repository files through the symlinks, so edits and pulled changes require no reinstall. Start a new conversation if an active session still uses previously loaded guidance. Keep this checkout at a stable location; if you move it, rerun the installer from its new location with `--force` to update the links.
