# draw.io Sequence Diagram Instructions

Apply to: `diagrams/*.drawio` sequence diagram files in this project.

---

## 1. Workflow

1. Read the source code first. Use README/architecture docs only as supporting context.
2. Identify participants, loops, branches, calls, returns, and state mutations from the code.
3. Lay out the diagram using the geometry rules below.
4. After every edit, validate XML:
   ```bash
   xmllint --noout <file>.drawio
   ```
5. If an element's size or position changes, cascade the layout update to affected arrows, labels, bars, frames, lifelines, final return line, and canvas size.

---

## 2. File And Canvas

- Format: draw.io XML (`.drawio`)
- XML structure: `mxfile -> diagram -> mxGraphModel -> root -> mxCell`
- Global font: `fontFamily=Helvetica;fontSize=12`
- Arrow labels and operation boxes: `fontSize=11`
- Initial canvas: `pageWidth=1000;pageHeight=600`
- Final canvas after layout:
  - `pageWidth = max(x + width) + 50`
  - `pageHeight = max(y + height) + 50`
  - Start visible layout around `x>=50`, `y>=50` to preserve top/left margin.

---

## 3. Participants

### Extraction

Identify participants from code behavior:

- **User / Actor**: human caller, CLI input/output, entry point interaction
- **Main controller**: function/class owning the orchestration loop
- **External services**: LLM API, databases, external systems
- **Tool handlers**: local functions or dispatch maps that execute tool calls
- **Policy / Hooks / Events**: permission checks, lifecycle hooks, event buses

### Layout

- Horizontal spacing between participants: 150-200px
- Standard lifeline width: `width=100`
- User actor width: `width=20`, `size=40`
- Lifeline bottoms must extend at least 20px below the lowest horizontal connector.

### Palette

| Role type | fillColor | strokeColor | fontColor |
|---|---|---|---|
| User / Actor | `#f0f4ff` | `#1d4ed8` | `#1d4ed8` |
| Main controller | `#dae8fc` | `#475569` | `#475569` |
| LLM / External API | `#dae8fc` | `#3333FF` | `#3333FF` |
| Tool handlers | `#d5e8d4` | `#82b366` | `#2d6a2d` |
| Permission / Policy | `#fff3e0` | `#f57c00` | `#e65100` |
| Hooks / Events | `#f3e5f5` | `#9c27b0` | `#7b1fa2` |

---

## 4. Geometry And Alignment

### Centering

Participant header, dashed lifeline, and execution bar must share the same horizontal center:

```text
cx = lifeline.x + lifeline.width / 2
```

- draw.io automatically places the dashed lifeline at `cx`.
- Execution bar width is fixed at `10px`.
- Execution bar x-position:
  ```text
  bar.x = (lifeline.width - 10) / 2
  ```
- For a standard `width=100` lifeline, use `bar.x=45`.

### Horizontal Connectors

All call/return connector lines must be horizontal:

```text
sourcePoint.y == targetPoint.y
```

Do not use slanted call/return lines.

### Arrow Endpoints

Let `cx = lifeline.x + lifeline.width / 2`.

| Direction | sourcePoint.x | targetPoint.x |
|---|---|---|
| Call | `cx(caller) + 5` | `cx(callee) - 5` |
| Return | `cx(responder) - 5` | `cx(receiver) + 5` |
| User side | `cx(User)` | use dashed line center directly |

---

## 5. Execution Bars

- Must be child `mxCell` of the lifeline container: `parent=lifeline_id`
- Coordinates are relative to the parent lifeline.
- Style template:
  ```text
  html=1;points=[];perimeter=orthogonalPerimeter;
  fillColor=<same as lifeline>;
  strokeColor=<same as lifeline strokeColor>;
  strokeWidth=1.5
  ```
- When any related call, return, or operation block moves vertically, update the execution bar height so it spans the full active region.
- Final output / print return lines should align with the bottom edge of the caller/controller execution bar.

---

## 6. Arrows And Labels

### Arrow Semantics

| Type | draw.io style | Meaning |
|---|---|---|
| Synchronous call | `endArrow=block;strokeWidth=2` | Caller blocks waiting for return |
| Synchronous return | `endArrow=classic;dashed=1;strokeWidth=2` | Return value to caller |
| Asynchronous call | `endArrow=open;strokeWidth=2` | Caller does not block |
| Final output to User | `endArrow=classic;dashed=1;strokeColor=#15803d;strokeWidth=2` | Terminal response shown to User |

