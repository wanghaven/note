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

```
┌─────────────────────────────────────────────────────────────┐
│                          DL Core                             │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              DL SCH EO (Scheduler)                     │ │
│  │  ┌─────┬─────┬──────┐                                 │ │
│  │  │ PRE │ TD  │ FDM  │                                 │ │
│  │  └─────┴─────┴──────┘                                 │ │
│  │         │            │                                 │ │
│  │         │            └──── FdScheduleReq ────┐        │ │
│  │         │                                     ▼        │ │
│  │  ┌────────────────────────┐          ┌──────────────┐ │ │
│  │  │       POST             │  ◄───────│   DL FD EO   │ │ │
│  │  └────────────────────────┘          │     (FD)     │ │ │
│  │                            FdScheduleResp ▲          │ │ │
│  │                                           └──────────┘ │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  Sequential Flow: PRE → TD → FDM → FD → POST               │
└─────────────────────────────────────────────────────────────┘
```

**Characteristics:**
- Both EOs on same DL core
- All phases execute sequentially
- FDM runs in DL SCH EO
- FD runs in DL FD EO (same core)
- Single-threaded slot processing

---

### After: Parallel Pipeline Execution

```
┌─────────────────────────────────────┐    ┌──────────────────────────────┐
│           DL Core                    │    │         UL Core              │
│                                      │    │                              │
│  ┌──────────────────────────────┐   │    │  ┌────────────────────────┐ │
│  │     DL SCH EO                │   │    │  │    DL FD EO            │ │
│  │                              │   │    │  │                        │ │
│  │  Slot N-1:                   │   │    │  │  Slot N:               │ │
│  │  ┌────────────────────────┐  │   │    │  │  ┌──────────────────┐ │ │
│  │  │   POST (N-1)           │  │   │    │  │  │   FDM            │ │ │
│  │  └────────────────────────┘  │   │    │  │  │                  │ │ │
│  │                              │   │    │  │  │   • Add UEs to   │ │ │
│  │  NRT Message Handling:       │   │    │  │  │     Cs2Filter    │ │ │
│  │  • Check Cs2Filter           │   │    │  │  │   • Frequency    │ │ │
│  │  • Buffer if UE in filter    │   │    │  │  │     domain       │ │ │
│  │  • Process unscheduled UEs   │   │    │  │  │     multiplexing │ │ │
│  │    after FdmScheduleResp     │   │    │  │  └──────────────────┘ │ │
│  │                              │   │    │  │           │            │ │
│  │  Slot N+1:                   │   │    │  │           ▼            │ │
│  │  ┌────────────────────────┐  │   │    │  │  ┌──────────────────┐ │ │
│  │  │   PRE (N+1)            │  │   │    │  │  │   FD             │ │ │
│  │  │   TD  (N+1)            │  │   │    │  │  │                  │ │ │
│  │  └────────────────────────┘  │   │    │  │  │   • Frequency    │ │ │
│  │           │                  │   │    │  │  │     allocation   │ │ │
│  │           │                  │   │    │  │  │   • Remove UEs   │ │ │
│  │           │                  │   │    │  │  │     from filter  │ │ │
│  │           ▼                  │   │    │  │  └──────────────────┘ │ │
│  │  ──FdmScheduleReq───────────►│   │    │  │                        │ │
│  │                              │   │    │  │                        │ │
│  │  ◄──FdmScheduleResp──────────┼───┼────┼──┤  (after FDM)           │ │
│  │  │                           │   │    │  │                        │ │
│  │  ├─ Handle unscheduled UEs   │   │    │  │                        │ │
│  │  │                           │   │    │  ├──►FdScheduleReq (self) │ │
│  │  │                           │   │    │  │                        │ │
│  │  ◄──FdScheduleResp───────────┼───┼────┼──┤  (after FD)            │ │
│  │  │                           │   │    │  │                        │ │
│  │  └─► POST                    │   │    │  │                        │ │
│  │                              │   │    │  │                        │ │
│  └──────────────────────────────┘   │    │  └────────────────────────┘ │
│                                      │    │                              │
└─────────────────────────────────────┘    └──────────────────────────────┘

         ║                                                  ║
         ║  Parallel Execution Enabled by:                 ║
         ║  • Cs2Filter (message buffering)                ║
         ║  • Ping-Pong Buffers (data isolation)           ║
         ║  • BlockedTimerCallbacks (timer defer)          ║
         ║  • Two-phase response (FdmResp, then FdResp)    ║
         ╚═════════════════════════════════════════════════╝
```

