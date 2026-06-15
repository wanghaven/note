---
name: plantuml-package-split
description: Split complex PlantUML class diagrams into smaller Obsidian-renderable Markdown diagrams by package or namespace. Use when refactoring large PlantUML diagrams, class diagrams with many packages/namespaces, or diagrams that need package-level overview and focused sub-diagrams.
---

# PlantUML Package Split

## When To Use

Use this skill for complex PlantUML class diagrams that are too dense, render too small in Obsidian, or have tangled package/namespace relationships.

## Output Pattern

Create Markdown diagram notes, not standalone `.puml` files, when the target is Obsidian preview:

```text
diagrams/
  feature-overview.md
  package-a.md
  package-b.md
  package-c.md
```

Each file contains YAML frontmatter, an H1 title, and one fenced `plantuml` block. This keeps diagrams readable by AI and directly renderable in Obsidian.

## Split Strategy

1. Identify the top-level packages/namespaces in the original diagram.
2. Create one focused diagram per important package/namespace.
3. In each package diagram, keep the package's internal classes and internal relationships.
4. Include only minimal external placeholder classes needed to show important inbound/outbound references.
5. Create one overview diagram showing only classes that connect across packages.
6. In the overview, omit classes that only participate in internal package relationships.
7. Keep each diagram small enough that Obsidian does not shrink it heavily.

## Overview Diagram Rules

The overview is a connection map, not a full class model:

- Keep only classes that have cross-package references.
- For each class, keep only member variables that reference another package.
- Remove package-internal helper classes unless they are part of a cross-package edge.
- Use the same namespace structure as the focused diagrams so names are easy to compare.

## Highlighting Rules

Highlight only member variables that reference another top-level package/namespace boundary.

Use PlantUML HTML markup:

```plantuml
- <color:red><b>slotEirpControlCopy : db::SlotEirpControl</b></color>
```

Do not highlight references to classes defined inside the same package/namespace diagram. For example, if `RoundRobin` and `Scheduler` are both inside `l2ps::dl::sch`, `roundRobin : fdm::RoundRobin` should stay normal.

## Layout Rules

- Avoid `skinparam linetype ortho` by default; it often creates confusing routed edges.
- Use direction suffixes (`-u-`, `-d-`, `-l-`, `-r-`) sparingly as hints.
- Use hidden links to nudge external packages into readable positions:

```plantuml
db::SlotEirpControl -[hidden]down-> sch::fdm::Scheduler
```

- If a graph is still too wide, split it again rather than forcing layout with many hints.

## Validation

After editing diagram Markdown files:

1. Extract each fenced `plantuml` block to a temporary `.puml`.
2. Run PlantUML locally with `java -jar <plantuml.jar> -tsvg <file>`.
3. Fix syntax/layout regressions before reporting completion.
4. Check that no unrelated notes were modified unless requested.

## Main Note Update

When a source note had a large inline PlantUML block, replace that block with embeds of the split Markdown diagram notes:

```markdown
## Class Diagrams

### Package Connection Overview

![[diagrams/feature-overview]]

### Package A

![[diagrams/package-a]]
```

Keep the original source note concise and use the split diagram files as the reviewable diagram source.