`client.messages.create(...)` from the non-async Anthropic SDK is synchronous: use a solid filled call arrow plus a dashed return arrow.

### Label Placement

Use a separate `edgeLabel` child `mxCell`, not inline edge text:

```xml
<mxCell id="label-id" value="label text"
    style="edgeLabel;html=1;align=center;verticalAlign=bottom;
           resizable=0;points=[];fontFamily=Helvetica;fontSize=11;
           fontColor=<color>;"
    parent="edge-id" connectable="0" vertex="1">
    <mxGeometry relative="1" as="geometry">
        <mxPoint x="0" y="-11" as="offset"/>
    </mxGeometry>
</mxCell>
```

- Labels must appear above the connector line.
- Match label `fontColor` to the connector color.
- Labels must not overlap operation boxes, frame labels, condition labels, or nearby connectors.
- In dense sections, keep about 10px vertical clearance between labels and neighboring elements.

---

## 7. Frames

### Frame Styles

| Frame | fillColor | strokeColor | fontColor |
|---|---|---|---|
| `loop` | `#eef2ff` | `#6366f1` | `#4338ca` |
| `alt` | `#fff8e8` | `#d39b2a` | `#b45309` |

### Condition Labels

Use a separate text cell instead of embedding the condition in the frame:

```text
text;html=1;align=center;verticalAlign=middle;resizable=0;
points=[];autosize=1;strokeColor=none;fillColor=none;
fontColor=<frame fontColor>;fontFamily=Helvetica;fontSize=11;fontStyle=1
```

### Vertical Nesting

Frame bottom edges must be strictly nested with at least 10px gap:

```text
innermost.bottom < parent.bottom < outer.parent.bottom
```

When lower content moves down, update all enclosing frame heights in the same pass. Keep the bottom gap visible; do not leave the last operation box almost touching the frame border.

### Horizontal Nesting

Left side:

- A frame's left edge must not overlap any participant that has no interactions inside that frame.
- Specifically, `frame.x >= nonParticipant.x + nonParticipant.width` for the leftmost non-participating participant.
- Each inner frame should indent about 10px further right than its parent.

Right side:

- Anchor the innermost frame's right edge to the rightmost participating lifeline's right edge when possible.
- Each outer frame extends about 10px further right than its child.
- If the outermost frame must exceed the rightmost participant to preserve nesting and spacing, that is acceptable.

### Loop Guards

- Avoid `loop [while True]` when the code has a meaningful exit condition.
- Use the actual continuation condition as the guard, for example `loop [stop_reason == "tool_use"]`.
- UML semantics: the loop continues while the guard is true and exits when it fails.

---

## 8. Operation Boxes

Use operation boxes for code operations that are not participant-to-participant messages, such as list appends, state mutations, and handler lookups.

Style template:

```text
rounded=1;whiteSpace=wrap;html=1;
fillColor=#f8fafc;strokeColor=#475569;fontColor=#475569;
fontFamily=Helvetica;fontSize=11
```

Layout rules:

- Default width: `200px`
- Center on the owning lifeline/bar.
- If owner center is `cx`, use `x = cx - 100` for `width=200`.
- Height is explicit, not implicit:
  - short single line: `height=30`
  - long single line that may wrap: `height=40`
  - two or more lines: `height=50` or more
- Place inside the relevant frame and after the triggering arrow.
- Keep about 10px clearance from adjacent labels, connectors, operation boxes, and frame borders.

Tool dispatch flows may be shown as two steps:

- operation box: `handler = TOOL_HANDLERS.get(block.name)`
- call arrow: `handler(**block.input)`

---

## 9. Cascading Layout Updates

Any local geometry change must be reconciled globally.

When an element's height or y-position changes, update affected:

- following or preceding operation boxes
- call and return line y-positions
- arrow label offsets if needed
- execution bar y/height
- enclosing frame heights
- lifeline heights
- final output / print return line
- canvas `pageWidth` / `pageHeight`

The goal is to preserve horizontal connectors, visible frame containment, centered operation boxes, and about 10px visual clearance throughout the affected region.

---

## 10. Label Accuracy

All method names, arguments, variables, and guard expressions must match the source code exactly.

Examples:

- `client.messages.create(...)` — not `message.create()`
- `results.append(...)` — not `result.append()`
- `block.type` — not `block_type`
- `("q", "exit", "")` — not `("q", "exit")`
