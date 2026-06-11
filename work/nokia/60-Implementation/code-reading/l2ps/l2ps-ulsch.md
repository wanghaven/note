---
title: L2-PS UL Scheduler (ulSch) Architecture And Mermaid Diagrams
date: 2026-06-11
tags:
  - work/nokia/implementation
  - l2ps
status: draft
aliases:
  - L2-PS UL Scheduler (ulSch) Architecture And Mermaid Diagrams
---

# L2-PS UL Scheduler (ulSch) Architecture And Mermaid Diagrams

**Scope.** This document describes the architecture of the **UL Scheduler EO** (`L2RtPool<P>_L2PsUlYySch`) within the L2-PS subsystem. It covers the per-cell-group UL scheduling pipeline for **FR1** (TDD and FDD), including RACH, PRE/TD/FD scheduling, PUSCH/PUCCH management, SRS, CoMP, link adaptation, DRX, overload control, and inter-band CA coordination.

**Applicability.** All class and message names are verified against source code under `/workspace/uplane/L2-PS/src/ul/`. FR2-specific paths are intentionally excluded.

> **Mermaid rendering notes.**
> - `flowchart LR` diagrams use `curve: "basis"` for smooth routing.
> - `classDiagram` uses `%%{init: {"layout": "elk"}}%%` for complex layouts.
> - `stateDiagram-v2` uses `direction TB` with notes for self-loop events.
> - `sequenceDiagram` has no special init.

---

## 1. Runtime Position

```mermaid
%%{init: {"flowchart": {"curve": "basis", "nodeSpacing": 30, "rankSpacing": 50}}}%%
flowchart LR
    %% External sources
    CPRT["L3 · CP-RT"]
    L2LO["L2-LO"]

    %% L2-PS subgraph — all L2-PS EOs live here
    subgraph L2PS["L2 · PS"]
        direction LR
        SGNL["SGNL EO"]
        SYNC["SlotSynchro<br/>Service"]
        DL["DL Scheduler"]
        UL["UL Scheduler"]
        FD["FD Scheduler"]
        BBRM["BBRM"]
        SRSBM["SRS-BM"]
        PCFG["PatternConfig"]
    end

    %% L1 subgraph
    subgraph L1["L1"]
        direction LR
        L1DL["L1-DL"]
        L1UL["L1-UL"]
    end

    %% L3 → SGNL → UL
    CPRT -->|"PsCell · PsUser · PsSgnl<br/>CellSetupReq / UserSetupReq"| SGNL
    SGNL -->|"InternalCellSetupReq<br/>InternalUserSetupReq<br/>BearerSetupReq"| UL

    %% L2-LO → UL
    L2LO -->|"UlMacPduReceiveInd<br/>(BSR)"| UL

    %% SlotSynchro → UL
    SYNC -->|"SlotSynchroInd"| UL

    %% DL ↔ UL (intra-scheduler)
    DL ---|"DlToUlIntraSchedUpdate<br/>FdSchCompleteIndToUl<br/>DlToUlPdcchSlotPatterns"| UL

    %% SRS-BM → UL
    SRSBM -->|"UlSrsBeamSelectionInd<br/>SrsBeamSelectionInd"| UL

    %% BBRM → UL
    BBRM -->|"ResourceResp<br/>RimResourceResp"| UL

    %% UL → BBRM
    UL -->|"ResourceReq<br/>RimResourceReq"| BBRM

    %% UL → DL (intra-sched)
    UL -->|"UlToDlIntraSchedUpdate"| DL

    %% UL → L1
    UL -->|"PuschReceiveReq<br/>PucchReceiveReq<br/>PrachReceiveReq<br/>SrsReceiveReq<br/>PdcchSendReq"| L1UL

    %% UL → PatternConfig
    UL -->|"SlotTypeReq"| PCFG
    PCFG -->|"PatternConfigReq"| L1DL

    %% L1 feedback → UL
    L1UL -->|"PuschReceiveRespPs<br/>PucchReceiveRespPs<br/>SrsReceiveRespPs<br/>PuschReceiveRespHarqU<br/>RimReceiveRespPs"| UL

    %% UL → SGNL (responses)
    UL -.->|"InternalResp"| SGNL
    SGNL -.->|"SetupResp"| CPRT

    %% Peer UL (inter-band CA / DSS)
    UL ---|"peerctrl::<br/>ScellUlInfoUpdateInd<br/>PcellUlBufferSplitInd<br/>PcellUlPowerCtrlInd"| UL
```

---

## 2. Top-Level Class Overview

```mermaid
%%{init: {"layout": "elk"}}%%
classDiagram
direction TB

namespace em {
    class Eo {
        -schedulerMainComponent : shared_ptr~MainComponent~
        -ulCellsFsmSet : CellsFsmSet~QueueFsm, MainComponent~
        -queueSchTime : EmQueue
        -ulDispatcherStateDefault : UlDispatcherStateDefault
        -router : EmFsmRouterWithDelay
        +init() bool
    }
    class QueueFsm {
        -startupHandler : QueueStateStartup
        -defaultHandler : QueueStateDefault
        -defaultRouter : StateDefaultRouter
        -deleteHandler : QueueStateDelete
    }
    class QueueStateDefault {
        -scheduler : shared_ptr~MainComponent~
        +handle(Id, EmFsmEvent) bool
        +handleCellStopSchedulingReq(msg)
    }
    class StateDefaultRouter {
        <<MessageRouter with ~85 routed message IDs>>
    }
}

namespace sch {
    class MainComponent {
        -cell : Cell ref
        -nrCellGrpId : NrCellGrpId
        -scheduler : bfgroup::Scheduler
        -preScheduler : pre::Scheduler
        -rim : Rim
        -drxManager : DrxManager
        -overloadController : OverloadController
        -synchro5GTimeManager : SlotSynchroManager
        -slotSynchroIndHandler : SlotSynchroIndHandler
        -intraUpdateSender : IntraSchedUpdateSender
        -intraUpdateReceiver : IntraSchedUpdateReceiver
        -dssManagerUl : DssManagerUl
        -l1Resources : L1Resources
        -timerWheelSet : TimerWheelSet
        -bsr : BufferStatusReport
        -taGrant : TaGrant
        -srsReceiveReqArray : SrsReceiveReqArray
        -messageHandler : MessageHandler
        +handle(SlotSynchroInd)
        +handle(UserSetupReq)
        +handle(BearerSetupReq)
        +handle(PuschReceiveRespPs)
        +performCellSetup(...)
        +performCellDelete(...)
    }
    class SlotSynchroIndHandler {
        -scheduler : bfgroup::Scheduler ref
        -overloadController : OverloadController ref
        -slotMeasurements : SlotMeasurementsUlCore ref
        +handle(SlotSynchroInd, isFlexibleBiSlot)
        -slotHandler(onAirTime)
        -processSlotForCell(onAirTime, cellConfig, cellDynamic)
        -updateScheduler(...)
    }
}

namespace bfgroup {
    class BfgroupScheduler["bfgroup::Scheduler"] {
        -tdScheduler : td::Scheduler
        -fdSchedulerList : FdSchedulerList
        -preScheduler : pre::Scheduler ref
        -rachScheduler : rach::Scheduler
        -pucchReceiveResp : PucchReceiveResp
        -puschReceiveResp : PuschReceiveResp
        -userSetup : UserSetup
        -bearerSetupHandler : BearerSetupHandler
        -cellHandler : CellHandler
        +schedule(onAirXhfn)
        +postSchedule(onAirXsfn, cell, cellDynamic)
        +schedulePrach(onAirXsfn, isPrachFirstSlot)
        +scheduleSrs(cellConfig, isBiSlot)
    }
}

Eo *-- QueueFsm
Eo *-- MainComponent
QueueFsm *-- QueueStateDefault
QueueFsm *-- StateDefaultRouter
QueueStateDefault --> MainComponent
MainComponent *-- SlotSynchroIndHandler
MainComponent *-- BfgroupScheduler
```

