# 5G-L2-PS System Architecture Summary

## 1. Overview and Role

**5G-L2-PS** (5G Layer 2 Packet Scheduling) is one of the real-time system components within the Nokia 5G User Plane domain. It is responsible for **MAC-layer scheduling** — the time-critical decision-making that maps user data onto the NR air interface resources each TTI/slot.

5G-L2-PS is always co-located with **5G-L2-LO** (Layer 2 Low) within the same **L2RT Instance** (L2 Real-Time Instance). Together they form the real-time data-path of L2. 5G-L2-PS handles per-slot DL and UL scheduling, while 5G-L2-LO handles associated lower-layer L2 processing (RLC segmentation, HARQ, MAC PDU assembly/disassembly, etc.).

### System Components in the 5G User Plane Domain

| Component     | Function                                              |
| ------------- | ----------------------------------------------------- |
| **5G-L1-DL**  | Physical layer downlink processing                    |
| **5G-L1-UL**  | Physical layer uplink processing                      |
| **5G-L2-PS**  | Real-time packet scheduling (MAC scheduler)           |
| **5G-L2-LO**  | Real-time lower L2 processing (RLC, HARQ, MAC PDU)    |
| **5G-L2-HI**  | Non-real-time L2 processing (PDCP, SDAP, RRC-related) |
| **5G-L2-SRB** | Signaling Radio Bearer handling                       |
| **5G-L2-TM**  | Test Mode                                             |

### Protocol Stack Coverage

5G-L2-PS participates in the following protocol layers on the air interface side:
- **MAC** (primary scope — scheduling decisions)
- Interacts with RLC, PDCP, SDAP (via 5G-L2-LO and 5G-L2-HI) and with L1 (via subcell interface)

On the transport side, the UP domain covers NR UP, PDU Session UP Protocol, and GTP-U (excluding parts in TRSW).

---

## 2. Hardware Platforms

5G-L2-PS runs on the **L2 processor** of the baseband board. The following L2 devices are used:

| Platform            | L2 Device                 | Characteristics                                                                                                                                            | Board Types                          |
| ------------------- | ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------ |
| **Snowfish / Loki** | Intel Snowfish            | 20 or 24 x86 Atom Tremont cores @2.2 GHz; 6 clusters of 4 cores; 4.5 MB L2 cache per cluster; 15 MB shared L3; DDR4-2933; HW Queue Manager (HQM)           | ABIO (24cx), ABIN (20cx), ASOE, ASOF |
| **Marlin / Thor**   | Marvell CN106XXS (Marlin) | 24 ARM Neoverse Perseus cores @2.1–2.5 GHz; 1 MB per-CPU L2 cache; 48 MB shared LLC; DDR5; HW event scheduler (SSO); NIX packet processor; 100 Gbps crypto | ABIP, ABIQ, ASOG, ASOH               |
| **Cloud vDU**       | Various server CPU        | Server-class CPUs on RINLINE2 or GPU101 platform                                                                                                           | N/A (virtualized)                    |
| **Nemo / Odin**     | Marvell Nemo              | 42 ARM cores                                                                                                                                               | ABIR, ASOK                           |

### Key HW Acceleration for L2-PS

- **Snowfish:** HW Queue Manager (HQM) for packet scheduling among cores; QAT for crypto; NIS (Columbia Park) for scheduling; FPPS (Highland Park) for packet processing/switching
- **Marlin:** HW event scheduler/ODP scheduler (SSO); NIX packet processor; Nitrox V for crypto (120G total); ML/AI accelerator; integrated Ethernet switch (800 Gbps capacity)

---

## 3. Deployment and Core Allocation

5G-L2-PS runs as dedicated CPU cores within the **L2RT container** (Linux container). Each L2RT Instance maps to one EM instance and one Linux container. The L2RT container includes both **LO cores** and **PS cores** (and optionally PS subpool cores).

### Deployment Flavors (Marlin / Thor — Classical)

| Deployment ID | Flavor Name | Configuration                    | LO Cores | PS Cores | Total L2RT Cores | Cell Technology | HP 2M (DP) | HP 2M (Ctxt) |
| ------------- | ----------- | -------------------------------- | -------- | -------- | ---------------- | --------------- | ---------- | ------------ |
| 506 FDD       | 2LO6PSFDD   | Half-board (2 instances)         | 2        | 6        | 8                | FDD             | 426        | 797          |
| 509 TDD       | 2LO6PSTDD   | Half-board (2 instances)         | 2        | 6        | 8                | TDD             | 377        | 549          |
| 511 TDD       | 4LO8PSTDD   | Full-board L2 (1 instance)       | 4        | 8        | 12               | TDD             | 377        | 877          |
| 513 TDD       | 4LO12PSTDD  | Full-board L2 16CPU (1 instance) | 4        | 12       | 16               | TDD             | 377        | 1051         |

