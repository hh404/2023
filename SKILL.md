---
name: dev-done
description: Dev done summary — read two commit IDs, generate structured test checklist and handover notes for QA and Android.
---

# Dev Done Summary

## Purpose

Use this skill when Hans finishes a story or subtask and needs to produce a structured handover for QA and Android. Story descriptions are often too vague — this summary fills the gap.

Output is pasted into an ADO subtask comment or PR description.

## Input

Hans provides:
- Two commit IDs (from → to)
- Optional: brief context about the story or feature
- Optional: `english` / `ticket` / `英文` → triggers Mode B (Globish lite, for copy-pasting into ADO ticket)

## Workflow

### Step 1 — Read the diff

Read the changes between the two commits. Identify:

- Which files changed and what layer they belong to (View / ViewModel / UseCase / Repository / Model)
- New or changed business logic (conditions, field handling, flow branching)
- New or changed error handling
- UI changes (new states, visibility conditions, new fields shown)
- Any feature flag or account-type gating

### Step 2 — Infer test scenarios

From the diff, derive test scenarios that cover:

- Happy path (normal flow, all fields present)
- Error paths (API failure, timeout, validation error)
- Edge cases (nil field, empty list, boundary value, unsupported account type)
- UI states (loading, success, empty, error)
- Any conditional logic found in the diff (if X then show Y, else Z)

### Step 3 — Produce structured output

All output uses bullets and section headers. No prose paragraphs.

---

## Output Format

```
**What changed:**
- [key logic change — one bullet per distinct change]
- [new field or condition handled]
- [error handling added or modified]

**Test checklist:**
- [ ] [happy path scenario]
- [ ] [error scenario]
- [ ] [edge case]
- [ ] [UI state: loading / empty / error]
- [ ] Screenshot / recording: [attach]

**Android alignment:**
- [iOS decision or behaviour Android must replicate]
- [field name or mapping Android needs to match]
- [补充: Android 侧实现说明] ← Hans fills this in

**Open questions:**
- [anything unconfirmed or pending QA / PO clarification]
```

---

## Mode B — Globish Lite (ticket-ready)

Triggered by: `english` / `ticket` / `英文` in Hans's input.

Same four sections, pure Globish English, no Chinese placeholders. Designed to be copy-pasted directly into ADO subtask comment or PR description.

```
**What changed:**
- [key logic change]
- [new field or condition handled]

**Test checklist:**
- [ ] [scenario]
- [ ] [scenario]
- [ ] Screenshot / recording: [attach]

**Android alignment:**
- [behaviour iOS has that Android must match]
- [field or mapping to align]

**Open questions:**
- [anything pending confirmation]
```

Globish rules for Mode B:
- Simple words, short sentences (≤18 words)
- No idioms, no native flair
- Keep all technical terms in English (GraphQL, BFF, ViewModel, etc.)
- No Chinese text of any kind

---

## Rules

- No prose. Every item is a bullet.
- "What changed" describes **what the code does**, not what files were touched.
- Test checklist must be **executable** — each item is one concrete action QA or Hans can perform.
- Android alignment: write what **iOS does**; leave `[补充]` placeholder for Hans to fill Android side.
- Open questions: only include if something is genuinely unclear from the diff. Omit section if empty.
- If the diff is large, focus on business logic and UI behaviour changes. Skip boilerplate, formatting, and refactoring noise.