---

## 3. EO FSM And Event Dispatch

Like DL, the UL Scheduler EO has a **two-tier dispatcher**:

1. **EO-level router** — `EmFsmRouterWithDelay<Direction::UPLINK, ...>` (in `ul/em/Eo.hpp`) handles cell-group-level events directly: `CellGroupSetupReq`, `CellGroupReconfigReq`, `CellGroupDeleteReq`, `GetResourceUsageReq`, `SlotSynchroInd`, `StartSlotSynchroInd`, `StopSlotSynchroInd`.
2. **Per-cell FSM** — Boost.SML `QueueFsm` with three states (Startup / Default / Delete), one per cell, managed by `CellsFsmSet<QueueFsm, MainComponent>`. The `StateDefaultRouter` then dispatches ~85 message IDs to handlers within the Default state.

```mermaid
%%{init: {'theme': 'base', 'flowchart': {'curve': 'basis'}}}%%
stateDiagram-v2
direction TB

[*] --> UlStartUpState

UlStartUpState --> UlDefaultState : CellSetupReq [guard passes]
UlDefaultState --> UlDeleteState : CellStopSchedulingReq
UlDeleteState --> UlStartUpState : CellDeleteReq [deleteGuard]

UlStartUpState --> [*] : StopEvent
UlDefaultState --> [*] : StopEvent
UlDeleteState --> [*] : StopEvent

note right of UlStartUpState
    - Allocates Cell DB and RtCell DB
    - Initializes PDCCH/RACH config
    - Stores cell parameters
    - Configures rad params
end note

note right of UlDefaultState
    - Routes ~85 message IDs via StateDefaultRouter
    - Handles SlotSynchroInd (scheduling pipeline)
    - Handles L1 receive responses
    - Handles L2-LO BSR indications
    - Handles DL↔UL intra-sched messages
    - Handles user/bearer setup/modify/delete
end note

note right of UlDeleteState
    - Cleans up cell resources
    - Transitions back to Startup for reuse
end note
```

**EQ Layout.** The UL Scheduler EO owns multiple Event Queues:

| EQ Name Pattern | Priority | Purpose |
|-----------------|----------|---------|
| `L2PsSchUlYy` | `EQ_PRIO_3` | Slot scheduling trigger (SlotSynchroInd, L1 responses) |
| `L2PsMsgUlYy` | `EQ_PRIO_2` | Non-slot messages (DlToUlIntraSchedUpdate, etc.) |
| `L2PsUsrUlYy` | `EQ_PRIO_2` | User/bearer management (UserSetupReq, BearerSetupReq) |
| `L2PsCelUlYy` | `EQ_PRIO_0` | Cell lifecycle (CellSetupReq, CellReconfigurationReq) |
| `L2PsXpiUlYy` | `EQ_PRIO_2` | DSS cross-pool-interface messages |
| `L2PsCaxUlYy` | `EQ_PRIO_2` | Inter-gNB CA messages |

---

## 4. Scheduling Pipeline (SlotSynchroInd Flow)

The core hot-path of the UL Scheduler is triggered every slot by `SlotSynchroInd` from the platform timer service.

```mermaid
%%{init: {"flowchart": {"curve": "basis", "nodeSpacing": 30, "rankSpacing": 60}}}%%
flowchart TB
    A["SlotSynchroInd received"] --> B["shouldSkipSlotSynchroInd?"]
    B -->|skip| Z["return"]
    B -->|no| C["isSynchronizationValid"]
    C -->|invalid| Z
    C -->|valid| D["handleSynchronization"]
    D --> E["handleSlotSynchroIndForOneOnAirSlot"]
    E --> F["updateSlotMeasurements<br/>(overloadControllerStartSlot, tickSlotFacade)"]
    F --> G["sendL2PsPeerMsgForFr1UlCa"]
    G --> H["slotHandler(onAirTime)"]
    H --> I["processSlotForCell"]
    I --> J["updatePreCsUes<br/>(pre::Scheduler candidate update)"]
    J --> K["triggerUeCheckingForSCellActDeact"]
    K --> L["updateSlotResources<br/>(timer wheels, token buckets, DRX)"]
    L --> M["rim.schedule()"]
    M --> N["sendUlToDlIntraSchedUpdate"]
    N --> O["updateScheduler"]
    O --> P["updateSchedulerPreProcessing<br/>(updateCs1ListWithEvents)"]
    P --> Q["selectSlotType → scheduleData"]
    Q --> R["bfgroup::Scheduler::schedule(onAirXhfn)<br/>[PRE → TD → FD pipeline]"]
    R --> S["bfgroup::Scheduler::postSchedule"]
    S --> T["slotHandlerPostProcessing<br/>(timers, slotTypeReqSender, counters, OLC)"]
    T --> U["metricsFacadeUl.endOfNewSlot"]
```

