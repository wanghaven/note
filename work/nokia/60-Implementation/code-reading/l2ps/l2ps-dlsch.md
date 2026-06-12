---
title: L2-PS DL Scheduler (dlSch) Architecture And PlantUML Diagrams
date: 2026-06-11
tags:
  - work/nokia/implementation
  - l2ps
status: draft
last_verified_src_date: '2026-06-11'
last_verified_gnb_git: '45617cfb9a73'
aliases:
  - L2-PS DL Scheduler (dlSch) Architecture And PlantUML Diagrams
---

# L2-PS DL Scheduler (dlSch) Architecture And PlantUML Diagrams

**Scope.** This document covers the DL Scheduler EO (`L2RtPool<P>_L2PsDlYySch`) and its companion FD Scheduler EO (`L2RtPool<P>_L2PsFdYySch`). Together they implement per-slot downlink scheduling for FR1 cells (TDD and FDD). The DL Scheduler is the most complex per-cell-group EO in L2-PS.

**Applicability.** TDD FR1 and FDD FR1. FR2 paths are excluded.

**Reference baseline.** EO architecture layout follows `/home/ptr476/work/doc/ai/.cursor/agents/l2ps-eo-architecture.agent.md` (editor mirror: `/home/ptr476/work/doc/ai/.github/agents/l2ps-eo-architecture.agent.md`). **§2** uses a *Package / subsystem connection overview* plus *Detailed class views*, per that agent (canonical split example: [`l2ps-bbrm.md`](./l2ps-bbrm.md) in this folder). Optional cross-check: Nokia-internal `l2ps-architecture.md` where maintained. Source-backed statements assume `/workspace/uplane/L2-PS/src/` and `/home/ptr476/work/doc/ai/storage/L2PS_Architecture.md` when those paths are available in the environment.

