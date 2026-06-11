---
title: L2PS DL EirpControl
date: 2026-06-11
tags:
  - work/nokia/project
  - feature-development
status: draft
aliases:
  - L2PS DL EirpControl
---

# L2PS DL EirpControl

## Current EIRP Design
- **SlotSynchroInd**
  - **PRE and TD**
    - CSI-RS Scheduling: 
      CsiRsSendReq::accumulateCsiRsNormalizedTransmittedPowerForBeamId()
      CsiRsSendReq::accumulateCsiRsTrackingNormalizedPowerForOneBeam()
      CsiRsSendReq::accumulateCsiRsBeamMgmtNormalizedPowerForOneBeam()
 
## Class Diagrams

> [!note]
> The original large class diagram has been split into focused package-level diagrams. Each diagram is a Markdown note containing a PlantUML code block, so Obsidian can render it directly and AI tools can still read the text source.

### Package Connection Overview

![[diagrams/eirp-control-overview]]

### L2PS DB EIRP

![[diagrams/l2ps_db_eirp]]

### L2PS DL DB EIRP

![[diagrams/l2ps_dl_db_eirp]]

### L2PS DL Scheduler EIRP

![[diagrams/l2ps_dl_sch_eirp]]

## Sequence chart
TODO

## Related

- [[navigation-nokia-home]]
- [[navigation-architecture]]
- [[navigation-implementation]]
