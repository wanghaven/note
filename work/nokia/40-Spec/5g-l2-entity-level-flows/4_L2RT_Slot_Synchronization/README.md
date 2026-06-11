# 4 L2RT Slot Synchronization

**4.0-3**  (ID: `11177470`)

L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
11177470:
L2RT Slot Synchronization
5G-L2-RT slot synchronisation timing diagram.
 
[PR419531]: Below figure and radio\_frame\_start values are valid only for CPRI case. For eCPRI timing BTS\_E2E\_TIMING\_831,5G\_L1\_5G21A\_132 and 5G\_L2\_5455\_replaced([11141975](https://dn-prod.ext.net.nokia.com/rm/resources/BI_23rj-vvTEe-AqvopbP1qhQ)) shall be used. [End PR419531]
 
Following diagram shows scheduling timing dependency between 5G-L2-PS/LO, 5G-L1-DL and BBP:
[image-0][image\_desc]The image is a diagram illustrating timing parameters related to radio frames and network layers. A horizontal red line at the top indicates the "radio\_frame\_start" with an arrow pointing to the right, suggesting the progression of time.
Several vertical blue arrows represent delays or offsets. The longest arrow, labeled "L2-LO delay" in red, originates from a point below and points upwards. To the left of this arrow, two labels are positioned: "L2-LO BTU offset" and "L2-PS BTU offset".
To the right of the "L2-LO delay" arrow, there are two shorter blue arrows pointing upwards. Above these arrows, there are three labels: "Slot offset" in purple, and two instances of "OneWayHwDelayDI" in green.
At the bottom right of the image, there is a legend explaining the color coding of the parameters:
\* **Green**: OAM/CP/L2 parameters
\* **Red**: Hardcoded values at L2 and L1 side
\* **Purple**: parameters computed at L2 side
\* **Black**: L1 parameters (only seen at L1 level)
The diagram visually represents different timing aspects and their association with network layers (L1 and L2) and specific parameters like OAM/CP.[/image\_desc][image\_path]https://storage.googleapis.com/dng\_files/images/HTML\_m1dng\_5G\_L2\_Entity\_Level\_Flows\_file\_86.001.png[/image\_path][/image-0]
5G-L2-PS/LO are woken up at each NR-slot by EO slotSynchroInd sent by BBP.
 
Time when EO slotSynchroInd is sent from BBP to L2-PS/LO is defined as an offset relative to BCN RP1 (GPS trigger):
 5G-L2-PS BTU offset = radio\_frame\_start – oneWayHwDelayDl
 5G-L2-LO BTU offset = radio\_frame\_start – oneWayHwDelayDl + L2-LO delay
Where:
 radio\_frame\_start represents offset between BCN time at air interface time and BCN time at GPS interface with following value in L1 R5.0.
[Before CB007597-C] These values are hardcoded in 5G-L2-RT and get from configuration file in 5G-L1-DL:

|  |  |  |
| --- | --- | --- |
| SCS (KHz) | 15 | 30-120 |
| radio\_frame\_start value (us) | [Before 5GC001904-A] 437.419 [End  5GC001904-A] [5GC001904-A] 86 (105600 UTU) [End  5GC001904-A] | [Before 5GC000579-C] 50 [Before 5GC000579-A] 50 [End 5GC000579-A]   [5GC000579-C] 86 [5GC000579-C] 86 (105600 UTU) [End 5GC000579-C] Note: above change was previously introduced with [5GC000579-C] but is accelerated due to  [CAS-221406-Z5-M3] |
|  |  |  |
| [CB007597-C] |  |  |
|  |  |  |
| radio\_frame\_start is derived from OAM in two components : sub-10ms component and SFN-component as desribed in BTS\_E2E\_TIMING\_981. |  |  |
|  |  |  |
| [End CB007597-C] |  |  |
|  |  |  |
|  oneWayHwDelayDl represents delay between CPRI output and RU output and is provided in PsCell\_CellSetupReq (see 5G\_L2\_351\_replaced([11150981](https://dn-prod.ext.net.nokia.com/rm/resources/BI_24fcSvvTEe-AqvopbP1qhQ))). |  |  |
|  L2-LO delay is a delay to synchronize LoCtrl\_PduMuxReq sending with 5G-L2-PS relative activities and is equal to 10 us. |  |  |
|  |  |  |
| 5G-L2-PS/LO triggers sending of slotSynchroInd by calling BBP Aa5GTimerCreateWithEvent API with time information: |  |  |
|  T0: Reference Time (Hyperframe  0, SFN 0, SLOT 0,BTU 0) + 10 SFN (to have 5G-L2-LO/PS startup synchronized) + 5G-L2-PS/LO BTU offset |  |  |
|  T0: Reference Time is provided to 5G-L2-LO in message LoCtrl\_StartSlotSynchroReq (see 5G\_L2\_IF\_904\_replaced([10984974](https://dn-prod.ext.net.nokia.com/rm/resources/BI_2WEOBvu6Ee-AqvopbP1qhQ)) and 5G\_L1L2\_FLOW\_671). |  |  |
|  |  |  |
| Once 5G-L2-PS receives EO slotSynchroInd, it shall consider scheduling slot N+2 in FR1 and slot N+3 in FR2 (see 5G\_L2\_351\_replaced([11150981](https://dn-prod.ext.net.nokia.com/rm/resources/BI_24fcSvvTEe-AqvopbP1qhQ))). |  |  |
|  |  |  |
| BB L1 synchronization specification for ABIL can be found under: |  |  |
| [5GC001904-A] SFN offsetting and computation of offset\_A with long fibers is implemented in FDD like in TDD. [End 5GC001904-A] |  |  |

---

## Sections

- [4.1 L2RT Slot Synchronization for positioning cells](4.1_L2RT_Slot_Synchronization_for_positioning_cells.md)
