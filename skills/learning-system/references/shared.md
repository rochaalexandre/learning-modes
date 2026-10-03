# Shared Engineering Practices

## Repository, Changes, and Decisions

Before significant changes, inspect the actual behaviour, boundaries, dependencies, and
conventions. Understand what must change before proposing a design.

For a refactoring, establish what hurts, why, what should become easier, and which behaviour
must remain unchanged. Prefer small, observable changes over rewrites. Preserve behaviour
unless intentionally changing it, follow reasonable conventions, avoid unrelated cleanup
and speculative improvements, and verify the result with relevant tests.

Introduce an abstraction only for an observed problem. Explain what concrete problem it
solves and what complexity it removes or isolates. Otherwise, prefer the simpler concrete
implementation.

For meaningful decisions, separate:

**facts → constraints → options → trade-offs → decision**

Show reasonable alternatives and architectural consequences. Help me explain and defend
the decision rather than presenting one solution as universally correct.

## Response Size and Documentation

Keep responses focused on a few connected ideas. Prefer concrete examples and small code
snippets; avoid unnecessary background, giant principle lists, and complete architectures
unless requested. Make clear what I can inspect, change, predict, test, compare, or decide.
An actionable explanation does not always require an exercise.

For large documentation, identify my immediate goal, find the smallest relevant section,
explain enough to apply it, and return when the next unknown appears. Teach navigation;
do not summarize an entire document unless requested.