---

## 5. PRE / TD / FD Scheduling Subsystems

### 5.1 Pre-Scheduler (`pre::Scheduler`)

Responsible for CS1 list maintenance — the candidate set of UEs eligible for UL scheduling.

| Responsibility | Class |
|----------------|-------|
| CS1 list management (add/remove/prioritize) | `pre::Scheduler` |
| Random Access procedure (Msg1→Msg3) | `pre::RaProcedure` |
| Proactive scheduling | `pre::ProactiveScheduling` |
| UL HR/BR LA state transitions | `la::UlHrBrLaStateManager` |
| Friend List maintenance | `pscommon::sch::td::FlMaintainance` |

### 5.2 TD Scheduler (`td::Scheduler`)

Time-Domain scheduling: selects UEs from CS1 into CS2, applies PF metric, beam selection, PDCCH capacity check, BBRM resource coordination.

| Responsibility | Class |
|----------------|-------|
| Per-carrier scheduling | `td::CarrierScheduler` |
| PF metric computation | `td::PfMetricUl` |
| Beam selection | `pscommon::sch::td::BeamSelection` |
| PDCCH resource check | `td::pdcch::DynamicEvaluator` |
| Resource group weight | `td::SasRgWeightPostSchedAlgorithm` |
| Token bucket decrease | `td::DecreaseTokenBucket` |
| FD scheduler proxy/configurator | `td::FdSchedulerProxy`, `td::FdSchedulerConfigurator` |
| MU-MIMO SD scheduler | `td::MuMimo::SdScheduler` |

### 5.3 FD Scheduler (`fd::Scheduler`)

Frequency-Domain scheduling: PRB allocation, MCS/TBS calculation, DCI filling, PUSCH/PDCCH L1 message building.

| Responsibility | Class |
|----------------|-------|
| FD orchestration | `fd::Scheduler` |
| PRB allocation | `fd::AvailablePrbRetriever`, `fd::UlPrbRandomizer` |
| PUSCH grant building | `fd::PuschReceiveReqArray`, `fd::PuschReceiveReqArrayContainer` |
| PDCCH DCI filling | `fd::PdcchSendReq`, `fd::Dci`, `fd::DciFormat00`, `fd::DciFormat01` |
| MCS/TBS computation | `fd::McsUtils`, `fd::McsDowngradeForMaxDataRate` |
| Retransmission | `fd::ReTxScheduler` |
| SRS scheduling | `fd::srs::SrsScheduler` |
| Configured Grant Type 2 | `fd::configuredGrant::type2::CgReconfigurator` |
| Throughput pooling | `fd::throughputPooling::ThroughputHandler` |
| UL CoMP allocation | `comp::fd::Allocator`, `comp::fd::SinglePuschSlotAllocator` |
| Counters | `fd::counters::PuschCounterUpdater` |

### 5.4 PRE Stage — Sequence

```mermaid
%%{init: {'theme': 'base', 'flowchart': {'curve': 'basis'}}}%%
sequenceDiagram
    autonumber
    participant SH as SlotSynchroIndHandler
    participant MC as MainComponent (UL)
    participant BFG as bfgroup::Scheduler
    participant PRE as pre::Scheduler
    participant CS1 as Cs1ListDecision
    participant RACH as pre::RaProcedure
    participant PRO as ProactiveScheduling
    participant LA as la::UlHrBrLaStateManager
    participant FL as FlMaintainance
    participant UeDB as UeDb (UL)

    SH->>MC: updatePreCsUes(onAirTime)
    MC->>BFG: updateCs1ListWithEvents(onAirXhfn, cellDyn)
    BFG->>PRE: updateCs1ListWithEvents(xsfn, cellDyn, resetBwpSwitch)
    PRE->>CS1: updateCs1ListWithEvents(sfn, slot, caFn, nonCaFn, laMgr)

    loop for each UE in UeDb
        CS1->>UeDB: read drx/bsr/bwp/beam/la
        CS1->>CS1: insert/remove ue with priority
    end

    PRE->>RACH: processOngoingRaProcedures(xsfn)
    PRE->>PRO: kickProactiveTriggers(xsfn)
    PRE->>LA: tickHrBrTransitions(xsfn)
    PRE->>FL: maintainFriendList(xsfn)

    PRE-->>BFG: CS1 ready (per-cell)
```

### 5.5 TD Stage — Sequence (per carrier)

```mermaid
%%{init: {'theme': 'base', 'flowchart': {'curve': 'basis'}}}%%
sequenceDiagram
    autonumber
    participant BFG as bfgroup::Scheduler
    participant TD as td::Scheduler
    participant CAR as td::CarrierScheduler
    participant BEAM as pscommon::sch::td::BeamSelection
    participant PF as td::PfMetricUl
    participant DYN as td::pdcch::DynamicEvaluator
    participant MU as td::MuMimo::SdScheduler
    participant TOK as td::DecreaseTokenBucket
    participant RGW as td::SasRgWeightPostSchedAlgorithm
    participant CFG as td::FdSchedulerConfigurator

    BFG->>TD: schedule(onAirXhfn)
    loop for each carrier (cell)
        TD->>CAR: schedule(cellDbIdx, xhfn)
        CAR->>BEAM: selectAnalogBeams(cs1List)
        BEAM-->>CAR: beam assignment per UE
        loop for each UE in CS1
            CAR->>PF: computeMetric(ue, history)
            PF-->>CAR: pfWeight (UL)
        end
        CAR->>CAR: buildCs2(sortedByPfWeight)
        CAR->>DYN: checkPdcchCapacity(cs2List)
        DYN-->>CAR: pdcchCapacityOk per UE
        CAR->>MU: scheduleMuMimoSpatialDomain(cs2List)
        MU-->>CAR: muMimo groups + ports
        CAR->>TOK: decreaseTokenBucket(scheduledUes)
        CAR->>RGW: applyResourceGroupWeight()
        CAR->>CFG: configureFdScheduler(cs2List)
    end
    TD-->>BFG: CS2 ready (per cell, per beam group)
```

### 5.6 FD Stage — Sequence (per carrier)