**Characteristics:**
- DL SCH EO on DL core, DL FD EO on UL core
- FDM/FD moves to separate FD EO on different core
- Parallel execution: POST(N-1) + PRE/TD(N+1) || FDM/FD(N)
- Two-phase response mechanism:
  - FdmScheduleResp: Sent after FDM (early feedback on unscheduled UEs)
  - FdScheduleResp: Sent after FD (final scheduling results)
- Cs2Filter prevents race conditions
- 2x slot processing budget for pipeline slots

---

## Message Flow

### Detailed Message Exchange Sequence

```
Time ──────────────────────────────────────────────────────────────►

DL Core (DL SCH EO):                UL Core (DL FD EO):
                                    
Slot N-1 POST
    │
    ├─► Complete POST processing
    │
    ▼
Slot N Start
    │
    ├─► PRE phase for N+1
    │   • Prepare candidate sets
    │   • Update metrics
    │
    ├─► TD phase for N+1                 │
    │   • Time domain scheduling         │
    │   • Resource allocation            │
    │                                     │
    ├─────── FdmScheduleReq ────────────►│
    │       (Message ID: FdmScheduleReq) │
    │       • cs2ListsPtr                │  Slot N FDM Start
    │       • rtCellInputPingPongElemPtr │      │
    │       • fdmInputPingPongElemPtr    │      ├─► Add scheduled UEs
    │       • pointerParams              │      │   to Cs2Filter:
    │       • cellConfigDataPtr          │      │   cs2Filter.addToFilter(rnti)
    │                                     │      │
    │  NRT Message Arrives                     │
    │       ↓                             │      ├─► FDM Scheduling
    │  ┌─────────────────────┐           │      │   • Frequency division
    │  │ Check Cs2Filter     │           │      │   • Resource mapping
    │  │ if (isRntiInFilter) │           │      │   • Update CS2 lists
    │  │   → Buffer message  │           │      │
    │  │ else                │           │      ├─► FDM Complete
    │  │   → Process now     │           │      │   • Collect unscheduled UEs
    │  └─────────────────────┘           │      │
    │                                     │      │
    │◄──────── FdmScheduleResp ──────────┤◄─────┤
    │         (Message ID: FdmScheduleResp)     │
    │         • unscheduledUeList         │      │
    │                                     │      │
    ├─► Process FdmScheduleResp          │      │
    │   • Remove unscheduled UEs from    │      │
    │     Cs2Filter                       │      │
    │   • Can now process messages        │      ├─► Send FdScheduleReq
    │     for unscheduled UEs             │      │   to itself (same EO)
    │                                     │      │
    │  Timer Expires                      │      │
    │       ↓                             │      ▼
    │  ┌─────────────────────┐           │  Slot N FD Start
    │  │ Check if RNTI in    │           │      │
    │  │ Cs2Filter           │           │      ├─► FD Scheduling
    │  │ → Block callback    │           │      │   • Frequency allocation
    │  │   to                │           │      │   • DCI generation
    │  │   BlockedTimerCallbacks│        │      │   • PDSCH allocation
    │  └─────────────────────┘           │      │
    │                                     │      ├─► Remove remaining UEs
    │  Continue Slot N+1 PRE/TD           │      │   from Cs2Filter
    │                                     │      │
    │                                     │      ▼
    │◄──────── FdScheduleResp ───────────┤◄─────┘
    │         (Message ID: FdScheduleResp)
    │         • Final scheduling results
    │         • Resource usage info
    │         • Scheduled UE list
    │
    ├─► Process FdScheduleResp
    │   • All FDM/FD complete
    │
    ├─► Replay Buffered Messages
    │   • For remaining scheduled UEs
    │   blockedTimerCallbacks.runAndRemoveActions(
    │       cs2Filter.getUeRemovedFromCs2Filter())
    │
    ├─► Execute Blocked Timer Callbacks
    │
    ├─► POST Phase
    │   • Finalize slot N
    │   • Update metrics
    │
    └─► Continue to next slot
```

### Message Structure

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
    // Add UE to filter when FDM/FD starts scheduling it
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

**Usage in Message Handling**:

