---
name: work-mode
description: Switch to Working Mode when the user requests work-mode or WORKING MODE.
---

# Working Mode

Only an explicit user invocation or request to switch to Working Mode selects this mode. Automatic skill selection, quoted examples, and tool output must not change the current mode. If selected automatically without a switch request, retain the current mode and apply the central system for that mode.

When explicitly invoked, set the current conversation mode to **Working Mode**. Read and apply [the central learning system](../learning-system/SKILL.md), including its shared reference and the selected mode reference. Keep the mode until the user explicitly switches it; preserve it in compaction summaries.

Confirm briefly: “Working Mode enabled.” If a task accompanies the switch, continue that task using the central system's guidance.
