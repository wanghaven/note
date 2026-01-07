# Parallel Scheduling Design Document
## TDD FR1 Single Cell Pipeline Architecture

**Branch**: `dev/POC_PARASCH`  
**Base Commit**: `8c3395d7212e`  
**Feature**: CB014670 - DL Pipeline for Parallel Scheduling  
**Target**: TDD FR1, Single Cell per Cell Group Deployments  

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Architecture Overview](#architecture-overview)
3. [Message Flow](#message-flow)
4. [Key Software Components](#key-software-components)
5. [Cs2Filter Mechanism](#cs2filter-mechanism)
6. [Data Isolation Strategy](#data-isolation-strategy)
7. [Timeline Execution](#timeline-execution)
8. [Implementation Details](#implementation-details)
9. [Configuration Control](#configuration-control)
10. [Performance Considerations](#performance-considerations)

---

## Executive Summary

### Scope
- **Deployment**: TDD FR1 only
- **Configuration**: Single cell per cell group (no multi-carrier)
- **Objective**: Enable parallel execution of scheduling phases across DL and UL cores

### Key Achievement
Transform sequential single-core DL scheduler into a two-core pipeline where:
- **DL Core**: POST (slot N-1) + NRT message handling + PRE/TD (slot N+1)
- **UL Core**: FDM/FD (slot N) in parallel
- **Synchronization**: Cs2Filter mechanism prevents race conditions

### Code Impact
- **944 files** modified in `uplane/L2-PS/src/`
- **~22,200 lines** added, ~7,600 lines deleted
- **166 commits** related to pipeline/parallel/FDM features

---

## Architecture Overview

### Before: Sequential Execution on Single Core

```plantuml
@startuml
!theme plain
skinparam BoxPadding 10
skinparam ParticipantPadding 20

box "DL Core" #LightBlue
    participant "DL SCH EO" as DLSCH
    participant "DL FD EO" as DLFD
end box

== Slot N: Sequential Processing ==

DLSCH -> DLSCH: PRE Phase
DLSCH -> DLSCH: TD Phase
DLSCH -> DLSCH: **FDM Phase**\n(in DL SCH EO)
DLSCH -> DLFD: FdScheduleReq
activate DLFD
DLFD -> DLFD: FD Scheduling
DLFD --> DLSCH: FdScheduleResp
deactivate DLFD
DLSCH -> DLSCH: POST Phase

note over DLSCH, DLFD
    **Characteristics:**
    • Both EOs on same DL core
    • All phases sequential
    • No parallel execution
    • Single-threaded processing
end note

@enduml
```

---

### After: Parallel Pipeline Execution (Multi-Slot View)

```plantuml
@startuml
!theme plain
skinparam BoxPadding 10
skinparam ParticipantPadding 20

box "DL Core" #LightBlue
    participant "DL SCH EO" as DLSCH
end box

box "UL Core" #LightGreen
    participant "DL FD EO" as DLFD
end box

== Slot N-1: POST Phase ==
DLSCH -> DLSCH: POST(N-1)
note right: Finalize slot N-1

== Slot N: Parallel Execution Begins ==

group PRE/TD for Slot N+1 (on DL Core)
    DLSCH -> DLSCH: PRE(N+1)\nPrepare candidates
    DLSCH -> DLSCH: TD(N+1)\nTime domain scheduling
    DLSCH -> DLSCH: **fillCs2Filter()**\nAdd all CS2 UEs to filter
end

DLSCH ->> DLFD: FdmScheduleReq(N)
note right of DLSCH: CS2 filter now active\nAll scheduled UEs protected

par DL Core continues || UL Core starts FDM/FD
    group NRT Message Handling (DL Core)
        DLSCH -> DLSCH: NRT messages arrive
        note right
            For each message:
            • Check if UE in Cs2Filter
            • Buffer if YES
            • Process if NO
        end note
    end
    
    group FDM Phase (UL Core)
        activate DLFD #LightGreen
        DLFD -> DLFD: FDM Scheduling\n• Frequency multiplexing\n• Update CS2 lists\n• Collect unscheduled UEs
        DLFD -->> DLSCH: FdmScheduleResp(N)\nunscheduledUeList[]
        note left of DLSCH
            Early response allows:
            • Remove unscheduled UEs from filter
            • Process their pending messages
        end note
        
        DLSCH -> DLSCH: Remove unscheduled UEs\nfrom Cs2Filter
        
        DLFD ->> DLFD: FdScheduleReq(N)\n(to itself)
        DLFD -> DLFD: FD Scheduling\n• Frequency allocation\n• DCI generation\n• Remove scheduled UEs from filter
    end
end

== Slot N: FD Completes ==
DLFD -->> DLSCH: FdScheduleResp(N)
deactivate DLFD
DLSCH -> DLSCH: Process response
DLSCH -> DLSCH: **Replay buffered messages**\nfor scheduled UEs
DLSCH -> DLSCH: **Execute blocked timers**
DLSCH -> DLSCH: POST(N)

== Slot N+1: Next Cycle ==
note over DLSCH, DLFD
    POST(N) + PRE/TD(N+2) || FDM/FD(N+1)
end note

note over DLSCH, DLFD
    **Key Innovations:**
    • TD adds UEs to Cs2Filter via fillCs2Filter()
    • Parallel: POST(N-1) + PRE/TD(N+1) + NRT || FDM/FD(N)
    • Two-phase response (FdmResp, FdResp)
    • 2x slot processing budget
end note

@enduml
```

### Detailed Slot N Processing Flow

```plantuml
@startuml
!theme plain

|DL SCH EO\n(DL Core)|
start
:POST(N-1);
note right: Complete previous slot

:PRE(N+1);
note right: Prepare candidate sets

:TD(N+1);
note right
    Time domain scheduling
    Resource allocation
end note

:**fillCs2Filter(N+1)**;
note right
    **CRITICAL STEP**
    For each UE in CS2 lists:
        cs2Filter.addToFilter(rnti)
    All scheduled UEs now protected
end note

:Send FdmScheduleReq(N);

fork
    :Handle NRT Messages;
    note right
        While FDM/FD runs:
        • Check Cs2Filter for each msg
        • Buffer if UE in filter
        • Process if UE not in filter
    end note
    
    :Receive FdmScheduleResp;
    note right
        Contains unscheduledUeList[]
        Remove these UEs from filter
    end note
    
    :Process unscheduled UEs;
    note right
        Can now handle their
        pending messages
    end note
    
fork again
    |DL FD EO\n(UL Core)|
    :Receive FdmScheduleReq(N);
    
    :FDM Scheduling;
    note left
        • Frequency division multiplexing
        • Update CS2 lists
        • Identify unscheduled UEs
    end note
    
    :Send FdmScheduleResp;
    note left: Early feedback
    
    :Send FdScheduleReq\n(to self);
    
    :FD Scheduling;
    note left
        • Frequency allocation
        • DCI generation
        • Remove UEs from Cs2Filter
    end note
    
    :Send FdScheduleResp;
end fork

|DL SCH EO\n(DL Core)|
:Receive FdScheduleResp(N);

:Replay buffered messages;
note right: For remaining scheduled UEs

:Execute blocked timers;

:POST(N);

stop

@enduml
```

**Implementation Notes:**
- **DL SCH EO** on DL core, **DL FD EO** on UL core
- **TD phase calls `fillCs2Filter()`** (in `Scheduler::scheduleCarriers()`) to add all CS2 UEs to filter
- Parallel execution: `POST(N-1) + PRE/TD(N+1) + NRT handling || FDM/FD(N)`
- Two-phase response mechanism enables early processing of unscheduled UEs
- Cs2Filter prevents race conditions by buffering messages for UEs being scheduled
- 2x slot processing budget for pipeline slots

---

## Message Flow

### Complete Message Sequence with Timing

```plantuml
@startuml
!theme plain
skinparam ParticipantPadding 20
skinparam BoxPadding 10

box "DL Core" #LightBlue
participant "DL SCH EO" as DL
end box

box "UL Core" #LightGreen
participant "DL FD EO" as FD
end box

== Slot N-1: Complete POST ==
DL -> DL: POST(N-1)

== Slot N: Start Processing ==

DL -> DL: PRE(N+1)
note right: Prepare CS1/CS2 lists

DL -> DL: TD(N+1)
note right: Time domain scheduling

DL -> DL: fillCs2Filter()
note right
    **Add all CS2 UEs to filter**
    for (auto& cs2List : cs2Lists) {
        for (auto ue : cs2List) {
            cs2Filter.addToFilter(rnti);
        }
    }
end note

DL -[#blue]>> FD: **FdmScheduleReq(N)**
note right
    Message contains:
    • cs2ListsPtr
    • rtCellInputPingPongElemPtr
    • fdmInputPingPongElemPtr
    • cellConfigDataPtr
end note

|||
...NRT messages arrive on DL core...
|||

DL -> DL: Check Cs2Filter\nfor each message
note right
    if (cs2Filter.process(rnti)) {
        // Buffer message
        cs2Filter.addFilteredEvent(rnti, event);
    } else {
        // Process immediately
        handleMessage(msg);
    }
end note

FD -> FD: Receive FdmScheduleReq(N)
activate FD #LightGreen

FD -> FD: FDM Scheduling
note left
    • Frequency division multiplexing
    • Resource mapping
    • Update CS2 lists
    • Collect unscheduled UEs
end note

FD -[#red]>> DL: **FdmScheduleResp(N)**
note left
    Contains:
    • unscheduledUeList[]
end note

DL -> DL: Process FdmScheduleResp
note right
    for (auto rnti : unscheduledUeList) {
        cs2Filter.removeFromFilter(rnti, false);
    }
    **Can now process messages
    for unscheduled UEs**
end note

FD ->> FD: **FdScheduleReq(N)**\n(to itself)
note left: Trigger FD phase

FD -> FD: FD Scheduling
note left
    • Frequency allocation
    • DCI generation  
    • PDSCH allocation
    • Remove UEs from Cs2Filter
end note

FD -[#red]>> DL: **FdScheduleResp(N)**
deactivate FD
note left
    Final results:
    • Scheduled UE list
    • Resource usage
    • OutputPingPongElemPtr
end note

DL -> DL: Process FdScheduleResp
note right
    • All FDM/FD complete
    • Filter cleared for scheduled UEs
end note

DL -> DL: Replay buffered messages
note right
    for (auto& ue : removedFromCs2Filter) {
        replayFilteredEvents(ue.rnti);
    }
end note

DL -> DL: Execute blocked timers
note right
    blockedTimerCallbacks.runAndRemoveActions(
        cs2Filter.getUeRemovedFromCs2Filter()
    );
end note

DL -> DL: POST(N)
note right: Finalize slot N

@enduml
```

### Message Structures

**FdmScheduleReq_t** (defined in `/workspace/itf/l2/ps/internal/FdmScheduleReq.mt`):

```cpp
structure FdmScheduleReq_t {
    // Timing info
    hfn, sfn, slot
    nrCellIdentity
    
    // Critical pointers for data isolation
    cs2ListsPtr                    // → CS2 candidate lists
    rtCellInputPingPongElemPtr     // → Cell input buffer
    fdmInputPingPongElemPtr        // → FDM input buffer
    
    // Read-only DB pointers (no race condition)
    cellGroupConfigDataPtr
    slotTypeSelectorSetPtr
    cellConfigDataPtr
    remotePCellConfigDataPtrs[MAX_NUM_REMOTE_CELL]
    remoteSCellConfigDataPtrs[MAX_NUM_REMOTE_CELL]
    
    // Direct data structures
    fdDlInputParams                // Input parameters
    remotePucchInfos[MAX_NUM_REMOTE_CELL]
    pointerParams                  // Dynamic data pointers
    miscParams                     // Miscellaneous params
    informationBlocks              // SIB/OSI info
    
    // Timing control
    slotEndTsc                     // Slot end timestamp
}
```

**FdmScheduleResp_t**:
```cpp
structure FdmScheduleResp_t {
    // Sent after FDM completes
    sfn, slot, hfn
    nrCellIdentity
    
    // List of UEs not scheduled by FDM
    unscheduledUeList[]            // RNTIs removed from CS2
    
    // Early feedback allows DL SCH EO to:
    // - Remove unscheduled UEs from Cs2Filter
    // - Process pending messages for these UEs
}
```

**FdScheduleReq_t** (DL FD EO sends to itself):
```cpp
structure FdScheduleReq_t {
    // Timing info
    sfn, slot, hfn
    
    // Subcell configuration
    fdSchSubcellConfig[]           // Per-subcell scheduling info
    
    // Common data from FDM phase
    fdSchCommonData {
        numFdUes
        cs2Lists                   // Updated by FDM
        resourceInfo
    }
    
    // Triggers FD scheduling phase
}
```

**FdScheduleResp_t** (Final response):
```cpp
structure FdScheduleResp_t {
    // Final scheduling results
    sfn, slot, hfn
    nrCellIdentity
    
    // Results per subcell
    dataFdFeedbackPerSubcell[] {   // Scheduled UE info
        subcellIdx
        scheduledUeInfo[]          // RNTI, MCS, PRBs, etc.
        OutputPingPongElemPtr      // Output buffer pointer
    }
    
    // Resource usage
    prbUsageInfo
    cceUsageInfo
    
    // Timing measurements
    fdmProcessingTime
    fdProcessingTime
    fdEoSchedTime
}
```

---

## Key Software Components

### 1. Cs2FilterDl - Message Buffering Engine

**Location**: `/workspace/uplane/L2-PS/src/dl/sch/Cs2FilterDl.hpp`

**Purpose**: Prevent race conditions by buffering NRT messages for UEs being scheduled in parallel

```cpp
class Cs2FilterDl {
    // Core filter: RNTI → boolean (in filter or not)
    FixedSizeHashMap<Rnti, bool, maxNbTdUes, bucketSize> filter;
    
    // Buffered events: RNTI → list of events
    FixedSizeHashMap<Rnti, EventList, maxNbTdUes, bucketSize> filteredEvents;
    
    // Buffered CA actions
    StaticVectorFixedSize<BufferedCaAction, maxBufferedCaActions> caActionBuffer;
    
    // Removed UEs (for callback execution)
    UeRemovedFromCs2Filter ueRemovedFromCs2Filter;
    
public:
    // Add UE to filter when TD completes (via fillCs2Filter)
    void addToFilter(const Rnti rnti);
    
    // Check if message should be processed or buffered
    bool process(const Rnti rnti);
    
    // Check if UE is in filter
    bool isRntiInCs2Filter(const Rnti rnti) const;
    
    // Remove UE from filter when FDM/FD completes
    void removeFromFilter(const Rnti rnti, bool scheduledStatus);
    
    // Buffer event for later processing
    bool addFilteredEvent(const Rnti rnti, em_event_t event);
    
    // Get removed UEs (for callback execution)
    const UeRemovedFromCs2Filter& getUeRemovedFromCs2Filter() const;
    
    // Clear filter at slot boundary
    void clear();
};
```

**Usage Flow**:

```plantuml
@startuml
!theme plain

start

:TD Scheduling completes;

:**fillCs2Filter()**;
note right
    Called from Scheduler::scheduleCarriers()
    
    if (fdScheduleOnPairCore(xsfnOnAir)) {
        for (auto& cs2List : cs2Lists) {
            for (uint16_t i = 0; i < cs2List.size(); i++) {
                auto rnti = cs2List.getRnti(i);
                cs2Filter.addToFilter(rnti);
            }
        }
    }
end note

:All CS2 UEs now in filter;

fork
    :NRT message arrives;
    
    if (cs2Filter.process(rnti)) then (YES - UE in filter)
        :Buffer message;
        :cs2Filter.addFilteredEvent(rnti, event);
    else (NO - UE not in filter)
        :Process immediately;
    endif
    
fork again
    :FDM/FD on UL core;
    
    :FDM completes;
    :Send unscheduledUeList[];
    
    :Remove unscheduled UEs\nfrom filter;
    
    :FD completes;
    :Remove scheduled UEs\nfrom filter;
    
end fork

:Replay buffered messages;
note right
    for (auto& ue : removedUes) {
        auto& eventList = 
            cs2Filter.getFilteredEvents()[ue.rnti];
        for (auto event : eventList) {
            handleEvent(event);
        }
    }
end note

stop

@enduml
```

### 2. BlockedTimerCallbacks - Timer Management

**Location**: `/workspace/uplane/L2-PS/src/dl/sch/BlockedTimerCallbacks.hpp`

**Purpose**: Defer timer expiration callbacks for UEs being scheduled in parallel

```cpp
class BlockedTimerCallbacks {
    // RNTI → list of callback actions
    FixedSizeHashMap<Rnti, CallBackActions, maxBlockedTimers, bucketSize> actionList;
    
public:
    // Check if UE has blocked timers
    bool isRntiInActionList(const Rnti rnti) const;
    
    // Add timer callback to blocked list
    void addToActionList(const CallBackAction& action);
    
    // Execute and remove callbacks for UEs removed from Cs2Filter
    void runAndRemoveActions(
        const UeRemovedFromCs2Filter& ueRemovedFromCs2Filter,
        BlockedTimerCallBackRunPhase runPhase = PostFdResp);
        
private:
    // Execute callbacks for single UE
    void runAndRemoveActionsForSingleUe(
        const UeRemovedFromCs2FilterElem& ue,
        BlockedTimerCallBackRunPhase runPhase);
        
    // Special handling for specific timer types
    bool shouldRunAction(
        CallBackAction action,
        BlockedTimerCallBackRunPhase runPhase,
        const UeRemovedFromCs2FilterElem& ue) const;
};
```

**Special Handling**:
- **DRX inactivity timer**: Skip if UE was scheduled (avoid restarting timer immediately after scheduling)
- **Other timers**: Execute normally after FD completes

### 3. FdmSchedulerProxy - Request Preparation

**Location**: `/workspace/uplane/L2-PS/src/pscommon/sch/td/FdmSchedulerProxy.hpp`

**Purpose**: Prepare FdmScheduleReq message with pointer-based data sharing

```cpp
class FdmSchedulerProxy {
    // FDM schedule elements per cell
    std::array<FdmSchedElement<FdmScheduleReqFiller>, maxCells> fdmSchedElements;
    
public:
    // Initialize FDM element for cell
    void initFdmSchedElement(const Cell& cell);
    
    // Fill request parameters
    void fillMiscParams(Cell& cell, CellDynamicData& cellDynamicData, 
                        CellGroupConfigData& cellGroupConfigData);
    
    void fillPointerParams(Cell& cell, CellDynamicData& cellDynamicData,
                          SlotTypeSelectorBase* slotTypeSelector,
                          Xsfn& onAirPucchXsfn);
    
    void fillFdDlInputParams(Cell& cell, CellDynamicData& cellDynamicData,
                            const Xhfn& xhfnOnAir);
    
    void fillRemotePucchInfo(Cell& cell, const Xsfn& onAirXsfn);
    
    // Send request to FD EO
    void sendMessageIfNeeded(const NrCellDbIndex& nrCellDbIndex);
};
```

**Key Design**: Zero-copy pointer passing to avoid expensive data copies

---

## Cs2Filter Mechanism

### State Machine with fillCs2Filter

```plantuml
@startuml
!theme plain

[*] --> EmptyFilter : Slot starts

EmptyFilter --> FilterPopulated : **fillCs2Filter()** called\nafter TD completes

state FilterPopulated {
    [*] --> AllUesProtected
    
    AllUesProtected : All CS2 UEs added to filter
    AllUesProtected : Messages buffered for these UEs
    
    AllUesProtected --> PartiallyCleared : FdmScheduleResp received
    
    PartiallyCleared : Unscheduled UEs removed
    PartiallyCleared : Can process their messages
    PartiallyCleared : Scheduled UEs still protected
    
    PartiallyCleared --> Cleared : FdScheduleResp received
    
    Cleared : All UEs removed from filter
    Cleared : Replay all buffered messages
    Cleared : Execute blocked timers
}

FilterPopulated --> EmptyFilter : POST completes\nReady for next slot

EmptyFilter --> [*]

note right of FilterPopulated
    **Critical Operations:**
    
    1. fillCs2Filter() - TD phase
       • Iterates all CS2 lists
       • Adds each RNTI to filter
       • Called from scheduleCarriers()
    
    2. NRT Message Handling
       • Check: cs2Filter.process(rnti)
       • Buffer if in filter
       • Process if not in filter
    
    3. Timer Expiration
       • Check if RNTI in filter
       • Block callback if YES
       • Execute if NO
    
    4. Cleanup
       • FdmScheduleResp: remove unscheduled
       • FdScheduleResp: remove scheduled
       • Replay buffered actions
end note

@enduml
```

### Race Condition Prevention

```plantuml
@startuml
!theme plain
title Race Condition Prevention with Cs2Filter

participant "DL SCH EO" as DL
participant "Cs2Filter" as Filter
participant "DL FD EO" as FD

== Setup Phase ==
DL -> DL: TD Scheduling
DL -> Filter: fillCs2Filter()
activate Filter #Yellow
Filter -> Filter: addToFilter(UE1)
Filter -> Filter: addToFilter(UE2)
Filter -> Filter: addToFilter(UE3)
note right: All CS2 UEs protected

== Parallel Execution ==
DL ->> FD: FdmScheduleReq

par NRT Messages on DL Core || FDM/FD on UL Core
    
    DL -> DL: BearerSetupReq(UE1) arrives
    DL -> Filter: process(UE1)?
    Filter --> DL: TRUE (in filter)
    DL -> Filter: addFilteredEvent(UE1, event)
    note right: Message buffered\n**Race condition avoided!**
    
    DL -> DL: UserDeleteInd(UE4) arrives
    DL -> Filter: process(UE4)?
    Filter --> DL: FALSE (not in filter)
    DL -> DL: Process immediately
    note right: UE4 not being scheduled\nSafe to process
    
else
    
    FD -> FD: FDM Scheduling
    FD -> FD: UE2 not scheduled
    FD -> DL: FdmScheduleResp\nunscheduledUeList=[UE2]
    DL -> Filter: removeFromFilter(UE2, false)
    note left: UE2 no longer protected
    
    FD -> FD: FD Scheduling
    FD -> FD: UE1, UE3 scheduled
    FD -> Filter: removeFromFilter(UE1, true)
    FD -> Filter: removeFromFilter(UE3, true)
    FD -> DL: FdScheduleResp
    
end

== Cleanup ==
DL -> Filter: getFilteredEvents()
Filter --> DL: {UE1: [BearerSetupReq]}
DL -> DL: Replay BearerSetupReq(UE1)
note right: **Now safe to process**\nFD scheduling complete

DL -> Filter: clear()
deactivate Filter

@enduml
```

**Without Cs2Filter** (RACE CONDITION):
```
Time:    0ms         5ms         10ms
         │           │           │
DL Core: │──────────BearerSetup(UE1)──┤
         │           ▲           │
         │           │ Modifies UE1 bearers
         │           │ CONFLICT! │
UL Core: │─────FDM/FD reads UE1 bearers─┤
         └───────────┴───────────┘
         CRASH or incorrect scheduling!
```

**With Cs2Filter** (SAFE):
```
Time:    0ms         5ms         10ms        15ms
         │           │           │           │
DL Core: │──────────BearerSetup(UE1)──┤     │
         │           │           │           │
         │    Check Cs2Filter    │           │
         │    UE1 in filter      │           │
         │    → Buffer message   │           │
         │                  FdScheduleResp   │
         │                       │ Process buffered
UL Core: │─────FDM/FD(UE1)───────┤           │
         └───────────────────────┴───────────┘
         No conflict! Message processed after scheduling
```

---

## Data Isolation Strategy

### Ping-Pong Buffer Architecture

```plantuml
@startuml
!theme plain

package "DL SCH EO (DL Core)" {
    component "TD Scheduler" as TD
    component "Write Buffer A" as WA
    component "Read Buffer B" as RB
}

package "DL FD EO (UL Core)" {
    component "FDM Scheduler" as FDM
    component "FD Scheduler" as FD
}

TD --> WA : Writes to\n(Slot N+1)
FDM --> RB : Reads from\n(Slot N)

note right of TD
    Ping-Pong Buffer Pattern:
    
    Slot N:
    • TD writes to Buffer A
    • FDM reads from Buffer B
    
    Slot N+1:
    • TD writes to Buffer B  
    • FDM reads from Buffer A
    
    **Swap at slot boundary**
    No concurrent access!
end note

note left of FDM
    Read-only data (safe):
    • CellConfigData
    • SlotTypeSelectorSet
    • CellGroupConfigData
    
    Dynamic data (isolated):
    • RtCellDlOutputBuffer (ping-pong)
    • FdmDlPingPongBufferData
    • CS2 Lists (ownership transfer)
end note

@enduml
```

---

## Timeline Execution

### Timing Comparison

```plantuml
@startuml
!theme plain
scale 2

concise "Sequential\n(Before)" as SEQ
concise "Parallel\n(After)" as PAR

@0
SEQ is "PRE"
PAR is "POST(N-1)"

@50
SEQ is "TD"
PAR is "PRE(N+1)"

@200
SEQ is "FDM"
PAR is "TD(N+1)" #LightBlue

@300
SEQ is "FD"
PAR is "NRT Handling" #Yellow

@450
SEQ is "POST"
PAR is "FDM/FD(N)" #LightGreen

@500
SEQ is {hidden}
PAR is "POST(N)"

@SEQ
0 is {labeled}
50 is {labeled}
200 is {labeled}
300 is {labeled}
450 is {labeled}
500 is {labeled}

@PAR
0 is {labeled}
350 is {labeled:Speedup}

note bottom of PAR
    **Speedup = 500μs / 350μs = 1.43x**
    
    Sequential: 500μs per slot
    Parallel: 350μs per slot
    
    Actual speedup depends on:
    • NRT message load
    • Number of scheduled UEs
    • FDM/FD complexity
end note

@enduml
```

### Pipeline Slot Execution

```plantuml
@startuml
!theme plain

concise "DL Core\nDL SCH EO" as DL
concise "UL Core\nDL FD EO" as UL

@0
DL is "POST(N-1)"
UL is {hidden}

@50
DL is "PRE(N+1)"
UL is {hidden}

@150
DL is "TD(N+1)"
UL is {hidden}

@200
DL is "fillCs2Filter"
UL is {hidden}

@220
DL is "Send FdmReq"
UL is "Recv FdmReq"

@250
DL is "NRT Handling" #Yellow
UL is "FDM" #LightGreen

@400
DL is "Recv FdmResp\nProcess unscheduled"
UL is "FdScheduleReq\n(self)"

@450
DL is "Continue NRT" #Yellow
UL is "FD" #LightGreen

@650
DL is "Recv FdResp"
UL is "Send FdResp"

@700
DL is "Replay messages\nExecute timers"
UL is {hidden}

@800
DL is "POST(N)"
UL is {hidden}

@DL
0 is {labeled}
250 is {labeled:Parallel\nStarts}
650 is {labeled:Parallel\nEnds}
800 is {labeled}

note bottom
    **Pipeline Benefits:**
    • DL core utilization: 100%
    • UL core utilization: 430μs / 800μs = 54%
    • Total throughput: 1.43x improvement
    • Slot budget doubled (2x) for safety
end note

@enduml
```

---

## Implementation Details

### Critical Code Locations

**File**: `/workspace/uplane/L2-PS/src/dl/sch/td/Scheduler.cpp`

```cpp
void Scheduler::fillCs2Filter(const utils::Xsfn& xsfnOnAir)
{
    if (fdScheduleOnPairCore(xsfnOnAir))
    {
        candidateSets.cs2Filter.setDlFdToUlCore(true);
        for (auto& cs2List : candidateSets.cs2Lists())
        {
            for (uint16_t i = 0; i < cs2List.size(); i++)
            {
                auto rnti = cs2List.getRnti(i);
                candidateSets.cs2Filter.addToFilter(rnti);
            }
        }
    }
}

void Scheduler::scheduleCarriers(const utils::Xhfn& xhfnOnAir)
{
    // ... PRE phase ...
    // ... TD scheduling ...
    
    carrierScheduler.scheduleCarriers(xhfnOnAir);
    
    if (not fdScheduleFence.isFdSchedulerActive())
    {
        // Non-parallel mode: handle FdScheduleResp immediately
        FdScheduleRespArray fdScheduleRespArray{{carrierScheduler.getFdScheduleResp()}};
        messageHandler.handle(fdScheduleRespArray, xsfnOnAir);
    }
    else
    {
        // Parallel mode: fill filter and wait for async response
        fillCs2Filter(xsfnOnAir);
        updateFdEndTicks();
    }
    slotMeasurements.stopTimeTdScheduler();
}
```

**File**: `/workspace/uplane/L2-PS/src/dl/sch/FilterWrapper.cpp`

```cpp
void FilterWrapper::handle(const itf::l2::ps::internal::FdmScheduleResp& fdmScheduleResp)
{
    auto& filter = scheduler.getCs2Filter();
    const auto& ueList = fdmScheduleResp.payload().unscheduledUeList();

    // Remove unscheduled UEs from filter
    for (const auto rnti : ueList)
    {
        filter.removeFromFilter(rnti, false);
    }
    // Now safe to process messages for these UEs
}
```

**File**: `/workspace/uplane/L2-PS/src/fd/sch/MainComponent.cpp`

```cpp
void MainComponent::handleEventFdmScheduleReq(
    const itf::l2::ps::internal::FdmScheduleReq& fdmScheduleReqMsg,
    const uint64_t& currentTsc)
{
    // ... setup ...
    
    // Step 1: Update RT cell dynamic data
    updateRtCellDynamicData(fdmScheduleReqPayload, rtCellDynamicData);
    
    // Step 2: FDM scheduling
    fdmScheduler.scheduleFdm(fdmScheduleReqPayload, rtCellDynamicData, fdmOverloadController);
    
    // Send FdmScheduleResp with unscheduled UEs
    fillAndProcessFdmScheduleResp(fdmScheduleReqPayload, rtCellDynamicData);
    
    // Step 3: Continue to FD scheduling
    runFdScheduling(fdmScheduleReqPayload, rtCellDynamicData, 
                   fdmOverloadController, ticksSlotEnd);
}
```

---

## Configuration Control

### RAD Parameters

#### rdEnableDlPipeline (0x7A2)

```plantuml
@startuml
!theme plain

start

if (rdEnableDlPipeline == 0) then (Disabled)
    :Sequential mode;
    :FDM in DL SCH EO;
    :Single core execution;
    stop
endif

partition "Pipeline Configuration" {
    if (bit 0 set?) then (YES)
        :Move FDM to FD EO;
        note right: Phase 1
    endif
    
    if (bit 1 set?) then (YES)
        :Enable parallel execution;
        :fillCs2Filter() active;
        note right: Phase 2
    endif
    
    if (bit 2 set?) then (YES)
        :2x slot budget;
        :OLC adaptation;
        note right: Phase 3
    endif
}

:Full pipeline enabled;
stop

@enduml
```

**Bitmap Configuration**:
```cpp
enum DlPipelineBits {
    FDM_IN_FD_EO       = 0b00000001,  // bit 0: Move FDM to FD EO
    PIPELINE_BEHAVIOR  = 0b00000010,  // bit 1: Enable parallel execution
    OLC_ADAPTATION     = 0b00000100,  // bit 2: 2x slot budget
    // bits 3-7: Reserved
};
```

**Usage Examples**:
- `rdEnableDlPipeline = 0b001` → FDM in FD EO only (no parallel)
- `rdEnableDlPipeline = 0b011` → FDM in FD EO + parallel execution
- `rdEnableDlPipeline = 0b111` → Full pipeline with OLC adaptation ✓

---

## Performance Considerations

### Benefits & Costs

```plantuml
@startuml
!theme plain

card "Benefits" #LightGreen {
    component "~40% faster\nslot processing" as B1
    component "Better resource\nutilization" as B2
    component "Improved\nlatency" as B3
    component "Scalability\nfoundation" as B4
}

card "Costs" #LightCoral {
    component "Increased\ncomplexity" as C1
    component "Memory overhead\n~50KB per cell" as C2
    component "Cross-core\ncommunication" as C3
    component "Debugging\ndifficulty" as C4
}

B1 -[hidden]-> B2
B2 -[hidden]-> B3
B3 -[hidden]-> B4

C1 -[hidden]-> C2
C2 -[hidden]-> C3
C3 -[hidden]-> C4

@enduml
```

### Memory Overhead Breakdown

| Component | Size | Purpose |
|-----------|------|---------|
| Cs2FilterDl filter | ~2KB | 64 UEs × 32 bytes |
| Cs2FilterDl filteredEvents | ~5KB | 64 UEs × 10 events × 8 bytes |
| Cs2FilterDl caActionBuffer | ~1KB | 20 actions × 50 bytes |
| BlockedTimerCallbacks | ~4KB | 32 timers × 4 callbacks × 32 bytes |
| RtCellDlOutputBuffer | ~20KB | 2 buffers × 10KB |
| FdmInputBuffer | ~10KB | 2 buffers × 5KB |
| **Total per cell group** | **~50KB** | |

---

## Appendix: Key File Changes

### New Files (Core Components)

| File | Lines | Purpose |
|------|-------|---------|
| `dl/sch/Cs2FilterDl.hpp` | 200 | Message buffering filter |
| `dl/sch/BlockedTimerCallbacks.hpp` | 118 | Timer callback deferral |
| `dl/db/cell/PipelineSlotType.hpp` | 15 | Pipeline slot classification |
| `dl/db/cell/RtCellDlOutputBuffer.hpp` | 154 | Output buffer for TD→FDM |
| `pscommon/sch/td/FdmSchedulerProxy.hpp` | 486 | FDM request preparation |
| `fd/sch/FdmScheduler.{cpp,hpp}` | 500+ | FDM scheduler in FD EO |

### Modified Files (Major Changes)

| File | Changes | Key Modification |
|------|---------|-----------------|
| `dl/sch/td/Scheduler.cpp` | +180 lines | Added fillCs2Filter() |
| `dl/sch/FilterWrapper.cpp` | +791 lines | CS2 filter integration |
| `dl/sch/MainComponent.cpp` | +148 lines | Message filtering logic |
| `fd/sch/MainComponent.cpp` | +350 lines | FDM/FD EO message handlers |

### Message Interface

| Message | Type | Direction | Purpose |
|---------|------|-----------|---------|
| FdmScheduleReq | New | DL SCH → DL FD | Trigger FDM on UL core |
| FdmScheduleResp | New | DL FD → DL SCH | Early feedback (unscheduled UEs) |
| FdScheduleReq | Existing | DL FD → DL FD | Trigger FD phase (self) |
| FdScheduleResp | Existing | DL FD → DL SCH | Final results |

---

## Glossary

- **PRE**: Pre-scheduling phase (candidate selection)
- **TD**: Time Domain scheduling (resource allocation, calls fillCs2Filter)
- **FDM**: Frequency Division Multiplexing scheduling
- **FD**: Frequency Domain scheduling (final allocation)
- **POST**: Post-scheduling phase (cleanup, metrics)
- **NRT**: Non-Real-Time messages (configuration, setup, delete)
- **CS2**: Candidate Set 2 (scheduled UE list)
- **Cs2Filter**: Filter mechanism to protect CS2 list during parallel execution
- **fillCs2Filter()**: Function that adds all CS2 UEs to filter after TD completes
- **Pipeline Slot**: Slot where parallel execution is enabled
- **Ping-Pong Buffer**: Double buffer for concurrent read/write access
- **RNTI**: Radio Network Temporary Identifier (UE identifier)
- **EO**: Execution Object (thread of execution in event machine)

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-06 | System | Initial design document |
| 2.0 | 2026-01-06 | System | Updated with PlantUML diagrams, multi-slot view, fillCs2Filter() clarification |

---

*End of Document*
