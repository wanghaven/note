# 13 Frozen Requirements

## 13.0-1 Frozen Requirements Document Owner Mateusz Zawadzki mateusz.2.zawadzki@nokia.com (ID: 12563474)

### 13.1 Common DL/UL/SiSo

#### 13.1.1 CNI-108168 step 1.3

##### 13.1.1.1 Enhancement enabler for Inter Bad CA

##### 13.1.1.1-1 Enhancement enabler for Inter Bad CA

**13.1.1.1.0-4**  (ID: `11394155`)

Enhancement enabler for Inter Bad CA
This requirement is frozen starting from release 25R2 please refer L1 Interface module.

L1/L2 interface shall support enhancement enabler for Inter Band CA between CCs with different numerologies in TDD FR1 CPRI and eCPRI, FDD FR1 CPRI and FR2-TDD-eCPRI

**Note: For FDD + FR1-TDD CA UEs, L2-PS will include the details of HARQ-ACK bit for P(S)Cell and Scell in l2CtxtAnMgt** of PuschUciConfig in UlData\_PuschReceiveReq, so 5G-L1-UL will return back in the response to help to parse the HARQ-ACK bits for PCell and Scell. The purpose of the structure is to decrease the processing time in L2-PS so improving the delay budget for Scell HARQ-ACK processing.\*\*\*\*

**[RP003187-D] The requirement is also applicable for** L1 Thor for FR1-TDD-eCPRI **[End RP003187-D]**\*\*\*\*

**[RP003187-K] The requirement is also applicable for** L1 Thor for FR1-FDD-CPRI **[End RP003187-K]**\*\*\*\*

|  |  |
| --- | --- |
| Technology / HW | **Thor** |
| **FR1-FDD-CPRI** | **[RP003187-K] Supported** [End RP003187-K]\*\*\*\* |
| **FR1-FDD-OBSAI** | **[CB010969-SR-CB] Supported** [End CB010969-SR-CB]\*\*\*\* |
| **FR1-FDD-7-2a-eCPRI** | Supported |
| **FR1 TDD CPRI** | Supported |
| **FR1-TDD-7-2a-eCPRI** | **[RP003187-D] Supported** [RP003187-D]\*\*\*\* |
| **FR1-TDD-7-2e- eCPRI** | **[CB009514-H] Supported** [End CB009514-H]\*\*\*\* |

---

##### 13.1.1.2 Cell configuration and bandwidth

**13.1.1.2.0-2**  (ID: `11394852`)

Cell configuration and bandwidth
This requirement is frozen starting from release 23R1 please refer Management (BB) in L1 Requirements module.

This feature introduces the baseband cell set and the configuration needed to support the following configuration:

* FDD FR1 CPRI for 3 cells 30 MHz 4T4R (or all 2T4R, or all 2T2R), no BF, see CB006761
* AHPF RRH and ASIB/ABIO Ariscale

ABIO board can support 2 baseband cell sets (ABIO slot A and B), total 6 cells

* ABIO slot A: CPRI port #1, #2, #3, #4, #5 and #6 or part of it depending on cell BW, on RU and configuration
* ABIO slot B: CPRI port #7, #8 and #9 or part of it depending on cell BW, on RU and configuration

Note: this feature does not support DSS. A configuration block provided by this feature is composed of one capacity Plug In Unit(s) ABIL, one RF cell sets, and the needed fronthaul connections. This configuration block can be combined with any other valid configuration block in same RAU.

Fronthaul connectivity

* Each RU in this configuration block is connected via one CPRI 9.8G optical links to the ABIO.
* On ABIO any of the 1 to 6 ports or port 7 to 9 -depending on ABIO Slot A or B- can be used to terminate the CPRI link,
* On RU side any of the available optical ports can be used for 5G NR
* Maximum fiber length as defined in feature 5GC000579 is supported. However, the restriction regarding differential delay is not applicable to the Radio Units covered by this configuration feature.

---

##### 13.1.1.3 Testing related requirements

**13.1.1.3.0-11**  (ID: `11395903`)

Testing related requirements
This requirement is frozen starting from release 21A please refer L1 test vectors.

Testing only. Baseband block feature 5GC002411 is used for testing 3 sectors of 1 CC configurations with 1 subcell per cell (or sector). All bandwidth configurations related to TDD FR1 eCPRI shall be supported by the subfeature 5GC001120-H.

See L1 test vector specs <https://nokia.sharepoint.com/:f:/r/sites/ATFL1Spec/Coauthored%20documents/L1High%20specs/L1%20test%20vector%20specs?csf=1&web=1&e=3T8DF8>

---

##### 13.1.1.4 UL Cell configuration

###### 13.1.1.4-1 UL Subcell pooling

###### 13.1.1.4-2 UL Subcell pooling

###### 13.1.1.4-3 UL Subcell pooling

###### 13.1.1.4-4 UL Subcell pooling

###### 13.1.1.4-5 UL Subcell pooling

###### 13.1.1.4-6 UL Subcell pooling

###### 13.1.1.4-7 UL Subcell pooling

###### 13.1.1.4-8 UL Subcell pooling

###### 13.1.1.4-9 UL Subcell pooling

###### 13.1.1.4-10 UL Subcell pooling

###### 13.1.1.4-11 UL Subcell pooling

###### 13.1.1.4-12 UL Subcell pooling

###### 13.1.1.4-13 UL Subcell pooling

###### 13.1.1.4-14 UL Subcell pooling

###### 13.1.1.4-15 UL Subcell pooling

###### 13.1.1.4-16 UL Subcell pooling

###### 13.1.1.4-17 UL Subcell pooling

###### 13.1.1.4-18 UL Subcell pooling

###### 13.1.1.4-19 UL Subcell pooling

###### 13.1.1.4-20 UL Subcell pooling

###### 13.1.1.4-21 UL Subcell pooling

###### 13.1.1.4-22 UL Subcell pooling

###### 13.1.1.4-23 UL Subcell pooling

###### 13.1.1.4-24 UL Subcell pooling

###### 13.1.1.4-25 UL Subcell pooling

###### 13.1.1.4-26 UL Subcell pooling

###### 13.1.1.4-27 UL Subcell pooling

###### 13.1.1.4-28 UL Subcell pooling

###### 13.1.1.4-29 UL Subcell pooling

###### 13.1.1.4.1 Bandwidth Configuration

###### 13.1.1.4.1.1 Loki

###### 13.1.1.4.1.1.0-18 Loki This requirement is frozen starting from release 24R1 please refer Management (BB) chapter in L1 Requirements module. The L1 Loki in ABIO shall support CB006919-A: NR 3 cells 30MHz in FR1 FDD CPRI (ABIO) starting from 5G21B. This feature introduces additional FDD DU configuration block and corresponding baseband cell set for up to 3x FR1 FDD NR 30MHz 4T4R. This configuration is exclusively NR and does not allow DSS. This feature is exclusively dedicated to 30MHz FDD carrier bandwidth with AHPF RRH and ASIB/ABIO Ariscale. For other FDD wide carrier use case please check the corresponding BW feature.**** (ID: 11395300)

###### 13.1.1.4.1.2 Thor BB

**13.1.1.4.1.2.0-3**  (ID: `11395415`)

Thor BB
**This requirement is frozen starting from release 24R2 please refer Management (BB) chapter in L1 Requirements module.**

**[RP003187-J] L1** Thor shall support up to 3 A2 or up to 3 A4 subcells **[End RP003187-J]**\*\*\*\*

**[RP003187-L] L1 shall support** up to 6 A2 or 6 A4 subcells in Thor **[End RP003187-L]**\*\*\*\*

**[CB008325-5G-BA] L1 shall support** up to 12 A2 or 12 A4 subcells in Thor\*\*\*\*

* Up to 12 cells (4T4R), 20MHz

**[End CB008325-5G-BA]**

---

###### 13.1.1.4.2 Subcell Type

###### 13.1.1.4.2.1 Loki

**13.1.1.4.2.1.0-3**  (ID: `11394628`)

Loki
This requirement is frozen starting from release 23R1 please refer Management (BB) chapter in L1 Requirements module.

L1 shall support up to 3 C2 type subcells without beamforming, no C2 and/or C4 type subcell mixing is possible (as an intermediate step for 4DL-4UL without beamforming), with 20MHz to 100 MHz BW.

**[RP003187-D] The requirement is also applicable for** L1 Thor for FR1-TDD-eCPRI. **[End RP003187-D]**\*\*\*\*

---

###### 13.1.1.4.3 UL Subcell pooling

**13.1.1.4.3.0-2**  (ID: `11396025`)

UL Subcell pooling
This requirement is frozen starting from release 25R3 please refer BTSC\_L1\_Req\_11072 in L1 Requirements module.

**[Before CB013199-B]**

PRB pooling is always active within L1 SW.

