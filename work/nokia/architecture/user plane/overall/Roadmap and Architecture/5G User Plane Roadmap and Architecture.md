# 5G User Plane Roadmap and Architecture

# Part 1 — High-Level Architecture

---

## 1.1 Roadmap

### HW Platforms (FR1 Focus)

|                                  | Snowfish / Loki Platform                                        | Marlin / Thor Platform                                                        | GPU101                                       | Nemo / Odin Platform           |
| -------------------------------- | --------------------------------------------------------------- | ----------------------------------------------------------------------------- | -------------------------------------------- | ------------------------------ |
| Cloud Platform                   | RINLINE1                                                        | RINLINE2                                                                      | GPU101                                       | N/A                            |
| L1 Device                        | Marvell CNF95XXN Loki                                           | Marvell CNF105XXN Thor (or fused variant Magni)                               | Various server CPU + Nvidia RTX 4500 Pro GPU | Marvell Odin (2 BPHY chiplets) |
| L1 Composition on Classical      | ABIO, ASOE, ASOF: 2 x Loki; ABIN: 1 x Loki                      | ABIP/ASOG/ASOH: 1 x Thor; ABIQ: 1 x Magni                                     | N/A                                          | ABIR, ASOK: 1 x Odin           |
| L1 Composition on Cloud vDU      | RINLINE1: 1 x Loki (obsolete)                                   | RINLINE2: 1 x Thor                                                            | GPU101: 1 x CPU + 1 x GPU                    | N/A                            |
| L2 Device on Classical           | Intel Snowfish (20 or 24 x86 Atom cores)                        | Marvell CN106XXS Marlin (24 ARM cores)                                        | N/A                                          | Marvell Nemo (42 ARM cores)    |
| L2 Device on Cloud vDU/vCU       | (obsolete)                                                      | Various server CPU                                                            | Various server CPU + Nvidia GPU RTX 4500 Pro | N/A                            |
| Platform Introduced (L3 call)    | 5G21A: Classical; 23R2: RINLINE1                                | 23R2: Classical; 23R4: RINLINE2                                               | 26R3: GPU101                                 | 28R3: Classical                |
| Introduction of NR FR1 Use Cases | 5G21A: FDD; 5G21A: TDD cmW                                      | 24R1: FDD; 24R1: TDD cmW                                                      | 27R3: FDD; 27R3: TDD cmW                     | 28R3: FDD; 28R3: TDD cmW       |
| Introduction of HW Variants      | 5G21A: ABIO; 22R1: ASOE; 22R3: ABIN; 23R3: RINLINE1; 24R1: ASOF | 24R1: ABIP, ABIQ; 24R3: RINLINE2; 25R1: ASOG, ASOH; 26R3: ASOH as FHE-CPRI GW | 27R3: GPU101                                 | 28R3: ABIR; 29R1: ASOK         |

---

## 1.2 Decomposition

### Scope of 5G User Plane Domain

**System Components in Scope**
- 5G-L1-DL
- 5G-L1-UL
- 5G-L2-PS
- 5G-L2-LO
- 5G-L2-HI
- 5G-L2-SRB
- 5G-L2-TM

**External Protocol Layers in Scope**
- Air Interface Layer 1 (excluding RF)
- MAC, RLC, PDCP, SDAP (on Air Interface)
- NR UP, PDU Session User Plane Protocol, GTP-U (excluding the parts in TRSW)

## 1.3 User Plane Configuration Model

### Basic Concepts (1)

**L1 Instance** (5G-L1-DL and 5G-L1-UL)
- One instance of L1 SW and the scope for L1 SW configuration.
- The same L1 instance covers both DL and UL directions since both 5G-L1-DL and 5G-L1-UL are configured together.
- The same L1 instance can contain both LTE and 5G.
- 1 Loki = 1 L1 Instance.
- 1 Thor = 1 L1 Instance.
- 1 GPU Instance = 1 L1 Instance.
- 1 Odin = 1 L1 Instance (even with 2 BPHY chiplets per Odin; separate actions may later check feasibility of 2 independent L1 Instances for RAT isolation).

**L2RT Instance** (5G-L2-PS and 5G-L2-LO, or 5G-L2-TM)
- One instance of 5G-L2-PS and 5G-L2-LO SW, or one instance of 5G-L2-TM, and the scope of the SW configuration of these components.
- Cannot mix LTE and 5G.
- Maps to one EM instance and one Linux container.
- Multiple L2RT Instances are possible on a single processor.

**L2NRT Instance** (5G-L2-HI)
- One instance of 5G-L2-HI and the scope of the SW configuration of this component.

**Cell (NRCELL)**
- L2RT has cell contexts. L1 does not. L2NRT has limited-use cell contexts for counter and debug support.

**NRCELLGRP**
- In FR1 restricted to 1 NRCELL.
- L2RT has NRCELLGRP contexts. L1 and L2NRT do not.

**Subcell**
- L1 does not have cell context. Subcell contexts are used instead.
- The division of the cell into subcells is mainly a mechanism for easier scaling of L1 processing for MU MIMO. It makes MU MIMO largely transparent to L1 since MU MIMO can be implemented by multiplying the number of subcells instead of defining new cell types in L1. Also it is a mechanism to allow more parallelism in L1 and in the L1-L2 interface and for splitting the DL and UL parts of the L1 processing.
- Subcells are separate for DL and UL.
- DL represented by yellow color (5G-L1-DL color).
- UL represented by blue color (5G-L1-UL color).

**Nomenclature of Subcell Types**
- Letter based on numerology:
  - A — FR1 FDD with 15 kHz SCS
  - C — FR1 TDD with 30 kHz SCS
- Number based on the number of Spatial Streams: 2, 4, 8
  - Spatial Streams do not count special eAxCs in eCPRI mode for PRACH, SSBs or NDM SRS.
- Example: DL C4 is for 4 spatial streams cmW (FR1 TDD with 30 kHz SCS).

**Primary vs. Secondary Subcell**
- Primary subcell can be used for all physical channels and signals of the cell.
- Secondary subcells can be used for additional capacity for selected channels. Used only in Beamforming configurations, mainly for MU MIMO.
- Primary subcell is represented by underlining and a darker shade.

**Notation for Subcell Capabilities**

| Sub component | Type            | Meaning                                                                 |
| ------------- | --------------- | ----------------------------------------------------------------------- |
| L1 DL         | C4 (underlined) | Primary DL subcell, supporting all channels (SSB, CSI-RS, PDCCH, PDSCH) |
| L1 DL         | C4              | Secondary DL subcell, primarily intended for MU MIMO                    |
| L1 UL         | C4 (underlined) | Primary UL subcell, supporting all channels (PRACH, PUSCH, PUCCH, SRS)  |
| L1 UL         | C4              | Secondary UL subcell, primarily intended for MU MIMO                    |
**L1 Pool**
- The pooling scope of certain poolable resources in L1.
- An L1 instance contains one or more L1 Pools.
- Cannot mix LTE and 5G in the same L1 Pool.
- L1 Pools are bi-directional (same L1 pool contains both DL and UL parts). However the poolable resources are separate between DL and UL so this does not imply any pooling between the DL and UL parts.

**L1 Subpool**
- The pooling scope of certain poolable resources in L1.
- L1 Subpool is a sub-division of an L1 Pool.
- Subpools are unidirectional (each is either DL or UL).
- The L1 Pool contains one or more DL L1 Subpools + one or more UL L1 Subpools.

**L2 Pool**
- The pooling scope of certain poolable resources in L2.

**L2 Subpool**
- The pooling scope of certain poolable resources in L2.
- L2 Subpool is a sub-division of an L2 Pool.