### Deployment Flavors (Snowfish / Loki — Classical)

| Deployment ID  | Flavor Name | Configuration           | LO Cores | PS Cores | Cell Technology | HP 2M (DP) | HP 2M (Ctxt) |
| -------------- | ----------- | ----------------------- | -------- | -------- | --------------- | ---------- | ------------ |
| 506 FDD (ABIO) | 2LO6PSFDD   | Half-board              | 2        | 6        | FDD             | 410        | 763          |
| 507 TDD (ABIO) | 2LO4PSTDD   | Half-board              | 2        | 4        | TDD             | 491        | 520          |
| 509 TDD (ABIO) | 2LO6PSTDD   | Half-board (UE pooling) | 2        | 6        | TDD             | 531        | 490          |
| 511 TDD (ABIO) | 4LO8PSTDD   | Full-board L2           | 4        | 8        | TDD             | 591        | 490          |

### Core Layout Principle

On each board, cores are allocated from the isolated CPU set (IsolCpus) using Linux cgroups:
- **Non-IsolCpus** (typically cores 0–3): Linux SMP, OAM, control functions
- **IsolCpus** (cores 4–23): Real-time workloads — L2-HI, L2RT (LO + PS), CP-UE, LTE, TM

Within each L2RT instance, cores are pinned:
- **LO cores** handle 5G-L2-LO processing
- **PS cores** handle 5G-L2-PS scheduling — these are organized into **L2 Subpools**

### Board-Level Deployment Examples

| Board     | Half-Board L2RT   | Full-Board L2RT         | Notes                                   |
| --------- | ----------------- | ----------------------- | --------------------------------------- |
| ABIO      | 2 × (2LO + 4–6PS) | 1 × (4LO + 8PS) or more | Snowfish 24-core; 2 Loki per board      |
| ABIN      | 2 × (2LO + 4PS)   | 1 × (4LO + 8PS)         | Snowfish 20-core; 1 Loki per board      |
| ABIP/ABIQ | 2 × (2LO + 6PS)   | 1 × (4LO + 8–12PS)      | Marlin 24-core; 1 Thor per board        |
| ASOE/ASOF | 2 × (2LO + 4PS)   | 1 × (4LO + 8PS)         | Snowfish 24-core; 2 Loki; TRSW on board |
| ASOG/ASOH | 2 × (2LO + 4PS)   | 1 × (4LO + 8–12PS)      | Marlin 24-core; 1 Thor; TRSW on board   |

### Memory Allocation

Each L2RT instance receives dedicated Huge Pages:
- **Data Plane (DP)**: Scheduling buffers, MAC PDUs (e.g., 377–591 × 2MB pages)
- **Context (Ctxt)**: UE contexts, cell contexts, scheduling state (e.g., 490–1051 × 2MB pages)
- TDD instances generally require less DP memory but variable context memory depending on core count

### CPU Weight

L2RT instances typically receive **6.0–6.4%** CPU weight in the cgroup hierarchy (under the `RAT5G > lxc` group), compared to 5G-L2-HI at ~5% and CP-UE at ~39–46%.

---

## 4. Instance Model and Relationship with L2-LO

### L2RT Instance

An **L2RT Instance** = one instance of 5G-L2-PS + 5G-L2-LO SW, running in the same Linux container.

Key properties:
- Cannot mix LTE and 5G within one L2RT instance
- Multiple L2RT instances are possible on a single processor (half-board = 2 instances; full-board = 1 instance)
- Each instance maps to one EM (Element Manager) instance
- L2RT instances are separate for LTE and 5G (unlike L1 instances which are shared)

### L2 Pool

- The **L2 Pool** is the pooling scope of certain poolable resources in L2
- One L2RT instance contains one or more L2 Pools
- Pool types define the LO + PS core split and the number of subpools

### L2 Subpool

- **L2 Subpool** is a sub-division of an L2 Pool
- Each L2 subpool is a set of PS cores that handle scheduling for assigned cells
- The subpool is the unit for cell-to-core assignment

### L2 Pool Type Examples

| Pool Type                 | LO Cores | PS Subpool Layout      | Use Case           |
| ------------------------- | -------- | ---------------------- | ------------------ |
| NR FDD 3SP                | 2 LO     | 3 × PS subpools        | FDD standard       |
| NR FDD 3SP (1-core LO)    | 1 LO     | 3 × PS subpools        | FDD reduced LO     |
| NR FDD 2C 1SP (1-core LO) | 1 LO     | 1 × 2-core PS subpool  | FDD single subpool |
| NR FDD 2C 2SP (1-core LO) | 1 LO     | 2 × 2-core PS subpools | FDD dual subpool   |
| NR TDD FR1 2SP (1 Loki)   | 2 LO     | 2 × 2-core PS subpools | TDD standard       |
| NR TDD FR1 3SP (1 Loki)   | 2 LO     | 3 × 2-core PS subpools | TDD 3-sector       |
| NR TDD FR1 4SP (1 Loki)   | 2 LO     | 4 × 2-core PS subpools | TDD 4-sector       |