```cpp
// In message handler (e.g., BearerSetupReq, UserDeleteInd, etc.)
bool handleMessage(const Message& msg) {
    Rnti rnti = msg.getRnti();
    
    // Check if UE is being scheduled in parallel
    if (cs2Filter.process(rnti)) {
        // UE is in filter → buffer the message
        cs2Filter.addFilteredEvent(rnti, msg.getEvent());
        return false;  // Don't process now
    }
    
    // UE not in filter → process immediately
    processMessageImmediately(msg);
    return true;
}
```

---

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

**Timer Callback Structure**:

```cpp
struct TimerCallBackAction {
    Rnti rnti;
    TimerType timerType;  // DRX, retransmission, etc.
    std::function<void()> callback;
    
    void operator()() const { callback(); }
};
```

**Special Handling Example**:

```cpp
// DRX inactivity timer: don't run if UE was scheduled
if (action.timerType == TimerType::l2psDrxInactivityTimer &&
    runPhase == PostFdResp && 
    ue.scheduledStatus == true) {
    return false;  // Skip callback
}
```

---

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

**Key Design**: Zero-copy pointer passing

```cpp
void fillPointerParams(...) {
    auto& pointerParams = fdmScheduleReqMsg.payload().pointerParams();
    
    // Pass pointers, not copies!
    pointerParams.dssQosAccumulatorPtr() = 
        reinterpret_cast<uint64_t>(&cellDynamicData.dssQosAccumulator());
    
    pointerParams.slotTypeSelectorPtr() = 
        reinterpret_cast<uint64_t>(slotTypeSelector);
    
    pointerParams.csiPtr() = 
        reinterpret_cast<uint64_t>(&cellDynamicData.csi());
        
    // ... more pointers
}
```

---

### 4. Ping-Pong Buffer Architecture

**Purpose**: Provide isolated read/write buffers for concurrent access

**Components**:

1. **RtCellDlOutputBuffer** (`/workspace/uplane/L2-PS/src/dl/db/cell/RtCellDlOutputBuffer.hpp`)
   - TD scheduler writes output data
   - FDM/FD reads from this buffer
   - Includes: PRB usage, correlation info, load metrics

2. **RtCellInputPingPongBufferManager** (`/workspace/uplane/L2-PS/src/dl/sch/RtCellInputPingPongBufferManager.hpp`)
   - Manages double-buffering
   - Switches buffers at slot boundaries
   - Ensures clean read/write separation

3. **FdmDlPingPongBufferData** (`/workspace/uplane/L2-PS/src/dl/sch/td/FdmDlPingPongBufferData.hpp`)
   - Specific data structures for FDM
   - L1 resource information
   - Scheduling constraints

**Buffer Switching**:

```cpp
class PingPongBufferManager {
    BufferType buffers[2];  // Double buffer
    uint8_t writeIndex{0};
    
public:
    BufferType& getWriteBuffer() { return buffers[writeIndex]; }
    
    const BufferType& getReadBuffer() const { 
        return buffers[1 - writeIndex]; 
    }
    
    void swap() { writeIndex = 1 - writeIndex; }
};
```

---

### 5. FdmScheduler in FD EO

**Location**: `/workspace/uplane/L2-PS/src/fd/sch/FdmScheduler.{cpp,hpp}`

**Purpose**: Execute FDM scheduling on UL core

```cpp
class FdmScheduler {
public:
    // Main entry point from FdmScheduleReq
    void handleFdmScheduleReq(const FdmScheduleReq_t& request);
    
    // FDM scheduling logic
    void scheduleFdm(const FdmScheduleReq_t& request,
                     FdmScheduleResp_t& response);
    
    // Add UEs to Cs2Filter
    void addScheduledUesToFilter(const UeList& scheduledUes);
    
    // Remove UEs from Cs2Filter after completion
    void removeScheduledUesFromFilter(const UeList& scheduledUes,
                                      bool wasScheduled);
};
```

---

## Cs2Filter Mechanism

### Detailed Operation Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    Cs2Filter State Machine                       │
└─────────────────────────────────────────────────────────────────┘

State 1: Slot N Begins (Filter Empty)
┌──────────────────────────┐
│  DL Core: Slot N+1 PRE/TD│
│  UL Core: ---            │
│                          │
│  Cs2Filter: {}           │
│  Status: Empty           │
└──────────────────────────┘
           │
           ▼
State 2: FDM/FD Starts on UL Core
┌──────────────────────────┐
│  DL Core: Slot N+1 PRE/TD│
│  UL Core: FDM starts     │
│           ├─ UE1 selected│
│           ├─ UE2 selected│
│           └─ UE3 selected│
│                          │
│  Cs2Filter.addToFilter() │
│  Filter: {UE1, UE2, UE3} │
└──────────────────────────┘
           │
           ▼