```mermaid
%%{init: {'theme': 'base', 'flowchart': {'curve': 'basis'}}}%%
sequenceDiagram
    autonumber
    participant CAR as td::CarrierScheduler
    participant PRX as td::FdSchedulerProxy
    participant FD as fd::Scheduler
    participant RET as fd::ReTxScheduler
    participant PRB as fd::AvailablePrbRetriever
    participant RND as fd::UlPrbRandomizer
    participant MCS as fd::McsUtils
    participant CG as fd::configuredGrant::type2
    participant DCI as fd::Dci (Format00/01)
    participant SRS as fd::srs::SrsScheduler
    participant PUSCH as fd::PuschReceiveReqArray
    participant PDCCH as fd::PdcchSendReq

    CAR->>PRX: invokeFdScheduler(cs2List)
    PRX->>FD: schedule(cs2List)

    FD->>RET: scheduleRetransmissions(cs2List)
    RET-->>FD: retx UE list + prbs

    loop for each UE in cs2List
        FD->>PRB: getAvailablePrb(cell, slot)
        PRB-->>FD: prb mask
        FD->>RND: randomizePrbStart(ue, mask)
        RND-->>FD: prb start
        FD->>MCS: pickMcsTbs(ue, prbCount, slotType)
        MCS-->>FD: mcs + tbs
        opt configured grant Type 2
            FD->>CG: applyCgReconfig(ue)
        end
        FD->>DCI: fillDci(format, prb, mcs, tbs, harq)
        DCI-->>FD: pdcch payload
        FD->>PDCCH: appendPdcchSendReq(ue, dci)
        FD->>PUSCH: appendPuschReceiveReq(ue, prb, mcs, harq)
    end

    FD->>SRS: scheduleAperiodicSrs(slot)
    FD-->>PRX: return
    PRX-->>CAR: PUSCH + PDCCH messages built
```

### 5.7 Post Stage — Sequence

```mermaid
%%{init: {'theme': 'base', 'flowchart': {'curve': 'basis'}}}%%
sequenceDiagram
    autonumber
    participant SH as SlotSynchroIndHandler
    participant BFG as bfgroup::Scheduler
    participant TD as td::Scheduler
    participant CAR as td::CarrierScheduler
    participant PSRS as srs::PeriodicSrsScheduler
    participant TPUT as fd::throughputPooling::ThroughputHandler
    participant OLC as overload::OverloadController
    participant PCFG as PatternConfigSender
    participant INTRA as IntraSchedUpdateSender (UL→DL)
    participant METR as metricsFacadeUl
    participant L1 as L1-UL / L1-DL
    participant DL as DL Scheduler

    BFG->>TD: postSchedule(xsfn)
    loop for each carrier
        TD->>CAR: postSchedule(xsfn)
        CAR->>PSRS: schedulePeriodicSrs(slot)
        CAR->>TPUT: accountPooling(scheduledBytes)
    end

    BFG-->>SH: scheduling complete
    SH->>PCFG: sendSlotTypeReq()
    PCFG->>L1: SlotTypeReq

    BFG->>INTRA: sendUlToDlIntraSchedUpdate(scheduledUes, harq)
    INTRA->>DL: UlToDlIntraSchedUpdate

    SH->>OLC: endSlotMeasurements()
    SH->>METR: endOfNewSlot(slot)
```

---

## 6. DB Model

```mermaid
%%{init: {"layout": "elk"}}%%
classDiagram
direction TB

namespace CellLevel {
    class CellDb {
        <<CellDbBase~CellUlDynamicSpecific~>>
        +forVotedCell(nrCellGrpId, action)
        +forAllCellsInGroup(nrCellGrpId, action)
        +isCellGroupActive(nrCellGrpId) bool
    }
    class CellGroupDbUl {
        +cellGroupParams() CellGroup
        +slotOffset() uint
        +isEligiblePrachReceiveReq() bool
        +isDlFdSchOnULCoreEnabled() bool
    }
    class CellDynamicData {
        +specific() CellUlDynamicSpecific
        +pdcchSlotPatternData()
        +rimDelayedInPattern750() bool
    }
    class CellGroupDynamicData {
        +specific() CellGroupDynamicSpecificData
    }
    class RtCellDbUl {
        <<pre-allocated per-slot data>>
    }
}

namespace UeLevel {
    class UeDb {
        <<UeDbBase~Ue~>>
    }
    class UeDbGuard {
        <<UeDbGuard~Ue, UeDb~>>
        +deletePendingUes()
    }
    class Ue["db::Ue (UeData)"] {
        +rnti : Rnti
        +bearers
        +bsr data
        +harq processes
        +drx state
        +power headroom
        +beam state
        +la state
        +ca state
    }
}

CellDb --> CellDynamicData : per-cell dynamic
CellGroupDbUl --> CellGroupDynamicData : per-group dynamic
UeDb --> Ue : indexed by RNTI
UeDbGuard --> UeDb : RAII deletion guard
CellDb --> RtCellDbUl : pre-allocated slot data
```

**DB Access Pattern:**
- Cell DB: singleton static access via `db::CellDb::db()`
- UE DB: singleton static access via `db::UeDb::db()`
- Cell Group DB: singleton via `db::CellGroupDb::db()`
- All stores use fixed-size pre-allocated arrays (zero heap allocation on hot path)

---

## 7. Cell Bring-Up And Delete Flow

```mermaid
%%{init: {'theme': 'base', 'flowchart': {'curve': 'basis'}}}%%
sequenceDiagram
    participant CPRT as CP-RT
    participant SGNL as SGNL EO
    participant UL as UL Scheduler
    participant L1 as L1-UL

    CPRT->>SGNL: CellSetupReq
    SGNL->>UL: InternalCellSetupReq (→ CelUlYy queue)
    Note over UL: QueueStateStartup::guard()
    UL->>UL: allocateCellAndRtCellDb()
    UL->>UL: configRadParamsAndCellGroupSetupStoring()
    UL->>UL: initializationAndSlotConfiguration()
    UL->>UL: initPdcchRachConfig()
    UL->>UL: handleRtCellDynamicData()
    Note over UL: FSM → UlDefaultState
    UL->>UL: MainComponent::performCellSetup()
    UL->>UL: configureOverloadController()
    UL-->>SGNL: CellSetupResp (OK/NOK)
    SGNL-->>CPRT: CellSetupResp

    Note over UL: ... scheduling active ...

    CPRT->>SGNL: CellStopSchedulingReq
    SGNL->>UL: InternalCellStopSchedulingReq
    Note over UL: FSM → UlDeleteState
    UL->>UL: MainComponent::handle(CellStopSchedulingReq)
    UL->>UL: bfgroup::Scheduler::handleCellStopScheduling()
    CPRT->>SGNL: CellDeleteReq
    SGNL->>UL: InternalCellDeleteReq
    UL->>UL: MainComponent::performCellDelete()
    Note over UL: FSM → UlStartUpState (ready for reuse)
    UL-->>SGNL: CellDeleteResp
    SGNL-->>CPRT: CellDeleteResp
```

