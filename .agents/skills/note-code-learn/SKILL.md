# Skill: Obsidian Code Learning Note

## Purpose

This skill converts:

* source code
* design discussions (chat)
* debugging sessions
* experiments
* runtime logs
* personal observations

into a structured Obsidian architecture knowledge note.

It is NOT a code summarizer.

It is a knowledge extraction system.

---

## Scope

This skill applies to ANY codebase:

* AI Agent systems
* Distributed systems
* Operating systems
* Networking / 5G / RAN
* Databases
* Compilers
* High-performance systems

---

## Output Language Rule

* All explanations MUST be in Chinese
* Code MUST remain in English
* Class / function / API names remain in English
* Diagram labels remain in English
* Technical terms remain in English when standard in industry

---

## Diagram Rule

* Prefer draw.io for diagrams whenever possible (architecture and sequence diagrams)
* For each chapter, create diagrams in draw.io first, then export SVG for note embedding
* In Obsidian notes, embed generated SVG directly as the default
* Use PNG fallback only if SVG rendering is unstable or explicitly requested
* Do NOT use Mermaid
* Use PlantUML only as a fallback when draw.io is not practical
* Keep diagram labels in English
* Draw instructional architecture diagrams, not bare node-link sketches
* Keep color and typography consistent across related diagrams
* Keep layout clean and visually balanced: align container sizes and positions whenever possible
* Prefer orthogonal horizontal/vertical connectors; avoid unnecessary curved/crossing lines
* Minimize line intersections; adjust routing and spacing to keep flows readable
* Keep spacing, margins, and visual rhythm consistent for a polished note-ready look

---

## Core Principle

Prioritize:

Architecture

>

Design Rationale

>

Tradeoffs

>

Patterns

>

Implementation Details

Do NOT produce:

* line-by-line explanation
* API documentation
* tutorial-style walkthrough

---

## CRITICAL: Chat Integration Rule

You MUST integrate chat / conversation context into the note.

Chat includes:

* Cursor / Copilot discussion
* debugging reasoning
* design debates
* experimental observations
* hypotheses
* rejected ideas

Chat content is NOT optional, but it must be used as supporting architectural evidence.

Do NOT create a standalone chat-dump section. Integrate only high-value chat-derived knowledge into the relevant design, tradeoff, experiment, or chapter sections.

---

## Chat-to-Knowledge Transformation Rule

Convert chat into structured knowledge:

* decisions → Architecture Decision
* reasoning → Design Rationale
* disagreement → Tradeoff
* experiments → Observation + Conclusion
* suggestions → Alternative Design
* confusion → Clarified Model

Do NOT copy chat verbatim.
Do NOT list chat extraction results mechanically unless the user explicitly asks for an audit checklist.

---

## Required Structure

# Chapter

## Learning Goal

## Problem Statement

## Core Design

## Architecture Diagram

## Sequence Diagram (Draw.io)

For every chapter, add at least one sequence diagram created in draw.io and embed its exported SVG in the note.

## Execution Flow

## Design Evolution (VERY IMPORTANT)

Include chat-derived evolution here.

## Key Insights

Describe only the main insights of the chapter in a concise way.
Do not split this section into too many fine-grained subitems or rigid templates.
Prefer 1 short paragraph or 3-5 brief bullets.

## Reusable Pattern

Pattern

Context

Problem

Solution

Benefits

Tradeoffs

---

## Production Perspective

Compare with:

* production-grade systems
* frameworks (Claude Code / Cursor / OpenAI Agents SDK / Kubernetes / etc.)

---

## My Experiments

Include only experiments that materially change architecture understanding. Summarize logs and terminal outputs briefly; do not paste long raw logs.

---

## Architecture Impact

| Dimension       | Impact |
| --------------- | ------ |
| Extensibility   |        |
| Maintainability |        |
| Safety          |        |
| Observability   |        |
| Scalability     |        |

---

## Connections

Show architecture evolution chain.

Example:

Source Code → Design Discussion → Final Architecture → Pattern Extraction

---

Obsidian links are optional. Add only links that are useful for navigation; do not generate a separate Knowledge Graph section by default.

---

## One Sentence Summary

A single sentence summarizing the chapter.

---

## Final Quality Rule

Before output:

If result is:

* just explanation → reject
* just code summary → reject
* no chat integration → reject
* no architecture insight → reject
* verbose checklist-style chat dump → reject

Final output must be:
A reusable architecture knowledge artifact.