---

## 5. L2 Subpool Types and Scheduling Architecture

### FR1 TDD Subpool Types

| Subpool Type | Core Count | DL/UL Scheduling Model           | Max Cells (high perf) | Max Cells (performance) | Max Cells (connectivity) | Notes                                                                     |
| ------------ | ---------- | -------------------------------- | --------------------- | ----------------------- | ------------------------ | ------------------------------------------------------------------------- |
| 1-core       | 1 PS       | Mix (DL+UL per core)             | —                     | —                       | 1                        | Max 50 MHz BW or max 8DL/8UL UE/TTI. Reduced peak with simultaneous DL+UL |
| 2-core       | 2 PS       | Direct / Partial mix / Cross mix | —                     | 1                       | 2 (avoid from 27R1)      | Scheduling timing alignment. 2 cells should be avoided from 27R1          |
| 3-core       | 3 PS       | Direct (2 DL + 1 UL)             | 1                     | —                       | —                        | Future                                                                    |
| 4-core       | 4 PS       | Cross mix                        | —                     | —                       | 3                        | 28R1 CB015845. Scheduling timing alignment                                |

### FDD Subpool Types

| Subpool Type | Core Count | DL/UL Scheduling Model     | Max Cells (high perf) | Max Cells (performance) | Max Cells (connectivity) | Notes                                |
| ------------ | ---------- | -------------------------- | --------------------- | ----------------------- | ------------------------ | ------------------------------------ |
| 1-core       | 1 PS       | Mix (DL+UL per core)       | —                     | 1                       | —                        | Reduced peak with simultaneous DL+UL |
| 2-core       | 2 PS       | Direct (DL or UL per core) | 1                     | 2 (w/o connectivity)    | 4 (w/o performance)      | Scheduling timing alignment          |

### Scheduling Model Definitions

- **Mix**: Same core handles both DL and UL scheduling for a cell — simpler but lower peak
- **Direct**: Each core handles one direction (DL or UL) — better parallelism
- **Cross mix**: Cells cross-allocated between cores for load balancing
- **Partial mix**: Hybrid of direct and mix modes

### High Load Cell Placement (27R1 CB014508)

Cells can be categorized as **high load** for optimized placement across PS subpools:
- Cells split into high BW (TDD ≥ 50 MHz, FDD ≥ 20 MHz) and low BW categories
- High load cells preferentially mapped to 2-core L2 subpools
- Placement minimizes high load cells per BB Pool and per L2 subpool
- Ordering: descending BW within each load category

---

## 6. Cell Type and Cell Slot Model (L2RT Perspective)

### L2RT Cell Types

Each NR cell consumes one **L2RT cell type** that defines its resource footprint in L2:

| L2RT Type | Duplex | Typical nrCellType Range | Description                  |
| --------- | ------ | ------------------------ | ---------------------------- |
| GA2       | FDD    | 1DL 2UL – 2DL 2UL        | Small FDD cell               |
| GA4       | FDD    | 2DL 4UL – 4DL 4UL        | Medium FDD cell              |
| GA8       | FDD    | 4DL 8UL – 8DL 8UL        | Large FDD cell (BF capable)  |
| GA16      | FDD    | 8DL 8UL – 16DL 8UL       | FDD BF eCPRI 7-2e            |
| GC2       | TDD    | 2DL 2UL                  | Small TDD cell               |
| GC4       | TDD    | 4DL 4UL / 4DL 2UL        | Medium TDD cell              |
| GC4S      | TDD    | 0DL 4UL                  | Positioning cell (NRPOSCELL) |
| GC8       | TDD    | 8DL 4UL – 8DL 8UL        | Large TDD cell               |
| GC16      | TDD    | 16DL 4UL – 16DL 8UL      | Largest TDD cell             |

### Cell Slot Model — L2RT Domain

The CSM L2RT domain determines how many cells can be hosted per L2RT instance:
- **Consumer**: FR1 Cell / Positioning Cell
- **Providing system component**: 5G-L2-PS / 5G-L2-LO
- **Scope**: L2RT Instance