---

## 8. UE Configuration Flow

```mermaid
%%{init: {'theme': 'base', 'flowchart': {'curve': 'basis'}}}%%
sequenceDiagram
    participant CPRT as CP-RT
    participant SGNL as SGNL EO
    participant UL as UL Scheduler

    CPRT->>SGNL: UserSetupReq
    SGNL->>UL: InternalUserSetupReq (→ UsrUlYy queue)
    Note over UL: QueueStateDefault validates cell group/ue
    UL->>UL: bfgroup::Scheduler::handle(UserSetupReq)
    UL->>UL: UserSetup — creates UE in UeDb
    UL->>UL: DRX config, LA init, beam init
    UL-->>SGNL: UserSetupResp

    CPRT->>SGNL: BearerSetupReq
    SGNL->>UL: InternalBearerSetupReq
    UL->>UL: bfgroup::Scheduler::handle(BearerSetupReq)
    UL->>UL: BearerSetupHandler — configures DRB/SRB
    UL->>UL: Token bucket init, priority config
    UL-->>SGNL: BearerSetupResp

    CPRT->>SGNL: UserModifyReq
    SGNL->>UL: InternalUserModifyReq
    UL->>UL: MainComponent::handleUserModifyReq()
    UL->>UL: bfgroup::UserModifyHandler
    UL-->>SGNL: UserModifyResp
```

---

## 9. Slot-Level Processing Flow (Main Hot Path)

```mermaid
%%{init: {"flowchart": {"curve": "basis", "nodeSpacing": 30, "rankSpacing": 60}}}%%
flowchart TB
    subgraph PrePhase["PRE Phase"]
        A1["updateCs1ListWithEvents<br/>(CS1 list refresh: SR, BSR, DRX, timer events)"]
        A2["pre::Scheduler::schedule<br/>(updateCs1ListWithEvents, CS1 prioritization)"]
    end

    subgraph TdPhase["TD Phase"]
        B1["td::Scheduler::schedule<br/>(beam selection, PF metric, CS2 build)"]
        B2["PDCCH capacity check<br/>td::pdcch::DynamicEvaluator"]
        B3["MU-MIMO SD scheduling<br/>td::MuMimo::SdScheduler"]
        B4["Token bucket decrease"]
    end

    subgraph FdPhase["FD Phase"]
        C1["fd::Scheduler::schedule<br/>(PRB allocation per UE)"]
        C2["MCS/TBS computation"]
        C3["DCI filling (DCI 0_0 / 0_1)"]
        C4["PuschReceiveReq building"]
        C5["PdcchSendReq filling"]
    end

    subgraph PostPhase["Post-Schedule Phase"]
        D1["postSchedule<br/>(beam result send, SRS, RG weights)"]
        D2["sendSlotTypeReq → PatternConfigSender"]
        D3["Overload Control measurements"]
        D4["Counter updates, periodic logs"]
    end

    A1 --> A2
    A2 --> B1
    B1 --> B2
    B2 --> B3
    B3 --> B4
    B4 --> C1
    C1 --> C2
    C2 --> C3
    C3 --> C4
    C4 --> C5
    C5 --> D1
    D1 --> D2
    D2 --> D3
    D3 --> D4
```

---

## 10. L1 Response Processing

The UL Scheduler receives asynchronous L1 responses carrying HARQ feedback, CSI, SRS measurements, and decoded UL MAC PDU indications.

```mermaid
%%{init: {'theme': 'base', 'flowchart': {'curve': 'basis'}}}%%
sequenceDiagram
    participant L1 as L1-UL
    participant UL as UL Scheduler
    participant DL as DL Scheduler
    participant L2LO as L2-LO

    L1->>UL: PuschReceiveRespPs (HARQ ACK + CQI/PMI)
    UL->>UL: PuschReceiveResp handler<br/>(HARQ process update, LA update, CoMP SINR)
    UL->>DL: UlToDlIntraSchedUpdate (HARQ status, DL feedback)

    L1->>UL: PuschReceiveRespHarqU (HARQ-only)
    UL->>UL: HARQ process update (retransmission management)

    L1->>UL: PucchReceiveRespPs (SR, HARQ-ACK, CSI)
    UL->>UL: PucchReceiveResp handler<br/>(SR trigger, DL HARQ feedback, CSI update)
    UL->>DL: DlHarqFeedbackReq

    L1->>UL: SrsReceiveRespPs (SRS measurements)
    UL->>UL: SRS handler (beam update, LA SINR update)

    L1->>UL: RimReceiveRespPs (RIM RS measurement)
    UL->>UL: rim::Rim::handleRimReceiveResp()

    L2LO->>UL: UlMacPduReceiveInd (BSR from decoded MAC PDU)
    UL->>UL: BufferStatusReport handler<br/>(update UE buffer, scheduling request)
```

---

## 11. Output Messages

| Direction | Message | Destination | Trigger |
|-----------|---------|-------------|---------|
| UL → L1-UL | `PuschReceiveReq` | L1-UL | FD scheduler scheduled a PUSCH grant |
| UL → L1-UL | `PucchReceiveReq` | L1-UL | PUCCH resource allocated for SR/HARQ-ACK/CSI |
| UL → L1-UL | `PrachReceiveReq` | L1-UL | PRACH slot, RACH scheduler active |
| UL → L1-UL | `SrsReceiveReq` | L1-UL | Periodic/aperiodic SRS scheduled |
| UL → L1-DL | `PdcchSendReq` | L1-DL | UL DCI (DCI 0_0 / 0_1) scheduled on PDCCH |
| UL → DL | `UlToDlIntraSchedUpdate` | DL Scheduler | Per-slot UE status, HARQ, beam info |
| UL → DL | `DlHarqFeedbackReq` | DL Scheduler | DL HARQ feedback from PUCCH decode |
| UL → BBRM | `ResourceReq` / `RimResourceReq` | BBRM | Request PRB resources / RIM resources |
| UL → PatternConfig | `SlotTypeReq` | PatternConfig | Per-slot L1 slot type configuration |
| UL → L2-HI | `UlRadioLinkStatusInd` (via PsCtrl) | L2-HI DU | Split-mode detection (RLF) |
| UL → peer UL | `ScellUlControlInd` | Peer UL | Inter-band CA SCell coordination |