Parameter **isPrbPoolingEnabled in message** L1Config\_SwConfigurationReq (BTSC\_L1\_Req\_4743\_replaced([11584801](https://dn-prod.ext.net.nokia.com/rm/resources/BI_BPk5K_wGEe-AqvopbP1qhQ))) for feature **CB009055 for uplink, according to requirement 5G\_UP\_7372, defines distribution stream PRB and layer PRB among sub pools within pool.**\*\*\*\*

|  |  |  |
| --- | --- | --- |
| **isPrbPoolingEnabled** | **PRB quantity within sub pool** |  |
| Sub pool 0 or 2 | Sub pool 1 or 3 |  |
| TRUE | 1638  stream PRB | 1638  stream PRB |
| 819  layer PRB | 819  layer PRB |  |
| FALSE | 2184  stream PRB | 1092  stream PRB |
| 1092  layer PRB | 546  layer PRB |  |

The requirement is also applicable for L1 **Thor for FR1-TDD-CPRI (see 5G\_UP\_8107).**

**[CB013199-B]**

For initial PRB allocation values, please refer to **BTSC\_L1\_Req\_11072\_replaced([11585413](https://dn-prod.ext.net.nokia.com/rm/resources/BI_BP7efvwGEe-AqvopbP1qhQ)). Do not update this requirement.**

**[End CB013199-B]**

---

##### 13.1.1.5 Mixed bandwidth support (candidate to frozen chapter as it is maintained in Management (BB) in L1 Requirements module)

###### 13.1.1.5.0-3 Mixed bandwidth support (candidate to frozen chapter as it is maintained in Management (BB) in L1 Requirements module) 5G-L1-UL shall support mixed carrier bandwidth subcells. For supported configurations, see BTSC_L1_Req_9939_replaced( 11585085 ). (ID: 11445541)

##### 13.1.1.6 Supercell handling

###### 13.1.1.6.0-9 Supercell handling -Cellsets from CB008434-A and CB008434-B can be combined together such that there can be 3 super-cells with 2 sub-cells in each or 2 super-cells with one having 4 and the other having 2 sub-cells. Such a configuration requires one super-cell having sub-cells distributed on the two Lokis of an ABIO/ASOE board. -Sub-cell(s) belonging to a super-cell cannot be combined with 'normal' cells on the same Loki, but on two different Lokis. (ID: 11488484)

##### 13.1.1.7 BB Resource management

###### 13.1.1.7.1 ARM/DSP core

**13.1.1.7.1.0-3**  (ID: `11488528`)

ARM/DSP core
11488528:
ARM/DSP core
11488528:
ARM/DSP core
11488528:
ARM/DSP core
11488528:
ARM/DSP core
11488528:
ARM/DSP core
11488528:
ARM/DSP core
11488528:
ARM/DSP core
11488528:
ARM/DSP core
11488528:
ARM/DSP core
11488528:
ARM/DSP core
11488528:
ARM/DSP core
11488528:
ARM/DSP core
11488528:
ARM/DSP core
11488528:
ARM/DSP core
11488528:
ARM/DSP core
11488528:
ARM/DSP core
11488528:
ARM/DSP core
11488528:
ARM/DSP core
11488528:
ARM/DSP core
11488528:
ARM/DSP core
5G L1 UL and DL shall reserve static allocation of ARM/DSP core based on the information from L1SWConfigurationReq received during start-up phase. In the same manner, the MHAB resources are equally allocated between the RATs on shared one Loki in ASOE.

The following figures show the allocation of resources between NR TDD and NR FDD on shared one Loki in ASOE:

[image-0][image\_desc]The image displays a diagram illustrating two clusters of processing units: an "ARM cluster" and a "Ceva MDAB cluster (DSP)".
The ARM cluster is depicted at the top and contains five rectangular blocks. From left to right, these blocks are labeled:
1. "Linux Ctrl NRT F+T" (light blue)
2. "Ctrl RT F+T DL" (green)
3. "Ctrl RT F+T DL" (green)
4. "Ctrl RT FDD UL" (red)
5. "Ctrl RT TDD UL" (red)
The Ceva MDAB cluster (DSP) is shown below the ARM cluster and contains a row of sixteen rectangular blocks, each with a yellow border and a gradient fill from yellow at the top to pink and then blue at the bottom. The text within these blocks alternates between "F+T DL" and "F+T UL". Specifically, there are eight "F+T DL" blocks and eight "F+T UL" blocks. The sequence is:
- "F+T DL" (x8)
- "F+T UL" (x8)
The last block in the Ceva MDAB cluster is a red rectangle with a yellow border, labeled "IQro uting".
The overall diagram is enclosed within a blue border.[/image\_desc][image\_path]https://storage.googleapis.com/dng\_files/images/HTML\_pukkola\_5G\_L1\_Entity\_Level\_file\_11878.001.png[/image\_path][/image-0]

One ARM core is for Linux NRT which will be shared between NR FDD and NR TDD. For RT in DL direction 3 cores are shared between NR FDD and NR TDD, whereas in UL, one core is dedicated for NR FDD and one core for NR TDD.

In the case of DSP cores, now the UL and DL cores are shared, they should be 50-50% or close to 50-50% between NR FDD and NR TDD on shared one Loki.

[Before CB011014-A]

Functionality was initially introduced with feature CB011014-A in release 23R4 and backported to release 23R3 with CNI-97871.

[End CB011014-A]

---

###### 13.1.1.7.2 Other resources

###### 13.1.1.7.2.0-5 Other resources 5G L1 DL shall reserve the shared memory based on the information received from L1Config_SwConfigurationReq message for multi-RAT loki/[CB007487-S]Thor[End CB007487-S] in concurrent mode. The first L1 pool is always reserved for 5G subcells in case of concurrent mode 5G+LTE. (ID: 11488568)

##### 13.1.1.8 Message validation (propose to delete)

###### 13.1.1.8.1 Validation of the cell slots information

###### 13.1.1.8.1.0-2 Validation of the cell slots information Loki (ID: 11488594)

**13.1.1.8.1.0-2.0-1**  (ID: `11488600`)

Validation of the cell slots information
L1 SW shall validate the cell slots information i.g length, placement to handle if OAM configure incorrectly.

---

###### 13.1.1.8.1.0-3 Validation of the cell slots information Thor (ID: 11488606)

**13.1.1.8.1.0-3.0-1**  (ID: `11488612`)

Validation of the cell slots information
L1 SW shall validate the cell slots information i.g length, placement to handle if OAM configure incorrectly.

[CB009851-A] This requirement is also applicable for RINLINE2 for FR1-TDD-7-2a-eCPRI. [End CB009851-A]

---

###### 13.1.1.8.2 Validation of the maxNumOfDataLayersPerCell and maxNumOfDataStreamsPerCell

**13.1.1.8.2.0-1**  (ID: `11488625`)

Validation of the maxNumOfDataLayersPerCell and maxNumOfDataStreamsPerCell
Content of this requirement is frozen and valid until 23R4 release. For later releases please refer to the objects below.

L1 SW shall validate the DL&UL maxNumOfDataLayersPerCell and DL&UL maxNumOfDataStreamsPerCell according 5G\_L1\_6043\_replaced([11486043](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fD5VAPvvEe-AqvopbP1qhQ)) if OAM configure incorrectly.

[CB009443-C] This requirement shall be supported in RINLINE1 HW for FR1-TDD-eCPRI. [End CB009443-C]

---

###### 13.1.1.8.2.1 Loki

**13.1.1.8.2.1.0-1**  (ID: `11488636`)

Loki
L1 SW shall process and store the maxNumOfDataLayersPerCell and maxNumOfDataStreamsPerCell of L1Config\_SwConfigurationReq for UL and DL subpools:

DL maxNumOfDataStreamsPerCell =  4;

DL maxNumOfDataLayersPerCell = 4;

UL maxNumOfDataStreamsPerCell =  4;

UL maxNumOfDataLayersPerCell = 2.

---

###### 13.1.1.8.2.2 Thor

**13.1.1.8.2.2.0-2**  (ID: `11488655`)

Thor
L1 SW shall process and store the maxNumOfDataLayersPerCell and maxNumOfDataStreamsPerCell of L1Config\_SwConfigurationReq for UL and DL subpools:

DL maxNumOfDataStreamsPerCell =  4;

DL maxNumOfDataLayersPerCell = 4;

If any of the following conditions is satisfied:

- C8 subcell is to be deployed in uplink pool.

- All C4 subcells (cell slot=12 per subcell) are to be deployed in uplink pool with full board deployment.

The following parameters shall be set for all subpools of such pool:

UL maxNumOfDataStreamsPerCell =  8;

UL maxNumOfDataLayersPerCell = 4;

Otherwise:

UL maxNumOfDataStreamsPerCell =  4;

UL maxNumOfDataLayersPerCell = 2.

[CB010708-B, CB010708-C] In case of eCPRI 7-2e, maxNumOfDataLayersPerCell and maxNumOfDataStreamsPerCell of L1Config\_SwConfigurationReq for UL should be as below table

|  |  |  |  |
| --- | --- | --- | --- |
| Subcell type | maxNumOfDataLayersPerCell | maxNumOfDataStreamsPerCell | First feature |
| C4\_2 | 2 | 4 | CB007595-A |
| C8\_2 | 2 | 8 | CB010708-B |
| C8\_4 | 4 | 8 | CB010708-C |

Note: this table needs to be revisited in future when official cell slot model for eCPRI 7-2e is implemented.

[End CB010708-B, CB010708-C]

---

###### 13.1.1.8.3 Validation of the frequencyRange

###### 13.1.1.8.3.0-1 Validation of the frequencyRange L1 SW shall validate the frequencyRange according BTSC_L1_Req_4743_replaced( 11584801 ) if OAM configure correctly. (ID: 11488666)

###### 13.1.1.8.4 Validation of the subpool configuration

**13.1.1.8.4.0-1**  (ID: `11488677`)

Validation of the subpool configuration
L1 SW shall do parameter(5G\_L1\_6044\_replaced([11487298](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fEApvPvvEe-AqvopbP1qhQ)), 5G\_L1\_6057\_replaced([11486165](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fD6jEfvvEe-AqvopbP1qhQ))) checking according the cell slot info definition in the EFS(5G\_L1\_6052\_replaced([11485840](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fD4t6_vvEe-AqvopbP1qhQ))) when get the cell slot info from L1Config\_SwConfigurationReq, DlCell\_SetupReq and UlCell\_SetupReq message.

[Before NCI-122313]

[CB009443-C] This requirement shall be supported in RINLINE1 HW for FR1-TDD-eCPRI. [End CB009443-C]

[CNI-122313] RINLINE1 support is terminated in 24R1, requirement is not valid for RINLINE1 starting from 24R2. [End CNI-122313]

---

###### 13.1.1.8.5 Validation of the fronthaulMode configuration

**13.1.1.8.5.0-1**  (ID: `11488689`)

Validation of the fronthaulMode configuration
L1 SW shall validate fronthaulMode parameter value with requested subcellType in DlCell\_SetupReq and UlCell\_SetupReq message. Non-supported fronthaulMode and subcellType combinations shall be invalidated and responded with "NotOk" on Dl/UlCell\_SetupResp message.

HW-Technology Map:

|  |  |  |
| --- | --- | --- |
| Technology / HW | Loki | Thor |
| FR1-FDD-CPRI | Supported | [CB010578-A] Supported [End CB010578-A] |
| FR1-FDD-OBSAI | Supported | [CB010578-A] Supported [End CB010578-A] |

---

##### 13.1.1.9 New L1 HW introduction

**13.1.1.9.0-11**  (ID: `11488760`)

New L1 HW introduction
L1 SW shall be supported on SoC-based L1 HW: RINLINE-2.

SoC name is Thor.

"CB009851: RINLINE2 HW Introduction and L3 Call TDD eCPRI with Switched Fronthaul" is first L3 Call feature for this HW for L1 SW.

"CB010606 RINLINE2 HW Introduction and L3 Call with Direct Connectivity" is second L3 Call feature for this HW for L1 SW.

---

##### 13.1.1.10 Full board tests

**13.1.1.10.0-12**  (ID: `11488919`)

Full board tests
11488919:
Full board tests
11488919:
Full board tests
11488919:
Full board tests
11488919:
Full board tests
11488919:
Full board tests
11488919:
Full board tests
11488919:
Full board tests
11488919:
Full board tests
11488919:
Full board tests
11488919:
Full board tests
11488919:
Full board tests
11488919:
Full board tests
11488919:
Full board tests
11488919:
Full board tests
11488919:
Full board tests
11488919:
Full board tests
11488919:
Full board tests
11488919:
Full board tests
11488919:
Full board tests
11488919:
Full board tests
L1 SW for Thor shall support the next configuration.

L1 shall support following L1 instance: L1\_Thor\_FR1.

Each L1 pool selects L1 pool type NR\_L1Pool\_Thor\_TDD\_FR1\_eCPRI.

For L1 Pool 0 PRB pooling shall be enabled (isPrbPoolingEnabled=TRUE in message L1Config\_SwConfigurationReq as described in 5G\_L1\_12311\_replaced([11396018](https://dn-prod.ext.net.nokia.com/rm/resources/BI_e8qEivvvEe-AqvopbP1qhQ)))

For L1 Pool 1 PRB pooling shall be enabled (isPrbPoolingEnabled=TRUE in message L1Config\_SwConfigurationReq as described in 5G\_L1\_12311\_replaced([11396018](https://dn-prod.ext.net.nokia.com/rm/resources/BI_e8qEivvvEe-AqvopbP1qhQ)))

For UL:

- 2 L1 pools per Thor, every L1 pool consists of 96 cell slots;

- 2 L1 subpools per pool, every L1 subpool consists of 48 cell slots;

- 4 C4 cells per L1 subpool (2 primary subcells and 2 secondary subcells), every subcell consists of 12 cell slots;

- 1638 stream PRB per L1 subpool;

- 819 layer PRB per L1 subpool.

[image-0][image\_desc]The image contains a table with a header row and multiple data rows. The header row consists of cells labeled "C4". The data rows are divided into sections, each representing a "Thor L1 SP" with associated "NR TDD FR1 48 slots".
Here is the table represented in markdown:

| C4 | C4 | C4 | C4 | C4 | C4 | C4 | C4 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 0-11 | 12-23 | 24-35 | 36-47 | 48-59 | 60-71 | 72-83 | 84-95 |
| **Thor L1 SP 0** |  |  |  |  |  |  |  |
| NR TDD FR1 48 slots |  |  |  |  |  |  |  |

| C4 | C4 | C4 | C4 | C4 | C4 | C4 | C4 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 96-107 | 108-119 | 120-131 | 132-143 | 144-155 | 156-167 | 168-179 | 180-191 |
| **Thor L1 SP 1** |  |  |  |  |  |  |  |
| NR TDD FR1 48 slots |  |  |  |  |  |  |  |
| **Thor L1 SP 2** |  |  |  |  |  |  |  |
| NR TDD FR1 48 slots |  |  |  |  |  |  |  |
| **Thor L1 SP 3** |  |  |  |  |  |  |  |
| NR TDD FR1 48 slots[/image\_desc][image\_path]https://storage.googleapis.com/dng\_files/images/HTML\_pukkola\_5G\_L1\_Entity\_Level\_file\_11929.001.png[/image\_path][/image-0] |  |  |  |  |  |  |  |

For DL:

- 2 pools per Thor, every pool consists of 96 cell slots;

- 2 subpools per pool, every sub pool consists of 48 cell slots;

- 4 C4 cells per sub pool (2 primary sub cells and 2 secondary sub cells), every cell consists of 12 cell slots;

- 2184 stream PRB per sub pool;

- 2184 layer PRB per sub pool.

[image-1][image\_desc]The image contains a table with a header row and multiple data rows. The header row has cells labeled "C4" in yellow. The first data row contains numerical ranges from "0-11" to "84-95". Below this, there are two cells spanning horizontally, labeled "Thor L1 SP 0 NR TDD FR1 48 slots" and "Thor L1 SP 1 NR TDD FR1 48 slots" respectively, in a grey background. Underneath these, another row of data cells labeled "C4" in yellow contains numerical ranges from "96-107" to "180-191". Finally, there are two more cells spanning horizontally at the bottom, labeled "Thor L1 SP 2 NR TDD FR1 48 slots" and "Thor L1 SP 3 NR TDD FR1 48 slots" respectively, also on a grey background.
The table can be represented as follows:

|  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- |
| C4 | C4 | C4 | C4 | C4 | C4 | C4 | C4 |
| 0-11 | 12-23 | 24-35 | 36-47 | 48-59 | 60-71 | 72-83 | 84-95 |
| Thor L1 SP 0 NR TDD FR1 48 slots | Thor L1 SP 1 NR TDD FR1 48 slots |  |  |  |  |  |  |
| C4 | C4 | C4 | C4 | C4 | C4 | C4 | C4 |
| 96-107 | 108-119 | 120-131 | 132-143 | 144-155 | 156-167 | 168-179 | 180-191 |
| Thor L1 SP 2 NR TDD FR1 48 slots | Thor L1 SP 3 NR TDD FR1 48 slots |  |  |  |  |  |  |

---

**13.1.1.10.0-12.0-2**  (ID: `11488939`)

Full board tests
11488939:
Full board tests
11488939:
Full board tests
11488939:
Full board tests
11488939:
Full board tests
11488939:
Full board tests
11488939:
Full board tests
11488939:
Full board tests
11488939:
Full board tests
11488939:
Full board tests
11488939:
Full board tests
11488939:
Full board tests
11488939:
Full board tests
11488939:
Full board tests
11488939:
Full board tests
11488939:
Full board tests
11488939:
Full board tests
11488939:
Full board tests
11488939:
Full board tests
11488939:
Full board tests
11488939:
Full board tests
With capacity defined in 5G\_L1\_11572\_replaced([11488919](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fEKatfvvEe-AqvopbP1qhQ)), L1 SW shall support following configuration (3 cells 16DL 8UL on Full ABIP/ABIQ):

* One subpool can support one primary subcell only.
* For DL, two subcells of each cell are placed to L1 subpools sequently. Each L1 pool serves half amount subcells of each cell.  Each subcell consumes 12 cell slots. It means primary subcell of cell1 is in subpool0, primary subcell of cell2 is in subpool2, primary subcell of cell3 is in subpool1.
* For DL, Last 24 cell slots of subpool1/3 are not used. For UL, Last 24 cell slots of subpool0/1/2 are not used, subpool3 is not used.
* For DL, Large PRB pooling is enabled.
* For UL, Primary subcells are placed in subpools with same subpool id of DL's primary subcells. Secondary subcells are followed primary subcell sequently.

[image-0][image\_desc]The image is a diagram illustrating a system architecture, likely related to telecommunications or computing. It's structured as a grid with cells and labels indicating different components and their relationships.
The diagram is divided into two main horizontal sections, each representing a set of "Subpools Pools". Within each of these main sections, there are three rows labeled "cell 1", "cell 2", and "cell 3".
The left side of the diagram features labels like "GC16" and "L2 SP". "GC16" appears in yellow boxes, suggesting a specific component or configuration. "L2 SP" is found at the bottom, with further labels like "L2 Pool NR TDD FR1 Full-Board".
The central and right portions of the diagram are filled with cells labeled "C4" (some underlined) and "L1 SP". These "L1 SP" cells are further described by text like "Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2)" and "Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2)", indicating specific types of L1 pools.
The arrangement of the "C4" cells within the "cell 1", "cell 2", and "cell 3" rows suggests different configurations or groupings of these components. The "GC16" components seem to span across multiple cells in the vertical direction.
Here's a markdown representation of the table-like structure:

| Category | Cell 1 | Cell 2 | Cell 3 | Subpools Pools |
| --- | --- | --- | --- | --- |
| **Top Section** |  |  |  |  |
| GC16 |  | C4 | C4 | cell 1 |
|  | GC16 | C4 | C4 | cell 2 |
|  |  |  |  | cell 3 |
|  | L1 SP (Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2)) | L1 SP (Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2)) |  | Subpools Pools |
| **Bottom Section** |  |  |  |  |
| GC16 |  | C4 | C4 | cell 1 |
|  | GC16 | C4 | C4 | cell 2 |
|  |  |  |  | cell 3 |
| L2 SP (L2 Pool NR TDD FR1 Full-Board) | L1 SP (Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2)) | L1 SP (Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2)) |  | Subpools Pools |
|  |  |  |  |  |
|  | L1 SP (Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2)) | L1 SP (Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2)) |  |  |
| *Note: The table representation is an approximation as the original image has a more complex, non-uniform grid structure.*[/image\_desc][image\_path]https://storage.googleapis.com/dng\_files/images/HTML\_pukkola\_5G\_L1\_Entity\_Level\_file\_11931.001.png[/image\_path][/image-0] |  |  |  |  |

---

###### 13.1.1.10.0-19 Full board tests Loki (ID: 11489041)

**13.1.1.10.0-19.0-1**  (ID: `11489047`)

Full board tests
NR FDD + LTE FDD

---

**13.1.1.10.0-19.0-1.0-7**  (ID: `11489146`)

Full board tests
11489146:
Full board tests
11489146:
Full board tests
11489146:
Full board tests
11489146:
Full board tests
11489146:
Full board tests
11489146:
Full board tests
11489146:
Full board tests
11489146:
Full board tests
11489146:
Full board tests
11489146:
Full board tests
11489146:
Full board tests
11489146:
Full board tests
11489146:
Full board tests
11489146:
Full board tests
11489146:
Full board tests
11489146:
Full board tests
11489146:
Full board tests
11489146:
Full board tests
11489146:
Full board tests
11489146:
Full board tests
L1 shall support following configuration in ABIO:

- (3 cells FDD NB NR + 3 cells FDD LTE ) in Loki A and (6 cells LTE FDD ) in Loki B.

Note: In this scenario, Loki A is always multi-RAT Loki.

[image-0][image\_desc]The image is a diagram illustrating a network or system architecture. It depicts several components connected by lines representing data or signal pathways.
At the top, there are three rectangular grey boxes, each containing two pairs of colored ovals, one blue and one yellow. These boxes are labeled "CPU1,0" and "CPU1,1" respectively.
Below these, a horizontal white rectangular bar labeled "frontpa" is shown. This bar has several colored squares along its top edge, labeled "P0" through "P7". Lines connect the "CPU" boxes to specific ports on this "frontpa" bar.
Below the "frontpa" bar, two larger blue rectangular boxes are positioned side-by-side, labeled "Loki B" on the left and "Loki A" on the right. Each of these "Loki" boxes has a series of smaller grey squares along its top edge, labeled "G1" through "G8". Colored lines originate from the "frontpa" bar and connect to specific ports on the "Loki" boxes. Specifically, a red line connects "P0" to "G1" on "Loki B", an orange line connects "P1" to "G2" on "Loki B", and a yellow line connects "P2" to "G3" on "Loki B". Green lines connect "P3" to "G4" on "Loki B" and "G5" on "Loki A". Blue lines connect "P4" to "G6" on "Loki A", "P5" to "G7" on "Loki A", and "P6" to "G8" on "Loki A". A final blue line connects "P7" to a port on "Loki A" that is not explicitly labeled with a "G" number.
Below the "Loki B" and "Loki A" boxes, there are two pairs of colored ovals, one blue and one yellow, positioned below each "Loki" box.
At the bottom center of the diagram, a grey rectangular box labeled "SNF" is shown. A thick grey line connects the "Loki B" and "Loki A" boxes to the "SNF" box.[/image\_desc][image\_path]https://storage.googleapis.com/dng\_files/images/HTML\_pukkola\_5G\_L1\_Entity\_Level\_file\_11946.001.png[/image\_path][/image-0]

- (3 cells FDD NB NR + 3 cells FDD LTE ) in Loki A and (3 cells TDD WB NR ) in Loki B.

Note: In this scenario, either Loki A or Loki B can be multi-RAT Loki. For instance, if Loki A is chosen to be multi-RAT then Loki B is single RAT (WB NR) and vice versa.

[image-1][image\_desc]The image is a diagram illustrating a system architecture. At the top, there are two sets of three rectangular units. The left set contains three red ovals, and the right set contains three yellow ovals within blue ovals. Lines connect these units to a horizontal bar labeled "fonte". This bar has several colored input ports: red, orange, yellow, green, light blue, and dark blue.
Below the "fonte" bar, there are two larger rectangular units labeled "Loki B" on the left and "Loki A" on the right. Each of these units has a series of labeled ports along their top edge, indicated by "A" and "B" and numbered "G1" through "G4".
Colored lines connect the ports on the "fonte" bar to the ports on the "Loki B" and "Loki A" units. Specifically, the red, orange, and yellow lines from the "fonte" bar connect to "Loki B". The green, light blue, and dark blue lines from the "fonte" bar connect to "Loki A".
Below "Loki B" and "Loki A", there is a gray rectangular unit labeled "SNF". Two thick gray lines connect the bottom of "Loki B" and "Loki A" to the "SNF" unit.
To the left of "Loki B", there is a single red oval. To the right of "Loki A", there are two yellow ovals stacked vertically, and below them, two blue ovals stacked vertically.
There are also two labels above the "fonte" bar: "eCPU1" connected to the left set of units, and "eCPU 2" connected to the right set of units.
The diagram appears to represent a data flow or connection schematic, possibly related to computing or networking components.[/image\_desc][image\_path]https://storage.googleapis.com/dng\_files/images/HTML\_pukkola\_5G\_L1\_Entity\_Level\_file\_11946.002.png[/image\_path][/image-1]

---

**13.1.1.10.0-19.0-2**  (ID: `11489152`)

Full board tests
NR FDD + NR TDD

---

**13.1.1.10.0-19.0-2.0-3**  (ID: `11489220`)

Full board tests
11489220:
Full board tests
11489220:
Full board tests
11489220:
Full board tests
11489220:
Full board tests
11489220:
Full board tests
11489220:
Full board tests
11489220:
Full board tests
11489220:
Full board tests
11489220:
Full board tests
11489220:
Full board tests
11489220:
Full board tests
11489220:
Full board tests
11489220:
Full board tests
11489220:
Full board tests
11489220:
Full board tests
11489220:
Full board tests
11489220:
Full board tests
11489220:
Full board tests
11489220:
Full board tests
11489220:
Full board tests
L1 SW shall support following cell slot allocation with single NR TDD in non-shared Loki and concurrent mode NR TDD+NR FDD in shared same Loki of ASOE. On full ASOE, L1 SW should support to configure (1)+(2)+(3) as below:

(1) 3\*8DL8Ul(#) NR TDD Cells(Max BW=100MHz) in non-shared Loki

(2) 3\*8DL8UL NR FR1 TDD cells(Max BW=[Before CB010367-B-UPD001]50MHz[CB010367-B-UPD001]30MHz[End CB010367-B-UPD001]

): 1*8DL8UL NR FR1 TDD cell(Max BW=[Before CB010367-B-UPD001]50MHz[CB010367-B-UPD001]30MHz[End CB010367-B-UPD001]) in non-shared Loki + 2*8DL8UL NR FR1 TDD cells(Max BW=[Before CB010367-B-UPD001]50MHz[CB010367-B-UPD001]30MHz[End CB010367-B-UPD001]) in shared Loki

(3) [Before CB010367-B-UPD001]4[CB010367-B-UPD001]3[End CB010367-B-UPD001]\*4DL4UL NR FR1 FDD cells (Max BW=20MHz) in shared Loki

Note:

(#) : it means 1*8DL/8UL cell should be combined with 2*C4 subcells in the same L1 subpool on DL/UL, one is C4 primary subcell, another one is C4 secondary subcell.

Loki A (NR FR1 TDD only): 3*8DL8UL NR FR1 TDD cells with BW up to 100MHz + 1*8DL8UL NR FR1 TDD cell with BW up to [Before CB010367-B-UPD001]50MHz[CB010367-B-UPD001]30MHz[End CB010367-B-UPD001]

For NR TDD, L1 SW shall support the L1 instance type NR\_L1\_Loki\_TDD\_FR1\_eCPRI\_IQF\_Symm, which is defined in 5G\_UP\_12470 & 5G\_UP\_12471. In this L1 instance, for DL and UL, two L1 subpools with total 96 cell slots are supported:

- Support symmetric L1 subpool setting in DL & UL.

- In DL/UL, 48 cell slots per L1 subpool, 4\*C2/C4 subcells per L1 subpool, each subcell with BW up to 100MHz, and each subcell consumes 12 cell slots.

- In DL/UL, the L1 pool shall support in total 8\*C2/C4 subcells and comsumes 96 cell slots in total.

[CB010367-B] For this L1 instance type in DL/UL, L1 SW shall support to configure up to 6*C2/C4 subcells with BW up to 100MHz, and 2*C2/C4 subcells with BW up to [Before CB010367-B-UPD001]50MHz[CB010367-B-UPD001]30MHz[End CB010367-B-UPD001]. For 2 subcells with BW up to [Before CB010367-B-UPD001]50MHz[CB010367-B-UPD001]30MHz[End CB010367-B-UPD001], they have one Primary subcell and one Secondary subcell and should be placed in the same L1 subpool, occupied cell slot index 72-95. [End CB010367-B]

Note: In DL & UL, the subcell placement with Primary subcell and Secondary subcell per Loki follows 5G\_UP\_2510, for the details of channel support on Primary subcell and Secondary subcell refer to 5G\_UP\_2554.

[image-0][image\_desc]The image is a diagram illustrating a layered structure, likely related to telecommunications or networking. It is divided into two main sections, labeled "L1 DL" (Layer 1 Downlink) and "L1 UL" (Layer 1 Uplink). Each section is further subdivided.
The "L1 DL" section has a header row with cells labeled "C2/C4" and "100". Below this, there are two rows representing "L1 Subpool". The first subpool covers the range "0-47", and the second covers "48-95". Beneath the subpool rows are rows with numerical ranges: "00-11", "12-23", "24-35", "36-47", "48-59", "60-71", "72-83", and "84-95".
The "L1 UL" section mirrors the structure of the "L1 DL" section, also with a header row of "C2/C4" and "100", followed by "L1 Subpool" rows for "0-47" and "48-95", and then the same numerical range rows.
To the right of the diagram, there is a legend that associates colored squares with different categories:
- A light green square is labeled "L1 DL Primary subcell".
- A lighter green square is labeled "L1 DL Secondary subcell".
- A yellow square is labeled "cell slot".
- A light blue square is labeled "L1 UL Primary subcell".
- A lighter blue square is labeled "L1 UL Secondary subcell".
The diagram uses a grid-like structure with distinct cells and color-coding to represent different components or states within the L1 DL and L1 UL layers.

| L1 DL | C2/C4 100 | C2/C4 100 | C2/C4 100 | C2/C4 100 | C2/C4 100 | C2/C4 100 | C2/C4 100 | C2/C4 100 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  | L1 Subpool 0-47 | L1 Subpool 48-95 |  |  |  |  |  |  |
|  | 00-11 | 12-23 | 24-35 | 36-47 | 48-59 | 60-71 | 72-83 | 84-95 |
| L1 UL | C2/C4 100 | C2/C4 100 | C2/C4 100 | C2/C4 100 | C2/C4 100 | C2/C4 100 | C2/C4 100 | C2/C4 100 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  | L1 Subpool 0-47 | L1 Subpool 48-95 |  |  |  |  |  |  |
|  | 00-11 | 12-23 | 24-35 | 36-47 | 48-59 | 60-71 | 72-83 | 84-95 |
| Legend: |  |  |  |  |  |  |  |  |
| - L1 DL Primary subcell (light green) |  |  |  |  |  |  |  |  |
| - L1 DL Secondary subcell (lighter green) |  |  |  |  |  |  |  |  |
| - cell slot (yellow) |  |  |  |  |  |  |  |  |
| - L1 UL Primary subcell (light blue) |  |  |  |  |  |  |  |  |
| - L1 UL Secondary subcell (lighter blue)[/image\_desc][image\_path]https://storage.googleapis.com/dng\_files/images/HTML\_pukkola\_5G\_L1\_Entity\_Level\_file\_11950.001.png[/image\_path][/image-0] |  |  |  |  |  |  |  |  |

Loki B (NR FR1 TDD + NR FR1 FDD ): 2*8DL8UL NR FR1 TDD cells with BW up to [Before CB010367-B-UPD001]50MHz[CB010367-B-UPD001]30MHz[End CB010367-B-UPD001]+ [Before CB010367-B-UPD001]4[CB010367-B-UPD001]3[End CB010367-B-UPD001]*4DL4UL NR FR1 FDD cells with BW up to 20MHz

L1 SW shall support concurrent mode NR FR1 TDD eCPRI + NR FR1 FDD CPRI cell set on shared Loki B. There are two L1 pools with total 96 cell slots in the Loki B. For both UL and DL, the first L1 pool is for TDD eCPRI with 48 cell slots, the second L1 pool is for FDD CPRI with 48 cell slots.

- In the DL subpool(both FDD and TDD), maxNumOfDataStreamsPerCell=4, maxNumOfDataLayersPerCell=4.

- In the UL subpool(both FDD and TDD), maxNumOfDataStreamsPerCell=4, maxNumOfDataLayersPerCell=2.

- In the first TDD L1 pool, for the first TDD subcell in subpoolid=0, the FirstCellSlot=0 and cellSlotLength=12.

- In the second FDD L1 pool, for the first FDD subcell in subpoolid=1, the FirstCellSlotId=48 and cellSlotLength=[Before CB010367-B-UPD001]12[CB010367-B-UPD001]16[End CB010367-B-UPD001].

- L1 SW shall support CPRI + eCPRI in the same Loki, support 15Khz scs + 30khz scs in the same Loki. But same FH mode, either CPRI or eCPRI in the same pool; the same numerology, either scs 15Khz or 30Khz in the same pool.

o In the first L1 pool-NR TDD poolID=0(\*) (cell slot from 0~47): NR\_L1\_Loki\_TDD\_FR1\_eCPRI\_IQF\_T1\_only

L1 shall support the L1 instance type NR\_L1\_Loki\_TDD\_FR1\_eCPRI\_IQF\_T1\_only which is defined more details in 5G\_L1\_12369\_replaced([11486379](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fD7xNvvvEe-AqvopbP1qhQ)), 5G\_L1\_12470\_replaced([11486690](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fD8_YPvvEe-AqvopbP1qhQ)) & 5G\_L1\_12471\_replaced([11486726](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fD9mY_vvEe-AqvopbP1qhQ)).

- Only one L1 subpool(FrequencyRange=FR1) supported with 48 cell slots in DL/UL.

- For DL/UL, In the L1 pool, L1 SW shall support to configure 4\*C2(only for Primary subcell)/C4 subcells(BW up to 100MHz) with DL PRB pooling enabled, each subcell consumes 12 cell slots.

[CB010367-B] In this L1 instance type, for configuration 4\*C4 subcells in DL/UL, the BW of each C4 subcell is limited to configure max  [Before CB010367-B-UPD001]50MHz[CB010367-B-UPD001]30MHz[End CB010367-B-UPD001]

MHz at system level. [End CB010367-B]

o In the Second L1 pool-NR FDD FR1 poolID=1(\*) (cell slot from 48~95): NR\_L1\_Loki\_FDD\_FR1\_CPRI\_T2\_only

L1 shall support the L1 instance type NR\_L1\_Loki\_FDD\_FR1\_CPRI\_T2\_only with DL/UL PRB pooling enabled and flexibleCAmode =3, which is defined more details in 5G\_L1\_12372\_replaced([11486496](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fD8YSfvvEe-AqvopbP1qhQ)) & 5G\_L1\_12458\_replaced([11486635](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fD8_W_vvEe-AqvopbP1qhQ)).

- Only one L1 subpool(FrequencyRange=FR1\_NB) supported with 48 cell slots in DL/UL.

- For DL in the L1 pool, L1 SW shall support to configure [Before CB010367-B-UPD001]4[CB010367-B-UPD001]3[End CB010367-B-UPD001]\*A1/A2/A4 subcells(BW up to 20MHz), each subcell consumes [Before CB010367-B-UPD001]12[CB010367-B-UPD001]16[End CB010367-B-UPD001] cell slots.

- For UL in the L1 pool, L1 SW shall support to configure [Before CB010367-B-UPD001]4[CB010367-B-UPD001]3[End CB010367-B-UPD001]\*A2/A4 subcells(BW up to 20MHz), each subcell consumes [Before CB010367-B-UPD001]12[CB010367-B-UPD001]16[End CB010367-B-UPD001] cell slots.

- Different Subcell types(A1(only for DL)/A2/A4) can be mixed in the same L1 pool.

- Different subcell BW(5/10/15/20 MHz) can be mixed in the same L1 pool.

- Mixed cell type and mixed BW can happen at the same time in the same L1 pool.

Note:  (\*): PoolID=0/1 is for a configuration example, it can be any U32 value but unique per gNB/eNB/SBTS.

[xlsx\_desc]--- Sheet1 ---
C2/C4\n100 C4\n100 C2/C4\n100 C4\n100 An\n20 An\n20 An\n20 UL
subpoolId=0 (0-47) \nFrequencyRange = FR1 NaN NaN NaN subpoolId=1 (48-95) \nFrequencyRange = FR1\_NB NaN NaN L1 subpool
poolID=0(0-47) for TDD pool NR\_L1\_Loki\_TDD\_FR1\_eCPRI\_IQF\_T1\_only NaN NaN NaN poolID=1(48-95) for FDD pool NR\_L1\_Loki\_FDD\_FR1\_CPRI\_T2\_only NaN NaN L1 pool
0-11 12-23 24-35 36-47 48-63 64-79 80-95 Cell slot
NaN NaN NaN NaN NaN NaN NaN NaN
C2/C4\n100 DL/UL Primary subcell for NR TDD NaN NaN An\n20 A2/A4 subcell in DL for NR FDD NaN NaN
C2/C4\n100 NaN NaN NaN An\n20 A2/A4 subcell in UL for NR FDD NaN NaN
NaN NaN NaN NaN NaN NaN NaN NaN
C4\n100 DL/UL Secondary subcell for NR TDD NaN NaN NaN NaN NaN NaN
C4\n100 NaN NaN NaN NaN NaN NaN NaN[/xlsx\_desc][xlsx\_path]https://storage.googleapis.com/dng\_files/attachments/pukkola\_5G\_L1\_Entity\_Level\_file11950\_1.xlsx[/xlsx\_path]

Configuration example(1)+(2)+(3) on full ASOE:

(1) 3\*8DL8UL NR TDD Cells(Max BW=100MHz) in non-shared Loki-A

(2) 3*8DL8UL NR FR1 TDD cells(Max BW=[Before CB010367-B-UPD001]50MHz[CB010367-B-UPD001]30MHz[End CB010367-B-UPD001]): 1*8DL8UL NR FR1 TDD cell(Max BW=[Before CB010367-B-UPD001]50MHz[CB010367-B-UPD001]30MHz[End CB010367-B-UPD001]) in non-shared Loki A + 2\*8DL8UL NR FR1 TDD cells(Max BW=[Before CB010367-B-UPD001]50MHz[CB010367-B-UPD001]30MHz[End CB010367-B-UPD001]) in shared Loki B

(3) [Before CB010367-B-UPD001]4[CB010367-B-UPD001]3[End CB010367-B-UPD001]\*4DL4UL NR FR1 FDD cells(Max BW=20MHz) in shared Loki B

[image-1][image\_desc]The image displays a diagram illustrating the allocation of L1 subcells for two different configurations, "Loki A" and "Loki B". Each configuration is further divided into TDD cells and FDD cells, with specific subcell types indicated by colored boxes and labels. A legend on the right explains the meaning of these colored boxes and labels.
**Loki A Configuration:**
This configuration is divided into four TDD cells.
\* **TDD cell 1:** Contains two "C4 L1 TDD DL Primary subcell" blocks.
\* **TDD cell 2:** Contains two "C4 L1 TDD DL Secondary subcell" blocks.
\* **TDD cell 3:** Contains two "C4 L1 TDD UL Primary subcell" blocks.
\* **TDD cell 4:** Contains two "C4 L1 TDD UL Secondary subcell" blocks.
Below the TDD cells, there are two sections labeled "L1 SP" (L1 Subpools) and "L1 Pools". The first section is described as "Loki Symm DL L1 Pool NR TDD FR1 (CPRI)", and the second as "Loki Symm UL L1 Pool NR TDD FR1 (Ecpri)".
**Loki B Configuration:**
This configuration is divided into two TDD cells and three FDD cells.
\* **TDD cell 5:** Contains two "C4 L1 TDD DL Primary subcell" blocks and two "C4 L1 TDD DL Secondary subcell" blocks.
\* **TDD cell 6:** Contains two "C4 L1 TDD UL Primary subcell" blocks and two "C4 L1 TDD UL Secondary subcell" blocks.
\* **3 FDD Cells:** Contains four "A4 L1 FDD DL subcell" blocks and four "A4 L1 FDD UL subcell" blocks.
Below the TDD and FDD cells, there are two sections labeled "L1 SP" (L1 Subpools) and "L1 Pools". The first section is described as "Half Loki L1 pool NR TDD FR1 CPRI", and the second as "Half Loki L1 pool NR FDD FR1 CPRI".
**Legend:**
\* **Yellow box with C4:** L1 TDD DL Primary subcell
\* **Light yellow box with C4:** L1 TDD DL Secondary subcell
\* **Blue box with C4:** L1 TDD UL Primary subcell
\* **Light blue box with C4:** L1 TDD UL Secondary subcell
\* **Yellow box with A4:** L1 FDD DL subcell
\* **Blue box with A4:** L1 FDD UL subcell
The diagram uses a grid-like structure to visually represent the allocation of these subcells across different cells and pools.[/image\_desc][image\_path]https://storage.googleapis.com/dng\_files/images/HTML\_pukkola\_5G\_L1\_Entity\_Level\_file\_11950.003.png[/image\_path][/image-1]

[image-2][image\_desc]The image contains a table with six columns: "CELL No.", "Cell BW", "L1 instance", "nrCellType", "subcell composition DL", and "subcell composition UL". The table has eight rows, including the header row.
Here is the content of the table:

| CELL No. | Cell BW | L1 instance | nrCellType | subcell composition DL | subcell composition UL |
| --- | --- | --- | --- | --- | --- |
| TDD Cell 1 | 100 MHz | Loki A | 8DL 8UL | C4 C4 | C4 C4 |
| TDD Cell 2 | 100 MHz | Loki A | 8DL 8UL | C4 C4 | C4 C4 |
| TDD Cell 3 | 100 MHz | Loki A | 8DL 8UL | C4 C4 | C4 C4 |
| TDD Cell 4 | 30 MHz | Loki A | 8DL 8UL | C4 C4 | C4 C4 |
| TDD Cell 5 | 30 MHz | Loki B | 8DL 8UL | C4 C4 | C4 C4 |
| TDD Cell 6 | 30 MHz | Loki B | 8DL 8UL | C4 C4 | C4 C4 |
| 3 FDD Cells | 20 MHz | Loki B | 4DL4UL | A4 A4 A4 | A4 A4 A4 |

---

###### 13.1.1.10.0-20 Full board tests Thor (ID: 11489226)

###### 13.1.1.10.0-20.1 NR FR1 TDD NR FR1 TDD NR FR1 TDD (ID: 11489236)

###### 13.1.1.10.0-20.1-1 NR FR1 TDD NR FDD + LTE FDD (ID: 11489475)

**13.1.1.10.0-20.1-2.0-4**  (ID: `11489521`)

NR FR1 TDD
11489521:
NR FR1 TDD
11489521:
NR FR1 TDD
11489521:
NR FR1 TDD
11489521:
NR FR1 TDD
11489521:
NR FR1 TDD
11489521:
NR FR1 TDD
11489521:
NR FR1 TDD
11489521:
NR FR1 TDD
11489521:
NR FR1 TDD
11489521:
NR FR1 TDD
11489521:
NR FR1 TDD
11489521:
NR FR1 TDD
11489521:
NR FR1 TDD
11489521:
NR FR1 TDD
11489521:
NR FR1 TDD
11489521:
NR FR1 TDD
11489521:
NR FR1 TDD
11489521:
NR FR1 TDD
11489521:
NR FR1 TDD
11489521:
NR FR1 TDD
L1 SW shall support concurrent mode NR FR1 TDD eCPRI BB cell set(CB010713 BB cell set B) + LTE FDD CPRI  BB cell set (CB009015 BB set B) on Thor:

Cell Configuration: Up to 3x8DL8UL NR TDD 100MHz cells with 8RX/4RX IRC receiver(CB010713 BB cell set B)

+ up to 12x4T4R 20MHz LTE FDD cells(CB009015 BB cell set B)

Note:  8UL\* means 1xC8 Primary subcell or 2xC4(1xC4 Primary subcell + 1xC4 Secondary subcell)

Configuration example as below: The details CSM deployment of this concurrent mode refer to BTSC\_L1\_Req\_10399\_replaced([11584630](https://dn-prod.ext.net.nokia.com/rm/resources/BI_BPeyifwGEe-AqvopbP1qhQ)).

[image-0][image\_desc]The image is a diagram illustrating the configuration of Half ABIP NR TDD and Half ABIP LTE FDD, identified as (24R1 CB010713-F).
The diagram is structured into two main sections, corresponding to two different cell sets:
**CB010713 BB cell set B: cell 1~cell 3**
This section describes the Half ABIP NR TDD configuration, supporting up to 3 NR TDD cells with 8DL (Downlink) and 4UL (Uplink) Layers, and 8RX/4RX mixed streams.
**CB009015 BB cell set B: 12 cells**
This section describes the Half ABIP LTE FDD configuration, supporting up to 12 cells with 20 MHz bandwidth and 4T4R (Transmit/Receive antenna configuration).
The right side of the diagram labels rows as "cell 1", "cell 2", "cell 3", and a combined "Subpools Pools" section with a further breakdown of "12 cells".
The main body of the diagram is a grid representing resource allocation. The top rows show different sub-blocks labeled "GC8", "C4", and "C8", indicating different resource units or configurations. Below these, there are rows labeled "L2 SP" and "L1 SP", representing different protocol layers.
The bottom section of the grid shows the actual cell configurations:
\* A green block labeled "LTE 12 cells 20 MHz 4T4R" spans across the "cell 1", "cell 2", and "cell 3" rows in the lower left.
\* A yellow block labeled "(LTE 12 cells 20 MHz 4T)" is positioned to the right of the green block, spanning across the "cell 1" and "cell 2" rows.
\* A blue block labeled "(LTE 12cells 20 MHz 4R)" is positioned to the right of the yellow block, spanning across the "cell 1" and "cell 2" rows.
The bottom-most row of the grid contains labels for the pools:
\* "L2 Pool NR TDD FR1 3SP"
\* "Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2)"
\* "Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2)"
\* "Thor DL L1 Pool LTE FDD"
\* "Thor UL L1 Pool LTE FDD"
The diagram visually represents how different types of cells (NR TDD and LTE FDD) and their associated resources are allocated and managed within the ABIP system.[/image\_desc][image\_path]https://storage.googleapis.com/dng\_files/images/HTML\_pukkola\_5G\_L1\_Entity\_Level\_file\_11979.001.png[/image\_path][/image-0]

---

**13.1.1.10.0-20.1-3.0-3**  (ID: `11489579`)

NR FR1 TDD
11489579:
NR FR1 TDD
11489579:
NR FR1 TDD
11489579:
NR FR1 TDD
11489579:
NR FR1 TDD
11489579:
NR FR1 TDD
11489579:
NR FR1 TDD
11489579:
NR FR1 TDD
11489579:
NR FR1 TDD
11489579:
NR FR1 TDD
11489579:
NR FR1 TDD
11489579:
NR FR1 TDD
11489579:
NR FR1 TDD
11489579:
NR FR1 TDD
11489579:
NR FR1 TDD
11489579:
NR FR1 TDD
11489579:
NR FR1 TDD
11489579:
NR FR1 TDD
11489579:
NR FR1 TDD
11489579:
NR FR1 TDD
11489579:
NR FR1 TDD
L1 SW shall support concurrent mode NR FR1 FDD CPRI  BB cell set (CB009014 BB cell set B) + NR FR1 TDD eCPRI BB cell set(CB010713 BB cell set B) on Thor:

Cell Configuration: Up to 6x4DL4UL NR FDD 40MHz cells(CB009014 BB cell set B)

+ Up to 3x8DL8UL NR TDD 100MHz cells with 8RX/4RX IRC receiver(CB010713 BB cell set B)

Note:  8UL\* means 1xC8 Primary subcell or 2xC4(1xC4 Primary subcell + 1xC4 Secondary subcell)

Configuration example as below:

[image-0][image\_desc]The image displays a diagram illustrating the configuration of NR FDD and NR TDD cells on a Half ABIP platform. The diagram is divided into two main sections, each corresponding to a different cell set: CB009014 BB cell set B and CB010713 BB cell set B.
The top section, "Up to 12 NR FDD cells 4DL4UL on Half ABIP and Up to 3 NR TDD cells 8DL 4UL Layers 8UL Streams 8RX/4RX mixed on Half ABIP (24R1 CB010713-E)", presents a detailed breakdown of resource allocation. It features a grid with columns representing different types of radio units (GAn 40, An 40) and rows indicating different layers or pools (L2 SP, L1 SP). Within this grid, colored blocks (green for GC8, yellow for C4, blue for C8) denote the allocation of specific resources for NR FDD and NR TDD cells. The right side of this section labels the rows as "6 cells", "Subpools", "Pools", "cell 1", "cell 2", and "cell 3".
The bottom section, "CB010713 BB cell set B: cell 1~cell 3 Up to 3 NR TDD cells 8DL 4UL Layers 8UL Streams 8RX/4RX mixed on Half ABIP", provides a textual description of the capabilities for NR TDD cells. It specifies that for 8UL Streams, the system supports either 1xC8 (for cells 1-2) or 2xC4 (for cell 3), with the choice depending on the receiver type (8RX or 4RX).
The table within the top section can be represented as follows:

| Category | GAn 40 | GAn 40 | GAn 40 | GAn 40 | GAn 40 | GAn 40 | An 40 | An 40 | An 40 | An 40 | An 40 | An 40 | An 40 | An 40 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| L2 SP | L2 SP | L2 SP | L2 SP | L2 SP | L2 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP |  |
| **Resource Allocation** | **L2 Pool NR FDD 6SP** |  |  |  |  | **Thor DL L1 Pool NR FDD 2SP** |  |  |  |  | **Thor UL L1 Pool NR FDD 2SP** |  |  |  |
|  | GC8 |  |  |  |  | C4 | C4 |  |  | C8 |  |  |  |  |
|  |  | GC8 |  |  |  | C4 | C4 |  |  | C8 |  |  |  |  |
|  |  |  | GC8 |  |  |  |  | C4 | C4 |  |  |  |  |  |
| L2 SP | L2 SP | L2 SP | L2 SP | L2 SP | L2 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP |  |
| **Resource Allocation** | **L2 Pool NR TDD FR1 3SP** |  |  |  |  | **Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2)** |  |  |  |  | **Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2)** |  |  |  |
| The right-hand side labels are: |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| 6 cells |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Subpools |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Pools |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| cell 1 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| cell 2 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| cell 3 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Subpools |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Pools[/image\_desc][image\_path]https://storage.googleapis.com/dng\_files/images/HTML\_pukkola\_5G\_L1\_Entity\_Level\_file\_11983.001.png[/image\_path][/image-0] |  |  |  |  |  |  |  |  |  |  |  |  |  |  |

L1 SW shall support the L1 Instance type  L1\_Thor\_FR1 with the following L1 pool list:

L1 pool #0 (cell slot 0~95): L1 pool type "NR\_L1Pool\_Thor\_FDD\_FR1\_CPRI", The details of this L1 pool type are defined in 5G\_L1\_11161\_replaced([11486909](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fD-NfvvvEe-AqvopbP1qhQ)) of CB009014 BB set type B in Half ABIP.

L1 pool #1 (cell slot 96~191):  L1 pool type "NR\_L1Pool\_Thor\_TDD\_FR1\_eCPRI", The details of this L1 pool type are defined in 5G\_L1\_13044\_replaced([11489257](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo0PvvEe-AqvopbP1qhQ)) & 5G\_L1\_13058\_replaced([11489295](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo0_vvEe-AqvopbP1qhQ)) of CB010713 BB set type B in Half ABIP.

DL:

L1 pool #0 for NR FDD:

- Up to 6xA4 subcells in L1 pool, each A4 subcell with BW up to 40MHz consumes 16 cell slots.

- For each L1 subpool, frequencyRange = FR1, maxNumOfDataStreamsPerCell =4, maxNumOfDataLayersPerCell =4, PRB pooling default enabled though L1 SW DL internal Prbpooling parameter

- The following red box is configured for above Configuration Example: NR FR1 FDD 6 A4 cells with up to 40MHz.

L1 pool #1 for NR TDD:

- Up to 12xC4 subcells(up to 6xC4 Primary subcells+ up to 6xC4 Secondary subcells) in L1 pool, each C4 subcell with BW up to 100MHz consumes 8 cell slots. The frequencyRange = FR1 in each L1 subpool, maxNumOfDataStreamsPerCell =4, maxNumOfDataLayersPerCell =4, PRB pooling default enabled through L1 SW DL internal Prbpooling parameter.

- The following 3 red boxes are configured for above Configuration Example cell1~cell3(3x8DL(2xC4) subcells). The cellslot index(128~143) of L1 subpool#2 and cellslot index(160~191) of L1 subpool #3 are not used in any DL subcell.

[image-1][image\_desc]The image contains a table with data related to cellular network configurations. The table has several rows and columns, with headers and data cells.
The top row appears to be a header row indicating different subcell types and bandwidths (SubCells/BW). The subsequent rows detail cell slots, initial stream PRB, initial layer PRB, L1 subpools, and L1 pool.
The columns are segmented by numerical ranges, likely representing carrier frequencies or resource blocks. Some cells contain numerical values like "1296" and "2184", possibly indicating PRB counts or capacities. Other cells contain text labels such as "L1 SP #0 (0-47 cs)", "NR\_L1Pool\_Thor\_FDD\_FR1\_CPRI L1 pool #0 for NR FR1 FDD", and descriptions for DL primary and secondary subcells.
The table uses different background colors (yellow, grey, white) and borders to distinguish different sections and data points. Some cells are highlighted with red borders.
Here is the table represented in markdown:

| SubCells/BW | A4 40 | A4 40 | A4 40 | A4 40 | A4 40 | A4 40 | C4 100 | C4 100 | C4 100 | C4 100 | C4 100 | C4 100 | C4 100 | C4 100 | C4 100 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Cell slots | 0-15 | 16-31 | 32-47 | 48-63 | 64-79 | 80-95 | 96-103 | 104-111 | 112-119 | 120-127 | 128-135 | 136-143 | 144-151 | 152-159 | 160-167 |
| Initial Stream PRB |  |  |  |  |  |  | 1296 | 2184 | 2184 | 2184 | 2184 | 2184 | 2184 | 2184 | 2184 |
| Initial Layer PRB |  |  |  |  |  |  | 1296 | 2184 | 2184 | 2184 | 2184 | 2184 | 2184 | 2184 | 2184 |
| L1 Subpools | L1 SP #0 (0-47 cs) | L1 SP #1 (48-95 cs) | L1 SP #2 (96-143 cs) | L1 SP #3 (144-191 cs) |  |  |  |  |  |  |  |  |  |  |  |
| L1 Pool | NR\_L1Pool\_Thor\_FDD\_FR1\_CPRI L1 pool #0 for NR FR1 FDD | NR\_L1Pool\_Thor\_TDD\_FR1\_eCPRI L1 pool #1 for NR FR1 TDD |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | C4 100 DL Primary subcell for NR FR1 TDD |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  | C4 100 DL Secondary subcell for NR FR1 TDD |  |  |  |  |  |  |  |  |

UL:

L1 pool #0 for NR FDD:

- Up to 6xA4 subcells in L1 pool, each A4 subcell with BW up to 40MHz consumes 16 cell slots.

- For each L1 subpool, frequencyRange = FR1, maxNumOfDataStreamsPerCell =4, maxNumOfDataLayersPerCell =2, PRB pooling enabled through L1 SW DL internal Prbpooling parameter.

- The following red box is configured for above Configuration Example: NR FR1 FDD 6 A4 cells with up to 40MHz.

L1 pool #1 for NR TDD:

- Up to 3xC8 or 6xC4 subcells in L1 pool, the mixed C8 with C4 subcell(s) rule refers to 5G\_L1\_13058\_replaced([11489295](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo0_vvEe-AqvopbP1qhQ))(Note: ensure at least one C8 subcell). Each C8 subcell with BW up to 100MHz consumes 24 Cell slot, Each C4 subcell with BW up to 100 MHz consumes 12 Cell slot.

- For each L1 subpool, frequencyRange = FR1, maxNumOfDataStreamsPerCell =8, maxNumOfDataLayersPerCell =4, isPRBpoolingEnabled = true.

- The following 3 red boxes are configured for above Configuration Example cell1~cell3(2xC8 subcells+ 1x8UL(2xC4) subcells). The cellslot index(168~191) of L1 subpool#3 is not used in any UL subcell.

[image-2][image\_desc]The image contains a table with information about cell slots, initial stream PRB, initial layer PRB, L1 subpools, and L1 pool. The table has several columns and rows, with data organized into different sections.
Here's a markdown representation of the table:

| Header | A4 40 | A4 40 | A4 40 | A4 40 | A4 40 | A4 40 | C4 100 | C4 100 | C4 100 | C4 100 | Not used | Not used | SubCells/BW |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  | C8 100 | C8 100 | C8 100 |  |  |  |  |
| 0-15 | 16-31 | 32-47 | 48-63 | 64-79 | 80-95 | 96-107 | 108-119 | 120-131 | 132-143 | 144-155 | 156-167 | 168-179 | 180-191 |
|  | 1296 |  |  | 1296 |  | 1638 | 119 | 131 | 143 | 155 | 167 | 1638 | 819 |
|  | 648 |  |  | 648 |  | 819 | 100 | 100 | 100 | 100 | 100 | 819 | Initial Layer PRB |
| L1 SP #0 (0-47 cs) | L1 SP #1 (48-95 cs) | L1 SP #2 (96-143 cs) | L1 SP #3 (144-191 cs) |  |  |  |  |  |  |  |  |  | L1 Subpools |
| NR\_L1Pool\_Thor\_FDD\_FR1\_CPRI L1 pool #0 for NR FR1 FDD | NR\_L1Pool\_Thor\_TDD\_FR1\_eCPRI L1 pool #1 for NR FR1 TDD |  |  |  |  |  |  |  |  |  |  |  | L1 Pool |
|  |  |  |  |  |  | C4 100 |  |  |  |  |  |  | UL Primary subcell for NR FR1 TDD |
|  |  |  |  |  |  | C4 100 |  |  |  |  |  |  | UL Secondary subcell for NR FR1 TDD |

---

**13.1.1.10.0-20.1-4.0-2**  (ID: `11489622`)

NR FR1 TDD
11489622:
NR FR1 TDD
11489622:
NR FR1 TDD
11489622:
NR FR1 TDD
11489622:
NR FR1 TDD
11489622:
NR FR1 TDD
11489622:
NR FR1 TDD
11489622:
NR FR1 TDD
11489622:
NR FR1 TDD
11489622:
NR FR1 TDD
11489622:
NR FR1 TDD
11489622:
NR FR1 TDD
11489622:
NR FR1 TDD
11489622:
NR FR1 TDD
11489622:
NR FR1 TDD
11489622:
NR FR1 TDD
11489622:
NR FR1 TDD
11489622:
NR FR1 TDD
11489622:
NR FR1 TDD
11489622:
NR FR1 TDD
11489622:
NR FR1 TDD
L1 SW shall support mixing of same L1 pool types with different CSM deployments on Thor:NR FR1 TDD eCPRI BB cell set(CB010713 BB cell set B) + NR FR1 TDD eCPRI  BB cell set (CB009142 BB cell set B)
 
Cell Configuration: Up to 3x8DL8UL 100MHz cells with 8RX IRC receiver(CB010713 BB cell set B)
                            + up to 1x4D4UL 100MHz Supercell(1) with up to 3 subcells(CB009142 BB cell set B)
 
Note:  8UL\* means 1xC8 Primary subcell
        Supercell (1): The detailed supercell mode refers to 5G\_UP\_5471.
Configuration example as below:
 [image-0][image\_desc]The image displays a diagram illustrating the configuration of cells, layers, streams, and supercells within a receiver system, likely for telecommunications. The diagram is organized into two main sections: a textual description on the left and a visual representation of the system's structure on the right.
The textual section provides details about different cell sets and their capabilities. It mentions "Up to 3 cells 8DL 4UL Layers 8UL Streams 8RX receiver on Half ABIP and up to 1 4D4UL supercell with up to 3 subcells on Half ABIP (24R1 CB010713 -D)". It then breaks down configurations for "CB010713 BB cell set B: cell 1~cell 3" and "CB009142 BB cell set B: cell 4". For the first cell set, it specifies "Up to 3 cells 8DL 4UL Layers 8UL Streams 8RX Receiver on Half ABIP" and notes that "In case of 8UL Streams, support either 1xC8 (cells 1...3 in the example) with the receiver type is 8RX." For the second cell set, it states "up to 1 4DL4UL supercell with up to 3SSBs on Half ABIP".
The visual section is a table-like structure that maps these configurations across different "cells" (cell 1, cell 2, cell 3, cell 4) and "Subpools Pools". The table uses colored blocks to represent different types of resource allocations or functionalities.
Here's a breakdown of the table content:

| Row/Column | Cell 1 | Cell 2 | Cell 3 | Cell 4 | Subpools Pools |
| --- | --- | --- | --- | --- | --- |
| **Top Section (GC8, C4, C8)** | GC8 | GC8 | C8 | C8 | cell 1 |
|  |  |  |  | C8 | cell 2 |
|  |  |  |  | C8 | cell 3 |
| **Middle Section (L2 SP, L1 SP)** | L2 SP |  |  |  |  |
| L2 Pool NR TDD FR1 3SP | L2 SP |  |  |  |  |
| L2 Pool NR TDD FR1 3SP | L1 SP |  |  |  |  |
| Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2) | L1 SP |  |  |  |  |
| Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) | Subpools |  |  |  |  |
| Pools |  |  |  |  |  |
| **Bottom Section (GC4, C4, L1 SP)** | GC4 | C4 |  |  |  |
| L2 SP |  |  |  |  |  |
| L2 Pool NR TDD FR1 3SP | C4 |  |  |  |  |
| L1 SP |  |  |  |  |  |
| Thor DL L1 Pool NR TDD FR1 | C4 |  |  |  |  |
| L1 SP |  |  |  |  |  |
| Thor UL L1 Pool NR TDD FR1 Asymmetric PRBS | cell 4 |  |  |  |  |
|  |  | C4 | C4 |  | Subpools |
| Pools |  |  |  |  |  |
| The colored blocks within the table represent: |  |  |  |  |  |
| \* **Green blocks (GC8, GC4):** Likely represent some form of control or group allocation. |  |  |  |  |  |
| \* **Yellow blocks (C4):** Indicate a specific type of resource or configuration, possibly related to bandwidth or capacity. |  |  |  |  |  |
| \* **Blue blocks (C8):** Similar to yellow blocks, but representing a different configuration, potentially higher capacity. |  |  |  |  |  |
| \* **Gray blocks (L2 SP, L1 SP):** Denote different processing layers or pools. The text within these blocks specifies the exact type of pool and its associated parameters (e.g., "Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2)"). |  |  |  |  |  |
| The diagram visually correlates the textual descriptions of cell sets and their capabilities with the specific resource allocations shown in the table.[/image\_desc][image\_path]https://storage.googleapis.com/dng\_files/images/HTML\_pukkola\_5G\_L1\_Entity\_Level\_file\_11986.001.png[/image\_path][/image-0] |  |  |  |  |  |
| L1 SW shall support the  L1 Instance type  L1\_Thor\_FR1 with the following L1 pool list: |  |  |  |  |  |
| L1 pool #0 (cell slot 0~95):  L1 pool type "NR\_L1Pool\_Thor\_TDD\_FR1\_eCPRI", The details of this L1 pool type are defined in 5G\_L1\_13044\_replaced([11489257](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo0PvvEe-AqvopbP1qhQ)) & 5G\_L1\_13058\_replaced([11489295](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo0_vvEe-AqvopbP1qhQ)) of CB010713 BB set type B in Half ABIP; |  |  |  |  |  |
| L1 pool #1 (cell slot 96~191):  L1 pool type "NR\_L1Pool\_Thor\_TDD\_FR1\_eCPRI", which defined in CB009142-B(supercell), for DL & UL, the details as below: |  |  |  |  |  |
| - L1 SW shall provide the support of one supercell with up to 3 subcells. |  |  |  |  |  |
| - Each subcell shall be primary subcell with BW up to 100MHz C2/C4 in DL and UL without Beamforming refer to 5G\_UP\_6025, DL/UL PRB pooling not supported. |  |  |  |  |  |
| - Each DL/UL subcell consume 24 cell slots, in total 3 primary subcells consume 72 cell slots, the last 24 cell slots of this L1 pool are not used to any subcell. |  |  |  |  |  |
| - All sub-cells of a supercell must be same type and the same bandwidth. |  |  |  |  |  |
| - Each subcell with nrCellType 2DL-2UL/4DL-4UL without beamforming shall be supported. |  |  |  |  |  |
|  |  |  |  |  |  |
| DL: |  |  |  |  |  |
| L1 pool #0: |  |  |  |  |  |
| - Up to 12xC4 subcells(up to 6xC4 Primary subcells+ up to 6xC4 Secondary subcells) in L1 pool, each C4 subcell with BW up to 100MHz consumes 8 cell slots. |  |  |  |  |  |
| - For each L1 subpool, frequencyRange = FR1, maxNumOfDataStreamsPerCell =4, maxNumOfDataLayersPerCell =4, PRB pooling default enabled through L1 SW DL internal Prbpooling parameter. |  |  |  |  |  |
| - The following 3 red boxes are configured for above Configuration Example cell1~cell3(3x8DL(2xC4) subcells). The cellslot index(32~47) of L1 subpool#0 and cellslot index(64~95) of L1 subpool #1 are not used in any DL subcell. |  |  |  |  |  |
| L1 pool #1: |  |  |  |  |  |
| - Up to 3xC4 Primary subcells in L1 pool, each C4 subcell with BW up to 100 MHz consumes 24 cell slots. |  |  |  |  |  |
| - For each L1 subpool, frequencyRange = FR1, maxNumOfDataStreamsPerCell =4, maxNumOfDataLayersPerCell =4, PRB pooling disabled though L1 SW DL internal Prbpooling parameter. |  |  |  |  |  |
| - The following one red box is configured for above Configuration Example cell4(1 supercell with 3xC4 primary subcells). |  |  |  |  |  |
| [image-1][image\_desc]The image is a screenshot of a spreadsheet or a similar grid-based document, likely related to telecommunications or network configuration. It displays a table with several rows and columns, detailing different configurations or parameters. |  |  |  |  |  |
| The top row contains headers like "C4 100" and "Not used", with the last column labeled "SubCells/ BW". Below this, there are numerical ranges like "0-7", "8-15", etc., up to "168-191". |  |  |  |  |  |
| The subsequent rows provide specific details: |  |  |  |  |  |
| - "Cell slots" |  |  |  |  |  |
| - "Initial Stream PRB" |  |  |  |  |  |
| - "Initial Layer PRB" |  |  |  |  |  |
| - "L1 Subpools" |  |  |  |  |  |
| - "L1 Pool" |  |  |  |  |  |
| The table is divided into sections, with some cells containing numerical values like "2184" or "NA". Other cells describe "L1 SP" (likely Layer 1 Sub-pool) with associated slot ranges and counts, such as "L1 SP #0 (0-47 cs)" and "48 cell slots". There are also entries for "NR\_L1Pool\_Thor\_TDD\_FR1\_eCPRI L1 pool #0" and "#1". |  |  |  |  |  |
| The bottom part of the visible table shows entries like "C4 100 DL Primary subcell for NR TDD" and "C4 100 DL Secondary subcell for NR TDD". |  |  |  |  |  |
| Some cells in the top row are highlighted with red or yellow borders, possibly indicating specific configurations or areas of interest. The "Not used" cell is highlighted in green. |  |  |  |  |  |
| Here is the table represented in markdown: |  |  |  |  |  |

|  | C4 100 | C4 100 | C4 100 | C4 100 | C4 100 | C4 100 | C4 100 | C4 100 | C4 100 | C4 100 | C4 100 | C4 100 | C4 100 | C4 100 | Not used | SubCells/ BW |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| UL: |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| L1 pool #0: |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| - Up to 3xC8 or 6xC4 subcells in L1 pool, the mixed C8 with C4 subcell(s) rule refers to 5G\_L1\_13058\_replaced([11489295](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo0_vvEe-AqvopbP1qhQ))(Note: ensure at least one C8 subcell). Each C8 subcell with BW up to 100MHz consumes 24 Cell slot, Each C4 subcell with BW up to 100 MHz consumes 12 Cell slot. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| - For each L1 subpool, frequencyRange = FR1, maxNumOfDataStreamsPerCell =8, maxNumOfDataLayersPerCell =4, isPRBpoolingEnabled = true. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| - The following 3 red boxes are configured for Configuration Example cell1~cell3(2xC8 subcells+ 1x8UL(2xC4) subcells). The cellslot index(72~95) of L1 subpool#1 is not used in any UL subcell. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| L1 pool #1: |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| - Up to 3xC4 Primary subcells in L1 pool, each C4 subcell with BW up to 100 MHz consumes 24 cell slots. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| - For each L1 subpool, frequencyRange = FR1, maxNumOfDataStreamsPerCell =4, maxNumOfDataLayersPerCell =4, isPRBpoolingEnabled = false. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| - The following one red box is configured for above Configuration Example cell4(1 supercell with 3xC4 primary subcells). |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| [image-2][image\_desc]The image contains a table with information about cell configurations and resource allocation. The table has several rows and columns, with headers and data cells. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| Here's a breakdown of the table content: |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| **Header Row 1:** This row seems to define different cell types or configurations. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* C4 100 (repeated multiple times) |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* C8 100 (repeated multiple times) |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* Not used (repeated multiple times) |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| **Header Row 2:** This row defines time slot ranges. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* 0-11 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* 12-23 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* 24-35 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* 36-47 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* 48-59 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* 60-71 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* 72-83 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* 84-95 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* 96-119 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* 120-143 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* 144-167 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* 168-191 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| **Data Rows:** |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* **Row 1 (under time slots):** Contains numerical values and "NA". |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* 1638 (under 0-11 and 48-59) |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* NA (under 96-119, 120-143, 144-167, 168-191) |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* **Row 2 (under time slots):** Contains numerical values and "NA". |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* 819 (under 12-23 and 60-71) |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* NA (under 96-119, 120-143, 144-167, 168-191) |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* **Row 3 (under time slots):** Describes L1 Subpools with slot ranges. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* L1 SP #0 (0-47 cs) |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* 48 cell slots |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* L1 SP #1 (48-95 cs) |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* 48 cell slots |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* L1 SP #2 (96-143 cs) |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* 48 cell slots |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* L1 SP #3 (144-191 cs) |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* 48 cell slots |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* **Row 4 (under time slots):** Defines L1 Pools. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* NR\_L1Pool\_Thor\_TDD\_FR1\_eCPRI L1 pool #0 (under 0-71) |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* NR\_L1Pool\_Thor\_TDD\_FR1\_eCPRI L1 pool #1 (under 96-191) |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| **Rightmost Column Headers:** |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* SubCells |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* Cell slots |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* Initial Stream PRB |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* Initial Layer PRB |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* L1 Subpools |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* L1 Pool |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| **Bottom Section:** |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* C4 100: UL Primary subcell for NR TDD |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| \* C4 100: UL Secondary subcell for NR TDD |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| The table visually represents a mapping of cell configurations (C4, C8) and their associated resource allocations (slots, PRBs) across different time intervals and L1 pools. Some sections are marked as "Not used" or have "NA" values, indicating they are not utilized in this configuration. The red borders highlight specific cell configurations. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| ```markdown |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |

| Cell Configuration | 0-11 | 12-23 | 24-35 | 36-47 | 48-59 | 60-71 | 72-83 | 84-95 | 96-119 | 120-143 | 144-167 | 168-191 | SubCells | Cell slots | Initial Stream PRB | Initial Layer PRB | L1 Subpools | L1 Pool |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| C4 100 | C4 100 | C4 100 | C4 100 | C4 100 | C4 100 | C4 100 | Not used | Not used | C4 100 | C4 100 | C4 100 | Not used |  |  |  |  |  |  |
| C8 100 | C8 100 | C8 100 | C8 100 |  |  |  | Not used |  |  |  |  |  |  |  |  |  |  |  |
|  | 1638 |  |  |  | 1638 |  |  |  | NA | NA | NA | NA |  |  |  |  |  |  |
|  |  | 819 |  |  |  | 819 |  |  | NA | NA | NA | NA |  |  |  |  |  |  |
|  | L1 SP #0 (0-47 cs) |  |  | L1 SP #1 (48-95 cs) |  |  |  | L1 SP #2 (96-143 cs) |  | L1 SP #3 (144-191 cs) |  |  | Cell slots |  |  | L1 Subpools |  |  |
|  | 48 cell slots |  |  | 48 cell slots |  |  |  | 48 cell slots |  | 48 cell slots |  |  | Initial Stream PRB |  |  |  |  |  |
|  | NR\_L1Pool\_Thor\_TDD\_FR1\_eCPRI L1 pool #0 |  |  | NR\_L1Pool\_Thor\_TDD\_FR1\_eCPRI L1 pool #0 |  |  |  | NR\_L1Pool\_Thor\_TDD\_FR1\_eCPRI L1 pool #1 |  | NR\_L1Pool\_Thor\_TDD\_FR1\_eCPRI L1 pool #1 |  |  | Initial Layer PRB |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |  |  | L1 Pool |  |  |  |  |  |
| C4 100 | C4 100 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | UL Primary subcell for NR TDD |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| C4 100 | C4 100 |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
|  | UL Secondary subcell for NR TDD |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| ```[/image\_desc][image\_path]https://storage.googleapis.com/dng\_files/images/HTML\_pukkola\_5G\_L1\_Entity\_Level\_file\_11986.003.png[/image\_path][/image-2] |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |

---

**13.1.1.10.0-20.1.0-1**  (ID: `11489257`)

NR FR1 TDD
11489257:
NR FR1 TDD
11489257:
NR FR1 TDD
11489257:
NR FR1 TDD
11489257:
NR FR1 TDD
11489257:
NR FR1 TDD
11489257:
NR FR1 TDD
11489257:
NR FR1 TDD
11489257:
NR FR1 TDD
11489257:
NR FR1 TDD
11489257:
NR FR1 TDD
11489257:
NR FR1 TDD
11489257:
NR FR1 TDD
11489257:
NR FR1 TDD
11489257:
NR FR1 TDD
11489257:
NR FR1 TDD
11489257:
NR FR1 TDD
11489257:
NR FR1 TDD
11489257:
NR FR1 TDD
11489257:
NR FR1 TDD
11489257:
NR FR1 TDD
L1 SW for Thor shall support the next configuration.
L1 shall support following L1 instance: L1\_Thor\_FR1.
Each L1 pool selects L1 pool type NR\_L1Pool\_Thor\_TDD\_FR1\_eCPRI.
 
For L1 Pool 0 PRB pooling shall be enabled (isPrbPoolingEnabled=TRUE in message L1Config\_SwConfigurationReq as described in 5G\_L1\_12311\_replaced([11396018](https://dn-prod.ext.net.nokia.com/rm/resources/BI_e8qEivvvEe-AqvopbP1qhQ)));
For L1 Pool 1 PRB pooling shall be enabled (isPrbPoolingEnabled=TRUE in message L1Config\_SwConfigurationReq as described in 5G\_L1\_12311\_replaced([11396018](https://dn-prod.ext.net.nokia.com/rm/resources/BI_e8qEivvvEe-AqvopbP1qhQ)));
 
[CB010713-B, CB010713-C]
For UL: Mixed subcelltypes C4 & C8 shall be supported inside the same L1 subpool or L1 pool.
- C8 subcell should start with cell slot index={0,24,48,96,120,144};
- C4 primary & C4 secondary should be placed in pairs, C4 subcell should start with cell slot index={0,12,24,36,48,60,96,108,120,132,144,156};
- maxNumOfDataStreamsPerCell=8, maxNumOfDataLayerPerCell= 4 for the following Mixed subcell types C8 & C4 in UL.
  [image-0][image\_desc]The image displays a diagram illustrating a scheduling or resource allocation scheme, likely related to telecommunications. It is structured as a table with rows and columns.
The leftmost column is labeled "L1 UL". The rows are divided into several sections.
The top section shows a row with cells labeled "C4", "C4", "C4", "C4", "C4", "C4", and "not available".
Below this, another row has cells labeled "C8", "C8", "C8", and "not available".
To the right of these two rows, there is a bracketed label "mixable".
The next section of the table contains two columns. The first column has a cell labeled "Thor L1 SP NR TDD FR1 48 slots". The second column also has a cell labeled "Thor L1 SP NR TDD FR1 48 slots".
Below this, the table is divided into two main horizontal sections, each split into two columns.
The first horizontal section has cells labeled "0-47" in the left column and "48-95" in the right column. To the right of this section, there is a label "Cell Slot (1st L1 Pool)".
The second horizontal section has cells labeled "96-143" in the left column and "144-191" in the right column. To the right of this section, there is a label "Cell Slot (2nd L1 Pool)".
The diagram appears to represent the allocation of time slots or resources within a system, possibly for different types of communication (indicated by C4 and C8) and different pools of cell slots. The "mixable" label suggests that the resources in the top section can be combined or used flexibly.[/image\_desc][image\_path]https://storage.googleapis.com/dng\_files/images/HTML\_pukkola\_5G\_L1\_Entity\_Level\_file\_11953.001.png[/image\_path][/image-0]
 
  For C8, the subcell configuration in UL is the same as below:
      - 2 L1 pools per Thor, every L1 pool consists of 96 cell slots;
      - 2 L1 subpools per L1 pool, every sub pool consists of 48 cell slots;
      - 3 C8 subcells in total per L1 pool, every C8 subcell consumes 24 cell slots, the last 24 cell slots are not used;
      - 1638 initial stream PRB per L1 subpool;
      - 819 initial layer PRB per L1 subpool;
      - PRB pooling shall be enabled (parameter isPrbPoolingEnabled=TRUE in message L1Config\_SwConfigurationReq as described in 5G\_L1\_12311\_replaced([11396018](https://dn-prod.ext.net.nokia.com/rm/resources/BI_e8qEivvvEe-AqvopbP1qhQ)));
      - In L1Config\_SwConfigurationReq, the parameter maxNumOfDataLayerPerCelll shall be set to 4 for UL, the parameter maxNumOfDataStreamsPerCell shall be set to 8 for UL;
      - Upon reception of the UlPool\_BbResourceReconfReq message, PRB resources shall be reconfigured among subpools for UL as the following table refer to 5G\_L1\_9329\_replaced([11396093](https://dn-prod.ext.net.nokia.com/rm/resources/BI_e8qrlfvvEe-AqvopbP1qhQ)), the following Reconifgured Stream& Layer PRB shall also apply to mixed C4 & C8 subcell deployment:
             # 2184 Reconfigured stream PRB for L1 SP#(0,2), 1092 Reconfigured stream PRB for L1 SP#(1,3);
             # 1092 Reconfigured layer PRB for L1 SP#(0,2), 546 Reconfigured Layer PRB for L1 SP#(1,3).
 
[image-1][image\_desc]The image contains a spreadsheet with two tables. Both tables have similar structures, with columns labeled "C8" and "Not used", and rows describing various parameters. The first table covers cell ranges 0-23, 24-47, 48-71, and 72-95. The second table covers cell ranges 96-119, 120-143, 144-167, and 168-191. The rows describe parameters such as "SubCells", "Cell slots", "maxNumOfDataStreamsPerCell", "maxNumOfDataLayersPerCell", "Max subcell BW (MHz)", "Max subcell PRB", "Initial Stream PRB **", "Initial Layer PRB", "Reconfigured Stream PRB** ", "Reconfigured Layer PRB", "L1 Subpools", and "L1 Pool". Some cells contain numerical values, while others contain text like "Thor L1 SP #0", "Thor L1 SP #1", "Thor L1 SP #2", "Thor L1 SP #3", and "NR TDD FR1 48 cell slot". There are also asterisks (*) and double asterisks (**) in some cells, likely indicating special notes or conditions.
Here is the table represented in markdown:**Table 1*\*

| C8 | C8 | C8 | Not used | SubCells |
| --- | --- | --- | --- | --- |
| 0-23 | 24-47 | 48-71 | 72-95 |  |
| 8 | 8 | 8 | 8 | Cell slots |
| 4 | 4 | 4 | 4 | maxNumOfDataStreamsPerCell |
| 100 | 100 | 100 | 100 | maxNumOfDataLayersPerCell |
| 273 | 273 | 273 | 273 | Max subcell BW (MHz) |
| 1638 |  |  |  | Max subcell PRB |
| 819 |  |  |  | Initial Stream PRB \*\* |
| 2184\* |  |  |  | Initial Layer PRB |
| 1092\* |  |  |  | Reconfigured Stream PRB \*\* |
|  | 546\* |  |  | Reconfigured Layer PRB |
| Thor L1 SP #0 |  |  |  | L1 Subpools |
| NR TDD FR1 48 cell slot |  |  |  | L1 Pool |
|  |  |  |  |  |
|  |  |  |  | L1 pool #0 |
| **Table 2** |  |  |  |  |

| C8 | C8 | C8 | Not used | SubCells |
| --- | --- | --- | --- | --- |
| 96-119 | 120-143 | 144-167 | 168-191 |  |
| 8 | 8 | 8 | 8 | Cell slots |
| 4 | 4 | 4 | 4 | maxNumOfDataStreamsPerCell |
| 100 | 100 | 100 | 100 | maxNumOfDataLayersPerCell |
| 273 | 273 | 273 | 273 | Max subcell BW (MHz) |
| 1638 |  |  |  | Max subcell PRB |
| 819 |  |  |  | Initial Stream PRB \*\* |
| 2184\* |  |  |  | Initial Layer PRB |
| 1092\* |  |  |  | Reconfigured Stream PRB \*\* |
|  | 546\* |  |  | Reconfigured Layer PRB |
| Thor L1 SP #2 |  |  |  | L1 Subpools |
|  |  |  |  | L1 Pool |
|  |  |  |  |  |
|  |  |  |  | L1 pool #1 |
| [End CB010713-B, CB010713-C] |  |  |  |  |
|  |  |  |  |  |
| For C4, the subcell configuration in UL is the same as below from 5G\_L1\_12307\_replaced([11488956](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fEKaufvvEe-AqvopbP1qhQ)) of CB009055: |  |  |  |  |
| - 2 L1 pools per Thor, every L1 pool consists of 96 cell slots; |  |  |  |  |
| - 2 L1 subpools per L1 pool, every L1 subpool consists of 48 cell slots; |  |  |  |  |
| - Each L1 pool consumes 72 cell slots, the last 24 cell slots are not used; |  |  |  |  |
| - 6 C4 subcells per L1 pool (3 primary subcells and 3 secondary subcells), every subcell consists of 12 cell slots; |  |  |  |  |
| - 1638 initial stream PRB per L1 subpool; |  |  |  |  |
| - 819 initail layer PRB per L1 subpool. |  |  |  |  |
| [CB010713-A] |  |  |  |  |
| For UL, L1 SW not support to configure all C8 subcells or C8 mixed with C4 subcell, only support all C4 subells with 12 cell slots per subcell, refer to 5G\_L1\_12307\_replaced([11488956](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fEKaufvvEe-AqvopbP1qhQ)) of CB009055 |  |  |  |  |
| [End CB010713-A] |  |  |  |  |
|  |  |  |  |  |
| [CB010713-A, CB010713-B] |  |  |  |  |
| Note (8*) & (4*): The difference from CB009055(maxNumOfDataStreamsPerCell=4, maxNumOfDataLayerPerCell=2) is for Thor with full board deployment, in message L1Config\_SwConfigurationReq, to avoid reset in the scenario –“while all paired 2XC4 subcells(1 Primary +1 Secondary) with 12 cell slots per subcell insteaded of all C8 subcells”,  the two parameters maxNumOfDataStreamsPerCell should be 8 and maxNumOfDataLayerPerCell should be 4 for all C4 subcells in UL. |  |  |  |  |
| [End CB010713-A, CB010713-B] |  |  |  |  |
| [image-2][image\_desc]The image contains a table with data related to cellular network parameters. The table is divided into two main sections, each with a header row and multiple data rows. The columns are labeled with "C4" and "Not used", and some columns also have numerical ranges. The rows describe various parameters such as "Cell slots", "maxNumOfDataStreamsPerCell", "maxNumOfDataLayersPerCell", "Max subcell BW (MHz)", "Max subcell PRB", "Initial Stream PRB \*\*", and "Initial Layer PRB". |  |  |  |  |
| The table also includes information about "Thor L1 SP" (likely referring to specific sub-pools or configurations) and "L1 pool" numbers. |  |  |  |  |
| Here is the table represented in markdown format: |  |  |  |  |

| C4 | C4 | C4 | C4 | C4 | C4 | Not used | Not used | SubCells |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0-11 | 12-23 | 24-35 | 36-47 | 48-59 | 60-71 | 72-83 | 84-95 | Cell slots |
| 8\* | 8\* | 8\* | 8\* | 8\* | 8\* | 8\* | 8\* | maxNumOfDataStreamsPerCell |
| 4\* | 4\* | 4\* | 4\* | 4\* | 4\* | 4\* | 4\* | maxNumOfDataLayersPerCell |
| 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | Max subcell BW (MHz) |
| 273 | 273 | 273 | 273 | 273 | 273 | 273 | 273 | Max subcell PRB |
|  |  |  |  |  |  |  |  | Initial Stream PRB \*\* |
|  |  |  |  |  |  |  |  | Initial Layer PRB |
|  |  | **1638** |  |  | **1638** |  |  |  |
|  |  | **819** |  |  | **819** |  |  |  |
|  |  | Thor L1 SP #0 |  |  | Thor L1 SP #1 |  |  |  |
|  |  | NR TDD FR1 48 cell slot |  |  | NR TDD FR1 48 cell slot |  |  | L1 Subpools |
|  |  |  |  |  |  |  |  | L1 Pool |
|  |  | L1 pool #0 |  |  |  |  |  |  |
| C4 | C4 | C4 | C4 | C4 | C4 | Not used | Not used | SubCells |
| --------- | --------- | --------- | --------- | --------- | --------- | ---------- | ---------- | ---------------------------------------- |
| 96-107 | 108-119 | 120-131 | 132-143 | 144-155 | 156-167 | 168-179 | 180-191 | Cell slots |
| 8\* | 8\* | 8\* | 8\* | 8\* | 8\* | 8\* | 8\* | maxNumOfDataStreamsPerCell |
| 4\* | 4\* | 4\* | 4\* | 4\* | 4\* | 4\* | 4\* | maxNumOfDataLayersPerCell |
| 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | Max subcell BW (MHz) |
| 273 | 273 | 273 | 273 | 273 | 273 | 273 | 273 | Max subcell PRB |
|  |  |  |  |  |  |  |  | Initial Stream PRB \*\* |
|  |  |  |  |  |  |  |  | Initial Layer PRB |
|  |  | **1638** |  |  | **1638** |  |  |  |
|  |  | **819** |  |  | **819** |  |  |  |
|  |  | Thor L1 SP #2 |  |  | Thor L1 SP #3 |  |  |  |
|  |  |  |  |  |  |  |  | L1 Subpools |
|  |  | L1 pool #1 |  |  |  |  |  | L1 Pool |
|  |  |  |  |  |  |  |  |  |
| For DL, the subcell configuration in DL is the same as below from 5G\_L1\_12394\_replaced([11489015](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fEKavfvvEe-AqvopbP1qhQ)) of CB009142: |  |  |  |  |  |  |  |  |
| - 2 L1 pools per Thor, every L1 pool consists of 96 cell slots; |  |  |  |  |  |  |  |  |
| - 2 L1 subpools per L1 pool, every L1 subpool consists of 48 cell slots; |  |  |  |  |  |  |  |  |
| - 6 C4 subcells per sub pool (3 primary subcells and 3 secondary subcells), every subcell consists of 8 cell slots; |  |  |  |  |  |  |  |  |
| - 2184 stream PRB per L1 subpool; |  |  |  |  |  |  |  |  |
| - 2184 layer PRB per L1 subpool; |  |  |  |  |  |  |  |  |
| - PRB pooling shall be enabled (parameter isPrbPoolingEnabled=TRUE in message L1Config\_SwConfigurationReq as described in 5G\_L1\_12311\_replaced([11396018](https://dn-prod.ext.net.nokia.com/rm/resources/BI_e8qEivvvEe-AqvopbP1qhQ))). |  |  |  |  |  |  |  |  |
| [image-3][image\_desc]The image contains two tables, one above the other, with similar structures. Both tables display data related to "Sub Cells", "Cell Slots", "MaxNumOfDataStreamPerCell", "MaxNumOfDataLayersPerCell", "Max subcell BW in L1 subpool", "Max subcell PRB in L1 subpool", "Stream PRB", "Layer PRB", "Sub Pools", and "Pools". |  |  |  |  |  |  |  |  |
| The top table has columns labeled "C4" with numerical ranges from "0-7" to "88-95". The rows below these ranges contain the values "4", "4", "100", and "273". The table also shows "2184" twice, followed by "Thor L1 SP 0" and "Thor L1 SP 1" with the description "NR TDD FR1 48 slots". The bottom of this section is labeled "Pool 0". |  |  |  |  |  |  |  |  |
| The bottom table also has columns labeled "C4" with numerical ranges from "96-103" to "184-191". The rows below these ranges contain the values "4", "4", "100", and "273". Similar to the top table, it shows "2184" twice, followed by "Thor L1 SP 2" and "Thor L1 SP 3" with the description "NR TDD FR1 48 slots". The bottom of this section is labeled "Pool 1". |  |  |  |  |  |  |  |  |
| The right side of both tables contains the labels for the rows: "Sub Cells", "Cell Slots", "MaxNumOfDataStreamPerCell", "MaxNumOfDataLayersPerCell", "Max subcell BW in L1 subpool", "Max subcell PRB in L1 subpool", "Stream PRB", "Layer PRB", "Sub Pools", and "Pools". |  |  |  |  |  |  |  |  |
| Here is the markdown representation of the tables: |  |  |  |  |  |  |  |  |
| **Top Table** |  |  |  |  |  |  |  |  |

| C4 Range | C4 | C4 | C4 | C4 | C4 | C4 | C4 | C4 | C4 | C4 | C4 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0-7 | 8-15 | 16-23 | 24-31 | 32-39 | 40-47 | 48-55 | 56-63 | 64-71 | 72-79 | 80-87 | 88-95 |
| 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 |
| 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 |
| 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 |
| 273 | 273 | 273 | 273 | 273 | 273 | 273 | 273 | 273 | 273 | 273 | 273 |
| 2184 |  |  |  |  |  |  |  |  |  |  |  |
| 2184 |  |  |  |  |  |  |  |  |  |  |  |
| Thor L1 SP 0 |  |  |  |  |  |  |  |  |  |  |  |
| NR TDD FR1 48 slots |  |  |  |  |  |  |  |  |  |  |  |
| Thor L1 SP 1 |  |  |  |  |  |  |  |  |  |  |  |
| NR TDD FR1 48 slots |  |  |  |  |  |  |  |  |  |  |  |

| Pool 0 | | | | | | | | | | | |
**Row Labels:**
\* Sub Cells
\* Cell Slots
\* MaxNumOfDataStreamPerCell
\* MaxNumOfDataLayersPerCell
\* Max subcell BW in L1 subpool
\* Max subcell PRB in L1 subpool
\* Stream PRB
\* Layer PRB
\* Sub Pools
\* Pools
**Bottom Table**

| C4 | C4 | C4 | C4 | C4 | C4 | C4 | C4 | C4 | C4 | C4 | C4 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 96-103 | 104-111 | 112-119 | 120-127 | 128-135 | 136-143 | 144-151 | 152-159 | 160-167 | 168-175 | 176-183 | 184-191 |
| 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 |
| 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 | 4 |
| 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 |
| 273 | 273 | 273 | 273 | 273 | 273 | 273 | 273 | 273 | 273 | 273 | 273 |
| 2184 |  |  |  |  |  |  |  |  |  |  |  |
| 2184 |  |  |  |  |  |  |  |  |  |  |  |
| Thor L1 SP 2 |  |  |  |  |  |  |  |  |  |  |  |
| NR TDD FR1 48 slots |  |  |  |  |  |  |  |  |  |  |  |
| Thor L1 SP 3 |  |  |  |  |  |  |  |  |  |  |  |
| NR TDD FR1 48 slots |  |  |  |  |  |  |  |  |  |  |  |

| Pool 1 | | | | | | | | | | | |
**Row Labels:**
\* Sub Cells
\* Cell Slots
\* MaxNumOfDataStreamPerCell
\* MaxNumOfDataLayersPerCell
\* Max subcell BW in L1 subpool
\* Max subcell PRB in L1 subpool
\* Stream PRB
\* Layer PRB
\* Sub Pools
\* Pools[/image\_desc][image\_path]https://storage.googleapis.com/dng\_files/images/HTML\_pukkola\_5G\_L1\_Entity\_Level\_file\_11953.004.png[/image\_path][/image-3]

---

**13.1.1.10.0-20.1.0-1.0-4**  (ID: `11489302`)

NR FR1 TDD
Refer to Cell Slot model's definition of CB010713 BB set type A/B in 5G\_L1\_13044\_replaced([11489257](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo0PvvEe-AqvopbP1qhQ))/5G\_L1\_13079\_replaced([11489281](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo0vvvEe-AqvopbP1qhQ))/5G\_L1\_13058\_replaced([11489295](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo0_vvEe-AqvopbP1qhQ)) and Cell Slot Model's definition of CB009142 BB set type A in 5G\_L1\_12394\_replaced([11489015](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fEKavfvvEe-AqvopbP1qhQ)).

L1 SW shall support many kinds of BB set changes between CB010713 and CB009142. during some BB set changes, L1 SW shall support the BB cell set re-deployment by cell(s)' reconfiguration(addition/deletion/modification), and two parameters maxNumOfDataStreamsPerCell and maxNumOfDataLayersPerCell in message L1Config\_SwConfigurationReq will be reset with different values. BB set changes' rule refers to the following table:

|  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- |
| **Original deployment** | **At least one cell with 16 DL(After Reconfiguration)** | **At least one cell with 8RX in UL(After Reconfiguration)** | **Subcell type with CS to be deployed in UL(After Reconfiguration)** | **maxNumOfDataStreamsPerCell in UL** | **maxNumOfDataLayersPerCell in UL** |
| CB010713 BB set type -A on Full ABIP | TRUE | TRUE | Mixed at least one C8 subell (24 CS per subcell)with C4 subcell(s) (12 CS per subcell) | 8 | 4 |
| FALSE | All C4 subcells (12 CS per subcell) | 8 | 4 |  |  |
| FALSE | TRUE | **ABIP reset > re-deployment with** CB010173 set type B(Mixed at least one C8 subell (24 CS per subcell) with C4 subcell(s) (12 CS per subcell)**) on each Half ABIP**\*\*\*\* | 8 | 4 |  |
| FALSE | ABIP **reset > re-deployment with** CB009142 BB set type A(All C4 subcells with 8 CS per subcell**) on each Half ABIP**\*\*\*\* | 8->4 | 4->2 |  |  |
| CB010713 BB set type-B on Half ABIP | FALSE | TRUE | Mixed at least one C8 sub ell (24 CS per subcell) with C4 subcell(s) (12 CS per subcell)) | 8 | 4 |
| FALSE | ABIP **reset > re-deployment with** CB009142 BB set type A(All C4 subcells with 8 CS per subcell**) on Half ABIP**\*\*\*\* | 8->4 | 4->2 |  |  |
| TRUE | TRUE | ABIP **reset > re- deployment with** CB010173 set type A(Mixed at least one C8 subell (24 CS per subcell) with C4 subcell(s) (12 CS per subcell)**) on full ABIP**\*\*\*\* | 8 | 4 |  |
| FALSE | ABIP **reset > re-deployment with** CB010173 set type A(All C4 subcells with 12 CS per subcell**) on full ABIP**\*\*\*\* | 8 | 4 |  |  |
| CB009142 BB set type -A on Half ABIP | FALSE | FALSE | All C4 subcells (8 CS per subcell) | 4 | 2 |
| TRUE | ABIP **reset > re-deployment with** CB010173 set type B(Mixed at least one C8 subell (24 CS per subcell) with C4 subcell(s) (12 CS per subcell)**) on Half ABIP**\*\*\*\* | 4->8 | 2->4 |  |  |
| TRUE | TRUE | ABIP **reset > re-deployment with** CB010173 set type A(Mixed at least one C8 subell (24 CS per subcell) with C4 subcell(s) (12 CS per subcell)**) on full ABIP**\*\*\*\* | 4->8 | 2->4 |  |
| FALSE | ABIP **reset > re-deployment with** CB010173 set type A (All C4 subcells with 12 CS per subcell**) on full ABIP**\*\*\*\* | 4->8 | 2->4 |  |  |

---

**13.1.1.10.0-20.1.0-1.0-4.0-1**  (ID: `11489311`)

NR FR1 TDD
Reconfiguration case-1

---

**13.1.1.10.0-20.1.0-1.0-4.0-1.0-1**  (ID: `11489319`)

NR FR1 TDD
11489319:
NR FR1 TDD
11489319:
NR FR1 TDD
11489319:
NR FR1 TDD
11489319:
NR FR1 TDD
11489319:
NR FR1 TDD
11489319:
NR FR1 TDD
11489319:
NR FR1 TDD
11489319:
NR FR1 TDD
11489319:
NR FR1 TDD
11489319:
NR FR1 TDD
11489319:
NR FR1 TDD
11489319:
NR FR1 TDD
11489319:
NR FR1 TDD
11489319:
NR FR1 TDD
11489319:
NR FR1 TDD
11489319:
NR FR1 TDD
11489319:
NR FR1 TDD
11489319:
NR FR1 TDD
11489319:
NR FR1 TDD
11489319:
NR FR1 TDD
Follow the BB set changes' rule in 5G\_L1\_13310\_replaced([11489302](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo1PvvEe-AqvopbP1qhQ)), L1 SW should support the following reconfiguration case-1:

- CB010713 BB set type-B refers to 5G\_L1\_13058\_replaced([11489295](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo0_vvEe-AqvopbP1qhQ))

- CB010713 BB set type-A refers to 5G\_L1\_13079\_replaced([11489281](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo0vvvEe-AqvopbP1qhQ))

Notice:  The details of User Scenario refer to SRAN\_SFS\_SISO.3885 UC-G-1-1 under /RA System General Modules/Site Solution/SRAN\_SFS\_Site\_Solution

[image-0][image\_desc]The image displays a comparison of two configurations for a baseband unit (BB set) labeled "CB010713". The top section, "Before: CB010713 BB set type -B", shows a configuration with up to 3 cells, each supporting 8DL 4UL Layers and 8UL Streams, with an 8RX receiver on Half ABIP. The UL L1 Pool #1 has `maxNumOfDataStreamsPerCell = 8` and `maxNumOfDataLayersPerCell = 4`. This configuration is visually represented by a table showing the allocation of resources within cells.
The bottom section, "After: whole ABIP reset and re-deployment with CB010713 BB set type -A", details a new configuration. This configuration involves 1 x 16DL8UL cell with an 8RX receiver and 2 x 8DL8UL cells with an 8RX receiver on Full ABIP. The UL L1 Pool #1 & #2 both have `maxNumOfDataStreamsPerCell = 8` and `maxNumOfDataLayersPerCell = 4`. An "Action" is described as "Reconfigure cell1 from 8DL8UL to 16DL8DL with 8RX receiver". This section also includes a table illustrating the resource allocation for the "After" configuration.
The tables in both sections depict resource blocks within cells, categorized by L2 SP (Layer 2 Single Path) and L1 SP (Layer 1 Single Path), with specific pool names like "L2 Pool NR TDD FR1 3SP", "Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2a)", "Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2a)", and "L2 Pool NR TDD FR1 6SP". Different colored blocks (green, yellow, blue) represent different types of resource allocations, such as GC8, C4, and C8. The tables also indicate "NULL" for certain pool allocations in the "Before" configuration. The "After" configuration shows a change in the cell structure, with a larger cell (GC16) and different resource distributions.
**Table Representation of "Before: CB010713 BB set type -B"**

| Cell | Resource Allocation 1 | Resource Allocation 2 | Resource Allocation 3 | Resource Allocation 4 | Resource Allocation 5 | Resource Allocation 6 | Pool Type |
| --- | --- | --- | --- | --- | --- | --- | --- |
| cell 1 | GC8 | C4 C4 | C8 | C8 | C8 |  | Subpools Pools |
| cell 2 | GC8 | C4 C4 |  |  |  |  | Subpools Pools |
| cell 3 | GC8 | C4 C4 |  |  |  |  | Subpools Pools |
| Pools | L2 SP (L2 Pool NR TDD FR1 3SP) | L2 SP (L2 Pool NR TDD FR1 3SP) | L2 SP (L2 Pool NR TDD FR1 3SP) | L1 SP (Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2a)) | L1 SP (Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2a)) |  | Pools |
| Pools | NULL | NULL |  |  |  |  | Pools |
| **Table Representation of "After: CB010713 BB set type -A"** |  |  |  |  |  |  |  |

| Cell | Resource Allocation 1 | Resource Allocation 2 | Resource Allocation 3 | Resource Allocation 4 | Resource Allocation 5 | Resource Allocation 6 | Pool Type |
| --- | --- | --- | --- | --- | --- | --- | --- |
| cell 1 | GC16 | C4 C4 | C8 |  |  |  | Subpools Pools |
| cell 2 |  |  |  |  |  |  | Subpools Pools |
| cell 3 | GC8 | GC8 | C4 C4 | C4 C4 | C8 |  | Subpools Pools |
| Pools | L2 SP (part of same L2 Pool) | L2 SP (part of same L2 Pool) | L2 SP (part of same L2 Pool) | L1 SP (Thor DL L1 Pool NR TDD FR1) | L1 SP (Thor DL L1 Pool NR TDD FR1) |  | Pools |
| Pools | L2 SP (L2 Pool NR TDD FR1 6SP) | L2 SP (L2 Pool NR TDD FR1 6SP) | L2 SP (L2 Pool NR TDD FR1 6SP) | L1 SP (Thor UL L1 Pool NR TDD FR1) | L1 SP (Thor UL L1 Pool NR TDD FR1) |  | Pools |

---

**13.1.1.10.0-20.1.0-1.0-4.0-2**  (ID: `11489325`)

NR FR1 TDD
Reconfiguration Case-2

---

**13.1.1.10.0-20.1.0-1.0-4.0-2.0-1**  (ID: `11489344`)

NR FR1 TDD
11489344:
NR FR1 TDD
11489344:
NR FR1 TDD
11489344:
NR FR1 TDD
11489344:
NR FR1 TDD
11489344:
NR FR1 TDD
11489344:
NR FR1 TDD
11489344:
NR FR1 TDD
11489344:
NR FR1 TDD
11489344:
NR FR1 TDD
11489344:
NR FR1 TDD
11489344:
NR FR1 TDD
11489344:
NR FR1 TDD
11489344:
NR FR1 TDD
11489344:
NR FR1 TDD
11489344:
NR FR1 TDD
11489344:
NR FR1 TDD
11489344:
NR FR1 TDD
11489344:
NR FR1 TDD
11489344:
NR FR1 TDD
11489344:
NR FR1 TDD
Follow the BB set changes' rule in 5G\_L1\_13310\_replaced([11489302](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo1PvvEe-AqvopbP1qhQ)), L1 SW should support the following reconfiguration case-2:

- CB010713 BB set type-A refers to 5G\_L1\_13079\_replaced([11489281](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo0vvvEe-AqvopbP1qhQ))

- CB009142 BB set type-A refers to 5G\_L1\_12394\_replaced([11489015](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fEKavfvvEe-AqvopbP1qhQ))

Notice:  The details of User Scenario refer to SRAN\_SFS\_SISO.3885 UC-G-1-3 & UC-G-1-5 under /RA System General Modules/Site Solution/SRAN\_SFS\_Site\_Solution

[image-0][image\_desc]The image displays a diagram illustrating a system configuration, likely related to telecommunications or networking. The diagram is divided into two main sections: a textual description on the left and a visual representation of cells and pools on the right.
The text section provides the following information:
- Title: (24R1 CB010713 -G)
- Configuration Type: Before: CB010713 BB set type -A
- System Description:
- 1 cell with 16DL 8UL Streams
- 4RX receiver + up to 5 cells with 8DL8UL with 4RX receiver
- On Full ABIP
- UL L1 Pool #1 & #2 Parameters:
- maxNumOfDataStreamsPerCell = 8;
- maxNumOfDataLayersPerCell = 4;
The visual section on the right is a grid-like structure representing different "cells" and "subpools." Each cell is further subdivided into sections labeled with abbreviations like "GC16," "GC8," "L2 SP," and "L1 SP." These labels likely denote different functional blocks or processing units within the system. Within these sections, there are colored rectangles labeled "C4" and "C4" (underlined), indicating data streams or layers. The cells are organized vertically and labeled "cell 1," "cell 3," "cell 5," "cell 1," "cell 2," "cell 4," and "cell 6." There are also rows labeled "Subpools Pools."
The table below represents the visual layout of the cells and their contents:

| Cell | Column 1 | Column 2 | Column 3 | Column 4 | Column 5 | Column 6 | Column 7 | Column 8 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **cell 1** | GC16 |  | C4 C4 |  | C4 C4 |  | C4 C4 |  |
|  |  | GC8 |  | C4 C4 |  | C4 C4 |  | C4 C4 |
|  |  |  |  |  |  |  |  |  |
| **cell 3** |  |  |  |  |  |  |  |  |
|  |  | GC8 |  | C4 C4 |  | C4 C4 |  | C4 C4 |
|  |  |  |  |  |  |  |  |  |
| **cell 5** | L2 SP (part of same L2 Pool) | L2 SP | L2 SP | L1 SP Thor DL L1 Pool NR TDD FR1 | L1 SP Thor DL L1 Pool NR TDD FR1 | L1 SP Thor UL L1 Pool NR TDD FR1 | L1 SP Thor UL L1 Pool NR TDD FR1 |  |
|  |  | GC8 |  | C4 C4 |  | C4 C4 |  | C4 C4 |
|  |  |  |  |  |  |  |  |  |
| **Subpools Pools** |  |  |  |  |  |  |  |  |
| **cell 1** |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |
| **cell 2** |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |
| **cell 4** |  |  |  |  |  |  |  |  |
|  |  | GC8 |  | C4 C4 |  | C4 C4 |  | C4 C4 |
|  |  |  |  |  |  |  |  |  |
| **cell 6** | L2 SP L2 Pool NR TDD FR1 6SP | L2 SP | L1 SP Thor DL L1 Pool NR TDD FR1 | L1 SP Thor DL L1 Pool NR TDD FR1 | L1 SP Thor UL L1 Pool NR TDD FR1 | L1 SP Thor UL L1 Pool NR TDD FR1 |  |  |
|  |  |  |  |  |  |  |  |  |
| **Subpools Pools** |  |  |  |  |  |  |  |  |

[image-1][image\_desc]The image displays a diagram illustrating a change in a system configuration, labeled "Action-1". The text on the left describes the action taken: "Removed cell1 with 16DL8UL Streams 4RX receiver". Following this, the "After-1" section details the new configuration: "whole ABIP reset and re-deployed with CB009142 BB set type -A on Half ABIP, and no BB cell set on another Half ABIP up to 5 cells with 8DL8UL with 4RX receiver on Half ABIP." It also specifies parameters for "UL L1 Pool #1": `maxNumOfDataStreamsPerCell = 4;` and `maxNumOfDataLayersPerCell = 2;`.
The right side of the image contains a visual representation of the system's subpools and cells. The diagram is divided into columns representing time or stages, and rows representing different cells and subpools.
The table below summarizes the visual representation:

| Cell/Subpool | Column 1 | Column 2 | Column 3 | Column 4 | Column 5 | Column 6 | Column 7 | Column 8 | Column 9 | Column 10 | Column 11 | Column 12 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **cell 1** | GC8 |  |  |  | C4 | C4 |  |  |  |  |  |  |
| **cell 2** | GC8 |  |  | C4 | C4 |  | C4 | C4 |  |  |  |  |
| **3...5** |  | GC8 | GC8 | GC8 | GC8 | C4 | C4 | C4 | C4 | C4 | C4 | C4 |
| **Subpools Pools** | L2 SP | L2 SP | L2 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP |
| **Pool Description** | L2 Pool NR TDD FR1 3SP |  |  | Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2) |  |  |  |  |  | Thor UL L1 Pool NR TDD FR1 (@CPRI 7-2) |  |  |
| The diagram shows different blocks labeled "GC8", "C4", "L2 SP", and "L1 SP", indicating different types of processing units or streams within the cells and subpools. The "GC8" blocks appear in the initial columns, while "C4" blocks are more prevalent in later columns. The "L2 SP" and "L1 SP" labels denote subpools at different layers. The pool descriptions at the bottom provide further context about the type of pool and protocol used. An arrow labeled "Action-1" points from the text description towards the diagram, visually connecting the action to its outcome.[/image\_desc][image\_path]https://storage.googleapis.com/dng\_files/images/HTML\_pukkola\_5G\_L1\_Entity\_Level\_file\_11961.002.png[/image\_path][/image-1] |  |  |  |  |  |  |  |  |  |  |  |  |

[image-2][image\_desc]The image displays a diagram illustrating an "OR Action-2" which involves reconfiguring cell1 to 8DL8UL Streams with a 4RX receiver. The "After-2" section details a whole ABIP reset and redeployment with a specific BB set type on a Half ABIP, and no BB cell set on another Half ABIP, supporting up to 6 cells with 8DL8UL and 4RX receiver on Half ABIP. It also specifies parameters for UL L1 Pool #1: `maxNumOfDataStreamsPerCell = 4` and `maxNumOfDataLayersPerCell = 2`.
To the right of the text, there is a visual representation of resource allocation across different cells and subpools. The diagram is structured with rows labeled "cell 1", "cell 2", and "3...6", and columns representing different pools or configurations.
The table below summarizes the visual representation:

| Cell/Subpool | Configuration 1 | Configuration 2 | Configuration 3 | Configuration 4 | Configuration 5 | Configuration 6 | Configuration 7 | Configuration 8 | Configuration 9 | Configuration 10 | Configuration 11 | Configuration 12 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| cell 1 | GC8 |  | C4 | C4 |  |  |  |  |  |  |  |  |
| cell 2 | GC8 |  | C4 | C4 | C4 | C4 | C4 | C4 | C4 | C4 | C4 | C4 |
| 3...6 | L2 SP | L2 SP | L2 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP |
| Pools | L2 Pool NR TDD FR1 3SP |  |  | Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2) |  |  |  |  |  | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) |  |  |

---

**13.1.1.10.0-20.1.0-1.0-4.0-3**  (ID: `11489350`)

NR FR1 TDD
Reconfiguration Case-3

---

**13.1.1.10.0-20.1.0-1.0-4.0-3.0-1**  (ID: `11489368`)

NR FR1 TDD
11489368:
NR FR1 TDD
11489368:
NR FR1 TDD
11489368:
NR FR1 TDD
11489368:
NR FR1 TDD
11489368:
NR FR1 TDD
11489368:
NR FR1 TDD
11489368:
NR FR1 TDD
11489368:
NR FR1 TDD
11489368:
NR FR1 TDD
11489368:
NR FR1 TDD
11489368:
NR FR1 TDD
11489368:
NR FR1 TDD
11489368:
NR FR1 TDD
11489368:
NR FR1 TDD
11489368:
NR FR1 TDD
11489368:
NR FR1 TDD
11489368:
NR FR1 TDD
11489368:
NR FR1 TDD
11489368:
NR FR1 TDD
11489368:
NR FR1 TDD
Follow the BB set changes' rule in 5G\_L1\_13310\_replaced([11489302](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo1PvvEe-AqvopbP1qhQ)), L1 SW should support the following reconfiguration case-3:

- CB009142 BB set type-A refers to 5G\_L1\_12394\_replaced([11489015](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fEKavfvvEe-AqvopbP1qhQ))

- CB010713 BB set type-A refers to 5G\_L1\_13079\_replaced([11489281](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo0vvvEe-AqvopbP1qhQ))

Notice:  The details of User Scenario refer to SRAN\_SFS\_SISO.3885 UC-G-1-2 under /RA System General Modules/Site Solution/SRAN\_SFS\_Site\_Solution

[image-0][image\_desc]The image is a diagram illustrating a configuration for a cellular network, specifically detailing a "Before" state labeled "CB009142 BB set type -A" within a larger context of "(24R1 CB010713 -G)".
The diagram is structured into several sections. On the left, there is descriptive text:
- "3 cell with 8DL 8UL Streams"
- "4RX receiver on Half APBIP"
- "UL L1 Pool #1:"
- "maxNumOfDataStreamsPerCell = 4;"
- "maxNumOfDataLayersPerCell = 2;"
The main part of the image is a grid-like structure representing different cells and their associated processing units or streams. This grid is divided vertically into three main "Cells" labeled "cell 1", "cell 2", and "Cell 3" on the right side. Horizontally, the grid is divided into several time slots or processing stages.
Within these cells, different colored blocks represent different types of streams or processing units:
- Green blocks labeled "GC8" appear in the first column, distributed across cell 1 and cell 2.
- Yellow blocks labeled "C4" appear in the second and third columns, distributed across cell 1 and cell 2.
- Blue blocks labeled "C4" appear in the fourth and fifth columns, distributed across cell 2 and cell 3.
Below these blocks, there are rows labeled "L2 SP" and "L1 SP", indicating different levels of processing. The bottom row provides further details about these L1 SPs:
- "L2 Pool NR TDD FR1 3SP"
- "Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2)"
- "Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2)"
Finally, on the far right, there are labels "Subpools" and "Pools" aligned with the horizontal divisions of the main grid.
The table representation of the grid is as follows:

| Cell | Column 1 | Column 2 | Column 3 | Column 4 | Column 5 | Column 6 |
| --- | --- | --- | --- | --- | --- | --- |
| **cell 1** | GC8 | C4 | C4 |  |  |  |
|  | GC8 | C4 | C4 |  |  |  |
| **cell 2** |  |  |  | C4 | C4 |  |
|  |  |  |  | C4 | C4 |  |
| **Cell 3** |  |  |  |  |  | C4 |
|  |  |  |  |  |  | C4 |
| **L2 SP** | L2 SP | L2 SP | L2 SP |  |  |  |
| **L1 SP** | L2 Pool NR TDD FR1 3SP | Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) |  |  |  |
| **Subpools** |  |  |  |  |  |  |
| **Pools** |  |  |  |  |  |  |

[image-1][image\_desc]The image displays a diagram illustrating a system configuration change, labeled "Action-1". The diagram is divided into two main sections: "Action-1" and "After-1", with a visual representation of resource allocation below.
The "Action-1" section describes a reconfiguration of "cell1" with "16DL8UL Streams" and a "4RX receiver".
The "After-1" section details a "whole ABIP reset and re-deployed with CB010713 BB set type -A". It specifies that the configuration will now support "1 cell with 16DL8UL 4RX receiver + up to 2 cells with 8DL8UL with 4RX receiver on Full ABIP". It also defines parameters for "UL L1 Pool #1 & #2": "maxNumOfDataStreamsPerCell = 8;" and "maxNumOfDataLayersPerCell = 4;".
Below these text descriptions is a visual representation of resource allocation across different cells and subpools. The diagram uses colored blocks to denote different types of resources or configurations.
The table below summarizes the visual representation of resource allocation:

| Cell/Subpool | Column 1 | Column 2 | Column 3 | Column 4 | Column 5 | Column 6 | Column 7 | Column 8 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **cell 1** | GC16 |  | C4 | C4 |  | C4 | C4 |  |
|  | L2 SP (part of same L2 Pool) | L2 SP (part of same L2 Pool) | L2 SP (part of same L2 Pool) | L1 SP | L1 SP |  |  |  |
|  | GC8 | GC8 |  | C4 | C4 |  |  |  |
| **cell 2** |  |  |  | C4 | C4 |  |  |  |
|  |  |  |  |  |  |  |  |  |
| **cell 3** |  |  |  | C4 | C4 |  |  |  |
|  | L2 SP | L2 SP | L2 SP | L1 SP | L1 SP | L1 SP | L1 SP |  |
|  | L2 Pool NR TDD FR1 6SP | Thor DL L1 Pool NR TDD FR1 | Thor DL L1 Pool NR TDD FR1 | Thor UL L1 Pool NR TDD FR1 | Thor UL L1 Pool NR TDD FR1 |  |  |  |
| **Subpools Pools** |  |  |  |  |  |  |  |  |
| **cell 1** |  |  |  |  |  |  |  |  |
| **cell 2** |  |  |  |  |  |  |  |  |
| **cell 3** |  |  |  |  |  |  |  |  |
| **Subpools Pools** |  |  |  |  |  |  |  |  |
| The diagram also includes an arrow pointing downwards with the text "Action-1" on it, visually connecting the initial action description to the subsequent state. The right side of the diagram labels the rows as "cell 1", "cell 2", and "cell 3" under "Subpools Pools".[/image\_desc][image\_path]https://storage.googleapis.com/dng\_files/images/HTML\_pukkola\_5G\_L1\_Entity\_Level\_file\_11963.002.png[/image\_path][/image-1] |  |  |  |  |  |  |  |  |

[image-2][image\_desc]The image displays a diagram illustrating a system configuration, likely related to telecommunications or computing. The diagram is divided into two main sections: a textual description on the left and a visual representation of the system on the right.
The textual description on the left presents two "Actions" or states:
**Or Action-2:**
This section describes adding a new cell with "16DL8UL Streams 4RX receiver".
**Or After-2:**
This section details a "whole ABIP reset and re-deployed with CB010713 BB set type -A". It further specifies the configuration: "1 cell with 16DL8UL 4RX receiver + up to 3 cells with 8DL8UL with 4RX receiver on Full ABIP." It also provides parameters for "UL L1 Pool #1 & #2":
\* `maxNumOfDataStreamsPerCell = 8;`
\* `maxNumOfDataLayersPerCell = 4;`
The visual representation on the right is a grid-like structure, depicting cells and their components. A large blue arrow points from the "Or Action-2" text towards this visual section, suggesting that the diagram illustrates the outcome of Action-2.
The visual diagram is organized into rows labeled "cell 1", "cell 2", "cell 3", and "cell 4", and columns representing different processing stages or pools. There are also rows labeled "Subpools Pools" at the bottom.
Within the grid, various blocks represent different components:
\* **GC16** and **GC8**: These appear to be specific processing units or groups.
\* **C4**: These are smaller blocks, possibly representing data channels or streams. They are colored yellow and blue.
\* **L2 SP**: These are labeled as "L2 SP" and some are further described as "(part of same L2 Pool)" or "L2 Pool NR TDD FR1 6SP".
\* **L1 SP**: These are labeled as "L1 SP" and are associated with "Thor DL L1 Pool NR TDD FR1" or "Thor UL L1 Pool NR TDD FR1".
The arrangement of these blocks within the cells and across the different pools suggests a hierarchical or distributed system architecture. For instance, "cell 1" in the top section contains "GC16" and "C4" blocks. "Cell 2" contains "C4" blocks. "Cell 3" contains "GC8" and "C4" blocks. "Cell 4" contains "GC8" and "C4" blocks. The "Subpools Pools" rows at the bottom seem to aggregate or further detail the L2 and L1 processing.
The diagram visually represents the configuration described in the text, showing how different components are allocated and interconnected within the cells and pools.[/image\_desc][image\_path]https://storage.googleapis.com/dng\_files/images/HTML\_pukkola\_5G\_L1\_Entity\_Level\_file\_11963.003.png[/image\_path][/image-2]

---

**13.1.1.10.0-20.1.0-1.0-4.0-4**  (ID: `11489374`)

NR FR1 TDD
Reconfiguration Case-4

---

**13.1.1.10.0-20.1.0-1.0-4.0-4.0-1**  (ID: `11489390`)

NR FR1 TDD
11489390:
NR FR1 TDD
11489390:
NR FR1 TDD
11489390:
NR FR1 TDD
11489390:
NR FR1 TDD
11489390:
NR FR1 TDD
11489390:
NR FR1 TDD
11489390:
NR FR1 TDD
11489390:
NR FR1 TDD
11489390:
NR FR1 TDD
11489390:
NR FR1 TDD
11489390:
NR FR1 TDD
11489390:
NR FR1 TDD
11489390:
NR FR1 TDD
11489390:
NR FR1 TDD
11489390:
NR FR1 TDD
11489390:
NR FR1 TDD
11489390:
NR FR1 TDD
11489390:
NR FR1 TDD
11489390:
NR FR1 TDD
11489390:
NR FR1 TDD
Follow the BB set changes' rule in 5G\_L1\_13310\_replaced([11489302](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo1PvvEe-AqvopbP1qhQ)), L1 SW should support the following reconfiguration case-4:

- CB010713 BB set type-A refers to 5G\_L1\_13079\_replaced([11489281](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo0vvvEe-AqvopbP1qhQ))

- CB010713 BB set type-B refers to 5G\_L1\_13058\_replaced([11489295](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo0_vvEe-AqvopbP1qhQ))

Notice:  The details of User Scenario refer to SRAN\_SFS\_SISO.3885 UC-G-1-4 & UC-G-1-6 under /RA System General Modules/Site Solution/SRAN\_SFS\_Site\_Solution

[image-0][image\_desc]The image displays a diagram illustrating a system configuration, likely related to telecommunications or computing. The diagram is divided into several sections, with text on the left and a grid-like structure on the right.
The text on the left provides context for the diagram:
"(24R1 CB010713 -G)
Before: CB010713 BB set type -A
1 cell 16DL 8UL streams 8RX receiver + Up to 5 cells with 8DL 8UL
Streams 8RX receiver on Full ABIP
UL L1 Pool #1 & #2:
maxNumOfDataStreamsPerCell = 8;
maxNumOfDataLayersPerCell = 4;"
The right side of the image is a table with rows labeled "cell 1", "cell 3", "cell 5", "Subpools Pools", "cell 1", "cell 2", "cell 4", "cell 6", and "Subpools Pools" on the right edge. The columns are divided by vertical lines and labeled at the top with terms like "GC16", "GC8", "L2 SP", "L1 SP", and specific pool names like "Thor DL L1 Pool NR TDD FR1" and "Thor UL L1 Pool NR TDD FR1".
The table contains colored cells (green, yellow, and blue) with text indicating different components or states.
Here's a markdown representation of the table:

|  | Column 1 | Column 2 | Column 3 | Column 4 | Column 5 | Column 6 | Column 7 | Column 8 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **cell 1** | GC16 |  | C4 | C4 | C8 |  |  |  |
|  | GC8 |  |  |  |  |  |  |  |
|  | GC8 |  |  |  |  |  |  |  |
| **cell 3** | L2 SP | L2 SP | L1 SP | L1 SP | L1 SP | L1 SP |  |  |
|  | (part of same L2 Pool) |  | Thor DL L1 Pool NR TDD FR1 |  | Thor UL L1 Pool NR TDD FR1 |  |  |  |
|  | GC8 |  | C4 | C4 | C8 |  |  |  |
|  | GC8 |  |  |  |  |  |  |  |
| **cell 5** |  |  | C4 | C4 | C8 |  |  |  |
|  |  |  |  |  |  |  |  |  |
| **Subpools Pools** |  |  |  |  |  |  |  |  |
| **cell 1** |  |  | C4 | C4 | C8 |  |  |  |
| **cell 2** |  |  |  |  |  |  |  |  |
| **cell 4** |  |  | C4 | C4 | C8 |  |  |  |
| **cell 6** | GC8 |  | C4 | C4 | C8 |  |  |  |
|  | GC8 |  |  |  |  |  |  |  |
| **Subpools Pools** | L2 SP | L2 SP | L1 SP | L1 SP | L1 SP | L1 SP |  |  |
|  | L2 Pool NR TDD FR1 6SP |  | Thor DL L1 Pool NR TDD FR1 |  | Thor UL L1 Pool NR TDD FR1 |  |  |  |

[image-1][image\_desc]The image displays a diagram illustrating a change in a system configuration, labeled "Action-1". The diagram is divided into two main sections: a textual description on the left and a visual representation of the system's structure on the right.
The textual description on the left details the changes:
"Action-1:
Removed cell1 with 16DL8UL Streams
8RX receiver
After-1:
whole ABIP reset and re-deployed with
CB010713 BB set type-B on each Half ABIP
3 cells with 8DL8UL 8RX receiver on Half ABIP + up to
2 cells with 8DL8UL with 8RX receiver on Half ABIP.
UL L1 Pool #1 & #2:
maxNumOfDataStreamsPerCell = 8;
maxNumOfDataLayersPerCell = 4;"
The visual representation on the right is a table-like structure depicting cells and their components. The table has rows labeled "cell 1" through "cell 5", with "Subpools Pools" appearing between "cell 3" and "cell 4", and again between "cell 5" and the bottom of the diagram. The columns represent different stages or types of processing, with labels like "L2 SP", "L1 SP", and specific names like "L2 Pool NR TDD FR1 3SP", "Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2)", and "Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2)".
Within the cells, there are colored blocks representing different functionalities:
- Green blocks labeled "GC8" appear in the upper left sections of cells 1, 2, 4, and 5.
- Yellow blocks labeled "C4" are distributed across various cells and columns, often in pairs.
- Blue blocks labeled "C8" are present in the upper sections of cells 1, 2, and 3, and in the lower section of cell 4.
The "Action-1" label is also visually represented by a large blue arrow pointing from the top towards the diagram.
The table can be represented as follows:

| Cell/Pool | Column 1 (GC8) | Column 2 (GC8) | Column 3 (GC8) | Column 4 (C4 C4) | Column 5 (C4 C4) | Column 6 (L1 SP Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2)) | Column 7 (C8) | Column 8 (C8) | Column 9 (L1 SP Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2)) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **cell 1** | GC8 |  |  | C4 C4 |  |  | C8 |  |  |
| **cell 2** |  | GC8 |  |  | C4 C4 |  | C8 |  |  |
| **cell 3** |  |  | GC8 |  |  | L1 SP Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2) |  | C8 | L1 SP Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) |
| **Subpools Pools** | L2 SP | L2 SP | L2 SP |  |  |  |  |  |  |
| **cell 4** | GC8 |  |  | C4 C4 |  |  | C8 |  |  |
| **cell 5** |  | GC8 |  |  | C4 C4 | L1 SP Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2) |  | C8 | L1 SP Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) |
| **Subpools Pools** | L2 SP | L2 SP | L2 SP |  |  |  |  |  |  |

[image-2][image\_desc]The image displays a diagram illustrating a configuration change labeled "OR Action-2". The text on the left describes the action: "Reconfigured cell1 with 8DL8UL Streams 8RX receiver". Following this, under "After-2:", it details a "whole ABIP reset and re-deployed with CB010713 BB set type -B on each Half ABIP". It specifies that "Up to 3 cells with 8DL8UL 8RX receiver on each Half ABIP" are configured, with "UL L1 Pool #1 & #2" having "maxNumOfDataStreamsPerCell = 8" and "maxNumOfDataLayersPerCell = 4".
The main part of the image is a table-like structure representing a resource allocation or scheduling. The table is divided into rows representing "cell 1" through "cell 6" and "Subpools Pools". The columns represent different types of processing units or pools, with labels like "L2 SP", "L2 Pool NR TDD FR1 3SP", "L1 SP", "Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2)", and "Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2)".
Within the cells of this table, there are colored blocks representing allocated resources.
- Green blocks are labeled "GC8".
- Yellow blocks are labeled "C4".
- Blue blocks are labeled "C8".
The table shows a distribution of these resources across different cells and pools. For example, "cell 1" has "GC8" and "C4" resources in the initial columns, and "C8" resources in the later columns. The pattern repeats for subsequent cells, with variations in the placement and quantity of these resources. The "Subpools Pools" rows appear to be headers or separators.
An arrow pointing downwards from the text "OR Action-2" to the table visually connects the described action to the diagram.
Here is the table represented in markdown:

| Cell/Pool | Column 1 | Column 2 | Column 3 | Column 4 | Column 5 | Column 6 |
| --- | --- | --- | --- | --- | --- | --- |
| **cell 1** | GC8 |  | C4 C4 | C4 C4 | C8 | C8 |
| **cell 2** | GC8 |  | C4 C4 | C4 C4 | C8 | C8 |
| **cell 3** | GC8 |  | C4 C4 | C4 C4 | C8 | C8 |
| **Subpools Pools** | L2 SP | L2 SP | L2 SP | L1 SP | L1 SP | L1 SP |
|  | L2 Pool NR TDD FR1 3SP |  |  | Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) |  |
| **cell 4** | GC8 |  | C4 C4 | C4 C4 | C8 | C8 |
| **cell 5** | GC8 |  | C4 C4 | C4 C4 | C8 | C8 |
| **cell 6** | GC8 |  | C4 C4 | C4 C4 | C8 | C8 |
| **Subpools Pools** | L2 SP | L2 SP | L2 SP | L1 SP | L1 SP | L1 SP |
|  | L2 Pool NR TDD FR1 3SP |  |  | Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) |  |

---

**13.1.1.10.0-20.1.0-1.0-4.0-5**  (ID: `11489397`)

NR FR1 TDD
Reconfiguration Case-5

---

**13.1.1.10.0-20.1.0-1.0-4.0-5.0-1**  (ID: `11489414`)

NR FR1 TDD
11489414:
NR FR1 TDD
11489414:
NR FR1 TDD
11489414:
NR FR1 TDD
11489414:
NR FR1 TDD
11489414:
NR FR1 TDD
11489414:
NR FR1 TDD
11489414:
NR FR1 TDD
11489414:
NR FR1 TDD
11489414:
NR FR1 TDD
11489414:
NR FR1 TDD
11489414:
NR FR1 TDD
11489414:
NR FR1 TDD
11489414:
NR FR1 TDD
11489414:
NR FR1 TDD
11489414:
NR FR1 TDD
11489414:
NR FR1 TDD
11489414:
NR FR1 TDD
11489414:
NR FR1 TDD
11489414:
NR FR1 TDD
11489414:
NR FR1 TDD
Follow the BB set changes' rule in 5G\_L1\_13310\_replaced([11489302](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo1PvvEe-AqvopbP1qhQ)), L1 SW should support the following reconfiguration case-5:

- CB009142 BB set type-A refers to 5G\_L1\_12394\_replaced([11489015](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fEKavfvvEe-AqvopbP1qhQ))

- CB010713 BB set type-B refers to 5G\_L1\_13058\_replaced([11489295](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo0_vvEe-AqvopbP1qhQ))

Notice:  The details of User Scenario refer to SRAN\_SFS\_SISO.3992 UC-G-2-2 under /RA System General Modules/Site Solution/SRAN\_SFS\_Site\_Solution

[image-0][image\_desc]The image displays two configurations of a system, labeled "Before-1" and "OR Before-2". Both configurations describe "BB cell set" settings for a half ABIP receiver.
**Before-1 Configuration:**
This configuration has two BB cell sets:
\* **BB cell set 1: CB009142 BB set type-A on Half ABIP**
\* 6 cells with 8DL 8UL Streams 4RX receiver on Half APBIP UL L1 Pool #1.
\* `maxNumOfDataStreamsPerCell = 4`
\* `maxNumOfDataLayersPerCell = 2`
\* **BB cell set 2: CB010713 BB set type-B on another Half ABIP**
\* 2 cells with 8DL 8UL Streams 8RX receiver on Half APBIP UL L1 Pool #2.
\* `maxNumOfDataStreamsPerCell = 8`
\* `maxNumOfDataLayersPerCell = 4`
The visual representation shows a timeline or allocation of resources across different cells (cell 1 to cell 8, and subpools/pools).
**OR Before-2 Configuration:**
This configuration also has two BB cell sets, similar to Before-1, but with a slight difference in the second cell set:
\* **BB cell set 1: CB009142 BB set type-A on Half ABIP**
\* 6 cells with 8DL 8UL Streams 4RX receiver on Half APBIP UL L1 Pool #1.
\* `maxNumOfDataStreamsPerCell = 4`
\* `maxNumOfDataLayersPerCell = 2`
\* **BB cell set 2: CB010713 BB set type -B on another Half ABIP**
\* 3 cells with 8DL 8UL Streams 8RX receiver on Half APBIP UL L1 Pool #2.
\* `maxNumOfDataStreamsPerCell = 8`
\* `maxNumOfDataLayersPerCell = 4`
The visual representation for this configuration is also a timeline or resource allocation across cells (cell 1 to cell 9, and subpools/pools).
**Visual Table Representation (for Before-1 configuration):**

| Cell/Pool | Column 1 | Column 2 | Column 3 | Column 4 | Column 5 | Column 6 | Column 7 | Column 8 | Column 9 | Column 10 | Column 11 | Column 12 | Column 13 | Column 14 | Column 15 | Column 16 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **Cell 1** | GC8 |  |  |  | C4 C4 |  |  |  | C4 C4 |  |  |  |  |  |  |  |
| **Cell 2** | GC8 |  |  |  | C4 C4 |  |  |  | C4 C4 |  |  |  |  |  |  |  |
| **Cells 3...6** | GC8 | GC8 | GC8 | GC8 | GC8 | C4 C4 | C4 C4 | C4 C4 | C4 C4 | C4 C4 | C4 C4 | C4 C4 | C4 C4 | C4 C4 | C4 C4 | C4 C4 |
| **Subpools Pools** | L2 SP | L2 SP | L2 SP |  |  |  |  |  | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP |
|  | L2 Pool NR TDD FR1 3SP |  |  |  |  |  |  |  | Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) |
| **Cell 7** | GC8 |  |  |  | C4 C4 |  |  |  | C8 |  |  |  |  |  |  |  |
| **Cell 8** | GC8 |  |  |  | C4 C4 |  |  |  | C8 |  |  |  |  |  |  |  |
| **Subpools Pools** | L2 SP | L2 SP | L2 SP |  |  |  |  |  | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP |
|  | L2 Pool NR TDD FR1 3SP |  |  |  |  |  |  |  | Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) |
| **Visual Table Representation (for OR Before-2 configuration):** |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |

| Cell/Pool | Column 1 | Column 2 | Column 3 | Column 4 | Column 5 | Column 6 | Column 7 | Column 8 | Column 9 | Column 10 | Column 11 | Column 12 | Column 13 | Column 14 | Column 15 | Column 16 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **Cell 1** | GC8 |  |  |  | C4 C4 |  |  |  | C4 C4 |  |  |  |  |  |  |  |
| **Cell 2** | GC8 |  |  |  | C4 C4 |  |  |  | C4 C4 |  |  |  |  |  |  |  |
| **Cells 3...6** | GC8 | GC8 | GC8 | GC8 | GC8 | C4 C4 | C4 C4 | C4 C4 | C4 C4 | C4 C4 | C4 C4 | C4 C4 | C4 C4 | C4 C4 | C4 C4 | C4 C4 |
| **Subpools Pools** | L2 SP | L2 SP | L2 SP |  |  |  |  |  | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP |
|  | L2 Pool NR TDD FR1 3SP |  |  |  |  |  |  |  | Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) |
| **Cell 7** | GC8 |  |  |  | C4 C4 |  |  |  | C8 |  |  |  |  |  |  |  |
| **Cell 8** | GC8 |  |  |  | C4 C4 |  |  |  | C8 |  |  |  |  |  |  |  |
| **Cell 9** | GC8 |  |  |  | C4 C4 |  |  |  | C8 |  |  |  |  |  |  |  |
| **Subpools Pools** | L2 SP | L2 SP | L2 SP |  |  |  |  |  | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP | L1 SP |
|  | L2 Pool NR TDD FR1 3SP |  |  |  |  |  |  |  | Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) | Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2) |

[image-1][image\_desc]The image contains a text box with a light gray background and a black border. Inside the text box, there is text on the left and a blue arrow pointing downwards on the right.
The text on the left reads:
"Action on Before -1 or Before-2:
Reconfigured one 8DL8UL cell with 4Rx IRC receiver of BB cell set 1
to 8DL8UL cell with 8Rx IRC receiver in this ABIP."
The blue arrow on the right has the word "Action" written in white text on it. The arrow is pointing downwards and slightly to the right.[/image\_desc][image\_path]https://storage.googleapis.com/dng\_files/images/HTML\_pukkola\_5G\_L1\_Entity\_Level\_file\_11967.002.png[/image\_path][/image-1]

[image-2][image\_desc]The image displays two distinct sections, "After-1" and "OR After-2", each containing textual descriptions and corresponding visual representations of cell configurations. Both sections are divided into two main parts, "BB cell set 1" and "BB cell set 2", with further details provided for each.
**After-1 Section:**
\* **BB cell set 1: CB009142 BB set type-A on Half ABIP**
\* No impact on cell1-cell5 of BB cell set 1, cell 6 is deleted.
\* New cell added on BB cell set 2.
\* **BB cell set 2: CB010713 BB set type-B on another Half ABIP**
\* New cell 6 added and up to 3 cells with 8DL 8UL Streams 8RX receiver on Half APBIP.
\* UL L1 Pool #2:
\* maxNumOfDataStreamsPerCell = 8;
\* maxNumOfDataLayersPerCell = 4;
The visual representation for "After-1" shows a grid-like structure with cells labeled "cell 1", "cell 2", "3...5", "Subpools Pools", "cell 7", "Cell 6", and "cell 8". Within this grid, various blocks are depicted, representing different configurations: "GC8", "C4", "C8", "L2 SP", and "L1 SP". The "L2 SP" blocks are further described as "L2 Pool NR TDD FR1 3SP", and the "L1 SP" blocks as "Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2)" and "Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2)".
**OR After-2 Section:**
\* **cell reconfiguration failure report with fault ID.**
\* **BB cell set 1: CB009142 BB set type-A on Half ABIP**
\* No impact on BB cell set 1.
\* **BB cell set 2: CB010713 BB set type-B on another Half ABIP**
\* No impact on BB cell set 2.
The visual representation for "OR After-2" is similar to "After-1" but with some differences in the cell configurations. The cell labels are "cell 1", "cell 2", "3...6", "Subpools Pools", "cell 7", "Cell 8", and "cell 9". The blocks within this grid also include "GC8", "C4", "C8", "L2 SP", and "L1 SP", with similar descriptions for the "L2 SP" and "L1 SP" blocks.
**Table Representation:**
Due to the complex, multi-layered nature of the visual data with overlapping and varying block sizes, a direct markdown table representation would be overly simplified and lose significant detail. The visual elements represent a timeline or allocation of resources across different cells and subpools, with specific labels indicating the type and configuration of these resources.
The image can be interpreted as a comparison of two scenarios ("After-1" and "OR After-2") detailing changes in BB cell sets and their impact on cell configurations, visualized through a block diagram.[/image\_desc][image\_path]https://storage.googleapis.com/dng\_files/images/HTML\_pukkola\_5G\_L1\_Entity\_Level\_file\_11967.003.png[/image\_path][/image-2]

---

**13.1.1.10.0-20.1.0-1.0-4.0-6**  (ID: `11489421`)

NR FR1 TDD
Reconfiguration Case-6

---

**13.1.1.10.0-20.1.0-1.0-4.0-6.0-1**  (ID: `11489432`)

NR FR1 TDD
11489432:
NR FR1 TDD
11489432:
NR FR1 TDD
11489432:
NR FR1 TDD
11489432:
NR FR1 TDD
11489432:
NR FR1 TDD
11489432:
NR FR1 TDD
11489432:
NR FR1 TDD
11489432:
NR FR1 TDD
11489432:
NR FR1 TDD
11489432:
NR FR1 TDD
11489432:
NR FR1 TDD
11489432:
NR FR1 TDD
11489432:
NR FR1 TDD
11489432:
NR FR1 TDD
11489432:
NR FR1 TDD
11489432:
NR FR1 TDD
11489432:
NR FR1 TDD
11489432:
NR FR1 TDD
11489432:
NR FR1 TDD
11489432:
NR FR1 TDD
Follow the BB set changes' rule in 5G\_L1\_13310\_replaced([11489302](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo1PvvEe-AqvopbP1qhQ)), L1 SW should support the following reconfiguration case-6:

- CB010713 BB set type-B refers to 5G\_L1\_13058\_replaced([11489295](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo0_vvEe-AqvopbP1qhQ))

- CB009142 BB set type-A refers to 5G\_L1\_12394\_replaced([11489015](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fEKavfvvEe-AqvopbP1qhQ))

Notice:  The details of User Scenario refer to SRAN\_SFS\_SISO.3992 UC-G-2-3 under /RA System General Modules/Site Solution/SRAN\_SFS\_Site\_Solution

[image-0][image\_desc]The image displays a comparison of two configurations for a system labeled "(24R1 CB010713-G)". The top section describes the "Before" state, and the bottom section describes the "After" state, separated by an "Action" arrow.
**Before State:**
\* **Configuration:** CB010713 BB set type -B on Half ABIP.
\* **Cell Structure:** Up to 3 cells, each supporting 8DL 8UL Streams.
\* **Receiver:** 8RX receiver on Half ABIP.
\* **UL L1 Pool #1 Parameters:**
\* `maxNumOfDataStreamsPerCell = 8`
\* `maxNumOfDataLayersPerCell = 4`
\* **Visual Representation:** A diagram shows three cells (cell 1, cell 2, cell 3) with subpools and pools.
\* **Cell 1:** Contains a "GC8" block.
\* **Cell 2:** Contains a "GC8" block.
\* **Cell 3:** Contains a "GC8" block.
\* **Subpools/Pools Row:** Shows "L2 SP" blocks labeled "L2 Pool NR TDD FR1 3SP" and "L1 SP" blocks labeled "Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2a)" and "Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2a)".
\* **Top Row (Cells 1-3):** Shows "C4 C4" blocks and "C8" blocks distributed across the cells.
**Action:**
\* The action taken is to "Reconfigure all cells (cell1~3) to 8DL8UL streams with 4RX receiver".
**After State:**
\* **Configuration:** Whole ABIP reset and re-deployed with CB009142 BB set type -A on Half ABIP.
\* **Cell Structure:** 3 cells, each supporting 8DL 8UL Streams.
\* **Receiver:** 4RX receiver on Half APBIP.
\* **UL L1 Pool #1 Parameters:**
\* `maxNumOfDataStreamsPerCell = 4`
\* `maxNumOfDataLayersPerCell = 2`
\* **Visual Representation:** A diagram similar to the "Before" state, but with differences in the distribution of blocks.
\* **Cell 1:** Contains a "GC8" block.
\* **Cell 2:** Contains a "GC8" block.
\* **Cell 3:** Contains a "GC8" block.
\* **Subpools/Pools Row:** Shows "L2 SP" blocks labeled "L2 Pool NR TDD FR1 3SP" and "L1 SP" blocks labeled "Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2)" and "Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2)".
\* **Top Row (Cells 1-3):** Shows "C4 C4" blocks distributed across the cells. The "C8" blocks from the "Before" state are absent.
The diagram visually illustrates the change in the system's configuration, specifically the reduction in data streams and layers per cell, and the change in the receiver type, as a result of the described action.[/image\_desc][image\_path]https://storage.googleapis.com/dng\_files/images/HTML\_pukkola\_5G\_L1\_Entity\_Level\_file\_11969.001.png[/image\_path][/image-0]

---

**13.1.1.10.0-20.1.0-1.0-4.0-7**  (ID: `11489438`)

NR FR1 TDD
Reconfiguration Case-7

---

**13.1.1.10.0-20.1.0-1.0-4.0-7.0-1**  (ID: `11489450`)

NR FR1 TDD
11489450:
NR FR1 TDD
11489450:
NR FR1 TDD
11489450:
NR FR1 TDD
11489450:
NR FR1 TDD
11489450:
NR FR1 TDD
11489450:
NR FR1 TDD
11489450:
NR FR1 TDD
11489450:
NR FR1 TDD
11489450:
NR FR1 TDD
11489450:
NR FR1 TDD
11489450:
NR FR1 TDD
11489450:
NR FR1 TDD
11489450:
NR FR1 TDD
11489450:
NR FR1 TDD
11489450:
NR FR1 TDD
11489450:
NR FR1 TDD
11489450:
NR FR1 TDD
11489450:
NR FR1 TDD
11489450:
NR FR1 TDD
11489450:
NR FR1 TDD
Follow the BB set changes' rule in 5G\_L1\_13310\_replaced([11489302](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo1PvvEe-AqvopbP1qhQ)), L1 SW should support the following reconfiguriaton case-7:

- CB010713 BB set type-B refers to 5G\_L1\_13058\_replaced([11489295](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo0_vvEe-AqvopbP1qhQ))

- CB009142 BB set type-A refers to 5G\_L1\_12394\_replaced([11489015](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fEKavfvvEe-AqvopbP1qhQ))

Notice:  The details of User Scenario refer to SRAN\_SFS\_SISO.3992 UC-G-2-4 under /RA System General Modules/Site Solution/SRAN\_SFS\_Site\_Solution

[image-0][image\_desc]The image displays a diagram illustrating two BB (Baseband) cell sets, labeled "BB cell set 1" and "BB cell set 2", with their configurations before a change. The diagram is divided into two main sections, each representing a cell set. Each section is further divided into rows representing cells (cell 1, cell 2, cell 3, cell 4, cell 5, and 6...8) and columns representing different pools or stages (L2 SP, L1 SP).
**BB cell set 1: CB010713 BB set type -B on Half ABIP**
This set is described as supporting "Up to 3 cells 8DL 8UL Streams" with a "mixture of 8RX/4RX receiver on Half ABIP". The "UL L1 Pool #1" has the following parameters:
\* `maxNumOfDataStreamsPerCell = 8;`
\* `maxNumOfDataLayersPerCell = 4;`
The diagram for this set shows:
\* **Cell 1:** Contains "GC8" in the L2 SP section and "C8" in the L1 SP section.
\* **Cell 2:** Contains "GC8" in the L2 SP section and "C4", "C4" in the L1 SP section.
\* **Cell 3:** Contains "GC8" in the L2 SP section and "C4", "C4" in the L1 SP section. The L2 SP section for cell 3 shows "L2 SP" repeated three times, and the L1 SP section is labeled "Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2a)".
**BB cell set 2: CB0009142 set type -A on Half ABIP**
This set is described as supporting "Up to 5 cells 8DL 8UL Streams" with a "4RX receiver on Half ABIP". The "UL L1 Pool #2" has the following parameters:
\* `maxNumOfDataStreamsPerCell = 4;`
\* `maxNumOfDataLayersPerCell = 2;`
The diagram for this set shows:
\* **Cell 4:** Contains "GC8" in the L2 SP section and "C4", "C4" in the L1 SP section.
\* **Cell 5:** Contains "GC8", "GC8", "GC8" in the L2 SP section and "C4", "C4" in the L1 SP section. The L2 SP section for cell 5 shows "L2 SP" repeated three times, and the L1 SP section is labeled "Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2)".
\* **Cells 6...8:** The diagram shows "C4", "C4", "C4", "C4", "C4", "C4" in the L1 SP section, labeled "Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2)".
The diagram uses colored blocks (green for GC8, yellow for C4, blue for C8) to represent data streams or configurations within the different pools and cells. The text "(24R1 CB010713 -G)" appears at the top left of the image. The right side of the diagram has labels for "cell 1" through "cell 5" and "6...8", followed by "Subpools Pools".[/image\_desc][image\_path]https://storage.googleapis.com/dng\_files/images/HTML\_pukkola\_5G\_L1\_Entity\_Level\_file\_11971.001.png[/image\_path][/image-0]

[image-1][image\_desc]The image displays a diagram illustrating changes to a system configuration, specifically focusing on "BB cell sets" and their associated "pools" and "cells." The diagram is divided into two main sections: "Action" and "After."
The "Action" section states: "Added one new 8DL8UL cell with 4RX receiver." This indicates a modification has been made to the system.
The "After" section details the impact of this action on two different BB cell sets:
**BB cell set 1: CB010713 BB set type -B on Half ABIP**
\* "No impact on BB cell set 1"
**BB cell set 2: CB0009142 set type -A on Half ABIP**
\* "new 8DL8UL cell 9 with 4RX receiver added and up to 6 cells 8DL 8UL Streams"
\* "With 4RX receiver on Half ABIP"
\* "UL L1 Pool #2:"
\* "maxNumOfDataStreamsPerCell = 4;"
\* "maxNumOfDataLayersPerCell = 2;"
The right side of the image presents a visual representation of the BB cell sets, broken down into "cells" (cell 1 through cell 5, and a range 6...9) and "Subpools Pools." Each cell is further divided into horizontal sections representing different layers or pools, labeled with abbreviations like "GC8," "L2 SP," and "L1 SP," along with specific pool names like "L2 Pool NR TDD FR1 3SP," "Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2a)," and "Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2)." Different colored blocks within these sections (green, yellow, blue) likely represent different types of data streams or configurations.
The table below summarizes the visual representation of the BB cell sets:
| Cell | Top Row (e.g., GC8)[/image\_desc][image\_path]https://storage.googleapis.com/dng\_files/images/HTML\_pukkola\_5G\_L1\_Entity\_Level\_file\_11971.002.png[/image\_path][/image-1]

---

**13.1.1.10.0-20.1.0-1.0-4.0-8**  (ID: `11489456`)

NR FR1 TDD
Reconfiguration Case-8

---

**13.1.1.10.0-20.1.0-1.0-4.0-8.0-1**  (ID: `11489471`)

NR FR1 TDD
11489471:
NR FR1 TDD
11489471:
NR FR1 TDD
11489471:
NR FR1 TDD
11489471:
NR FR1 TDD
11489471:
NR FR1 TDD
11489471:
NR FR1 TDD
11489471:
NR FR1 TDD
11489471:
NR FR1 TDD
11489471:
NR FR1 TDD
11489471:
NR FR1 TDD
11489471:
NR FR1 TDD
11489471:
NR FR1 TDD
11489471:
NR FR1 TDD
11489471:
NR FR1 TDD
11489471:
NR FR1 TDD
11489471:
NR FR1 TDD
11489471:
NR FR1 TDD
11489471:
NR FR1 TDD
11489471:
NR FR1 TDD
11489471:
NR FR1 TDD
Follow the BB set changes' rule in 5G\_L1\_13310\_replaced([11489302](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo1PvvEe-AqvopbP1qhQ)), L1 SW should support the following reconfiguration on concurrent mode, see case-8:

- CB009014 BB set type-A refers to 5G\_L1\_11160\_replaced([11486889](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fD-NfPvvEe-AqvopbP1qhQ))

- CB010713 BB set type-B refers to 5G\_L1\_13058\_replaced([11489295](https://dn-prod.ext.net.nokia.com/rm/resources/BI_fELo0_vvEe-AqvopbP1qhQ))

Notice:  The details of User Scenario refer to SRAN\_SFS\_SISO.3992 UC-G-2-5 under /RA System General Modules/Site Solution/SRAN\_SFS\_Site\_Solution

[image-0][image\_desc]The image displays a diagram illustrating two different Baseband (BB) cell sets, labeled "BB cell set 1" and "BB cell set 2," both operating on "Half ABIP."
**BB cell set 1: CB009014 BB set type -A on Half ABIP**
This set is configured for up to 12 NR FDD cells, each supporting up to 20 MHz bandwidth with 4T4R antennas. PRB pooling is enabled.
\* **UL L1 Pool #1:**
\* `maxNumOfDataStreamsPerCell = 4`
\* `maxNumOfDataLayersPerCell = 2`
The diagram shows a breakdown of resource allocation across different pools and cells. The top row indicates 12 cells, each with "GAn" and "20" MHz, and "L2 SP."
Below this, the diagram is divided into sections:
\* **L2 Pool NR FDD 6SP:** This section shows a "GC8" resource allocated in the first cell.
\* **Thor DL L1 Pool NR FDD 2SP:** This section shows "C4" and "C4" resources allocated in the 4th and 5th cells, and "C4" and "C4" in the 7th and 8th cells.
\* **Thor UL L1 Pool NR FDD 2SP:** This section shows a "C8" resource allocated in the 10th cell, and a "C4" resource allocated in the 11th cell.
The right side labels these as "Subpools," "Pools," "cell 13," "cell 14," and "cell 15."
**BB cell set 2: CB010713 BB set type -B on Half ABIP**
This set is configured for up to 3 NR TDD cells, supporting 8DL and 8UL streams, with a mixture of 8RX/4RX receivers.
\* **UL L1 Pool #2:**
\* `maxNumOfDataStreamsPerCell = 8`
\* `maxNumOfDataLayersPerCell = 4`
The diagram for this set shows:
\* **L2 Pool NR TDD FR1 3SP:** This section shows a "GC8" resource allocated in the first cell, and another "GC8" in the 4th cell, and a third "GC8" in the 7th cell.
\* **Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2a):** This section shows "C4" and "C4" resources allocated in the 4th and 5th cells, and "C4" and "C4" in the 7th and 8th cells.
\* **Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2a):** This section shows "C4" and "C4" resources allocated in the 10th and 11th cells.
The right side labels these as "Subpools," "Pools."
The overall structure is a comparison of two BB cell set configurations, detailing their capabilities and resource allocations in a visual table format.[/image\_desc][image\_path]https://storage.googleapis.com/dng\_files/images/HTML\_pukkola\_5G\_L1\_Entity\_Level\_file\_11973.001.png[/image\_path][/image-0]

[image-1][image\_desc]The image displays a document with text and a table. The text describes an action taken and its consequences. The action involved adding a new NR TDD 8DL8UL cell with an 8RX/4RX receiver. The "After" section reports a failure during cell addition. It then details two BB cell sets, "BB cell set 1" and "BB cell set 2", with their respective identifiers and types. For both cell sets, it states "No impact".
The table, located below the text, visually represents the configuration of cells. It is divided into columns and rows, with headers and labels indicating different components and their assignments.
Here's a breakdown of the table's structure and content:
**Top Row Headers:** These headers appear to represent different types of cells or configurations, with labels like "GAn 20" and "An 20". There are multiple instances of these headers, suggesting a breakdown of resources or channels.
**Second Row Headers:** Underneath the first row, there are labels like "L2 SP" and "L1 SP", likely indicating different layers or processing stages.
**Main Table Body:** This section contains colored cells (green, yellow, and blue) with labels such as "GC8", "C4", and "C8". These likely represent specific configurations or assignments within the cell structure. The table is organized into horizontal sections labeled "L2 Pool NR FDD 6SP", "L2 Pool NR TDD FR1 3SP", "Thor DL L1 Pool NR FDD 2SP", "Thor UL L1 Pool NR FDD 2SP", and "Thor DL L1 Pool NR TDD FR1 (eCPRI 7-2a)", and "Thor UL L1 Pool NR TDD FR1 (eCPRI 7-2a)".
**Right Side Labels:** On the far right, there are labels indicating "12 cells", "Subpools", "Pools", "cell 13", "cell 14", "cell 15", and again "Subpools", "Pools". These likely provide context for the table's data, possibly relating to the number of cells, their grouping, and specific cell identifiers.
**Markdown Representation of the Table:**
| Header 1 | Header 2 | Header 3 | Header 4 | Header 5 | Header 6 | Header 7 | Header 8 | Header 9 | Header 10 | Header 11 | Header 12 | Header 13 | Header 14 | Header 15 | Header 16 | Header 17 | Header 18 | Header 19 | Header 20 | Header 21 | Header 22 | Header 23 | Header 24 | Header 25 | Header 26 | Header 27 | Header 28 | Header 29 | Header 30 | Header 31 | Header 32 | Header 33 | Header 34 | Header 35 | Header 36 | Header 37 | Header 38 | Header 39 | Header 40 | Header 41 | Header 42 | Header 43 | Header 44 | Header 45 | Header 46 | Header 47 | Header 48 | Header 49 | Header 50 | Header 51 | Header 52 | Header 53 | Header 54 | Header 55 | Header 56 | Header 57 | Header 58 | Header 59 | Header 60 | Header 61 | Header 62 | Header 63 | Header 64 | Header 65 | Header 66 | Header 67 | Header 68 | Header 69 | Header 70 | Header 71 | Header 72 | Header 73 | Header 74 | Header 75 | Header 76 | Header 77 | Header 78 | Header 79 | Header 80 | Header 81 | Header 82 | Header 83 | Header 84 | Header 85 | Header 86 | Header 87 | Header 88 | Header 89 | Header 90 | Header 91 | Header 92 | Header 93 | Header 94 | Header 95 | Header 96 | Header 97 | Header 98 | Header 99 | Header 100 | Header 101 | Header 102 | Header 103 | Header 104 | Header 105 | Header 106 | Header 107 | Header 108 | Header 109 | Header 110 | Header 111 | Header 112 | Header 113 | Header 114 | Header 115 | Header 116 | Header 117 | Header 118 | Header 119 | Header 120 | Header 121 | Header 122 | Header 123 | Header 124 | Header 125 | Header 126 | Header 127 | Header 128 | Header 129 | Header 130 | Header 131 | Header 132 | Header 133 | Header 134 | Header 135 | Header 136 | Header 137 | Header 138 | Header 139 | Header 140 | Header 141 | Header 142 | Header 143 | Header 144 | Header 145 | Header 146 | Header 147 | Header 148 | Header 149 | Header 150 | Header 151 | Header 152 | Header 153 | Header 154 | Header 155 | Header 156 | Header 157 | Header 158 | Header 159 | Header 160 | Header 161 | Header 162 | Header 163 | Header 164 | Header 165 | Header 166 | Header 167 | Header 168 | Header 169 | Header 170 | Header 171 | Header 172 | Header 173 | Header 174 | Header 175 | Header 176 | Header 177 | Header 178 | Header 179 | Header 180 | Header 181 | Header 182 | Header 183 | Header 184 | Header 185 | Header 186 | Header 187 | Header 188 | Header 189 | Header 190 | Header 191 | Header 192 | Header 193 | Header 194 | Header 195 | Header 196 | Header 197 | Header 198 | Header 199 | Header 200 | Header 201 | Header 202 | Header 203 | Header 204 | Header 205 | Header 206 | Header 207 | Header 208 | Header 209 | Header 210 | Header 211 | Header 212 | Header 213 | Header 214 | Header 215 | Header 216 | Header 217 | Header 218 | Header 219 | Header 220 | Header 221 | Header 222 | Header 223 | Header 224 | Header 225 | Header 226 | Header 227 | Header 228 | Header 229 | Header 230 | Header 231 | Header 232 | Header 233 | Header 234 | Header 235 | Header 236 | Header 237 | Header 238 | Header 239 | Header 240 | Header 241 | Header 242 | Header 243 | Header 244 | Header 245 | Header 246 | Header 247 | Header 248 | Header 249 | Header 250 | Header 251 | Header 252 | Header 253 | Header 254 | Header 255 | Header 256 | Header 257 | Header 258 | Header 259 | Header 260 | Header 261 | Header 262 | Header 263 | Header 264 | Header 265 | Header 266 | Header 267 | Header 268 | Header 269 | Header 270 | Header 271 | Header 272 | Header 273 | Header 274 | Header 275 | Header 276 | Header 277 | Header 278 | Header 279 | Header 280 | Header 281 | Header 282 | Header 283 | Header 284 | Header 285 | Header 286 | Header 287 | Header 288 | Header 289 | Header 290 | Header 291 | Header 292 | Header 293 | Header 294 | Header 295 | Header 296 | Header 297 | Header 298 | Header 299 | Header 300 | Header 301 | Header 302 | Header 303 | Header 304 | Header 305 | Header 306 | Header 307 | Header 308 | Header 309 | Header 310 | Header 311 | Header 312 | Header 313 | Header 314 | Header 315 | Header 316 | Header 317 | Header 318 | Header 319 | Header 320 | Header 321 | Header 322 | Header 323 | Header 324 | Header 325 | Header 326 | Header 327 | Header 328 | Header 329 | Header 330 | Header 331 | Header 332 | Header 333 | Header 334 | Header 335 | Header 336 | Header 337 | Header 338 | Header 339 | Header 340 | Header 341 | Header 342 | Header 343 | Header 344 | Header 345 | Header 346 | Header 347 | Header 348 | Header 349 | Header 350 | Header 351 | Header 352 | Header 353 | Header 354 | Header 355 | Header 356 | Header 357 | Header 358 | Header 359 | Header 360 | Header 361 | Header 362 | Header 363 | Header 364 | Header 365 | Header 366 | Header 367 | Header 368 | Header 369 | Header 370 | Header 371 | Header 372 | Header 373 | Header 374 | Header 375 | Header 376 | Header 377 | Header 378 | Header 379 | Header 380 | Header 381 | Header 382 | Header 383 | Header 384 | Header 385 | Header 386 | Header 387 | Header 388 | Header 389 | Header 390 | Header 391 | Header 392 | Header 393 | Header 394 | Header 395 | Header 396 | Header 397 | Header 398 | Header 399 | Header 400 | Header 401 | Header 402 | Header 403 | Header 404 | Header 405 | Header 406 | Header 407 | Header 408 | Header 409 | Header 410 | Header 411 | Header 412 | Header 413 | Header 414 | Header 415 | Header 416 | Header 417 | Header 418 | Header 419 | Header 420 | Header 421 | Header 422 | Header 423 | Header 424 | Header 425 | Header 426 | Header 427 | Header 428 | Header 429 | Header 430 | Header 431 | Header 432 | Header 433 | Header 434 | Header 435 | Header 436 | Header 437 | Header 438 | Header 439 | Header 440 | Header 441 | Header 442 | Header 443 | Header 444 | Header 445 | Header 446 | Header 447 | Header 448 | Header 449 | Header 450 | Header 451 | Header 452 | Header 453 | Header 454 | Header 455 | Header 456 | Header 457 | Header 458 | Header 459 | Header 460 | Header 461 | Header 462 | Header 463 | Header 464 | Header 465 | Header 466 | Header 467 | Header 468 | Header 469 | Header 470 | Header 471 | Header 472 | Header 473 | Header 474 | Header 475 | Header 476 | Header 477 | Header 478 | Header 479 | Header 480 | Header 481 | Header 482 | Header 483 | Header 484 | Header 485 | Header 486 | Header 487 | Header 488 | Header 489 | Header 490 | Header 491 | Header 492 | Header 493 | Header 494 | Header 495 | Header 496 | Header 497 | Header 498 | Header 499 | Header 500 | Header 501 | Header 502 | Header 503 | Header 504 | Header 505 | Header 506 | Header 507 | Header 508 | Header 509 | Header 510 | Header 511 | Header 512 | Header 513 | Header 514 | Header 515 | Header 516 | Header 517 | Header 518 | Header 519 | Header 520 | Header 521 | Header 522 | Header 523 | Header 524 | Header 525 | Header 526 | Header 527 | Header 528 | Header 529 | Header 530 | Header 531 | Header 532 | Header 533 | Header 534 | Header 535 | Header 536 | Header 537 | Header 538 | Header 539 | Header 540 | Header 541 | Header 542 | Header 543 | Header 544 | Header 545 | Header 546 | Header 547 | Header 548 | Header 549 | Header 550 | Header 551 | Header 552 | Header 553 | Header 554 | Header 555 | Header 556 | Header 557 | Header 558 | Header 559 | Header 560 | Header 561 | Header 562 | Header 563 | Header 564 | Header 565 | Header 566 | Header 567 | Header 568 | Header 569 | Header 570 | Header 571 | Header 572 | Header 573 | Header 574 | Header 575 | Header 576 | Header 577 | Header 578 | Header 579 | Header 580 | Header 581 | Header 582 | Header 583 | Header 584 | Header 585 | Header 586 | Header 587 | Header 588 | Header 589 | Header 590 | Header 591 | Header 592 | Header 593 | Header 594 | Header 595 | Header 596 | Header 597 | Header 598 | Header 599 | Header 600 | Header 601 | Header 602 | Header 603 | Header 604 | Header 605 | Header 606 | Header 607 | Header 608 | Header 609 | Header 610 | Header 611 | Header 612 | Header 613 | Header 614 | Header 615 | Header 616 | Header 617 | Header 618 | Header 619 | Header 620 | Header 621 | Header 622 | Header 623 | Header 624 | Header 625 | Header 626 | Header 627 | Header 628 | Header 629 | Header 630 | Header 631 | Header 632 | Header 633 | Header 634 | Header 635 | Header 636 | Header 637 | Header 638 | Header 639 | Header 640 | Header 641 | Header 642 | Header 643 | Header 644 | Header 645 | Header 646 | Header 647 | Header 648 | Header 649 | Header 650 | Header 651 | Header 652 | Header 653 | Header 654 | Header 655 | Header 656 | Header 657 | Header 658 | Header 659 | Header 660 | Header 661 | Header 662 | Header 663 | Header 664 | Header 665 | Header 666 | Header 667 | Header 668 | Header 669 | Header 670 | Header 671 | Header 672 | Header 673 | Header 674 | Header 675 | Header 676 | Header 677 | Header 678 | Header 679 | Header 680 | Header 681 | Header 682 | Header 683 | Header 684 | Header 685 | Header 686 | Header 687 | Header 688 | Header 689 | Header 690 | Header 691 | Header 692 | Header 693 | Header 694 | Header 695 | Header 696 | Header 697 | Header 698 | Header 699 | Header 700 | Header 701 | Header 702 | Header 703 | Header 704 | Header 705 | Header 706 | Header 707 | Header 708 | Header 709 | Header 710 | Header 711 | Header 712 | Header 713 | Header 714 | Header 715 | Header 716 | Header 717 | Header 718 | Header 719 | Header 720 | Header 721 | Header 722 | Header 723 | Header 724 | Header 725 | Header 726 | Header 727 | Header 728 | Header 729 | Header 730 | Header 731 | Header 732 | Header 733 | Header 734 | Header 735 | Header 736 | Header 737 | Header 738 | Header 739 | Header 740 | Header 741 | Header 742 | Header 743 | Header 744 | Header 745 | Header 746 | Header 747 | Header 748 | Header 749 | Header 750 | Header 751 | Header 752 | Header 753 | Header 754 | Header 755 | Header 756 | Header 757 | Header 758 | Header 759 | Header 760 | Header 761 | Header 762 | Header 763 | Header 764 | Header 765 | Header 766 | Header 767 | Header 768 | Header 769 | Header 770 | Header 771 | Header 772 | Header 773 | Header 774 | Header 775 | Header 776 | Header 777 | Header 778 | Header 779 | Header 780 | Header 781 | Header 782 | Header 783 | Header 784 | Header 785 | Header 786 | Header 787 | Header 788 | Header 789 | Header 790 | Header 791 | Header 792 | Header 793 | Header 794 | Header 795 | Header 796 | Header 797 | Header 798 | Header 799 | Header 800 | Header 801 | Header 802 | Header 803 | Header 804 | Header 805 | Header 806 | Header 807 | Header 808 | Header 809 | Header 810 | Header 811 | Header 812 | Header 813 | Header 814 | Header 815 | Header 816 | Header 817 | Header 818 | Header 819 | Header 820 | Header 821 | Header 822 | Header 823 | Header 824 | Header 825 | Header 826 | Header 827 | Header 828 | Header 829 | Header 830 | Header 831 | Header 832 | Header 833 | Header 834 | Header 835 | Header 836 | Header 837 | Header 838 | Header 839 | Header 840 | Header 841 | Header 842 | Header 843 | Header 844 | Header 845 | Header 846 | Header 847 | Header 848 | Header 849 | Header 850 | Header 851 | Header 852 | Header 853 | Header 854 | Header 855 | Header 856 | Header 857 | Header 858 | Header 859 | Header 860 | Header 861 | Header 862 | Header 863 | Header 864 | Header 865 | Header 866 | Header 867 | Header 868 | Header 869 | Header 870 | Header 871 | Header 872 | Header 873 | Header 874 | Header 875 | Header 876 | Header 877 | Header 878 | Header 879 | Header 880 | Header 881 | Header 882 | Header 883 | Header 884 | Header 885 | Header 886 | Header 887 | Header 888 | Header 889 | Header 890 | Header 891 | Header 892 | Header 893 | Header 894 | Header 895 | Header 896 | Header 897 | Header 898 | Header 899 | Header 900 | Header 901 | Header 902 | Header 903 | Header 904 | Header 905 | Header 906 | Header 907 | Header 908 | Header 909 | Header 910 | Header 911 | Header 912 | Header 913 | Header 914 | Header 915 | Header 916 | Header 917 | Header 918 | Header 919 | Header 920 | Header 921 | Header 922 | Header 923 | Header 924 | Header 925 | Header 926 | Header 927 | Header 928 | Header 929 | Header 930 | Header 931 | Header 932 | Header 933 | Header 934 | Header 935 | Header 936 | Header 937 | Header 938 | Header 939 | Header 940 | Header 941 | Header 942 | Header 943 | Header 944 | Header 945 | Header 946 | Header 947 | Header 948 | Header 949 | Header 950 | Header 951 | Header 952 | Header 953 | Header 954 | Header 955 | Header 956 | Header 957 | Header 958 | Header 959 | Header 960 | Header 961 | Header 962 | Header 963 | Header 964 | Header 965 | Header 966 | Header 967 | Header 968 | Header 969 | Header 970 | Header 971 | Header 972 | Header 973 | Header 974 | Header 975 | Header 976 | Header 977 | Header 978 | Header 979 | Header 980 | Header 981 | Header 982 | Header 983 | Header 984 | Header 985 | Header 986 | Header 987 | Header 988 | Header 989 | Header 990 | Header 991 | Header 992 | Header 993 | Header 994 | Header 995 | Header 996 | Header 997 | Header 998 | Header 999 | Header 1000 | Header 1001 | Header 1002 | Header 1003 | Header 1004 | Header 1005 | Header 1006 | Header 1007 | Header 1008 | Header 1009 | Header 1010 | Header 1011 | Header 1012 | Header 1013 | Header 1014 | Header 1015 | Header 1016 | Header 1017 | Header 1018 | Header 1019 | Header 1020 | Header 1021 | Header 1022 | Header 1023 | Header 1024 | Header 1025 | Header 1026 | Header 1027 | Header 1028 | Header 1029 | Header 1030 | Header 1031 | Header 1032 | Header 1033 | Header 1034 | Header 1035 | Header 1036 | Header 1037 | Header 1038 | Header 1039 | Header 1040 | Header 1041 | Header 1042 | Header 1043 | Header 1044 | Header 1045 | Header 1046 | Header 1047 | Header 1048 | Header 1049 | Header 1050 | Header 1051 | Header 1052 | Header 1053 | Header 1054 | Header 1055 | Header 1056 | Header 1057 | Header 1058 | Header 1059 | Header 1060 | Header 1061 | Header 1062 | Header 1063 | Header 1064 | Header 1065 | Header 1066 | Header 1067 | Header 1068 | Header 1069 | Header 1070 | Header 1071 | Header 1072 | Header 1073 | Header 1074 | Header 1075 | Header 1076 | Header 1077 | Header 1078 | Header 1079 | Header 1080 | Header 1081 | Header 1082 | Header 1083 | Header 1084 | Header 1085 | Header 1086 | Header 1087 | Header 1088 | Header 1089 | Header 1090 | Header 1091 | Header 1092 | Header 1093 | Header 1094 | Header 1095 | Header 1096 | Header 1097 | Header 1098 | Header 1099 | Header 1100 | Header 1101 | Header 1102 | Header 1103 | Header 1104 | Header 1105 | Header 1106 | Header 1107 | Header 1108 | Header 1109 | Header 1110 | Header 1111 | Header 1112 | Header 1113 | Header 1114 | Header 1115 | Header 1116 | Header 1117 | Header 1118 | Header 1119 | Header 1120 | Header 1121 | Header 1122 | Header 1123 | Header 1124 | Header 1125 | Header 1126 | Header 1127 | Header 1128 | Header 1129 | Header 1130 | Header 1131 | Header 1132 | Header 1133 | Header 1134 | Header 1135 | Header 1136 | Header 1137 | Header 1138 | Header 1139 | Header 1140 | Header 1141 | Header 1142 | Header 1143 | Header 1144 | Header 1145 | Header 1146 | Header 1147 | Header 1148 | Header 1149 | Header 1150 | Header 1151 | Header 1152 | Header 1153 | Header 1154 | Header 1155 | Header 1156 | Header 1157 | Header 1158 | Header 1159 | Header 1160 | Header 1161 | Header 1162 | Header 1163 | Header 1164 | Header 1165 | Header 1166 | Header 1167 | Header 1168 | Header 1169 | Header 1170 | Header 1171 | Header 1172 | Header 1173 | Header 1174 | Header 1175 | Header 1176 | Header 1177 | Header 1178 | Header 1179 | Header 1180 | Header 1181 | Header 1182 | Header 1183 | Header 1184 | Header 1185 | Header 1186 | Header 1187 | Header 1188 | Header 1189 | Header 1190 | Header 1191 | Header 1192 | Header 1193 | Header 1194 | Header 1195 | Header 1196 | Header 1197 | Header 1198 | Header 1199 | Header 1200 | Header 1201 | Header 1202 | Header 1203 | Header 1204 | Header 1205 | Header 1206 | Header 1207 | Header 1208 | Header 1209 | Header 1210 | Header 1211 | Header 1212 | Header 1213 | Header 1214 | Header 1215 | Header 1216 | Header 1217 | Header 1218 | Header 1219 | Header 1220 | Header 1221 | Header 1222 | Header 1223 | Header 1224 | Header 1225 | Header 1226 | Header 1227 | Header 1228 | Header 1229 | Header 1230 | Header 1231 | Header 1232 | Header 1233 | Header 1234 | Header 1235 | Header 1236 | Header 1237 | Header 1238 | Header 1239 | Header 1240 | Header 1241 | Header 1242 | Header 1243 | Header 1244 | Header 1245 | Header 1246 | Header 1247 | Header 1248 | Header 1249 | Header 1250 | Header 1251 | Header 1252 | Header 1253 | Header 1254 | Header 1255 | Header 1256 | Header 1257 | Header 1258 | Header 1259 | Header 1260 | Header[/image\_desc][image\_path]https://storage.googleapis.com/dng\_files/images/HTML\_pukkola\_5G\_L1\_Entity\_Level\_file\_11973.002.png[/image\_path][/image-1]

---

## Sections

- [13.2 DL](13.2_DL.md)
- [13.3 UL](13.3_UL.md)
- [13.4 Baseband block Requirements and EFS](13.4_Baseband_block_Requirements_and_EFS.md)
- [13.5 Timing &amp; Synchronization](13.5_Timing_amp_Synchronization.md)
- [13.6 L1 Interface changes summary](13.6_L1_Interface_changes_summary.md)