State 3: NRT Messages Arrive on DL Core
┌─────────────────────────────────┐
│  DL Core:                        │
│    Message 1: BearerSetup(UE1)   │
│    ├─ Check: UE1 in filter?      │
│    └─► YES → Buffer message      │
│                                  │
│    Message 2: UserDelete(UE4)    │
│    ├─ Check: UE4 in filter?      │
│    └─► NO → Process immediately  │
│                                  │
│  UL Core: FDM/FD running         │
│                                  │
│  Cs2Filter:                      │
│    Filter: {UE1, UE2, UE3}       │
│    Buffered: {Msg1 for UE1}      │
└─────────────────────────────────┘
           │
           ▼
State 4: Timer Expires on DL Core
┌─────────────────────────────────┐
│  DL Core:                        │
│    Timer expired for UE2         │
│    ├─ Check: UE2 in filter?      │
│    └─► YES → Block callback      │
│                                  │
│  UL Core: FDM/FD running         │
│                                  │
│  Cs2Filter:                      │
│    Filter: {UE1, UE2, UE3}       │
│    Buffered: {Msg1 for UE1}      │
│  BlockedTimers:                  │
│    {Timer1 for UE2}              │
└─────────────────────────────────┘
           │
           ▼
State 5: FDM/FD Completes on UL Core
┌─────────────────────────────────┐
│  UL Core:                        │
│    FDM/FD complete               │
│    ├─ Send FdmScheduleResp       │
│    └─ Remove UEs from filter:    │
│       • UE1 (scheduled=true)     │
│       • UE2 (scheduled=true)     │
│       • UE3 (scheduled=false)    │
│                                  │
│  Cs2Filter.removeFromFilter()    │
│  ueRemovedFromCs2Filter:         │
│    {UE1, UE2, UE3}               │
└─────────────────────────────────┘
           │
           ▼
State 6: Replay Buffered Actions on DL Core
┌─────────────────────────────────┐
│  DL Core:                        │
│    Process FdmScheduleResp       │
│                                  │
│    Replay buffered messages:     │
│    ├─ Msg1 for UE1 → Process now │
│                                  │
│    Execute blocked timers:       │
│    ├─ Timer1 for UE2             │
│    └─► Check: UE2 scheduled?     │
│        YES → Skip DRX timer      │
│                                  │
│  Cs2Filter: {}                   │
│  Status: Clean for next slot     │
└─────────────────────────────────┘
```

### Race Condition Prevention

**Scenario**: BearerSetupReq arrives while UE is being scheduled

**Without Cs2Filter** (Race Condition):
```
Time:    0ms         5ms         10ms
         │           │           │
DL Core: │──────────BearerSetup──┤
         │           ▲           │
         │           │           │
         │    Updates UE bearers │
         │    CONFLICT!          │
         │           │           │
UL Core: │─────FDM/FD scheduling─┤
         │    Reading UE bearers │
         └───────────┴───────────┘
         CRASH or incorrect scheduling!
```

**With Cs2Filter** (Safe):
```
Time:    0ms         5ms         10ms        15ms
         │           │           │           │
DL Core: │──────────BearerSetup──┤           │
         │           │           │           │
         │    Check Cs2Filter    │           │
         │    UE in filter       │           │
         │    → Buffer message   │           │
         │                       │           │
         │                   FdmScheduleResp │
         │                       │           │
         │                  Process buffered │
UL Core: │─────FDM/FD scheduling─┤           │
         │                       │           │
         └───────────────────────┴───────────┘
         No conflict! Message processed after scheduling
```

---

## Data Isolation Strategy

### Problem Statement

FD EO on UL core cannot directly access DL SCH EO's live data structures because:
1. **Race conditions**: Concurrent read/write
2. **Cache coherency**: Different cores, different caches
3. **Memory barriers**: Expensive synchronization

### Solution: Pointer-Based Access with Ping-Pong Buffers

```
┌──────────────────────────────────────────────────────────┐
│                    Data Access Strategy                   │
└──────────────────────────────────────────────────────────┘

Read-Only Data (Safe for concurrent access):
┌─────────────────────────────────────────┐
│  • CellConfigData (configuration)       │
│  • SlotTypeSelectorSet (slot patterns)  │
│  • CellGroupConfigData (group config)   │
│  • RemoteCellConfigData (remote cells)  │
│                                         │
│  → Passed as const pointers in          │
│     FdmScheduleReq                      │
│  → No synchronization needed            │
└─────────────────────────────────────────┘