---

## 12. Design Issues Observed

| # | Issue | Impact | Location |
|---|-------|--------|----------|
| 1 | **God class: `MainComponent`** (400+ lines header, ~50 handle methods, ~40 owned members) | Extremely difficult to test in isolation; every change risks regression | `ul/sch/MainComponent.hpp` |
| 2 | **`SlotSynchroIndHandler` monolith** (~1500 lines `.cpp`) | Single method orchestrates all slot processing; unclear boundaries between phases | `ul/sch/mainComponent/SlotSynchroIndHandler.cpp` |
| 3 | **`bfgroup::Scheduler` conflates TD + FD + RACH + SRS + CA** | One class owns `td::Scheduler`, `FdSchedulerList`, `rach::Scheduler`, `PeriodicSrsScheduler`, plus 15+ handlers | `ul/sch/bfgroup/Scheduler.hpp` |
| 4 | **Testable mock indirection everywhere** | `#include TESTABLE_MOCK(...)` pattern forces UT mocking at class level, not interface level; complicates dependency injection | Every `.hpp` file |
| 5 | **Static singleton DB access** (`CellDb::db()`, `UeDb::db()`) | Hidden global state; impossible to run parallel unit tests | `ul/db/cell/CellDbUl.hpp`, `ul/db/ue/UeDbUl.hpp` |
| 6 | **Overload controller tightly coupled to slot handler** | OLC metrics scattered across `processSlotForCell`, `updateSchedulerPostProcessing`, and `slotHandlerPostProcessing` | `SlotSynchroIndHandler.cpp` lines 460–600 |
| 7 | **Inter-band CA logic inlined into main path** | `interbandca/pcell/` and `interbandca/scell/` handlers called unconditionally even on single-carrier cells | `MainComponent.hpp` lines 60–75 |
| 8 | **85+ message IDs in a single router** (`StateDefaultRouter`) | Flat dispatch table; no grouping by concern; adding a new message requires touching the router and the `QueueStateDefault` checker lists | `ul/em/StateDefaultRouter.hpp` |

---

## 13. Refactoring Direction (Modular Decomposition)

### Proposed Module Structure

```mermaid
%%{init: {"flowchart": {"curve": "basis", "nodeSpacing": 30, "rankSpacing": 50}}}%%
flowchart LR
    subgraph Modules["Independent Modules"]
        direction TB
        MOD_SLOT["1. Slot Orchestrator"]
        MOD_PRE["2. Pre-Scheduler<br/>(CS1 Management)"]
        MOD_TD["3. TD Scheduler"]
        MOD_FD["4. FD Scheduler<br/>+ L1 Message Builder"]
        MOD_RESP["5. L1 Response<br/>Processor"]
        MOD_SGNL["6. Signaling<br/>(Cell/UE Lifecycle)"]
        MOD_CA["7. CA + Inter-band<br/>Coordinator"]
    end

    subgraph Stores["DB Stores"]
        direction TB
        CELL_DB["Cell DB<br/>(Writer: MOD_SGNL)"]
        UE_DB["UE DB<br/>(Writer: MOD_SGNL)"]
        DYN_DB["Slot Dynamic DB<br/>(Writer: MOD_SLOT)"]
        HARQ_DB["HARQ DB<br/>(Writer: MOD_RESP)"]
    end

    MOD_SLOT -->|"calls"| MOD_PRE
    MOD_SLOT -->|"calls"| MOD_TD
    MOD_SLOT -->|"calls"| MOD_FD
    MOD_SLOT -->|"calls"| MOD_RESP

    MOD_PRE -.->|"reads"| UE_DB
    MOD_PRE -.->|"reads"| CELL_DB
    MOD_TD -.->|"reads"| UE_DB
    MOD_TD -.->|"reads"| DYN_DB
    MOD_FD -.->|"reads"| UE_DB
    MOD_FD -.->|"reads"| CELL_DB
    MOD_RESP -.->|"reads"| UE_DB
    MOD_RESP -->|"writes"| HARQ_DB
    MOD_SGNL -->|"writes"| CELL_DB
    MOD_SGNL -->|"writes"| UE_DB
    MOD_SLOT -->|"writes"| DYN_DB
    MOD_CA -.->|"reads"| UE_DB
```

### Module Definitions

| # | Module | Public Interface (max 4 methods) | DB Access |
|---|--------|----------------------------------|-----------|
| 1 | **Slot Orchestrator** | `handleSlotSynchroInd()`, `handleStopSlotSynchro()`, `configureOverload()` | Writes: Slot Dynamic DB; Reads: Cell DB |
| 2 | **Pre-Scheduler** | `updateCandidates(xsfn)`, `schedule(xsfn)`, `postSchedule(xsfn)` | Reads: UE DB, Cell DB |
| 3 | **TD Scheduler** | `schedule(xhfn, beamId)`, `postSchedule(xsfn)` | Reads: UE DB, Slot Dynamic DB |
| 4 | **FD Scheduler + L1 Builder** | `schedule(cs2List)`, `sendL1Messages()` | Reads: UE DB, Cell DB |
| 5 | **L1 Response Processor** | `handlePuschResp(msg)`, `handlePucchResp(msg)`, `handleSrsResp(msg)` | Writes: HARQ DB; Reads: UE DB |
| 6 | **Signaling (Cell/UE Lifecycle)** | `handleCellSetup(msg)`, `handleUserSetup(msg)`, `handleUserDelete(msg)`, `handleCellDelete(msg)` | Writes: Cell DB, UE DB |
| 7 | **CA + Inter-band Coordinator** | `handlePeerMsg(msg)`, `evaluatePowerSplit(xsfn)` | Reads: UE DB |

### Design Principles Applied

