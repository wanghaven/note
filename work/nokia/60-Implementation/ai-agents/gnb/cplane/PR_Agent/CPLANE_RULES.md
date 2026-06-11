# C-Plane Rules — Comprehensive Investigation Guide

**Purpose:** Authoritative knowledge base for C-Plane (gNB-CU-CP) PR investigation. Combines operational rules, domain knowledge, investigation strategy, and Cursor-specific hints into a single reference.

**PR = Problem Report (Pronto ticket), NOT Pull Request.**

---

## Document Status

All sections have been populated from the codebase and documentation. No remaining `[REQUIRES INPUT]` blocks.

**Version:** 1.0 | **Last Updated:** 2026-03 | **Base components:** cu/cp_ue, cu/cp_sb, cu/cp_if, cu/cp_nb, cu/cp_cl, cu/cp_e2

---

## Part I — C-Plane Component Overview

### 1. What Is C-Plane?

C-Plane (CP) is the **gNB-CU-CP** (5G NR gNodeB Centralized Unit — Control Plane). It manages the control-plane signalling for 5G NR:
- **UE (User Equipment) lifecycle**: connection setup, modification, release, handover
- **3GPP interfaces**: F1AP (to gNB-DU), E1AP (to gNB-CU-UP), XNAP (to peer gNBs), NGAP (to AMF)
- **NR RRC**: Radio Resource Control signalling over the Uu interface
- **Cell management**: cell states, energy saving, load reporting
- **O-RAN E2**: interface to the RAN Intelligent Controller (RIC)
- **NSA (Non-Standalone)** and **SA (Standalone)** 5G NR architecture variants

---

### 2. Component Map

**cu/ shared sub-components:**

| Component | Directory   | Responsibility                                             | Key Interfaces          |
| --------- | ----------- | ---------------------------------------------------------- | ----------------------- |
| **cp_ue** | `cu/cp_ue/` | UE context lifecycle, HO state machine                     | F1AP, E1AP, XNAP, NGAP  |
| **cp_sb** | `cu/cp_sb/` | Signalling Bearer, RRC encoding/decoding, SRB management   | Uu (via F1AP)           |
| **cp_if** | `cu/cp_if/` | Protocol message handling: F1AP, E1AP, XNAP, NGAP          | All external interfaces |
| **cp_nb** | `cu/cp_nb/` | NodeB-level configuration, system information              | F1AP, OAM               |
| **cp_cl** | `cu/cp_cl/` | Cell state machine, energy saving strategy, load reporting | OAM, E2                 |
| **cp_e2** | `cu/cp_e2/` | E2/O-RAN interface, RIC interactions                       | E2AP                    |

**Standalone processes:**

| Process    | Directory        | Binary   | Responsibility                                                           | Key Interfaces                        |
| ---------- | ---------------- | -------- | ------------------------------------------------------------------------ | ------------------------------------- |
| **CP-NRT** | `CP-NRT/CP-NRT/` | `cp-nrt` | Non-RT E1AP bearer/PDU coordination, L2 HI, pool/OAM/IPsec scenarios     | E1AP, L2 HI, OAM                      |
| **CP-RT**  | `CP-RT/CP-RT/`   | `Cprt`   | Real-time multi-threaded UE procedures (Boost.MSM FSMs), cell management | F1AP, cprtue/cprtbe/cprtrp interfaces |

---

### 2b. Deployment Topology

| Network Element | Hosts                                   | Transport to CU-CP    | HA Model                                   |
| --------------- | --------------------------------------- | --------------------- | ------------------------------------------ |
| **gNB-CU-CP**   | CP-UE+CP-SB, CP-NB, CP-CL, CP-IF, CP-E2 | — (local ZMQ)         | CP-UE: N+, CP-CL: N+, CP-NB: 2N, CP-IF: 2N |
| **gNB-CU-UP**   | CP-NRT + L2-HI-CU                       | E1AP (SCTP or SysCom) | 2N                                         |
| **gNB-DU**      | CP-RT + L2-PS + L2-LO + L2-HI-DU + L1   | F1AP (SCTP or SysCom) | —                                          |

**Transport layers:** ZMQ (inter-CU-CP components), SCTP (external 3GPP), SysCom (OAM + classical optimized paths).

**Key SCTP ports:** F1AP=38472, E1AP=38462, X2AP=36422, XNAP=38422, NGAP=38412, E2AP=31422.

**Classical BTS:** LXC containers (CPNB, CPCL, CPIF, CPNRT, CPRT) on System Module; CP-UE on Baseband Card (ABIL/ABIO/ABIN).

**Cloud BTS:** systemd-based; CP-NRT in 2-core VM (AirFrame/RCP).

---

### 3. Protocol Stack and Interface Overview

```
AMF (Core Network)
     ↕ NGAP (TS 38.413) — N2 interface
[cp_if: NGAP handler]
     ↕
[cp_nb: NodeB coordinator]
[cp_ue: UE context]    ←→  [cp_sb: RRC / SRB]
[cp_cl: Cell manager]
     ↕ F1AP (TS 38.473) — F1-C interface       ←── CP-RT (Cprt) handles F1AP UE procedures
[cp_if: F1AP handler]                                 NSA: UeContextSetupFsm
     ↕                                               SA:  SAUeContextSetupFsm
 gNB-DU (L2 / L1)

     ↕ E1AP (TS 38.463) — E1 interface         ←── CP-NRT (cp-nrt) handles E1AP bearer scenarios
[cp_if: E1AP handler]                                 BearerSetupReqScenario, BearerModifyReqScenario
     ↕
 gNB-CU-UP (U-Plane)

     ↕ XNAP (TS 38.423) — Xn-C interface
[cp_if: XNAP handler]
     ↕
 Neighboring gNB (peer CU-CP)

     ↕ E2AP (O-RAN.WG3) — E2 interface
[cp_e2]
     ↕
 O-RAN RIC

Internal cp_ue ↔ CP-RT message bus:
  cp_ue ──[SCpUeCpRtSyscomCommunicationEnvelope (msgId e.g. 0xDE30)]──► Cprt/CprtUeApp
  Log: "151c-CP-UE" sends → "1515-CP-RT/UE" receives
```

---

### 4. NSA vs SA Architecture

| Aspect          | NSA (Non-Standalone)                                                    | SA (Standalone)                                          |
| --------------- | ----------------------------------------------------------------------- | -------------------------------------------------------- |
| Control anchor  | LTE MeNB (Master eNB)                                                   | 5G gNB-CU-CP                                             |
| 5G role         | Secondary Node (SN)                                                     | Primary (master) node                                    |
| Bearer setup    | EN-DC / MR-DC multi-connectivity procedures                             | Direct from AMF/SMF via NGAP                             |
| RRC             | Split: LTE MeNB handles primary RRC                                     | gNB-CU-CP handles all NR RRC                             |
| UE connectivity | LTE + NR dual connectivity                                              | NR only                                                  |
| PMQAP           | Expected templates built inside L2 procedures; cannot inject externally | Can inject expected `bearerSetupReq` via E1AP parameters |
| Key impact      | NSA setup chains involve MR-DC procedures; SA does not                  | Different code paths for bearer context setup            |

**CRITICAL RULE:** A fix in an NSA flow MUST be verified against SA, and vice versa, unless the issue is proven variant-specific.

---

### 4b. Default Error Handling Rules

All C-Plane components follow a common error handling convention:

**Critical error** (procedure cannot continue):
1. Report unsuccessful outcome to sender (NOK status or failure/reject message)
2. Clear/release locally allocated resources (timers, state, bearers)
3. Release external resources if already configured (other CP components, U-Plane, DU, core, UE)
4. Print error log with templated format: failure cause, procedure name, and IDs (UEID, bearer ID)

**Non-critical error** (procedure can continue):
1. Print warning/error log indicating failure was ignored
2. Continue processing with valid default values

If the connection is no longer viable, a UE Context Release may be triggered.

C++ exceptions: caught close to throwing place; NOT used for control flow. Some critical failures may trigger application restart.

---

### 4c. Debugging Tools & cplane-tools

| Tool                               | Purpose                               | Usage                                              |
| ---------------------------------- | ------------------------------------- | -------------------------------------------------- |
| **cplane-tools** (`cplane/tools/`) | Online R&D param modification via ZMQ | `set_logging_level`, `set_overload_high_threshold` |
| **Snapshot**                       | Troubleshooting data packages         | Profiles 0-5; triggered via WebUI/REST/event       |
| **EMIL**                           | C-plane L3 diagnostics                | AaTrace-based; cannot decode MuLTI interfaces      |
| **Wireshark + LuaShark**           | Decode gNB internal traffic           | LuaShark plugin generated with each build          |
| **MFA**                            | Message sequence charts for SCT       | Message Flow Analyzer                              |
| **Log-and-Trace**                  | Feature-flag logging                  | `/var/preserve/feature_log_activation.txt`         |

**Crash artifacts:** `journalctl -u ccsrt` for crash signature; RPRAM tarball in `/var/tmp` survives reboot.

**Termination:** CU uses `genAPI::ControllableProcess` + `setTerminateCb()` with 3-second timeout. Both CU and CP-NRT call `AaStartupEeShutdown()` for CCS cleanup.

---

### 5. Key 3GPP Specifications