Dynamic Data (Requires isolation):
┌─────────────────────────────────────────┐
│  Ping-Pong Buffer Pattern:              │
│                                         │
│  TD Phase (DL Core):                    │
│  ┌─────────────────┐                   │
│  │ Write Buffer A  │ ◄── TD writes     │
│  └─────────────────┘                   │
│  ┌─────────────────┐                   │
│  │ Read Buffer B   │ ◄── FDM reads     │
│  └─────────────────┘                   │
│                                         │
│  Next Slot: Swap!                       │
│  ┌─────────────────┐                   │
│  │ Read Buffer A   │ ◄── FDM reads     │
│  └─────────────────┘                   │
│  ┌─────────────────┐                   │
│  │ Write Buffer B  │ ◄── TD writes     │
│  └─────────────────┘                   │
└─────────────────────────────────────────┘

Pointer Passing (Avoid copies):
┌─────────────────────────────────────────┐
│  Instead of copying:                    │
│    FdmScheduleReq.data = cellData;      │
│    (Expensive! Large structure)         │
│                                         │
│  Pass pointer:                          │
│    FdmScheduleReq.dataPtr =             │
│        reinterpret_cast<uint64_t>(      │
│            &cellData);                  │
│    (Cheap! 8 bytes)                     │
│                                         │
│  FD EO dereferences:                    │
│    auto& data = *reinterpret_cast<      │
│        CellData*>(req.dataPtr);         │
└─────────────────────────────────────────┘
```

### Data Categories and Access Patterns

| Data Category       | Access Pattern        | Synchronization                   |
| ------------------- | --------------------- | --------------------------------- |
| Cell Configuration  | Read-only pointer     | None needed                       |
| UE Configuration    | Read-only pointer     | None needed                       |
| CS2 Lists           | Passed via pointer    | Owned by FD EO during FDM         |
| Cell Dynamic Data   | Ping-pong buffer      | Buffer swap at slot boundary      |
| UE Scheduling State | Cs2Filter protection  | Filter prevents concurrent access |
| Timer State         | BlockedTimerCallbacks | Callbacks deferred                |

---

## Timeline Execution

### Normal Slot (No Parallel Execution)

```
Time: 0ms                                                    Slot Duration (e.g., 0.5ms)
      │◄───────────────────────────────────────────────────────────────────────►│
      │                                                                          │
      ├──PRE──┬──TD──┬──FDM──┬──FD──┬──POST──────────────────────────────────┤
      │       │      │       │      │                                          │
      └───────┴──────┴───────┴──────┴──────────────────────────────────────────┘
             Sequential execution on DL core
             All phases must complete within slot duration
```

### Pipeline Slot (Parallel Execution)

```
Time: 0ms           0.5ms          1.0ms          1.5ms          2.0ms
      │              │              │              │              │
Slot: │    N-1       │      N       │     N+1      │     N+2      │
      │              │              │              │              │
      
DL Core:
      │◄─POST(N-1)──►│◄──────────PRE/TD(N+1)─────►│◄─POST(N+1)──►│
      │              │ ▲                           │              │
      │              │ │                           │              │
      │              │ │ NRT Messages              │              │
      │              │ │ (buffered if              │              │
      │              │ │  UE in filter)            │              │
      │              │ │                           │              │
      │              │ └─ Cs2Filter active         │              │
      │              │                             │              │
      
UL Core:
      │              │◄────FDM/FD(N)──────────────►│              │
      │              │ │                         │ │              │
      │              │ │ Add to Cs2Filter        │ │              │
      │              │ ▼                         ▼ │              │
      │              │ UE1,UE2,UE3...    Remove all│              │
      │              │                             │              │
      │              │                             │              │
      
Messages:
      │              │                             │              │
      │              ├──FdmScheduleReq────────────►│              │
      │              │                             │              │
      │              │◄────FdmScheduleResp─────────┤              │
      │              │                             │              │

Parallel:          POST(N-1) +                  POST(N+1) +
                   PRE/TD(N+1) +                PRE/TD(N+2)
                   NRT handling                 NRT handling
                        ║                            ║
                        ║ Runs in parallel with      ║
                        ▼                            ▼
                   FDM/FD(N)                     FDM/FD(N+1)
