---
name: note-summary-drawio
description: Use when creating or updating learn-claude-code summary architecture drawio diagrams (s01+), especially incremental chapter evolution from previous chapter diagrams.
---

# Skill: Learn-Claude-Code Summary Drawio Standards

## Purpose

Use this skill to generate **summary architecture diagrams** for `learn-claude-code` and keep later chapters evolving with the same visual language and progression logic.

The goal is not to redraw from scratch, but to incrementally evolve from the previous chapter diagram.

---

## Scope

Applies to the following diagrams:

- `s01_agent_loop.drawio`
- `s02_tool_use.drawio`
- `s03_Permission.drawio`
- `s04_Hooks.drawio`
- `s05_TodoWrite.drawio`
- `s06_Subagent.drawio`

Also applies to all `s07+` summary architecture diagrams.

---

## Core Principle

Each chapter diagram must preserve two main threads:

1. **Keep the stable main loop skeleton unchanged**
2. **Only add chapter-specific mechanisms and clearly mark “Preserved / New”**

Do not turn the diagram into a completely new narrative. Readers should immediately see what this chapter adds on top of the previous one.

---

## Layout Rules

- **Primary direction**: left-to-right (`input -> state -> LLM -> decision -> execute -> write back`).
- **Feedback path**: use a dashed line for `tool_result -> messages[]`.
- **Connector style**: use `edgeStyle=orthogonalEdgeStyle`; prefer horizontal/vertical orthogonal routing; avoid diagonal lines and crossings.
- **Layering**: place large containers first (for example `Parent/Subagent zone`), then main flow nodes, then local submodules and legend.
- **Readability**: keep consistent spacing; avoid text crossing lines and overlapping node boxes.

---

## Visual Style (from s01-s06)

### 1) Three Color Groups (Required)

- **Blue (historical baseline layer)**: `strokeColor=#1d4ed8`
- **Green (previous change layer)**: `strokeColor=#0f766e`
- **Orange (current chapter layer)**: `strokeColor=#c2410c`
- Do not introduce a fourth semantic color system (such as separate gray/yellow/purple systems).

### 2) Font Color Matches Border Color (Required)

- For any node/container: `fontColor == strokeColor`
- Bold title, regular-weight description
- Do not use embedded light-color text (such as `rgb(...)` / `light-dark(...)`)

### 2.1) Latest Mandatory Visual Rules

- Chapter title nodes (for example `s02 Tool Use`, `s08 Context Compact Architecture`) must be pure text titles: `text=1`, with `strokeColor=none` and `fillColor=none` (no title border box).
- `Return Result` must be black in all chapters: `strokeColor=#111827`, `fontColor=#111827`, with recommended background `#f8fafc`.
- The `stop_reason == "tool_use"?` decision diamond must use Blue (`#1d4ed8`) from `s01` onward; decision branch lines directly connected to this diamond (Yes/No) must also be Blue.
- All rounded rectangle nodes must use a unified small-corner style aligned with `compact-overview.en.svg`: `rounded=1`, `absoluteArcSize=1`, `arcSize=8`.
- All text label backgrounds must be transparent: use `labelBackgroundColor=none`, and do not use inline `background` / `background-color` styles in label HTML.

### 3) Same-Color Nested Layering (Required)

- Within the same color group, apply lightness layering by hierarchy:
  - L1 outer container: relatively darker among light shades
  - L2 middle layer: medium lightness
  - L3 inner execution box: lightest
- Recommended `strokeWidth` hints: `>=3` (L1), `>=2` (L2), `1~1.6` (L3)

### 4) Connector Color Rules

- Baseline main flow uses Blue
- Previous-change flow uses Green
- Current-change flow uses Orange
- Dashed lines represent semantics only (for example feedback), not a color-group change

### 5) s02+ Incremental Mapping Rules

- Starting from `s02`, keep a fixed three-layer evolution mapping:
  - historical baseline: Blue
  - previous change: Green
  - current chapter change: Orange
- Keep mapping consistent within one diagram; prioritize immediate visual distinction of evolution layers

---

## Mandatory Node Vocabulary

Keep the following core terms as consistent as possible (small chapter-specific additions/removals are allowed):

- `User Query`
- `messages[]`
- `LLM (content + stop_reason)`
- `stop_reason == "tool_use"?`
- `TOOL_HANDLERS`
- `tool_result append to messages[]`
- `Return Result`

For newly introduced capability nodes, prioritize names that are consistent with code. Prefer direct function/variable/tool names from code (for example `check_permission()`, `trigger_hooks(...)`, `spawn_subagent`, `compact_history`, `TOOL_HANDLERS`). Use a “mechanism + action” label only when direct code names are not suitable for diagram labels.

---

## Evolution-by-Chapter Pattern

### s01

- Minimal closed loop: `messages -> LLM -> decision -> tool -> result -> messages`

### s02

- Preserve the s01 loop
- Add `TOOL_HANDLERS` dispatch zone and 5 tool mappings

### s03

- Preserve s02 dispatch
- Insert `check_permission()` three-gate pipeline before execution (`deny/rule/approval`)

### s04

- Preserve s03 permission logic (while semantics move into hooks)
- Add hook lifecycle stages: `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `Stop`

### s05

- Preserve s04 hook layering
- Add `todo_write` + `rounds_since_todo` + reminder injection path

### s06

- Preserve the s05 main flow
- Add Parent/Subagent dual zones, fresh messages, summary-only return, and no recursive task

---

## Legend Rule (Required)

Each summary diagram must include three color legend lines at the bottom:

- `Blue: baseline before s0(n-1)`
- `Green: previous change (s0(n-1))`
- `Orange: current change (s0n)`

Requirements:

- Clearly express the meaning of all three evolution layers
- Colors must match the three-color-group rules

---

## Size Control Rule

If the diagram becomes too large, reduce complexity in this order:

1. Merge repeated small nodes (for example merge multiple small tool nodes into `base handlers`)
2. Merge verbose text into one mechanism block instead of splitting into many line-by-line nodes
3. Keep the main trunk flow and branches; remove secondary decorations

Do not remove:

- the main closed loop
- current chapter new mechanisms
- Preserved/New legend

---

## File Naming Rule

- Keep chapter prefix in file names: `s0X_<topic>.drawio` or `s0X-<topic>.drawio`
- Keep `diagram name` aligned with chapter naming (for example `s06_Subagent`)
- Use unified title format: `s0X <Topic>`

---

## Generation Workflow

1. Read the previous chapter summary diagram as the base
2. Read current chapter `code.py` + `README.md` and extract newly added mechanisms
3. Add nodes/edges into the base diagram without re-laying out the core skeleton
4. Add or update legend (`Preserved/New`)
5. Self-check edge crossings, spacing, and color consistency

---

## Quality Checklist

- [ ] Main closed loop exists and is traceable
- [ ] Current chapter additions are clearly visible
- [ ] Preserved/New legend is complete
- [ ] Connectors are orthogonal with minimal crossings
- [ ] No obvious node overlap; text does not collide with lines
- [ ] Color semantics remain consistent with s01-s06
- [ ] Naming follows established vocabulary without unrelated terms

---

## Output Rule

- Keep diagram labels in English (consistent with existing diagrams)
- Keep explanatory text in English, while preserving key mechanism names exactly as in code
- When exporting SVG, prioritize white background and Obsidian compatibility