| Interface / Feature            | Spec                                                                                                              | Key Sections                        |
| ------------------------------ | ----------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| NR Architecture                | [TS 38.401](https://portal.3gpp.org/desktopmodules/Specifications/SpecificationDetails.aspx?specificationId=3219) | Overall gNB split architecture      |
| NR RRC                         | [TS 38.331](https://portal.3gpp.org/desktopmodules/Specifications/SpecificationDetails.aspx?specificationId=3197) | RRC procedures, message definitions |
| NG Application Protocol (NGAP) | [TS 38.413](https://portal.3gpp.org/desktopmodules/Specifications/SpecificationDetails.aspx?specificationId=3223) | N2 interface, AMF ↔ gNB-CU-CP       |
| Xn Application Protocol (XNAP) | [TS 38.423](https://portal.3gpp.org/desktopmodules/Specifications/SpecificationDetails.aspx?specificationId=3228) | Xn-C, handover, resource management |
| E1 Application Protocol (E1AP) | [TS 38.463](https://portal.3gpp.org/desktopmodules/Specifications/SpecificationDetails.aspx?specificationId=3233) | gNB-CU-CP ↔ gNB-CU-UP bearer setup  |
| F1 Application Protocol (F1AP) | [TS 38.473](https://portal.3gpp.org/desktopmodules/Specifications/SpecificationDetails.aspx?specificationId=3257) | gNB-CU-CP ↔ gNB-DU UE context       |
| E2 Application Protocol (E2AP) | [O-RAN.WG3.E2AP](https://specifications.o-ran.org/specifications)                                                 | E2 interface, RIC                   |
| NR Multi-RAT DC (NR MR-DC)     | [TS 37.340](https://portal.3gpp.org/desktopmodules/Specifications/SpecificationDetails.aspx?specificationId=3198) | EN-DC / NSA architecture            |

---

### 6. Scope Boundary

#### IN Scope (Investigate Within C-Plane)
- All `cu/cp_*` component code
- NR RRC protocol handling (cp_sb)
- F1AP, E1AP, XNAP, NGAP message processing (cp_if)
- UE context lifecycle and handover (cp_ue)
- Cell state machine and energy saving (cp_cl)
- Bearer management (DRB/SRB setup, modification, release)
- E2/O-RAN interface (cp_e2)
- NSA and SA procedure flows
- PCMD & Trace (per-UE tickets, cell registration, trace activation — §14b)
- CP-RT services: positioning, PWS, auto access barring, ML, load reporting, paging, slice-aware admission (§14c)
- CP-NRT services: DPS, dynamic firewall, load manager (§14d)
- TTCN3 test logic (SCT tests in `sct/`)

#### OUT of Scope (Escalate)
| Scope                                   | Escalate To              |
| --------------------------------------- | ------------------------ |
| L2 (PDCP-U, RLC, MAC, scheduler)        | U-Plane / DU team        |
| L1 / PHY                                | L1/PHY team              |
| GTP-U / F1-U / transport                | Transport / U-Plane team |
| OAM / configuration management database | OAM team                 |
| AMF / SMF / UPF (core network side)     | Core network team        |
| TTCN3 framework engine bugs             | Test infrastructure team |
| 3rd-party libs / OS / platform          | Platform team            |
| DU-side L2 processing                   | DU / L2 team             |

#### Ownership Determination Evidence
1. **Log prefix / process name** — which binary logged the error
2. **TTCN3 failing assertion** — which component's receive/send failed
3. **Protocol interface** — which side violated the F1AP/E1AP/XNAP contract per spec
4. **Stack trace** — which library/module is the crash site
5. **3GPP spec** — which entity is specified to perform the failing operation

---

## Part II — Domain Knowledge (per Component)

### 7. cp_cl — Cell Management & Energy Saving

#### 7.1 Energy Saving Strategy
- `MaxValueSOffStrategy`: tracks cell load counters to decide cell switch-off
- Counter resets when a new configuration is applied
- Cell switch-off only if counter reaches threshold
- **Known bug pattern:** configuration change resetting counter mid-count, causing false "not ready to switch off" state

#### 7.2 Key File Locations and Strategy Pattern

```
cu/cp_cl/src/                         → Cell-level implementation
cu/cp_cl/src/load_reporting_service/  → Load reporting to OAM/RIC
cu/cp_cl/src/distributed_units_service/ → DU management, cell switching
cu/cp_cl/src/procedures/              → Cell activation/deactivation/config update procedures
cu/cp_cl/src/admission_control/       → Admission control (SA/NSA/NRDC/iGnbCa)
cu/cp_cl/src/storage_service/         → CellContextContainer and middleware
cu/cp_cl/src/types/                   → cp_cl-specific types (ServiceStatus, CellContext)
```

**Energy Saving strategy classes (live in CP-RT, not cp_cl):**

| Class                        | Path                                                                         | Role                                                                                                                                                                 |
| ---------------------------- | ---------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ISwitchOffMethodStrategy`   | `CP-RT/.../energy_saving/src/strategies/ISwitchOffMethodStrategy.hpp`        | Strategy interface: `calculateSOffList(Outcome&, bool)`                                                                                                              |
| `CommonSOffStrategy`         | `CP-RT/.../energy_saving/src/strategies/CommonSOffStrategy.hpp/.cpp`         | Base class for strategies                                                                                                                                            |
| `MaxValueSOffStrategy`       | `CP-RT/.../energy_saving/src/strategies/MaxValueSOffStrategy.hpp/.cpp`       | Max-value counter-based switch-off; compares `getSwitchOffDelayCounter()` to `getSwitchOffDelay()`                                                                   |
| `SlidingAverageSOffStrategy` | `CP-RT/.../energy_saving/src/strategies/SlidingAverageSOffStrategy.hpp/.cpp` | Sliding average alternative                                                                                                                                          |
| `MixedMaxValueSOffStrategy`  | `CP-RT/.../energy_saving/src/strategies/MixedMaxValueSOffStrategy.hpp/.cpp`  | Mixed mode strategy                                                                                                                                                  |
| `SwitchStrategiesProvider`   | `CP-RT/.../energy_saving/src/strategies/SwitchStrategiesProvider.hpp/.cpp`   | Selects strategy by `LbpsSOffTrRule`                                                                                                                                 |
| `EnergySavingAlgorithm`      | `CP-RT/.../energy_saving/src/EnergySavingAlgorithm.cpp`                      | Orchestration: `strategyProvider.getSOffStrategy(...)` → `calculateSOffList`; counter reset via `resetSwitchOffDelayCounter` when `LbpsSOffTrRule::maxValue` enabled |

**cp_cl ES role (not strategy, but consumption/coordination):**

| Class                                        | Path                                                                              | Role                                                                     |
| -------------------------------------------- | --------------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| `CellOperations`                             | `cu/cp_cl/src/distributed_units_service/.../CellOperations.cpp`                   | `validateThenGetCellsSwitchAvailable` for `GNBDUCellSwitchingIndication` |
| `ConcreteDuCellSwitchingIndicationProcedure` | `cu/cp_cl/src/procedures/.../ConcreteDuCellSwitchingIndicationProcedure.hpp/.cpp` | Cell switch-on/off from DU indication                                    |
| `CellContextContainerMiddleware`             | `cu/cp_cl/src/storage_service/src/CellContextContainerMiddleware.cpp`             | `isCellInEnergySaving` query                                             |

**Counter reset root cause:** In `EnergySavingAlgorithm.cpp`, `resetSwitchOffDelayCounter` zeroes `cellSwitchOffDelayCounter` and `txSwitchOffDelayCounter` when new config uses `LbpsSOffTrRule::maxValue` and previous rule was different (log: *"Max value method turned on. Resetting switchOffDelayCounters!"*). Related: `resetSwitchOnDelayCounters`, `resetSlidingAverageContexts`, `resetDelayCountersIfNeeded`.

**Admission control classes in cp_cl:**

| Class                          | Path                                                              |
| ------------------------------ | ----------------------------------------------------------------- |
| `RadioAdmissionControlService` | `cu/cp_cl/src/admission_control/radio_admission_control_service/` |
| `ConcreteAdmissionControlSa`   | `cu/cp_cl/src/admission_control/admission/sa_admission/`          |
| `ConcreteAdmissionControlNsa`  | `cu/cp_cl/src/admission_control/admission/nsa_admission/`         |
| `ConcreteAdmissionControlNrdc` | `cu/cp_cl/src/admission_control/admission/nrdc_admission/`        |
| `AdmissionControlIgnbCa`       | `cu/cp_cl/src/admission_control/admission/ignbca_admission/`      |
| `CaSolutionFinderCacheService` | `cu/cp_cl/src/admission_control/scells_selection/`                |

#### 7.3 Cell State Machine

cp_cl does **not** use a single Boost.MSM FSM for cell lifecycle. State is carried in **enums on `CellContext`** and updated by **procedures**.

**Primary cell state** (`types::cp_cl::CellState` in `cu/libs/types/include/types/cp_cl/CellState.hpp`):
- `deactivated` → `activated` → `served` (normal lifecycle)
- `deactivating` (CU-initiated) / `deactivatingByDu` (DU-initiated)

**Service status** (`ServiceStatus` in `cu/cp_cl/src/types/include/cpcl_types/ServiceStatus.hpp`):
- `outOfService`, `inService`

**Energy Saving state** (`CpEnergySavingState` in `cu/libs/types/include/types/CpEnergySavingState.hpp`):
- `notEnergySaving`, `energySaving`

**Administrative state** (`CellAdministrativeState` in the same types area)

**Load Reporting internal state** (`load_reporting::CellState` in `cu/cp_cl/src/load_reporting_service/include/.../CellLoadReportingContext.hpp`):
- `pendingAdd`, `pendingReAdd`, `syncedWithDu`, `pendingRemoval` — transitions managed in `DuLoadReportManager.cpp`

**CP-RT cell config state** (different enum, `CP-RT/.../types/cell_config/CellState.hpp`):
- `activatedInService`, `disabled`, `activatedOutOfService`, `deactivated`

**CellContext key fields** (at `cu/cp_cl/src/types/include/cpcl_types/CellContext.hpp`):
`status` (CellState), `serviceStatus`, `cpEnergySavingState`, `cellAdministrativeState`, `ngTriggeredCellStatus`, `x2TriggeredCellStatus`, `xnTriggeredCellStatus`, `barringState`, `isCellActivating`, `runningCellActivationTimerType`, `cellOperationalMode`

**CellContexts** = `containers::CpCellMap<types::NRCellIdentity, CellContext>` (at `cu/cp_cl/src/types/include/cpcl_types/CellContexts.hpp`)

**CellContextContainer** interface: `cu/cp_cl/src/storage_service/include/storage_service/CellContextContainer.hpp`
Concrete: `ConcreteCellContextContainer.hpp/.cpp`; Middleware: `CellContextContainerMiddleware.hpp/.cpp`

**Transition guards** are spread across procedures (`ConcreteDuConfigurationUpdateProcedure`, activation/deactivation procedures) and `CellContextContainerMiddleware` rules. Unit tests encode expected transitions: `ConcreteCellContextContainer_tests.cpp`.

**Key procedures for cell lifecycle:**

| Procedure                                          | Path                                                                          |
| -------------------------------------------------- | ----------------------------------------------------------------------------- |
| `ConcreteDuConfigurationUpdateProcedure`           | `cu/cp_cl/src/procedures/.../ConcreteDuConfigurationUpdateProcedure.hpp/.cpp` |
| `ConcreteBackhaulAvailableCellActivationProcedure` | `cu/cp_cl/src/procedures/.../cell_activation/`                                |
| `ConcreteEndcCellActivationProcedure`              | `cu/cp_cl/src/procedures/.../cell_activation/`                                |
| `ConcreteCellDeactivationProcedure`                | `cu/cp_cl/src/procedures/.../cell_deactivation/`                              |
| `ConcreteCuCellDeactivationProcedure`              | `cu/cp_cl/src/procedures/.../cell_deactivation/`                              |
| `ConcreteCellStatusIndicationProcedure`            | `cu/cp_cl/src/procedures/`                                                    |

**DistributedUnitsService key methods** (at `cu/cp_cl/src/distributed_units_service/.../DistributedUnitsService.hpp/.cpp`):
`onMessage(DuConfigurationUpdate)`, `onMessage(GNBDUCellSwitchingIndication)`, `onMessage(CuConfigurationUpdateAck/Failure)`, `startDuConfigurationUpdateProcedure`, `addDistributedUnit(s)`, `impactLevelChangeNotification`

#### 7.4 ES Test Patterns (from TTCN3 SCT)
- `f_UT_delay(60.0)` → `f_UT_delay(550.0)` — timing difference was root cause of RAIN test failure
- Counter window: 30/30 threshold requires ~300–550s at normal load
- Configuration change mid-test resets counter to 1/30

---

### 8. cp_ue — UE Context Management

- One UE context per connected UE
- Manages HO state machine
- Sends F1AP messages to CP-RT via `itf::cp::cpue_cprt::SCpUeCpRtSyscomCommunicationEnvelope`
- Log prefix: `151c-CP-UE` / `ASC-151c-2-cp_ue`
- Example cross-process flow: cp_ue encodes `F1AP_PDU_Contents::UEContextModificationRequest` → sends via SysCom msgId `0xDE30` → `1515-CP-RT/UE` receives

#### 8.1 UE Context Lifecycle

**Creation (SA):**
1. `CplaneUe::createUeDeployment()` → `IUeLauncherFactory::createUeLauncher`
2. `UeLauncher::addUeSa` → `registerUe<IUeSa>` → `UeInfoSaFactory::createActiveUeInfo`
3. `createActiveUeInfo` → `createActiveUeContext` (StateData facade) + `createStandaloneUe` (ConcreteUeSa)
4. State initialized: `SaIdentifiers`, `UeSAContextData`, `UeSecurityInformation`, `SrbInformation`, `UeFailureInformation`

**Context type:** `applications::cp_ue::UeSAContext` = `state_data::IStateDataLocalDBFacade<KeyTypeSA>`
**Domain data:** `UeSAContextData` (identifiers, mobility, DRX, CA/NRDC, measurement state) at `cu/cp_ue/src/procedures/user_management/user_context_data/include/user_context_data/UeSAContextData.hpp`

**Destruction:**
`UeLauncher::removeUeSa` → `senderProvider.getCplaneSbSenderService().removeUe(ueIdCu)` → `activeUeContainer.eraseUe` → `admissionControlSa.releaseUe`
(Parallel APIs: `removeUeNsa`, `removeUeNrdc`, `removeUeIGnbCa`)

#### 8.2 Procedure Framework

**Factory:** `ConcreteUeProcedureFactory` at `cu/cp_ue/src/procedures/user_management/ue_procedure_factory_sa/`

**Key SA procedures** (each a `create*` method on the factory):

| Category              | Representative procedures                                                                                                                                                                          |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RRC / access          | `createRrcEstablishmentProcedure`                                                                                                                                                                  |
| Context / NG          | `createNgapUeContextModificationProcedure`, `create*SAUeContextReleaseProcedure`, `createNgUeContextReleaseProcedure`                                                                              |
| PDU session           | `createInitialPduSessionResourceSetupProcedure`, `createSubsequentPduSessionResourceSetupProcedure`, `createPduSessionResourceModifyProcedures`, `createPduSessionResourceReleaseCommandProcedure` |
| Security / capability | `createSAUeCapabilityEnquiryProcedure`, `createUeCapabilityCheckProcedure`                                                                                                                         |
| Reconfiguration       | `createSADuToCuRRCReconfigurationProcedure`, `createRrcReconfigurationSaProcedure`                                                                                                                 |
| Reestablishment       | `createReestablishmentProcedure`, unprepared source/target variants                                                                                                                                |
| Handover (SA)         | `createIntraGnbHandoverProcedure`, `createNgHandoverProcedure`, `createXnHandoverProcedure`, `createInterRatHandoverProcedure`                                                                     |
| SCell / CA            | `createSCellAdditionProcedure`, `createScellReleaseProcedure`, `createUeCaReevaluationProcedure`                                                                                                   |
| RRC inactive          | `createTransitionToRrcInactiveProcedure`, `createTransitionFromRrcInactiveToRrcConnectedProcedure`                                                                                                 |
| NRDC MN               | `createNrdcMnSideSnodeAdditionProcedure`, `createNrdcMnSideBearerTakebackProcedure`                                                                                                                |

NSA procedures are under separate directories (`menb_handover`, `sgnb_*`, `*_nsa`) with their own factory.

**State machines:** Boost.MSM (`boost::msm::back::state_machine<...Frontend>`) with action/guard patterns.
Base scaffolding: `cu/cp_ue/src/framework/ue_base_state_machine/`

#### 8.3 Message Dispatch

**Per-UE dispatch:** `ConcreteUeSa::onMessage(...)` — many overloads for internal start events, F1AP, NGAP (`*WithAmfId`), E1AP, XNAP (`*WithGnbId`), SRB/cell responses, trace (at `cu/cp_ue/src/framework/launcher_framework/procedure_launcher/ue_sa/src/ConcreteUeSa.cpp`)

**Global routing by `ueIdCu`:** `ConcreteGlobalDispatcherInternal::forwardEventToUe<UeType>` → reads `event.ueIdCu` → `IActiveUeContainer::findUeSa/findUeNsa/findUeNrdc/findUeIGnbCa` → `ue.onMessage(event)` (at `cu/cp_ue/src/framework/launcher_framework/global_dispatcher/global_dispatcher_internal/`)

**Protocol-specific handlers → UE:** `global_dispatcher_ngap`, `global_dispatcher_f1`, `global_dispatcher_xnap` etc. under `cu/cp_ue/src/framework/launcher_framework/global_dispatcher/`

**Pool-level:** `CplaneUe` (implements `ICplaneUe`) handles `CpUeDataDistributionRequest`, `CpUeNiddDeliveryRequest`, initializes `IGlobalDispatcherCplaneUe`

#### 8.4 Timer Management

**Enum:** `TimerIdentifier` at `cu/cp_ue/src/framework/cpue_timer_manager/include/cpue_timer_manager/TimerIdentifier.hpp`

Key values: `radioLinkRecovery`, `ngSignalingConnGuard`, `srbInactivityTimerSA`, `ngRelocOverall`, `xnDataFwdGuard`, `ranPagingGuard`, `maxUeRrcInactTimeGuard`, `nrEcidMeasSupervision`, `tStoreUeContext`, `ueCapabilityCheckGuardTimer`, `timerUEContextRetrieval`, `fiveQI1RrcRelDelayTimerSA`, `x2SgNbReconfigurationComplete` (37 identifiers total)

**Manager:** `CpUeTimerManager` — one per `UeIdCu`, backed by `timer_management::TimerService` with `startTimer`/`startPeriodicTimer`/`isTimerActive`

#### 8.5 Key Directory Layout

| Area                             | Path                                                                  |
| -------------------------------- | --------------------------------------------------------------------- |
| SA UE create/destroy             | `cu/cp_ue/src/framework/launcher_framework/ue_launcher/`              |
| UE facade + `onMessage`          | `cu/cp_ue/src/framework/launcher_framework/procedure_launcher/ue_sa/` |
| Route by `ueIdCu`                | `cu/cp_ue/src/framework/launcher_framework/global_dispatcher/`        |
| Procedure inventory              | `cu/cp_ue/src/procedures/` (80+ subdirectories)                       |
| Context state data               | `cu/cp_ue/src/state_data_creator/`                                    |
| Timers                           | `cu/cp_ue/src/framework/cpue_timer_manager/`                          |
| SA services (per-UE / singleton) | `cu/cp_ue/src/services/ue_services/ue_services_sa/`                   |
| NSA services                     | `cu/cp_ue/src/services/ue_services/ue_services_nsa/`                  |

---

### 9. cp_sb — Signalling Bearer / RRC

- Handles SRB0, SRB1, SRB2 management
- RRC message encode/decode
- PMQAP verification in SA mode via `bearerSetupProcedureOk(request, true)`
- In NSA: `bearerSetupProcedureWitSecurityParams` builds L2 expected template internally — no external injection available without interface change

#### 9.1 Architecture

cp_sb applies **PDCP framing + security (cipher + integrity)** on SRB PDUs/SDUs. It does not own full RRC ASN.1 encoding — RRC payloads arrive as `types::Payload` from cp_ue.

**Message flow:** SysCom in → `SrbReceiver` → `SrbApp::onMessage(...)` → `SrbManager` → `SrbDispatcher` (virtual, concrete = `ConcreteCpUeSender`) back toward cp_ue.

#### 9.2 Key Classes

| Class                                          | Role                                                                                                                            | Path                                                |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| `SrbApp`                                       | Application layer: `onMessage(...)` dispatches to `SrbManager`                                                                  | `cu/cp_sb/src/bearer_management/`                   |
| `SrbManager`                                   | Orchestrates: `BearerSetupReq`, `UlPduReceiveInd`, `SrbSendReq`, security activate/deactivate, lock-step, short MAC-I           | `cu/cp_sb/src/bearer_management/src/SrbManager.cpp` |
| `SrbDb` / `SrbDbInMemory`                      | Per-bearer storage (`SrbUl`/`SrbDl` by `SrbBearerIndex`)                                                                        | `cu/cp_sb/src/bearer_management/`                   |
| `ConcreteSrbUl`                                | UL: decrypt, integrity verify, SN handling, `enableIntegrityProtection`, `enableFullProtection`, `proceedLockStep`              | `cu/cp_sb/src/bearer_management/`                   |
| `ConcreteSrbDl`                                | DL: encrypt, add MAC-I, `handleProtectionActivateSdu` for lock-step SRB1                                                        | `cu/cp_sb/src/bearer_management/`                   |
| `SrbSecurity`                                  | Ciphering + integrity using `SecurityInfo`/`SrbSecurityParams`; algorithms: `NEA1NIA1`, `NEA2OpenSSL`/`NIA2OpenSSL`, `NEA3NIA3` | `cu/cp_sb/src/security/`                            |
| `PduHelper` / `PdcpUlHelper` / `CpSbPdcpCount` | PDCP COUNT handling                                                                                                             | `cu/cp_sb/src/pdcp/`                                |
| `SrbReceiver`                                  | SysCom subscription → dispatch into `SrbApp`                                                                                    | `cu/cp_sb/src/bearer_management/`                   |
| `SrbDispatcher`                                | Virtual API to send SDUs/PDUs/responses back to cp_ue                                                                           | `cu/cp_sb/src/bearer_management/`                   |

#### 9.3 SRB0/SRB1/SRB2 Handling

All SRBs use the same `SrbUl`/`SrbDl` pair — differentiated by `types::SrbId` and `BearerSetupReq` fields. Lock-step activation is explicit for **SRB1** in `SrbManager::handleSrbSendReq` (checks `srbSendReq.isLockStepAct and srbSendReq.srbId == types::SrbId{1u}`).

#### 9.4 Security Activation

Via `SrbManager`: `SecurityConfReq` → `SecurityActivationReq` → `SecurityDeactivationReq` → `ProceedLockStepReq` on `SrbUl`/`SrbDl` + `SrbSecurity` (`encrypt`/`decrypt`/`addMacI`/`checkMacI`).

**No large FSM**: behaviour is request/response + bearer state in `SrbDb` and UL/DL objects.

#### 9.5 Key Directories

```
cu/cp_sb/src/bearer_management/  → Core SRB logic (SrbManager, SrbDb, SrbUl, SrbDl)
cu/cp_sb/src/security/           → SrbSecurity, algorithm implementations
cu/cp_sb/src/pdcp/               → PDCP helpers/counts
cu/cp_sb/src/shb/records/        → SHB codecs (CpSbMessagesCodecFactory)
cu/cp_sb/src/cpsb_exe/           → main_cpSb.cpp, CplaneSbRunner.cpp
```

---

### 10. cp_if — Protocol Interface Handler

- Handles F1AP, E1AP, XNAP, NGAP, X2AP over SCTP + ZMQ/protobuf to other CP components
- Routes messages to/from cp_ue, cp_sb, cp_nb, cp_cl
- Key TTCN3 templates: `sct/protocols/F1AP/`, `sct/protocols/E1AP/`, `sct/protocols/XNAP/`

#### 10.1 Main Dispatcher Pattern

**`CpIfServiceReceiver`** (ZMQ pull → parse `cp_if_interface::CpIfRequest` → `switch(request_case())`):
- Most cases → `MainIfServiceDispatcher::onMessage(...)` (typed internal messages)
- `CpUePartialResetAck` → `ConcreteCpIfServiceDispatcher` (matching dispatcher for UE pool)
- `CpIfNgRanUpdateReq` / `CpIfCellConfigUpdateReq` → `CpCellHandler::onMessage(..., poolId)` (cell-oriented path)

**`MainIfServiceDispatcher`** = `message_gateway::DispatcherImpl<MainIfDispatcherTypes>` — compile-time list of message types → registered handlers (transport, NIDD, data distribution, pool failure, E2 acks, etc.)

#### 10.2 Per-Protocol Services

| Protocol | Key Classes                                                                                 | Path                                                            |
| -------- | ------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| **F1AP** | `F1ConnectionManagement`, `F1Connection`, `F1APDispatcher`, `SCTPF1Router`                  | `cu/cp_if/src/f1_service/`, `cu/cp_if/src/sctp_service/src/f1/` |
| **E1AP** | `E1APRouter`, `SCTPE1Router`, `PartialE1APDeserializer`, `PartiallyDeserializedE1APMessage` | `cu/cp_if/src/e1_service/`, `cu/cp_if/src/sctp_service/src/e1/` |
| **XNAP** | `XnLinksManager`, `ConcreteXnLinkHandler`, link setup/reset procedures                      | `cu/cp_if/src/xn_service/`                                      |
| **X2AP** | `X2APHandler`, `LteEnb`                                                                     | `cu/cp_if/src/x2_service/`                                      |
| **NGAP** | `NgServiceHandler`, `NgLinkController`, `NgConnection`, NG setup procedures                 | `cu/cp_if/src/ng_service/`                                      |

**SCTP management:** `SCTPThreadsContainer` owns SCTP worker threads, SysCom, PM hooks (at `cu/cp_if/src/sctp_service/`)

#### 10.3 Routing to cp_ue vs cp_cl vs cp_nb

- **→ cp_ue**: SCTP routers partial-decode (ASN.1 `PartialE1APDeserializer`, `F1APPartialDeserializer`) → `cpueServiceApi.send(ueIdCu, ...)` with encoded `CpUeRequest` payloads
- **→ cp_cl / cp_nb**: ZMQ/protobuf "cp_if service" messages and broadcasters (`ConcreteCpCellMessagesBroadcaster`, `CpIfSendToCpCl`); cp_nb-oriented indications (F1/Xn link info)

#### 10.4 Key Directories

```
cu/cp_if/src/cp_if_service/  → CpIfServiceReceiver, MainIfServiceDispatcher, CpIfServiceHandler
cu/cp_if/src/f1_service/     → F1 connection management
cu/cp_if/src/e1_service/     → E1 connection management
cu/cp_if/src/xn_service/     → Xn link management
cu/cp_if/src/x2_service/     → X2 (EN-DC) management
cu/cp_if/src/ng_service/     → NG (AMF) management
cu/cp_if/src/sctp_service/   → SCTP threads, per-protocol workers
```

**NSA Bearer Setup key TTCN3 path:**
```
cuBearerContextSetupProcedureNsa(...)
  → performL2HiCuBearerSetupProcedure(p_E1AP_BearerContextSetupRequest, ...)
    → m_l2Pools[poolId].pool.start(bearerSetupProcedureWitSecurityParams(...))
      → hiUserCuPort.receive(p_bearerSetupReq)  ← L2 receive with built template
```
**SA Bearer Setup key TTCN3 path:** `bearerSetupProcedureOk(p_bearerSetupReq, true)` — injected template

---

### 11. cp_nb — NodeB Level

**Role:** gNodeB-level orchestration — network plan (cells, DUs, slices, AMF, SCTP plans, ANR), OAM-driven configuration, scaling/admin, resource/pool coordination, and sending structured requests to cp_if / cp_cl / cp_e2 / cp_ue.

#### 11.1 Key Classes

| Class                              | Role                                                                                      | Path                                                              |
| ---------------------------------- | ----------------------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| `NetworkPlan`                      | Large aggregate over planned MOs (cells, DUs, adjacency, ANR profiles, timers, slices)    | `cu/cp_nb/src/network_plan/include/network_plan/NetworkPlan.hpp`  |
| `CplaneNbWithDependencies`         | Instantiates NetworkPlan, AnrService, ScaleFaultReporter, etc.                            | `cu/cp_nb/src/cpnb_lib/`                                          |
| `OAMConfigurationHandler`          | OAM config handler wired with IAnrService, ISharedNpfAnrServiceState, NPF update ordering | `cu/cp_nb/src/oam/oam_configuration/`                             |
| `ScaleFaultReporter`               | Reports/clears scale-related faults via FaultManager                                      | `cu/cp_nb/src/scale_adm/include/scale_adm/ScaleFaultReporter.hpp` |
| `ScaleCuAdmin` / `ScaleAdmin`      | Scale administration                                                                      | `cu/cp_nb/src/scale_adm/`                                         |
| `AnrService`                       | ANR-related updates, NeighbourRelationsAccess, SDL, SharedNpfAnrServiceState              | `cu/cp_nb/src/` (AnrService.hpp)                                  |
| `SaServiceImpactedAlFaultReporter` | SA service impacted alarms from faulty slice data + guard timer                           | `cu/cp_nb/src/network_plan/include/network_plan/`                 |
| `ResourceMonitorHandler`           | Resource monitoring                                                                       | `cu/cp_nb/src/resource_monitor/`                                  |
| `ConcreteNetworkPlanHandler`       | File/network plan ingestion                                                               | `cu/cp_nb/src/network_plan_file/`                                 |
| `ConcreteSdlPoolsStorage`          | SDL pool storage and converters                                                           | `cu/cp_nb/src/database/`                                          |

#### 11.2 Dispatch Pattern

Mostly **orchestrator + senders**: `senders/` (`ConcreteCpIfServiceSender`, `ConcreteCplaneCellSender`, `ConcreteE2Sender`, factories) emit typed internal messages toward other processes — not a single giant switch like `CpIfServiceReceiver`.

#### 11.3 Key Directories

```
cu/cp_nb/src/network_plan/        → NetworkPlan, SaServiceImpactedAlFaultReporter
cu/cp_nb/src/oam/                 → OAM configuration handling
cu/cp_nb/src/scale_adm/           → Scaling, fault reporting
cu/cp_nb/src/database/            → SDL pool storage
cu/cp_nb/src/resource_monitor/    → Resource monitoring
cu/cp_nb/src/network_plan_file/   → Network plan file ingestion
cu/cp_nb/src/cpnb_lib/            → Top-level wiring (CplaneNbWithDependencies)
cu/cp_nb/src/senders/             → Senders to cp_if, cp_cl, cp_e2
```

---

### 12. cp_e2 — E2 / O-RAN Interface

**Role:** O-RAN E2 interface — SCTP client toward RIC, E2 setup, RIC subscription / service update, indications and control (RAN function policy, PM), coordination with cp_if and cp_nb.

#### 12.1 Key Classes

| Class                                                      | Role                                                                                                                                                                  | Path                                             |
| ---------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------ |
| `CpE2AgentCore`                                            | Top-level agent: SCTP profile, link connect, delegates to ConcreteE2LinkHandler                                                                                       | `cu/cp_e2/src/e2_services/src/CpE2AgentCore.cpp` |
| `ConcreteE2LinkHandler`                                    | E2AP state: setup request/response/failure, timeouts, RIC service update, subscriptions, error indication; uses E2APSerializer, E2APDedicatedInbound, fault reporting | `cu/cp_e2/src/e2_services/`                      |
| `CpE2CuCpServiceAdaptor` / `CpE2CuCpServiceAdaptorHandler` | Bridges internal messages (link info, cell status, block/unblock/lock, NIDD) between E2 core and cp_if / cp_nb                                                        | `cu/cp_e2/src/e2_services/`                      |
| `SCTPClientEndpoint` / `SCTPAfifClientEndpoint`            | SCTP I/O toward RIC                                                                                                                                                   | `cu/cp_e2/src/e2_services/`                      |
| `CpE2PmHandler`                                            | PM-related E2 handling                                                                                                                                                | `cu/cp_e2/src/e2_services/`                      |

**Note:** There is no separate `E2SetupHandler` class — E2 setup is implemented on `ConcreteE2LinkHandler` (`sendE2SetupRequestMessage`, `handleE2Payload`).

#### 12.2 E2AP Message Processing

Raw `types::Payload` → `ConcreteE2LinkHandler::handleE2Payload` → decode/dispatch by message type (setup, subscription, control, error indication); outbound via `ISCTPClientEndpoint::handleSendPayload`.

#### 12.3 Key Directories

```
cu/cp_e2/src/e2_services/   → Link handler, adaptor, SCTP, agent core
cu/cp_e2/src/controller/    → main_cpE2.cpp, CplaneE2Runner, CpE2ServiceWithDependencies
cu/cp_e2/src/senders/       → CpE2ConcreteCplaneIfSender, CpE2ConcreteCplaneNbSender
cu/cp_e2/src/libs/          → Subscriptions, transaction IDs, NIDD parameters, RAN function policy
cu/cp_e2/src/shb/records/   → CpE2MessagesCodecFactory, CpE2AsnMessagesCodecFactory
```

---

### 13. CP-NRT — Non-Real-Time Process (`cp-nrt`)

#### 13.1 Role and Architecture
- **Binary:** `cp-nrt`
- **Purpose:** Non-real-time coordination with gNB-CU-UP (E1AP), L2 U-Plane (L2 HI), OAM/pool configuration, IPsec/TRSW address management
- **Core pattern:** Scenario-driven — `ScenarioHandler` dispatches incoming events (E1AP, L2 HI, OAM, internal) to specific **scenario procedure classes**
- **UE state:** `cpnrt::UeContext` aggregates UP-facing UE state (DRBs, PDU sessions, NSA/SA type, E1 IDs, HO, security, NIDD)

#### 13.2 Key Source Locations

| Concern                      | Path                                                                                                  |
| ---------------------------- | ----------------------------------------------------------------------------------------------------- |
| Central event dispatcher     | `CP-NRT/CP-NRT/src/scenario/scenario/src/ScenarioHandler.cpp`                                         |
| UE context (NRT)             | `CP-NRT/CP-NRT/src/ueContext/` — `UeContext.hpp`, `CuUpPicker.hpp`                                    |
| Bearer setup scenario        | `CP-NRT/CP-NRT/src/scenario/bearer/bearer_setup/src/BearerSetupReqScenario.cpp`                       |
| Bearer modify scenario       | `CP-NRT/CP-NRT/src/scenario/bearer/`                                                                  |
| Bearer error indication      | `CP-NRT/CP-NRT/src/scenario/bearer/bearer_error_ind/src/BearerErrorIndScenario.cpp`                   |
| L2 HI bearer setup builder   | `CP-NRT/CP-NRT/src/scenario/scenario_common/src/msg_builder/BearerSetupReqBuilder.cpp`                |
| PDU session builder          | `CP-NRT/CP-NRT/src/scenario/scenario_common/src/msg_builder/PduSessionToSetupListBuilder.cpp`         |
| Pool/OAM scenarios           | `CP-NRT/CP-NRT/src/scenario/oamScenarios/` — `DeltaPlanScenario.cpp`, `ContinueDeltaPlanScenario.cpp` |
| Pool config scenarios        | `CP-NRT/CP-NRT/src/scenario/pool_configuration/`                                                      |
| IPsec / TRSW config          | `CP-NRT/CP-NRT/src/scenario/trsw_addr_config/`                                                        |
| E1 ASN serialize/deserialize | `CP-NRT/CP-NRT/src/proxy/`                                                                            |
| GTP-U path supervision       | `CP-NRT/CP-NRT/src/dynamicDataPathSupervision/`                                                       |
| State machine base           | `CP-NRT/CP-NRT/state_machines/include/state_machines/BaseStateMachine.hpp`                            |
| GTest unit tests             | `CP-NRT/CP-NRT/tests/ut/`                                                                             |

#### 13.3 NSA vs SA in CP-NRT
- `cpnrt::UeContext` carries `types::UeContextType` and E-UTRAN DRB lists
- `BearerSetupReqBuilder.cpp` uses `itf::TypeOfBearer::SA` vs `itf::TypeOfBearer::NSA`
- `CuUpPicker.cpp` applies NSA-specific IPsec policy
- `ContinueDeltaPlanScenario.cpp` handles NSA UEs in E1 reset

#### 13.4 Build and Test

```bash
gnb_build/build.py --icecc cplane cpnrt app build      # build cp-nrt binary
gnb_build/build.py --icecc cplane cpnrt ut run          # build and run GTest unit tests
gnb_build/build.py --icecc cplane cpnrt sct run         # build and run SCT tests
```

Test layout: `CP-NRT/CP-NRT/tests/ut/` → scenarios, proxy, ueContext, dataProvider, niddParser

---

### 14. CP-RT — Real-Time Process (`Cprt`)

#### 14.1 Role and Architecture
- **Binary:** `Cprt`
- **Purpose:** Hard real-time UE and cell procedure execution using Boost.MSM finite state machines. Handles F1AP UE context operations, intra/inter-gNB handover, SCell management, cell beamforming, Xp/Xn interface management.
- **Multi-threaded:** Dedicated thread applications per plane:

| Thread App  | Log identifier                  | Role                                   |
| ----------- | ------------------------------- | -------------------------------------- |
| `CprtApp`   | `ASC-1515-*-Cprt`               | Main application coordinator           |
| `CpIfDuApp` | `ASC-1515-*-Cprt`               | DU interface (F1AP I/O from/to gNB-DU) |
| `CprtUeApp` | `ASC-1515-2-Cprt` `85-cp_rt_ue` | UE procedures (FSM execution)          |
| `CprtBeApp` | —                               | BE plane messages                      |
| `CprtRPApp` | —                               | RP messages, RAN parameters            |

**Log pattern for CP-RT:**
```
1a ASC-1515-2-Cprt <2026-02-10T15:43:30.545141Z> 85-cp_rt_ue DBG/cp_rt/UeMessageChecker.cpp:406 [ueIdCu:32768,ueIdDu:2] is UE message
1f ASC-1515-2-Cprt <2026-02-10T15:43:30.545222Z> 85-cp_rt_ue DBG/cp_rt/UeContextModificationService.cpp:228 [ueIdCu:32768,ueIdDu:2,intUeIdDu:2] UeContextModificationService start
```
- Log level codes: `DBG` = debug, `INF` = info, `WRN` = warning, `ERR` = error
- UE context tag: `[ueIdCu:X,ueIdDu:Y,intUeIdDu:Z]`

#### 14.2 Key FSMs (Boost.MSM)

| FSM Class                     | Path                                     | Purpose                                          |
| ----------------------------- | ---------------------------------------- | ------------------------------------------------ |
| `UeContextSetupFsm` (NSA)     | `ue_setup/include/ue_setup/nsa/`         | NSA UE context setup: F1, L2 HI/PS/LO, admission |
| `SAUeContextSetupFsm`         | `ue_setup/include/ue_setup/sa/setup/`    | SA UE context setup                              |
| `SAHandoverUeContextSetupFsm` | `ue_setup/include/ue_setup/sa/handover/` | SA handover setup                                |
| `UeScellAdditionFsm`          | `ue_scell_mgmt/include/fsm/`             | Secondary cell addition                          |
| `UeContextReleaseFsm`         | `ue_release/src/fsm/`                    | UE context release                               |
| `BeamConfigUpdateFsm`         | `cell_mgmt/`                             | Cell beam configuration update                   |
| `IgNBCaXpIfFsm`               | `xp_mgmt/`                               | Inter-gNB CA, Xp interface                       |
| Base class                    | `ue_fsm::BaseUeStateMachine`             | Common MSM infrastructure                        |

#### 14.3 NSA vs SA Split in CP-RT

**Explicit directory split:**
```
ue_setup/src/nsa/  → NsaUeSetupAdmissionControl.cpp (NSA admission)
ue_setup/src/sa/   → SaUeSetupAdmissionControl.cpp (SA admission)
                      CellGroupConfigHelper.cpp
                      SaUeSetupInit.cpp
ue_setup/src/sa/handover/ → SaHOUeSetupAdmissionControl.cpp
```

**Test split:**
```
tests/ut/nsa/ → UeContextSetupFsmTests.cpp, UeContextSetupFsmWithCaTests.cpp
tests/ut/sa/  → SAUeContextSetupFsmTests.cpp (inferred from SA pattern)
```

**CRITICAL:** A fix in an NSA FSM state MUST be verified against the corresponding SA FSM state, and vice versa, unless proven variant-specific.

#### 14.4 Key Source Locations

| Concern                 | Path                                                                                                      |
| ----------------------- | --------------------------------------------------------------------------------------------------------- |
| Process entry           | `CP-RT/CP-RT/src/main/src/Main.cpp`                                                                       |
| Thread apps             | `CP-RT/CP-RT/src/main/src/` — `CprtApp`, `CpIfDuApp`, `CprtUeApp`, etc.                                   |
| NSA UE setup FSM        | `CP-RT/CP-RT/src/services/ue_mgmt/ue_procedures/ue_setup/src/nsa/`                                        |
| SA UE setup FSM         | `CP-RT/CP-RT/src/services/ue_mgmt/ue_procedures/ue_setup/src/sa/`                                         |
| UE modify procedure     | `CP-RT/CP-RT/src/services/ue_mgmt/ue_procedures/ue_modify/`                                               |
| UE release procedure    | `CP-RT/CP-RT/src/services/ue_mgmt/ue_procedures/ue_release/`                                              |
| SCell management        | `CP-RT/CP-RT/src/services/ue_mgmt/ue_procedures/ue_scell_mgmt/`                                           |
| F1AP message builders   | `CP-RT/CP-RT/src/services/ue_mgmt/ue_procedures/msg_builders/`                                            |
| Cell management         | `CP-RT/CP-RT/src/services/cell_mgmt/`                                                                     |
| Xp management           | `CP-RT/CP-RT/src/services/xp_mgmt/`                                                                       |
| UE context modification | `CP-RT/CP-RT/src/services/ue_mgmt/ue_procedures/ue_modify/` — `UeContextModificationService.cpp`          |
| F1 message validator    | `CP-RT/CP-RT/src/services/ue_mgmt/ue_procedures/ue_modify/src/` — `UeContextModificationReqValidator.cpp` |
| F1AP common types       | `CP-RT/CP-RT/src/common/`                                                                                 |
| Interface definitions   | `CP-RT/itf/cp/rt/cprtue/` — `*.mt` files (UE context messages)                                            |
| Interface definitions   | `CP-RT/itf/cp/rt/cprtbe/` — BE messages                                                                   |
| Interface definitions   | `CP-RT/itf/cp/rt/cprtrp/` — RP messages                                                                   |
| GTest unit tests        | `CP-RT/CP-RT/UT/` and `tests/ut/` per service                                                             |

#### 14.5 Build and Test

```bash
gnb_build/build.py --icecc cplane cprt app build                          # build Cprt binary
gnb_build/build.py --icecc cplane cprt ut run                              # build and run all GTest UTs
gnb_build/build.py --icecc cplane cprt ut -t <target> -f "<filter>" run   # specific target + filter
gnb_build/build.py --icecc cplane cprt ut -t <target> --ut-verbose debug run  # verbose logging
gnb_build/build.py --icecc cplane cprt ut -t <target> -s run              # shuffle for race detection
gnb_build/build.py --icecc cplane cprt ut -t <target> debug               # debug with debugger
gnb_build/build.py --icecc cplane cprt sct run                             # build and run SCT tests
```

Test layout: `CP-RT/CP-RT/UT/` (aggregated) + `tests/ut/nsa/` and `tests/ut/sa/` per service

---

### 14b. PCMD & Trace (Cross-Component Domain)

PCMD (Per-Call Measurement Data) and trace management span all C-Plane components. This is one of the largest cross-cutting domains — PRs may involve any layer of the stack.

#### 14b.1 Architecture Overview

```
  Trace Controller NR (external process)
       ↕  SysCom (register/start/stop/overload/vendor records)
  ┌─────────────────────────────────────────────────────────┐
  │                    C-Plane PCMD Stack                     │
  │                                                           │
  │  cp_cl (cell-level)         cp_ue (per-UE)                │
  │  ┌─────────────────┐       ┌──────────────────────┐      │
  │  │ ManagementService│       │ PcmdService           │      │
  │  │ CpClService      │       │ ConcreteUePcmdSession │      │
  │  │                  │       │ PcmdTicket            │      │
  │  │ Cell resource    │       │ CpUeTraceController   │      │
  │  │ registration,    │──────▶│ NrSender              │      │
  │  │ start/stop,      │ params│                       │      │
  │  │ bulk stop        │       │ collect() → ticket    │      │
  │  └─────────────────┘       │ sendTicket() →         │      │
  │                             │  AppVendorRecordInd   │      │
  │  CP-NRT (CU-UP side)       └──────────────────────┘      │
  │  ┌─────────────────┐                                      │
  │  │ TraceController  │  CP-RT (helpers)                     │
  │  │ Service          │  ┌──────────────────┐               │
  │  │ UePcmdSession    │  │ PcmdHelper        │               │
  │  │ Manager          │  │ (cause classif,   │               │
  │  │ PcmdRecords      │  │  angle mapping)   │               │
  │  │ Service          │  │ CprtTraceMgmtApp  │               │
  │  │ SBA/MBA session  │  │ (RCP trace mgmt)  │               │
  │  └─────────────────┘  └──────────────────┘               │
  │                                                           │
  │  Shared library: cu/libs/pcmd/                            │
  │  (types, senders, receivers, dispatchers)                  │
  └─────────────────────────────────────────────────────────┘
```

#### 14b.2 Component Roles

| Component      | PCMD/Trace Role                                                          | Key Classes                                                                          |
| -------------- | ------------------------------------------------------------------------ | ------------------------------------------------------------------------------------ |
| `cu/libs/pcmd` | Shared Prophy types, syscom sender/receiver, `PcmdDispatcher`            | `TraceControllerNrSender`, `TraceControllerNrReceiver`, `PcmdDispatcher`             |
| `cp_ue`        | Per-UE PCMD ticket creation, event collection, vendor record send        | `PcmdService`, `ConcreteUePcmdSession`, `PcmdTicket`, `CpUeTraceControllerNrSender`  |
| `cp_cl`        | Cell-level resource registration, start/stop, bulk UE stop, trace params | `ManagementService`, `ConcreteManagementService`, `CpClService`, `CellConfigService` |
| `CP-NRT`       | CU-UP side trace sessions (SBA/MBA), PCMD records for bearer/PDU events  | `TraceControllerService`, `UePcmdSessionManager`, `PcmdRecordsService`               |
| `CP-RT`        | Cause classification helpers, angle mapping, RCP trace management thread | `PcmdHelper`, `CprtTraceMgmtApp`, `CprtTraceMgmtThread`                              |

#### 14b.3 Key File Locations

```
cu/libs/pcmd/types/                      → Prophy PCMD record field types
cu/libs/pcmd/senders/                    → TraceControllerNrSender (syscom send)
cu/libs/pcmd/receivers/                  → TraceControllerNrReceiver (syscom receive)
cu/libs/pcmd/dispatchers/                → PcmdDispatcher (route TC messages)

cu/cp_ue/src/services/pcmd/common/       → PcmdService (facade)
cu/cp_ue/src/services/pcmd/sessions/     → UePcmdSession, ConcreteUePcmdSession
cu/cp_ue/src/services/pcmd/tickets/      → PcmdTicket (collects events, builds records)
cu/cp_ue/src/services/pcmd/senders/      → CpUeTraceControllerNrSender
cu/cp_ue/src/services/pcmd/trace_start_service/  → Trace activation
cu/cp_ue/src/services/pcmd/deactivate_trace_service/  → Trace deactivation

cu/cp_cl/src/pcmd/services/              → ManagementService, CpClService, CellConfigService
cu/cp_cl/src/pcmd/senders/               → CpCl trace sender
cu/cp_cl/src/pcmd/receivers/             → CpCl trace receiver
cu/cp_cl/src/pcmd/dispatchers/           → CpCl trace dispatcher

CP-NRT/CP-NRT/src/trace_controller/      → TraceControllerService, UePcmdSessionManager, PcmdRecordsService
CP-NRT/CP-NRT/src/scenario/cplaneScenarios/  → TraceStartScenario, DeactivateTraceScenario

CP-RT/CP-RT/src/common/pcmd_helpers/     → PcmdHelper, MsgBuilders, Converters
CP-RT/CP-RT/src/main/src/tracemanagement_app/  → CprtTraceMgmtApp, CprtTraceMgmtThread
```

#### 14b.4 PCMD Data Flow

1. **Trace Controller NR** (external) sends resource start/stop to **cp_cl** via SysCom
2. **cp_cl** `ManagementService` registers cells, builds trace parameters, provides them to **cp_ue**
3. **cp_ue** `ConcreteUePcmdSession` collects UE events into **`PcmdTicket`** during procedures
4. **cp_ue** `sendTicket()` builds `AppVendorRecordInd` from ticket records, sends via `CpUeTraceControllerNrSender`
5. **CP-NRT** `TraceControllerService` manages SBA/MBA sessions, `PcmdRecordsService` builds CU-UP side records
6. **CP-RT** `PcmdHelper` classifies F1AP causes for DU call final status; `CprtTraceMgmtApp` handles RCP trace

#### 14b.5 Trace Activation Types

- **MBA** (Management-Based Activation): OAM-triggered, cell-wide
- **SBA** (Signaling-Based Activation): per-UE, triggered via NGAP trace start
- Both managed by `cp_cl` (cell registration) and propagated to `cp_ue` (per-UE sessions)

#### 14b.6 Message Tracing (separate from PCMD)

`cu/libs/message_tracing/` provides **RCP/EMIL message tracing** (process-local), separate from the PCMD vendor record pipeline:
- `TraceMgmt` wraps `rcp_msg_trace::TraceMgmt` from `tracemanagementlib`
- Registers on ZMQ receiver fd for CU components; CP-RT uses epoll in `CprtTraceMgmtApp`
- Controlled by `emilTracingEnabled` flag and RAD param `rdFakeTracingStatusNotification`

#### 14b.7 SCT Tests

```
cu/cp_ue/sct/testcases/TestPcmdAndTrace.ttcn3
cu/cp_ue/sct/testcases/TestPcmdTraceControllerRestart.ttcn3
cu/cp_ue/sct/procedures/PcmdAndTraceProcedures.ttcn3
CP-RT/CP-RT/SCT/Ttcn3/testcases/Pcmd/TestPcmdUeSetupAndRelease.ttcn3
CP-RT/CP-RT/SCT/Ttcn3/testcases/Pcmd/TestPcmdUeHandover.ttcn3
CP-RT/CP-RT/SCT/Ttcn3/testcases/Pcmd/TestPcmdSbaManagement.ttcn3
CP-RT/CP-RT/SCT/Ttcn3/testcases/Pcmd/TestPcmdCarrierAggregation.ttcn3
```

#### 14b.8 Investigation Hints

- PCMD ticket issues: start from `cp_ue/src/services/pcmd/sessions/` — check `collect()` calls and `sendTicket()` logic
- Trace activation failures: check `cp_cl/src/pcmd/services/` — resource registration and cell config
- CP-NRT trace issues: check `CP-NRT/.../trace_controller/` — SBA/MBA session lifecycle
- Missing PCMD records: verify `PcmdTicket` has the record type in its `supportedRecordIds`
- Trace Controller restart: see `TestPcmdTraceControllerRestart.ttcn3` for expected recovery behavior

---

### 14c. Other CP-RT Services

Beyond the core UE/cell/RRM services documented in §14, CP-RT contains additional service domains that may appear in PRs:

| Service                         | Code Path                                                | Purpose                                                                                                                 | Key Classes                                                                                                                        |
| ------------------------------- | -------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| **Positioning**                 | `CP-RT/CP-RT/src/services/positioning_mgmt/`             | NR positioning measurement via F1AP + L2 PS: TRP info exchange, measurement sessions, PM counters                       | `PositioningMgmtService`, `PositioningMeasurementSession`, `PositioningTrpExchangeTask`                                            |
| **Public Warning System (PWS)** | `CP-RT/CP-RT/src/services/public_warning_system/`        | ETWS/CMAS via F1AP `WriteReplaceWarningRequest` / `PWSCancelRequest`, L2 PS PWS msg add/replace/delete                  | `PublicWarningSystemService`, `ConcretePublicWarningSystem`, `PWSSetupProcedureEngine`, `ETWSSetupPerformer`, `CMASSetupPerformer` |
| **Auto Access Barring (UAC)**   | `CP-RT/CP-RT/src/services/auto_access_barring/`          | Automatic Unified Access Class barring based on CU/DU overload, RRC/PUCCH load; drives SIB updates                      | `AutoAccessBarringService`, `UacFsm`, `AutoUacHysteresisManager`, `RrcLoadMonitor`, `PucchLoadMonitor`                             |
| **ML Management**               | `CP-RT/CP-RT/src/services/ml_mgmt/`                      | External ML plane integration: use-case availability, model training/accuracy indications, per-cell activate/deactivate | `MlMgmtService`, `MlManager`, `MlActivateManager`, `CellMlActivateTask`, `AIMLContext`                                             |
| **Load Reporting (F1)**         | `CP-RT/CP-RT/src/services/load_report_mgmt/`             | F1 load reporting: DL/UL GBR load, RRC/PUCCH/CSI-RS/SR load calculators, periodic aggregation                           | `LoadReportingService`, `LoadReportingManager`, `{Rrc,PucchSr,DlGbr,...}LoadCalculator`                                            |
| **L2 PS Management**            | `CP-RT/CP-RT/src/services/l2ps_mgmt/`                    | PWS offline storage forwarding to L2 PS                                                                                 | `L2PsInterface`                                                                                                                    |
| **Slice-Aware Admission**       | `CP-RT/CP-RT/src/common/slice_aware/`                    | Per-cell UE context for slice/resource-group aware admission: CSI/SR/user resource-group bookkeeping                    | `CellUserContext`, `UserRgInformation`, `SrRgInformation`, `CsiRgInformation`                                                      |
| **Paging**                      | `CP-RT/CP-RT/src/services/cprt_cen_ue_mgmt/` + cell_mgmt | F1AP paging dispatch (via `CpRtCenUeApp`), paging policy, eDRX support                                                  | `PagingHandler`, `InternalCellPagingTaskFactory`                                                                                   |

**Paging flow:** F1AP paging arrives at `CpIfDuApp` → SysCom to `CpRtCenUeApp` → `PagingHandler` → `InternalCellPagingTask` via cell mgmt. RAN paging for RRC inactive is handled by `cp_ue` (`ConcreteRanPagingProcedure`). NGAP paging routing is in `cp_if` (`SCTPNGRouter`).

**SCT tests:**
```
CP-RT/CP-RT/SCT/Ttcn3/testcases/TestPositioningMeasurementProcedure.ttcn3
CP-RT/CP-RT/SCT/Ttcn3/testcases/TestPWS.ttcn3
CP-RT/CP-RT/SCT/Ttcn3/testcases/TestLoadReporting.ttcn3
CP-RT/CP-RT/SCT/Ttcn3/testcases/TestMachineLearning.ttcn3
CP-RT/CP-RT/SCT/Ttcn3/testcases/SliceAwareAdmissionControl/TestSAUserBasedSliceAware.ttcn3
```

---

### 14d. Other CP-NRT Services

Beyond the core bearer/PDU/OAM scenarios documented in §13, CP-NRT contains additional service domains:

| Service                                 | Code Path                                                                                         | Purpose                                                                                                                                      | Key Classes                                                                                                                 |
| --------------------------------------- | ------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| **Dynamic Data Path Supervision (DPS)** | `CP-NRT/CP-NRT/src/dynamic_data_path_supervision_service/` + `dynamicDataPathSupervisionContext/` | GTP-U data path supervision via TRSW: register/remove/clear paths, path status monitoring, recovery timers, E1 partial reset on failed paths | `DynamicDataPathSupervisionService`, `DynamicDataPathSupervisionContextManager`, `DynamicDataPathSupervisionFailureHandler` |
| **Dynamic Firewall**                    | `CP-NRT/CP-NRT/src/dynamic_firewall_service/`                                                     | Runtime TRSW firewall open/close for IP connections (pool-wide and per-UE), including cloud deployment variants                              | `DynamicFirewallService`, `DynamicFirewallProcedureFactory`, firewall rule procedures (Open, Close, OpenUe, CloseAll)       |
| **Load Manager**                        | `CP-NRT/CP-NRT/src/scenario/load_manager/`                                                        | L2 HI load measurement report handling: stores UP UE CPU load in `PoolDataProvider`                                                          | `LoadManagerScenario`                                                                                                       |

**Key messages:**
- DPS: `TrswDynamicDataPathSupervisionReq/Resp`, `TrswDynamicDataPathStatusInd`
- Firewall: TRSW firewall open/close requests via proxy
- Load: `L2HiMessage` wrapping `LoadMeasurementRepInd_t`

**SCT tests:**
```
CP-NRT/CP-NRT/sct/testcases/TestDynamicFirewall.ttcn3
CP-NRT/CP-NRT/sct/testcases/TestNetworkplan.ttcn3  (includes DPS scenarios)
```

**Unit tests:**
```
CP-NRT/CP-NRT/tests/ut/dynamic_data_path_supervision_service/
CP-NRT/CP-NRT/tests/ut/dynamic_firewall_service/
```

---

## Part III — Architecture & Threading

### 15. Threading / Concurrency Model

#### CP-RT (Multi-threaded — Critical for race condition investigation)

CP-RT (`Cprt`) runs multiple dedicated thread applications. Each has its own event loop:

| Thread App  | Primary Role         | Log signature                 |
| ----------- | -------------------- | ----------------------------- |
| `CprtApp`   | Main coordinator     | `ASC-1515-*-Cprt`             |
| `CpIfDuApp` | F1AP I/O with gNB-DU | `ASC-1515-*-Cprt`             |
| `CprtUeApp` | UE procedure FSMs    | `ASC-1515-2-Cprt 85-cp_rt_ue` |
| `CprtBeApp` | BE plane             | —                             |
| `CprtRPApp` | RP plane, RAN params | —                             |

**Interfaces between CP-RT threads** use typed `.mt` message definitions (`CP-RT/itf/cp/rt/`).
**Interfaces from cp_ue to CP-RT**: SysCom envelope `itf::cp::cpue_cprt::SCpUeCpRtSyscomCommunicationEnvelope`.

**Intermittent failure investigation rules for CP-RT:**
1. Check inter-thread message ordering — does the failure depend on which thread processes first?
2. Use `GTEST_SHUFFLE=1 GTEST_REPEAT=10` to expose race conditions in unit tests
3. Look at the F1AP message flow: `CpIfDuApp` (receives from DU) → `CprtUeApp` (processes FSM)
4. Check for FSM state guard conditions — can the FSM be in wrong state due to concurrency?

#### CP-NRT (Scenario-driven, lighter concurrency)
- `ScenarioHandler` dispatches events sequentially to scenario classes
- Lighter concurrency model than CP-RT

#### cu/ components
- SCT tests use explicit timing via `f_UT_delay`
- `GTEST_SHUFFLE=1 GTEST_REPEAT=N` for race detection in unit tests

#### CP-RT Detailed Lock Patterns and Synchronization

**ThreadGuard (4 `std::shared_mutex`, file-scope anonymous namespace in `ThreadGuard.cpp`):**

| Lock                  | Read guard                         | Write guard                          | Protects                                                          |
| --------------------- | ---------------------------------- | ------------------------------------ | ----------------------------------------------------------------- |
| `cellConfigLock`      | `createCellConfigReadGuard()`      | `createCellConfigUpdateGuard()`      | Cell configuration data; main thread writes, UE threads read-copy |
| `niddConfigLock`      | `createNiddConfigReadGuard()`      | `createNiddConfigUpdateGuard()`      | NIDD/network plan shared state                                    |
| `traceSessionLock`    | `createTraceSessionReadGuard()`    | `createTraceSessionUpdateGuard()`    | Trace session data in LOM                                         |
| `l2NrtPoolConfigLock` | `createL2NrtPoolConfigReadGuard()` | `createL2NrtPoolConfigUpdateGuard()` | L2 NRT pool configuration                                         |

**Write re-entrancy:** `LockDepthGuard` (atomic counter) enforces **at most one active write guard** at a time across all four locks. Second write → `gsl::Expects(false)`.

**Version atomics (lock-free cross-thread sync):**
- `cellVersionInRtThread` (`std::atomic<uint32_t>`) — bumped in `CellConfigWriteGuard` destructor
- `niddVersionInRtThread` (`std::atomic<uint64_t>`) — bumped in `NiddConfigWriteGuard` destructor
- UE threads compare local `cellVersionInThisThread`/`niddVersionInThisThread` to RT versions via `BaseVersionSynchronizationManager::syncCellConfig/syncNiddConfig`; on mismatch: take read guard → copy config → update local version
- `CprtUeVersionSynchronizationManager` extends base: refreshes UE-scoped NIDD maps and sends `CpRtUe_VersionSynchronizationInd` to main thread

**Per-thread synchronization:**

| Thread                     | Locks held                                                                           | Shared data access                                                                                     |
| -------------------------- | ------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------ |
| **CprtApp** (`cp_rt`)      | All 4 ThreadGuard write guards for mutations; read guards during cross-thread copies | Authoritative cell/NIDD/pool/trace config; `ignoreCcchDataRcvInd` (`std::atomic<bool>`)                |
| **CprtUeApp** (`cprtue`)   | ThreadGuard read guards for config sync; version atomics for change detection        | Local copies of cell/NIDD config; `UeThreadMgmtService` handles version sync indications               |
| **CpIfDuApp** (`cp_if_du`) | No ThreadGuard usage; SCTP/F1 internals may use own primitives                       | Routes via SysCom: paging → cenUE CPID, UE-associated → per-UE-thread CPID, non-UE → main `cp_rt` CPID |
| **CprtBeApp** (`cp_rt_be`) | `BeamConfig::mutex` (static `std::mutex` in `BeamConfig.hpp`) for shared beam data   | Shared `BeamConfig*` from process setup                                                                |
| **CprtRPApp**              | Only syncs NIDD version via `CprtRPVersionSynchronizationManager`                    | RAN parameters                                                                                         |

**Additional `std::mutex` instances in CP-RT (outside ThreadGuard):**

| Mutex                            | In class                            | Protects                     |
| -------------------------------- | ----------------------------------- | ---------------------------- |
| `BeamConfig::mutex` (static)     | `BeamConfig`                        | Beam repository              |
| `PmCounterUpdater::mutex`        | `PmCounterUpdater.hpp`              | PM counters                  |
| `cellMapMutex`                   | `SemiDynamicBwSwitchGuardService`   | Per-cell reconfig map        |
| Per-map mutexes                  | `PeriodicUeCountersUpdater`         | UE counter maps              |
| `searchSpaceIdAvailabilityMutex` | `UeSparseSssgUtilities`             | Search space ID availability |
| `ProtectedData::mtx`             | `DuSyncInformationService`          | Sync status                  |
| `mutex` (shared_mutex)           | `BeamWeightJsonFileRelationStorage` | File relation storage        |

**Inter-thread message passing:** SysCom (`ISyscomPort::sendMsg`, `ISyscomMsgDispatcher::receiveAndDispatchMsg`) with per-component CPIDs. No `InterThreadMsgSender` class exists — threads communicate exclusively via SysCom ports + `InternalPort` for same-thread events + timer port.

**Response/callback handling:** `ResponseMsgHandler<MsgPort, MsgFilter>` registers `msgPort.listen(msgId, filter, handler)` with RAII `RegistrationToken` (auto-deregister on destruction). `WithTimeoutMsgHandler` wraps nested handler + `requestTimerToken` on `ITimerPort`. Timer callbacks are delivered through the same `SyscomMsgDispatcher` on the owning thread — no arbitrary pthread callbacks.

**Overload management:** `OverloadManager` uses `mutex` (for `threadsOverload` map, UE thread max overload), `schedulingOvlMutex` (cell overload set), `signallingOvlMutex` (L2 pool overload set), `excludedCellsForCaMutex` (excluded CA cells). `OverloadMonitor` hooks message queue depth via `CcsMessageQueueMonitor::record` → `OverloadObserver` (`onEntry`/`onChange`/`onExit`). Main thread uses `createMainThreadMonitor`, UE threads use `createUeThreadMonitor`.

**Debug hook:** `rdArtificialInterThreadDelay` R&D flag → `DelayedSendSyscomPort` inserts `usleep` before SysCom send (stress/test only)

---

### 16. Build & Test Infrastructure

All builds and tests use `gnb_build/build.py` from the workspace root (`/workspace`).
Run `gnb_build/build.py --icecc cplane -h` for full component/sub-component help.

#### 16.1 Build Tool Overview

```
gnb_build/build.py --icecc cplane [-t TARGET] {cu,cprt,cpnrt,libs,shb} ...
                                               └ cu {all,cpcl,cpe2,cpif,cpnb,cpsb,cpue}
```

Targets: `airframe`, `airframe-dyn`, `airscale`, `airscale-dyn`, `native` (default: `native`)

Build steps (append to command): `sdk`, `config`, `build`, `run`

**Build types per component:**

| Component  | Available build types                                                                 |
| ---------- | ------------------------------------------------------------------------------------- |
| `cu <sub>` | `sct`, `ut`, `app`, `format`, ...                                                     |
| `cprt`     | `sct`, `ut`, `app`, `coal`, `ttcn3_lint`, `format`, `csa_app`, `csa_ut`, `clang_tidy` |
| `cpnrt`    | `sct`, `ut`, `app`, ...                                                               |

Run `gnb_build/build.py --icecc cplane <component> -h` to see all available types.

#### 16.2 Build Commands — cu/ components
```bash
gnb_build/build.py --icecc cplane cu cpue app build    # build cp_ue
gnb_build/build.py --icecc cplane cu cpcl app build    # build cp_cl
gnb_build/build.py --icecc cplane cu cpif app build    # build cp_if
gnb_build/build.py --icecc cplane cu cpsb app build    # build cp_sb
gnb_build/build.py --icecc cplane cu cpnb app build    # build cp_nb
gnb_build/build.py --icecc cplane cu cpe2 app build    # build cp_e2
gnb_build/build.py --icecc cplane cu all app build     # build all cu/ components
```

#### 16.3 Build Commands — CP-NRT and CP-RT

```bash
gnb_build/build.py --icecc cplane cpnrt app build      # build CP-NRT (cp-nrt binary)
gnb_build/build.py --icecc cplane cprt app build        # build CP-RT (Cprt binary)
```

#### 16.4 Unit Tests
```bash
# cu/ component UTs
gnb_build/build.py --icecc cplane cu cpue ut run        # cp_ue UTs
gnb_build/build.py --icecc cplane cu cpcl ut run        # cp_cl UTs
gnb_build/build.py --icecc cplane cu cpif ut run        # cp_if UTs
gnb_build/build.py --icecc cplane cu cpsb ut run        # cp_sb UTs
gnb_build/build.py --icecc cplane cu cpnb ut run        # cp_nb UTs
gnb_build/build.py --icecc cplane cu cpe2 ut run        # cp_e2 UTs

# CP-NRT / CP-RT UTs
gnb_build/build.py --icecc cplane cpnrt ut run          # CP-NRT all UTs
gnb_build/build.py --icecc cplane cprt ut run            # CP-RT all UTs

# Run specific UT target with filter and verbose logging
gnb_build/build.py --icecc cplane cprt ut -t nidd_config_UT --ut-verbose debug -f "*getRimConfig*" run

# Shuffle for race condition detection
gnb_build/build.py --icecc cplane cprt ut -t <target> -s run

# Debug a UT (opens debugger)
gnb_build/build.py --icecc cplane cprt ut -t <target> debug
```

#### 16.5 SCT Tests (TTCN3)
```bash
# cu/ components
gnb_build/build.py --icecc cplane cu cpue sct run       # cp_ue SCTs
gnb_build/build.py --icecc cplane cu cpsb sct run       # cp_sb SCTs
gnb_build/build.py --icecc cplane cu cpe2 sct run       # cp_e2 SCTs

# CP-RT and CP-NRT
gnb_build/build.py --icecc cplane cprt sct run           # CP-RT SCTs
gnb_build/build.py --icecc cplane cpnrt sct run          # CP-NRT SCTs

# Run specific SCT test by pattern
gnb_build/build.py --icecc cplane cu cpue sct -p "testCaseName" run

# Filter by basket
gnb_build/build.py --icecc cplane cu cpcl sct -b wip run
gnb_build/build.py --icecc cplane cu cpue sct -b stable run

# Repeat for flakiness detection
gnb_build/build.py --icecc cplane cu cpsb sct -r 5 run

# Re-run only last-failed tests
gnb_build/build.py --icecc cplane cu cpue sct --last-failed run

# Profiling
gnb_build/build.py --icecc cplane cu cpue sct --profile-callgrind run
gnb_build/build.py --icecc cplane cu cpue sct --profile-memcheck run
```

#### 16.6 Code Formatting
```bash
ninja format
# or
/workspace/cplane/scripts/format_code.sh --cp-cu --exclude /workspace/cplane/build
```

#### 16.7 TTCN3 Test Patterns
| Pattern                                      | Usage                                               |
| -------------------------------------------- | --------------------------------------------------- |
| `f_UT_delay(seconds)`                        | Timing delays — CHECK CAREFULLY for race conditions |
| `bearerSetupProcedureOk(req, true)`          | Assert DRB setup succeeded with expected request    |
| `bearerSetupProcedureWitSecurityParams(...)` | Internal NSA L2 expected template builder           |
| `cuBearerContextSetupProcedureNsa(...)`      | Full NSA bearer setup procedure                     |
| `hiUserCuPort.receive(p_bearerSetupReq)`     | L2 receive assertion with template                  |
| `BTSs["CONFIG_ID"]`                          | Test parametrization by BTS configuration           |
| `@wip` / `@stable` baskets                   | Test filtering                                      |
| `SCT_TTCN3_REPEAT_COUNT`                     | Repeat for flakiness detection                      |

---

---

### 17. Log Format Reference

#### 17.1 Format A — Lab / SCT / HO.log style (ASC prefix)

```
<hex_line> ASC-<sicad>-<thread_n>-<process> <ISO-timestamp>Z <LEVEL>/<module>/<file>:<line> <message>
```

**Examples:**
```
1a ASC-1515-2-Cprt <2026-02-10T15:43:30.545141Z> 85-cp_rt_ue DBG/cp_rt/UeMessageChecker.cpp:406 [ueIdCu:32768,ueIdDu:2] is UE message
4e ASC-151C-2-cp_ue <2026-02-10T15:43:30.545089Z> 64-cp_ue DBG/cp_ue/SyscomF1apSenderService.cpp:252 sendUeContextModificationRequest
```

#### 17.2 Format B — Production / RAIN log style (pod prefix)

```
<hex> po-<process>-<instance>-ctr-<component>-<EID>-<n>-<Binary> <ISO-timestamp>Z <thread_hex>-<thread_name> <LEVEL>/<module>/<file>:<line> <message>
```

**Examples from RAIN-cells_remain_ES-Snapshot_MRBTS-ALL_OK.log:**
```
46 po-cprt-0-ctr-cprt-E400-0-Cprt <2026-03-14T13:35:55.267204Z> EF-cp_rt_ue WRN/cp_rt/UeRrcMessageSender.cpp:xxx Timeout RLF Guard Timer
46 po-cprt-0-ctr-cprt-E400-0-Cprt <2026-03-14T13:34:35.839647Z> DD-cp_rt INF/cp_rt/...
52 po-oamconfig-0-ctr-oamconfig-E010-0-CPCONFI <2026-03-14T13:01:40.376Z> 127-CPCONFIG INF/...
52 po-oamconfig-0-ctr-oamconfig-E010-0-NTS <2026-03-14T13:01:40.376Z> D2-NTS INF/...
```

**Key differences from Format A:**
- Process is identified by **pod name** (`po-cprt-0-ctr-cprt-E400-0-Cprt`), not `ASC-<sicad>`
- Thread is shown as `<hex>-<name>` (e.g., `EF-cp_rt_ue`, `DD-cp_rt`, `DC-cp_if_du`)
- OAM components share pod `po-oamconfig-0` but differ by binary suffix (`-CPCONFI`, `-NTS`, `-NRTS`)

#### 17.3 Log level codes

`DBG` (debug), `INF` (info), `WRN` (warning), `ERR` (error)

#### 17.4 Process ↔ log prefix map (both formats)

| Format A prefix    | Format B pod/thread                        | Process   | Binary             |
| ------------------ | ------------------------------------------ | --------- | ------------------ |
| `ASC-151c-*-cp_ue` | `po-cprt-…-Cprt` + thread `*-cp_ue`        | cp_ue     | shared lib in Cprt |
| `ASC-1515-*-Cprt`  | `po-cprt-…-Cprt` + thread `DD-cp_rt`       | cp_rt     | `Cprt`             |
| —                  | `po-cprt-…-Cprt` + thread `EF-cp_rt_ue`    | cp_rt_ue  | `Cprt`             |
| —                  | `po-cprt-…-Cprt` + thread `DC-cp_if_du`    | cp_if_du  | `Cprt`             |
| `ASC-*-cp-nrt`     | `po-cpnrt-…-cp-nrt`                        | cp-nrt    | `cp-nrt`           |
| —                  | `po-oamconfig-…-CPCONFI` + `127-CPCONFIG`  | CPCONFIG  | oamconfig          |
| —                  | `po-oamconfig-…-NTS` + `D2-NTS` / `D4-NTS` | NTS/NRTS  | oamconfig          |
| —                  | `po-oamfh-…-REM` + `B8-REM`                | REM       | oamfh              |
| —                  | `po-oamasm-…-oamembe` + `CE-CmStatusSer0`  | emservice | oamasm             |
| —                  | `po-oamext-…`                              | oamext    | oamext             |

#### 17.5 Context tags

- **UE context (CP-RT):** `[ueIdCu:X,ueIdDu:Y,intUeIdDu:Z]`
- **Cell context (CP-RT):** `[CELL] nrCellIdentity:XXXXX`
- **Scenario context (CPCONFIG):** `NrcellRAsyncScenario`, `NrcellRSyncScenario`

#### 17.6 Cross-process message tracing

- cp_ue sends: `message sent itf::cp::cpue_cprt::SCpUeCpRtSyscomCommunicationEnvelope(0x<msgId>), size: N bytes`
- CP-RT receives: `message recv itf::cp::cpue_cprt::SCpUeCpRtSyscomCommunicationEnvelope(0x<msgId>)`
- grep hint: search for `ueIdCu:X` to trace all log lines for a specific UE across processes

#### 17.7 Identifying the log format

```
grep -q "^.. ASC-" <logfile> && echo "Format A (Lab/SCT)" || echo "Format B (Production/RAIN)"
```
Always run this check first to select the correct grep patterns for investigation.

---

## Part IV — Investigation Methodology

### 18. Problem Classification

| Type                     | Indicators                                | Common Root Causes                                        |
| ------------------------ | ----------------------------------------- | --------------------------------------------------------- |
| **Fault / Alarm**        | Fault/alarm ID in Actual Result           | Timeout, validation failure, protocol violation           |
| **Crash**                | Process crash, abort, segfault, core dump | Null pointer, memory corruption, assertion                |
| **Hang / Timeout**       | No response, stuck, operation timed out   | Deadlock, missing response handler, infinite wait         |
| **Unexpected Behavior**  | Wrong state, wrong value, missing message | Logic error, state machine bug, missing case              |
| **Performance / KPI**    | KPI below threshold, throughput drop      | Bottleneck, misconfiguration, counter error               |
| **Configuration Issue**  | Parameter rejected, config not applied    | Validation failure, wrong value range, missing dependency |
| **Regression**           | "Was passing before", new SW version      | Code change, flag behavior, dependency update             |
| **Intermittent / Flaky** | Sometimes fails, timing-dependent         | Race condition, timing window, ordering dependency        |
| **Memory / Resource**    | Memory growing, OOM, resource exhaustion  | Leak, missing cleanup, unbounded container                |

---

### 19. Codebase Search Strategy

#### 19.1 By Classification

| Classification          | Search Targets in C-Plane                                                          |
| ----------------------- | ---------------------------------------------------------------------------------- |
| **Fault/Alarm**         | Fault handler; alarm source; fault activation condition                            |
| **Crash**               | Stack trace functions → `cu/cp_*/src/`; null checks; protocol handler              |
| **Hang/Timeout**        | Timer setup; awaited response; stuck state; message handler registration           |
| **Unexpected Behavior** | State machine; message handler; factory/creator; template builder                  |
| **Configuration**       | Parameter validation; config applier; OAM interface handler                        |
| **Regression**          | `git log -20 -- <file>`; diff between versions; R&D flag conditional               |
| **Intermittent**        | Concurrency patterns; callbacks; shared state; async handoffs; `f_UT_delay` values |
| **Memory**              | Allocation patterns; destructors; cleanup; shared_ptr cycles                       |

#### 19.2 Cursor Tool Usage
```
Grep(pattern, path="cplane/cu/cp_*/")   → exact text/symbol search (regex supported)
Glob("*.ttcn3", dir="cplane/sct/")      → find TTCN3 test files by pattern
Read(path, offset, limit)               → read specific file/range
Shell("git log --oneline -20 -- <f>")  → regression analysis
Shell("rg 'pattern' cplane/cu/")        → fast log/code search
Shell("gnb_build/build.py --icecc cplane cu cpue ut run")  → run cp_ue UTs
Shell("gnb_build/build.py --icecc cplane cprt ut run")     → run CP-RT UTs
Task(explore, ...)                       → spawn subagent for large search
Task(shell, "gnb_build/build.py ...")   → spawn shell subagent for builds
```

#### 19.3 Protocol and Component Search Hints

| Concern                     | Where to Search                                                        |
| --------------------------- | ---------------------------------------------------------------------- |
| F1AP protocol handling      | `cu/cp_if/` + `sct/protocols/F1AP/` + `sct/libraries/Lib3GPP/F1AP/`    |
| F1AP UE FSM (real-time)     | `CP-RT/CP-RT/src/services/ue_mgmt/`                                    |
| E1AP protocol handling      | `cu/cp_if/` + `sct/protocols/E1AP/` + `sct/libraries/Messages/IfE1AP/` |
| E1AP bearer scenarios (NRT) | `CP-NRT/CP-NRT/src/scenario/bearer/` + `ScenarioHandler.cpp`           |
| XNAP                        | `cu/cp_if/` + `sct/protocols/XNAP/`                                    |
| NR RRC                      | `cu/cp_sb/` + `sct/protocols/NR_RRC/`                                  |
| Energy Saving               | `cu/cp_cl/src/`                                                        |
| Load Reporting              | `cu/cp_cl/src/load_reporting_service/`                                 |
| E2                          | `cu/cp_e2/`                                                            |
| NSA UE setup (RT)           | `CP-RT/CP-RT/src/services/ue_mgmt/ue_procedures/ue_setup/src/nsa/`     |
| SA UE setup (RT)            | `CP-RT/CP-RT/src/services/ue_mgmt/ue_procedures/ue_setup/src/sa/`      |
| UE modify / HO (RT)         | `CP-RT/CP-RT/src/services/ue_mgmt/ue_procedures/ue_modify/`            |
| UE release (RT)             | `CP-RT/CP-RT/src/services/ue_mgmt/ue_procedures/ue_release/`           |
| SCell management (RT)       | `CP-RT/CP-RT/src/services/ue_mgmt/ue_procedures/ue_scell_mgmt/`        |
| Cell management (RT)        | `CP-RT/CP-RT/src/services/cell_mgmt/`                                  |
| Pool/OAM config (NRT)       | `CP-NRT/CP-NRT/src/scenario/oamScenarios/` + `pool_configuration/`     |
| IPsec/TRSW config (NRT)     | `CP-NRT/CP-NRT/src/scenario/trsw_addr_config/`                         |
| UE context (NRT)            | `CP-NRT/CP-NRT/src/ueContext/UeContext.hpp`                            |
| cprtue/cprtbe/cprtrp (RT)   | `CP-RT/itf/cp/rt/` (`.mt` interface files)                             |

---

### 20. Log Analysis

#### 20.1 Log Sources
- TTCN3 SCT verdict output (from `ninja sct_run_<comp>`)
- Component logs (`cp_ue`, `cp_cl`, etc.) — logger prefix identifies component
- System logs (if captured on HW setup)
- RAIN test output logs (e.g., `RAIN-cells_remain_ES-Snapshot*.log`)

#### 20.2 Temporal Anchoring (Critical for Large Logs)

**Problem:** Large RAIN/production log files (millions of lines) contain multiple test scenarios interleaved in time. The same scenario may appear multiple times — some runs passing (OK), some failing (NotOK). Unrelated scenarios run before and after. Analyzing the wrong scenario instance produces wrong conclusions.

**Temporal anchoring** is the technique of identifying the **exact time window** of the failing scenario instance before doing any analysis.

**Step-by-step:**

1. **Identify the scenario trigger** from the Pronto description / test steps:

| Scenario Type   | Typical Trigger Event                             | Log Search Pattern                    |
| --------------- | ------------------------------------------------- | ------------------------------------- |
| SA UE setup     | `RRCSetupRequest` / `InitialULRRCMessage`         | `InitialULRRCMessage`, `RRCSetup`     |
| NSA UE setup    | `SgNBAdditionRequest`                             | `SgNBAdditionRequest`, `SgNBAddition` |
| Handover        | `HandoverRequired` / `HandoverRequest`            | `HandoverReq`, `HOPreparation`        |
| Energy Saving   | `GNBDUCellSwitchingIndication` / ES config change | `CellSwitching`, `energySavingState`  |
| Cell activation | `F1SetupRequest` / cell config update             | `F1Setup`, `CellActivation`           |
| Bearer setup    | `BearerContextSetupRequest`                       | `BearerContextSetup`                  |
| UE release      | `UEContextReleaseCommand`                         | `UEContextRelease`                    |
| TTCN3 test      | Testcase function name                            | `Starting testcase`, function name    |

2. **Find the tester's anchor point** — the timestamps/log lines the Pronto author highlighted as the problem. These are your anchor timestamps.

3. **Search backward from anchor** to find the trigger. This gives you the scenario start time. Use:
   ```
   # Find all instances of trigger, then pick the one closest before the anchor
   grep -n "SgNBAdditionRequest" <logfile> | tail -20
   ```

4. **Define the analysis window**: `[trigger_timestamp → anchor_timestamp + margin]`
   - Margin: typically 10-60 seconds after the last symptom, to capture cleanup/release
   - Everything outside this window is noise for this investigation

5. **Tag your window** in all findings: `[ANALYSIS WINDOW: 2026-03-15T10:42:33 → 2026-03-15T10:43:15]`

6. **(Optional) Compare with passing instance**: If the same scenario passed earlier in the log:
   - Find the earlier trigger instance
   - Extract the same analysis window
   - Diff the two: message sequences, timing gaps, state differences
   - Document as: `[PASSING INSTANCE: <ts_start> → <ts_end>]` vs `[FAILING INSTANCE: <ts_start> → <ts_end>]`

**Rules:**
- NEVER mix log lines from different scenario instances in the same causal chain
- ALWAYS state which instance (by timestamp range) you are analyzing
- If multiple failures of the same scenario exist, analyze the one closest to the tester's anchor
- If no anchor timestamps are provided, search for error/failure/fault keywords and use the latest occurrence as anchor

#### 20.3 Log Analysis Tips
- **TTCN3 failure**: Find the failing `receive` call — it tells you exactly which message was not received
- **Timing issues**: `f_UT_delay(X)` values — if X is too short for the operation, expect intermittent failures
- **Counter-based failures**: Look for counter reset events (e.g., "Counter RESET to 1/30") vs. threshold crossing events
- **Protocol flow**: Trace the expected message sequence (from 3GPP spec) and find where it breaks

#### 17.3 Evidence Tagging
Every claim must be tagged:
- `[OBSERVED]` — directly seen in logs, code, or PR text
- `[INFERRED]` — logically derived from observed evidence
- `[ASSUMED]` — no direct evidence — flag clearly, include in Open Questions

---

### 21. Component Ownership Rules

#### Root cause is IN C-Plane if:
- Code path is within `cplane/cu/cp_*/`
- TTCN3 test failure is in a procedure calling `cp_*` component logic
- The 3GPP spec assigns the failing operation to gNB-CU-CP
- Fault is raised by a `cp_*` component handler

#### Root cause is OUTSIDE C-Plane if:
- Log lines show error in another component (L2, OAM, Core, Transport)
- TTCN3 failure is in a lower-layer component (L2, L1)
- 3GPP spec assigns the operation to gNB-DU, gNB-CU-UP, or core
- Crash backtrace points to a library not owned by cplane

#### If outside C-Plane, MUST provide:
1. Component name (L2/L1/OAM/Core/Transport/DU/CU-UP/etc.)
2. Evidence: why this points outside cplane
3. Reassignment recommendation with justification

---

## Part V — Investigation Output

### 22. Output Templates

#### 19.1 Investigation Report (Template 1)

```markdown
# C-Plane PR Investigation Report

## PR: [pr_id] — [title]

## 1. Problem Classification
**Type:** [Fault/Alarm | Crash | Hang/Timeout | Unexpected Behavior | Performance/KPI |
          Configuration Issue | Regression | Intermittent/Flaky | Memory/Resource | Other]
**Component(s):** [cp_ue / cp_sb / cp_if / cp_nb / cp_cl / cp_e2]

## 2. Problem Summary
[1–3 sentences]

## 3. Evidence Collected
| #   | Evidence | Source | Tag |
| --- | -------- | ------ | --- |

## 4. Investigation Workspace
| Evidence Type | Status | Detail |
| ------------- | ------ | ------ |

## 5. Candidate Code Locations
| #   | File | Symbol/Function | Why Relevant | Evidence Tag |
| --- | ---- | --------------- | ------------ | ------------ |

## 6. Root Cause Hypotheses
| #   | Hypothesis | Causal Chain | Supporting | Contradicting | Confidence |
| --- | ---------- | ------------ | ---------- | ------------- | ---------- |

### Confidence Calculation
- [+25] …
- [-15] …
- **Total: X%**

## 7. Recommended Fix
### Proposed Change
[diff-style, exact file paths]
### Why It Works
[causal chain trace]
### Risk / Side Effects
[NSA/SA compat, affected components]

## 8. Alternatives
### Alternative A: …
### Alternative B: …

## 9. Validation Plan
- **UT tests:** `ninja <comp>_UT --gtest_filter="…"`
- **SCT tests:** `SCT_TEST_PATTERNS="…" ninja sct_run_<comp>`
- **New tests:** …
- **Repro checklist:** …
- **Post-fix monitoring:** …
- **Rollback risk:** …

## 10. 3GPP Spec Alignment
- **Specs reviewed:** [TS 38.xxx §x.x]
- **Alignment:** …
- **Deviations:** …

## 11. Component Ownership
**Root cause resides in:** [cp_* component / External]

## 12. Open Questions
[Non-blocking only]

## 13. Confidence Level
**[Confident / Likely / Speculative]** — [justification]
```

#### 19.2 Escalation Report (Template 2)

```markdown
# C-Plane → Cross-Component Escalation Report

## PR: [pr_id] — [title]

## 1. Investigation Summary Within C-Plane
## 2. Evidence Root Cause Is External
| #   | Evidence | Points To | Tag |
| --- | -------- | --------- | --- |
## 3. Hypotheses Ruled Out (C-Plane-internal)
## 4. Recommended Next Component(s)
| Rank | Component | Reasoning | Questions for That Agent |
| ---- | --------- | --------- | ------------------------ |
## 5. Scope Boundary Justification
## 6. Artifacts to Pass Forward
```

#### 19.3 Missing Context Report (Template 3)

```markdown
# C-Plane PR Investigation — HALTED: Missing Context

## PR: [pr_id] — [title]

## 1. Preliminary Classification
## 2. What Was Attempted
## 3. MISSING CONTEXT — BLOCKING QUESTIONS
| #   | Question | Why Blocking | What It Unlocks |
| --- | -------- | ------------ | --------------- |
## 4. Partial Findings
[OBSERVED and INFERRED only — NO speculation]
## 5. Recommended Next Steps
```

---

### 23. Solution Quality Checklist

Before proposing any fix:
- [ ] Fix is at the layer that owns the responsibility (not duplicated elsewhere)
- [ ] NSA and SA variants both covered (unless proven variant-specific and documented)
- [ ] All relevant `cp_*` components checked (not just the one that surfaced the symptom)
- [ ] No unnecessary new state — prefer querying existing data structures
- [ ] Unit tests included (both OK case and NOK case)
- [ ] No changes outside cplane scope

---

## Part VI — Anti-Hallucination Rules

### 24. Mandatory Guardrails

1. **NEVER claim a bug location without citing evidence.** File path + function + why.
2. **NEVER invent log content, fault IDs, file names, parameters, or backtraces.** Only use what is provided or found via tool.
3. **NEVER continue with blocking missing context.** Stop → Missing Context Report.
4. **ALWAYS tag claims:** `[OBSERVED]` / `[INFERRED]` / `[ASSUMED]`.
5. **ALWAYS prefer minimal, low-risk fix** unless constraints allow refactoring.
6. **ALWAYS maintain backward compatibility** (NSA and SA) unless explicitly allowed.
7. **NEVER leak secrets or credentials.** Redact if shown in logs or configs.
8. **NEVER speculate on components without evidence.** At least one concrete piece of evidence required.
9. **ALWAYS verify NSA vs SA variant impact.**
10. **ALWAYS check component boundary.** Confirm `cp_*` ownership before proposing fix.
11. **PROPOSE before IMPLEMENT.** Never apply changes without user agreement.
12. **IF PR lacks repro/logs**, propose a data request: which log levels to enable, which TTCN3 basket to run, which R&D flags to activate.

---

## Part VII — Quick Reference Checklists

### 25. Timing Issue Investigation Checklist (Intermittent / Flaky)
- [ ] Are `f_UT_delay` values sufficient for the operation? (compare to operation's actual duration)
- [ ] Is there a race between configuration apply and counter read?
- [ ] Does the test rely on a counter that can reset mid-test?
- [ ] Does `GTEST_SHUFFLE=1 GTEST_REPEAT=10` reproduce the failure?
- [ ] Is `SCT_TTCN3_REPEAT_COUNT=5` reproducing the SCT failure?

### 26. NSA Bearer Setup PMQAP Checklist
- [ ] Is PMQAP verification needed in NSA mode?
- [ ] Is the expected `bearerSetupReq` template injectable via `p_l2hicuSetupReqList`?
- [ ] Is `performL2HiCuBearerSetupProcedure` using the injected template or building internally?
- [ ] Is the SA equivalent path also updated?
- [ ] Are `pmCountersInfo.pmqapProfileList` fields correctly set in the E1AP message?

### 27. Handover Investigation Checklist
- [ ] Which HO type? (Xn-based, F1-based, inter-gNB, intra-gNB)
- [ ] At which step did the HO procedure fail? (preparation / execution / completion)
- [ ] Was XNAP Handover Request sent? Was Acknowledge received?
- [ ] Was RRC Handover Command correctly prepared and sent to DU?
- [ ] Was source UE context correctly released?
- [ ] Does the failure occur in NSA or SA or both?

### 28. CP-RT FSM Investigation Checklist

- [ ] Which FSM is involved? (UeContextSetupFsm / SAUeContextSetupFsm / UeContextReleaseFsm / UeScellAdditionFsm / other)
- [ ] Is it NSA or SA? (check `tests/ut/nsa/` vs `tests/ut/sa/` for variant-specific behavior)
- [ ] Which thread app processed the event? (`CprtUeApp` / `CpIfDuApp` / `CprtBeApp`)
- [ ] Is the FSM in the correct state for the received event?
- [ ] Is there a guard condition that failed silently?
- [ ] What was the last log line before the failure? (grep `[ueIdCu:X,ueIdDu:Y]`)
- [ ] Was there a cross-thread message that arrived out of order?
- [ ] Does the same FSM state handle the event in BOTH NSA and SA variants?

### 29. CP-NRT Scenario Investigation Checklist

- [ ] Which `ScenarioHandler` event triggered the scenario?
- [ ] Which scenario class is responsible? (grep `ScenarioHandler.cpp` for the message type)
- [ ] Is the scenario a `BearerSetupReq`, `BearerModifyReq`, or `DeltaPlan` variant?
- [ ] Is the issue NSA-specific? (check `itf::TypeOfBearer::NSA` vs `::SA` in `BearerSetupReqBuilder.cpp`)
- [ ] Was the E1AP message correctly parsed? (check `proxy/` ASN deserialize path)
- [ ] Was the L2 HI message correctly built? (check `BearerSetupReqBuilder.cpp`)
- [ ] Is `cpnrt::UeContext` in the expected state?
- [ ] Is `CuUpPicker` selecting the correct CU-UP?

### 30. Energy Saving (ES) Domain Knowledge

#### 30.1 ES Architecture Overview

Energy Saving in gNB is a multi-process feature spanning OAM, C-Plane, and radio layers:

```
emservice (status)          OAM Layer
    ↓
REM (trigger)  →  NTS/NRTS (handler)  →  CPCONFIG (cell MO)
                                              ↓
                                         CP-RT (cell state)
                                              ↓
                                         L1 / Radio (RMOD_R)
```

#### 30.2 Key ES Components and Their Roles

| Component     | Pod/Binary               | Responsibility                                                                                                                          |
| ------------- | ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------- |
| **NTS/NRTS**  | `po-oamconfig-…-NTS`     | Central ES logic: `CellEnergySavingHandler`, `CellEnergySavingFaultToleranceManager`, `ExitEnergySavingHandler`, `SingleCellController` |
| **REM**       | `po-oamfh-…-REM`         | Triggers ES mode changes: `ConfigureEnergySavingModeTrigger`, manages deep sleep timer                                                  |
| **CPCONFIG**  | `po-oamconfig-…-CPCONFI` | Cell MO state machine: updates `energySavingState` via `NrcellRAsyncScenario`, sends `ExitEnergySavingNotif`                            |
| **emservice** | `po-oamasm-…-oamembe`    | Reports ES status: `energySavingState` through `JsonPayloadParser` / `CmStatusService`                                                  |
| **CP-RT**     | `po-cprt-…-Cprt`         | Cell activation/deactivation: `AntennaCarrierActivationReq`, F1AP cell setup                                                            |
| **OAMFM**     | `po-oamfh-…-OAMFM`       | Fault management: plan activation notifications, alarm handling                                                                         |

#### 30.3 ES State Values Observed in Logs

| Parameter            | Values                                         | Where Seen                           |
| -------------------- | ---------------------------------------------- | ------------------------------------ |
| `energySavingState`  | `notEnergySaving`, (presumably `energySaving`) | CPCONFIG MO, emservice status        |
| `energySavingMode`   | `NORMAL`                                       | emservice configuration plans        |
| `operationalState`   | `disabled`, `enabled`                          | Cell MO lifecycle                    |
| `availabilityStatus` | `off line`, `on line`                          | Cell MO lifecycle                    |
| `proceduralStatus`   | `not initiated`, `configured`                  | Cell MO lifecycle                    |
| RMOD_R states        | `SLEEP`, `POWEROFFBYES`, (active)              | Checked by `ExitEnergySavingHandler` |

#### 30.4 ES Investigation Checklist

**OAM / Configuration Layer:**
- [ ] Which strategy is active? (MaxValueSOffStrategy or other)
- [ ] What is the counter threshold and current value?
- [ ] Was a configuration change applied mid-test (resetting the counter)?
- [ ] Was NTS/NRTS killed or restarted during the test? (check for process restart logs — this can cause lost ES state)
- [ ] Did `ConfigureEnergySavingModeTrigger` fire in REM logs?
- [ ] What does NTS `CellEnergySavingHandler` report? Was it created for each cell?
- [ ] Was `CellEnergySavingFaultToleranceManager` active?
- [ ] Did `ExitEnergySavingHandler` attempt to send `EXIT_ENERGY_SAVING_NOTIF`? What was the RMOD_R state?
- [ ] Does CPCONFIG show `NrcellRAsyncScenario` completing or failing for the affected cell?
- [ ] What is the final `energySavingState` in CPCONFIG/emservice logs?

**C-Plane / Cell Layer:**
- [ ] Did CP-RT receive cell activation/deactivation requests for the affected cell? (search `[CELL] nrCellIdentity:`)
- [ ] Were there `AntennaCarrierActivationReq` / completion logs?
- [ ] Is cell protection (last-cell protection) enabled? Is it correctly guarding the transition?
- [ ] Are there UE connection failures around the ES event (RLF timers, BearerErrorInd)?

**Test Infrastructure:**
- [ ] Is the `f_UT_delay` in the TTCN3 test long enough for the counter to reach threshold?
- [ ] Do RAIN logs show "Counter RESET" events at unexpected times?
- [ ] Was there an infrastructure event (pod restart, network glitch) during the test?

#### 30.5 ES-Specific Grep Patterns for RAIN Logs

```bash
# Identify ES-related log lines (run on RAIN logs)
grep -i "energySaving" <logfile> | head -50
grep "CellEnergySavingHandler\|CellEnergySavingFaultToleranceManager\|ExitEnergySavingHandler" <logfile> | head -50
grep "ConfigureEnergySavingModeTrigger" <logfile> | head -20
grep "NrcellRAsyncScenario\|NrcellRSyncScenario" <logfile> | head -30
grep "EXIT_ENERGY_SAVING_NOTIF\|ExitEnergySavingNotif" <logfile> | head -20

# Check for NTS restart (critical for ES state loss)
grep "NTS" <logfile> | grep -i "start\|stop\|kill\|restart\|signal" | head -20

# Cell state changes in CP-RT
grep "nrCellIdentity.*CELL\|AntennaCarrier" <logfile> | head -30

# RMOD_R state (checked by ExitEnergySavingHandler)
grep "RMOD_R\|SLEEP\|POWEROFFBYES" <logfile> | head -20
```