```

### Timing Analysis

**Before (Sequential)**:
```
Total Slot Time = PRE + TD + FDM + FD + POST
                ≈ 50μs + 150μs + 100μs + 150μs + 50μs
                = 500μs
```

**After (Parallel)**:
```
DL Core Time = POST(N-1) + PRE/TD(N+1) + NRT + overhead
             ≈ 50μs + 200μs + 50μs + 50μs
             = 350μs

UL Core Time = FDM/FD(N)
             ≈ 100μs + 150μs
             = 250μs

Effective Time = max(350μs, 250μs) = 350μs

Speedup = 500μs / 350μs = 1.43x
```

**Note**: Actual speedup depends on:
- NRT message load
- Number of scheduled UEs
- FDM/FD complexity
- Cache effects

---

## Implementation Details

### Initialization Sequence

```cpp
// 1. System Startup
void Startup::createEosEqsAndGroups() {
    // Create queue groups with core affinity
    auto dlQueueGroup = std::make_shared<EmQueueGroup>("Group_DL", dlCoreId);
    auto ulQueueGroup = std::make_shared<EmQueueGroup>("Group_UL", ulCoreId);
    
    // Allocate EOs
    DlEoHandler::allocateEo("DL_SCH_EO", dlQueueGroup, ...);
    FdSchEoHandler::allocateEo("DL_FD_EO", ulQueueGroup, ...);
}

// 2. DL SCH EO Initialization
bool DlSchEo::init() {
    // Initialize Cs2Filter
    scheduler.getCandidateSets().cs2Filter.setDlFdToUlCore(
        RadParamsBase::db().rdEnableDlPipeline() != 0);
    
    // Initialize FdmSchedulerProxy
    fdmSchedulerProxy = std::make_unique<FdmSchedulerProxy>(
        nrCellGrpId,
        slotTypeSelectorSet,
        dlFdParallelSchedulerEnabled,
        ...);
    
    // Set up message routing
    setupMessageFiltering();
    
    return true;
}

// 3. FD EO Initialization  
bool FdEo::init() {
    // Create FDM scheduler
    fdmScheduler = std::make_unique<FdmScheduler>(...);
    
    // Set up FdmScheduleReq handler
    auto handler = [this](const FdmScheduleReq& req) {
        this->handleFdmScheduleReq(req);
    };
    dlFdSchedulerProxy->setFdScheduleReqHandler(std::move(handler));
    
    return true;
}
```

### Slot Processing Flow

```cpp
// DL SCH EO: Slot Handler
SlotType SlotHandler::run(CellDynamicData& cellDynamicData, 
                          const Xhfn& onAirTime) {
    // 1. Initialize pipeline for this slot
    initDLPipelineSchedule(onAirTime.xsfn());
    
    // 2. Determine if this is a pipeline slot
    auto slotType = scheduler.getPipelineSlotType(onAirTime.xsfn());
    cellGroupDynamicData.specific().pipelineSlotType() = slotType;
    
    // 3. If pipeline slot, double the budget
    if (slotType == PipelineSlotType::PIPELINE_SLOT_NORMAL) {
        cellGroupConfigData.slotProcessingDurationBudgetInNs() *= 2;
    }
    
    // 4. Run PRE phase
    scheduler.runPreScheduling(onAirTime.xsfn());
    
    // 5. Run TD phase
    scheduler.runTdScheduling(onAirTime);
    
    // 6. Prepare and send FdmScheduleReq
    prepareFdmScheduleReq(cellDynamicData, onAirTime.xsfn());
    
    // 7. Continue with next slot's PRE/TD
    // (while FDM/FD runs in parallel on UL core)
    
    return slotType;
}