1. **Zero direct coupling:** Only the Slot Orchestrator (Module 1) calls other modules. Modules 2–7 never call each other.
2. **DB isolation:** Each mutable DB store has exactly ONE writer module.
3. **Interface minimalism:** Each module exposes 2–4 public methods.
4. **UT independence:** Each module testable by mocking only its DB read/write views.
5. **Hot-path guarantee:** All DB stores use fixed-size pre-allocated storage.
6. **No CRTP sharing between independent modules.**

### Self-Check Table

| Question | Answer |
|----------|--------|
| Are modules directly coupled? | No — only Slot Orchestrator calls others |
| Is mutable state shared? | No — each DB store has 1 writer, others get read-only views |
| How many modules change for a typical feature (e.g., new MCS table)? | 1 (FD Scheduler) |
| Can modules be developed in parallel? | Yes — clear interface boundaries |
| Is timing behavior independently testable? | Yes — Slot Orchestrator owns timing; others receive pre-computed time |

### Boundary clarifications (consistent with other EO refactorings)

| # | Item | Clarification |
|---|------|---------------|
| 1 | Module 1 "Slot Orchestrator" | Issues `ResourceReq` to BBRM and consumes `ResourceResp`; forwards PRB budget to Module 4 (FD Scheduler + L1 Builder). |
| 2 | Module 4 "FD Scheduler + L1 Builder" | Combines UL FD scheduling and L1 message build (PUSCH/PDCCH). This is the **UL counterpart** to FD EO's modules 3–5 — UL FD scheduling is **in-process** in UL SCH (no separate UL FD EO). |
| 3 | Module 5 "L1 Response Processor" | Sole writer of `HARQ DB`; also forwards UL→DL feedback via `UlToDlIntraSchedUpdate` and `DlHarqFeedbackReq` (consumed by DL SCH Module 6). |
| 4 | SRS-BM `UlSrsBeamSelectionInd` consumer | Consumed by Module 2 (Pre-Scheduler) via UE DB beam-state updates. |

---

## 14. Cross-EO Refactoring Consistency

This section validates that the UL SCH refactoring above is mutually consistent with the parallel proposals in `l2ps_srsbm_mermaid.md`, `l2ps_dlsch_mermaid.md`, `l2ps_fd_mermaid.md`, and `l2ps_bbrm_mermaid.md`. **You are here: UL SCH**.

### 14.1 Common refactoring shape

| Property                              | SRS-BM      | DL SCH      | UL SCH (here) | FD EO       | BBRM        |
| ------------------------------------- | ----------- | ----------- | ------------- | ----------- | ----------- |
| Module count                          | 7           | 7           | **7**         | 6           | 7           |
| Has Event Dispatcher module?          | No (FSM)    | No (FSM)    | **No (FSM)**  | Yes         | Yes         |
| Has Orchestrator / Pipeline module?   | Yes (M7)    | Yes (M1)    | **Yes (M1)**  | Yes (M2)    | No (M6 sync)|
| Single-writer DB store invariant      | ✓           | ✓           | **✓**         | ✓           | ✓           |
| ≤ 4 public methods per module         | ✓           | ✓           | **✓**         | ✓           | ✓           |
| Self-Check Table                      | ✓           | ✓           | **✓**         | ✓           | ✓           |
| Hot-path fixed-size storage           | ✓           | ✓           | **✓**         | ✓           | ✓           |

All five EOs follow the same skeleton: 6–7 independent modules, one writer per store, ≤ 4 public methods per module.

### 14.2 Inter-EO message-to-module mapping (UL SCH endpoint highlighted)

| Message                                    | Producer EO (Module)                          | Consumer EO (Module)                          |
| ------------------------------------------ | --------------------------------------------- | --------------------------------------------- |
| `FdInitInd` / `FdDeleteInd` / `FdScheduleReq` / `TdMetricOrderReq` | DL SCH                              | FD EO (M1 Event Dispatcher)                   |
| `FdScheduleResp`                           | FD EO (M5 L1 Builder)                         | DL SCH (M1 Slot Orchestrator)                 |
| `ResourceReq` / `RimResourceReq`           | DL SCH (M1), **UL SCH (M1 Slot Orchestrator)**| BBRM (M1 Dispatcher → M6 Period Sync → M7 Response Builder) |
| `ResourceResp` / `RimResourceResp`         | BBRM (M7 Response Builder)                    | DL SCH (M1), **UL SCH (M1 Slot Orchestrator → M4 FD Scheduler)** |
| `DlMetricInd`                              | DL SCH (M1)                                   | BBRM (M3 / M4 / M5)                           |
| `UlMetricInd`                              | **UL SCH (M1 Slot Orchestrator)**             | BBRM (M3 PRB / M4 UE / M5 SubCell Engines)    |
| `PuschReceiveReq` / `PucchReceiveReq` / `PrachReceiveReq` / `SrsReceiveReq` | **UL SCH (M4 FD + L1 Builder)** | L1-UL                                       |
| `PdcchSendReq` (UL DCI)                    | **UL SCH (M4 FD + L1 Builder)**               | L1-DL                                         |
| `PuschReceiveRespPs` / `PuschReceiveRespHarqU` | L1-UL                                     | **UL SCH (M5 L1 Response Processor)**         |
| `PucchReceiveRespPs`                       | L1-UL                                         | **UL SCH (M5 L1 Response Processor)**         |
| `SrsReceiveRespPs` / `RimReceiveRespPs`    | L1-UL                                         | **UL SCH (M5 L1 Response Processor)**         |
| `UlMacPduReceiveInd` (BSR)                 | L2-LO                                         | **UL SCH (M5 L1 Response Processor → M2 Pre-Scheduler)** |
| `UlToDlIntraSchedUpdate` / `DlHarqFeedbackReq` | **UL SCH (M5)**                           | DL SCH (M6 Feedback Processor)                |
| `DlToUlIntraSchedUpdate`                   | DL SCH (M6 Feedback Processor)                | **UL SCH (M5 L1 Response Processor)**         |
| `UlSrsBeamSelectionInd` / `SrsBeamSelectionInd` | SRS-BM (M6 Output Gateway)               | **UL SCH (M2 Pre-Scheduler)**, DL SCH (M2)    |
| `ScellUlControlInd` / peer CA messages     | **UL SCH (M7 CA + Inter-band Coordinator)**   | peer UL SCH (M7)                              |
| `SlotTypeReq`                              | **UL SCH (M1 Slot Orchestrator)**             | PatternConfig EO                              |
| `UlRadioLinkStatusInd`                     | **UL SCH (M5 → M7)**                          | L2-HI DU (via PsCtrl)                         |
| `CellSetupReq` / `UserSetupReq` / `*DeleteReq` | SGNL EO                                   | DL SCH (M7), **UL SCH (M6 Signaling)**, FD EO (M1), BBRM (M2), SRS-BM (M1) |
| `SlotSynchroInd`                           | Platform Timer                                | DL SCH (M1), **UL SCH (M1 Slot Orchestrator)**, BBRM (M6), SRS-BM (M7) |

