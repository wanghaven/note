## Roadmap

### HW Platforms

| Classical Platform                                    | Xeon / Loner Platform                  | Snowfish / Loki Platform                                    | Marlin / Thor Platform                                                     | N/A                                                                    | Nemo / Odin Platform                |
| ----------------------------------------------------- | -------------------------------------- | ----------------------------------------------------------- | -------------------------------------------------------------------------- | ---------------------------------------------------------------------- | ----------------------------------- |
| Cloud Platform                                        | N/A                                    | RINLINE1                                                    | RINLINE2                                                                   | GPU101                                                                 | N/A                                 |
| L1 Device                                             | Intel FPGA Loner                       | Marvell CNF95XXN Loki                                       | Marvell CNF105XXN Thor (or its fused variant Magni)                        | Various server CPU depending on cloud vendor. Nvidia RTX 4500 Pro GPU. | Marvell Odin (with 2 BPHY chiplets) |
| L1 Composition on Classical                           | ABIL, ASOD: 1 x Loner                  | ABIO, ASOE, ASOF: 2 x Loki ABIN: 1 x Loki                   | ABIP/ASOG/ASOH: 1 x Thor ABIQ: 1x Magni                                    | N/A                                                                    | ABIR, ASOK: 1 x Odin                |
| L1 Composition on Cloud vDU                           | N/A                                    | RINLINE1: 1 x Loki (obsolete)                               | RINLINE2: 1 x Thor                                                         | GPU101: 1 x CPU + 1 x GPU                                              | N/A                                 |
| L2 Device on Classical                                | Intel Xeon (x86 Broadwell cores)       | Intel Snowfish (20 or 24 x86 Atom cores)                    | Marvell CN106XXS Marlin (24 ARM cores)                                     | N/A                                                                    | Marvell Nemo (42 ARM cores)         |
| L2 Device on Cloud vDU and vCU                        | N/A                                    | (obsolete)                                                  | Various server CPU depending on cloud vendor.                              | Various server CPU depending on cloud vendor. Nvidia GPU RTX 4500 Pro. | N/A                                 |
| Platform Introduced (L3 call)                         | 5G18A                                  | 5G21A: Classical 23R2: RINLINE1                             | 23R2: Classical 23R4: RINLINE2                                             | 26R3: GPU101                                                           | 28R3: Classical                     |
| Introduction of NR Use Cases (1st commercial release) | 5G19A: FDD 5G19: TDD cmW 5G19: TDD mmW | 5G21A: FDD 5G21A: TDD cmW 22R1: TDD mmW                     | 24R1: FDD 24R1: TDD cmW 24R3: TDD mmW                                      | 27R3: FDD 27R3: TDD cmW                                                | 28R3: FDD 28R3: TDD cmW             |
| Introduction of HW Variants (1st commercial release)  | 5G19: ABIL 5G19A: ASOD                 | 5G21A: ABIO 22R1: ASOE 22R3: ABIN 23R3: RINLINE1 24R1: ASOF | 24R1: ABIP, ABIQ 24R3: RINLINE2 25R1: ASOG, ASOH 26R3: ASOH as FHE-CPRI GW | 27R3: GPU101                                                           | 28R3: ABIR 29R1: ASOK               |

-----
## Decomposition

### Scope of 5G User Plane Domain

System Components in Scope
- 5G-L1-DL
- 5G-L1-UL
- 5G-L2-PS
- 5G-L2-LO
- 5G-L2-HI
- 5G-L2-SRB
- 5G-L2-TM
External Protocol Layers in Scope
- Air Interface Layer 1 (excluding RF)
- MAC, RLC, PDCP, SDAP (on Air Interface)
- NR UP, PDU Session User Plane Protocol, GTP-U (excluding the parts in TRSW)

### User Plane Functional Architecture
### eCPRI 7-2e Functional Split

(*) Including its associated DMRS.

| Direction                     | DL                                                              |                                                                 |                                            |                                                                                  |                                            |                                            | UL                                                                  |                                                   |                                        |                                                                              |                                                    |
| ----------------------------- | --------------------------------------------------------------- | --------------------------------------------------------------- | ------------------------------------------ | -------------------------------------------------------------------------------- | ------------------------------------------ | ------------------------------------------ | ------------------------------------------------------------------- | ------------------------------------------------- | -------------------------------------- | ---------------------------------------------------------------------------- | -------------------------------------------------- |
| Channel                       | PDSCH (*)                                                       | PDCCH (*)                                                       | PSS, SSS                                   | PBCH (*)                                                                         | CSI-RS                                     | RIM-RS TX                                  | PUSCH (*)                                                           | PUCCH (*)                                         | PRACH                                  | SRS                                                                          | RIM-RS RX                                          |
| Messages on DlData and UlData | DlData _ PdschSendReq, DlData _ PdschPayloadTb SendReq          | DlData _ PdcchSendReq                                           | DlData _ SsBlockSendReq                    | DlData _ SsBlockSendReq                                                          | DlData _ CsiRsSendReq                      | DlData _ RimRsSendReq                      | UlData _ PuschReceive... -Req, -RespLo, -RespPsHarq, -RespPs        | UlData _ PucchReceive... -Req, -RespPs, -RespHarq | UlData _ PrachReceive... -Req, -RespPs | UlData _ SrsReceive... -Req, -Resp, -Ps, -BmPs                               | UlData _ RimReceive... -Req, -Resp                 |
| Functions in L1 (BB)          | Encoding Symbol Mapping Scrambling                              | Encoding Symbol Mapping Scrambling                              | -                                          | -                                                                                | -                                          | -                                          | Decoding Demodulation                                               | Decoding Demodulation Equalization Channel Est.   | Detection Correlation                  | -                                                                            | -                                                  |
| Messages on eCPRI             | DlDataFh _ PdschSendReq, DlDataFh _ PdschEncoded PayloadSendReq | DlDataFh _ PdcchSendReq, DlDataFh _ PdcchEncoded PayloadSendReq | DlDataFh _ SsBlockSendReq                  | DlDataFh _ SsBlockSendReq                                                        | DlDataFh _ CsiRsSendReq                    | DlDataFh _ RimRsSendReq                    | UlDataFh _ PuschReceive... -Req, -RespPs, -RespStCfo, eCPRI UP (UL) | eCPRI CP (DL), eCPRI UP (UL)                      | eCPRI UP (UL)                          | UlDataFh _ SrsReceive... -Req, -RespPs, -RespBmPs                            | UlDataFh _ RimReceive... -Req, -Resp               |
| Functions in L1 (Radio)       | DMRS Modulation Layer Mapping RE Mapping TX Power Precoding     | DMRS Modulation RE Mapping TX Power Precoding                   | Seq creation RE Mapping TX Power Precoding | Encoding Symbol Mapping Scrambling DMRS Modulation RE Mapping TX Power Precoding | Seq creation RE Mapping TX Power Precoding | Seq creation RE Mapping TX Power Precoding | Equalization Measurements Channel Est.                              | -                                                 | -                                      | Covariance Measurements Channel Est. Beam weight calculation for sub-band BF | Detection Measurements (including RI) Channel Est. |
|                               | BF                                                              | BF                                                              | BF                                         | BF                                                                               | BF                                         | BF                                         | BF                                                                  | BF                                                | BF                                     | -                                                                            | BF                                                 |
| Functions in L1Low (RFE)      | IFFT CP Insertion                                               | IFFT CP Insertion                                               | IFFT CP Insertion                          | IFFT CP Insertion                                                                | IFFT CP Insertion                          | IFFT CP Insertion                          | FFT CP Removal                                                      | FFT CP Removal                                    | FFT PRACH Filtering CP Removal         | FFT CP Removal                                                               | FFT CP Removal                                     |

### eCPRI ULPI+Cat-B Functional Split (CB010276)

(*) Including its associated DMRS.

| Direction                     | DL                                                                                                         |                                                                                              |                                                        |                                                                                              |                                                        |                                 | UL                                                                  |                                                   |                                        |                                                                              |                                 |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- | ------------------------------------------------------ | -------------------------------------------------------------------------------------------- | ------------------------------------------------------ | ------------------------------- | ------------------------------------------------------------------- | ------------------------------------------------- | -------------------------------------- | ---------------------------------------------------------------------------- | ------------------------------- |
| Channel                       | PDSCH (*)                                                                                                  | PDCCH (*)                                                                                    | PSS, SSS                                               | PBCH (*)                                                                                     | CSI-RS                                                 | RIM-RS TX                       | PUSCH (*)                                                           | PUCCH (*)                                         | PRACH                                  | SRS                                                                          | RIM-RS RX                       |
| Messages on DlData and UlData | DlData _ PdschSendReq, DlData _ PdschPayloadTb SendReq                                                     | DlData _ PdcchSendReq                                                                        | DlData _ SsBlockSendReq                                | DlData _ SsBlockSendReq                                                                      | DlData _ CsiRsSendReq                                  | Not supported in the IoT phase. | UlData _ PuschReceive... -Req, -RespLo, -RespPsHarq, -RespPs        | UlData _ PucchReceive... -Req, -RespPs, -RespHarq | UlData _ PrachReceive... -Req, -RespPs | UlData _ SrsReceive... -Req, -Resp, -Ps, -BmPs                               | Not supported in the IoT phase. |
| Functions in L1 (BB)          | Encoding Symbol Mapping Scrambling DMRS Modulation Layer Mapping RE Mapping TX Power Beam Weight Combining | Encoding Symbol Mapping Scrambling DMRS Modulation RE Mapping TX Power Beam Weight Combining | Seq creation RE Mapping TX Power Beam Weight Combining | Encoding Symbol Mapping Scrambling DMRS Modulation RE Mapping TX Power Beam Weight Combining | Seq creation RE Mapping TX Power Beam Weight Combining |                                 | Decoding Demodulation Normalization Beam selection                  | Decoding Demodulation Equalization Channel Est.   | Detection Correlation                  | Covariance Measurements Channel Est. Beam weight calculation for sub-band BF |                                 |
| Messages on eCPRI             | eCPRI CP (DL), eCPRI UP (DL)                                                                               | eCPRI CP (DL), eCPRI UP (DL)                                                                 | eCPRI CP (DL), eCPRI UP (DL)                           | eCPRI CP (DL), eCPRI UP (DL)                                                                 | eCPRI CP (DL), eCPRI UP (DL)                           |                                 | UlDataFh _ PuschReceive... -Req, -RespPs, -RespStCfo, eCPRI UP (UL) | eCPRI CP (DL), eCPRI UP (UL)                      | eCPRI UP (UL)                          | eCPRI UP (UL)                                                                |                                 |
| Functions in L1 (Radio)       | Precoding                                                                                                  | Precoding                                                                                    | Precoding                                              | Precoding                                                                                    | Precoding                                              |                                 | Equalization Measurements Channel Est.                              | -                                                 | -                                      | -                                                                            |                                 |
|                               | BF (L1-BB assisted)                                                                                        | BF (L1-BB assisted)                                                                          | BF (L1-BB assisted)                                    | BF (L1-BB assisted)                                                                          | BF (L1-BB assisted)                                    |                                 | BF (L1-BB assisted)                                                 | BF                                                | BF                                     | -                                                                            |                                 |
| Functions in L1Low (RFE)      | IFFT CP Insertion                                                                                          | IFFT CP Insertion                                                                            | IFFT CP Insertion                                      | IFFT CP Insertion                                                                            | IFFT CP Insertion                                      |                                 | FFT CP Removal                                                      | FFT CP Removal                                    | FFT PRACH Filtering CP Removal         | FFT CP Removal                                                               |                                 |
|                               |                                                                                                            |                                                                                              |                                                        |                                                                                              |                                                        |                                 |                                                                     |                                                   |                                        |                                                                              |                                 |
## User Plane Configuration Model

(L1 and L2RT)
### Basic Concepts (1)
L1 Instance (5G-L1-DL and 5G-L1-UL)
- One instance of L1 SW and the scope for L1 SW configuration.
- The same L1 instance covers both DL and UL directions since both 5G-L1-
DL and 5G-L1-UL are configured together.
- The same L1 instance can contain both LTE and 5G.
- 1 Loki is 1 L1 Instance.
- 1 Thor is 1 L1 Instance.
- 1 GPU Instance is 1 L1 Instance.
- 1 Odin is 1 L1 Instance. (Even with 2 BPHY chiplets per Odin. However, separate actions can be planned later to check feasibility of 2 independent L1 Instances due to RAT isolation requirements.)
L2RT Instance (5G-L2-PS and 5G-L2-LO, or 5G-L2-TM)
- One instance of 5G-L2-PS and 5G-L2-LO SW, or one instance of 5G-L2-TM, and the scope of the SW configuration of these components.
- Cannot mix LTE and 5G.
- Maps to one EM instance and one Linux container.
- Multiple L2RT Instances are possible on a single processor.
L2NRT Instance (5G-L2-HI)
- One instance of 5G-L2-HI and the scope of the SW configuration of this component.
Cell (NRCELL)
- L2RT has cell contexts. L1 does not. L2NRT has limited-use cell contexts for counter and debug support.
- Represented by green color, which is also the color of the L2RT.
NRCELLGRP
- Use in FR2 to group cells that need joint Analog Beamforming decisions.
- In FR1 restricted to 1 NRCELL.
- L2RT has NRCELLGRP contexts. L1 and L2NRT do not.

### Basic Concepts (2) - The Subcell
Subcell
- L1 does not have cell context. Subcell contexts are used instead.
- The division of the cell into subcells is mainly a mechanism for easier scaling 
of L1 processing for MU MIMO. It makes MU MIMO largely transparent to L1 
since MU MIMO can be implemented by multiplying the number of subcells 
instead of defining new cell types in L1. This was important especially in the 
context of FPGA-based L1 on the ABIL board, but the concept still remains 
used on all L1 variants. Also it is a mechanism to allow more parallelism in L1 
and in the L1-L2 interface and for splitting the DL and UL parts of the L1 
processing.
- Historically (on ABIL), having more than 1 subcell was also a mechanism for 
various FDM improvements such as for providing more L1 FDM capacity and 
for providing a small degree of FD BF in the absence real FD BF on the eCPRI 
interface. This usage of the subcells is not supported on ABIO and newer HW 
platforms anymore. More information about the RRM impacts of this old 
mechanism can be found in https://webnei.emea.nsn-
net.net/#/webnei/60f16eb87dacf90015d67207/1.
- Subcells are separate for DL and UL.
- DL represented by yellow color, which is also the color of 5G-L1-DL.
- UL represented by blue color, which is also the color of 5G-L1-UL.
Nomenclature of Subcell Types
- Letter based on numerology:
- A for FR1 FDD with 15 kHz SCS.
- C for FR1 TDD with 30 kHz SCS.
- D for FR2 TDD with 120 kHz SCS.
- Number based on the number of Spatial Streams: 2, 4, 8.
- Spatial Streams do not count special eAxCs in eCPRI mode for PRACH, SSBs or NDM SRS.
- Example
- DL C4 is for 4 spatial streams cmW i.e. FR1 TDD with 30 kHz SCS.
Primary vs. Secondary subcell.
- Primary subcell can be used for all physical channels and signals of the cell.
- Secondary subcells can be used for additional capacity for selected channels. Used only in Beamforming configurations, mainly for MU MIMO.
- Primary subcell is represented by underlining and with a darker shade of its color.