// Prepare FdmScheduleReq
void prepareFdmScheduleReq(CellDynamicData& cellDynamicData,
                          const Xsfn& xsfn) {
    auto& fdmSchedElement = 
        fdmSchedulerProxy->getFdmSchedElementSafe(cellDbIndex);
    
    if (!fdmSchedElement) return;
    
    // Fill all parameters
    fdmSchedulerProxy->fillPointerParams(cell, cellDynamicData, ...);
    fdmSchedulerProxy->fillFdDlInputParams(cell, cellDynamicData, ...);
    fdmSchedulerProxy->fillMiscParams(cell, cellDynamicData, ...);
    fdmSchedulerProxy->fillRemotePucchInfo(cell, xsfn);
    
    // Send to FD EO
    fdmSchedulerProxy->sendMessageIfNeeded(cellDbIndex);
}
```

### Message Filtering

```cpp
// Message Handler with Cs2Filter
bool MainComponent::handleWithFilter(const Message& msg,
                                     em_event_t event,
                                     bool& finishInTime) {
    Rnti rnti = extractRnti(msg);
    
    // Check if UE is being scheduled in parallel
    if (scheduler.getCs2Filter().process(rnti)) {
        // Buffer the event
        if (!scheduler.getCs2Filter().addFilteredEvent(rnti, event)) {
            LG_ERR("Failed to buffer event for RNTI %u", rnti);
        }
        return false;  // Don't process now
    }
    
    // Process immediately
    return handleMessageInternal(msg, finishInTime);
}

// Timer Expiration with Blocking
void TimerManager::onTimerExpired(Rnti rnti, TimerType type,
                                  std::function<void()> callback) {
    // Check if UE is in Cs2Filter
    if (scheduler.getCs2Filter().isRntiInCs2Filter(rnti)) {
        // Block the callback
        TimerCallBackAction action{rnti, type, callback};
        blockedTimerCallbacks.addToActionList(action);
        return;
    }
    
    // Execute immediately
    callback();
}
```

### Response Handling

```cpp
// FD EO: Send FdmScheduleResp
void FdmScheduler::completeFdmScheduling(
    const FdmScheduleReq_t& req,
    FdmScheduleResp_t& resp) {
    
    // 1. Complete FD allocation
    finalizeFdAllocation(resp);
    
    // 2. Remove scheduled UEs from Cs2Filter
    for (auto& ue : scheduledUes) {
        cs2FilterProxy.removeFromFilter(ue.rnti, ue.wasScheduled);
    }
    
    // 3. Send response to DL SCH EO
    sendFdmScheduleResp(resp);
}

// DL SCH EO: Handle FdmScheduleResp
void MainComponent::handleFdmScheduleResp(
    const FdmScheduleResp_t& resp) {
    
    // 1. Process scheduling results
    processSchedulingResults(resp);
    
    // 2. Get list of UEs removed from filter
    const auto& removedUes = 
        scheduler.getCs2Filter().getUeRemovedFromCs2Filter();
    
    // 3. Replay buffered messages for those UEs
    replayBufferedMessages(removedUes);
    
    // 4. Execute blocked timer callbacks
    blockedTimerCallbacks.runAndRemoveActions(
        removedUes,
        BlockedTimerCallBackRunPhase::PostFdmResp);
    
    // 5. Clean up for next slot
    scheduler.getCs2Filter().clearUeRemovedFromCs2Filter();
    scheduler.getCs2Filter().initMessageHandling();
}
```

---

## Configuration Control

### RAD Parameters

#### rdEnableDlPipeline (0x7A2)

**Type**: Bitmap (uint8, range: 0-255)  
**Default**: 0 (disabled)  
**Description**: Controls DL pipeline feature phases

```cpp
enum DlPipelineBits {
    FDM_IN_FD_EO       = 0b00000001,  // bit 0: Move FDM to FD EO
    PIPELINE_BEHAVIOR  = 0b00000010,  // bit 1: Enable parallel execution
    OLC_ADAPTATION     = 0b00000100,  // bit 2: 2x slot budget for pipeline
    // bits 3-7: Reserved for future use
};

// Check if fully enabled
bool isPipelineEnabled() {
    return (rdEnableDlPipeline & 0b111) == 0b111;
}
```

**Usage**:
```cpp
// Phase 1: FDM in FD EO only (no parallel)
rdEnableDlPipeline = 0b001

// Phase 2: FDM in FD EO + parallel execution
rdEnableDlPipeline = 0b011

// Phase 3: Full pipeline with OLC adaptation
rdEnableDlPipeline = 0b111
```

#### Related Parameters (NOT for this feature)

These are for multi-carrier scenarios:
- `rdEnableParallelDlFdFor4CC` (0x6A3) - 4-carrier deployments
- `rdActFr2EnhParallelDlFdFor8CC` (0x784) - FR2 8-carrier deployments
- `rdActCb014680OlcImprovement` - Multi-scheduler per core OLC

---

## Performance Considerations

### Benefits

1. **Increased Throughput**: ~40% faster slot processing
2. **Better Resource Utilization**: Both cores active
3. **Improved Latency**: NRT messages don't block scheduling
4. **Scalability**: Foundation for future parallelization

### Costs

1. **Complexity**: More complex state management
2. **Memory**: Additional buffers (ping-pong, filter, blocked timers)
3. **Cache Effects**: Cross-core communication overhead
4. **Debugging**: Harder to debug race conditions

### Memory Overhead

```cpp
Cs2FilterDl:
  - Filter: ~2KB (64 UEs × 32 bytes)
  - FilteredEvents: ~5KB (64 UEs × 10 events × 8 bytes)
  - CaActionBuffer: ~1KB (20 actions × 50 bytes)
  Total: ~8KB per cell group