### 14.3 DB store namespace check (no collisions)

Each EO owns its DB stores; identically-named stores in different docs are distinct.

| Logical concept   | SRS-BM                       | DL SCH                                 | UL SCH (here)               | FD EO                                | BBRM                                |
| ----------------- | ---------------------------- | -------------------------------------- | --------------------------- | ------------------------------------ | ----------------------------------- |
| Cell config       | `CellConfigStore`            | `CellConfigStore`                      | **Cell DB (UL local)**      | (pointer hand-off from DL SCH)       | `CellConfigStore` (pool config)     |
| UE state          | `UeRegistry`                 | `UeEligibilityStore` + `UeMetricStore` | **UE DB (UL local)**        | `EoDb` (per-slot scratch)            | `UePoolStore`                        |
| HARQ              | (n/a)                        | `HarqStore`                            | **`HARQ DB` (UL local)**    | (n/a)                                | (n/a)                                |
| PRB allocation    | (n/a)                        | `PrbAllocationStore`                   | **(FD Scheduler internal)** | (per-slot)                           | `PrbPoolStore`                       |
| L1 messages       | (n/a)                        | (FD EO owned)                          | **(built in M4 FD Scheduler)** | `L1MessageStore`                  | (n/a)                                |
| Runtime policy    | `RuntimePolicy`              | `TimeBudgetStore`                      | **`Slot Dynamic DB`**       | (slot-scoped)                        | `SyncStore`                          |

### 14.4 Observed cross-EO issues and resolutions

| # | Issue                                                                           | Resolution                                                                                                                                |
| - | ------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| 1 | UL does FD in-process (no separate UL FD EO), unlike DL                          | Intentional — UL FD is faster and doesn't need core-split. UL SCH M4 combines FD + L1 build; DL SCH externalizes to FD EO.                |
| 2 | UL `ResourceReq` producer is M1 Slot Orchestrator, DL is M4 Resource Allocator   | Both legal: DL has explicit Resource Allocator (M4); UL collapses it into Orchestrator since UL PRB allocation is part of FD scheduling.  |
| 3 | UL has no Feedback Processor module — L1 Response Processor (M5) does it         | UL M5 is functionally equivalent to DL M6. DL split is necessary because DL receives feedback indirectly via UL (PUCCH); UL receives L1 directly. |
| 4 | UL has CA / Inter-band Coordinator (M7); other EOs do not                        | Intentional — UL is the only EO with cross-cell-group/peer-EO traffic for inter-band CA. DL CA is handled inside Module 6.                |
| 5 | BBRM Period Synchronizer fires milestones that overlap UL slot ticks             | Resolved: BBRM `SyncStore` is BBRM-local. UL slot state lives in `Slot Dynamic DB`. Cross-EO via `MetricInd` / `ResourceResp` only.       |

**Conclusion**: The five refactoring proposals are **mutually consistent**. Cross-EO interaction is exclusively via typed messages, with each message having clearly identified producer/consumer modules. No DB store is shared across EOs.

---

## 15. Reading Map

| Priority | File / Directory | Purpose |
|----------|-----------------|---------|
| 1 | `ul/em/Eo.hpp` | EO shell, EQ wiring, FSM router template |
| 2 | `ul/em/QueueFsm.hpp` | Boost.SML FSM (Startup → Default → Delete) |
| 3 | `ul/em/QueueStateDefault.hpp` | Default state message dispatch |
| 4 | `ul/em/StateDefaultRouter.hpp` | Complete message-ID → handler routing table |
| 5 | `ul/sch/MainComponent.hpp` | Central coordinator, all handle() methods |
| 6 | `ul/sch/mainComponent/SlotSynchroIndHandler.cpp` | Hot-path slot pipeline (~1500 lines) |
| 7 | `ul/sch/bfgroup/Scheduler.hpp` | Beam-forming group scheduler (TD+FD+RACH+SRS) |
| 8 | `ul/sch/pre/Scheduler.hpp` | Pre-scheduler / CS1 list management |
| 9 | `ul/sch/td/Scheduler.hpp` | TD scheduler (PF metric, beam, CS2) |
| 10 | `ul/sch/fd/Scheduler.hpp` | FD scheduler (PRB, MCS, DCI, L1 message build) |
| 11 | `ul/sch/rach/Scheduler.hpp` | RACH/PRACH scheduling |
| 12 | `ul/db/cell/CellDbUl.hpp` | Cell database (static config per cell) |
| 13 | `ul/db/ue/UeDbUl.hpp` | UE database |
| 14 | `ul/db/cell/CellDynamicData.hpp` | Per-slot dynamic cell data |
| 15 | `ul/synchro/overload/OverloadController.hpp` | UL overload control |
| 16 | `ul/sch/intraSchedCom/IntraSchedUpdateSender.hpp` | UL→DL internal communication |
| 17 | `ul/sch/fd/PdcchSendReq.hpp` | PDCCH L1 message builder |
| 18 | `ul/sch/fd/PuschReceiveReqArray.hpp` | PUSCH L1 receive request array |
| 19 | `ul/sch/srs/PeriodicSrsScheduler.hpp` | Periodic SRS scheduling |
| 20 | `ul/drx/DrxManager.hpp` | UL DRX state machine |
| 21 | `ul/sch/la/UlHrBrLaStateManager.hpp` | Link Adaptation HR/BR state |
| 22 | `ul/comp/fd/Allocator.hpp` | UL CoMP frequency-domain allocator |
| 23 | `ul/sch/dss/DssManagerUl.hpp` | Dynamic Spectrum Sharing UL manager |
| 24 | `ul/sch/interbandca/pcell/NrRelSCellSetupReqHandler.hpp` | Inter-band CA PCell handler |

## Related

- [[navigation-nokia-home]]
- [[navigation-implementation]]
- [[L2PS]]
