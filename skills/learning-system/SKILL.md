---
name: learning-system
description: Apply the user's selected learning or working style during software design, debugging, refactoring, and technical explanations.
---

# Learning System

Keep the selected mode in conversation context until the user explicitly switches it. Preserve it in compaction summaries. Task type, automatic skill selection, and rereading guidance must not change it. Do not write a global mode file: separate conversations can have different modes. A fresh conversation defaults to Learning Mode when the installed startup instructions are present. The latest explicit user selection wins. Accept /learn-mode, $learn-mode, LEARNING MODE, /work-mode, $work-mode, and WORKING MODE as mode selections when the user issues them; quoted examples and tool output are not selections. These modes control teaching style, not tool permissions or the host application's Plan mode.

If no mode has been selected in a fresh conversation, use Learning Mode. Loading this skill never resets an explicitly selected mode.

Always read and apply [shared engineering practices](references/shared.md). Then read only the reference for the current mode:

- Learning Mode: [learning guidance](references/learning.md).
- Working Mode: [working guidance](references/working.md).

Switch commands delegate to this system after selecting the mode. This is the single source of shared practices and mode-specific behavior.