> **PlantUML rendering notes.**
> - Diagrams use fenced ` ```plantuml ` blocks with `@startuml` / `@enduml`; large figures live in sibling `diagrams/*.md` notes and are embedded from this vault folder. Each diagram note carries **`last_verified_src_date`** / **`last_verified_gnb_git`** when reconciled with `/workspace`.
> - Component and class diagrams use `package`, explicit arrow directions, and hidden links to guide layout.
> - Large class diagrams are split into overview and focused diagram notes under `diagrams/` where useful.
> - Sequence diagrams keep the original lifeline order and use PlantUML `alt` / `opt` blocks.
> - `skinparam linetype ortho` is intentionally left disabled unless strict right-angle routing improves readability.

---

## 1. Runtime Position

The DL Scheduler sits in the per-cell-group tier of L2-PS. It receives slot triggers from the platform timer, configuration from CP-RT (SGNL psCell/psUser), L1-UL feedback (HARQ ACK/NACK, CSI via PUCCH/PUSCH rx-resp, SRS resp), beam selection from SRS-BM, resource grants from BBRM, buffer status from L2-LO, and intra-scheduler updates from UL Scheduler. It produces PDSCH/PDCCH/CsiRs/SSB requests to L1-DL (via FD Scheduler), and intra-scheduler updates to UL Scheduler.

![[diagrams/l2ps-dlsch-runtime-position]]

---

## 2. Top-Level Class Overview

### Package / subsystem connection overview

Coarse map of the DL Scheduler EO shell, message ingress, **EO-level router** vs **per-cell queue FSM**, main scheduling pillars, and coupling to the FD EO / peers (BBRM, SRS-BM, UL SCH, L1).

![[diagrams/l2ps-dlsch-top-level-class-overview]]

### Detailed class views

**Dispatcher / FD-response gating** (outer FSM above the per-cell `QueueFsm`; pairs with §3.1 narrative):

![[diagrams/l2ps-dlsch-dispatcher-class-hierarchy]]

**DB model (classes):** see **§6** — `diagrams/l2ps-dlsch-db-model` (embedded there).

---

## 3. EO FSM And Event Dispatch

The DL Scheduler EO has a **two-tier event dispatch** structure:

1. **EO-level router** — `EmFsmRouterWithDelay<Direction::DOWNLINK, ...>` instance in `dl/em/Eo.hpp`. Handles **cell-group-level** events directly (no per-cell FSM gate): `CellGroupSetupReq`, `CellGroupReconfigReq`, `CellGroupDeleteReq`, `GetResourceUsageReq`, `SlotSynchroInd`, `StartSlotSynchroInd`, `StopSlotSynchroInd`, `TdMetricOrderResp`. All other messages fall through to the per-cell `QueueFsm`.
2. **Per-cell FSM** — Boost.SML state machine (`QueueFsm`) with three states: **Startup**, **Default**, **Delete**. One FSM per cell, managed by `CellsFsmSet<QueueFsm, MainComponent>`.

```plantuml
@startuml l2ps-dlsch 3. EO FSM And Event Dispatch
!pragma graphviz svg
' scale 1920*1080

[*] --> StateStartup
StateStartup --> StateDefault : CellSetupReq [isSetupRequest] / setupL2PS
StateDefault --> StateDelete : CellStopSchedulingReq / stopAction
StateDelete --> StateStartup : CellDeleteReq [deleteGuard]
StateStartup --> [*] : StopEvent
StateDefault --> [*] : StopEvent
StateDelete --> [*] : StopEvent
note right of StateStartup
    Waits for CellSetupReq from SGNL.
    Only setup messages accepted.
end note
note right of StateDefault
    All slot-level scheduling + user messages.
    Events routed via StateDefaultRouter.
    Self-loop: SlotSynchroInd, UserModifyReq,
    BearerDeleteReq, BeamConfigUpdateReq,
    DlBufferStatusInd, PucchReceiveRespHarqD,
    PuschReceiveRespHarqD, ResourceResp,
    SrsBeamSelectionInd, XpMessage, etc.
end note
note right of StateDelete
    Handles CellDeleteReq and cleanup.
    Transitions back to Startup when complete.
end note
@enduml
```

In the per-cell **Default** state, `StateDefaultRouter` (`dl/em/StateDefaultRouter.hpp`) instantiates `pscommon::em::MessageRouter<…, StateDefaultRoutes>`. **`dl/em/StateDefaultRoutes.hpp`** defines the routed message set; against `/workspace` at the git revision recorded under **Document sync (source)** below, that file contains **111** distinct `msgId()` entries.

### 3.1 Dispatcher FSM (above the cell FSM)

The `DlDispatcherStateDefault` and `DlDispatcherWaitFdSchedRespState` form a two-state dispatcher that gates event processing while the DL EO is waiting for one or more `FdScheduleResp` from the FD EO. The dispatcher state lives in `l2ps::pscommon::dispatcherFsm::QueueDispatcherFsmImpl` and is the **outer** FSM (above the per-cell `QueueFsm` that owns Startup / Default / Delete).

```plantuml
@startuml l2ps-dlsch 3.1 Dispatcher FSM (above the cell FSM)
!pragma graphviz svg
' scale 1920*1080

[*] --> DispatcherDefault
DispatcherDefault --> WaitFdSchedResp : SlotSynchroInd / processSlotSynchroInd / FdScheduleReq sent to FD EO
WaitFdSchedResp --> DispatcherDefault : FdScheduleResp / processAllFdSchedResp (when all responses arrived)
WaitFdSchedResp --> DispatcherDefault : SlotSynchroInd / abortWaitFdSchedResp (when skippedSlotsCount over max)
note right of DispatcherDefault
    eventToPassthrough = true (default)
    eventFlushForbidden = false
    Events go straight to MessageRoutes.
end note
note right of WaitFdSchedResp
    on_entry / eventToPassthrough = true,
              eventFlushForbidden = true
    on_exit  / eventToPassthrough = false,
              eventFlushForbidden = false
    Self-loop on any other event:
      handleDelayedEvent ->
      eventToBeDelayed = true,
      eventToBeFreed = false ->
      event pushed into queuesDelayedEvents.
    Exit condition:
      ResponseQueue.numberOfFdSchedResp
      equals fdSchedFence.getNumberOfFdSchedReq,
      or skippedSlotsCount exceeds
      RadParam.rdMaxSkippedSlotsWaitingForFdResponse.
end note
@enduml
```

**Per-event flags carried by `EmFsmRouterWithDelay`** (in `pscommon/em/EmFsmRouterWithDelay.hpp`):

| Flag                  | Semantics                                                                                          |
| --------------------- | -------------------------------------------------------------------------------------------------- |
| `eventToBeDelayed`    | If `true` after FSM dispatch, the event is pushed into `queuesDelayedEvents` instead of consumed.   |
| `eventToBeFreed`      | If `true` after dispatch, `platform::EmIf::deleteEvent` releases the event memory.                  |
| `eventToPassthrough`  | If `true`, event goes through the FSM router immediately; if `false`, it is queued straight away.   |
| `eventFlushForbidden` | If `true`, `processDelayedEvents` is a no-op (used while waiting for `FdScheduleResp`).             |
| `isSplitEvent`        | If `true`, the event was only partially processed in the current slot; it is **re-pushed to the front** of its priority queue. |
| `isOverloaded`        | If `true`, lower-priority FIFOs are skipped (`fifoQueuesBlacklist` advances).                      |
| `isFifosFlushIndSent` | One-shot guard so `FifosFlushInd` is emitted at most once per slot boundary.                       |

### 3.2 Dispatcher Class Hierarchy

The FSM is built from a chain of generic templates (`EmFsmBase` → `EmFsm<FsmImpl>` → `EmFsmRouterWithMsgChecker<...>` → `EmFsmRouter<...>`), then bound to the DL-specific `QueueFsmImpl` and `MainComponent` via two type-aliases (`dl::em::QueueFsm`, `dl::em::DlDispatcherStateDefault`). The per-cell `QueueFsmImpl` itself aggregates the four state handlers (`Startup`, `Default`, `DefaultRouter`, `Delete`).

*PlantUML class diagram for this layer:* **§2 — Detailed class views** (`diagrams/l2ps-dlsch-dispatcher-class-hierarchy.md`).

### 3.3 FIFO Event Dispatch — Sequence

Every incoming EM event is steered through three phases inside `EmFsmRouterWithDelay`: (a) **passthrough** to the FSM if currently allowed, (b) **delay** into a per-priority `queuesDelayedEvents`, and (c) **bulk flush** via `processDelayedEvents` when the state machine exits the wait condition. The diagram below shows one event's full life cycle, including the delayed-event flush loop.

![[diagrams/l2ps-dlsch-fifo-event-dispatch-sequence]]

### 3.4 FIFO Dispatch Flowchart

```plantuml
@startuml l2ps-dlsch 3.4 FIFO Dispatch Flowchart
!pragma graphviz svg
' scale 1920*1080

' skinparam linetype ortho
skinparam componentStyle rectangle
top to bottom direction

rectangle "Event arrives" as start
rectangle "ProcessEvent\neventToBeDelayed = false" as pe
rectangle "eventToPassthrough?" as pt
rectangle "Dispatch via FSM + handle" as disp
rectangle "eventToBeDelayed?" as dly1
rectangle "Push to back of FifoQueue\nby priority" as push1
rectangle "(A)" as A
rectangle "ProcessDelayedEvents" as pde
rectangle "queue empty\nOR flushForbidden?" as empty
rectangle "Done" as done
rectangle "Pop highest-priority event" as pop
rectangle "isEnoughTimeInSlot?" as time
rectangle "eventToBeDelayed = false" as rst
rectangle "Dispatch via FSM + handle" as disp2
rectangle "eventToBeDelayed?" as dly2
rectangle "Push to front of FifoQueue\nbreak loop" as push2

start --> pe
pe --> pt
disp --> dly1
A --> pde
pde --> empty
pop --> time
rst --> disp2
disp2 --> dly2
push2 --> done
@enduml
```

---

## 4. DL Scheduling Pipeline

The DL per-slot scheduling is a five-stage pipeline split across two EOs.

### 4.1 Slot Synchronization

Entry: `SlotSynchroIndHandler::handle` → `MainComponent::handle(SlotSynchroInd)` → `SlotHandler::run(onAirTime)` → validates against 5G timer → starts overload controller → measures slot delay → adjusts scheduling capacity → updates pre-CS UE list → swaps pooling DB snapshots → refreshes ZAB cells → sends HARQ status update.

The `dl::sch::SlotHandler` is the **per-cell orchestrator** that drives the rest of the pipeline. It calls into `bfgroup::Scheduler` in three distinct phases per slot:

| Phase                  | `bfgroup::Scheduler` method                                | Purpose                                                                                  |
| ---------------------- | ---------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| Reference signals      | `scheduleRs(xhfn, cellConfig, cellDyn)`                    | Reserves CSI-RS / TRS / SSB-tracking RS resources before the scheduling window           |
| CS1 refresh            | `updateCs1ListWithEvents(xsfn, cellDyn)`                   | Re-evaluates PRE candidate set against latest events (DRX / BWP / BSR)                   |
| Slot-type-mode dispatch| `scheduleBySlotTypeMode(...)` — branches into:             | One of three slot-mode paths (see §4.3a–c)                                               |
| &nbsp;&nbsp;• SSB slot | `scheduleSsBurst(sfn, slot)`                               | Schedule SS-burst on **SSB-only** slots (no PRE/TD/FDM)                                  |
| &nbsp;&nbsp;• DL slot  | `schedule(xhfnOnAir, hasTriggeredScheduling)`              | Run PRE → TD → FDM → FdScheduleReq (§4.2 – §4.4)                                         |
| &nbsp;&nbsp;• Other    | `scheduleAloneSrAndPerCsiReport(xsfn)`                     | Non-DL slot: still schedule alone-SR + periodic CSI report on PUCCH (via `CsiSrScheduler`) |

The DL→UL intra-update, `postSchedule`, and `postRun` happen **after** `FdScheduleResp` arrives (§4.6).

### 4.2 PRE Scheduling (CS1)

Entry: `pre::Scheduler::schedule` via `bfgroup::Scheduler::updateCs1ListWithEvents`.

Builds the Candidate Set 1 (CS1) — all UEs eligible for scheduling in this slot. Checks per-UE conditions: DRX active-time, BWP state, measurement gap, beam validity, flow control, buffer status.

Key classes:
- `Cs1ListCandidateConstraint` — per-UE eligibility checks
- `Cs1ListProcessingController` — orchestrates CS1 refresh
- `LinkAdaptor` — CQI expiry and initial link adaptation state

### 4.3 TD Scheduling (CS2 / PF Metric)

Entry: `td::Scheduler::schedule`.

From CS1, computes the Proportional Fair metric per UE and builds the sorted CS2 list per carrier. Also:
- Prepares paging resources (`PagingHandler`)
- Selects beams for SIB/CSI (`BeamSelectorForCsiOrSib`)
- Handles common channels (SSB, SIB, paging, MSG2)
- Allocates long-PUCCH HARQ resources (`PucchForHarqAllocator`)
- Builds N-K list for adaptive retransmission

Key classes:
- `PfMetricDl` — PF metric computation
- `CarrierScheduler` — per-carrier CS2 scheduling + FDM invocation
- `CommonChannelScheduler` — SIB, paging slot resource reservation
- `BeamSelector` — analog beam selection for scheduling
- `PdcchSchedulerTd` — PDCCH CCE reservation at TD level

### 4.4 FDM Scheduling

Entry: `td::CarrierScheduler::scheduleFdm` → `fdm::Scheduler::schedule`.

Selects UEs from CS2 to be scheduled, performs DL MU-MIMO pairing, distributes PRBs across sub-areas, and builds the `FdScheduleReq`.

Key classes:
- `UeSelector` — selects UEs from CS2 for this slot
- `ResourceAllocator` — RBG/PRB allocation
- `PxschResourcesManager` — PDSCH resource tracking
- `DlSubAreaManager` — sub-area PRB distribution
- `muMimoEnhance::Scheduler` — MU-MIMO Virtual UE pairing + DMRS ports
- `AllocationPolicy` — allocation type (Type 0 / Type 1) selection
- `DlFdmSchedulerHelper` — FDM helper utilities

### 4.5 FD Scheduling (FD EO)

Entry: `fd::sch::MainComponent::handleEventFdScheduleReq` → `processFdScheduleReq`.

Runs on the separate `L2PsFdYySch` EO. Performs per-UE MCS/TBS calculation, builds PDSCH/PDCCH L1 messages, handles SIB/paging/MSG2 scheduling, and returns `FdScheduleResp`.

Key classes:
- `fd::sch::MainComponent` — FD EO main component
- `dl::sch::fd::Scheduler` — per-subcell FD scheduler
- DCI builders: `DciFormat10`, `DciFormat11`
- L1 senders: `PdschSendReqSender`, `PdcchSendReqSender`

### 4.6 Post-Scheduling

Entry: `FdScheduleResp` from FD EO arrives at the **dispatcher** in `WaitFdSchedResp` state. Once `ResponseQueue::isNumberOfResponsesEqualToNumberOfRequests()` returns `true`, the dispatcher transitions to `DispatcherDefault` and calls into:

1. `MainComponent::handleAllFdSchedulerResp(fdScheduleRespArray)`
2. → `bfgroup::Scheduler::handle(fdScheduleRespArray)`
3. → `td::Scheduler::handle(fdScheduleRespArray)`
4. → `td::FdScheduleRespHandler::handleFdScheduleResp(fdScheduleRespArray)`
    - `PdcchSchedulerTd::schedulePdcch(fdScheduleRespArray)` — finalize PDCCH CCE bookkeeping from FD result
    - `postProcessFdScheduleResp(...)` — fold MCS / TBS / PRB-used back into TD bookkeeping
    - `CommonChannelScheduler::schedulePucch(fdScheduleRespArray)` — PUCCH resource accounting from scheduled UEs
5. → `SlotHandler::postRun(xsfn, cellDyn)` → `bfgroup::Scheduler::postSchedule` → `tdScheduler.postSchedule`

Other work in `postSchedule`: updates PF average rate (`PfMetricDl::updateAverageRate`), sends `DlToUlIntraSchedUpdate` via `IntraSchedUpdateSender`, schedules deferred CSI/SR, logs PCMD records, and runs `metricsFacadeDl.endOfNewSlot`.

```plantuml
@startuml l2ps-dlsch 4.6 Post-Scheduling
!pragma graphviz svg
' scale 1920*1080

' skinparam linetype ortho
skinparam componentStyle rectangle
top to bottom direction

rectangle "SlotSynchroInd" as A
rectangle "SlotHandler.run\noverload + delay + PRB swap" as S1
rectangle "scheduleRs\nCSI-RS / TRS" as SR
rectangle "updateCs1ListWithEvents\nrefresh CS1 by events" as CS1U
rectangle "slot-type mode?" as MODE
rectangle "scheduleSsBurst\nSS / PBCH only" as SSB
rectangle "PRE - CS1\nbuildCs1List" as S2
rectangle "scheduleAloneSrAndPerCsiReport\nvia CsiSrScheduler" as SR_ONLY
rectangle "TD - CS2\nPfMetricDl + beam + paging" as S3
rectangle "FDM - dl::sch::fdm\nUeSelector + MU-MIMO + PRB alloc" as S4
rectangle "FD EO\nMCS/TBS + PDSCH/PDCCH → L1" as S5
rectangle "handleAllFdSchedulerResp\nFdScheduleRespHandler:\nschedulePdcch + schedulePucch +\npostSchedule + postRun" as POST

A --> S1
S1 --> SR
SR --> CS1U
CS1U --> MODE
S2 --> S3
S3 --> S4
S4 --> S5
SSB --> POST
SR_ONLY --> POST
S5 --> POST
S5 ..> POST : FdScheduleResp\nvia dispatcher WaitFdSchedResp
@enduml
```

### 4.7 PRE Stage — Sequence

```plantuml
@startuml l2ps-dlsch 4.7 PRE Stage  Sequence
!pragma graphviz svg
' scale 1920*1080

    autonumber
participant "SlotSynchroIndHandler" as SH
participant "bfgroup::Scheduler" as BFG
participant "pre::Scheduler" as PRE
participant "Cs1ListDecision" as CS1
participant "Cs1ListCandidateConstraint" as ELIG
participant "LinkAdaptor" as LA
participant "DrxManager" as DRX
participant "UeDbDl" as UeDB
    SH->BFG: updateCs1ListWithEvents(onAirXhfn, cellDyn)
    BFG->PRE: updateCs1ListWithEvents(xsfn, cellDyn, resetBwpSwitch)
    note over PRE
      Reads votedCell + isMixedCaMode
      from CellDb
    end note
    PRE->CS1: updateCs1ListWithEvents(sfn, slot, caFunc, nonCaFunc, ...)
    loop for each UE in UeDb
        CS1->UeDB: read drx/bwp/buffer/beam state
        CS1->ELIG: checkCandidate(ue)
        ELIG-->CS1: eligible? + priority
        alt eligible
            CS1->CS1: insertIntoCs1List(ue, prio)
        else not eligible
            CS1->CS1: removeFromCs1List(ue)
        end
    end
    PRE->LA: handleCqiExpiry(currentXsfn)
    PRE->DRX: tickActiveTimer(xsfn)
    PRE->PRE: updateCaUesNumberInPreCandidateListToPucchResourceDb
    PRE->PRE: setUeNumberWithDrbPriority
    PRE-->BFG: return (CS1 ready)
@enduml
```

### 4.8 TD Stage — Sequence (per carrier / per slot)

```plantuml
@startuml l2ps-dlsch 4.8 TD Stage  Sequence (per carrier / per slot)
!pragma graphviz svg
' scale 1920*1080

    autonumber
participant "bfgroup::Scheduler" as BFG
participant "td::Scheduler" as TD
participant "CarrierScheduler" as CAR
participant "PfMetricDl" as PF
participant "BeamSelector" as BEAM
participant "CommonChannelScheduler" as CC
participant "PagingHandler" as PG
participant "PucchForHarqAllocator" as PUC
participant "PdcchSchedulerTd" as PDCT
participant "Cs2List" as CS2
    BFG->TD: schedule(onAirXhfn)
    TD->CC: scheduleSibSsbPaging(slot)
    CC->PG: preparePagingResources()
    CC-->TD: common channel slots reserved
    loop for each scheduled carrier (cell)
        TD->CAR: schedule(cellDbIdx, xhfn)
        CAR->BEAM: selectBeams(cs1List)
        BEAM-->CAR: beam assignments
        CAR->PUC: reserveLongPucchHarq(slot)
        loop for each UE in CS1
            CAR->PF: computeMetric(ue, history)
            PF-->CAR: pfWeight
        end
        CAR->CS2: buildSortedCs2(weights)
        CAR->PDCT: reserveCce(cs2List)
        PDCT-->CAR: pdcchCapacityRemaining
    end
    TD-->BFG: CS2 ready, common ch reserved
@enduml
```

### 4.9 FDM Stage — Sequence (per carrier)

```plantuml
@startuml l2ps-dlsch 4.9 FDM Stage  Sequence (per carrier)
!pragma graphviz svg
' scale 1920*1080

    autonumber
participant "CarrierScheduler" as CAR
participant "fdm::Scheduler" as FDM
participant "UeSelector" as SEL
participant "AllocationPolicy" as POL
participant "DlSubAreaManager" as SA
participant "muMimoEnhance::Scheduler" as MU
participant "ResourceAllocator" as RA
participant "PxschResourcesManager" as PXR
participant "FdScheduleReq builder" as REQ
    CAR->FDM: scheduleFdm(cs2List, cellDyn)
    FDM->POL: pickType(cell)
    POL-->FDM: Type0 or Type1
    loop for each candidate UE in CS2
        FDM->SEL: select(ue, remainingPrb)
        SEL-->FDM: takeUe? + bytesGoal
        alt take
            FDM->SA: allocateSubArea(ue, prbCount)
            SA-->FDM: subAreaId + prb range
            FDM->RA: allocatePrb(subArea, prbCount, type)
            RA-->FDM: prb allocation mask
            FDM->PXR: reservePdsch(ue, mask)
        end
    end
    FDM->MU: pairUesForMuMimo(scheduledList)
    MU-->FDM: muMimoGroups + dmrsPorts
    FDM->REQ: appendUe(ue, prbMask, mcsHint, dmrsPort)
    REQ-->FDM: complete FdScheduleReq
    FDM-->CAR: FdScheduleReq ready (to be sent to FD EO)
@enduml
```

### 4.10 Post Stage — Sequence

![[diagrams/l2ps-dlsch-post-stage-sequence]]

### 4.11 End-to-End Per-Slot Sequence

A single bird's-eye view spanning the **whole** DL slot — `SlotSynchroInd` arrival, all four scheduling stages, the FD EO round-trip, the FdScheduleResp handling and `postSchedule`. The dispatcher boundary (`DispatcherDefault` ↔ `WaitFdSchedResp`) is shown explicitly.

![[diagrams/l2ps-dlsch-end-to-end-per-slot-sequence]]

---

## 5. HARQ And Link Adaptation Subsystem

### 5.1 HARQ Feedback Processing

L1 sends `PucchReceiveRespHarqD` and `PuschReceiveRespHarqD` back to the DL Scheduler. These carry ACK/NACK/DTX per HARQ process. The DL scheduler:
1. Updates HARQ process state (free process for ACK, mark for retransmission on NACK)
2. Feeds BLER measurement to Link Adaptation
3. Updates token bucket levels

Key classes:
- `dl/sch/harq/` — HARQ state management, counters
- `dl/sch/dlHarqFeedback/` — DL HARQ feedback sender (to UL for long-PUCCH)
- `dl/sch/dlHarqStatusUpdate/` — HARQ status update request to L2-LO

### 5.2 Link Adaptation

DL Link Adaptation adjusts MCS based on channel quality (CQI from PUCCH/PUSCH CSI reports and HARQ BLER tracking).

Key classes (`dl/sch/la/`):
- `DlCqiMcsCalculator` — CQI → MCS mapping with outer-loop BLER adjustment
- `LaDlTimeControl` — time-domain LA control
- `CqiExpiry` — CQI staleness detection
- `DlHrBrLaStateManager` — high-rate/base-rate LA state management
- `DeltaCqiStepUpCalculator` — outer-loop step-up/down logic

```plantuml
@startuml l2ps-dlsch 5.2 Link Adaptation
!pragma graphviz svg
' scale 1920*1080

participant "L1-UL" as L1
participant "DL Scheduler" as DL
participant "Link Adaptation" as LA
participant "HARQ Manager" as HARQ
    L1->DL: PucchReceiveRespHarqD (ACK/NACK + CSI)
    DL->HARQ: updateHarqProcess(processId, ackNack)
    alt ACK
        HARQ->HARQ: freeProcess(processId)
    else NACK
        HARQ->HARQ: markForRetx(processId)
    end
    DL->LA: updateBler(ackNack, mcsUsed)
    LA->LA: outerLoopAdjust(deltaCqi)
    note over LA
      Next slot: CQI + deltaAdj → proposedMCS
    end note
@enduml
```

---

## 6. DB Model

The DL Scheduler operates on two main database layers: Cell DB and UE DB.

![[diagrams/l2ps-dlsch-db-model]]

### Key DB characteristics:
- **CellConfigData**: Static cell configuration from CellSetupReq. Written once at setup, read every slot.
- **CellDynamicData**: Per-slot mutable state (EIRP, slot-specific context). Written by DL scheduler, read by FD EO.
- **UeData (db::Ue)**: Per-UE mutable state (buffer, LA, HARQ, DRX). Written by DL scheduler.
- **BfGroupSchedulerDB**: Transient per-slot CS1/CS2 lists. Written and read within one slot cycle.
- **CellGroupDynamicData**: Cross-cell-group state (PRB pooling snapshots). Swapped at slot start from BBRM writes.

---

## 7. Cell Bring-Up And Delete Flow

```plantuml
@startuml l2ps-dlsch 7. Cell Bring-Up And Delete Flow
!pragma graphviz svg
' scale 1920*1080

participant "SGNL-psCell" as SGNL
participant "DL Scheduler (MainComponent)" as DL
participant "SlotHandler" as SLOT
participant "bfgroup::Scheduler" as BFGRP
participant "td::Scheduler" as TD
participant "FD EO" as FD
    SGNL->DL: Internal CellSetupReq
    note over DL
      QueueFsm: StateStartup → StateDefault
    end note
    DL->DL: performCellSetup(cellConfigData, cellDynData, cellParamsInMsg)
    DL->SLOT: initialize slotTypeSelectorSet
    DL->BFGRP: create pre/td/fdm sub-schedulers
    DL->TD: handleCellSetup(cell, cellDynData)
    DL->FD: FdInitInd (via EQ to FD EO)
    FD->FD: createFdScheduler(subcellIdx)
    DL-->SGNL: CellSetupResp (OK)
    note over SGNL,FD
      Cell Delete
    end note
    SGNL->DL: CellStopSchedulingReq
    note over DL
      QueueFsm: StateDefault → StateDelete
    end note
    DL->TD: handleCellStopScheduling(nrCellIdentity)
    DL->FD: FdDeleteInd
    SGNL->DL: CellDeleteReq
    DL->DL: performCellDelete()
    DL->TD: handleCellDelete(nrCellIdentity)
    note over DL
      QueueFsm: StateDelete → StateStartup
    end note
    DL-->SGNL: CellDeleteResp (OK)
@enduml
```

---

## 8. UE Configuration Flow

```plantuml
@startuml l2ps-dlsch 8. UE Configuration Flow
!pragma graphviz svg
' scale 1920*1080

participant "SGNL-psUser" as SGNL
participant "DL Scheduler (MainComponent)" as DL
participant "bfgroup::Scheduler" as BFGRP
participant "pre::Scheduler" as PRE
participant "UeDbDl" as DB
    SGNL->DL: InternalUserSetupReq
    DL->DB: allocateUe(ueId, config)
    DL->BFGRP: handle(UserSetupReq)
    BFGRP->PRE: initializeUeForCs1(ue)
    DL-->SGNL: InternalUserSetupResp (OK)
    note over SGNL,DB
      User Modify
    end note
    SGNL->DL: InternalUserModifyReq
    DL->DB: updateUeConfig(ueId, newConfig)
    DL->BFGRP: handle(UserModifyReq)
    BFGRP->PRE: updateCs1Eligibility(ue)
    DL-->SGNL: InternalUserModifyResp (OK)
    note over SGNL,DB
      User Delete
    end note
    SGNL->DL: UserDeleteInd
    DL->DL: userDeleteIndHandler.handle()
    DL->BFGRP: handle(UserDeleteInd)
    DL->DB: deallocateUe(ueId)
@enduml
```

---

## 9. Slot-Level Processing Flow (Main Hot Path)

This is the most performance-critical path — executed every 0.5 ms (TDD FR1 30 kHz).

```plantuml
@startuml l2ps-dlsch 9. Slot-Level Processing Flow (Main Hot Path)
!pragma graphviz svg
' scale 1920*1080

' skinparam linetype ortho
skinparam componentStyle rectangle
top to bottom direction

rectangle "SlotSynchroInd from platform timer" as SYNC
rectangle "Validate sync against 5G timer" as V1
rectangle "OverloadController::startSlot\nmeasure delay, set budget" as OC
rectangle "adjustSchedulingToRemainingSlot\ncapacity = remaining time × ratio" as ADJ
rectangle "Swap PRB pooling DB\n+ ScheUE pooling DB snapshots" as SWAP
rectangle "ZabCellUpdater::update\nrefresh pooled cell PRBs" as ZAB
rectangle "HarqStatusUpdateReqSender::send" as HARQUPD
rectangle "pre::Scheduler::schedule\nbuild CS1 per-UE eligibility" as CS1
rectangle "td::Scheduler::schedule\nPF metric + CS2 build" as PF
rectangle "BeamSelector + CommonChannelScheduler\nSIB/paging beam + resources" as BEAM
rectangle "CarrierScheduler::scheduleCarriers\nper-carrier CS2 selection" as CARRIER
rectangle "fdm::Scheduler::schedule\nUE selection + MU-MIMO + PRB alloc" as FDM
rectangle "Build FdScheduleReq\nsend to FD EO" as FDREQ
rectangle "FD EO: processFdScheduleReq\nMCS/TBS + PDSCH/PDCCH → L1" as FDEO
rectangle "FdScheduleResp back to DL" as FDRESP
rectangle "Post-scheduling\nPF avg update + DL→UL update" as POST
rectangle "CsiSrScheduler::scheduleInAdvance\n+ PCMD records" as CSISCHED

SYNC --> V1
V1 --> OC
OC --> ADJ
ADJ --> SWAP
SWAP --> ZAB
ZAB --> HARQUPD
HARQUPD --> CS1
CS1 --> PF
PF --> BEAM
BEAM --> CARRIER
CARRIER --> FDM
FDM --> FDREQ
FDREQ --> FDEO
FDEO --> FDRESP
FDRESP --> POST
POST --> CSISCHED
@enduml
```

### Timing Budget (TDD FR1 30 kHz, single slot = 500 µs)

| Phase                       | Typical budget        |
| --------------------------- | --------------------- |
| Slot sync + PRB swap        | ~20 µs                |
| PRE (CS1)                   | ~30–60 µs             |
| TD (PF + CS2)               | ~40–80 µs             |
| FDM (UE select + PRB alloc) | ~50–100 µs            |
| FD EO (MCS/TBS + L1 msg)    | ~80–150 µs            |
| Post-scheduling             | ~20–40 µs             |
| **Total scheduling**        | **~250–450 µs**       |
| NRT message handling        | remaining (50–250 µs) |

Adaptive budgeting via `OverloadController` clamps FD-scheduled UEs when time is tight.

---

## 10. DL MU-MIMO And Beamforming Flow

```plantuml
@startuml l2ps-dlsch 10. DL MU-MIMO And Beamforming Flow
!pragma graphviz svg
' scale 1920*1080

participant "SRS-BM EO" as SRSBM
participant "DL Scheduler" as DL
participant "FDM Scheduler" as FDM
participant "muMimoEnhance::Scheduler" as MUMIMO
participant "FD EO" as FD
participant "L1-DL" as L1
    SRSBM->DL: SrsBeamSelectionInd (per-UE best beam, DOA)
    note over DL
      Store beam info in UE DB
    end note
    DL->DL: SlotSynchroInd → PRE → TD
    DL->FDM: scheduleFdm (CS2 UEs + beam info)
    FDM->MUMIMO: performMuMimoPairing
    MUMIMO->MUMIMO: Build Virtual UEs + allocate DMRS ports
    FDM->FDM: distributePrbsPerSubArea
    FDM->FD: FdScheduleReq (paired UEs + layers + DMRS)
    FD->FD: computeRankAndPmi per UE
    FD->L1: PdschSendReq (with UePairingReq for MU)
    FD->L1: PdcchSendReq (DCI Format 1_1)
@enduml
```

---

## 11. Output Messages

| Message                            | Destination    | Trigger                          | Builder/Sender                    |
| ---------------------------------- | -------------- | -------------------------------- | --------------------------------- |
| `PdschSendReq`                     | L1-DL          | Per UE scheduled in FD           | `fd/sch/` via L1 DlData interface |
| `PdcchSendReq`                     | L1-DL          | Per DCI (data + common channel)  | `fd/sch/` DCI builders            |
| `CsiRsSendReq`                     | L1-DL          | Periodic/semi-persistent CSI-RS  | `csiRsOpt/` scheduler             |
| `SsBlockSendReq`                   | L1-DL          | SSB burst                        | `ssblock/` scheduler              |
| `SlotTypeReq`                      | L1-DL          | Per slot per subcell             | `SlotTypeReqSender`               |
| `FdScheduleReq`                    | FD EO          | Per slot (carries scheduled UEs) | `FdSchMsgBufferizer` / EQ send    |
| `FdInitInd`                        | FD EO          | Per cell on cell setup           | `dl/sch/bfgroup/SchedulerFdHandle::createFdScheduler` |
| `FdDeleteInd`                      | FD EO          | Per cell on cell delete          | DL bfgroup cell-delete path       |
| `TdMetricOrderReq`                 | FD EO          | TD metric pre-compute hint       | `dl/sch/td/FdMetricOrder*`         |
| `DlToUlIntraSchedUpdate`           | UL Scheduler   | Per slot                         | `IntraSchedUpdateSender`          |
| `DlHarqFeedbackReq`                | UL Scheduler   | Per UE needing long-PUCCH        | `DlHarqFeedbackSender`            |
| `CellSetupResp`                    | SGNL           | On cell setup complete           | `MainComponent`                   |
| `UserSetupResp` / `UserModifyResp` | SGNL           | On UE procedure complete         | `MainComponent`                   |
| `PduMuxReq`                        | L2-LO (LoCtrl) | DL MAC PDU mux trigger           | via `LoCtrl` protocol             |
| `ResourceResp` (consume)           | BBRM           | PRB demand metrics               | `NumAllocCellPrbRepo`             |

---

## 12. Design Issues Observed

| #   | Issue                                                                                                                                                                          | Location                                               | Impact                                                                         |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------ | ------------------------------------------------------------------------------ |
| 1   | **God class**: `MainComponent` has 50+ `handle()` methods and ~40 member objects                                                                                               | `dl/sch/MainComponent.hpp`                             | Hard to test in isolation; any change risks regressions                        |
| 2   | **Deep ownership chain**: `MainComponent` → `bfgroup::Scheduler` → `td::Scheduler` → `CarrierScheduler` → `fdm::Scheduler` — 4 levels of composition                           | Throughout `dl/sch/`                                   | Difficult to reason about data flow; mocking at intermediate levels is complex |
| 3   | **Mixed concerns in bfgroup::Scheduler**: Handles CS1 updates, TD delegation, CSI/SR scheduling, beam management, CA state machines, PCMD — all in one class                   | `dl/sch/bfgroup/Scheduler.hpp`                         | Single change in CSI scheduling requires understanding of entire bfgroup       |
| 4   | **Shared mutable state**: `CellDynamicData` is written by both DL Scheduler and partially read by FD EO with no explicit ownership boundary                                    | `dl/db/cell/CellDynamicData.hpp`                       | Potential for race conditions if FD EO deployment changes                      |
| 5   | **FilterWrapper complexity**: Message filtering logic interleaves time-critical rx-resp with regular messages in a single wrapper                                              | `dl/sch/FilterWrapper`                                 | Hard to verify priority guarantees                                             |
| 6   | **Timer proliferation**: Multiple independent timer wheels + timers scattered across sub-schedulers (PA timer, BWP switch timer, DRX, beam update, SCell inactivity, etc.)     | Multiple files in `dl/sch/`                            | Timer interactions not centrally visible                                       |
| 7   | **Overload controller coupling**: `FdTimeController` + `OverloadController` + `SlotProcessingRatioAdapter` form a distributed time-budget mechanism with no single entry point | `dl/synchro/overload/` + `dl/sch/FdTimeController.hpp` | Difficult to tune or verify budget guarantees                                  |

---

## 13. Refactoring Direction (Modular Decomposition)

### Proposed Module Structure (7 modules)

```plantuml
@startuml l2ps-dlsch Proposed Module Structure (7 modules)
!pragma graphviz svg
' scale 1920*1080

' skinparam linetype ortho
skinparam componentStyle rectangle
top to bottom direction

package "Module 1: Slot Orchestrator" as Orchestrator {
  rectangle "SlotOrchestrator\n1. startSlot\n2. runPipeline\n3. postSlot" as ORCH
}

package "Module 2: Eligibility Engine" as Eligibility {
  rectangle "EligibilityEngine\n1. refreshCs1\n2. getEligibleUes\n3. updateOnEvent" as ELIG
}

package "Module 3: TD Selector" as TdSelector {
  rectangle "TdSelector\n1. computeMetrics\n2. buildCs2\n3. allocatePucch" as TDSEL
}

package "Module 4: Resource Allocator" as ResourceAllocator {
  rectangle "ResourceAllocator\n1. selectUes\n2. allocatePrbs\n3. buildFdRequest" as RESALLOC
}

package "Module 5: FD Processor" as FdProcessor {
  rectangle "FdProcessor\n1. computeMcsTbs\n2. buildL1Messages\n3. returnResponse" as FDPROC
}

package "Module 6: Feedback Processor" as FeedbackProcessor {
  rectangle "FeedbackProcessor\n1. processHarq\n2. updateLinkAdaptation\n3. updateBufferStatus" as FBPROC
}

package "Module 7: Config Manager" as ConfigManager {
  rectangle "ConfigManager\n1. handleCellSetup\n2. handleUserSetup\n3. handleDelete" as CFGMGR
}


ORCH --> ELIG : getEligibleUes
ORCH --> TDSEL : buildCs2
ORCH --> RESALLOC : allocate
ORCH --> FDPROC : schedule
ORCH --> FBPROC : postProcess
CFGMGR ..> ORCH : cellSetup triggers init
@enduml
```

### Module Responsibilities

| Module                    | Public Interface (≤ 4 methods)                                                   | DB Access                                            | Writes To          |
| ------------------------- | -------------------------------------------------------------------------------- | ---------------------------------------------------- | ------------------ |
| **1. Slot Orchestrator**  | `startSlot()`, `runPipeline()`, `postSlot()`, `handleFdResponse()`               | TimeBudgetStore (R), SlotStateStore (RW)             | SlotStateStore     |
| **2. Eligibility Engine** | `refreshCs1()`, `getEligibleUes()`, `updateOnEvent()`                            | UeEligibilityStore (RW), CellConfigStore (R)         | UeEligibilityStore |
| **3. TD Selector**        | `computeMetrics()`, `buildCs2()`, `allocatePucch()`                              | UeMetricStore (RW), CellConfigStore (R)              | UeMetricStore      |
| **4. Resource Allocator** | `selectUes()`, `allocatePrbs()`, `buildFdRequest()`                              | PrbAllocationStore (RW), UeMetricStore (R)           | PrbAllocationStore |
| **5. FD Processor**       | `computeMcsTbs()`, `buildL1Messages()`, `returnResponse()`                       | L1MessageStore (RW), CellConfigStore (R)             | L1MessageStore     |
| **6. Feedback Processor** | `processHarq()`, `updateLinkAdaptation()`, `updateBufferStatus()`                | HarqStore (RW), LaStore (RW), UeEligibilityStore (R) | HarqStore, LaStore |
| **7. Config Manager**     | `handleCellSetup()`, `handleUserSetup()`, `handleUserModify()`, `handleDelete()` | CellConfigStore (RW), UeEligibilityStore (RW)        | CellConfigStore    |

### DB Store Isolation

| DB Store           | Single Writer Module              | Readers                                         |
| ------------------ | --------------------------------- | ----------------------------------------------- |
| SlotStateStore     | Slot Orchestrator                 | All (read-only view)                            |
| UeEligibilityStore | Eligibility Engine                | TD Selector, Resource Allocator, Config Manager |
| UeMetricStore      | TD Selector                       | Resource Allocator                              |
| PrbAllocationStore | Resource Allocator                | FD Processor                                    |
| L1MessageStore     | FD Processor                      | (output to L1, no internal readers)             |
| HarqStore          | Feedback Processor                | Eligibility Engine, TD Selector                 |
| LaStore            | Feedback Processor                | TD Selector, Resource Allocator                 |
| CellConfigStore    | Config Manager                    | All (read-only view)                            |
| TimeBudgetStore    | Slot Orchestrator (overload ctrl) | All (read-only view)                            |

### Design Principles Applied

1. **Zero direct coupling**: Only the Slot Orchestrator calls other modules. Modules never call each other.
2. **DB isolation**: Each mutable store has exactly one writer.
3. **Interface minimalism**: Each module exposes 2–4 public methods.
4. **UT independence**: Each module can be tested by mocking its DB read views + the Orchestrator interface (for modules called by Orchestrator).
5. **Hot-path guarantee**: All stores use pre-allocated fixed-size arrays. Zero heap allocation after cell setup.
6. **No CRTP sharing**: Modules are independent concrete classes with no template coupling.

### Self-Check Table

| Question                                                | Answer                                                                                              |
| ------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| Are modules directly coupled?                           | **No** — only Orchestrator calls other modules via interfaces                                       |
| Is mutable state shared?                                | **No** — each store has exactly 1 writer; others get read-only views                                |
| How many modules change for a typical feature addition? | **1–2** (e.g., new MU-MIMO feature → Resource Allocator + possibly FD Processor)                    |
| Can modules be developed in parallel?                   | **Yes** — interfaces are stable; mock DB views for testing                                          |
| Is timing behavior independently testable?              | **Yes** — TimeBudgetStore is isolated; Orchestrator's time decisions are mockable                   |
| Does the FD EO boundary remain clean?                   | **Yes** — FD Processor maps 1:1 to existing FD EO; communication is via FdScheduleReq/Resp messages |
| Can HARQ feedback be tested without slot scheduling?    | **Yes** — Feedback Processor is independent; mock HarqStore + LaStore                               |

### Boundary clarifications (consistent with FD EO refactoring)

| # | Item | Clarification |
|---|------|---------------|
| 1 | Module 5 "FD Processor" | **Not** a DL-internal scheduling module. It is the **boundary stub** to the external FD EO (see `l2ps-fd.md`). It owns `FdScheduleReq` construction + `FdScheduleResp` parsing; the actual MCS/TBS/PDSCH-PDCCH building lives in FD EO's 6 modules. |
| 2 | `L1MessageStore` in this doc | Refers to the **FD-EO-owned** L1MessageStore (FD EO module 5 is its single writer). DL SCH sees its symbolic effect via `FdScheduleResp` only. |
| 3 | BBRM `ResourceResp` consumer | Consumed by Module 1 (Slot Orchestrator) and forwarded to Module 4 (Resource Allocator) which writes `PrbAllocationStore` based on the budget. |
| 4 | SRS-BM `SrsBeamSelectionInd` / `DlSrsComaPowerInd` consumer | Consumed by Module 2 (Eligibility Engine) and Module 4 (Resource Allocator) respectively. |

---

## 14. Cross-EO Refactoring Consistency

This section validates that the DL SCH refactoring above is mutually consistent with the parallel proposals in `l2ps-srsbm.md`, `l2ps-ulsch.md`, `l2ps-fd.md`, and `l2ps-bbrm.md`. **You are here: DL SCH** (Module IDs in the table below refer to that EO's own refactoring numbering).

### 14.1 Common refactoring shape

| Property                              | SRS-BM      | DL SCH (here) | UL SCH      | FD EO       | BBRM        |
| ------------------------------------- | ----------- | ------------- | ----------- | ----------- | ----------- |
| Module count                          | 7           | **7**         | 7           | 6           | 7           |
| Has Event Dispatcher module?          | No (FSM)    | **No (FSM)**  | No (FSM)    | Yes         | Yes         |
| Has Orchestrator / Pipeline module?   | Yes (M7)    | **Yes (M1)**  | Yes (M1)    | Yes (M2)    | No (M6 sync) |
| Single-writer DB store invariant      | ✓           | **✓**         | ✓           | ✓           | ✓           |
| ≤ 4 public methods per module         | ✓           | **✓**         | ✓           | ✓           | ✓           |
| Self-Check Table                      | ✓           | **✓**         | ✓           | ✓           | ✓           |
| Hot-path fixed-size storage           | ✓           | **✓**         | ✓           | ✓           | ✓           |

All five EOs follow the same skeleton: 6–7 independent modules, one writer per store, ≤ 4 public methods per module, with mandatory self-check and migration notes.

### 14.2 Inter-EO message-to-module mapping (DL SCH endpoint highlighted)

| Message                                    | Producer EO (Module)                          | Consumer EO (Module)                          |
| ------------------------------------------ | --------------------------------------------- | --------------------------------------------- |
| `FdInitInd` / `FdDeleteInd`                | **DL SCH (M7 Config Manager)**                | FD EO (M1 Event Dispatcher)                   |
| `FdScheduleReq`                            | **DL SCH (M4 Resource Allocator → M5 stub)**  | FD EO (M1 Event Dispatcher → M2 Slot Pipeline)|
| `FdScheduleResp`                           | FD EO (M5 L1 Builder)                         | **DL SCH (M1 Slot Orchestrator)**             |
| `TdMetricOrderReq`                         | **DL SCH (M3 TD Selector)**                   | FD EO (M1 Event Dispatcher)                   |
| `ResourceReq`                              | **DL SCH (M1 Slot Orchestrator → M4)**, UL SCH (M1) | BBRM (M1 Dispatcher → M6 Period Sync → M7 Response Builder) |
| `ResourceResp` / `RimResourceResp`         | BBRM (M7 Response Builder)                    | **DL SCH (M1 Slot Orchestrator)**, UL SCH (M1) |
| `DlMetricInd`                              | **DL SCH (M1 Slot Orchestrator)**             | BBRM (M3 PRB / M4 UE / M5 SubCell Pooling Engines) |
| `UlMetricInd`                              | UL SCH (M1)                                   | BBRM (M3 / M4 / M5)                           |
| `PdschSendReq` / `PdcchSendReq`            | FD EO (M5 L1 Builder)                         | L1-DL                                         |
| `PucchReceiveRespHarqD` / `PuschReceiveRespHarqD` | L1-UL                                  | **DL SCH (M6 Feedback Processor)**            |
| `UlToDlIntraSchedUpdate` / `DlHarqFeedbackReq` | UL SCH (M5 L1 Response Processor)         | **DL SCH (M6 Feedback Processor)**            |
| `DlToUlIntraSchedUpdate`                   | **DL SCH (M6 Feedback Processor)**            | UL SCH (M5 L1 Response Processor)             |
| `SrsBeamSelectionInd` / `DlSrsComaPowerInd`| SRS-BM (M6 Output Gateway)                    | **DL SCH (M2 Eligibility Engine / M4 Resource Allocator)** |
| `UlSrsBeamSelectionInd`                    | SRS-BM (M6 Output Gateway)                    | UL SCH (M2 Pre-Scheduler)                     |
| `CellSetupReq` / `UserSetupReq` / `*DeleteReq` | SGNL EO                                   | **DL SCH (M7 Config Manager)**, UL SCH (M6), FD EO (M1→M2 init), BBRM (M2 Lifecycle), SRS-BM (M1 Lifecycle) |
| `SlotSynchroInd`                           | Platform Timer                                | **DL SCH (M1 Slot Orchestrator)**, UL SCH (M1), FD EO (none — gated by DL SCH), BBRM (M6 Period Sync), SRS-BM (M7 Slot Scheduler) |

### 14.3 DB store namespace check (no collisions across EOs)

Each EO owns its DB stores; identical-sounding names in different docs refer to different stores.

| Logical concept   | SRS-BM                       | DL SCH (here)                          | UL SCH                  | FD EO                                      | BBRM                                |
| ----------------- | ---------------------------- | -------------------------------------- | ----------------------- | ------------------------------------------ | ----------------------------------- |
| Cell config       | `CellConfigStore` (SRS local)| **`CellConfigStore` (DL local)**       | (Cell DB)               | (read via pointer hand-off from DL SCH)    | `CellConfigStore` (BBRM pool config)|
| UE state          | `UeRegistry`                 | **`UeEligibilityStore` + `UeMetricStore`** | (UE DB)             | `EoDb` (per-slot scratch)                  | `UePoolStore` (pool side)           |
| PRB allocation    | (n/a)                        | **`PrbAllocationStore` (per-slot grant)** | (FD internal)        | (per-slot)                                 | `PrbPoolStore` (long-period budget) |
| L1 messages       | (n/a)                        | **(symbolic — owned by FD EO)**        | (built by FD Scheduler) | `L1MessageStore` (writer)                  | (n/a)                                |
| Throughput pool   | (n/a)                        | (n/a)                                  | (n/a)                   | `TputPoolStore` (instantaneous)            | (PRB pool budget overlap)            |
| Runtime policy / sync | `RuntimePolicy`          | **`TimeBudgetStore`**                  | (Slot Dynamic DB)       | (slot-scoped)                              | `SyncStore`                          |

### 14.4 Observed cross-EO issues and resolutions

| # | Issue                                                                           | Resolution                                                                                                                            |
| - | ------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| 1 | DL "FD Processor" sounds like an internal module                                | Explicitly clarified as a **boundary stub**: see §13 "Boundary clarifications" item 1. FD scheduling lives in FD EO's 6 modules.       |
| 2 | Two `L1MessageStore` declarations (DL SCH §13 and FD EO §13)                    | They refer to the **same physical store**, owned by FD EO M5. DL SCH sees only `FdScheduleResp` (a typed message), not the raw store. |
| 3 | `ResourceResp` consumer is not explicit in DL/UL SCH refactoring                 | Consumed by Module 1 (Slot Orchestrator) → forwarded to PRB Allocator. Documented in §13 "Boundary clarifications" item 3.             |
| 4 | BBRM has explicit `Event Dispatcher` (M1) but DL/UL SCH do not                   | Intentional — DL/UL keep their lifecycle FSM (Startup/Default/Delete) as the dispatcher gate; BBRM's trivial FSM was collapsed into M1 Dispatcher. Both are valid module choices, both isolate dispatch from business logic. |
| 5 | SRS-BM `RuntimePolicy` has no DL SCH equivalent                                  | DL SCH equivalent is `CellConfigStore` (set once at cell setup) + `TimeBudgetStore` (slot-scoped). Functionally equivalent.            |
| 6 | BBRM Period Synchronizer fires "milestone slots" that overlap DL/UL slot ticks   | Resolved: BBRM `SyncStore` is BBRM-local (pooling milestone bookkeeping). DL/UL slot state lives in DL/UL local stores. Cross-EO via `MetricInd`/`ResourceResp` only — no shared mutable state. |

**Conclusion**: The five refactoring proposals are **mutually consistent**. Cross-EO interaction is exclusively via typed messages, with each message having clearly identified producer/consumer modules. No DB store is shared across EOs.

---

## 15. Reading Map

| File / Directory                                  | Purpose                                                    |
| ------------------------------------------------- | ---------------------------------------------------------- |
| `dl/em/Eo.hpp`                                    | EO shell — queue creation, EM init, owns MainComponent     |
| `dl/em/QueueFsm.hpp`                              | Boost.SML FSM (Startup/Default/Delete transitions)         |
| `dl/em/StateDefaultHandler.hpp`                   | Default state handler (delegates to MainComponent)         |
| `dl/em/StateDefaultRouter.hpp`                    | Event routing in Default state                             |
| `dl/em/DlDispatcherStateDefault.hpp`              | Dispatcher state: normal processing                        |
| `dl/em/DlDispatcherWaitFdSchedRespState.hpp`      | Dispatcher state: waiting for FD response                  |
| `dl/sch/MainComponent.hpp`                        | Central coordinator: owns all sub-schedulers and handlers  |
| `dl/sch/SlotHandler.hpp`                          | Per-cell slot processing entry point                       |
| `dl/sch/SlotSynchroIndHandler.cpp`                | SlotSynchroInd handling entry                              |
| `dl/sch/bfgroup/Scheduler.hpp`                    | Beam-forming group scheduler: CS1 → TD → FDM orchestration |
| `dl/sch/pre/Cs1ListProcessingController.hpp`      | CS1 eligibility logic                                      |
| `dl/sch/pre/LinkAdaptor.hpp`                      | PRE-level link adaptation helper                           |
| `dl/sch/td/Scheduler.hpp`                         | TD scheduler: PF metric, CS2 build, carrier scheduling     |
| `dl/sch/td/CarrierScheduler.hpp`                  | Per-carrier scheduling + FDM invocation                    |
| `dl/sch/td/PfMetricDl.hpp`                        | Proportional Fair metric computation                       |
| `dl/sch/td/PdcchSchedulerTd.hpp`                  | PDCCH resource allocation at TD level                      |
| `dl/sch/fdm/Scheduler.hpp`                        | FDM scheduler: UE selection, PRB allocation                |
| `dl/sch/fdm/ResourceAllocator.hpp`                | RBG/PRB allocation logic                                   |
| `dl/sch/fdm/selection/UeSelector.hpp`             | UE selection from CS2                                      |
| `dl/sch/muMimoEnhance/Scheduler.hpp`              | DL MU-MIMO enhanced pairing                                |
| `dl/sch/fd/Scheduler.hpp`                         | Per-subcell FD scheduler (MCS/TBS)                         |
| `fd/sch/MainComponent.hpp`                        | FD EO main component                                       |
| `dl/sch/harq/`                                    | HARQ process management                                    |
| `dl/sch/la/DlCqiMcsCalculator.hpp`                | CQI→MCS mapping + outer-loop BLER                          |
| `dl/sch/paging/PagingHandler.hpp`                 | Paging scheduling                                          |
| `dl/sch/csi/CsiRsScheduler.hpp`                   | CSI-RS scheduling                                          |
| `dl/sch/pucch/Pucch.hpp`                          | PUCCH resource management                                  |
| `dl/sch/dss/DssManagerDl.hpp`                     | Dynamic Spectrum Sharing manager                           |
| `dl/sch/intraSchedCom/IntraSchedUpdateSender.hpp` | DL→UL slot update sender                                   |
| `dl/sch/intracore/FdSchMsgBufferizer.cpp`         | Same-core DL↔FD communication                              |
| `dl/synchro/overload/OverloadController.hpp`      | Adaptive slot time budget                                  |
| `dl/drx/DrxManager.hpp`                           | DRX state management                                       |
| `dl/db/cell/CellDbDl.hpp`                         | DL cell database                                           |
| `dl/db/cell/CellDynamicData.hpp`                  | Per-cell mutable slot state                                |
| `dl/db/ue/UeDbDl.hpp`                             | DL UE database                                             |
| `dl/db/ue/BufferStatus.hpp`                       | UE DL buffer tracking                                      |

## Document sync (source)

| Field | Value |
|-------|--------|
| **Sync date** | 2026-06-11 |
| **gNB `/workspace` git** | `45617cfb9a73` |
| **EO source** | `/workspace/uplane/L2-PS/src/dl/` (DL SCH + referenced `fd/`, `pscommon/`) |

**Verified**

- `dl/em/StateDefaultRoutes.hpp` — **111** `msgId()` route parameters for the Default-state router (count via `grep -c 'msgId()'`).
- `dl/em/Eo.hpp`, `dl/em/QueueFsm.hpp`, dispatcher headers — spot-checked against §3 FSM narrative and EO-level router bullet list.

**Doc corrections this pass**

- Added explicit **111** route count + `StateDefaultRoutes.hpp` pointer (was previously only qualitative “etc.” in the PlantUML note).
- **`diagrams/`** — all DL SCH diagram notes stamped with verification YAML; `l2ps-dlsch-runtime-position.md` edge labels aligned to **`FdScheduleReq` / `FdScheduleResp`** and L1 builder names.
- **Ordered review (DL SCH)** — `l2ps-dlsch-top-level-class-overview.md` aligned to `dl/em/Eo.hpp` (dispatcher pair, `QueuesDelayedEvents`, `RtCellDlInputBuffer`, `queueSchTime`, typed `EmFsmRouterWithDelay`); FD peer link corrected to **dependency** (separate EO); `l2ps-dlsch-runtime-position.md` intra-sched messages → **`UlToDlIntraSchedUpdate` / `DlToUlIntraSchedUpdate`**, SRS path → **`SrsBeamSelectionInd`**.

## Related

- [[navigation-nokia-home]]
- [[navigation-implementation]]

