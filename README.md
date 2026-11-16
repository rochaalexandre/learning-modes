# Engineering Learning Toolkit

Two complementary skills for Codex and Claude Code, built around concrete code, experimentation, observation, reasoning, and feedback across repositories.

| Skill | Use it for | Result |
|---|---|---|
| [Study Planner](skills/study-planner/SKILL.md) | Goals, competency gaps, priorities, roadmaps, courses, books, and learning materials | A realistic next learning step, its purpose, and evidence to look for |
| [Engineering Mentor](skills/engineering-mentor/SKILL.md) | Concrete problems, implementation planning, design, pair programming, code and commit review, and technical communication | Guided practice, focused feedback, and evidence of growing independence |

The planner helps decide what to learn and in what order. It can reuse an existing task, challenge, or resource rather than assigning a new project for every topic. The mentor accompanies practical work throughout a session. Both respect your learning profile and share local progress; there are no learning or working modes to switch.

## Install and initialize

Requires Bash and standard Unix utilities; no runtime package dependencies.

```sh
git clone https://github.com/rochaalexandre/learning-modes.git
cd learning-modes
bash install.sh --target both
```

Use `--target codex` or `--target claude` for one agent. `--home DIR` selects an existing alternate home for testing or provisioning; it does not change the home resolved by a running agent.

| Agent | Skills directory | Startup instructions |
|---|---|---|
| Codex | `~/.agents/skills/` | `~/.codex/AGENTS.md` |
| Claude Code | `~/.claude/skills/` | `~/.claude/CLAUDE.md` |

The installer links both skill directories to this checkout, adds conditional startup pointers, and initializes missing local memory files. It retains startup content outside the managed block and backs up changed files. Both agents read only the skill relevant to the request. Keep the checkout at a stable location and start a new conversation after installation.

For manual installation, copy both `study-planner/` and `engineering-mentor/` into the same agent skills directory. The planner points to plain shared references housed under the mentor; install the two together. The shared memory reference describes initialization when the installer is skipped.

## Use

| Agent | Study Planner | Engineering Mentor |
|---|---|---|
| Codex | `$study-planner` | `$engineering-mentor` |
| Claude Code | `/study-planner` | `/engineering-mentor` |

Examples for the planner:

```text
I want to design services more confidently. Help identify my gaps and what to study next.
Compare this course and roadmap with my current goals. What can I skip for now?
Revise my study priorities using my recent progress, without changing my active focus yet.
```

Examples for the mentor:

```text
Help me decompose this feature before I implement it.
Review this commit and help me reason about the responsibilities in this class.
Show a smaller example of this execution flow, then let me experiment.
Help me turn this code concern into a precise review comment.
Implement the agreed change and explain the important trade-off.
```

The learner implements by default; an explicit implementation request authorizes edits. Explanations are available without completing an exercise. Questions, demonstrations, tests, and debugging support reasoning without making every session an assessment. Teaching changes when repeated clarification or frustration signals an ineffective approach.

Once mentoring begins, continue the conversation naturally; activation on every message is unnecessary. The installed startup pointers and skill descriptions support selection, and the mentor preserves its intent and next step in compaction summaries. Selection and continuity rely on the host following instructions, not a background process or global session flag. If context is lost in a new chat, invoke the appropriate skill again; the shared files persist when local access is available.

## Shared instructions and personal memory

Each `SKILL.md` owns its workflow. Both reach the same [learning context](skills/engineering-mentor/references/learning-context.md) for teaching and memory loading, and consult [memory maintenance](skills/engineering-mentor/references/memory.md) only for initialization, meaningful updates, focus changes, or history. Reusable [templates](skills/engineering-mentor/assets/) contain preferences and unassessed defaults. Shared resources are housed under Engineering Mentor to keep the two-skill package small without another skill or configuration layer.

Personal data lives outside repositories:

```text
~/.software-engineering-mentor/
├── learning-profile.md
├── progress.md
└── archive/
```

Edit `learning-profile.md` to change durable preferences. Both skills use it; installation and updates preserve existing files. Defaults favor examples, observation and experimentation, analogies, short explanations, externalized reasoning, contextual terminology, and gradual independence.

Initial active competencies are planning and problem decomposition, software design, and technical communication. Delegation is added only if you choose it. The mentor primarily records meaningful learning evidence, recurring difficulties, and current needs. The planner consults evidence when revising priorities and changes active goals only when you explicitly change the plan. Progress remains within 120 lines with a few representative observations per competency; evidence distinguishes independent reasoning, guided work, self-report, and unknowns rather than assigning mastery scores.

To reset, ask: “Start a fresh learning cycle focused on software design.” To change active focus, explicitly name the new goals. The skill saves and verifies the previous active file in `archive/` before replacing it, preserving your profile and relevant evidence for continuing competencies. Completed or paused cycles stay separate; archiving implies no mastery. Finishing an exercise leaves the cycle active. Only relevant history is consulted when requested or useful for a new goal.

Persistence requires local file access; if unavailable, the skill reports what was not read or saved. Both agents share ordinary Markdown files. Sequential sessions are supported; simultaneous writes are not coordinated by a locking service. Reread before writing and avoid concurrent updates to the same memory.

## Update and migrate

```sh
git pull --ff-only
bash install.sh --target both --force
```

Linked content updates with the checkout. Rerun installation to update startup instructions and migrate older installations. `--force` backs up conflicting skill destinations and retires `learn-mode`, `work-mode`, `learning-system`, and the earlier `software-engineering-mentor` entrypoint into `~/.learning-modes-backups/`. Correct links are unchanged. Backed-up links retain their original targets; reusable instructions remain available in Git history. If you move the checkout, rerun installation from its new location with `--force`.

The installer replaces a previous `learning-modes` or `software-engineering-mentor` managed block with `engineering-learning-toolkit` pointers. Duplicate or malformed blocks stop installation before target changes. Manually added imports of `LearningSystem.md` or old mode instructions outside the block are preserved; inspect and remove obsolete imports to avoid conflicts.

Existing `~/.learning-modes/progress.md` stays untouched and is copied once to `~/.software-engineering-mentor/archive/legacy-learning-modes.md`. Existing profiles, active progress, and archives survive updates, even with `--force`. Legacy assessments remain history rather than becoming new mastery claims or active goals. The local memory path is retained from the single-mentor iteration so personalized data needs no further move.

## Validate changes

```sh
bash -n install.sh
bash tests/install.sh
```

Tests use disposable homes for both agents: fresh and repeated installation, legacy and single-mentor migration, both skill links, shared memory preservation, archives, malformed blocks, conflicts, and symlink refusal. Skill metadata uses the shared `SKILL.md` name and description format. Native discovery, conditional loading, and continuity still need smoke tests in fresh sessions of both agents.