Key rules:
- 5G-L2-PS and 5G-L2-LO are **not differentiated** in the CSM — the cell slot position for each cell/NRCELLGRP shall be the same for both
- L2RT instances are **separate** for LTE and 5G
- FR1 DL-only cells consume the **same** L2RT capacity as bi-directional cells
- 5G-L2-HI has no cell slot model
- In FR1, each NRCELLGRP is restricted to 1 NRCELL

### Cell Context

- **L2RT has cell contexts** — each cell has scheduling state, UE contexts, HARQ state in L2-PS/LO
- L1 does not have cell context (uses subcell context instead)
- L2NRT (5G-L2-HI) has limited-use cell contexts only for counter and debug support

---

## 7. Interworking and Interfaces

### Interface with 5G-L1 (DL and UL)

- L2-PS makes scheduling decisions and sends **scheduling grants** to L1 via the L2-L1 interface
- L1 does not have cell-level context; it operates on **subcells** — the division of a cell into subcells is transparent to L2-PS in terms of MU-MIMO scaling
- One L2RT instance typically maps to one L1 instance (via pool/subpool alignment), but the mapping is through L1 pools/subpools
- Subcells are split separately for DL and UL
- Multiple subcells per cell are used mainly for MU-MIMO beamforming (secondary subcells) and for parallelism in L1

### Interface with 5G-L2-LO

- Co-located in the same L2RT instance and Linux container
- LO handles RLC segmentation/reassembly, HARQ processes, MAC PDU assembly
- PS + LO share the same L2 Pool and L2 Subpool structure
- LO cores and PS cores are pinned separately within the container (e.g., `2LO6PSFDD` = 2 LO cores + 6 PS cores)

### Interface with 5G-L2-HI

- 5G-L2-HI (non-real-time) handles PDCP, SDAP, and RRC-related L2 functions
- L2-HI runs in a **separate container** (UPUE type) with its own core allocation (typically 2 cores)
- Communication between L2RT and L2-HI is cross-container
- L2-HI has no cell slot model

### Interface with 5G-L2-SRB

- Signaling Radio Bearer handling — separate from L2-PS scheduling path

### Interface with OAM / CP-UE

- OAM uses the Cell Slot Model to calculate supported configurations at runtime
- CP-UE (Control Plane UE) runs in its own container with ~39–46% CPU weight
- Cell setup/delete triggers L2-PS resource allocation per CSM rules

### Interface with RPSW

- RPSW (RAN Platform SW) provides the platform runtime environment
- Runs on the non-isolated cores, handling Linux and platform services

---

## 8. Configuration Management

### Basic vs. Advanced UP Configurations

| Aspect              | Basic UP Configuration                                                  | Advanced UP Configuration             |
| ------------------- | ----------------------------------------------------------------------- | ------------------------------------- |
| CSM                 | Basic L1 and L2 Cell Slot Model                                         | Advanced L1 and/or L2 Cell Slot Model |
| Mandatory use cases | Test Dedicated State; Commercial Cell Sets for Super Cell; RF cell sets | Commercial Cell Sets                  |
| Dependencies        | No pooling features; no advanced trade-offs                             | May depend on pooling features        |
| Stability           | Kept stable across releases per HW platform                             | May change with feature additions     |

### Parameters Affecting L2-PS Capacity

**Provided cell slots** (what the system offers):
- System Release, BB HW Platform, Board Type, UP Deployment (Instance Type), Duplex Mode and Numerology (SCS)

**Consumed cell slots** (what each cell costs):
- System Release, BB HW Platform, RAT (LTE or 5G), Duplex Mode and Numerology, Cell BW, Number of DL or UL Spatial Streams, Feature Activations (especially PRB pooling), Fronthaul mode

### Subset Principles

- **Fewer Cells**: Unused positions don't consume slots
- **Cells with Fewer Subcells**: Cell-level consumption unchanged; empty subcell positions don't consume L1 slots
- **Smaller Cells**: Smaller BW or fewer layers — cell slot consumption is not reduced at L2 level

---

## 9. Key Restrictions and Constraints

### L2 Subpool Constraints

- TDD 2-core subpool with 2 cells: Should be avoided from 27R1 — recommendation is to use 2 × 1-core subpools instead
- TDD 1-core subpool: Max 50 MHz BW or max 8 DL/UL UE/TTI
- FDD 2-core subpool: Max 4 connectivity cells or 1 high-perf cell
- Scheduling timing alignment required when multiple cells share a subpool

### Cross-Release Stability

- Basic UP configurations and Basic Cell Slot Models are kept stable across releases for each HW platform
- Advanced configurations may evolve with new features

### Mixing Restrictions

- Different rows of L1 or L2 CSM diagrams shall not be mixed unless explicitly noted
- Cannot mix LTE and 5G within the same L2RT instance
- FDD and TDD cells use separate L2RT instances (separate CellTechno)