Notation for Subcell Capabilities

| Sub component | type | Meaning                                                                              |
| ------------- | ---- | ------------------------------------------------------------------------------------ |
| L1 DL         | C4   | primary DL subcell of the cell, supporting all channels (SSB, CSI-RS, PDCCH, PDSCH)  |
| L1 DL         | C4   | secondary DL subcell, primarily intended for MU MIMO.                                |
| L1 UL         | C4   | primary UL subcell of the cell, supporting all channels (PRACH, PUSCH, PUCCH, SRS)   |
| L1 UL         | C4   | secondary UL subcell, primarily intended for MU MIMO.                                |

### Basic Concepts (3) - The Pools and Subpools
L1 Pool
- The pooling scope of certain poolable resources in L1.
- An L1 instance contains one or more L1 Pools.
- Cannot mix LTE and 5G in the same L1 Pool.
- Alignment with implementation 2024-11-20: L1 Pools are bi-directional i.e. 
the same L1 pool contains both DL and UL parts. However the poolable 
resources are separate between DL and UL so this does not imply any 
pooling between the DL and UL parts.
L1 Subpool
- The pooling scope of certain poolable resources in L1.
- L1 Subpool is a sub-division of an L1 Pool.
- Subpools are unidirectional, i.e. each subpool is either an L1 DL Subpool or 
an L1 UL Subpool.
- Alignment with implementation 2024-11-20: The L1 Pool contains one or 
more DL L1 Subpools + one or more UL L1 Subpools.
L2 Pool
- The pooling scope of certain poolable resources in L2.
L2 Subpool
- The pooling scope of certain poolable resources in L2.
- L2 Subpool is a sub-division of an L2 Pool.
[5G User Plane Architecture - Baseband Pooling](https://nokia.sharepoint.com/sites/5GSystemEngineering/Shared Documents/5G RAN A-S/5G User Plane/5G User Plane Architecture - Baseband Pooling.pptx?web=1)  defines which resources are pooled on pool and subpool levels.
[LTE-5G Common User Plane Architecture and Roadmap]([LTE-5G Common User Plane Architecture and Roadmap.pptx](https://nokia.sharepoint.com/:p:/r/sites/5GSystemEngineering/_layouts/15/Doc.aspx?sourcedoc=%7B09126050-31E6-41EC-B0E2-2C775321719E%7D&file=LTE-5G%20Common%20User%20Plane%20Architecture%20and%20Roadmap.pptx&wdLOR=c2E7B66E3-BE70-4AB8-9739-6E863A57A0FF))  has further definitions of these concepts.

### Placement of High Load Cell (27R1 CB014508)
Background
- 27R2 CB014508 provides possibility to categorize a cell as high load cell in the configuration 
file. High load cell categorization is expected to be based on absolute traffic load expectation 
between cell within RAT in the network, such as data volume. 
- It enables mapping of high load cells to the most sufficient UP resources in balanced manner for 
better KPI expectation.
- By default, all cells have normal load categorization.
- There are legacy rules how to place a cell, for instance:
- Minimize number of normal load cells per L2 subpool.
- Minimize number of normal load cells per L1 subpool.
- Cell counte and BW-based rules for load balancing cumulative BW between L1 Pools/L1 Subpools/L2 subpools apply still in TDD, 
and the BW-based rules are also inherited to FDD by this feature. 
- There are new rules and they apply in addition to the legacy rules without directly overriding 
them.
New Rules
- Cells shall be categorized to high BW or to low BW by the system.
- TDD threshold is 50MHz and FDD one is 20MHz to consider a cell as low BW.
- Within high BW cells and separately within low BW cells number of high load cells per BB Pool shall 
be minimized.
- Number of high BW cells per L1 subpool and per L2 subpool shall be minimized.
- Within high BW cells and separately within low BW cells number of high load cells per L1 subpool 
and per L2 subpool shall be minimized.
- A high BW cell shall be primarily mapped to BB pool having 2-core L2 subpool(s).
- Within high BW cells and separately within low BW cells a high load cell shall be primarily mapped to 
BB pool having 2-core L2 subpool(s).
- A high BW cell shall be primarily mapped to the 2-core L2 subpool.
- Within high BW cells and separately within low BW cells a high load cell shall be primarily mapped to 
the 2-core L2 subpool.
- Within high BW cells and separately within low BW cells a normal cell shall be primarily mapped to 
2-core L2 subpool, if there is any such L2 subpool unused after mapping high load cells.
- Within high BW cells and separately within low BW cells, and within high load and separately within 
normal load, the cells shall be mapped in descending BW order.

Possible OAM implementation for cells under configuration
- Form high BW and low BW lists of cells and map all cells under configuration to them.
- Order cells in descending BW order in each list.
- Go through the cells separately in each list from first to last and place a cell with high load 
categorization to the first position if this is the first high load cell or to the first position after 
previously placed high load cell if this is not the first such cell.
- Configure high BW cells to eligible pools and subpools from first to last, minimizing total number 
of cells per pool and subpool, minimizing number of high BW high load cells per pool and subpool, 
and favoring pools and subpools with 2-core L2 subpool deployment.
- If there are multiple placement possibilities to a cell under configuration, the cell may be placed to a subpool and a pool that have 
the lowest accumulated BW of already configured cells.
- Configure low BW cells to eligible pools and subpools from first to last, minimizing total number of 
cells per pool and subpool, minimizing number of low BW high load cells per pool and subpool, and 
favoring pools and subpools with 2-core L2 subpool deployment.
- If there are multiple placement possibilities to a cell under configuration, the cell may be placed to a subpool and a pool that have 
the lowest accumulated BW of already configured cells.
Online Reconfiguration
- Load categorization change of a cell shall be supported online (but parameter modification type is 
‘conditional BTS restart’).
- Online modification may apply in 4 different scopes:
- If no new placement of a cell is needed – change is applied online.
- If only the cell in question needs new placement and no other reconfiguration is needed (destination BB pool applies to the cell) – 
the cell lock/unlock is applied.
- If board level reconfiguration is needed (e.g. L1 pool reconfiguration) – reset of BB module/L1 instance and all cells there is 
applied.
- If multiple board reconfigurations or system module reconfiguration is needed – BTS/RAT reset is applied (if allowed in the current 
state based on online modified configuration).
Activation Flag
- Temporary activation flag is sufficient. Default setting is ‘Activated’, and there is temporary 
possibility deactivate the feature. ACD is required.

### Aspects of UP Configuration
#### 1) Cell Set Feature Defined by PdM

  CB006916: "NR ABIO BB cell sets up to 6 TDD cells eCPRI 16DL/4UL"

  This feature introduces the baseband cell set of 3 cells NR FR1 TDD up to 16DL/4UL layers with eCPRI fronthaul. ABIO board can support 2 baseband cell sets (ABIO slot A and B), total 6 cells.

  Following cell sets are supported by this feature: Cell set type CB006916-A: Up to 3 cells 16DL-4UL. With beamforming. Carrier bandwidth up to 100MHz. 10GE or 25GE eCPRI link is used on ABIO.

  Note: above Focal Point description uses "layers" to refer to "spatial streams".

  
#### 2) Cell Type and its Subcell Composition

  Defined in the Cell Type Catalog based on Cell Technology (FDD, cmW or mmW), Beamforming mode, Receiver Type and the Spatial Dimensions (nrCellType) of the Cell.

  Example: cmW (FR1 TDD) Beamforming 4RX nrCellType 16DL 4UL
   
| Sub component  | type | Meaning                |
| -------------- | ---- | ---------------------- |
| L2RT           | GC16 | Cell Type in L2RT      |
|                |      |                        |
| L1 DL          | C4   | Primary DL Subcell     |
| L1 DL          | C4   | Secondary DL Subcells  |
| L1 DL          | C4   | Secondary DL Subcells  |
| L1 DL          | C4   | Secondary DL Subcells  |
| L1 UL          | C4   | Primary UL Subcell     |
| L1 UL          | C4   | Secondary UL Subcells  |

#### 3) High-Level UP Configuration Diagram
  Example of how the cell set is intended to be realized in User Plane.
  New style introduced in 22R1/22R2 to visualize the Cell Slot Model and pooling concepts.
  Usually depicts one L2RT instance and one L1 Instance.
  When two instances of either L1 or L2RT need to be shown, it is marked separately.
  
|--------------------------------------------------------------------------------------|
| L2RT                          | 5G-L1-DL                                                   | 5G-L1-UL      |
|--------------------------------------------------------------------------------------|
| GC16                         | C4            C4            C4            C4              | C4                |  Cell 1
|            GC16              |      C4            C4            C4            C4         |       C4          |  Cell 2
|                        GC16  |           C4            C4            C4            C4    |            C4     |  Cell 3
|--------------------------------------------------------------------------------------|
| L2SP    L2SP     L2SP  |    L1Sp          L1Sp         L1Sp        L1Sp     |       L1Sp       |  SubPools
|--------------------------------------------------------------------------------------|
| TDD FR1 L2 instance |                   TDD FR1 L1 Instance eCPRI                            |  Pools
|--------------------------------------------------------------------------------------|
#### 4) L2 Deployment
| 5G21B: ABIO | cluster 0 | cluster 1 |     |     |     | cluster 2 |     |     |     | cluster 3 |     |     |     | cluster 4 |     |     |     | cluster 5 |     |     |     | Comments                  |
| ----------- | --------- | --------- | --- | --- | --- | --------- | --- | --- | --- | --------- | --- | --- | --- | --------- | --- | --- | --- | --------- | --- | --- | --- | ------------------------- |
| TDD         | L3 (*)    | HI        | HI  | -   | -   | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  | -         | -   | -   | -   | -         | -   | -   | -   | L2NRT and L2RT Instance 1 |
|             |           | -         | -   | HI  | HI  | -         | -   | -   | -   | -         | -   | -   | -   | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  | L2NRT and L2RT Instance 2 |

#### 5) Cell Slot Model
Defines the actual UP capabilities. Part of the rule set that defines how O&M is allowed to configure cells in User Plane. O&M is expected to calculate the exact configuration at cell setup time according to these rules.
#### 6)  5G-L2-PS Internal Deployment Assumption
TD schedulers (cell-specific) are arranged according to L2 subpools in the L2 cell slot model.

| Core 0 |     | Core 1 |     | Core 2 |     | Core 3 |     |        |
| ------ | --- | ------ | --- | ------ | --- | ------ | --- | ------ |
| TD     | FD  |        | FD  |        | FD  |        | FD  | Cell 1 |
|        | FD  | TD     | FD  |        | FD  |        | FD  | Cell 2 |
|        | FD  |        | FD  | TD     | FD  |        | FD  | Cell 3 |
|        |     |        |     |        |     |        |     |        |

### Aspects of UP Configuration (5) - Plan for 24R1 onwards

Rationale: Many products and lots of porting features that need internal cell sets. Attempt to standardardize UP configurations to limit efforts.
Basic User Plane Configurations
- Basic L1 and L2 Cell Slot Model (when CSM applicable).
- Mandatory use cases
- Test Dedicated State.
- Commercial Cell Sets for TDD Super Cell, FDD Super Cell and FR2 before pooling is introduced and when no 
other advanced mechanism is needed.
- RF cell sets (for eCPRI 7-2e, for L1 parts only.
- Optional use cases
- Internal configurations for RRM features that don't fit in existing cell sets.
- Internal configurations for L3 calls and in parity features for porting other features than pooling.
- Note: Use of advanced configurations is recommended for alignment with commercial use.
- Forbidden dependencies
- All pooling features: Buffered UL, Subcell pooling, UE pooling, PRB pooling, etc. (But enabling of pooling on 
gNB level does not prevent Basic UP configurations where pooling is disabled at runtime.)
- fddCellConfigTradeOff other than maxCells.
- High number of cells per L2 subpool (exact definition varies per SW deployment).
- Cell amount optimization for FR1 FDD A2 or lower subcell type (UL layer-PRB exception).
- Cell amount optimization for FR1 FDD cell BW other than 20 MHz, 40 MHz, 50 MHz.
- Cell amount optimization for FR1 TDD less than 100 MHz.
- Special or customer-specific cell sets, concurrent mode within one cell set (depends on the product and 
subject to case-by-case selection).
- All supported products shall be covered for all supported numerologies, cell 
types and cell bandwidths.
- Basic UP Configurations for Maximum Non-Pooled Cell Amount (for SU MIMO cell types for example).
- Basic UP Configurations for Single Cell of the Highest Cell Type (for MU MIMO cell types for example).
- Shall be accessible via R&D mechanisms even for new products that officially 
support only pooled cell sets.
- Attempt to keep Basic UP Configurations and Basic Cell Slot Models stable 
across releases for each HW platform.
Advanced User Plane Configurations
- Advanced L1 and/or L2 Cell Slot Model (when CSM applicable).
- Use cases
- Commercial Cell Sets.
- Internal configurations for pooling features.
- Internal configurations for parity features for porting pooling features.
- May depend on any pooling feature or other advanced mechanism.
Temporary Subsets
- These are not separate configurations or cell slot models but merely use 
cases based on subsets of Basic or Advanced configurations and cell slot 
models.
- No new Temporary Subsets will be shown in UP Configuration Examples 
materials when no new development is involved. (For example L3 call of a 
new product on existing HW platform.)

### Cell Slot Model: Introduction

Purposes
- Allow runtime calculation of supported UP configurations by OAM instead of 
predefined configurations.
- Define constaints under which runtime configuration changes (successive 
cell delete, cell setup) in UP can be applied by OAM without any internal 
resource fragmentation in UP.
- Model will define the number of cells slots provided and consumed, as well 
as the allowed placements of cells on the numbered cell slots.
- Current scope is FR1 FDD and FR1 TDD for all HW Platforms except Xeon / 
Loner. FR2 will come later.
Domains

| Domain | Consumer              | Providing SC | Scope         |
|--------|-----------------------|--------------|---------------|
| L1 DL  | DL Subcell            | 5G-L1-DL     | L1 Instance   |
| L1 UL  | UL Subcell            | 5G-L1-UL     | L1 Instance   |
| PRACH  | UL Subcell            | 5G-L1-UL     | L1 Instance   |
| L2RT   | FR1: Cell             | 5G-L2-PS/LO  | L2RT Instance |
|        | FR2: NRCELLGRP        | 5G-L2-PS/LO  | L2RT Instance |
|        | FR1: Positioning Cell | 5G-L2-PS     | L2RT Instance |
| DL FDF | DL Subcell            | 5G-L1-DL     | L1 Instance   |
| UL FDF | UL Subcell            | 5G-L1-UL     | L1 Instance   |
 - Each of the 7 domains forms an independent cell slot space and the cell slot 
positions do not need to be aligned between the domains.
- 5G-L2-PS and 5G-L2-LO are not differentiated from each other in the cell 
slot model. This means that the cell slot position for each cell / NRCELLGRP 
shall be the same for both of these system components..
- 5G-L2-HI does not have a cell slot model.
- L1 Instance = Loki or Thor or Odin. The L1 instance and therefore the cell 
slots are common for LTE and 5G. Additionally, the subcell placement in the 
L1 cell slot model defines the L1 subpools. Previously planned SRS domain 
has been removed. SRS is processed by primary UL subcells.
- The L2RT instances are separate for LTE and 5G. The L2RT instances 
between 1/2 boards are separate.
- FR1 DL-only cells (24R3 CB008224) consume the same L2RT capacity as bi-
directional cells.
- The PRACH domain is introduced in 24R3 by CB010448.
- This applies for pooled L1 Pool types on Thor and newer HW and only for FR1 FDD.
- It is for the O&M purposes to help understand the underlying PRACH capacity restrictions.
- The cell slot assignment for PRACH is independent from the cell slot assignment in the L1 UL 
domain.
- Starting from CB010448 in 24R3, the CSI-RS pooling groups are modelled 
as part of the L1 DL domain.
- This applies for pooled L1 Pool types on Thor and newer HW and only for FR1 FDD.
- For each DL L1 Pool type, cell slot ranges are defined for CSI-RS pooling groups and the cell 
slot placement of the primary subcell determines the grouping of the cells.
- The DL/UL FDF domain is introduced in by 27R3 LL CB014369
- This applies for L1 Pool types on Thor and newer HW.
- It is for understanding underlaying Fronthaul Data Forwarding (FDF) capacities.

Subset Principles
- Fewer Cells are supported.
- In such a subset, unused cell or subcell positions don't consume any Cell Slots in the L2 and/or L1 CSM.
- Cells with Fewer Subcells are supported.
- In such a subset, the Cell Slot consumption on cell level is not reduced and directly follows the Cell Slot 
consumption indicated in the L2 CSM.
- Empty subcell positions don't consume any cell slots in the L1 CSM.
- Smaller or Less-Capable Cells or Subcells are supported.
- Smaller Cell BW.
- Smaller Subcell Types with fewer antennas or fewer spatial streams.
- In such a subset, the Cell Slot consumption of cells and subcells is not reduced and directly follows the Cell 
Slot consumption indicated in the L2 and/or L1 CSM.
Mixing Principles
- Unless otherwise noted, different rows of the L1 or L2 CSM diagrams shall 
not be mixed.
Relation to BB Cell Sets
- Customer-visible BB Cell Sets defined by SiSo PdM and Nokia-internal UP 
configurations defined by UP architects are subsets of the L1 and L2 
capabilities offered by this CSM. See 5G User Plane Configuration Examples.
- The feature scopes of BB Cell Sets defined by SiSo PdM may have 
restrictions compared to the CSM or exceptions to the subset principles 
above and those are not necessarily modelled in the cell slot model.
Examples of Parameters Affecting Provided Cell Slots
- System Release
- BB HW Platform and BB Board Type
- UP Deployment (Instance Type)
- Duplex Mode (FDD or TDD) and Numerology (SCS)
Examples of Parameters Affecting Consumed Cell Slots
- System Release
- BB HW Platform
- RAT (LTE or 5G)
- Duplex Mode (FDD or TDD) and Numerology (SCS)
- Cell BW
- Number of DL or UL Spatial Streams
- Feature Activations, especially PRB pooling
- Fronthaul: CPRI/OBSAI, eCPRI 7-2, eCPRI 7-2 eUL, ORAN
Acronyms and Notes
- CS = Cell Slot
- CSM = Cell Slot Model
- SP = Subpool.
- Note: L2 Subpools are used only for 22R2 onwards.

### Cell Slot Model: L1 or L2 Restrictions Outside CSM Impacting Cell Amounts

FR1 FDD PRACH Capacity (before CB010448)
- Due to limited L1 capacity, the cells need to be load balanced between 
different time-domain positions of PRACH, i.e. different PRACH 
Configuration Index values.
- Format 1 (5GC000938) is more consuming than format 0 (5GC000836).
- PRACH capacity per slot:
- Loki L1 Instance with 2 L1 Subpools
	- 2 cells format 1 or
	- 2 cells format 0 + 1 cell format 1 or
	- 3 cells format 0 per L1 Instance.
- Loki L1 Instance in Concurrent Mode
	- 1 cell format 1 or
	- 2 cells format 0
- Thor L1 Pool with 2 L1 Subpools
	- 2 cells format 1 or
	- 2 cells format 0 + 1 cell format 1 or
	- 3 cells format 0 or
	- CB010448: 4 cells format 0 per L1 Pool.
- Thor L1 Pool with 1 L1 Subpools
	- 1 cell format 1 or
	- 2 cells format 0
FR1 FDD PRACH Capacity (CB010448)
- Starting from CB010448 on Thor-based L1, PRACH capacity for FR1 FDD cells will be 
modelled as a CSM. (Also the PRACH capacity will increase in the same feature.)
FR1 FDD High-Speed (25R3, CB007491)
- The maximum number of NR FDD cells with High-Speed operation per L1 
Pool is limited.
- The position of those high-speed cells within the L1 Pool is not restricted in 
terms of neither the cell slot positions nor the L1 subpool.
- The total number of cells is not impacted i.e. there can be regular cells in 
addition to the maximum number of high-speed cells.
- Maximum number of High-Speed Cells:
- Loki L1 Pools with 2 L1 Subpools
	- 6 high-speed cells per L1 Pool
- Loki L1 Pools with 1 L1 Subpool (This applies for concurrent NR FDD and NR 
TDD/LTE on the same Loki.)
	- 3 high-speed cells per L1 Pool
- Thor L1 Pools with 2 L1 Subpools
	- 8 high-speed cells per L1 Pool.
	- 27R1 (CB014275): Up to 60MHz aggregated BW for high-speed cells per L1 Pool, in L1 pool with 8RX support.
- Thor L1 Pools with 1 L1 Subpool (This applies for concurrent NR FDD and NR 
TDD/LTE on the same half-Thor.)
	- 3 high-speed cells per L1 Pool.
	- 27R1 (CB014275): Up to 30MHz aggregated BW for high-speed cells per L1 Pool, in L1 pool with 8RX 	support.
### Architecturally Significant Requirements for User Plane Configuration Model

Note: Remaining ASRs have been moved to DOORS UP System Level chapter 3.1

| Release | Feature                                                                               | Requirement                                                                                                                                                                                                                      | Rationale                                                                                                                                                                                                                             |
| ------- | ------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 23R1    | (undocumented legacy behavior agreed as future direction and resolution of ambiguity) | For Beamforming FR1 TDD cells, it shall be allowed to configure an nrCellType with more spatial streams than what is needed for the DL MU MIMO or UL MU MIMO features configures in the cell.                                    | Avoid unnecessary dependencies between RRM and SiSo configurations and simplify the procedure to enable/disable MU MIMO features. For example 8DL 8UL can be used for the future 8RX receiver feature even if DL MU MIMO is disabled. |
| 24R1    | (CNI to be created by Bernd Baumgartner)                                              | The mapping of NDM SRS streams into OFDM symbol positions on the eCPRI interface shall be compatible between all combinations of RU type and all nrCellType, so that these combinations can be freely mixed in the same L1 Pool. | To fix architectural debt introduced by CB010388.                                                                                                                                                                                     |

| Release | Feature | Requirement | Rationale |
| --- | --- | --- | --- |
| 24R3 | CB010496 "FR2 ABIP BB cell sets 2 sectors 8ccDL4ccUL or 4 sectors 4ccDL2ccUL 2T2R" (This ASR is to be moved to the 24R2 part of CB010576 in CFAM phase.) | For any FR2 cell without MU MIMO, there shall be exactly one DL subcell and at most one UL subcell, and those subcells shall be primary. | To keep alignment with FR1, the concept of secondary subcells shall be reserved for future MU MIMO features. |
| 24R3 | CB010496 "FR2 ABIP BB cell sets 2 sectors 8ccDL4ccUL or 4 sectors 4ccDL2ccUL 2T2R" (This ASR is to be moved to the 24R2 part of CB010576 in CFAM phase.) | For any FR2 cell with both DL and UL, the primary DL subcell shall be allocated in the same relative L1 pool and L1 subpool as the primary UL subcell. (Note: For this purpose, there shall be a 1:1 mapping between the DL and UL pools and subpools.) | To keep alignment with FR1, to keep preparedness for any DL/UL interaction within L1, and to keep compatibility with future pooling features. |

---
## Cell Type and Subcell Type Catalogs

### Cell Type Catalog – FR2

(*) For CPRI, OBSAI or eCPRI 7-2a, nrCellType defines the number of Spatial Streams.

| System Use Case     | Component Carriers | RRM Feature              | 1st BB Cell Set (on Loki) | 1st BB Cell Set (on Thor) |     | Maximum Cell Composition of NRCELLGRP (subsets are supported) | NRCELLGRP in L2RT |
| ------------------- | ------------------ | ------------------------ | ------------------------- | ------------------------- | --- | ------------------------------------------------------------- | ----------------- |
| NRCELLGRP in mmW BF | 4CCs DL 2CCs UL    | (old feature from Loner) | 22R1 CB007596             | 24R2 CB010496             |     | 2 NRCELLs 2DL 2UL Streams + 2 NRCELLs 2DL 0UL Streams         | GD2 / 400         |
|                     | 8CCs DL 4CCs UL    | (old feature from Loner) | 22R1 CB006950             | 24R2 CB010496             |     | 4 NRCELLs 2DL 2UL Streams + 4 NRCELLs 2DL 0UL Streams         | GD2 / 800         |

| System Use Case  | nrCellType (*)           | RRM Feature              | 1st BB Cell Set (on Loki) | 1st BB Cell Set (on Thor) |     | Subcell Composition / DL | Subcell Composition / UL | Comment              |
| ---------------- | ------------------------ | ------------------------ | ------------------------- | ------------------------- | --- | ------------------------ | ------------------------ | -------------------- |
| NRCELL in mmW BF | 2DL 2UL (2DL 2UL Layers) | (old feature from Loner) | 22R1 CB007596             | 24R2 CB010496             |     | D2                       | D2                       |                      |
|                  | 2DL 0UL (2DL 0UL Layers) | 5GC001547                | 22R1 CB006950             | 24R2 CB010496             |     | D2                       | -                        | Supplemental DL cell |

### Cell Type Catalog – FDD Non-BF

(*) For CPRI, OBSAI or eCPRI 7-2a, nrCellType defines the number of Spatial Streams.

| System Use Case | nrCellType (*) | RRM Feature | 1st BB Cell Set (on Loki) | 1st BB Cell Set (on Thor) |  | Subcell Composition / DL | Subcell Composition / UL | Cell Type in L2RT | Comment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| FDD Non-BF | 1DL 2UL (1DL 2UL Layers) | 23R1 CB008983 | 23R1 (modify legacy CS) | 24R1 CB009014 |  | A1 | A2 | GA2 | Supports 4RX IRC for PUSCH with UL CoMP (27R1 CB008465). |
|  | 2DL 2UL (2DL 2UL Layers) | (old feature from Loner) | 5G21A CB006814 | 24R1 CB009014 |  | A2 | A2 | GA2 | Supports 4RX IRC for PUSCH with UL CoMP (27R1 CB008465). |
|  | 2DL 4UL (2DL 2UL Layers) | (old feature from Loner) | 5G21A CB006814 | 24R1 CB009014 |  | A2 | A4 | GA4 | Supports 8RX IRC for PUSCH with UL CoMP (27R1 CB008465). |
|  | 4DL 4UL (4DL 2UL Layers) | (old feature from Loner) | 5G21A CB006814 | 24R1 CB009014 |  | A4 | A4 | GA4 | Supports 8RX IRC for PUSCH with UL CoMP (27R1 CB008465). |
|  | 2DL 0UL (2DL 0UL Layers) | 24R3 CB008224 | 24R2 (modify legacy CS) | 24R2 (modify legacy CS) |  | A2 | - | GA2 |  |
|  | 4DL 0UL (4DL 0UL Layers) | 24R3 CB008224 | 24R2 (modify legacy CS) | 24R2 (modify legacy CS) |  | A4 | - | GA4 |  |
|  | 4DL 8UL (4DL 2UL Layers) | 27R1 CB014128 | (not supported) | 27R1 CB014560 |  | A4 | A8 | GA8 |  |
|  | 8DL 8UL (4DL 2UL Layers) | (future) | (future) | (future) |  | A8 | A8 | GA8 |  |

### Cell Type Catalog – FDD Super Cell

(*) For CPRI, OBSAI or eCPRI 7-2a, nrCellType defines the number of Spatial Streams.
(**) For super cells, the streams of nrCellType are counted per super cell subcell.

| System Use Case | nrCellType (*)                | RRM Feature   | 1st BB Cell Set (on Loki) | 1st BB Cell Set (on Thor) |     | Subcell Composition / DL   | Subcell Composition / UL                    | Cell Type in L2RT | Comment            |
| --------------- | ----------------------------- | ------------- | ------------------------- | ------------------------- | --- | -------------------------- | ------------------------------------------- | ----------------- | ------------------ |
| FDD Super Cell  | 1DL 2UL (**) (1DL 2UL Layers) | 26R2 CB009543 | 26R2 CB011061             | 26R3 CB011064             |     | A1 + (#subcells - 1) x A1F | #subcells x A2                              |                   | All UL sc primary. |
|                 | 2DL 2UL (**) (2DL 2UL Layers) | 26R2 CB009543 | 26R2 CB011061             | 26R3 CB011064             |     | A2 + (#subcells - 1) x A2F | #subcells x A2                              |                   | All UL sc primary. |
|                 | 2DL 4UL (**) (2DL 2UL Layers) | 26R2 CB009543 | 26R2 CB011061             | 26R3 CB011064             |     | A2 + (#subcells - 1) x A2F | #subcells x A4                              |                   | All UL sc primary. |
|                 | 4DL 4UL (**) (4DL 2UL Layers) | 26R2 CB009543 | 26R2 CB011061             | 26R3 CB011064             |     | A4 + (#subcells - 1) x A4F | #subcells x A4                              |                   | All UL sc primary. |

### Cell Type Catalog – FDD BF

(*) For CPRI, OBSAI or eCPRI 7-2a, nrCellType defines the number of Spatial Streams.

| System Use Case | nrCellType (*) | RRM Feature | 1st BB Cell Set (on Loki) | 1st BB Cell Set (on Thor) |  | Subcell Composition / DL | Subcell Composition / UL | Cell Type in L2RT | Comment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| FDD BF eCPRI 7-2a | 4DL 8UL (4DL 2UL Layers) | 26R2 CB013442 / CB008577 | (not supported) | 26R2 CB015905 |  | A4 | A8 | GA8 |  |
|  | 8DL 8UL (8DL 2UL Layers) | 27R2 CB007567 (Loki) / 27R3 CB016418 (Thor) |  | 27R3 CB016479 |  | A4 A4 | A8 | GA8 |  |

| System Use Case                                  | nrCellType (*)       | RRM Feature | 1st BB Cell Set (on Loki) | 1st BB Cell Set (on Thor) |     | DL Subcell Composition in L1 (BB) and L1 (Radio) | UL Subcell Compo- sition in L1 (BB) | UL Subcell Compo- sition in L1 (Radio) | Cell Type in L2RT |
| ------------------------------------------------ | -------------------- | ----------- | ------------------------- | ------------------------- | --- | ------------------------------------------------ | ----------------------------------- | -------------------------------------- | ----------------- |
| FDD BF (eCPRI 7-2e) Both UL and DL in 7-2e mode. | 8DL 8UL              |             |                           | 27R3 CB016430             |     | A4 A4                                            | A8'8                                | A16'8                                  | GA16              |
|                                                  | 16DL 8UL             |             |                           |                           |     | A4 A4 A4 A4                                      | A8'8                                | A16'8                                  | GA16              |
|                                                  | 16DL 8UL w/ 32RX IRC |             |                           |                           |     | A4 A4 A4 A4                                      | A8'8                                | A16’4 A16’4                            | GA16              |
### Cell Type Catalog – TDD Non-BF

(*) For CPRI, OBSAI or eCPRI 7-2a, nrCellType defines the number of Spatial Streams.
(**) For super cells, the streams of nrCellType are counted per super cell subcell.

| System Use Case | nrCellType (*) | RRM Feature | 1st BB Cell Set (on Loki) | 1st BB Cell Set (on Thor) |  | Subcell Composition / DL | Subcell Composition / UL | Cell Type in L2RT | Comment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| cmW Non-BF (CPRI or eCPRI) | 2DL 2UL (2DL 2UL Layers) | (old feature from Loner) | 5G21A 5GC002340 | 24R1 CB009142 |  | C2 | C2 | GC2 |  |
|  | 4DL 4UL (4DL 2UL Layers) | (old feature from Loner) | 5G21A 5GC002340 | 24R1 CB009142 |  | C4 | C4 | GC4 |  |
|  | 8DL 8UL (4DL 2UL Layers) | (not planned) | (not planned) | (not planned) |  | C8 | C8 | GC8 |  |
| cmW Non-BF NRPOSCELL | 0DL 4UL (0DL 0UL Layers) | 25R2 SiSo CB010680 | (not planned) | 25R2 CB010680 |  | none | C4S | GC4S |  |
| cmW Sub- Sectorization (eCPRI 7-2) | 2DL 2UL (2DL 2UL Layers) | (old feature from Loner) | 5G21A 5GC002340 | (not planned) |  | C2 | C2 | GC2 | 8T8R |
|  | 4DL 2UL (4DL 2UL Layers) | (old feature from Loner) | 5G21A 5GC002340 | (not planned) |  | C4 | C2 | GC4 | 8T8R |
| cmW Super Cell (CPRI or eCPRI) | 2DL 2UL (**) (2DL 2UL Layers) | 23R1 CB008985 | 23R1 CB008434 | 24R1 CB009142 |  | #SSBs x C2 | #SSBs x C2 | GC2 | All sc primary. |
|  | 4DL 4UL (**) (4DL 2UL Layers) | 23R1 CB008985 | 23R1 CB008434 | 24R1 CB009142 |  | #SSBs x C4 | #SSBs x C4 | GC4 | All sc primary. |

### Cell Type Catalog – TDD BF eCPRI 7-2a

(*) For CPRI, OBSAI or eCPRI 7-2a, nrCellType defines the number of Spatial Streams.
(**) TBD: For RF8, the streams of the nrCellType are counted at output of precoder and input of 
receiver. On fronthaul, 8 streams are used in both DL and UL due to BF in BB.

| System Use Case | nrCellType (*) | RRM Feature | 1st BB Cell Set (on Loki) | 1st BB Cell Set (on Thor) |  | Subcell Composition / DL | Subcell Composition / UL | Cell Type in L2RT | Comment |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| cmW BF (eCPRI 7-2) with 4RX | 4DL 4UL (4DL 2UL Layers) | (old feature from Loner) | 5G21A 5GC002340 | 24R1 CB009142 |  | C4 | C4 | GC4 | MAA or 8T8R |
|  | 4DL 4UL (**) (4DL 2UL Layers) | CB010250/ CB012180? | (not planned) | ~27R2 (legacy CS) |  | C8 | C4 + BF | GC8 | 8T8R RF8 |
|  | 4DL 8UL (**) (4DL 2UL Layers) | CB010250/ CB012180? | (not planned) | ~27R2 (legacy CS) |  | C8 | C8 | GC8 | 8T8R RF8 |
|  | 8DL 4UL (8DL 2UL Layers) | 5G21A 5GC000524 | 5G21A 5GC002339 | 24R1 CB009142 |  | C4 C4 | C4 | GC8 | MAA |
|  | 16DL 4UL (16DL 2UL Layers) | 23R1 CB008701 | 23R3 CB008149 | 24R1 CB009008 |  | C4 C4 C4 C4 | C4 | GC16 | MAA |
|  | 8DL 8UL (8DL 4UL Layers) | 23R1 CB008360 | 23R1 CB009403 | 24R1 CB009142 |  | C4 C4 | C4 C4 | GC8 | MAA |
|  | 16DL 8UL (16DL 4UL Layers) | 23R1 (combination) | 23R1 CB009403 | 24R1 CB009008 |  | C4 C4 C4 C4 | C4 C4 | GC16 | MAA |
| cmW BF (eCPRI 7-2) with 8RX | 16DL 8UL (16DL 4UL Layers) | 23R3...24R1 CB009363 | (not planned) | 23R3...24R1 CB009363 |  | C4 C4 C4 C4 | C8 | GC16 | MAA |
|  | 8DL 8UL (8DL 4UL Layers) | 23R3...24R1 CB009363 | (not planned) | 23R3...24R1 CB009363 |  | C4 C4 | C8 | GC8 | MAA |
|  | 16DL 16UL (16DL 8UL Layers) | (not planned) | (not planned) | (not planned) |  | C4 C4 C4 C4 | C8 C8 | GC16 |  |
### Cell Type Catalog – TDD BF eCPRI 7-2e Part 1

(*) For eCPRI 7-2e, nrCellType defines the maximum number of Layers.

| System Use Case | nrCellType (*) | RRM Feature | 1st BB Cell Set (on Loki) | 1st BB Cell Set (on Thor) |  | DL Subcell Composition in L1 (BB) and L1 (Radio) | UL Subcell Compo- sition in L1 (BB) | UL Subcell Compo- sition in L1 (Radio) | Cell Type in L2RT |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| cmW BF (eCPRI 7-2 eUL) | 4DL 2UL (4RX) | CB007595 | (not planned) | (not commercial) |  | C4 | C4'2 | C4'2 | GC4 |
| cmW BF (eCPRI 7-2e) Both UL and DL in 7-2e mode. | 4DL 2UL (4RX) | CB009170 | (not planned) | (not commercial) |  | C4 | C4'2 | C4'2 | GC4 |
|  | 8DL 2UL (4RX) | ~25R1 CB009514 | (not planned) | (not commercial) |  | C4 C4 | C4'2 | C4'2 | GC8 |
|  | 16DL 2UL (4RX) | ~25R1 CB009514 | (not planned) | (not commercial) |  | C4 C4 C4 C4 | C4'2 | C4'2 | GC16 |
|  | 4DL 2UL (4RX PUCCH) | ~25R2 CB010708 | (not planned) | (not commercial) |  | C4 | C4'2 | C16'2 | GC4 |
|  | 4DL 4UL | ~25R2 CB010708 | (not planned) | (not commercial) |  | C4 | C8'4 | C16'4 | GC4 |
### Cell Type Catalog – TDD BF eCPRI 7-2e Part 2

(*) For eCPRI 7-2e, nrCellType defines the maximum number of Layers.

| System Use Case | nrCellType (*) | RRM Feature | 1st BB Cell Set (on Loki) | 1st BB Cell Set (on Thor) |  | DL Subcell Composition in L1 (BB) and L1 (Radio) | UL Subcell Compo- sition in L1 (BB) | UL Subcell Compo- sition in L1 (Radio) | Cell Type in L2RT |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| cmW BF (eCPRI 7-2e) Both UL and DL in 7-2e mode. | 4DL 2UL | ~25R2 CB010708 | (not planned) | 25R3 CB009843 |  | C4 | C8'2 | C16'2 | GC4 |
|  | 8DL 2UL | ~25R2 CB010708 | (not planned) | 25R3 CB009843 |  | C4 C4 | C8'2 | C16'2 | GC8 |
|  | 8DL 4UL | ~25R2 CB010708 | (not planned) | 25R3 CB009843 |  | C4 C4 | C8'4 | C16'4 | GC8 |
|  | 8DL 8UL | 26R1 CB008235 | (not planned) | 26R1 CB009843 |  | C4 C4 | C8'8 | C16'8 | GC8 |
|  | 16DL 2UL | ~25R2 CB009514 | (not planned) | 25R3 CB009843 |  | C4 C4 C4 C4 | C8'2 | C16'2 | GC16 |
|  | 16DL 4UL | ~25R2 CB010708 | (not planned) | 25R3 CB009843 |  | C4 C4 C4 C4 | C8'4 | C16'4 | GC16 |
|  | 16DL 8UL | 26R1 CB008235 | (not planned) | 26R1 CB009843 |  | C4 C4 C4 C4 | C8'8 | C16'8 | GC16 |
|  | 16DL 8UL w/ 2x16RX IRC | 27R2 CB016111 | (not planned) | (applied as RRM change to legacy BB cell sets, e.g. CB009843) |  | C4 C4 C4 C4 | C8'8 | C16’4 C16’4 | GC16 |
### Cell Type Catalog – TDD ORAN ULPI Cat-B

(*) nrCellType defines here the maximum number of Layers.

| System Use Case | nrCellType (*) | RRM Feature | 1st BB Cell Set (on Loki) | 1st BB Cell Set (on Thor) |  | DL Subcell Composition in L1 (BB) and L1 (Radio) | UL Subcell Compo- sition in L1 (BB) | UL Subcell Compo- sition in L1 (Radio) | Cell Type in L2RT |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| cmW BF (O-RAN ULPI Cat-B) | 8DL 2UL |  | (not planned) |  |  | C4 C4 | C8'2 | C16'2 | GC8 |
|  | 8DL 4UL |  | (not planned) |  |  | C4 C4 | C8'4 | C16'4 | GC8 |
|  | 8DL 8UL |  | (not planned) |  |  | C4 C4 | C8'8 | C16'8 | GC8 |
|  | 16DL 2UL |  | (not planned) |  |  | C4 C4 C4 C4 | C8'2 | C16'2 | GC16 |
|  | 16DL 4UL | 27R3 CB010276 (IOT)/ CB013969 (RRM) | (not planned) | 27R3 CB010276 (IOT) Open (commercial) |  | C4 C4 C4 C4 | C8'4 | C16'4 | GC16 |
|  | 16DL 8UL |  | (not planned) |  |  | C4 C4 C4 C4 | C8'8 | C16'8 | GC16 |
### Cell Type Catalog - Obsolete/Rare

(*) For CPRI, OBSAI or eCPRI 7-2a, nrCellType defines the number of Spatial Streams.
(**) Limited to 2 super cell subcells with 2 streams on each. nrCellType is set to 4DL 4UL.

| System Use Case                | nrCellType (*)                | ABIL            | Loki            | Thor            |     | Subcell Composition / DL | Subcell Composition / UL | Comment                                                                |
| ------------------------------ | ----------------------------- | --------------- | --------------- | --------------- | --- | ------------------------ | ------------------------ | ---------------------------------------------------------------------- |
| cmWave CPRI BF                 | 4DL 2UL (2DL 2UL Layers)      | (to be removed) | (not supported) | (not supported) |     | C2 C2                    | C2                       | 2 x C2 for DL 2x2 MIMO mode is deprecated and will be removed in 22R4. |
|                                | 4DL 2UL (4DL 2UL Layers)      | supported       | (not supported) | (not supported) |     | C4                       | C2                       | CPRI BF is deprecated.                                                 |
| cmWave CPRI or eCPRI BF        | 8DL 2UL (4DL 2UL Layers)      | supported       | (not supported) | (not supported) |     | C4                       | C2 C2                    | 2 x C2 for UL is deprecated.                                           |
|                                | 8DL 4UL (4DL 2UL Layers)      | supported       | (not supported) | (not supported) |     | C4 C4                    | C2 C2                    | 2 x C2 for UL is deprecated.                                           |
| cmWave eCPRI BF                | 4DL 2UL (4DL 2UL Layers)      | supported       | (unofficial)    | (unofficial)    |     | C4                       | C2                       | 2RX in BF mode is deprecated. Not prevented by PDL rules. May work.    |
| cmWave CPRI Subsector- ization | 2DL 2UL (2DL 2UL Layers)      | supported       | (not supported) | (not supported) |     | C2                       | C2                       | CPRI Subsectorization is deprecated.                                   |
|                                | 4DL 2UL (4DL 2UL Layers)      | supported       | (not supported) | (not supported) |     | C4                       | C2                       | CPRI Subsectorization is deprecated.                                   |
| cmWave CPRI Non-BF             | 4DL 2UL (4DL 2UL Layers)      | supported       | (not supported) | (not supported) |     | C4                       | C2                       | Workaround for lack of 4RX.                                            |
| FDD CPRI Non-BF                | 4DL 2UL (4DL 2UL Layers)      | supported       | (not supported) | (not supported) |     | A4                       | A2                       | Workaround for lack of 4RX.                                            |
| FDD Super Cell (ABIL)          | 4DL 4UL (**) (4DL 2UL Layers) | 23R3 CB009107   | (not supported) | (not supported) |     | A4                       | A4                       | L2 GA4.                                                                |

### Subcell Type Catalog - Part 1

| Use Case                     | Subcell Type                 | RRM Feature              | 1st BB Cell Set (on Loki) | 1st BB Cell Set (on Thor) |     | Physical Channels and Signals           | Spatial Streams                                | MIMO Layers | eAxCs (in eCPRI mode)                        |
| ---------------------------- | ---------------------------- | ------------------------ | ------------------------- | ------------------------- | --- | --------------------------------------- | ---------------------------------------------- | ----------- | -------------------------------------------- |
| FDD CPRI or 23R1 eCPRI O-RAN | DL Primary A1                | 23R1 CB008983            | 23R1 (modify legacy CS)   | 24R1 CB009014             |     | PDCCH, PDSCH, PSS, SSS, PBCH, CSI-RS    | 1                                              | 1           | 1 regular                                    |
|                              | DL Primary A2                | (old feature from Loner) | 5G21A CB006814            | 24R1 CB009014             |     | PDCCH, PDSCH, PSS, SSS, PBCH, CSI-RS    | 2                                              | 2           | 2 regular                                    |
|                              | DL Primary A4                | (old feature from Loner) | 5G21A CB006814            | 24R1 CB009014             |     | PDCCH, PDSCH, PSS, SSS, PBCH, CSI-RS    | 4                                              | 4           | 4 regular                                    |
| FDD CPRI Super Cell          | DL Fronthaul Duplication A1F | 26R2 CB009543            | 26R2 CB011061             | 26R3 CB011064             |     | (no L1 processing other than fronthaul) | 1                                              | N/A         | N/A                                          |
|                              | DL Fronthaul Duplication A2F | 26R2 CB009543            | 26R2 CB011061             | 26R3 CB011064             |     | (no L1 processing other than fronthaul) | 2                                              | N/A         | N/A                                          |
|                              | DL Fronthaul Duplication A4F | 26R2 CB009543            | 26R2 CB011061             | 26R3 CB011064             |     | (no L1 processing other than fronthaul) | 4                                              | N/A         | N/A                                          |
| FDD CPRI or 23R1 eCPRI O-RAN | UL Primary A2                | (old feature from Loner) | 5G21A CB006814            | 24R1 CB009014             |     | PUCCH, PUSCH, PRACH, MIMO SRS           | 2 (+ 2 for PUSCH with UL CoMP (27R1 CB008465)) | 2           | 2 regular + 2 PRACH                          |
|                              | UL Primary A4                | (old feature from Loner) | 5G21A CB006814            | 24R1 CB009014             |     | PUCCH, PUSCH, PRACH, MIMO SRS           | 4 (+ 4 for PUSCH with UL CoMP (27R1 CB008465)) | 2           | 4 regular + 4 PRACH                          |
| FDD eCPRI                    | UL Primary A8                | 26R2 CB013442 / CB08577  | (not supported)           | 26R2 CB015905             |     | PUCCH, PUSCH, PRACH, MIMO SRS           | 8                                              | 2           | 8 regular + 4 PRACH 8 PRACH CB008577 onwards |

### Subcell Type Catalog - Part 2

| Use Case | Subcell Type | RRM Feature | 1st BB Cell Set (on Loki) | 1st BB Cell Set (on Thor) |  | Physical Channels and Signals | Spatial Streams | MIMO Layers | eAxCs (in eCPRI mode) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| mmW eCPRI | DL Primary D2 D2 | (old feature from Loner) | 22R1 CB007596 | 24R2 CB010496 |  | PDCCH, PDSCH, PSS, SSS, PBCH, CSI-RS | 2 | 2 | 2 regular + 2 SSB |
| mmW eCPRI | UL Primary D2 D2 | (old feature from Loner) | 22R1 CB007596 | 24R2 CB010496 |  | PUCCH, PUSCH, PRACH, MIMO SRS | 2 | 2 | 2 regular + 2 PRACH |

### Subcell Type Catalog - Part 3

| Use Case  | Subcell Type    | RRM Feature              | 1st BB Cell Set (on Loki) | 1st BB Cell Set (on Thor) |     | Physical Channels and Signals        | Spatial Streams | MIMO Layers | eAxCs (in eCPRI mode) |
| --------- | --------------- | ------------------------ | ------------------------- | ------------------------- | --- | ------------------------------------ | --------------- | ----------- | --------------------- |
| cmW eCPRI | DL Primary C2   | (old feature from Loner) | 5G21A 5GC002340           | 24R1 CB009142             |     | PDCCH, PDSCH, PSS, SSS, PBCH, CSI-RS | 2               | 2           | 2 regular             |
|           | DL Primary C4   | (old feature from Loner) | 5G21A 5GC002340           | 24R1 CB009142             |     | PDCCH, PDSCH, PSS, SSS, PBCH, CSI-RS | 4               | 4           | 4 regular             |
|           | DL Primary C8   | CB010250                 | (not planned)             | (future)                  |     | PDCCH, PDSCH, PSS, SSS, PBCH, CSI-RS | 8               | 4           | 8 regular             |
|           | DL Secondary C4 | (old feature from Loner) | 5G21A 5GC002339           | 24R1 CB009142             |     | PDCCH, PDSCH                         | 4               | 4           | 4 regular             |
| cmW CPRI  | DL Primary C2   | (old feature from Loner) | 5G21A 5GC002340           | 24R2 CB010706             |     | PDCCH, PDSCH, PSS, SSS, PBCH, CSI-RS | 2               | 2           | N/A                   |
|           | DL Primary C4   | (old feature from Loner) | 5G21A 5GC002340           | 24R2 CB010706             |     | PDCCH, PDSCH, PSS, SSS, PBCH, CSI-RS | 4               | 4           | N/A                   |

### Subcell Type Catalog - Part 4

NDM SRS (feature 5GC001086) is only for Beamforming RUs and it is optional. When enabled, the 
number of NDM eAxCs is either 32 or 64 per (sub)cell and it matches the number of TRXs in the RU.

| Use Case            | Subcell Type                 | RRM Feature              | 1st BB Cell Set (on Loki) | 1st BB Cell Set (on Thor) |     | Physical Channels and Signals  | Spatial Streams | MIMO Layers | eAxCs (in eCPRI mode)                      |
| ------------------- | ---------------------------- | ------------------------ | ------------------------- | ------------------------- | --- | ------------------------------ | --------------- | ----------- | ------------------------------------------ |
| cmW eCPRI           | UL Primary C2                | (old feature from Loner) | 5G21A 5GC002340           | 24R1 CB009142             |     | PUCCH, PUSCH, PRACH, MIMO SRS  | 2               | 2           | 2 regular + 2 PRACH                        |
|                     | UL Primary C4                | (old feature from Loner) | 5G21A 5GC002340           | 24R1 CB009142             |     | PUxCH, PRACH, MIMO SRS, BF SRS | 4               | 2           | 4 regular + 4 PRACH + up to 64 NDM for SRS |
|                     | UL Primary C8                | 24R1 CB009363            | (not planned)             | 24R1 CB009363             |     | PUxCH, PRACH, MIMO SRS, BF SRS | 8               | 4           | 8 regular + 4 PRACH + up to 64 NDM for SRS |
|                     | UL Secondary C4              | 23R1 CB008360            | 23R1 CB009403             | 24R1 CB009142             |     | PUSCH                          | 4               | 2           | 4 regular                                  |
| cmW CPRI            | UL Primary C2                | (old feature from Loner) | 5G21A 5GC002340           | (not planned)             |     | PUCCH, PUSCH, PRACH, MIMO SRS  | 2               | 2           | N/A                                        |
|                     | UL Primary C4                | (old feature from Loner) | 5G21A 5GC002340           | (not planned)             |     | PUCCH, PUSCH, PRACH, MIMO SRS  | 4               | 2           | N/A                                        |
| cmW eCPRI NRPOSCELL | UL Positioning  SRS C4 (C4S) | 25R2 SiSo CB010680       | (not planned)             | 25R2 CB010680             |     | SRS                            | 4               | 0           | 4 NDM for SRS                              |
|                     | UL Positioning  SRS C8 (C8S) | 26R2 SiSo CB013273       | (not planned)             | 26R2 CB013273             |     | SRS                            | 8               | 0           | 8 NDM for SRS                              |

### Subcell Type Catalog - Part 5

| Use Case                         | Subcell Type      | RRM Feature    | 1st BB Cell Set (on Loki) | 1st BB Cell Set (on Thor) |     | Physical Channels and Signals            | PUCCH, PRACH            | PUSCH               | SRS                        |
| -------------------------------- | ----------------- | -------------- | ------------------------- | ------------------------- | --- | ---------------------------------------- | ----------------------- | ------------------- | -------------------------- |
| cmW eCPRI 7-2 eUL for L1 (BB)    | UL Primary C4'2   | 24R3 CB007595  | (not planned)             | (not commercial)          |     | all (according to 7-2e functional split) | 4 Streams, 4 Streams    | 2 Layers            | (depends on Radio subcell) |
|                                  | UL Primary C8'2   | ~25R2 CB010708 | (not planned)             | CB009843                  |     | all (according to 7-2e functional split) | 8 Streams, 4 Streams    | 2 Layers            | (depends on Radio subcell) |
|                                  | UL Primary C8'4   | ~25R2 CB010708 | (not planned)             | CB009843                  |     | all (according to 7-2e functional split) | 8 Streams, 4 Streams    | 4 Layers            | (depends on Radio subcell) |
|                                  | UL Primary C8'8   | 26R1 CB008235  | (not planned)             | CB009843                  |     | all (according to 7-2e functional split) | 8 Streams, 4 Streams    | 8 Layers            | (depends on Radio subcell) |
| cmW eCPRI 7-2 eUL for L1 (Radio) | UL Primary C4'2   | 24R3 CB007595  | (not planned)             | (not commercial)          |     | all (according to 7-2e functional split) | 4 Streams               | 4 Streams 2 Layers  | 32/64 TRX                  |
|                                  | UL Primary C16'2  | ~25R2 CB010708 | (not planned)             | CB009843                  |     | all (according to 7-2e functional split) | (depends on BB subcell) | 16 Streams 2 Layers | 32/64 TRX                  |
|                                  | UL Primary C16'4  | ~25R2 CB010708 | (not planned)             | CB009843                  |     | all (according to 7-2e functional split) | (depends on BB subcell) | 16 Streams 4 Layers | 32/64 TRX                  |
|                                  | UL Primary C16'8  | 26R1 CB008235  | (not planned)             | CB009843                  |     | all (according to 7-2e functional split) | (depends on BB subcell) | 16 Streams 8 Layers | 32/64 TRX                  |

### Subcell Type Catalog - Part 6

| Use Case                            | Subcell Type      | RRM Feature                         | 1st BB Cell Set (on Loki) | 1st BB Cell Set (on Thor)             |     | Physical Channels and Signals           | PUCCH, PRACH            | PUSCH               | SRS                        |
| ----------------------------------- | ----------------- | ----------------------------------- | ------------------------- | ------------------------------------- | --- | --------------------------------------- | ----------------------- | ------------------- | -------------------------- |
| cmW O-RAN ULPI Cat-B for L1 (BB)    | UL Primary C4'2   |                                     |                           |                                       |     | all (O-RAN ULPI Cat-B functional split) | 4 Streams, 4 Streams    | 2 Layers            |                            |
|                                     | UL Primary C8'2   |                                     |                           |                                       |     | all (O-RAN ULPI Cat-B functional split) | 8 Streams, 4 Streams    | 2 Layers            |                            |
|                                     | UL Primary C8'4   | 27R3 CB010276 (IOT)/ CB013969 (RRM) | (not planned)             | 27R3 CB010276 (IOT) Open (commercial) |     | all (O-RAN ULPI Cat-B functional split) | 8 Streams, 8 Streams    | 4 Layers            | (depends on Radio subcell) |
|                                     | UL Primary C8'8   |                                     |                           |                                       |     | all (O-RAN ULPI Cat-B functional split) | 8 Streams, 4 Streams    | 8 Layers            |                            |
| cmW O-RAN ULPI Cat-B for L1 (Radio) | UL Primary C16'2  |                                     |                           |                                       |     | all (O-RAN ULPI Cat-B functional split) | (depends on BB subcell) | 16 Streams 2 Layers |                            |
|                                     | UL Primary C16'4  | 27R3 CB010276 (IOT)/ CB013969 (RRM) | (not planned)             | 27R3 CB010276 (IOT) Open (commercial) |     | all (O-RAN ULPI Cat-B functional split) | (depends on BB subcell) | 16 Streams 4 Layers | 64 TRX                     |
|                                     | UL Primary C16'8  |                                     |                           |                                       |     | all (O-RAN ULPI Cat-B functional split) | (depends on BB subcell) | 16 Streams 8 Layers |                            |

### Subcell Type Catalog - Part 7

| Use Case                                              | Subcell Type    | RRM Feature   | 1st BB Cell Set (on Loki) | 1st BB Cell Set (on Thor) |     | Physical Channels and Signals           | Spatial Streams          | MIMO Layers | eAxCs (in eCPRI 7-2a mode). SRS in 7-2e.   |
| ----------------------------------------------------- | --------------- | ------------- | ------------------------- | ------------------------- | --- | --------------------------------------- | ------------------------ | ----------- | ------------------------------------------ |
| FDD CPRI or eCPRI Cell Fronthaul Data Forwarding      | DL FDD A4FDF    | 27R3 CB014369 | -                         | 27R3 CB014369             |     | (no L1 processing other than fronthaul) | 4                        | 2           | 4 regular                                  |
|                                                       | UL FDD A4FDF    | 27R3 CB014369 | -                         | 27R3 CB014369             |     | (no L1 processing other than fronthaul) | 4                        | 2           | 4 regular + 4 PRACH                        |
| FDD eCPRI Cell Fronthaul Data Forwarding              | UL FDD A8FDF    | 27R3 CB014369 | -                         | 27R3 CB014369             |     | (no L1 processing other than fronthaul) | 4                        | 2           | 8 regular + 8 PRACH                        |
| cmW CPRI or eCPRI 7-2a Cell Fronthaul Data Forwarding | DL TDD  C4FDF   | 27R3 CB014369 | -                         | 27R3 CB014369             |     | (no L1 processing other than fronthaul) | 4                        | 4           | 4 regular                                  |
|                                                       | UL TDD C4FDF    | 27R3 CB014369 | -                         | 27R3 CB014369             |     | (no L1 processing other than fronthaul) | 4                        | 2           | 4 regular + 4 PRACH + up to 64 NDM for SRS |
| cmW eCPRI 7- 2a Cell Fronthaul Data Forwarding        | UL TDD C8FDF    | 27R3 CB014369 | -                         | 27R3 CB014369             |     | (no L1 processing other than fronthaul) | 4                        | 4           | 8 regular + 4 PRACH + up to 64 NDM for SRS |
| cmW eCPRI 7- 2e Cell Fronthaul Data Forwarding        | UL TDD C8’4FDF  | 27R3 CB014369 | -                         | 27R3 CB014369             |     | (no L1 processing other than fronthaul) | 8 for PUCCH, 4 for PRACH | 4           | 32/64 TRX                                  |
|                                                       | UL TDD C8’8FDF  | 27R3 CB014369 | -                         | 27R3 CB014369             |     | (no L1 processing other than fronthaul) | 8 for PUCCH, 4 for PRACH | 8           | 32/64 TRX                                  |

---
## UP SW Deployments

Allocation of cores to different UP L2 functions.
L1 SW deployments on high level when on same device with L2.
Covered: Snowfish, Marlin, vDU RAN NIC (RINLINE2), Nemo, vDU AI-RAN (GPU101).
Not covered: Xeon (see UP DOORS instead), Loki, Loner, Thor, Odin (see L1 documentation 
instead).

### L2 Deployments (1)

| HI  | HI  | 5G-L2-HI instance   | PS  | 5G-L2-PS outside L2 subpools |     |
| --- | --- | ------------------- | --- | ---------------------------- | --- |
| LO  | LO  | 5G-L2-LO instance   | TM  | 5G-L2-TM                     |     |
| PS  | PS  | 5G-L2-PS L2 subpool | L   | LTE                          |     |
(*) includes administrative parts of L2NRT and L2RT.

| ABIO         | cluster 0     | cluster 1 |     |     |     | cluster 2 |     |     |     | cluster 3 |     |     |     | cluster 4 |     |     |     | cluster 5 |     |     |     | L2 Pools |
| ------------ | ------------- | --------- | --- | --- | --- | --------- | --- | --- | --- | --------- | --- | --- | --- | --------- | --- | --- | --- | --------- | --- | --- | --- | -------- |
| Half Board 1 | Linux SMP (*) | LO        | LO  | -   | -   | HI        | HI  | HI  | HI  | PS        | PS  | PS  | PS  | -         | -   | -   | -   | -         | -   | -   | -   |          |
|              |               | LO        | LO  | -   | -   | HI        | HI  | HI  | HI  | PS        | PS  | PS  | PS  | -         | -   | -   | -   | -         | -   | -   | -   |          |
|              |               | LO        | LO  | -   | -   | HI        | HI  | HI  | HI  | PS        | PS  | PS  | PS  | -         | -   | -   | -   | -         | -   | -   | -   |          |
|              |               | HI        | HI  | -   | -   | LO        | LO  | PS  | PS  | PS        | PS  | PS  | PS  | -         | -   | -   | -   | -         | -   | -   | -   |          |
|              |               | HI        | HI  | -   | -   | LO        | LO  | PS  | PS  | PS        | PS  | PS  | PS  | -         | -   | -   | -   | -         | -   | -   | -   |          |
|              |               | HI        | HI  | -   | -   | LO        | LO  | PS  | PS  | L         | L   | L   | L   | -         | -   | -   | -   | -         | -   | -   | -   |          |
|              |               | -         | -   | -   | -   | -         | -   | -   | -   | TM        | TM  | TM  | TM  | -         | -   | -   | -   | -         | -   | -   | -   |          |
| Half Board 2 |               | -         | -   | LO  | LO  | -         | -   | -   | -   | -         | -   | -   | -   | HI        | HI  | HI  | HI  | PS        | PS  | PS  | PS  |          |
|              |               | -         | -   | LO  | LO  | -         | -   | -   | -   | -         | -   | -   | -   | HI        | HI  | HI  | HI  | PS        | PS  | PS  | PS  |          |
|              |               | -         | -   | LO  | LO  | -         | -   | -   | -   | -         | -   | -   | -   | HI        | HI  | HI  | HI  | PS        | PS  | PS  | PS  |          |
|              |               | -         | -   | HI  | HI  | -         | -   | -   | -   | -         | -   | -   | -   | LO        | LO  | PS  | PS  | PS        | PS  | PS  | PS  |          |
|              |               | -         | -   | HI  | HI  | -         | -   | -   | -   | -         | -   | -   | -   | LO        | LO  | PS  | PS  | PS        | PS  | PS  | PS  |          |
|              |               | -         | -   | HI  | HI  | -         | -   | -   | -   | -         | -   | -   | -   | LO        | LO  | PS  | PS  | L         | L   | L   | L   |          |
|              |               | -         | -   | LO  | LO  | -         | -   | -   | -   | -         | -   | -   | -   | PS        | PS  | PS  | PS  | L         | L   | L   | L   |          |
|              |               | -         | -   | LO  | LO  | -         | -   | -   | -   | -         | -   | -   | -   | PS        | PS  | PS  | PS  | L         | L   | L   | L   |          |
|              |               | -         | -   | L   | L   | -         | -   | -   | -   | -         | -   | -   | -   | LO        | LO  | PS  | PS  | L         | L   | L   | L   |          |
|              |               | -         | -   | L   | L   | -         | -   | -   | -   | -         | -   | -   | -   | LO        | LO  | PS  | PS  | L         | L   | L   | L   |          |
|              |               | -         | -   | -   | -   | -         | -   | -   | -   | -         | -   | -   | -   | -         | -   | -   | -   | TM        | TM  | TM  | TM  |          |
| Full Board   |               | HI        | HI  | HI  | HI  | LO        | LO  | LO  | LO  | -         | -   | -   | -   | PS        | PS  | PS  | PS  | PS        | PS  | PS  | PS  |          |
|              |               | HI        | HI  | HI  | HI  | LO        | LO  | LO  | LO  | PS        | PS  | PS  | PS  | PS        | PS  | PS  | PS  | PS        | PS  | PS  | PS  |          |
|              |               | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  | PS        | PS  | PS  | PS  | L         | L   | L   | L   | L         | L   | L   | L   |          |
|              |               |           |     |     |     |           |     |     |     |           |     |     |     |           |     |     |     |           |     |     |     |          |

### L2 Deployments (2)

| ABIN         | cluster 0     |     | cluster 1 |     |     |     | cluster 2 |     |     |     | cluster 3 |     |     |     | cluster 4 |     |     |     | L2 Pools |
| ------------ | ------------- | --- | --------- | --- | --- | --- | --------- | --- | --- | --- | --------- | --- | --- | --- | --------- | --- | --- | --- | -------- |
| Half Board 1 | Linux SMP (*) |     | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  | -         | -   | -   | -   | -         | -   | -   | -   |          |
|              |               |     | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  | -         | -   | -   | -   | -         | -   | -   | -   |          |
|              |               |     | -         | -   | -   | -   | TM        | TM  | TM  | TM  | -         | -   | -   | -   | -         | -   | -   | -   |          |
| Half Board 2 |               |     | -         | -   | -   | -   | -         | -   | -   | -   | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  |          |
| Full Board   |               |     | LO        | LO  | -   | -   | -         | -   | -   | -   | HI        | HI  | HI  | HI  | PS        | PS  | PS  | PS  |          |
|              |               |     | HI        | HI  | HI  | HI  | LO        | LO  | -   | -   | -         | -   | PS  | PS  | PS        | PS  | PS  | PS  |          |
|              |               |     | HI        | HI  | HI  | HI  | LO        | LO  | -   | -   | -         | -   | PS  | PS  | PS        | PS  | PS  | PS  |          |

### L2 Deployments (3)

| ASOE/ASOF    | cluster 0              | cluster 1 | cluster 2 |     |     |     | cluster 3 |     |     |     | cluster 4 |     |     |     | cluster 5 |     |     |     | L2 Pools |
| ------------ | ---------------------- | --------- | --------- | --- | --- | --- | --------- | --- | --- | --- | --------- | --- | --- | --- | --------- | --- | --- | --- | -------- |
| Half Board 1 | Linux SMP (*) and TRSW |           | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  | -         | -   | -   | -   | -         | -   | -   | -   |          |
|              |                        |           | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  | -         | -   | -   | -   | -         | -   | -   | -   |          |
|              |                        |           | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  | -         | -   | -   | -   | -         | -   | -   | -   |          |
|              |                        |           | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  | -         | -   | -   | -   | -         | -   | -   | -   |          |
|              |                        |           | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  | -         | -   | -   | -   | -         | -   | -   | -   |          |
|              |                        |           | -         | -   | -   | -   | TM        | TM  | TM  | TM  | -         | -   | -   | -   | -         | -   | -   | -   |          |
| Half Board 2 |                        |           | -         | -   | -   | -   | -         | -   | -   | -   | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  |          |
|              |                        |           | -         | -   | -   | -   | -         | -   | -   | -   | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  |          |
|              |                        |           | -         | -   | -   | -   | -         | -   | -   | -   | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  |          |
|              |                        |           | -         | -   | -   | -   | -         | -   | -   | -   | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  |          |
|              |                        |           | -         | -   | -   | -   | -         | -   | -   | -   | HI        | HI  | LO  | LO  | PS        | PS  | PS  | PS  |          |
|              |                        |           | -         | -   | -   | -   | -         | -   | -   | -   | LO        | LO  | PS  | PS  | L         | L   | L   | L   |          |
|              |                        |           | -         | -   | -   | -   | -         | -   | -   | -   | LO        | LO  | PS  | PS  | L         | L   | L   | L   |          |
|              |                        |           | -         | -   | -   | -   | -         | -   | -   | -   | -         | -   | -   | -   | TM        | TM  | TM  | TM  |          |
| Full Board   |                        |           | HI        | HI  | HI  | HI  | LO        | LO  | LO  | LO  | PS        | PS  | PS  | PS  | PS        | PS  | PS  | PS  |          |

| ASOE/ASOF                                 | cluster 0                                                               | cluster 1 |     | cluster 2 |     |     |     | cluster 3 |     |     |     | cluster 4 |     |     |     | cluster 5 |     |     |     | L2 Pools |
| ----------------------------------------- | ----------------------------------------------------------------------- | --------- | --- | --------- | --- | --- | --- | --------- | --- | --- | --- | --------- | --- | --- | --- | --------- | --- | --- | --- | -------- |
| Special RJio Deployments to be obsoleted. | Linux SMP (*) and TRSW                                                  |           | LO  | HI        | HI  | HI  | LO  | LO        | LO  | LO  | LO  | PS        | PS  | PS  | PS  | PS        | PS  | PS  | PS  |          |
|                                           | Linux SMP (*) and TRSW (5 cores Linux SMP incl. C-Plane + 3 cores TRSW) |           |     | HI        | HI  | HI  | LO  | LO        | LO  | LO  | LO  | PS        | PS  | PS  | PS  | PS        | PS  | PS  | PS  |          |
|                                           |                                                                         |           |     | HI        | HI  | HI  | LO  | LO        | LO  | LO  | LO  | PS        | PS  | PS  | PS  | PS        | PS  | PS  | PS  |          |

### L2 Deployments (4.1)

| ASOE/ASOF                           | cluster 0                                                                   | cluster 1 |     |     | cluster 2 |     |     |     | cluster 3 |     |     |     | cluster 4 |     |     |     | cluster 5 |     |     |     | L2 Pools |
| ----------------------------------- | --------------------------------------------------------------------------- | --------- | --- | --- | --------- | --- | --- | --- | --------- | --- | --- | --- | --------- | --- | --- | --- | --------- | --- | --- | --- | -------- |
| Special Full-Board RJio Deployments | Linux SMP (*) and TRSW (4-5 cores Linux SMP incl. C-Plane + 2-3 cores TRSW) |           | L   | L   | HI        | HI  | HI  | LO  | LO        | LO  | PS  | PS  | PS        | PS  | PS  | PS  | LO        | PS  | PS  | PS  |          |
|                                     |                                                                             |           |     |     |           |     |     |     |           |     |     |     |           |     |     |     |           |     |     |     |          |
|                                     |                                                                             |           | L   | L   | HI        | HI  | HI  | LO  | LO        | LO  | PS  | PS  | PS        | PS  | PS  | PS  | PS        | PS  | PS  | PS  |          |
|                                     |                                                                             |           | L   | L   | HI        | HI  | HI  | LO  | PS        | LO  | LO  | LO  | PS        | PS  | PS  | PS  | PS        | PS  | PS  | PS  |          |
|                                     |                                                                             |           |     |     |           |     |     |     |           |     |     |     |           |     |     |     |           |     |     |     |          |
|                                     |                                                                             |           | L   | L   | HI        | HI  | HI  | LO  | PS        | PS  | PS  | PS  | PS        | PS  | LO  | LO  | LO        | PS  | PS  | PS  |          |
|                                     |                                                                             |           | LO  | LO  | HI        | HI  | HI  | PS  | PS        | PS  | PS  | PS  | PS        | PS  | PS  | PS  | LO        | PS  | PS  | PS  |          |
|                                     |                                                                             |           | PS  | PS  | HI        | HI  | HI  | LO  | LO        | LO  | PS  | PS  | PS        | PS  | PS  | PS  | LO        | PS  | PS  | PS  |          |
|                                     |                                                                             |           | L   | L   | HI        | HI  | HI  | LO  | PS        | PS  | PS  | PS  | PS        | PS  | LO  | LO  | PS        | PS  | PS  | PS  |          |
|                                     |                                                                             |           | HI  | HI  | LO        | LO  | PS  | PS  | PS        | PS  | PS  | PS  | PS        | PS  | L   | L   | L         | L   | L   | L   |          |
|                                     |                                                                             |           | L   | HI  | LO        | LO  | PS  | PS  | PS        | PS  | PS  | PS  | PS        | PS  | HI  | L   | L         | L   | L   | L   |          |
|                                     |                                                                             |           | HI  | HI  | LO        | LO  | PS  | PS  | PS        | PS  | PS  | PS  | L         | L   | L   | L   | L         | L   | L   | L   |          |
|                                     |                                                                             |           | LO  | LO  | HI        | HI  | HI  | LO  | PS        | PS  | PS  | PS  | PS        | PS  | PS  | PS  | LO        | PS  | PS  | PS  |          |

### L2 Deployments (4.2)

L2 Pools in the L2RT Instances of previous slide and the definition of the color coding.

| LO  | LO  |     | +   | PS  | PS  | PS  |     |     |     |     |     |     | NR FDD 3SP                                                                                                                   |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | ---------------------------------------------------------------------------------------------------------------------------- |
| LO  |     |     | +   | PS  | PS  | PS  |     |     |     |     |     |     | NR FDD 3SP (with 1-core L2-LO)                                                                                               |
| LO  |     |     | +   | PS  | PS  |     |     |     |     |     |     |     | NR FDD 2C 1SP (with 1-core L2-LO)                                                                                            |
| LO  |     |     | +   | PS  | PS  | PS  | PS  |     |     |     |     |     | NR FDD 2C 2SP (with 1-core L2-LO)                                                                                            |
| LO  | LO  |     | +   | PS  | PS  | PS  | PS  |     |     |     |     |     | NR TDD FR1 2SP (mapped to 1 Loki)                                                                                            |
| LO  | LO  |     | +   | PS  | PS  | PS  | PS  | PS  | PS  |     |     |     | NR TDD FR1 3SP (mapped to 1 Loki)                                                                                            |
| LO  | LO  |     | +   | PS  | PS  | PS  | PS  | PS  | PS  | PS  | PS  |     | NR TDD FR1 4SP (mapped to 1 Loki)                                                                                            |
| LO  | LO  | LO  | +   | PS  | PS  | PS  | PS  | PS  | PS  |     |     |     | 2 L2 Pools: NR TDD FR1 2SP + NR TDD FR1 1SP (8DL) or 1 L2 Pool: NR TDD FR1 3SP (16DL) (mapped to 1.5 Lokis)                  |
| LO  | LO  | LO  | +   | PS  | PS  | PS  | PS  | PS  | PS  | PS  | PS  |     | 2 L2 Pools: NR TDD FR1 3SP + NR TDD FR1 1SP (8DL) (mapped to 1.5 Lokis)                                                      |
| LO  | LO  |     | +   | PS  | PS  | PS  | PS  | PS  | PS  |     |     |     | 2 L2 Pools: NR TDD FR1 2SP + NR TDD FR1 1SP (8DL) or 1 L2 Pool: NR TDD FR1 3SP (16DL) (mapped to 1.5 Lokis and 2-core L2-LO) |
| LO  | LO  |     | +   | PS  | PS  | PS  | PS  | PS  | PS  | PS  | PS  | PS  | 2 L2 Pools: NR TDD FR1 3SP (8DL 100M) + NR TDD FR1 1C 3SP (8DL 50M) (mapped to 1.5 Lokis and 2-core L2-LO).                  |


| ABIP         |     | 4 cores                                   |     |     | 4 cores |     |     |     | 4 cores |     |     |     | 4 cores |     |     |     | 4 cores |     |     |     | 4 cores |     |     |     | L2 Pools |     |     |     |     |
| ------------ | --- | ----------------------------------------- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- | -------- | --- | --- | --- | --- |
| Half Board 1 | L   | inux SMP (*)                              |     |     | LO      | LO  | -   | -   | HI      | HI  | HI  | HI  | PS      | PS  | PS  | PS  | -       | -   | -   | -   | -       | -   | -   | -   |          |     |     |     |     |
|              |     |                                           |     |     | HI      | HI  | -   | -   | LO      | LO  | PS  | PS  | PS      | PS  | PS  | PS  | -       | -   | -   | -   | -       | -   | -   | -   |          |     |     |     |     |
|              |     |                                           |     |     | HI      | HI  | -   | -   | LO      | LO  | PS  | PS  | PS      | PS  | PS  | PS  | -       | -   | -   | -   | -       | -   | -   | -   |          |     |     |     |     |
|              |     |                                           |     |     | HI      | HI  | -   | -   | LO      | LO  | PS  | PS  | PS      | PS  | PS  | PS  | -       | -   | -   | -   | -       | -   | -   | -   |          |     |     |     |     |
|              |     |                                           |     |     | HI      | HI  | -   | -   | LO      | PS  | PS  | PS  | L       | L   | L   | L   | -       | -   | -   | -   | -       | -   | -   | -   |          |     |     |     |     |
|              |     |                                           |     |     | -       | -   | -   | -   | -       | -   | -   | -   | TM      | TM  | TM  | TM  | -       | -   | -   | -   | -       | -   | -   | -   |          |     |     |     |     |
|              | L   | -                                         | LO  | LO  | HI      | HI  | -   | -   | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | -       | -   | -   | -   | -       | -   | -   | -   |          |     |     |     |     |
|              | L   | LO                                        | PS  | PS  | HI      | HI  | -   | -   | PS      | PS  | PS  | PS  | L       | L   | L   | L   | -       | -   | -   | -   | -       | -   | -   | -   |          |     |     |     |     |
| Half Board 2 | Li  | nux SMP (*)                               |     |     | -       | -   | LO  | LO  | -       | -   | -   | -   | -       | -   | -   | -   | HI      | HI  | HI  | HI  | PS      | PS  | PS  | PS  |          |     |     |     |     |
|              |     |                                           |     |     | -       | -   | HI  | HI  | -       | -   | -   | -   | -       | -   | -   | -   | LO      | LO  | PS  | PS  | PS      | PS  | PS  | PS  |          |     |     |     |     |
|              |     |                                           |     |     | -       | -   | HI  | HI  | -       | -   | -   | -   | -       | -   | -   | -   | LO      | LO  | PS  | PS  | PS      | PS  | PS  | PS  |          |     |     |     |     |
|              |     |                                           |     |     | -       | -   | HI  | HI  | -       | -   | -   | -   | -       | -   | -   | -   | LO      | LO  | PS  | PS  | PS      | PS  | PS  | PS  |          |     |     |     |     |
|              |     |                                           |     |     | -       | -   | LO  | LO  | -       | -   | -   | -   | -       | -   | -   | -   | PS      | PS  | PS  | PS  | L       | L   | L   | L   |          |     |     |     |     |
|              |     |                                           |     |     | -       | -   | LO  | LO  | -       | -   | -   | -   | -       | -   | -   | -   | PS      | PS  | PS  | PS  | L       | L   | L   | L   |          |     |     |     |     |
|              |     |                                           |     |     | -       | -   | L   | L   | -       | -   | -   | -   | -       | -   | -   | -   | LO      | LO  | PS  | PS  | L       | L   | L   | L   |          |     |     |     |     |
|              |     |                                           |     |     | -       | -   | L   | L   | -       | -   | -   | -   | -       | -   | -   | -   | LO      | LO  | PS  | PS  | L       | L   | L   | L   |          |     |     |     |     |
|              |     |                                           |     |     | -       | -   | HI  | HI  | -       | -   | -   | -   | -       | -   | -   | -   | LO      | PS  | PS  | PS  | L       | L   | L   | L   |          |     |     |     |     |
|              |     |                                           |     |     | -       | -   | -   | -   | -       | -   | -   | -   | -       | -   | -   | -   | -       | -   | -   | -   | TM      | TM  | TM  | TM  |          |     |     |     |     |
|              | L   | -                                         | LO  | LO  | -       | -   | HI  | HI  | -       | -   | -   | -   | -       | -   | -   | -   | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  |          |     |     |     |     |
|              | L   | LO                                        | PS  | PS  | -       | -   | HI  | HI  | -       | -   | -   | -   | -       | -   | -   | -   | PS      | PS  | PS  | PS  | L       | L   | L   | L   |          |     |     |     |     |
|              | L   | LO                                        | PS  | PS  | -       | -   | HI  | HI  | -       | -   | -   | -   | -       | -   | -   | -   | PS      | PS  | L   | L   | L       | L   | L   | L   |          |     |     |     |     |
|              |     | Extra UP cores in the tuned BB cell sets. |     |     |         |     |     |     |         |     |     |     |         |     |     |     |         |     |     |     |         |     |     |     |          |     |     |     |     |

### L2 Deployments (6a; regular full-board deployments)

| ABIP | 4 cores | 4 cores |  |  |  | 4 cores |  |  |  | 4 cores |  |  |  | 4 cores |  |  |  | 4 cores |  |  |  | L2 Pools (*) includes administrative |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Full Board Deployments for 3-sector TDD configurations | Linux SMP (*) | HI | HI | HI | HI | LO | LO | LO | LO | - | - | - | - | PS | PS | PS | PS | PS | PS | PS | PS |  |
|  |  | HI | HI | HI | HI | LO | LO | LO | LO | PS | PS | PS | PS | PS | PS | PS | PS | PS | PS | PS | PS |  |
|  |  | HI | HI | HI | HI | LO | LO | LO | LO | PS | PS | PS | PS | PS | PS | PS | PS | PS | PS | PS | PS |  |
|  |  | HI | HI | HI | HI | LO | LO | LO | LO | PS | PS | PS | PS | PS | PS | PS | PS | PS | PS | PS | PS |  |
|  |  | HI | HI | HI | HI | LO | LO | LO | LO | PS | PS | PS | PS | PS | PS | PS | PS | LO | PS | PS | PS |  |
|  |  | HI | HI | HI | LO | LO | LO | PS | PS | PS | PS | PS | PS | PS | PS | PS | PS | LO | PS | PS | PS |  |
|  |  | HI | HI | HI | LO | LO | LO | PS | PS | PS | PS | PS | PS | PS | PS | PS | PS | LO | PS | PS | PS |  |
|  |  | HI | HI | HI | LO | LO | LO | PS | PS | PS | PS | PS | PS | PS | PS | PS | PS | LO | PS | PS | PS |  |
|  |  | HI | HI | HI | LO | LO | LO | PS | PS | PS | PS | PS | PS | PS | PS | PS | LO | PS | PS | PS | PS |  |
|  |  | HI | HI | HI | LO | LO | LO | PS | PS | PS | PS | PS | PS | PS | PS | PS | PS | L | L | L | L |  |
|  |  | HI | HI | HI | LO | LO | LO | PS | PS | PS | PS | PS | PS | PS | PS | PS | PS | L | L | L | L |  |
|  |  | HI | HI | HI | LO | LO | LO | PS | PS | PS | PS | PS | PS | PS | PS | PS | PS | L | L | L | L |  |
|  |  | NA | NA | HI | HI | LO | LO | PS | PS | PS | PS | PS | PS | L | L | L | L | L | L | L | L |  |
|  |  | HI | HI | LO | LO | PS | PS | PS | PS | PS | PS | LO | PS | PS | PS | L | L | L | L | L | L |  |
### L2 Deployments (6c; Tuned full-board deployments)

Possible by distributed C-plane move to core-board.

|      |     |         |     |     |         |     |     |     |         |     |     |     |         |     |     |     |         |     |     |     |         |     |     |     |          | (*) includes administrative parts of L2NRT and L2RT. |
| ---- | --- | ------- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- | -------- | ---------------------------------------------------- |
| ABIP |     | 4 cores |     |     | 4 cores |     |     |     | 4 cores |     |     |     | 4 cores |     |     |     | 4 cores |     |     |     | 4 cores |     |     |     | L2 Pools |                                                      |
|      | L   | HI      | HI  | HI  | HI      | LO  | LO  | LO  | LO      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  |          |                                                      |
|      | L   | HI      | HI  | LO  | LO      | PS  | PS  | PS  | PS      | PS  | PS  | LO  | PS      | PS  | PS  | PS  | PS      | PS  | L   | L   | L       | L   | L   | L   |          |                                                      |
|      | L   | HI      | HI  | HI  | HI      | LO  | LO  | LO  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | LO      | PS  | PS  | PS  |          |                                                      |
|      | L   | HI      | HI  | HI  | LO      | LO  | LO  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | LO  | PS      | PS  | PS  | PS  |          |                                                      |
|      | L   | HI      | HI  | HI  | HI      | LO  | LO  | LO  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | LO      | PS  | PS  | PS  |          |                                                      |
|      | L   | HI      | HI  | HI  | HI      | LO  | LO  | LO  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | L       | L   | L   | L   |          |                                                      |
|      | L   | L       | HI  | HI  | LO      | LO  | LO  | LO  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | L       | L   | L   | L   |          |                                                      |
|      | L   | L       | HI  | HI  | HI      | LO  | LO  | LO  | LO      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | L   | L   | L   |          |                                                      |
|      | L   | L       | HI  | HI  | HI      | LO  | LO  | PS  | PS      | PS  | PS  | PS  | PS      | LO  | PS  | PS  | PS      | PS  | L   | L   | L       | L   | L   | L   |          |                                                      |


### L2 Deployments (7)

| ABIP                                                                  | 4 cores       |     |     |     | 4 cores |     |     |     | 4 cores |     |     |     | 4 cores |     |     |     | 4 cores |     |     |     | 4 cores |     |     |     | L2 Pools |     |
| --------------------------------------------------------------------- | ------------- | --- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- | -------- | --- |
| Special full-board (Rjio) deployments For 2-sector TDD configurations | Linux SMP (*) |     |     |     | HI      | HI  | HI  | LO  | LO      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | LO  | PS  | PS  | L       | L   | L   | L   |          |     |
|                                                                       | L             | PS  | PS  | PS  | PS      | HI  | HI  | LO  | LO      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | PS      | LO  | PS  | PS  | L       | L   | L   | L   |          |     |
|                                                                       | L             |     |     |     | HI      | HI  | HI  | HI  | LO      | LO  | LO  | LO  | PS      | PS  | PS  | PS  | PS      | PS  | PS  | PS  | LO      | PS  | PS  | PS  |          |     |
|                                                                       | L             |     |     |     | HI      | HI  | HI  | HI  | LO      | LO  | PS  | PS  | PS      | PS  | LO  | LO  | PS      | PS  | PS  | PS  | L       | L   | L   | L   |          |     |
|                                                                       |               |     |     |     |         |     |     |     |         |     |     |     |         |     |     |     |         |     |     |     |         |     |     |     |          |     |

L1 Aspects of 1st deployment above
- NR TDD
- One ½-Thor L1 pool for 6 TDD DB cells (2x100M + 2x30M + 2x20M).
- NetconfYang / SOAP M-plane mix required.
- PRB capacities and pooling:
- DL: 12864 configured, 8736 processed layer-PRBs. Pooling ratio 1.5.
- UL: 6432 configured, 4368 processed layer-PRBs. Pooling ratio 1.5.
- Pooling ratios are reasonable. Legacy PRB capacities are enough.
- UE/TTI capacities and pooling:
- 48 UE/TTI available and no need for increase.
- Use regular half-ABIP CSM
- NR FDD
- One ¼-Thor L1 pool for 2 FDD mMIMO cells (2x10M 4DL8RX).
- PRB pooling:
- DL: 416 configured, 1768 processed stream-PRBs. No pooling.
- UL: 832 configured, 1432 processed stream-PRBs. No pooling.
- Legacy PRB capacities are enough.
- UE/TTI capacities and pooling:
- Minimum 18 DL / 16 UL UE/TTI available which is reasonable capacity.
- New 1 L1 subpool L1 pool and CSM for NR FDD mMIMO.
L2 Aspects of 1st deployment above
- New CSM for L2 pool with 6 asymmetric L2 subpools.
- L2-PS
- Use 2 cores for 1 100M cell. Nominal performance for 100M TDD cells.
- Use 1 core for 1 30M/20M cell. Reduced performance for 20M/30M TDD cells.
- Expected to achieve min 60% of nominal performance in DL with 5GC001116 frame structure.
- Expected to achieve max 70% of nominal performance in UL with 5GC001116 frame structure.
- With DCP move and L2-HI reduction: 2 cores for 1 30M/20M with nominal performance
- Use 2 cores for 2 cells. Nominal performance for NR FDD cells.
- Mix of 2-core and 1-core L2 TDD subpool types in one L2 pool.
- L2-LO
- Nominal performance expected.
- L2-HI
- Nominal performance expected.
- Even in the DCP move and L2-HI resource reduction option considering other BB boards in the site (at least 1 other expected with 
L2-HI).

### L2 Deployments (8)

| ABIP/ABIQ | 4 cores | 4 cores |  |  |  | 4 cores |  |  |  | 4 cores |  |  |  | 4 cores |  |  |  | 4 cores |  |  |  | L2 Pools |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Full Board Deployments for 4-sector TDD configurations | Linux SMP (*) | HI | HI | HI | HI | LO | LO | PS | PS | PS | PS | LO | PS | PS | PS | L | L | L | L | L | L |  |
|  |  | HI | HI | HI | HI | LO | LO | PS | PS | PS | PS | LO | LO | PS | PS | L | L | L | L | L | L |  |
|  |  | HI | HI | HI | HI | LO | LO | PS | PS | PS | PS | LO | LO | PS | PS | PS | PS | L | L | L | L |  |
|  |  | HI | HI | HI | LO | LO | LO | PS | PS | PS | PS | PS | PS | PS | PS | PS | PS | PS | PS | PS | PS |  |
### L2 Deployments (9)

| ASOG/ASOH | 4 cores | 4 cores | 4 cores |  |  |  | 4 cores |  |  |  | 4 cores |  |  |  | 4 cores |  |  |  | L2 Pools |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Half Board 1 | Linux SMP (*) and TRSW |  | HI | HI | LO | LO | PS | PS | PS | PS | - | - | - | - | - | - | - | - |  |
|  |  |  | HI | HI | LO | LO | PS | PS | PS | PS |  |  |  |  |  |  |  |  |  |
|  |  |  | HI | HI | LO | LO | PS | PS | PS | PS | - | - | - | - | - | - | - | - |  |
|  |  |  | - | - | - | - | TM | TM | TM | TM | - | - | - | - | - | - | - | - |  |
| Half Board 2 |  |  | - | - | - | - | - | - | - | - | HI | HI | LO | LO | PS | PS | PS | PS |  |
|  |  |  |  |  |  |  |  |  |  |  | HI | HI | LO | LO | PS | PS | PS | PS |  |
|  |  |  | - | - | - | - | - | - | - | - | HI | HI | LO | LO | PS | PS | PS | PS |  |
|  |  |  | - | - | - | - | - | - | - | - | - | - | - | - | TM | TM | TM | TM |  |
| Full Board |  |  | HI | HI | HI | HI | LO | LO | LO | LO | PS | PS | PS | PS | PS | PS | PS | PS |  |
|  |  |  | HI | HI | HI | LO | LO | LO | LO | PS | PS | PS | PS | PS | PS | PS | PS | PS |  |
|  |  |  | HI | HI | HI | LO | LO | LO | LO | PS | PS | PS | PS | PS | PS | PS | PS | PS |  |
|  |  |  | HI | HI | HI | HI | LO | LO | PS | PS | PS | PS | PS | PS | LO | PS | PS | PS |  |
|  |  |  | HI | HI | HI | LO | LO | LO | PS | PS | PS | PS | PS | PS | LO | PS | PS | PS |  |
|  |  |  | HI | HI | HI | LO | LO | LO | PS | PS | PS | PS | PS | PS | LO | PS | PS | PS |  |
|  |  |  | HI | HI | HI | LO | LO | LO | PS | PS | PS | PS | PS | PS | L | L | L | L |  |
|  |  |  | HI | HI | HI | LO | LO | LO | PS | PS | PS | PS | PS | PS | LO | LO | PS | PS |  |
|  |  |  | HI | HI | HI | LO | LO | PS | PS | PS | PS | LO | PS | PS | L | L | L | L |  |

### L2 Subpool Types and Characteristics

| L2 Subpool Type | Deployment |  |  |  | DL/UL scheduling mapping to cores | Max configured cells for high performance | Max configured cells for performance | Max configured cells for connectivity | Max configured cells for very low load (for max cells marketing) | Restrictions | Availability |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| FR1 TDD 1-core | PS | - | - | - | Mix (DL+UL per core) | - | - | 1 | - | Max 50M cell BW or max 8DL/8UL UE/TTI. Reduced cell peak performance with simultaneous DL+UL load. | Legacy |
| FR1 TDD 2-core | PS | PS | - | - | 1 cell w/o DL pipeline: Direct (DL or UL per core). 1 cell w/ DL pipeline: Partial mix (DL or DL+UL per core). 2 cells: Cross mix (DL+UL per core with mix of cells) | - | 1 | 2 Should be avoided. Use 2 x FR1 TDD 1-core deployment instead. | - | Scheduling timing (slot duration and K2min) alignment between cells. | Legacy. 2 cells should be avoided. Use 2 x FR1 TDD 1-core deployment instead in all new BB cell sets from 27R1 onwards. |
| FR1 TDD 3-core | PS | PS | PS |  | Direct (DL or UL per core). 2 DL cores and 1 UL core. | 1 | - | - |  |  | future |
| FR1 TDD 4-core | PS | PS | PS | PS | Cross mix (DL+UL per core with mix of cells) – to be re- thought to prevent it. |  | - | 3 | - | Scheduling timing (slot duration and K2min) alignment between cells. | 28R1 CB015845 |
| FDD 1-core | PS | - | - | - | Mix (DL+UL per core) | - | 1 | - | 2 | Reduced peak performance with simultaneous DL+UL load. Scheduling timing (slot duration and K2min) alignment between cells. | Legacy |
| FDD 2-core | PS | PS | - | - | Direct (DL or UL per core) | 1 | 2 w/o connectivity cells. 1 w/ 2 connectivity cells. | 4 w/o performance cells. 2 w/ 1 performance cell. | 5 | Scheduling timing (slot duration and K2min) alignment between cells. | Legacy |

### TDD 2 cells on 2 cores replacement background

| Deployment                | Pros                                                               | Cons                                                | High level KPI impact                                                                                                                              | Test results for 6 cells on half-ABIP with TMO traffic model (TMT tests 1463 and 1464, reference 1453)                                                                                                                                                                                                                                                                                                                                 | Recommendations                                                                                                                                                           |
| ------------------------- | ------------------------------------------------------------------ | --------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1-core DL+UL              | Low complexity, single cell per core. Support odd number of cores. | Loose pooling benefit. Loose DL+UL parallelization. | Clear degradation in high load cell in the imbalanced load conditions. Improvement in case equal load in both cells.                               | Test 1463 compared to reference 1453. High load cell 301 step 3: -1.3 UE/TTI in DL, -1.2 UE/TTI in UL -33% of DL volume, - 34% of UL volume Pool level: -0.4 UE/TTI in DL, + 9 UE/TTI in UL -17% of DL volume, + 24% of UL volume                                                                                                                                                                                                      | Use this deployment in all new BB cell sets instead of 2 cells on 2 cores deployment. Don’t force change to any existing 2 cells on 2 core deployment due to KPI changes. |
| Single direction per core | Keep pooling. Keep DL+UL parallelization. Better cache.            | Complexity, still 2 cells per core.                 | Degradation in both cells in equal load conditions. No degradation or even slight improvement in high load cell in the imbalanced load conditions. | Test 1464 compared to reference 1453. High load cell 301 step 3: Improvement by cost of collapse of the other cell 303 and thus this not usable result (functional OLC issue). From 311 – 313 cell pair it can be interpreted that high load cell does not decrease or even gains a bit in this deployment when the other cell is having low load. Pool level: -12 UE/TTI in DL, - 3 UE/TTI in UL -37% of DL volume, - 8% of UL volume | Don’t proceed with this deployment. Not solving the 2 cells on 1 core complexity. Functionality and KPI issues.                                                           |

| Old BB Cell set (before 27R1) | Product | L2 Subpool Configuration | Used by RJIO | Used by TMO | Notes and Recommendations |
| --- | --- | --- | --- | --- | --- |
| CB006915 | ASOE | 2 x 8DL4UL layers 100M eCPRI 7-2a | No | No | There may be field use. Leave unchanged? |
| CB009022 | ASOE | 2 x 8DL4UL layers 100M eCPRI 7-2a | No | No | There may be field use. Leave unchanged? |
| CB007053 | ASOE | 2 x 4DL2UL layers 100M CPRI | No | No | There may be field use. Leave unchanged? |
| CB009499 | ASOF | 2 x 4DL2UL layers 100M CPRI / eCPRI 7-2a | No | No | There may be field use. Leave unchanged? |
| CB009142 | ABIP | 2 x 8DL4UL layers 100M eCPRI 7-2a | No | No | Modify by separation of performance and connectivity? |
| CB010706 | ABIP | 2 x 4DL2UL layers 100M CPRI | No | No | Modify by separation of performance and connectivity? |
| CB011098 | ABIP | 2 x 4DL2UL layers 100M ORAN | No | No | Modify by separation of performance and connectivity? |
| CB012512 | ABIP | 2 x 8DL4UL layers 50M eCPRI 7-2a | Yes | No | Modify deployment for 30/50M carriers? |
| CB009843 | ABIP | 2 x 16DL4UL layers 100M eCPRI 7-2e | No | No | Modify by separation of performance and connectivity? |
| CB011088 | ASOG/H | 2 x 8DL4UL layers 100M eCPRI 7-2a | No | No | Modify by separation of performance and connectivity? |
| CB011088 | ASOG/H | 2 x 4DL2UL layers 100M CPRI | No | No | Modify by separation of performance and connectivity? |
## UP Performance

### KPI Prioritization
From L2 Midterm Workshop 2025-02
Simplified Formula
	Cell Throughput is proportional to Slot Utilization x PRB Utilization x (MU MIMO Rank x MCS) x (1 - BLER) x TB Utilization
	MU MIMO Rank x MCS -> Spectral Efficiency

User Plane performance and KPIs shall be optimized for realistic field conditions
and in realistic SiSo configurations of the actual products. The primary KPIs for 
this optimization shall be cell throughput and data volume.
Secondary KPIs shall be optimized under the constraint that the primary KPIs are 
not negatively impacted. Secondary KPIs include for example:
- Slot Utilization, PRB Utilization, PDSCH or PUSCH UE/TTI
- MU MIMO Pairing / Rank, Spectral Efficiency
- MCS, BLER
Note: This requirement does not exclude the importance of other factors, whose 
importance depends on the case and on the algorithm in question. This includes 
for example:
- KPIs for stability and robustness, for example RRC success rate KPIs
- Priorities, Fairness, QoS, Slicing
- Latency
- User Throughput
- Interference
- Corner cases for lab testing and for demos


## High-Level UP Architecture for Carrier Aggregation

### Roadmap of Carrier Aggregation - High-Level Architectural View 2021-08-11

Note: Does not list all the feature contents but just the architecturally relevant parts.

| FR | 5G21A: Time-To-Market FR1 CA: FDD - TDD. | 5G21B: Time-To-Market FR1 CA: FDD - FDD, TDD - TDD | 22R1: FR1 CA Target Architecture | 22R2 | 22R3: CA with Higher Cell Amounts | 22R4 | Later: |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FR1 | FDD - TDD DL CA (5GC001390) • Inter-L2RT Architecture. • PUCCH Pipeline. • C-RNTI up to 72 FDD cells and/or up to 36 TDD cells per gNB-DU (or a linear mix). | All features support: • Inter-L2RT. • Distributable PUCCH. • Real DAI in UL DCI. FDD - FDD (5GC001167) • Data split to 3 legs. • Reverse Remote L2RT. FDD - TDD Enh (5GC002546) • Convert FDD - TDD to new architecture. TDD - TDD (5GC001729) • Trial. No Remote L2RT. SiSo restrictions. Intra- Band only. | All features support: • Inter-L2RT. • Distributable PUCCH. • Fake DAI in UL DCI. TDD - TDD (CB007922) • Commercial. • Includes Inter-Core. CA Arch Enh I (CB007736) • Includes Inter-Core. • Depends on 7922. Mixed CA Modes (CB008015) • Common parts for Fake DAI in UL DCI. TDD - FDD (5GC002329) 3CCs TDD PCell (CB006138) | 4CCs FDD PCell (5GC002640) 4CCs TDD PCell (CB008532) | CA Arch Enh II (CB007737) • Intra-Core Inter- NRCELLGRP Architecture for FDD - FDD and TDD - TDD. • Needed for more than 3 TDD cells per Half ABIO. • Needed for more than 6 FDD cells per Half ABIO. • C-RNTI above 72 cells per gNB-DU. |  | TDD-TDD UL CA (CB006449) FDD-TDD UL CA and TDD-FDD UL CA (CB006137) FDD-FDD UL CA (CB005935) Inter-gNB FR1 CA (CB008140) |
| FR2 | 5G19: CA with Analog BF for FR2 |  |  |  |  |  | TDD - FR2 (CB008292) FDD - FR2 (CB008293) FDD - TDD - FR2 (CB008303) |

### Architecturally Significant Requirements for Carrier Aggregation

Starting from 22R3 for selected features

| Release | Feature | Requirement | Rationale |
| --- | --- | --- | --- |
| Future (?) | CB00XXXX (formerly CB007737 "Carrier Aggregation Architecture enhancement but the C-RNTI part got descoped) | C-RNTI allocation mechanism shall be independent of cell placement on L2RT instances and on L2-PS cores. | Derived from the SiSo Independence principle of CA. |
| Future (?) | CB00XXXX | C-RNTI allocation mechanism shall support a scalable number of cells and L2RT Instances per gNB-DU and a scalable and poolable number of RRC Connected UEs per cell. | CA should support interworking with the BB Pooling features and concepts. |
| Future (?) | CB00XXXX | C-RNTI allocation mechanism shall support arbitrary many-to- many CA relations among cells within the gNB-DU and shall support any CA deployment scenarios defined by 3GPP TS 36.300 Annex J.1. | Derived from the general scalability requirements of CA. |
| Future (?) | CB00XXXX | C-RNTI allocation mechanism shall be extensible to inter-DU CA. | Avoid unnecessary rework of C-RNTI mechanisms and the corresponding KPI differences in future releases when introducing the inter-DU and inter-gNB features. |
| 26R3 | CB014293 "Inter-gNB UL carrier aggregation FR1-FR1" | CA-related information exchange between gNBs or between gNB-DUs shall happen only at L2 level or higher. | A similar requirement already applies within the gNB-DU. Furthermore, the L1-L2 interface shall not be opened across gNB-DUs due to its latency-sensitivity. |
| 26R3 | CB014293 "Inter-gNB UL carrier aggregation FR1-FR1" | CA-related information exchange between gNBs or between gNB-DUs on L2 level shall take place between two 5G-L2-PS instances (peer-to-peer) and between 5G-L2-HI and 5G-L2- LO (not peer-to-peer). | Avoid performance impact and complexity in 5G-L2-HI. 5G L2/L3 ADT decision on 2022-01-27. |
| 26R3 | CB014293 "Inter-gNB UL carrier aggregation FR1-FR1" | 5G-L2-PS information exchange between gNBs or between gNB-DUs shall be deployed as a Nokia-proprietary Xp application protocol. | Reuse the existing mechanisms in the Xp protocol suite to support communication between network elements. |
| 26R3 | CB014293 "Inter-gNB UL carrier aggregation FR1-FR1" | 5G-L2-LO/5G-L2-HI information exchange between gNBs or between gNB-DUs shall be deployed using a modified NR-UP protocol and GTP-U. | De-risk TRSW impact and avoid U-Plane architecture visibility in C-Plane Xn interface. 5G L2/L3 ADT decision on 2022-01- 27. |
| 23R120 2LL© 202 | 5C NBo0k0ia6137 C"Ionntefird beanntida lF -D JDu s+s iT SDipDo FlaR 1& UMLa CrkAo S (up to 2 UL CC)" | a(AaSriRnse nstill missing but will be related to UL CA in general.) |  |

### CA Scalable to Any Number of Cells and L2RT Instances.

#### Flexible Relations between PCells and SCells (N:M).
- This means to be archictecturally prepared to support all the
CA Deployment Scenarios from 3GPP TS 36.300 Annex J.1.

#### Long-Term Design Principles for FR1 CA (1)
SiSo Independence
- Any supported CA relation can be supported in any supported 
SiSo configuration (22R1 onwards).
- Operator does not see scheduler internal deployment 
(NRCELLGRP not used)
Any combination of cell placement cases can be supported 
simultaneously in the NRRELs of the same gNB-DU:
- 2) FR1 Intra-Core Inter-NRCELLGRP
- 3) FR1 Intra-L2RT Inter-Core
- 4) Inter-L2RT
- See green arrows in the figure.
Any combination of cell placement cases can be supported 
simultaneously for the CA of the same UE (if 3 or more CCs):
- 2) FR1 Intra-Core Inter-NRCELLGRP
- 3) FR1 Intra-L2RT Inter-Core
- 4) Inter-L2RT
- See red arrows in the figure.

Scheduling Algorithms are Cell-Specific
- For CA, no communication between cells is allowed in the 
delay critical part of the scheduling algorithm.
- Soft realtime is OK such as post-TTI exchange of decisions.
- For DL CA, use distributable PUCCH instead of Localized PUCCH.
- For UL CA, restrictions being studied.
UE Contexts are Component-Carrier-Specific
- PsCell, LoCell, PsUser and LoUser interfaces see cell contexts 
and cell-specific parts of the UE context.

Communication between Cells Happens on L2 Level and Higher
- L1 does not communicate with L1 of other cells.
Communication between Cells Uses Peer-To-Peer Interfaces
- No diagonal interfaces.
- L2RT does not communicate with L1 of other cells.
- 5G-L2-PS has no interface with 5G-L2-LO of the other cell.
- For UL CA, relevant UL MAC CEs on SCells are routed via 5G-L2-PS of SCell.
- 5G-L2-PS has PsPeerCtrl interface to another 5G-L2-PS.
- Functionally the same PsPeerCtrl interface is used between cells for all cell placement 
cases: Intra-Core, Intra-L2RT Inter-Core, Inter-L2RT.
- In case of Inter-gNB or Inter-DU, functionality of PsPeerCtrl is carried over XP.
- Note: This does not forbid DL and UL schedulers to talk across cells.
- Exception: For inter-gNB or inter-DU CA, 5G-L2-HI has 
interface with 5G-L2-LO of the other gNB-DU.
