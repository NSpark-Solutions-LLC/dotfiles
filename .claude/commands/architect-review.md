Perform a full architect review before implementing any significant change.

**TRIGGER when:**
- Touching shared infrastructure (DB schema, auth, routing, cache, service interfaces)
- Modifying more than 2 files
- Changing a state machine, data flow, or API contract
- Adding or removing a dependency
- Any new feature (not a bug fix in an isolated path)
- Any doubt about whether the change is significant

Arguments (optional): $ARGUMENTS — brief description of the change being reviewed

---

## Tier Classification — do this first

**Tier A — Full review required** (any one of these = Tier A):
- Touches shared infrastructure (DB schema, auth, routing, service interfaces)
- Modifies more than 2 files
- Changes a state machine, data flow, or API contract
- New feature (not a targeted bug fix)
- Adds or removes a dependency

**Tier B — Lightweight, self-certified** (ALL of these must be true):
- Single file, client-only or server-only (not both)
- Isolated bug fix in a self-contained function
- Does not touch shared state, cache keys, API contracts, or DB
- Blast radius limited to a single feature flow for a single user
- Type check passes before committing

**If in doubt, treat as Tier A.**

For Tier B: read the function and its callers, confirm self-containment, fix it, run the type check, commit. Document the self-certification in one sentence in the commit message.

---

## Tier A Process — complete in this order

### Step 1 — Read all affected code
Read every file that will be touched. Understand current behavior fully before drafting anything. Do not skip this step even if you think you already understand the code.

### Step 2 — Draft the proposed change
Write out what will change. Be specific: which functions, which interfaces, which data flows.

### Step 3 — Risk Register
Fill in this table for every risk identified:

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| (describe risk) | Low/Med/High | Low/Med/High | (concrete mitigation) |

Minimum risks to evaluate:
- Data loss or corruption
- Auth bypass or privilege escalation
- Performance regression (N+1 queries, blocking calls, cache invalidation)
- Breaking change to a public API or shared interface
- Dependency conflict or version mismatch

### Step 4 — Per-file Regression Analysis
For every file that will be modified, explicitly answer:

> *"What existing functionality in this file could break, and why won't it?"*

Format:
```
File: path/to/file.ts
Existing behavior at risk: [describe]
Why it won't break: [concrete reason — not "I'll be careful"]
```

Targeted bug fixes must not affect any code path the fix does not directly address.
Feature enhancements must not degrade existing behavior.

### Step 5 — Branch Parity Check (for refactors)
If any existing function is being replaced, renamed, or rewritten (not merely extended):

1. Enumerate every conditional branch in the old implementation:
   every `if`, `else`, `switch case`, `try/catch`, type guard, early return, and input-shape variation.

2. For each branch, state explicitly:
   - *"Preserved in the new implementation at [file:line]"*, OR
   - *"Intentionally removed because [reason]"*

3. Any branch that is neither preserved nor explicitly justified is a regression — stop and add it before committing.

### Step 6 — Present to user
Show steps 1–5 before writing any implementation code. The user reviews and approves before anything is built.

---

## Rules that always apply (Tier A and B)

- Read before writing. No guessing about current behavior.
- If any part of the request is ambiguous, ask before coding. Ambiguity is more expensive than a delay.
- When a bug is reported, find the root cause in the actual code before proposing any fix.
- For workflow/process changes: show a before/after ASCII diagram or numbered step list, then a 2–4 sentence plain-English summary.
