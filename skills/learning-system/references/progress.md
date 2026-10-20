# Evidence-Based Progress Tracking

Use this guidance in Learning Mode at meaningful milestones: completing a substantial
feature, a challenge, or a learning session with useful evidence. Do not require a reflection
after every small CodeCrafters stage or every conversation. Fit a brief reflection into a
natural stopping point when useful; do not interrupt learning or require an exercise to
produce evidence. A learner may skip a reflection. Working Mode does not initiate tracking.

## Skills and Assessment

Track transferable engineering skills across projects and coding challenges:

| Skill | Behavior to observe |
|---|---|
| Planning | Anticipating changes, dependencies, risks, and implementation direction before coding. |
| Design | Proposing responsibilities, alternatives, and abstractions, and explaining trade-offs. |
| Technical Communication | Explaining code observations with concrete evidence and appropriate engineering terminology. |
| Agent Delegation | Defining bounded tasks, providing context, evaluating agent plans, and verifying results. |

Use these levels for each milestone, not as permanent judgments of ability:

- **Not observed:** no relevant learner behavior was demonstrated.
- **With guidance:** the learner demonstrated the skill with substantive hints or support.
- **Mostly independently:** the learner demonstrated the skill with occasional prompting.
- **Independently:** the learner demonstrated the skill without substantive guidance.

Assess only behavior demonstrated by the learner. Never attribute agent-generated reasoning,
plans, explanations, or verification to the learner. Distinguish deliberate delegation from
inability: asking an agent to implement is not evidence of weak planning or design, and
delegation skill requires evidence of how the learner scoped, directed, or reviewed the work.
Never infer weakness from missing evidence; use Not observed and state that evidence was
unavailable. Passing tests alone is not proof of improved design ability.

Support each assessment with concrete observations of what the learner said or did and the
guidance involved. Compare with previous reflections when relevant evidence is available,
including across projects. Do not manufacture improvement or force an upward trend. If no
concrete improvement is supported, say so briefly under Growth observed. Choose one useful
next opportunity from the evidence, without making it an assignment or a curriculum.

## Private Storage and Initialization

Use only `~/.learning-modes/progress.md` for personal progress. Resolve `~` to the current
user's home directory, regardless of the working directory. This file persists across
CodeCrafters challenges, personal projects, and other learning environments.

Keep personal progress outside the public learning-modes repository and every project:
never commit, publish, or copy it into a repository, project documentation, fixtures, or
examples. The repository contains only reusable instructions and the blank template below.

Before writing, read the existing local file if present. Preserve its baseline and all
reflections; append new reflections without overwriting earlier entries. If absent, create
the directory and initialize the file using the template's title, Initial Baseline, and
Reflections headings. Use an explicitly supplied self-assessment for the baseline; otherwise
use Not assessed for each skill. Do not copy another user's baseline or infer one from
agent work. Not assessed is an initial-baseline marker, not a milestone assessment level.

Leave out the dated reflection block until there is a real milestone to record. Keep each
reflection ideally under 200 words. If local access requires permission or fails, do not
substitute a project-local file or claim the reflection was saved.

## Reflection Template

This is a formatting guide, not an example assessment. Replace the baseline placeholders
as described above and fill reflections only from observed learner behavior.

```md
# Learning Progress

## Initial Baseline

- Planning: <self-assessment or Not assessed>
- Design: <self-assessment or Not assessed>
- Technical Communication: <self-assessment or Not assessed>
- Agent Delegation: <self-assessment or Not assessed>

## Reflections

### YYYY-MM-DD — Project / Milestone

**Planning**
Level:
Evidence:

**Design**
Level:
Evidence:

**Technical Communication**
Level:
Evidence:

**Agent Delegation**
Level:
Evidence:

**Growth observed**
One concrete improvement, if supported by evidence.

**Next opportunity**
One useful skill to practice next.
```