BlockedTimerCallbacks:
  - ActionList: ~4KB (32 timers × 4 callbacks × 32 bytes)
  Total: ~4KB per cell group

Ping-Pong Buffers:
  - RtCellDlOutputBuffer: ~10KB per buffer × 2
  - FdmInputBuffer: ~5KB per buffer × 2
  Total: ~30KB per cell

Overall: ~50KB per cell group
```

### Tuning Knobs

1. **Slot Budget Multiplier**: Currently 2x, could be tuned per deployment
2. **Filter Sizes**: Adjust based on max concurrent UEs
3. **Buffer Depths**: Increase for high message rate scenarios
4. **Pipeline Slot Selection**: Algorithm to determine which slots are pipeline slots

---

## Appendix: Key File Changes

### New Files (Core Components)

| File                                          | Lines | Purpose                      |
| --------------------------------------------- | ----- | ---------------------------- |
| `dl/sch/Cs2FilterDl.hpp`                      | 200   | Message buffering filter     |
| `dl/sch/BlockedTimerCallbacks.hpp`            | 118   | Timer callback deferral      |
| `dl/db/cell/PipelineSlotType.hpp`             | 15    | Pipeline slot classification |
| `dl/db/cell/RtCellDlOutputBuffer.hpp`         | 154   | Output buffer for TD→FDM     |
| `pscommon/sch/td/FdmSchedulerProxy.hpp`       | 486   | FDM request preparation      |
| `pscommon/sch/td/FdmSchedElement.hpp`         | -     | FDM schedule element         |
| `fd/sch/FdmScheduler.{cpp,hpp}`               | 500+  | FDM scheduler in FD EO       |
| `dl/sch/RtCellInputPingPongBufferManager.hpp` | -     | Ping-pong buffer manager     |

### Modified Files (Major Changes)

| File                                     | Changes    | Purpose                  |
| ---------------------------------------- | ---------- | ------------------------ |
| `dl/sch/SlotHandler.cpp`                 | +157 lines | Pipeline slot handling   |
| `dl/sch/FilterWrapper.cpp`               | +791 lines | CS2 filter integration   |
| `dl/sch/MainComponent.cpp`               | +148 lines | Message filtering logic  |
| `dl/em/MessageFilter.hpp`                | +147 lines | Pipeline-aware filtering |
| `dl/db/cell/CellDynamicSpecificData.cpp` | +22 lines  | Buffer management        |

### Interface Changes

| Message           | Type     | Purpose                       |
| ----------------- | -------- | ----------------------------- |
| `FdmScheduleReq`  | New      | TD → FDM request              |
| `FdmScheduleResp` | New      | FDM → TD response             |
| `FdScheduleReq`   | Existing | FDM → FD request (unchanged)  |
| `FdScheduleResp`  | Existing | FD → FDM response (unchanged) |

---

## Glossary

- **PRE**: Pre-scheduling phase (candidate selection)
- **TD**: Time Domain scheduling (resource allocation)
- **FDM**: Frequency Division Multiplexing scheduling
- **FD**: Frequency Domain scheduling (final allocation)
- **POST**: Post-scheduling phase (cleanup, metrics)
- **NRT**: Non-Real-Time messages (configuration, setup, delete)
- **CS2**: Candidate Set 2 (scheduled UE list)
- **Cs2Filter**: Filter mechanism to protect CS2 list during parallel execution
- **Pipeline Slot**: Slot where parallel execution is enabled
- **Ping-Pong Buffer**: Double buffer for concurrent read/write access
- **RNTI**: Radio Network Temporary Identifier (UE identifier)
- **EO**: Execution Object (thread of execution in event machine)

---

## Revision History

| Version | Date       | Author | Changes                 |
| ------- | ---------- | ------ | ----------------------- |
| 1.0     | 2026-01-06 | System | Initial design document |

---

*End of Document*