Reference: [5G User Plane Architecture - Baseband Pooling](https://nokia.sharepoint.com/sites/5GSystemEngineering/Shared%20Documents/5G%20RAN%20A-S/5G%20User%20Plane/5G%20User%20Plane%20Architecture%20-%20Baseband%20Pooling.pptx?web=1) defines which resources are pooled on pool and subpool levels.

---

## 1.4 Cell Type and Cell Slot Model Overview

### Cell Type Categories 

Cell types are defined in the Cell Type Catalog based on Cell Technology (FDD or TDD cmW), Beamforming mode, Receiver Type and the Spatial Dimensions (nrCellType). Subcell type naming: letter A = FDD 15 kHz SCS, C = TDD 30 kHz SCS; number = spatial streams.

| Category                  | Fronthaul Modes        | Typical nrCellType Range          | DL Subcell Types                          | UL Subcell Types                      | L2RT Types     |
| ------------------------- | ---------------------- | --------------------------------- | ----------------------------------------- | ------------------------------------- | -------------- |
| FDD Non-BF                | CPRI, eCPRI 7-2a       | 1DL 2UL ... 8DL 8UL               | A1, A2, A4, A8                            | A2, A4, A8                            | GA2, GA4, GA8  |
| FDD Super Cell            | CPRI, eCPRI            | 1DL 2UL ... 4DL 4UL (per subcell) | A1..A4 + fronthaul duplication (A1F..A4F) | #subcells x A2..A4                    | —              |
| FDD BF                    | eCPRI 7-2a, eCPRI 7-2e | 4DL 8UL ... 16DL 8UL              | A4 (multiple)                             | A8, A8'8, A16'8                       | GA8, GA16      |
| TDD Non-BF (cmW)          | CPRI, eCPRI            | 2DL 2UL ... 4DL 4UL               | C2, C4                                    | C2, C4, C4S                           | GC2, GC4, GC4S |
| TDD BF eCPRI 7-2a (cmW)   | eCPRI 7-2a             | 4DL 4UL ... 16DL 8UL              | C4 (multiple)                             | C4, C8 (multiple)                     | GC4, GC8, GC16 |
| TDD BF eCPRI 7-2e (cmW)   | eCPRI 7-2e             | 4DL 2UL ... 16DL 8UL              | C4 (multiple)                             | C8'2..C8'8 (BB), C16'2..C16'8 (Radio) | GC4, GC8, GC16 |
| TDD ORAN ULPI Cat-B (cmW) | O-RAN ULPI Cat-B       | 8DL 2UL ... 16DL 8UL              | C4 (multiple)                             | C8'2..C8'8 (BB), C16'2..C16'8 (Radio) | GC8, GC16      |

For complete cell type and subcell type tables with per-nrCellType details, RRM features, and BB cell set references, see Part 2 sections 2.1 and 2.6.

### Cell Slot Model Overview

The Cell Slot Model (CSM) allows OAM to calculate supported UP configurations at runtime instead of relying on predefined configurations. It defines constraints for runtime configuration changes (cell delete/setup) without internal resource fragmentation. Scope: FR1 FDD and FR1 TDD for all HW Platforms except Xeon/Loner.

**CSM Domains:**

| Domain | Consumer                     | Providing SC | Scope         |
| ------ | ---------------------------- | ------------ | ------------- |
| L1 DL  | DL Subcell                   | 5G-L1-DL     | L1 Instance   |
| L1 UL  | UL Subcell                   | 5G-L1-UL     | L1 Instance   |
| PRACH  | UL Subcell                   | 5G-L1-UL     | L1 Instance   |
| L2RT   | FR1: Cell / Positioning Cell | 5G-L2-PS/LO  | L2RT Instance |
| DL FDF | DL Subcell                   | 5G-L1-DL     | L1 Instance   |
| UL FDF | UL Subcell                   | 5G-L1-UL     | L1 Instance   |

**Key Points:**
- Each domain forms an independent cell slot space; positions need not align between domains.
- L1 Instance = Loki or Thor or Odin. Common for LTE and 5G. Subcell placement defines L1 subpools.
- L2RT instances are separate for LTE and 5G. 5G-L2-HI has no cell slot model.
- PRACH domain (24R3 CB010448) and CSI-RS pooling groups (CB010448) apply on Thor+ for FR1 FDD.
- DL/UL FDF domain (27R3 CB014369) applies on Thor+.

**Key Principles:**
- *Subset:* Fewer cells, fewer subcells, or smaller/less-capable cells are always supported. Unused positions don't consume slots.
- *Mixing:* Different rows of CSM diagrams shall not be mixed unless noted.
- *Relation to BB Cell Sets:* Customer-visible cell sets and Nokia-internal UP configurations are subsets of CSM capabilities.

**Parameters Affecting Provided Cell Slots:** System Release, BB HW Platform, Board Type, UP Deployment, Duplex Mode and Numerology.
**Parameters Affecting Consumed Cell Slots:** System Release, BB HW Platform, RAT, Duplex Mode, Cell BW, Spatial Streams, Feature Activations (PRB pooling), Fronthaul mode.

For detailed CSM domain rules, subset principles, and restrictions, see Part 2 section 2.2.

---

## 1.5 Aspects of UP Configuration

### Feature-Defined Cell Set (Example)

CB006916: "NR ABIO BB cell sets up to 6 TDD cells eCPRI 16DL/4UL"

This feature introduces the baseband cell set of 3 cells NR FR1 TDD up to 16DL/4UL layers with eCPRI fronthaul. ABIO board can support 2 baseband cell sets (ABIO slot A and B), total 6 cells. Cell set type CB006916-A: Up to 3 cells 16DL-4UL with beamforming. Carrier bandwidth up to 100 MHz. 10GE or 25GE eCPRI link is used on ABIO.

Note: Focal Point description uses "layers" to refer to "spatial streams".

### Cell Type and Subcell Composition (Example)

Defined in the Cell Type Catalog based on Cell Technology (FDD, cmW), Beamforming mode, Receiver Type and the Spatial Dimensions (nrCellType) of the Cell.

Example: cmW (FR1 TDD) Beamforming 4RX nrCellType 16DL 4UL

| Sub component | Type         | Meaning               |
| ------------- | ------------ | --------------------- |
| L2RT          | GC16         | Cell Type in L2RT     |
| L1 DL         | C4 (primary) | Primary DL Subcell    |
| L1 DL         | C4 x3        | Secondary DL Subcells |
| L1 UL         | C4 (primary) | Primary UL Subcell    |
| L1 UL         | C4           | Secondary UL Subcell  |

### Basic and Advanced UP Configurations (24R1 Onwards)

**Rationale:** Many products and lots of porting features that need internal cell sets. Attempt to standardize UP configurations to limit efforts.

**Basic User Plane Configurations**
- Basic L1 and L2 Cell Slot Model (when CSM applicable).
- Mandatory use cases: Test Dedicated State; Commercial Cell Sets for TDD Super Cell, FDD Super Cell before pooling is introduced; RF cell sets (for eCPRI 7-2e, L1 parts only).
- Optional use cases: Internal configurations for RRM features; Internal configurations for L3 calls and parity features.
- Forbidden dependencies: All pooling features; fddCellConfigTradeOff other than maxCells; High number of cells per L2 subpool; Cell amount optimization for FR1 FDD A2 or lower; Cell amount optimization for FR1 TDD < 100 MHz; Special or customer-specific cell sets.
- All supported products shall be covered for all supported numerologies, cell types and cell bandwidths.
- Attempt to keep Basic UP Configurations and Basic Cell Slot Models stable across releases for each HW platform.

**Advanced User Plane Configurations**
- Advanced L1 and/or L2 Cell Slot Model (when CSM applicable).
- Use cases: Commercial Cell Sets; Internal configurations for pooling features and parity features for porting pooling.
- May depend on any pooling feature or other advanced mechanism.

**Temporary Subsets**
- Not separate configurations or cell slot models but merely use cases based on subsets of Basic or Advanced configurations.
- No new Temporary Subsets shown when no new development is involved.

---

## 1.6 UP Performance

### KPI Prioritization

From L2 Midterm Workshop 2025-02.

**Simplified Formula:**
Cell Throughput ∝ Slot Utilization × PRB Utilization × (MU MIMO Rank × MCS) × (1 - BLER) × TB Utilization
Where: MU MIMO Rank × MCS → Spectral Efficiency

User Plane performance and KPIs shall be optimized for realistic field conditions and in realistic SiSo configurations of the actual products. The primary KPIs for this optimization shall be cell throughput and data volume.

Secondary KPIs shall be optimized under the constraint that the primary KPIs are not negatively impacted. Secondary KPIs include:
- Slot Utilization, PRB Utilization, PDSCH or PUSCH UE/TTI
- MU MIMO Pairing / Rank, Spectral Efficiency
- MCS, BLER

Note: This does not exclude the importance of other factors such as:
- KPIs for stability and robustness (e.g. RRC success rate)
- Priorities, Fairness, QoS, Slicing
- Latency, User Throughput, Interference
- Corner cases for lab testing and demos

---
# Part 2 — Detailed Architecture and Deployment

## 2.1 Cell Type Catalogs (FR1)

### FDD Non-BF

(*) For CPRI, OBSAI or eCPRI 7-2a, nrCellType defines the number of Spatial Streams.

| System Use Case | nrCellType (*)           | RRM Feature              | 1st Cell Set (Loki) | 1st Cell Set (Thor) | DL Subcell | UL Subcell | L2RT Type | Comment                                                 |
| --------------- | ------------------------ | ------------------------ | ------------------- | ------------------- | ---------- | ---------- | --------- | ------------------------------------------------------- |
| FDD Non-BF      | 1DL 2UL (1DL 2UL Layers) | 23R1 CB008983            | 23R1                | 24R1 CB009014       | A1         | A2         | GA2       | Supports 4RX IRC for PUSCH with UL CoMP (27R1 CB008465) |
|                 | 2DL 2UL (2DL 2UL Layers) | (old feature from Loner) | 5G21A CB006814      | 24R1 CB009014       | A2         | A2         | GA2       | Supports 4RX IRC for PUSCH with UL CoMP (27R1 CB008465) |
|                 | 2DL 4UL (2DL 2UL Layers) | (old feature from Loner) | 5G21A CB006814      | 24R1 CB009014       | A2         | A4         | GA4       | Supports 8RX IRC for PUSCH with UL CoMP (27R1 CB008465) |
|                 | 4DL 4UL (4DL 2UL Layers) | (old feature from Loner) | 5G21A CB006814      | 24R1 CB009014       | A4         | A4         | GA4       | Supports 8RX IRC for PUSCH with UL CoMP (27R1 CB008465) |
|                 | 2DL 0UL (2DL 0UL Layers) | 24R3 CB008224            | 24R2                | 24R2                | A2         | -          | GA2       |                                                         |
|                 | 4DL 0UL (4DL 0UL Layers) | 24R3 CB008224            | 24R2                | 24R2                | A4         | -          | GA4       |                                                         |
|                 | 4DL 8UL (4DL 2UL Layers) | 27R1 CB014128            | (not supported)     | 27R1 CB014560       | A4         | A8         | GA8       |                                                         |
|                 | 8DL 8UL (4DL 2UL Layers) | (future)                 | (future)            | (future)            | A8         | A8         | GA8       |                                                         |

### FDD Super Cell

(*) For CPRI, OBSAI or eCPRI 7-2a, nrCellType defines the number of Spatial Streams.
(**) For super cells, streams of nrCellType are counted per super cell subcell.

| System Use Case | nrCellType (*)                | RRM Feature   | 1st Cell Set (Loki) | 1st Cell Set (Thor) | DL Subcell                 | UL Subcell     | Comment           |
| --------------- | ----------------------------- | ------------- | ------------------- | ------------------- | -------------------------- | -------------- | ----------------- |
| FDD Super Cell  | 1DL 2UL (**) (1DL 2UL Layers) | 26R2 CB009543 | 26R2 CB011061       | 26R3 CB011064       | A1 + (#subcells - 1) x A1F | #subcells x A2 | All UL sc primary |
|                 | 2DL 2UL (**) (2DL 2UL Layers) | 26R2 CB009543 | 26R2 CB011061       | 26R3 CB011064       | A2 + (#subcells - 1) x A2F | #subcells x A2 | All UL sc primary |
|                 | 2DL 4UL (**) (2DL 2UL Layers) | 26R2 CB009543 | 26R2 CB011061       | 26R3 CB011064       | A2 + (#subcells - 1) x A2F | #subcells x A4 | All UL sc primary |
|                 | 4DL 4UL (**) (4DL 2UL Layers) | 26R2 CB009543 | 26R2 CB011061       | 26R3 CB011064       | A4 + (#subcells - 1) x A4F | #subcells x A4 | All UL sc primary |

### FDD BF

(*) For CPRI, OBSAI or eCPRI 7-2a, nrCellType defines the number of Spatial Streams.

| System Use Case   | nrCellType (*)           | RRM Feature                                 | 1st Cell Set (Loki) | 1st Cell Set (Thor) | DL Subcell | UL Subcell | L2RT Type | Comment |
| ----------------- | ------------------------ | ------------------------------------------- | ------------------- | ------------------- | ---------- | ---------- | --------- | ------- |
| FDD BF eCPRI 7-2a | 4DL 8UL (4DL 2UL Layers) | 26R2 CB013442 / CB008577                    | (not supported)     | 26R2 CB015905       | A4         | A8         | GA8       |         |
|                   | 8DL 8UL (8DL 2UL Layers) | 27R2 CB007567 (Loki) / 27R3 CB016418 (Thor) |                     | 27R3 CB016479       | A4 A4      | A8         | GA8       |         |

| System Use Case                                 | nrCellType (*)       | 1st Cell Set (Thor) | DL Subcell (BB and Radio) | UL Subcell (BB) | UL Subcell (Radio) | L2RT Type |
| ----------------------------------------------- | -------------------- | ------------------- | ------------------------- | --------------- | ------------------ | --------- |
| FDD BF (eCPRI 7-2e) Both UL and DL in 7-2e mode | 8DL 8UL              | 27R3 CB016430       | A4 A4                     | A8'8            | A16'8              | GA16      |
|                                                 | 16DL 8UL             |                     | A4 A4 A4 A4               | A8'8            | A16'8              | GA16      |
|                                                 | 16DL 8UL w/ 32RX IRC |                     | A4 A4 A4 A4               | A8'8            | A16'4 A16'4        | GA16      |

### TDD Non-BF (FR1 cmW)

(*) For CPRI, OBSAI or eCPRI 7-2a, nrCellType defines the number of Spatial Streams.
(**) For super cells, streams of nrCellType are counted per super cell subcell.

| System Use Case                   | nrCellType (*)                | RRM Feature              | 1st Cell Set (Loki) | 1st Cell Set (Thor) | DL Subcell | UL Subcell | L2RT Type | Comment        |
| --------------------------------- | ----------------------------- | ------------------------ | ------------------- | ------------------- | ---------- | ---------- | --------- | -------------- |
| cmW Non-BF (CPRI or eCPRI)        | 2DL 2UL (2DL 2UL Layers)      | (old feature from Loner) | 5G21A 5GC002340     | 24R1 CB009142       | C2         | C2         | GC2       |                |
|                                   | 4DL 4UL (4DL 2UL Layers)      | (old feature from Loner) | 5G21A 5GC002340     | 24R1 CB009142       | C4         | C4         | GC4       |                |
| cmW Non-BF NRPOSCELL              | 0DL 4UL (0DL 0UL Layers)      | 25R2 SiSo CB010680       | (not planned)       | 25R2 CB010680       | none       | C4S        | GC4S      |                |
| cmW Sub-Sectorization (eCPRI 7-2) | 2DL 2UL (2DL 2UL Layers)      | (old feature from Loner) | 5G21A 5GC002340     | (not planned)       | C2         | C2         | GC2       | 8T8R           |
|                                   | 4DL 2UL (4DL 2UL Layers)      | (old feature from Loner) | 5G21A 5GC002340     | (not planned)       | C4         | C2         | GC4       | 8T8R           |
| cmW Super Cell (CPRI or eCPRI)    | 2DL 2UL (**) (2DL 2UL Layers) | 23R1 CB008985            | 23R1 CB008434       | 24R1 CB009142       | #SSBs x C2 | #SSBs x C2 | GC2       | All sc primary |
|                                   | 4DL 4UL (**) (4DL 2UL Layers) | 23R1 CB008985            | 23R1 CB008434       | 24R1 CB009142       | #SSBs x C4 | #SSBs x C4 | GC4       | All sc primary |

### TDD BF eCPRI 7-2a (FR1 cmW)

(*) For CPRI, OBSAI or eCPRI 7-2a, nrCellType defines the number of Spatial Streams.

| System Use Case             | nrCellType (*)             | RRM Feature              | 1st Cell Set (Loki) | 1st Cell Set (Thor)  | DL Subcell  | UL Subcell | L2RT Type | Comment     |
| --------------------------- | -------------------------- | ------------------------ | ------------------- | -------------------- | ----------- | ---------- | --------- | ----------- |
| cmW BF (eCPRI 7-2) with 4RX | 4DL 4UL (4DL 2UL Layers)   | (old feature from Loner) | 5G21A 5GC002340     | 24R1 CB009142        | C4          | C4         | GC4       | MAA or 8T8R |
|                             | 4DL 4UL (4DL 2UL Layers)   | CB010250/CB012180?       | (not planned)       | ~27R2                | C8          | C4 + BF    | GC8       | 8T8R RF8    |
|                             | 4DL 8UL (4DL 2UL Layers)   | CB010250/CB012180?       | (not planned)       | ~27R2                | C8          | C8         | GC8       | 8T8R RF8    |
|                             | 8DL 4UL (8DL 2UL Layers)   | 5G21A 5GC000524          | 5G21A 5GC002339     | 24R1 CB009142        | C4 C4       | C4         | GC8       | MAA         |
|                             | 16DL 4UL (16DL 2UL Layers) | 23R1 CB008701            | 23R3 CB008149       | 24R1 CB009008        | C4 C4 C4 C4 | C4         | GC16      | MAA         |
|                             | 8DL 8UL (8DL 4UL Layers)   | 23R1 CB008360            | 23R1 CB009403       | 24R1 CB009142        | C4 C4       | C4 C4      | GC8       | MAA         |
|                             | 16DL 8UL (16DL 4UL Layers) | 23R1 (combination)       | 23R1 CB009403       | 24R1 CB009008        | C4 C4 C4 C4 | C4 C4      | GC16      | MAA         |
| cmW BF (eCPRI 7-2) with 8RX | 16DL 8UL (16DL 4UL Layers) | 23R3...24R1 CB009363     | (not planned)       | 23R3...24R1 CB009363 | C4 C4 C4 C4 | C8         | GC16      | MAA         |
|                             | 8DL 8UL (8DL 4UL Layers)   | 23R3...24R1 CB009363     | (not planned)       | 23R3...24R1 CB009363 | C4 C4       | C8         | GC8       | MAA         |

### TDD BF eCPRI 7-2e (FR1 cmW)

(*) For eCPRI 7-2e, nrCellType defines the maximum number of Layers.

| System Use Case                                 | nrCellType (*)         | RRM Feature    | 1st Cell Set (Thor)                            | DL Subcell (BB and Radio) | UL Subcell (BB) | UL Subcell (Radio) | L2RT Type |
| ----------------------------------------------- | ---------------------- | -------------- | ---------------------------------------------- | ------------------------- | --------------- | ------------------ | --------- |
| cmW BF (eCPRI 7-2e) Both UL and DL in 7-2e mode | 4DL 2UL                | ~25R2 CB010708 | 25R3 CB009843                                  | C4                        | C8'2            | C16'2              | GC4       |
|                                                 | 8DL 2UL                | ~25R2 CB010708 | 25R3 CB009843                                  | C4 C4                     | C8'2            | C16'2              | GC8       |
|                                                 | 8DL 4UL                | ~25R2 CB010708 | 25R3 CB009843                                  | C4 C4                     | C8'4            | C16'4              | GC8       |
|                                                 | 8DL 8UL                | 26R1 CB008235  | 26R1 CB009843                                  | C4 C4                     | C8'8            | C16'8              | GC8       |
|                                                 | 16DL 2UL               | ~25R2 CB009514 | 25R3 CB009843                                  | C4 C4 C4 C4               | C8'2            | C16'2              | GC16      |
|                                                 | 16DL 4UL               | ~25R2 CB010708 | 25R3 CB009843                                  | C4 C4 C4 C4               | C8'4            | C16'4              | GC16      |
|                                                 | 16DL 8UL               | 26R1 CB008235  | 26R1 CB009843                                  | C4 C4 C4 C4               | C8'8            | C16'8              | GC16      |
|                                                 | 16DL 8UL w/ 2x16RX IRC | 27R2 CB016111  | (applied as RRM change to legacy BB cell sets) | C4 C4 C4 C4               | C8'8            | C16'4 C16'4        | GC16      |

### TDD ORAN ULPI Cat-B (FR1 cmW)

(*) nrCellType defines the maximum number of Layers.

| System Use Case           | nrCellType (*) | RRM Feature                          | 1st Cell Set (Thor)                    | DL Subcell (BB and Radio) | UL Subcell (BB) | UL Subcell (Radio) | L2RT Type |
| ------------------------- | -------------- | ------------------------------------ | -------------------------------------- | ------------------------- | --------------- | ------------------ | --------- |
| cmW BF (O-RAN ULPI Cat-B) | 8DL 2UL        |                                      |                                        | C4 C4                     | C8'2            | C16'2              | GC8       |
|                           | 8DL 4UL        |                                      |                                        | C4 C4                     | C8'4            | C16'4              | GC8       |
|                           | 8DL 8UL        |                                      |                                        | C4 C4                     | C8'8            | C16'8              | GC8       |
|                           | 16DL 2UL       |                                      |                                        | C4 C4 C4 C4               | C8'2            | C16'2              | GC16      |
|                           | 16DL 4UL       | 27R3 CB010276 (IOT) / CB013969 (RRM) | 27R3 CB010276 (IOT), Open (commercial) | C4 C4 C4 C4               | C8'4            | C16'4              | GC16      |
|                           | 16DL 8UL       |                                      |                                        | C4 C4 C4 C4               | C8'8            | C16'8              | GC16      |

---

## 2.2 Cell Slot Model (Detailed Notes)

The high-level CSM overview is in Part 1 section 1.4. This section provides additional implementation details.

### Domain-Specific Notes

- 5G-L2-PS and 5G-L2-LO are not differentiated from each other in the cell slot model. The cell slot position for each cell/NRCELLGRP shall be the same for both system components.
- The L1 instance and therefore the cell slots are common for LTE and 5G. Previously planned SRS domain has been removed; SRS is processed by primary UL subcells.
- The L2RT instances between 1/2 boards are separate.
- FR1 DL-only cells (24R3 CB008224) consume the same L2RT capacity as bi-directional cells.
- PRACH domain (24R3 CB010448): Applies for pooled L1 Pool types on Thor and newer HW, FR1 FDD only. Helps O&M understand underlying PRACH capacity restrictions. Cell slot assignment for PRACH is independent from UL domain.
- CSI-RS pooling groups (CB010448): Modelled as part of L1 DL domain. For each DL L1 Pool type, cell slot ranges are defined for CSI-RS pooling groups and the cell slot placement of the primary subcell determines grouping.
- DL/UL FDF domain (27R3 CB014369): For understanding underlying Fronthaul Data Forwarding (FDF) capacities.

### Subset Principles

- **Fewer Cells:** Unused cell/subcell positions don't consume any Cell Slots in the L2 and/or L1 CSM.
- **Cells with Fewer Subcells:** Cell Slot consumption on cell level is not reduced. Empty subcell positions don't consume cell slots in L1 CSM.
- **Smaller or Less-Capable Cells/Subcells:** Smaller Cell BW, smaller Subcell Types. Cell Slot consumption is not reduced.

### Mixing Principles

Unless otherwise noted, different rows of the L1 or L2 CSM diagrams shall not be mixed.

### Relation to BB Cell Sets

Customer-visible BB Cell Sets defined by SiSo PdM and Nokia-internal UP configurations defined by UP architects are subsets of the L1 and L2 capabilities offered by this CSM. See 5G User Plane Configuration Examples. Feature scopes of BB Cell Sets may have restrictions or exceptions not modelled in the CSM.

### Examples of Parameters Affecting Provided Cell Slots

- System Release, BB HW Platform and BB Board Type, UP Deployment (Instance Type), Duplex Mode (FDD or TDD) and Numerology (SCS)

### Examples of Parameters Affecting Consumed Cell Slots

- System Release, BB HW Platform, RAT (LTE or 5G), Duplex Mode and Numerology, Cell BW, Number of DL or UL Spatial Streams, Feature Activations (especially PRB pooling), Fronthaul mode (CPRI/OBSAI, eCPRI 7-2, eCPRI 7-2 eUL, ORAN)

**Acronyms:** CS = Cell Slot, CSM = Cell Slot Model, SP = Subpool. L2 Subpools used from 22R2 onwards.

---

## 2.3 L1 / L2 Restrictions Outside CSM

### FR1 FDD PRACH Capacity (before CB010448)

Due to limited L1 capacity, cells need to be load balanced between different time-domain positions of PRACH (different PRACH Configuration Index values). Format 1 (5GC000938) is more consuming than format 0 (5GC000836).

**PRACH capacity per slot:**

| L1 Configuration                   | Format 1 | Format 0                    | Mixed                              |
| ---------------------------------- | -------- | --------------------------- | ---------------------------------- |
| Loki L1 Instance (2 L1 Subpools)   | 2 cells  | 3 cells                     | 2 cells format 0 + 1 cell format 1 |
| Loki L1 Instance (Concurrent Mode) | 1 cell   | 2 cells                     | -                                  |
| Thor L1 Pool (2 L1 Subpools)       | 2 cells  | 3 cells (CB010448: 4 cells) | 2 cells format 0 + 1 cell format 1 |
| Thor L1 Pool (1 L1 Subpool)        | 1 cell   | 2 cells                     | -                                  |

Starting from CB010448 on Thor-based L1, PRACH capacity for FR1 FDD cells will be modelled as a CSM (with increased capacity).

### FR1 FDD High-Speed (25R3, CB007491)

The maximum number of NR FDD cells with High-Speed operation per L1 Pool is limited. The position of high-speed cells within the L1 Pool is not restricted. The total number of cells is not impacted.

| L1 Configuration                                        | Max High-Speed Cells | Additional Constraints (27R1 CB014275)                 |
| ------------------------------------------------------- | -------------------- | ------------------------------------------------------ |
| Loki L1 Pools (2 L1 Subpools)                           | 6 per L1 Pool        | -                                                      |
| Loki L1 Pools (1 L1 Subpool, concurrent NR FDD+TDD/LTE) | 3 per L1 Pool        | -                                                      |
| Thor L1 Pools (2 L1 Subpools)                           | 8 per L1 Pool        | Up to 60 MHz aggregated BW in L1 pool with 8RX support |
| Thor L1 Pools (1 L1 Subpool, concurrent NR FDD+TDD/LTE) | 3 per L1 Pool        | Up to 30 MHz aggregated BW in L1 pool with 8RX support |

---

## 2.4 Placement of High Load Cell (27R1 CB014508)

### Background

27R2 CB014508 provides possibility to categorize a cell as high load cell in the configuration file. High load cell categorization is expected to be based on absolute traffic load expectation between cells within RAT in the network, such as data volume. It enables mapping of high load cells to the most sufficient UP resources in balanced manner for better KPI expectation. By default, all cells have normal load categorization.

### New Rules

- Cells categorized to high BW or low BW by the system (TDD threshold: 50 MHz, FDD threshold: 20 MHz).
- Within high BW and separately within low BW cells, number of high load cells per BB Pool shall be minimized.
- Number of high BW cells per L1 subpool and per L2 subpool shall be minimized.
- A high BW cell shall be primarily mapped to BB pool having 2-core L2 subpool(s).
- Within high/low BW cells, a high load cell shall be primarily mapped to 2-core L2 subpool.
- Within high/low BW cells, a normal cell shall be primarily mapped to 2-core L2 subpool if available after mapping high load cells.
- Within each BW and load category, cells shall be mapped in descending BW order.

### OAM Implementation

1. Form high BW and low BW lists of cells; order in descending BW order.
2. Place high load cells first in each list.
3. Configure high BW cells to eligible pools/subpools, minimizing total cells per pool/subpool, favoring 2-core L2 subpool deployment.
4. Configure low BW cells similarly.
5. When multiple placement possibilities exist, place to subpool/pool with lowest accumulated BW.

### Online Reconfiguration

Load categorization change supported online (parameter modification type: 'conditional BTS restart'). Modification scopes:
- No new placement needed → applied online
- Only the cell needs new placement → cell lock/unlock
- Board level reconfiguration needed → reset of BB module/L1 instance
- Multiple board/system reconfigurations needed → BTS/RAT reset

Activation flag: Default 'Activated', temporary deactivation possible. ACD required.

---

## 2.5 ASRs for Configuration Model

Note: Remaining ASRs have been moved to DOORS UP System Level chapter 3.1

| Release | Feature                               | Requirement                                                                                                                                                                                                                      | Rationale                                                                                                                                     |
| ------- | ------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| 23R1    | (legacy behavior as future direction) | For Beamforming FR1 TDD cells, it shall be allowed to configure an nrCellType with more spatial streams than needed for DL/UL MU MIMO features configured in the cell.                                                           | Avoid unnecessary dependencies between RRM and SiSo configurations. E.g. 8DL 8UL can be used for 8RX receiver even if DL MU MIMO is disabled. |
| 24R1    | (CNI to be created)                   | The mapping of NDM SRS streams into OFDM symbol positions on the eCPRI interface shall be compatible between all combinations of RU type and all nrCellType, so that these combinations can be freely mixed in the same L1 Pool. | Fix architectural debt introduced by CB010388.                                                                                                |

---

## 2.6 Subcell Type Catalogs

### FDD Subcell Types

| Use Case          | Subcell Type                 | RRM Feature              | 1st Cell Set (Loki) | 1st Cell Set (Thor) | Physical Channels and Signals           | Spatial Streams            | MIMO Layers | eAxCs (eCPRI mode)                          |
| ----------------- | ---------------------------- | ------------------------ | ------------------- | ------------------- | --------------------------------------- | -------------------------- | ----------- | ------------------------------------------- |
| FDD CPRI or eCPRI | DL Primary A1                | 23R1 CB008983            | 23R1                | 24R1 CB009014       | PDCCH, PDSCH, PSS, SSS, PBCH, CSI-RS    | 1                          | 1           | 1 regular                                   |
|                   | DL Primary A2                | (old feature from Loner) | 5G21A CB006814      | 24R1 CB009014       | PDCCH, PDSCH, PSS, SSS, PBCH, CSI-RS    | 2                          | 2           | 2 regular                                   |
|                   | DL Primary A4                | (old feature from Loner) | 5G21A CB006814      | 24R1 CB009014       | PDCCH, PDSCH, PSS, SSS, PBCH, CSI-RS    | 4                          | 4           | 4 regular                                   |
| FDD Super Cell    | DL Fronthaul Duplication A1F | 26R2 CB009543            | 26R2 CB011061       | 26R3 CB011064       | (no L1 processing other than fronthaul) | 1                          | N/A         | N/A                                         |
|                   | DL Fronthaul Duplication A2F | 26R2 CB009543            | 26R2 CB011061       | 26R3 CB011064       | (no L1 processing other than fronthaul) | 2                          | N/A         | N/A                                         |
|                   | DL Fronthaul Duplication A4F | 26R2 CB009543            | 26R2 CB011061       | 26R3 CB011064       | (no L1 processing other than fronthaul) | 4                          | N/A         | N/A                                         |
| FDD CPRI or eCPRI | UL Primary A2                | (old feature from Loner) | 5G21A CB006814      | 24R1 CB009014       | PUCCH, PUSCH, PRACH, MIMO SRS           | 2 (+2 w/ UL CoMP CB008465) | 2           | 2 regular + 2 PRACH                         |
|                   | UL Primary A4                | (old feature from Loner) | 5G21A CB006814      | 24R1 CB009014       | PUCCH, PUSCH, PRACH, MIMO SRS           | 4 (+4 w/ UL CoMP CB008465) | 2           | 4 regular + 4 PRACH                         |
| FDD eCPRI         | UL Primary A8                | 26R2 CB013442/CB08577    | (not supported)     | 26R2 CB015905       | PUCCH, PUSCH, PRACH, MIMO SRS           | 8                          | 2           | 8 regular + 4 PRACH (8 PRACH from CB008577) |

### TDD (cmW) Subcell Types — eCPRI 7-2a / CPRI

| Use Case            | Subcell Type                | RRM Feature              | 1st Cell Set (Loki) | 1st Cell Set (Thor) | Physical Channels and Signals        | Spatial Streams | MIMO Layers | eAxCs (eCPRI mode)                     |
| ------------------- | --------------------------- | ------------------------ | ------------------- | ------------------- | ------------------------------------ | --------------- | ----------- | -------------------------------------- |
| cmW eCPRI           | DL Primary C2               | (old feature from Loner) | 5G21A 5GC002340     | 24R1 CB009142       | PDCCH, PDSCH, PSS, SSS, PBCH, CSI-RS | 2               | 2           | 2 regular                              |
|                     | DL Primary C4               | (old feature from Loner) | 5G21A 5GC002340     | 24R1 CB009142       | PDCCH, PDSCH, PSS, SSS, PBCH, CSI-RS | 4               | 4           | 4 regular                              |
|                     | DL Primary C8               | CB010250                 | (not planned)       | (future)            | PDCCH, PDSCH, PSS, SSS, PBCH, CSI-RS | 8               | 4           | 8 regular                              |
|                     | DL Secondary C4             | (old feature from Loner) | 5G21A 5GC002339     | 24R1 CB009142       | PDCCH, PDSCH                         | 4               | 4           | 4 regular                              |
| cmW CPRI            | DL Primary C2               | (old feature from Loner) | 5G21A 5GC002340     | 24R2 CB010706       | PDCCH, PDSCH, PSS, SSS, PBCH, CSI-RS | 2               | 2           | N/A                                    |
|                     | DL Primary C4               | (old feature from Loner) | 5G21A 5GC002340     | 24R2 CB010706       | PDCCH, PDSCH, PSS, SSS, PBCH, CSI-RS | 4               | 4           | N/A                                    |
| cmW eCPRI           | UL Primary C2               | (old feature from Loner) | 5G21A 5GC002340     | 24R1 CB009142       | PUCCH, PUSCH, PRACH, MIMO SRS        | 2               | 2           | 2 regular + 2 PRACH                    |
|                     | UL Primary C4               | (old feature from Loner) | 5G21A 5GC002340     | 24R1 CB009142       | PUxCH, PRACH, MIMO SRS, BF SRS       | 4               | 2           | 4 regular + 4 PRACH + up to 64 NDM SRS |
|                     | UL Primary C8               | 24R1 CB009363            | (not planned)       | 24R1 CB009363       | PUxCH, PRACH, MIMO SRS, BF SRS       | 8               | 4           | 8 regular + 4 PRACH + up to 64 NDM SRS |
|                     | UL Secondary C4             | 23R1 CB008360            | 23R1 CB009403       | 24R1 CB009142       | PUSCH                                | 4               | 2           | 4 regular                              |
| cmW CPRI            | UL Primary C2               | (old feature from Loner) | 5G21A 5GC002340     | (not planned)       | PUCCH, PUSCH, PRACH, MIMO SRS        | 2               | 2           | N/A                                    |
|                     | UL Primary C4               | (old feature from Loner) | 5G21A 5GC002340     | (not planned)       | PUCCH, PUSCH, PRACH, MIMO SRS        | 4               | 2           | N/A                                    |
| cmW eCPRI NRPOSCELL | UL Positioning SRS C4 (C4S) | 25R2 SiSo CB010680       | (not planned)       | 25R2 CB010680       | SRS                                  | 4               | 0           | 4 NDM SRS                              |
|                     | UL Positioning SRS C8 (C8S) | 26R2 SiSo CB013273       | (not planned)       | 26R2 CB013273       | SRS                                  | 8               | 0           | 8 NDM SRS                              |

NDM SRS (feature 5GC001086) is only for Beamforming RUs and it is optional. When enabled, the number of NDM eAxCs is either 32 or 64 per (sub)cell and matches the number of TRXs in the RU.

### TDD (cmW) Subcell Types — eCPRI 7-2e

| Use Case                      | Subcell Type     | RRM Feature    | 1st Cell Set (Thor) | Physical Channels | PUCCH, PRACH            | PUSCH                | SRS                        |
| ----------------------------- | ---------------- | -------------- | ------------------- | ----------------- | ----------------------- | -------------------- | -------------------------- |
| cmW eCPRI 7-2e for L1 (BB)    | UL Primary C4'2  | 24R3 CB007595  | (not commercial)    | all (7-2e split)  | 4 Streams, 4 Streams    | 2 Layers             | (depends on Radio subcell) |
|                               | UL Primary C8'2  | ~25R2 CB010708 | CB009843            | all (7-2e split)  | 8 Streams, 4 Streams    | 2 Layers             | (depends on Radio subcell) |
|                               | UL Primary C8'4  | ~25R2 CB010708 | CB009843            | all (7-2e split)  | 8 Streams, 4 Streams    | 4 Layers             | (depends on Radio subcell) |
|                               | UL Primary C8'8  | 26R1 CB008235  | CB009843            | all (7-2e split)  | 8 Streams, 4 Streams    | 8 Layers             | (depends on Radio subcell) |
| cmW eCPRI 7-2e for L1 (Radio) | UL Primary C4'2  | 24R3 CB007595  | (not commercial)    | all (7-2e split)  | 4 Streams               | 4 Streams, 2 Layers  | 32/64 TRX                  |
|                               | UL Primary C16'2 | ~25R2 CB010708 | CB009843            | all (7-2e split)  | (depends on BB subcell) | 16 Streams, 2 Layers | 32/64 TRX                  |
|                               | UL Primary C16'4 | ~25R2 CB010708 | CB009843            | all (7-2e split)  | (depends on BB subcell) | 16 Streams, 4 Layers | 32/64 TRX                  |
|                               | UL Primary C16'8 | 26R1 CB008235  | CB009843            | all (7-2e split)  | (depends on BB subcell) | 16 Streams, 8 Layers | 32/64 TRX                  |

### TDD (cmW) Subcell Types — O-RAN ULPI Cat-B

| Use Case                            | Subcell Type     | RRM Feature                        | 1st Cell Set (Thor) | Physical Channels      | PUCCH, PRACH            | PUSCH                | SRS                        |
| ----------------------------------- | ---------------- | ---------------------------------- | ------------------- | ---------------------- | ----------------------- | -------------------- | -------------------------- |
| cmW O-RAN ULPI Cat-B for L1 (BB)    | UL Primary C4'2  |                                    |                     | all (ULPI Cat-B split) | 4 Streams, 4 Streams    | 2 Layers             |                            |
|                                     | UL Primary C8'2  |                                    |                     | all (ULPI Cat-B split) | 8 Streams, 4 Streams    | 2 Layers             |                            |
|                                     | UL Primary C8'4  | 27R3 CB010276 (IOT)/CB013969 (RRM) | 27R3 CB010276 (IOT) | all (ULPI Cat-B split) | 8 Streams, 8 Streams    | 4 Layers             | (depends on Radio subcell) |
|                                     | UL Primary C8'8  |                                    |                     | all (ULPI Cat-B split) | 8 Streams, 4 Streams    | 8 Layers             |                            |
| cmW O-RAN ULPI Cat-B for L1 (Radio) | UL Primary C16'2 |                                    |                     | all (ULPI Cat-B split) | (depends on BB subcell) | 16 Streams, 2 Layers |                            |
|                                     | UL Primary C16'4 | 27R3 CB010276 (IOT)/CB013969 (RRM) | 27R3 CB010276 (IOT) | all (ULPI Cat-B split) | (depends on BB subcell) | 16 Streams, 4 Layers | 64 TRX                     |
|                                     | UL Primary C16'8 |                                    |                     | all (ULPI Cat-B split) | (depends on BB subcell) | 16 Streams, 8 Layers |                            |

### Subcell Types — Fronthaul Data Forwarding

| Use Case                   | Subcell Type   | RRM Feature   | 1st Cell Set (Thor) | Physical Channels           | Spatial Streams      | MIMO Layers | eAxCs                                  |
| -------------------------- | -------------- | ------------- | ------------------- | --------------------------- | -------------------- | ----------- | -------------------------------------- |
| FDD CPRI or eCPRI FDF      | DL FDD A4FDF   | 27R3 CB014369 | 27R3 CB014369       | (no L1 processing, FH only) | 4                    | 2           | 4 regular                              |
|                            | UL FDD A4FDF   | 27R3 CB014369 | 27R3 CB014369       | (no L1 processing, FH only) | 4                    | 2           | 4 regular + 4 PRACH                    |
| FDD eCPRI FDF              | UL FDD A8FDF   | 27R3 CB014369 | 27R3 CB014369       | (no L1 processing, FH only) | 4                    | 2           | 8 regular + 8 PRACH                    |
| cmW CPRI or eCPRI 7-2a FDF | DL TDD C4FDF   | 27R3 CB014369 | 27R3 CB014369       | (no L1 processing, FH only) | 4                    | 4           | 4 regular                              |
|                            | UL TDD C4FDF   | 27R3 CB014369 | 27R3 CB014369       | (no L1 processing, FH only) | 4                    | 2           | 4 regular + 4 PRACH + up to 64 NDM SRS |
| cmW eCPRI 7-2a FDF         | UL TDD C8FDF   | 27R3 CB014369 | 27R3 CB014369       | (no L1 processing, FH only) | 4                    | 4           | 8 regular + 4 PRACH + up to 64 NDM SRS |
| cmW eCPRI 7-2e FDF         | UL TDD C8'4FDF | 27R3 CB014369 | 27R3 CB014369       | (no L1 processing, FH only) | 8 (PUCCH), 4 (PRACH) | 4           | 32/64 TRX                              |
|                            | UL TDD C8'8FDF | 27R3 CB014369 | 27R3 CB014369       | (no L1 processing, FH only) | 8 (PUCCH), 4 (PRACH) | 8           | 32/64 TRX                              |

---

## 2.7 UP SW Deployments

Allocation of cores to different UP L2 functions. L1 SW deployments on high level when on same device with L2.

Covered: Snowfish, Marlin, vDU RAN NIC (RINLINE2), Nemo, vDU AI-RAN (GPU101).
Not covered: Loki, Thor, Odin (see L1 documentation).

**Legend:**

| Symbol | Meaning             |
| ------ | ------------------- |
| HI     | 5G-L2-HI instance   |
| LO     | 5G-L2-LO instance   |
| PS     | 5G-L2-PS L2 subpool |
| TM     | 5G-L2-TM            |
| L      | LTE                 |

(*) Includes administrative parts of L2NRT and L2RT.

### L2 Deployment: ABIO

| ABIO         | cluster 0     | cluster 1 |     |     |     | cluster 2 |     |     |     | cluster 3 |     |     |     | cluster 4 |     |     |     | cluster 5 |     |     |     |
| ------------ | ------------- | --------- | --- | --- | --- | --------- | --- | --- | --- | --------- | --- | --- | --- | --------- | --- | --- | --- | --------- | --- | --- | --- |
| Half Board 1 | Linux SMP (*) | LO        | LO  | -   | -   | HI        | HI  | HI  | HI  | PS        | PS  | PS  | PS  | -         | -   | -   | -   | -         | -   | -   | -   |
|              |               | LO        | LO  | -   | -   | HI        | HI  | HI  | HI  | PS        | PS  | PS  | PS  | -         | -   | -   | -   | -         | -   | -   | -   |
|              |               | LO        | LO  | -   | -   | HI        | HI  | HI  | HI  | PS        | PS  | PS  | PS  | -         | -   | -   | -   | -         | -   | -   | -   |
|              |               | HI        | HI  | -   | -   | LO        | LO  | PS  | PS  | PS        | PS  | PS  | PS  | -         | -   | -   | -   | -         | -   | -   | -   |
|              |               | HI        | HI  | -   | -   | LO        | LO  | PS  | PS  | PS        | PS  | PS  | PS  | -         | -   | -   | -   | -         | -   | -   | -   |
|              |               | HI        | HI  | -   | -   | LO        | LO  | PS  | PS  | L         | L   | L   | L   | -         | -   | -   | -   | -         | -   | -   | -   |
|              |               | -         | -   | -   | -   | -         | -   | -   | -   | TM        | TM  | TM  | TM  | -         | -   | -   | -   | -         | -   | -   | -   |
| Half Board 2 |               | -         | -   | LO  | LO  | -         | -   | -   | -   | -         | -   | -   | -   | HI        | HI  | HI  | HI  | PS        | PS  | PS  | PS  |
|              |               | -         | -   | LO  | LO  | -         | -   | -   | -   | -         | -   | -   | -   | HI        | HI  | HI  | HI  | PS        | PS  | PS  | PS  |
|              |               | -         | -   | LO  | LO  | -         | -   | -   | -   | -         | -   | -   | -   | HI        | HI  | HI  | HI  | PS        | PS  | PS  | PS  |
|              |               | -         | -   | HI  | HI  | -         | -   | -   | -   | -         | -   | -   | -   | LO        | LO  | PS  | PS  | PS        | PS  | PS  | PS  |
|              |               | -         | -   | HI  | HI  | -         | -   | -   | -   | -         | -   | -   | -   | LO        | LO  | PS  | PS  | PS        | PS  | PS  | PS  |
|              |               | -         | -   | HI  | HI  | -         | -   | -   | -   | -         | -   | -   | -   | LO        | LO  | PS  | PS  | L         | L   | L   | L   |
|              |               | -         | -   | LO  | LO  | -         | -   | -   | -   | -         | -   | -   | -   | PS        | PS  | PS  | PS  | L         | L   | L   | L   |
|              |               | -         | -   | LO  | LO  | -         | -   | -   | -   | -         | -   | -   | -   | PS        | PS  | PS  | PS  | L         | L   | L   | L   |
|              |               | -         | -   | L   | L   | -         | -   | -   | -   | -         | -   | -   | -   | LO        | LO  | PS  | PS  | L         | L   | L   | L   |
|              |               | -         | -   | L   | L   | -         | -   | -   | -   | -         | -   | -   | -   | LO        | LO  | PS  | PS  | L         | L   | L   | L   |
|              |               | -         | -   | -   | -   | -         | -   | -   | -   | -         | -   | -   | -   | -         | -   | -   | -   | TM        | TM  | TM  | TM  |
| Full Board   |               | HI        | HI  | HI  | HI  | LO        | LO  | LO  | LO  | -         | -   | -   | -   | PS        | PS  | PS  | PS  | PS        | PS  | PS  | PS  |
|              |               | HI        | HI  | HI  | HI  | LO        | LO  | LO  | LO  | PS        | PS  | PS  | PS  | PS        | PS  | PS  | PS  | PS        | PS  | PS  | PS  |
|              |               | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  | PS        | PS  | PS  | PS  | L         | L   | L   | L   | L         | L   | L   | L   |

### L2 Deployment: ABIN

| ABIN         | cluster 0     |     | cluster 1 |     |     |     | cluster 2 |     |     |     | cluster 3 |     |     |     | cluster 4 |     |     |     |
| ------------ | ------------- | --- | --------- | --- | --- | --- | --------- | --- | --- | --- | --------- | --- | --- | --- | --------- | --- | --- | --- |
| Half Board 1 | Linux SMP (*) |     | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  | -         | -   | -   | -   | -         | -   | -   | -   |
|              |               |     | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  | -         | -   | -   | -   | -         | -   | -   | -   |
|              |               |     | -         | -   | -   | -   | TM        | TM  | TM  | TM  | -         | -   | -   | -   | -         | -   | -   | -   |
| Half Board 2 |               |     | -         | -   | -   | -   | -         | -   | -   | -   | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  |
| Full Board   |               |     | LO        | LO  | -   | -   | -         | -   | -   | -   | HI        | HI  | HI  | HI  | PS        | PS  | PS  | PS  |
|              |               |     | HI        | HI  | HI  | HI  | LO        | LO  | -   | -   | -         | -   | PS  | PS  | PS        | PS  | PS  | PS  |
|              |               |     | HI        | HI  | HI  | HI  | LO        | LO  | -   | -   | -         | -   | PS  | PS  | PS        | PS  | PS  | PS  |

### L2 Deployment: ASOE / ASOF

| ASOE/ASOF    | cluster 0              | cluster 1 | cluster 2 |     |     |     | cluster 3 |     |     |     | cluster 4 |     |     |     | cluster 5 |     |     |     |
| ------------ | ---------------------- | --------- | --------- | --- | --- | --- | --------- | --- | --- | --- | --------- | --- | --- | --- | --------- | --- | --- | --- |
| Half Board 1 | Linux SMP (*) and TRSW |           | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  | -         | -   | -   | -   | -         | -   | -   | -   |
|              |                        |           | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  | -         | -   | -   | -   | -         | -   | -   | -   |
|              |                        |           | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  | -         | -   | -   | -   | -         | -   | -   | -   |
|              |                        |           | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  | -         | -   | -   | -   | -         | -   | -   | -   |
|              |                        |           | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  | -         | -   | -   | -   | -         | -   | -   | -   |
|              |                        |           | -         | -   | -   | -   | TM        | TM  | TM  | TM  | -         | -   | -   | -   | -         | -   | -   | -   |
| Half Board 2 |                        |           | -         | -   | -   | -   | -         | -   | -   | -   | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  |
|              |                        |           | -         | -   | -   | -   | -         | -   | -   | -   | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  |
|              |                        |           | -         | -   | -   | -   | -         | -   | -   | -   | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  |
|              |                        |           | -         | -   | -   | -   | -         | -   | -   | -   | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  |
|              |                        |           | -         | -   | -   | -   | -         | -   | -   | -   | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  |
|              |                        |           | -         | -   | -   | -   | -         | -   | -   | -   | LO        | LO  | PS  | PS  | L         | L   | L   | L   |
|              |                        |           | -         | -   | -   | -   | -         | -   | -   | -   | LO        | LO  | PS  | PS  | L         | L   | L   | L   |
|              |                        |           | -         | -   | -   | -   | -         | -   | -   | -   | -         | -   | -   | -   | TM        | TM  | TM  | TM  |
| Full Board   |                        |           | HI        | HI  | HI  | HI  | LO        | LO  | LO  | LO  | PS        | PS  | PS  | PS  | PS        | PS  | PS  | PS  |

### L2 Deployment: ABIP

| ABIP         | 4 cores       | 4 cores |     |     |     | 4 cores |     |     |     | 4 cores |     |     |     | 4 cores |     |     |     | 4 cores |     |     |     |
| ------------ | ------------- | ------- | --- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- |
| Half Board 1 | Linux SMP (*) |         |     |     | LO  | LO      | -   | -   | HI  | HI      | HI  | HI  | PS  | PS      | PS  | PS  | -   | -       | -   | -   |
|              |               |         |     |     | HI  | HI      | -   | -   | LO  | LO      | PS  | PS  | PS  | PS      | PS  | PS  | -   | -       | -   | -   |
|              |               |         |     |     | HI  | HI      | -   | -   | LO  | LO      | PS  | PS  | PS  | PS      | PS  | PS  | -   | -       | -   | -   |
|              |               |         |     |     | HI  | HI      | -   | -   | LO  | LO      | PS  | PS  | PS  | PS      | PS  | PS  | -   | -       | -   | -   |
|              |               |         |     |     | HI  | HI      | -   | -   | LO  | PS      | PS  | PS  | L   | L       | L   | L   | -   | -       | -   | -   |
|              |               |         |     |     | -   | -       | -   | -   | -   | -       | -   | -   | TM  | TM      | TM  | TM  | -   | -       | -   | -   |
| Half Board 2 | Linux SMP (*) |         |     |     | -   | -       | LO  | LO  | -   | -       | -   | -   | -   | -       | -   | -   | HI  | HI      | HI  | HI  | PS  | PS | PS | PS |
|              |               |         |     |     | -   | -       | HI  | HI  | -   | -       | -   | -   | -   | -       | -   | -   | LO  | LO      | PS  | PS  | PS  | PS | PS | PS |
|              |               |         |     |     | -   | -       | HI  | HI  | -   | -       | -   | -   | -   | -       | -   | -   | LO  | LO      | PS  | PS  | PS  | PS | PS | PS |
|              |               |         |     |     | -   | -       | HI  | HI  | -   | -       | -   | -   | -   | -       | -   | -   | LO  | LO      | PS  | PS  | PS  | PS | PS | PS |
|              |               |         |     |     | -   | -       | LO  | LO  | -   | -       | -   | -   | -   | -       | -   | -   | PS  | PS      | PS  | PS  | L   | L  | L  | L  |
|              |               |         |     |     | -   | -       | LO  | LO  | -   | -       | -   | -   | -   | -       | -   | -   | PS  | PS      | PS  | PS  | L   | L  | L  | L  |
|              |               |         |     |     | -   | -       | L   | L   | -   | -       | -   | -   | -   | -       | -   | -   | LO  | LO      | PS  | PS  | L   | L  | L  | L  |
|              |               |         |     |     | -   | -       | L   | L   | -   | -       | -   | -   | -   | -       | -   | -   | LO  | LO      | PS  | PS  | L   | L  | L  | L  |
|              |               |         |     |     | -   | -       | HI  | HI  | -   | -       | -   | -   | -   | -       | -   | -   | LO  | PS      | PS  | PS  | L   | L  | L  | L  |
|              |               |         |     |     | -   | -       | -   | -   | -   | -       | -   | -   | -   | -       | -   | -   | -   | -       | -   | -   | TM  | TM | TM | TM |

**Full Board Deployments (3-sector TDD):**

| ABIP Full Board | 4 cores       | 4 cores |     |     |     | 4 cores |     |     |     | 4 cores |     |     |     | 4 cores |     |     |     | 4 cores |     |     |     |
| --------------- | ------------- | ------- | --- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- |
|                 | Linux SMP (*) | HI      | HI  | HI  | HI  | LO      | LO  | LO  | LO  | -       | -   | -   | -   | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  |
|                 |               | HI      | HI  | HI  | HI  | LO      | LO  | LO  | LO  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  |
|                 |               | HI      | HI  | HI  | HI  | LO      | LO  | LO  | LO  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  |
|                 |               | HI      | HI  | HI  | HI  | LO      | LO  | LO  | LO  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  |
|                 |               | HI      | HI  | HI  | HI  | LO      | LO  | LO  | LO  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | LO      | PS  | PS  | PS  |
|                 |               | HI      | HI  | HI  | LO  | LO      | LO  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | LO      | PS  | PS  | PS  |
|                 |               | HI      | HI  | HI  | LO  | LO      | LO  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | LO      | PS  | PS  | PS  |
|                 |               | HI      | HI  | HI  | LO  | LO      | LO  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | LO      | PS  | PS  | PS  |
|                 |               | HI      | HI  | HI  | LO  | LO      | LO  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | LO  | PS      | PS  | PS  | PS  |
|                 |               | HI      | HI  | HI  | LO  | LO      | LO  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | L       | L   | L   | L   |
|                 |               | HI      | HI  | HI  | LO  | LO      | LO  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | L       | L   | L   | L   |
|                 |               | HI      | HI  | HI  | LO  | LO      | LO  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | L       | L   | L   | L   |
|                 |               | NA      | NA  | HI  | HI  | LO      | LO  | PS  | PS  | PS      | PS  | PS  | PS  | L       | L   | L   | L   | L       | L   | L   | L   |
|                 |               | HI      | HI  | LO  | LO  | PS      | PS  | PS  | PS  | PS      | PS  | LO  | PS  | PS      | PS  | L   | L   | L       | L   | L   | L   |

**Tuned Full-Board Deployments (with distributed C-plane move to core-board):**

| ABIP Tuned | 4 cores  | 4 cores |     |     | 4 cores |     |     |     | 4 cores |     |     |     | 4 cores |     |     |     | 4 cores |     |     |     |
| ---------- | -------- | ------- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- |
|            | L, HI    | HI      | HI  | HI  | LO      | LO  | LO  | LO  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | PS | PS | PS |
|            | L, HI    | HI      | LO  | LO  | PS      | PS  | PS  | PS  | PS      | PS  | LO  | PS  | PS      | PS  | PS  | PS  | PS      | L   | L   | L   | L  | L  | L  |
|            | L, HI    | HI      | HI  | HI  | LO      | LO  | LO  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | LO  | PS | PS | PS |
|            | L, HI    | HI      | HI  | LO  | LO      | LO  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | LO  | PS  | PS | PS | PS |
|            | L, HI    | HI      | HI  | HI  | LO      | LO  | LO  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | LO  | PS | PS | PS |
|            | L, HI    | HI      | HI  | HI  | LO      | LO  | LO  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | L   | L  | L  | L  |
|            | L, L, HI | HI      | LO  | LO  | LO      | LO  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | L   | L   | L  | L  |
|            | L, L, HI | HI      | HI  | LO  | LO      | LO  | LO  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | L  | L  | L  |
|            | L, L, HI | HI      | HI  | LO  | LO      | PS  | PS  | PS  | PS      | PS  | PS  | LO  | PS      | PS  | PS  | PS  | PS      | L   | L   | L   | L  | L  | L  |

### L2 Deployment: ABIP / ABIQ (4-Sector TDD)

| ABIP/ABIQ                 | 4 cores       | 4 cores |     |     |     | 4 cores |     |     |     | 4 cores |     |     |     | 4 cores |     |     |     | 4 cores |     |     |     |
| ------------------------- | ------------- | ------- | --- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- |
| Full Board (4-sector TDD) | Linux SMP (*) | HI      | HI  | HI  | HI  | LO      | LO  | PS  | PS  | PS      | PS  | LO  | PS  | PS      | PS  | L   | L   | L       | L   | L   | L   |
|                           |               | HI      | HI  | HI  | HI  | LO      | LO  | PS  | PS  | PS      | PS  | LO  | LO  | PS      | PS  | L   | L   | L       | L   | L   | L   |
|                           |               | HI      | HI  | HI  | HI  | LO      | LO  | PS  | PS  | PS      | PS  | LO  | LO  | PS      | PS  | PS  | PS  | L       | L   | L   | L   |
|                           |               | HI      | HI  | HI  | LO  | LO      | LO  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  |

### L2 Deployment: ASOG / ASOH

| ASOG/ASOH    | 4 cores                | 4 cores | 4 cores |     |     |     | 4 cores |     |     |     | 4 cores |     |     |     | 4 cores |     |     |     |
| ------------ | ---------------------- | ------- | ------- | --- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- |
| Half Board 1 | Linux SMP (*) and TRSW |         | HI      | HI  | LO  | LO  | PS      | PS  | PS  | PS  | -       | -   | -   | -   | -       | -   | -   | -   |
|              |                        |         | HI      | HI  | LO  | LO  | PS      | PS  | PS  | PS  |         |     |     |     |         |     |     |     |
|              |                        |         | HI      | HI  | LO  | LO  | PS      | PS  | PS  | PS  | -       | -   | -   | -   | -       | -   | -   | -   |
|              |                        |         | -       | -   | -   | -   | TM      | TM  | TM  | TM  | -       | -   | -   | -   | -       | -   | -   | -   |
| Half Board 2 |                        |         | -       | -   | -   | -   | -       | -   | -   | -   | HI      | HI  | LO  | LO  | PS      | PS  | PS  | PS  |
|              |                        |         |         |     |     |     |         |     |     |     | HI      | HI  | LO  | LO  | PS      | PS  | PS  | PS  |
|              |                        |         | -       | -   | -   | -   | -       | -   | -   | -   | HI      | HI  | LO  | LO  | PS      | PS  | PS  | PS  |
|              |                        |         | -       | -   | -   | -   | -       | -   | -   | -   | -       | -   | -   | -   | TM      | TM  | TM  | TM  |
| Full Board   |                        |         | HI      | HI  | HI  | HI  | LO      | LO  | LO  | LO  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  |
|              |                        |         | HI      | HI  | HI  | LO  | LO      | LO  | LO  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  |
|              |                        |         | HI      | HI  | HI  | LO  | LO      | LO  | LO  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  |
|              |                        |         | HI      | HI  | HI  | HI  | LO      | LO  | PS  | PS  | PS      | PS  | PS  | PS  | LO      | PS  | PS  | PS  |
|              |                        |         | HI      | HI  | HI  | LO  | LO      | LO  | PS  | PS  | PS      | PS  | PS  | PS  | LO      | PS  | PS  | PS  |
|              |                        |         | HI      | HI  | HI  | LO  | LO      | LO  | PS  | PS  | PS      | PS  | PS  | PS  | LO      | PS  | PS  | PS  |
|              |                        |         | HI      | HI  | HI  | LO  | LO      | LO  | PS  | PS  | PS      | PS  | PS  | PS  | L       | L   | L   | L   |
|              |                        |         | HI      | HI  | HI  | LO  | LO      | LO  | PS  | PS  | PS      | PS  | PS  | PS  | LO      | LO  | PS  | PS  |
|              |                        |         | HI      | HI  | HI  | LO  | LO      | PS  | PS  | PS  | PS      | LO  | PS  | PS  | L       | L   | L   | L   |

---

## 2.8 L2 Pool Types for L2RT Instances

| Pool Spec                      | LO  |     | +   | PS  |     |     |     |     |     |     |     |     |     | Description                                       |
| ------------------------------ | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | ------------------------------------------------- |
| NR FDD 3SP                     | LO  | LO  | +   | PS  | PS  | PS  |     |     |     |     |     |     |     |                                                   |
| NR FDD 3SP (1-core LO)         | LO  |     | +   | PS  | PS  | PS  |     |     |     |     |     |     |     |                                                   |
| NR FDD 2C 1SP (1-core LO)      | LO  |     | +   | PS  | PS  |     |     |     |     |     |     |     |     |                                                   |
| NR FDD 2C 2SP (1-core LO)      | LO  |     | +   | PS  | PS  | PS  | PS  |     |     |     |     |     |     |                                                   |
| NR TDD FR1 2SP (1 Loki)        | LO  | LO  | +   | PS  | PS  | PS  | PS  |     |     |     |     |     |     |                                                   |
| NR TDD FR1 3SP (1 Loki)        | LO  | LO  | +   | PS  | PS  | PS  | PS  | PS  | PS  |     |     |     |     |                                                   |
| NR TDD FR1 4SP (1 Loki)        | LO  | LO  | +   | PS  | PS  | PS  | PS  | PS  | PS  | PS  | PS  |     |     |                                                   |
| NR TDD FR1 2SP+1SP (1.5 Lokis) | LO  | LO  | LO  | +   | PS  | PS  | PS  | PS  | PS  | PS  |     |     |     | 2 L2 Pools: 2SP + 1SP (8DL) or 1 Pool: 3SP (16DL) |
| NR TDD FR1 3SP+1SP (1.5 Lokis) | LO  | LO  | LO  | +   | PS  | PS  | PS  | PS  | PS  | PS  | PS  | PS  |     | 2 L2 Pools: 3SP + 1SP (8DL)                       |

---

## 2.9 L2 Subpool Types and Characteristics

| L2 Subpool Type | Deployment  | DL/UL Scheduling Mapping                                                               | Max Cells (high perf) | Max Cells (performance)                       | Max Cells (connectivity)                    | Restrictions                                                            | Availability                                 |
| --------------- | ----------- | -------------------------------------------------------------------------------------- | --------------------- | --------------------------------------------- | ------------------------------------------- | ----------------------------------------------------------------------- | -------------------------------------------- |
| FR1 TDD 1-core  | PS          | Mix (DL+UL per core)                                                                   | -                     | -                                             | 1                                           | Max 50M BW or max 8DL/8UL UE/TTI. Reduced peak with simultaneous DL+UL. | Legacy                                       |
| FR1 TDD 2-core  | PS PS       | 1 cell w/o DL pipeline: Direct. 1 cell w/ DL pipeline: Partial mix. 2 cells: Cross mix | -                     | 1                                             | 2 (avoid; use 2x 1-core instead)            | Scheduling timing alignment between cells.                              | Legacy. 2 cells should be avoided from 27R1. |
| FR1 TDD 3-core  | PS PS PS    | Direct (2 DL cores + 1 UL core)                                                        | 1                     | -                                             | -                                           |                                                                         | future                                       |
| FR1 TDD 4-core  | PS PS PS PS | Cross mix                                                                              |                       | -                                             | 3                                           | Scheduling timing alignment between cells.                              | 28R1 CB015845                                |
| FDD 1-core      | PS          | Mix (DL+UL per core)                                                                   | -                     | 1                                             | -                                           | Reduced peak with simultaneous DL+UL. Scheduling timing alignment.      | Legacy                                       |
| FDD 2-core      | PS PS       | Direct (DL or UL per core)                                                             | 1                     | 2 (w/o connectivity) or 1 (w/ 2 connectivity) | 4 (w/o performance) or 2 (w/ 1 performance) | Scheduling timing alignment.                                            | Legacy                                       |

### TDD 2-Cell on 2-Core Replacement

| Deployment                | Pros                                                                | Cons                                                | Recommendation                                                                                                            |
| ------------------------- | ------------------------------------------------------------------- | --------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| 1-core DL+UL              | Low complexity, single cell per core. Supports odd number of cores. | Loses pooling benefit. Loses DL+UL parallelization. | Use in all new BB cell sets instead of 2 cells on 2 cores. Don't force change to existing deployments due to KPI changes. |
| Single direction per core | Keeps pooling. Keeps DL+UL parallelization. Better cache.           | Complexity, still 2 cells per core.                 | Don't proceed. Not solving 2-cells-on-1-core complexity. Functionality and KPI issues.                                    |
