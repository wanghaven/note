# ================================================================================

KNOWLEDGE for C-PLANE AGENT — QUESTION FRAMEWORK
(Use this to maintain and evolve the CPLANE_Agent.md and CPLANE_RULES.md)

## HOW TO USE THIS FORM

• This is the cplane-specific fill of the generic Component_Agent_Question_Framework.
• Sections marked ✅ are filled from existing codebase knowledge.
• Sections marked [TEAM PROVIDED] contain information provided by the team but not fully verified against the codebase.
• Sections marked ⚠️ [REQUIRES INPUT] still need the cplane development team to fill in.
• The completed answers are the source material for the C-Plane PR Investigation Agent.

================================================================================PENDING SYNC

## MAINTENANCE WORKFLOW

### File Roles


| File                                    | Role                                                                    | Read During Investigation?     |
| --------------------------------------- | ----------------------------------------------------------------------- | ------------------------------ |
| **CPLANE_Agent.md**                     | Agent identity, scope, methodology, guardrails                          | Yes -- read first              |
| **CPLANE_RULES.md**                     | Detailed domain knowledge (components, threading, code paths, patterns) | Yes -- primary reference       |
| **CPLANE_Agent_Knowledge_Framework.md** | Raw knowledge database for building/maintaining the above two files     | No -- maintenance only         |
| **CPLANE_Investigation_Request.md**     | User-facing template to start an investigation                          | No -- copied into chat by user |


### How the Files Relate

```
                   ┌─────────────────────────────────┐
                   │  Knowledge Framework (.md)       │
                   │  (raw Q&A knowledge database)    │
                   └──────────┬──────────────────────┘
                              │
                    manual sync (via AI prompt)
                              │
              ┌───────────────┼───────────────┐
              ▼                               ▼
┌──────────────────────┐      ┌──────────────────────────┐
│  CPLANE_Agent.md     │      │  CPLANE_RULES.md         │
│  (identity + method) │      │  (detailed knowledge)    │
└──────────────────────┘      └──────────────────────────┘
              │                               │
              └───────────┬───────────────────┘
                          │
                 read by AI during investigation
                          │
                          ▼
              ┌──────────────────────┐
              │  Investigation       │
              │  Report / Output     │
              └──────────────────────┘
```

### When to Update This File

Update the Knowledge Framework when:

1. **A PR investigation reveals a new pattern** (e.g., a new deadlock scenario, a previously unknown race condition, a new fault ID mapping)
2. **A component's architecture changes** (e.g., new thread app in CP-RT, new scenario type in CP-NRT, new protocol interface)
3. **A `[TEAM PROVIDED]` section is found to be wrong** during an investigation
4. **A new component or feature is added** to C-Plane
5. **Common investigation pitfalls are discovered** (e.g., "fault 4080 with X2AP → always check LTE eNB SCTP association first")

### How to Update (Step by Step)

**Step 1 — Edit this file**
Find the relevant numbered section (e.g., §4.1 for faults, §5.2 for concurrency) and add/correct the content.
If the section doesn't exist, add it under the most relevant numbered heading.
Mark new content with `✅` if verified against the codebase, or `[TEAM PROVIDED]` if based on team knowledge.

**Step 2 — Propagate to operational files**
The Knowledge Framework is NOT read during investigations. Changes here have NO effect until propagated.
Ask the AI in a Cursor chat:

```
The Knowledge Framework (CPLANE_Agent_Knowledge_Framework.md) has been updated
in section [X]. Please:
1. Verify the new content against the codebase
2. Propagate to CPLANE_RULES.md (and CPLANE_Agent.md if scope/methodology changed)
```

**Step 3 — Verify**
The AI will verify against the code, apply updates to the operational files, and report what changed.

### What Does NOT Happen Automatically

- The AI does **not** write back to any PR_Agent file during a normal PR investigation
- There is **no** automated sync between the Knowledge Framework and the operational files
- There is **no** trigger that detects changes in this file and propagates them

All updates to all four files are **manual** — either by a team member editing directly, or by asking the AI to make specific changes.

### Quick Reference: Who Updates What


| Scenario                                            | Who Acts                                                     | What Gets Updated                                      |
| --------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------ |
| Team discovers new domain knowledge                 | Team member edits Knowledge Framework → asks AI to propagate | Knowledge Framework → RULES.md                         |
| AI investigation finds code pattern not in RULES.md | User asks AI to update after investigation                   | RULES.md directly (optionally Knowledge Framework too) |
| Methodology or guardrails need changing             | User asks AI to update                                       | CPLANE_Agent.md                                        |
| Build system or test commands change                | User asks AI to update                                       | CPLANE_Agent.md + RULES.md + Investigation_Request.md  |
| Component is added/removed from scope               | User asks AI to update                                       | All four files                                         |


================================================================================

1. IDENTITY & PURPOSE

================================================================================

1.1  Official name of the component?
      ✅ C-Plane (CP) — the gNB-CU-CP (5G NR gNodeB Centralized Unit — Control Plane).
         Sub-components / processes:
         - cu/ shared: cp_ue, cp_sb, cp_if, cp_nb, cp_cl, cp_e2
         - CP-NRT: non-real-time process `cp-nrt` (E1AP bearer coordination, OAM scenarios)
         - CP-RT: real-time process `Cprt` (F1AP UE procedures, cell management)

```
  ✅ Deployment topology (from architecture doc, verified):
     - **gNB-CU-CP** hosts cu/ components in 4 VNFC classes:
       - 5G-CP-UE (contains CP-UE + CP-SB)
       - 5G-CP-NB (contains CP-NB)
       - 5G-CP-CL (contains CP-CL)
       - 5G-CP-IF (contains CP-IF)
       - 5G-CP-E2 (contains CP-E2)
       - All use SDL, PMAgent, FaultManager
     - **gNB-CU-UP** hosts CP-NRT + L2-HI-CU
       - CP-NRT connects to CU-CP via E1AP (SCTP or SysCom)
     - **gNB-DU** hosts CP-RT + L2-PS + L2-LO + L2-HI-DU + L1
       - CP-RT connects to CU-CP via F1AP (SCTP or SysCom)
     - Classical BTS: all on System Module in LXC containers (CPNB, CPCL, CPIF, CPNRT, CPRT)
       CP-UE deployed on Baseband Card (ABIL/ABIO/ABIN)
     - Cloud BTS: systemd-based startup, VMs on AirFrame; CP-NRT runs in 2-core VM

  ✅ HA models per VNFC (from cu/doc/architecture.adoc, verified):
     - CP-UE: N+ (all active, no standby; failure affects only UEs on that instance)
     - CP-CL: N+ (failure affects only cells on that instance)
     - CP-NB: 2N (active/standby; central configuration services)
     - CP-IF: 2N (active/standby; external link termination)
```

1.2  Terms or acronyms that must be defined upfront?
      ✅
      - PR = Problem Report (Pronto ticket), NOT Pull Request
      - gNB = next-generation NodeB (5G base station)
      - CU-CP = Centralized Unit — Control Plane
      - NSA = Non-Standalone (LTE+NR dual connectivity, EN-DC)
      - SA = Standalone (5G NR only)
      - DRB = Data Radio Bearer
      - SRB = Signalling Radio Bearer
      - UE = User Equipment
      - RRC = Radio Resource Control
      - F1AP = F1 Application Protocol (gNB-CU-CP ↔ gNB-DU)
      - E1AP = E1 Application Protocol (gNB-CU-CP ↔ gNB-CU-UP)
      - XNAP = Xn Application Protocol (peer gNB ↔ gNB)
      - NGAP = NG Application Protocol (gNB-CU-CP ↔ AMF)
      - E2AP = E2 Application Protocol (gNB ↔ O-RAN RIC)
      - PMQAP = PM Quality Assurance for Protocol
      - SCT = System Component Test (TTCN3-based integration tests)
      - UT = Unit Test (GTest-based)
      - HO = Handover
      - ES = Energy Saving
      - MO = Managed Object
      - RAIN = Automated test execution system
      - PCI = Pronto Creation Insights (field in Pronto)

================================================================================
2. SCOPE
================================================================================

2.1  What is IN scope?
      ✅
      - All cp_* sub-components (cp_ue, cp_sb, cp_if, cp_nb, cp_cl, cp_e2)
      - CP-NRT (`cp-nrt`): E1AP bearer/PDU coordination, L2 HI, pool/OAM/IPsec scenarios
      - CP-RT (`Cprt`): F1AP UE setup/modify/release/HO FSMs, cell management, SCell, Xp
      - NR RRC protocol handling
      - F1AP, E1AP, XNAP, NGAP message processing
      - UE context lifecycle (setup, modification, release, handover)
      - Bearer management (DRB/SRB)
      - Cell state machine and energy saving
      - E2/O-RAN interface
      - NSA (EN-DC / MR-DC) and SA procedure flows
      - TTCN3 SCT test logic in sct/

2.2  What is OUT of scope?
      ✅
      - L2 U-Plane (PDCP-U, RLC, MAC, scheduler) → U-Plane / DU team
      - L1 / PHY → L1/PHY team
      - GTP-U / F1-U / transport → Transport / U-Plane team
      - OAM / config management database → OAM team
      - Core network (AMF, SMF, UPF) → Core team
      - TTCN3 framework engine → Test infra team
      - 3rd-party libs / OS → Platform team

2.3  Non-goals?
      ✅
      - No broad system redesign
      - No changes to components outside cplane
      - No guessing unknown APIs or inventing evidence
      - No continuing investigation with unanswered blocking questions

================================================================================
3. DOMAIN KNOWLEDGE — CAPABILITIES & PROTOCOLS
================================================================================

3.1  Core capabilities, protocols, interfaces?
      ✅
      - NR RRC (TS 38.331): radio resource control signalling
      - F1AP (TS 38.473): F1-C interface, UE context management with gNB-DU
      - E1AP (TS 38.463): E1 interface, bearer context management with gNB-CU-UP
      - XNAP (TS 38.423): Xn-C interface, handover with neighboring gNBs
      - NGAP (TS 38.413): NG-C interface, UE mobility and session management with AMF
      - E2AP (O-RAN.WG3): E2 interface, RIC control and indication
      - NSA / EN-DC (TS 37.340): dual connectivity with LTE

```
  ✅ Transport layers (from CplaneSwArch docs, verified against codebase):
  - **ZMQ (protobuf-over-ZMQ):** inter-component communication within CU-CP
  - **SCTP:** external 3GPP interfaces (F1AP, E1AP, NGAP, XNAP, X2AP, E2AP)
  - **SysCom (AaSysCom):** OAM communication + classical BTS optimized F1/E1 paths

  ✅ ZMQ port assignments (verified against proto files and AppAddressProvider tests):
    | Port  | Service      | Used By       |
    | ----- | ------------ | ------------- |
    | 30500 | CpUePort     | cp_ue request |
    | 30501 | CpSbPort     | cp_sb (SRB)   |
    | 30510 | CpNbPort     | cp_nb         |
    | 30520 | CpCellConfig | cp_cl config  |
    | 30521 | CpCellPort   | cp_cl request |
    | 30531 | E1Service    | E1AP request  |
    | 30532 | X2Service    | X2AP request  |
    | 30539 | F1Service    | F1AP request  |
    | 30541 | CpIfService  | cp_if request |
    | 30543 | AmfService   | NGAP manager  |
    | 30545 | XnService    | XNAP request  |
    NOTE: Port 30544 (CpCellReceiver) appears in legacy docs; current code uses cpCellControlPort=30666.
    NOTE: Port 30542 is an additional official CPIF internal port.

  ✅ SCTP port assignments (verified against ConfigurationLoader.cpp and SCT params):
    | Port  | Protocol | Interface |
    | ----- | -------- | --------- |
    | 38472 | F1AP     | F1-C      |
    | 38462 | E1AP     | E1        |
    | 36422 | X2AP     | X2-C      |
    | 38422 | XNAP     | Xn-C      |
    | 38412 | NGAP     | NG-C      |
    | 31422 | E2AP     | E2        |

  ✅ DU-side interface matrix (CP-RT ↔ L2/L1, from architecture doc):
    | Interface | CP-RT                                  | CP-NRT                       |
    | --------- | -------------------------------------- | ---------------------------- |
    | OAM (CM)  | CP-RT-CM                               | CP-NRT-CM                    |
    | L2-HI     | HiCnfgDu, HiUserDu, HiMeasDu, HiSgnlDu | HiCnfgCu, HiUserCu, HiMeasCu |
    | L2-PS     | PsCnfg, PsCell, PsUser, PsSgnl, PsTM   | —                            |
    | L2-LO     | LoCnfg, LoCell, LoUser                 | —                            |
    | L1        | DlCell, UlCell                         | —                            |
```

3.2  Triggers or entry points (tasks, indications, events) and file locations?
      ✅ (partial — updated with CP-NRT and CP-RT knowledge)

```
  CP-NRT (`ScenarioHandler.cpp`):
  - E1AP BearerContextSetupRequest → `BearerSetupReqScenario` in `CP-NRT/CP-NRT/src/scenario/bearer_setup/src/BearerSetupReqScenario.cpp`
  - E1AP BearerContextModifyRequest → `BearerModifyReqScenario` in `CP-NRT/CP-NRT/src/scenario/bearer_modify/src/BearerModifyReqScenario.cpp`
  - L2 HI error indication → `BearerErrorIndScenario` in `CP-NRT/CP-NRT/src/scenario/bearer_error_ind/src/BearerErrorIndScenario.cpp`
  - OAM DeltaPlan → `DeltaPlanScenario` / `ContinueDeltaPlanScenario` in `CP-NRT/CP-NRT/src/scenario/oam_plan/src/DeltaPlanScenario.cpp`
  - Pool config → `PoolConfigurationProcedure` / `PoolConfigurationUpdateProcedure` in `CP-NRT/CP-NRT/src/scenario/pool_config/src/PoolConfigurationProcedure.cpp`
  - IPsec/TRSW config → `TrswIpSecTunnelConfigProcedure` in `CP-NRT/CP-NRT/src/scenario/trsw_config/src/TrswIpSecTunnelConfigProcedure.cpp`

  CP-RT (thread apps receive events via SysCom / interface messages):
  - F1AP UEContextSetupRequest → `CpIfDuApp` → `UeContextSetupFsm` (NSA) or `SAUeContextSetupFsm` (SA) in `CprtUeApp`
  - F1AP UEContextModificationRequest → `UeContextModificationService` in `CP-RT/CP-RT/src/services/ue_mgmt/ue_procedures/ue_modify/src/modify/UeModifyService.cpp`
  - F1AP UEContextReleaseCommand → `UeContextReleaseFsm` in `CP-RT/CP-RT/src/services/ue_mgmt/ue_procedures/ue_release/src/UeContextReleaseFsm.hpp`
  - SCell addition trigger → `UeScellAdditionFsm` in `CP-RT/CP-RT/src/services/ue_mgmt/ue_procedures/scell_add/src/UeScellAdditionFsm.hpp`
  - cp_ue sends via `itf::cp::cpue_cprt::SCpUeCpRtSyscomCommunicationEnvelope` → `CprtUeApp`

  cu/:
  - F1AP Initial UL RRC Transfer → triggers UE context creation in cp_if/cp_ue
  - NGAP Initial Context Setup → security activation in cp_ue
  - XNAP Handover Request → HO preparation in cp_if → cp_ue
  - OAM cell config change → cell state change in cp_cl

  ✅ cp_ue trigger entry points (from codebase analysis):
  - F1AP Initial UL RRC Transfer → `UeInitialAccessServiceSaRrc::admitUe()` → `UeLauncher::addUeSa()` → `UeInfoSaFactory::createActiveUeInfo()`
    File: `cu/cp_ue/src/framework/launcher_framework/ue_launcher/ue_initial_access_sa/src/UeInitialAccessServiceSaRrc.cpp`
    After UE exists: `ConcreteUeSaActiveProcedureInitialUlRrcMessageTransfer::process()`
  - NGAP Initial Context Setup → `ConcreteUeSa::onMessage(InitialContextSetupReqWithAmfId)` → `InitialContextSetupProcedure`
    Security: `SecurityModeCommandVisitor` in `InitialContextSetupActions.cpp`
    File: `cu/cp_ue/src/procedures/initial_context_setup/src/`
  - XNAP Handover Request → `ConcreteUeSaXnHandoverRequest::onMessage()` → `UeInitialAccessServiceSaXn::admitUeForHandover()`
    → `InterGnbHandoverOnTargetGnbProcedure` with states: `XnHandoverValidator`, `CpClAdmissionControl`
    File: `cu/cp_ue/src/procedures/handover_sa/inter_gnb_handover_target/src/`
  - NGAP Handover Request → `ConcreteUeSaNgHandoverRequest::onMessage()` → `UeInitialAccessServiceSaNg::admitUeForHandover()`
    File: `cu/cp_ue/src/framework/launcher_framework/procedure_launcher/ue_sa/src/ConcreteUeSaNgHandoverRequest.cpp`
  - OAM cell config / NIDD → `CplaneUe::checkAndHandleCpUeNiddDeliveryRequest()`, `handleDeltaNetworkPLanCpUeNiddDeliveryRequest()`
    File: `cu/cp_ue/src/framework/launcher_framework/cplane_ue/src/CplaneUe_CommonConfiguration.cpp`
```

3.3  Naming conventions?
      ✅ (from codebase analysis)
      - **Handlers:** `*Handler` for protocol/link handlers; `Concrete`* prefix for implementations of interfaces
        Examples: `ConcreteXnLinkHandler`, `XnLinkSetupHandler`, `A2MeasHandlerSA`, `ConcreteMeasHandlerSaFactory`
      - **Services:** `*Service` (often with `I*Service` interface); `Concrete*Service` for implementations
        Examples: `DistributedUnitsService`, `UeContextModificationService`, `ThroughputBasedB1IRatHoService`
      - **Procedures:** `*Procedure` for schedulable/concurrency tasks
        Examples: `ConcreteDuConfigurationUpdateProcedure`, `InitialContextSetupProcedure`, `PduSessionResourceModifyProcedure`
      - **State machines (cp_ue):** `*StateMachine` or `*Machine` (Boost.MSM)
        Examples: `NgHandoverOnTargetStateMachine`, `NgHandoverOnSourceMachine`, `InterScellAdditionMachine`
      - **FSMs (CP-RT):** `*Fsm` or `*Task` suffix
        Examples: `UeContextSetupFsm` (NSA), `SAUeContextSetupFsm` (SA), `UeContextReleaseFsm`, `BeamConfigUpdateFsm`
      - **Factories:** `*Factory` suffix, `Concrete*Factory`, or `create`* functions
        Examples: `UeInfoSaFactory`, `ConcreteUeProcedureFactory`, `SAHandoverUeContextSetupFsmFactory`
      - **Message dispatch:** `onMessage(const messages::*&)` methods on `ConcreteUeSa` facade; typed lambdas via `registerHandler()`
      - **Directory patterns:** `procedures/`, `services/`, `*_sa/`/`*_nsa/` variant splits
      - **Data models:** suffix `Context` or `Data` (e.g. `UeContext`, `CellContext`, `DrbContext`)
      - **TTCN3 modules:** PascalCase with `_Module` suffix (e.g. `F1AP_UE_Module`)
      - **TTCN3 test cases:** camelCase with descriptive name (e.g. `f1HandoverSuccess`)
      - **TTCN3 procedures:** helpers prefixed `f`_*, `bearerSetupProcedureOk`
      - **SysCom messages:** `itf::[domain]::[subdomain]::[MessageName]` (e.g. `itf::cp::cpue_cprt::...Envelope`)
      - **ASN.1/Generated types:** follow 3GPP naming (e.g. `Ngap_PDUSessionResourceSetupRequest`)
      - **File names:** match primary class name in `PascalCase.cpp` / `PascalCase.hpp`

3.4  Message/API flow: what C-Plane sends vs receives?
      ✅ (at interface level)
      Receives:
      - From AMF via NGAP: InitialContextSetupRequest, UEContextReleaseCommand, PDUSessionResourceSetupRequest
      - From gNB-DU via F1AP: InitialULRRCMessage, ULRRCMessageTransfer, F1SetupRequest
      - From gNB-CU-UP via E1AP: BearerContextSetupResponse, BearerContextModifyResponse
      - From peer gNB via XNAP: HandoverRequest, HandoverRequestAcknowledge, HandoverSuccess
      - From UE via RRC (relayed through F1AP): RRCSetupRequest, RRCSetupComplete, MeasurementReport

```
  Sends:
  - To AMF via NGAP: InitialContextSetupResponse, UEContextReleaseComplete, PDUSessionResourceSetupResponse
  - To gNB-DU via F1AP: UEContextSetupRequest, UEContextModificationRequest, RRCDeliveryReport
  - To gNB-CU-UP via E1AP: BearerContextSetupRequest, BearerContextModifyRequest
  - To peer gNB via XNAP: HandoverRequest, SNAdditionRequest
  - To UE via RRC (relayed through F1AP): RRCSetup, RRCReconfiguration, RRCRelease, RRCHandoverCommand
```

3.5  Where are key definitions (parameters, message types)?
      ✅ (partial)
      - TTCN3 message templates: sct/protocols/F1AP/, sct/protocols/E1AP/, sct/protocols/XNAP/
      - TTCN3 library templates: sct/libraries/Lib3GPP/F1AP/, sct/libraries/Lib3GPP/E1AP/
      - Interface messages: sct/libraries/Messages/IfE1AP/
      ✅ C++message types (from codebase analysis):
      - F1AP/E1AP/XNAP/NGAP messages: `messages::f1ap::*`, `messages::ngap::*`, `messages::xnap::*` namespaces
        Used in: `ConcreteUeSa::onMessage(const messages::ngap::InitialContextSetupReqWithAmfId&)`
      - Inter-process messages: `itf::cp::cpue_cprt::SCpUeCpRtSyscomCommunicationEnvelope` (cp_ue ↔ CP-RT)
      - CP-RT interfaces: `.mt` files at `CP-RT/itf/cp/rt/` (cprtue, cprtbe, cprtrp) — MuLTI codegen
      - CP-IF dispatch: protobuf ZMQ in `CpIfServiceReceiver.cpp` (switch on `cpIfRequest.request_case()`)
      - TTCN3 templates: `sct/protocols/F1AP/`, `sct/protocols/E1AP/`, `sct/libraries/Lib3GPP/`
      - C++ generated from ASN.1 (by MuLTI/assassin tools): `cu/libs/generated/protocols/[protocol]/include/`
        [TEAM PROVIDED — path not verified in this checkout; may be generated at build time]
      - SysCom `.mt` interface definitions → C++codegen headers: `CP-RT/itf/cp/rt/`
      - Managed Object (MO) parameters from YANG models → C++ generated representations
        [TEAM PROVIDED — location `cu/cp_oam/generated/mo/` not found in checkout; may be build-generated]

3.6  Critical timeouts?
      ✅ (from codebase analysis + RAIN logs)

```
  **RRC protocol timers (UE-side, configured by C-Plane via RRCReconfiguration):**
  - T300: RRCSetupRequest retransmission
  - T301: RRCRe-establishmentRequest retransmission
  - T304: Handover timer; triggers re-establishment upon expiry after HO command
  - T310: RLF detection; starts on consecutive out-of-sync from L1; triggers re-establishment
  - T311: RRC re-establishment timer; duration UE waits for response after initiating re-establishment

  **RRC timers in CP-RT code (NIDD config API):**
  - `INiddConfig::getT310()`, `getT310(NrCellIdentity)` — RLF detection timer
  - `INiddConfig::getT304()` — handover execution timer
  - `INiddConfig::getT311()`, `getT311(NrCellIdentity)` — RLF recovery timer
  - Types: `types::nrrrc::Timer310ForRLFHandling`, `types::nrrrc::Timer304`, `types::nrrrc::Timer311ForRLFHandling`
  - File: `CP-RT/CP-RT/src/common/nidd_config/include/nidd_config/INiddConfig.hpp`
  - Variants: `getT310VoNROptional`, `getT310PubSafetyOptional` (voice/public safety specific)

  **cp_ue internal guard timers (`TimerIdentifier` enum):**
  - `radioLinkRecovery`, `ngSignalingConnGuard`, `srbInactivityTimerSA`, `ngRelocOverall`,
    `t380Guard`, `tStoreUeContext`, `ranPagingRepGuardTimer`, `fiveQI1RrcRelDelayTimerSA`,
    `x2ProcGuardTimerForInterSgnbPSCellChange`
  - File: `cu/cp_ue/src/framework/cpue_timer_manager/include/cpue_timer_manager/TimerIdentifier.hpp`

  **Timeouts observed in RAIN logs (CP-RT):**
  - "Timeout RLF Guard Timer" — `UeRadioLinkFailureService.cpp:141` (frequent in production)
  - "Timeout while waiting for HiSgnlDu_SrbSendResp" — `WaitHiSgnlDuSrbSendResp.hpp:80`
    (expected during UeContextRelease with cDRX; contact L2HI if unexpected)
  - "Timeout while waiting for F1AP::DlRrcMessageTransfer or F1AP::UEContextSetupRequest" — `CuResponse.cpp:356`
  - "RRCSetUpComplete not received" — observed in production logs

  **gNB internal timers [TEAM PROVIDED]:**
  - UE Inactivity Timer (`tUeInactivity`): triggers UE context release if no data for this duration
  - Handover Preparation Timer (XnAP/NGAP): time waiting for HO Request response; failure → cancel
  - Bearer Setup Timer (E1AP): time CU-CP waits for BearerContextSetupResponse from CU-UP

  **ES / test timing:**
  - ES cell switch-off counter: ~300–550s to reach threshold (30/30) at normal load
  - Deep sleep timer (REM): OAM-side timer controlling how long a cell stays in power-saving
  - `f_UT_delay` in TTCN3: test-specific; wrong values cause false failures
```

3.7  Key cross-component flows (step-by-step)?
      ✅ (major flows documented in CPLANE_Agent.md §2.5)
      - UE Connection Setup (SA): documented
      - Bearer Setup/Modification: documented  
      - Xn Handover: documented
      - Energy Saving Cell Switch-Off: documented (C-Plane side + OAM side from RAIN log analysis)
        * C-Plane: cp_cl MaxValueSOffStrategy, counter threshold, cell switch-off
        * OAM: NTS/NRTS CellEnergySavingHandler → REM ConfigureEnergySavingModeTrigger → CPCONFIG energySavingState
        * CP-RT: AntennaCarrierActivation for cell state changes
        * Critical: NTS restart can cause lost ES state
      ✅ NSA Addition call flow (from CplaneSwArch_CallFlows.adoc, verified):
            `1. MeNB → CP-IF: X2AP:SgNBAdditionReq       2. CP-IF → CP-UE: CpUe_RecvNSAInitialAccessMsg       3. CP-UE → CP-CL: CpCell_AdmissionReq/Rsp       4. CP-UE → CP-IF → CP-NRT: E1AP:BearerContextSetupReq          CP-NRT → L2-HI-CU: HiUserCu_BearerSetupReq/Resp          CP-NRT → CP-IF → CP-UE: E1AP:BearerContextSetupResponse       5. CP-UE → CP-IF → CP-RT: F1AP:UeContextSetupReq          CP-RT → L2-PS: PsUser_UserSetupReq/Resp          CP-RT → L2-LO: LoUser_UserSetupReq/Resp          CP-RT → L2-HI-DU: HiUserDu_BearerSetupReq/Resp          CP-RT → CP-IF → CP-UE: F1AP:UeContextSetupResp       6. CP-UE → CP-IF → MeNB: X2AP:SgNBAdditionRequestAcknowledge       7. CP-UE → CP-NRT: E1AP:BearerModificationRequest (transport update)       8. MeNB → UE: LTE RRC Connection Reconfiguration → Complete → RACH       9. MeNB → CP-IF: X2AP:SgNBReconfigurationComplete + SN Status Transfer       10. CP-UE → CP-NRT: E1AP:BearerModificationRequest (final)`      

```
  ✅ Step-by-step flows [TEAM PROVIDED]:
```

```
  **F1 Handover (Intra-gNB-CU):**
  1. Source DU → CU-CP: F1AP ULRRCMessageTransfer (MeasurementReport)
  2. CU-CP (cp_ue): evaluates report, decides handover to target cell within same CU
  3. CU-CP → Target DU: F1AP UEContextModificationRequest (UE capabilities, security)
  4. Target DU → CU-CP: F1AP UEContextModificationResponse (resources prepared)
  5. CU-CP → UE (via Source DU): RRCReconfiguration (handover command)
  6. UE synchronizes with Target DU
  7. Target DU → CU-CP: F1AP ULRRCMessageTransfer (RRCReconfigurationComplete)
  8. CU-CP → Source DU: F1AP UEContextReleaseCommand (release old resources)

  **NGAP PathSwitch (after Xn Handover):**
  1. Target gNB (CU-CP) → AMF: NGAP PathSwitchRequest (new serving cell, PDU sessions)
  2. AMF → SMF: forwards request; SMF updates UPF path
  3. AMF → Target gNB: NGAP PathSwitchRequestAcknowledge (PDUSessionResourceModifiedList)
  4. Target gNB → CU-UP: E1AP BearerContextModificationRequest (new GTP-U endpoints)
  5. CU-UP → Target gNB: E1AP BearerContextModificationResponse
  6. Target gNB → Source gNB: NGAP UEContextRelease

  ✅ Additional flows (from codebase analysis):
  - **F1 Handover (CP-RT):** No F1AP "HandoverRequest" symbol; inter-DU/gNB SA HO is driven by
    `UeContextSetupRequest` + `HandoverPreparationInformation`.
    Factory: `UeMgmtFactory::createUeContextSetupTask()` → `SAHandoverUeContextSetupTask`
    Files: `CP-RT/.../ue_setup/src/sa/handover/SaHOUeSetupInit.cpp`, `SAHandoverUeContextSetupFsm.hpp`
    Intra-DU: `intra_du_ho/src/bearer_handover/states/BearerHandoverInit.cpp`
  - **NGAP UE mobility (cp_ue):**
    PathSwitch: `NgPathSwitch.cpp`, `NgapPathSwitch.cpp`, `NgPathSwitchSecurityUpdater.cpp`
      in `procedures/handover_sa/inter_gnb_handover_target/src/states/`
    HandoverRequired (source, sending): `HoPreparation.cpp` → `HandoverRequiredBuilder`
      in `procedures/handover_sa/inter_rat_lte_handover_source/src/states/`
    HandoverNotify (target): `NgHandoverNotifyBuilder.cpp`
      in `procedures/handover_sa/ng_handover_target/ng_handover_target_procedure/`
  - **PDU session modification (cp_ue + CP-NRT):**
    cp_ue: `PduSessionResourceModifyProcedure.cpp`, `PduSessionResourceModifyRequestService.cpp`
      in `procedures/pdu_session_resource_modify/src/`
    CP-NRT: `ScenarioHandler::handle(BearerContextModificationRequest)`, `pduSessionResourceModifyExecutor`
      in `CP-NRT/CP-NRT/src/scenario/scenario/src/ScenarioHandler.cpp`
```

================================================================================
4. DOMAIN KNOWLEDGE — FAULTS & ALARMS
================================================================================

4.1  Fault/error IDs or alarm types?
      ✅ (from codebase analysis)

```
  **Two parallel ID systems exist:**

  A. **`fault_manager` (CU → LOM / syscom — compact path):**
     - `enum class PersistentFault`: `communicationFailureAl`, `f1CellActivationFailedAl`,
       `gnbCpCellUpdateFailedAl`, `xnSctpSetupAl`, `enbScaleInRequiredAl`, …
     - `enum class TransientFault`: `ngAmfInitFullResetAl`, `ngResetNoRespAl`, …
     - File: `cu/libs/fault_manager/include/fault_manager/Faults.hpp`

  B. **`fm_proxy` (CU → OAM — rich notification path):**
     - `enum class PersistentFault`: `gnbCpCellUpdateFailedAl`, `nrGtpuPathFailureAl`,
       `communicationFailureAl`, `e2SctpSetupFailAl`, `saServiceImpactedAl`, SCTP/IPsec IDs
     - `enum class TransientFault`: NG/X2/Xn parallel setup, reset
     - `enum class Originator`: `cpnb`, `cpue`, `cpcl`, `cpif`, `cpe2`, `cpnrt`
     - Files: `libs/fm_proxy/include/fm_proxy/FaultId.hpp`, `Originator.hpp`

  C. **CP-RT (separate fault_manager):**
     - `enum class FaultId`: `communicationFailureAl`, `f1SctpSetupAl`, `gnbCpRtCellUpdateFailedAl`,
       `gnbCpRtCellActTimeoutAl`, DSS-related IDs
     - `cprt::cell_config::FaultId`: `incompatibleBeamSetConfigAl`, `powerSavingBsrPackageIncompleteAl`
     - File: `CP-RT/CP-RT/src/common/fault_manager/include/fault_manager/IFaultManager.hpp`

  **Common Fault IDs [TEAM PROVIDED]:**
     - 7115: Baseband Module Hardware Failure
     - 4080: Link failure (F1, E1, Xn)
     - 6010: Configuration failure

  **Alarm type categories [TEAM PROVIDED]:**
     - Protocol Errors: malformed/unexpected PDU (e.g. F1AP_CauseProtocol_AbstractSyntaxError)
     - Resource Unavailability: request cannot be fulfilled (e.g. NGAP_CauseRadioNetwork_Unspecified)
     - Timer Expiry: procedure fails to complete in time

  **Fault IDs observed in RAIN logs:**
     - L1: faultId=4694 (`raisePaNonFatalFault`)
     - OAMFM: faultId=1868 (cell-level, `FilteringManager` cancel attempts on NRCELLs)
     - ASM: fault 4775 (`CldCnumLdapAlarmReporter`)
```

4.2  Interface with fault/alarm system?
      ✅ (from codebase analysis)

```
  **Path A — `fault_manager::OAMFaultManager` (LOM_FaultInd):**
```

  reportFault(PersistentFault, FaultSeverity, ObjectType, ObjectId, FaultExtraInfo)
  cancelFault(PersistentFault, FaultSeverity, ObjectType, ObjectId, FaultExtraInfo)

  reportFault(Originator, Fault, FaultSubCaseId, FaultObject, FaultSeverity, AdditionalText, FaultAttributes)
  reportPersistentFault(FaultNotif) / reportTransientFault(FaultNotif)
  cancelFault(...) / clearAllFaults(ImpactedMOs)

4.3  Fault signatures: fields, format, limitations?
      ✅ (from codebase analysis)

```
  **Primary fault notification struct — `fm_proxy::FaultNotif`:**
```

  struct FaultNotif {
      std::string transactionId;
      Originator originator;
      Fault faultId;                    // variant<PersistentFault, TransientFault>
      FaultSubCaseId faultSubCaseId;    // std::uint32_t
      FaultObject faultObject;          // std::string (MO DN)
      FaultState faultState;            // cancel, start, event
      FaultSeverity faultSeverity;
      ActivationFilteringTime activationFilteringTime;
      DeactivationFilteringTime deactivationFilteringTime;
      ImpactedMOs impactedMOs;          // vector
      AdditionalText additionalText;
      FaultAttributes faultAttributes;  // set<Attributes{name, value}>
      std::optional faultSignature;  // {date, category, scope, minor, info}
  };

4.4  Internal vs external fault origin?
      ✅ (from codebase analysis)

```
  **Distinguishing patterns:**
  - `fm_proxy::FaultRaiseOrigin` enum: `cuConfigurationUpdateProcedureFailure`,
    `backhaulConfigurationUpdateProcedureFailure`, `s1uGtpuPathsFailure`, `nguGtpuPathsFailure`
    Used by: `ConcreteCellUpdateFailures` (cp_cl) to track WHY `gnbCpCellUpdateFailedAl` raised
  - `CellFaultMode`: `sa`, `nsa`, `nrdc` — drives cancel/downgrade logic per variant
    File: `libs/fm_proxy/include/fm_proxy/CellFaultMode.hpp`
  - CP-RT internal: `cprt::cell_config::FaultId` tracks beam-set/BSR faults locally
    before reporting to OAM (e.g. `CellMappingStoreUtils.cpp`)
  - SCTP external gating: `ConcreteXnLinkHandler::needToReportFault` — checks before raising
  - Cloud-only: `CommunicationFailureAlFaultReporter::reportIfCloud()` — only raises on cloud BTS
    File: `cu/libs/fault_manager/.../CommunicationFailureAlFaultReporter.cpp`

  **Classification rule [TEAM PROVIDED]:**
  - **Internal:** stack trace within cp_*/Cprt, assertion failure, memory corruption, logic error
  - **External:** protocol error from peer (logged parse failure), procedure timeout waiting for peer,
    explicit rejection cause from peer (e.g. NGAP Cause: "RadioNetwork/...")
  - Rule: if C-Plane correctly implements 3GPP spec but interaction fails due to peer's
    non-conformance or lack of response → fault is external
```

================================================================================
5. DOMAIN KNOWLEDGE — ARCHITECTURE & LIFECYCLE
================================================================================

5.1  Main architectural unit? Who creates it?
      ✅ (partial)
      - cu/: One UE context per connected UE (managed by cp_ue); one cell context per cell (cp_cl)
      - CP-NRT: `cpnrt::UeContext` — one per UE, aggregates UP-facing state (DRBs, PDU sessions, NSA/SA type, E1 IDs)
      - CP-RT: UE FSM instance per UE in `CprtUeApp`; cell FSM in `BeamConfigUpdateFsm`
      ✅ Factory/creator functions (from codebase analysis):
      - cp_ue UE creation: `UeInfoSaFactory::createActiveUeInfo()` → `createActiveUeContext()` → `createStandaloneUe()`
        → `IUeSaFactory::createUeSa` → `ConcreteUeSa`
        File: `cu/cp_ue/src/framework/launcher_framework/ue_launcher/src/UeInfoSaFactory.cpp`
      - cp_ue procedure factory: `ConcreteUeProcedureFactory` (central; creates all procedure types)
        File: `cu/cp_ue/src/procedures/user_management/ue_procedure_factory_sa/src/ConcreteUeProcedureFactory.cpp`
      - CP-RT UE task creation: `UeMgmtFactory::createUeContextSetupTask()` dispatches to:
        `SAUeContextSetupTask`, `ue_context_setup::UeContextSetupTask` (NSA), `NrdcUeContextSetupTask`
        File: `CP-RT/CP-RT/src/services/ue_mgmt/ue_mgmt/src/UeMgmtFactoryTaskCreators.cpp`
      - CP-NRT UE context creation: `UeContextManager::createUeContext()` — called at start of UE-associated scenarios
        File: `CP-NRT/CP-NRT/src/ueContext/src/UeContextManager.cpp` [VERIFIED in codebase]
      - CP-RT SA HO factory: `cprt::sa_ho_ue_context_setup::createUeContextSetupSAHandoverFsm()`
        File: `CP-RT/.../ue_setup/src/sa/SAHandoverUeContextSetupFsmFactory.cpp`

5.2  Threading/concurrency model?
      ✅ (CP-RT threading model now known)

```
  CP-RT is MULTI-THREADED with dedicated thread applications:
  - `CprtApp`: Main coordinator
  - `CpIfDuApp`: DU F1AP interface I/O (receives from gNB-DU)
  - `CprtUeApp`: UE procedure FSMs (Boost.MSM — NSA and SA)
  - `CprtBeApp`: BE plane
  - `CprtRPApp`: RP plane (RAN parameters)

  Inter-thread messages use typed `.mt` interfaces from `CP-RT/itf/cp/rt/`.
  cp_ue → CP-RT messages use `itf::cp::cpue_cprt::SCpUeCpRtSyscomCommunicationEnvelope`.

  CP-NRT: Scenario-driven, lighter concurrency. `ScenarioHandler` dispatches events.

  Race condition detection:
  - GTest: `GTEST_SHUFFLE=1 GTEST_REPEAT=N`
  - SCT: `SCT_TTCN3_REPEAT_COUNT=N`

  ✅ Lock patterns and synchronization (from codebase analysis):

  **CP-RT uses BOTH message passing AND shared mutable state:**
  - `std::mutex` + `std::lock_guard`: `BeamConfig.cpp`, `SemiDynamicBwSwitchGuardService.cpp`,
    `PeriodicUeCountersUpdater.cpp`, `PmCounterUpdater.cpp`, `OverloadManager.cpp`
  - `std::shared_mutex` + `shared_lock`/`unique_lock`: `BeamWeightJsonFileRelationStorage.cpp`
  - **`ThreadGuard`** (central cross-thread config discipline):
    `niddConfigLock`, `cellConfigLock`, `traceSessionLock`, `l2NrtPoolConfigLock` — all `std::shared_mutex`
    `ConcreteThreadReadGuard` (shared_lock), `ConcreteThreadWriteGuard` (unique_lock + lockDepth tracking)
    Version atomics: `cellVersionInRtThread`, `niddVersionInRtThread`
    File: `CP-RT/CP-RT/src/common/threads/src/ThreadGuard.cpp`
    ⚠️ Changes to ThreadGuard require guild permission: "Ask I_ECE_CP_GUILD_CPRT_COMM"
  - `std::atomic` / `std::atomic_bool`: Thread lifecycle in `CprtThread.cpp`, `CprtUeThread.cpp`, etc.
  - Cell/NR APIs distinguish "with lock" vs "without lock" sections (see `Cell.hpp`, `ICell.hpp`)

  **Concurrency rules [TEAM PROVIDED]:**
  - **Message Passing:** Inter-thread communication is strictly via message passing using SysCom
    interfaces (.mt files). Avoids direct data sharing and minimizes lock needs.
  - **Callback Re-dispatch:** Callbacks from async operations must NOT do heavy processing in the
    callback thread. Post a new event/message to the appropriate worker thread to continue.
    Violating this blocks I/O or timer threads.
  - Overly coarse locking is a common source of performance bottlenecks in CP-RT.

  **cp_ue: NO std::mutex in production code** — uses:
  - Logical `Token::lock()`/`unlock()` (delete gate, not a mutex) in `MessageToken.cpp`
  - `std::weak_ptr::lock()` for shared ownership
  - Message-based dispatch through `ConcreteUeSa` facades and typed handlers
```

5.2b Default error handling rules (from CplaneSwArch_Doc.adoc, verified as pattern in code):
      ✅
      **Critical error** (procedure cannot continue):
        1. Report unsuccessful outcome to sender (response/confirm with NOK, or failure/reject message)
        2. Clear/release locally allocated resources (timers, state, bearers)
        3. Release external resources if already configured (other CP components, U-Plane, DU, core, UE)
        4. Print error log with failure cause, procedure name, and IDs (UEID, bearer ID)
           (templated error log recommended for consistency across CP-CU)
      **Non-critical error** (procedure can continue):
        1. Print warning/error log indicating failure was ignored
        2. Continue processing with valid default values
      **UE context release trigger:** if keeping the connection makes no sense after the error
      **C++ exceptions:** caught close to throwing place; NOT used for control flow;
        special cases may trigger application restart if service cannot continue

5.3  Teardown sequence?
      ✅ (from codebase analysis)

```
  **cp_ue UE context release:**
  - Entry: `ConcreteUeProcedureFactory` creates `NgUeContextRelease` or `SAUeContextReleaseProcedure`
  - Action: `StartF1UeContextRelease::execute()` — sends RRC release via SRB if available, then triggers F1 release
  - **Guard:** if `ueIdDu` is missing → F1 release NOT performed (logs "Missing DuUeId")
  - Files: `cu/cp_ue/src/procedures/ue_context_release/src/UeContextReleaseActions.cpp`,
    `SAUeContextReleaseProcedure.cpp`, `UeContextReleaseGuards.hpp`

  **CP-RT `UeContextReleaseFsm` state sequence:**
  - `Init` → `ChooseLevelOfRelease` → branches to:
    `WaitL2PsUserStopResp`, `WaitResourceReleaseResp`, `WaitHiSgnlDuSrbSendResp`,
    `WaitLoUserCcchDataSendReq` (or IgNBCA variant)
  - Then: `WaitL2HiDuDrbDeleteResp` → `WaitL2HiDuSrbDeleteResp` → `FinalizeL2HiDuSrbDelete`
    → `WaitUserDeleteResp` → `Done`
  - Destructor: clears `responseMsgHandlers`
  - File: `CP-RT/.../ue_release/include/ue_release/fsm/UeContextReleaseFsm.hpp`

  **Protocol-level teardown sequence [TEAM PROVIDED]:**
  1. cp_if receives NGAP UEContextReleaseCommand
  2. cp_ue sends E1AP BearerContextReleaseCommand to CU-UP (for each PDU session)
  3. CU-UP releases GTP-U → E1AP BearerContextReleaseComplete
  4. Simultaneously, cp_ue sends F1AP UEContextReleaseCommand to DU
  5. DU releases context → F1AP UEContextReleaseComplete
  6. After confirmations from both CU-UP and DU: NGAP UEContextReleaseComplete to AMF
  7. cp_ue destroys internal UeContext and frees all associated memory

  **Cell deactivation (cp_cl):**
  - `DistributedUnitsService::performCellDeactivation()` → `ConcreteCellDeactivationProcedureFactory`
  - DU config update: `ConcreteDuConfigurationUpdateProcedure` handles `cellContextContainer.getDeactived()`
  - NRDC cells: `deactivateNrdcCells()`
```

5.4  What must NOT happen during teardown?
      ✅ (from codebase GSL assertions analysis)

```
  **cp_ue release guards (GSL `Expects()`):**
  - `Expects(context.xnIgNBCARelease != nullptr)` — IgNBCA sub-procedure must exist if branch taken
  - `Expects(saIdentifiers->ueIds.amfUeNgapId())` — AMF UE NGAP ID must be present
  - `Expects(saIdentifiers->ueIds.servedAmfId())` — served AMF ID must be present
  - Missing DuUeId → F1 release NOT sent (guarded, not asserted)

  **CP-RT release FSM guards (GSL `Expects()`/`Ensures()`):**
  - `Expects(sCellGroup)`, `Expects(primeGnbCellGroup)`, `Expects(pCellGroup)` — valid cell groups required
  - `Expects(l2NrtPool and not l2NrtPool->isPoolRemoved())` — L2 NRT pool must still exist when sending delete
    (pool must NOT be removed before DRB/SRB delete messages are sent)
  - `Ensures(nrCellGroup)` — postcondition after context data operations

  **High-level teardown rules [TEAM PROVIDED]:**
  - **No New Procedures:** once teardown begins for a UE, no new procedures must be initiated;
    incoming messages except release confirmations should be ignored or rejected
  - **No Resource Leaks:** all dynamic memory, FSMs, timers, context objects must be fully released
  - **No Deadlocks:** release sequence must not depend on resources locked by another procedure
  - **No In-Flight Message Processing:** messages in-flight before release was triggered must be
    gracefully discarded to avoid accessing already-freed memory

  **Code-level guards (from codebase GSL assertions):**
  - Must NOT send F1 release without a valid DuUeId
  - Must NOT send L2HI DRB/SRB delete if the L2 NRT pool is already removed
  - Must NOT proceed with IgNBCA release sub-procedure if it was not created
  - Must NOT release without valid AMF identifiers (AMF UE NGAP ID, served AMF ID)
```

5.5  Configuration/deployment variants?
      ✅ (partial)
      - NSA (Non-Standalone / EN-DC) vs SA (Standalone)
      - Detected at runtime via configuration attributes
      ✅ NSA/SA runtime detection (from codebase analysis):
      - **Cell deployment type:** `types::CellDepType` enum — `standalone`, `nonStandalone`, `nonStandaloneAndStandalone`
      - **Helper:** `isSaCellDepType(cellDepType)` → true for `standalone` or `nonStandaloneAndStandalone`
        File: `cu/cp_ue/src/cpue_utils/cell_params/include/cpue_utils/cell_params/CellParamsUtils.hpp`
      - **Filter:** `isSaOrNsaOrBoth` in `CplaneUe_CommonConfiguration.cpp` filters cell params
      - **UE-level NSA checks:** `NsaUEInformation::isNsaFullRrcConfigTriggered()` (cp_ue)
      - **Bearer-level:** `isNsa3xBearerAllowed` policy in `INrDrbContainer.hpp`
      - **No single `isNsa()` flag** — runtime mode inferred from cell deployment type, UE information structs,
        and NSA-specific services/procedures (separate `ue_services_nsa/` vs `ue_services_sa/` trees)

```
  **Variant determination at UE attach time [TEAM PROVIDED]:**
  - SA: RRCSetupRequest via F1AP InitialULRRCMessage → set SA mode at context creation
  - NSA: SgNBAdditionRequest via existing LTE connection → set NSA mode at context creation
  - Compile-time flags may exist for major features (e.g. `ENABLE_ORAN_E2_INTERFACE`) in CMakeLists.txt
```

5.6  Key code locations map?
      ✅ (substantially filled — see CPLANE_RULES.md §13 CP-NRT, §14 CP-RT, §2.9 in CPLANE_Agent.md)

```
  Key additions from CP-NRT/CP-RT analysis:
  - CP-NRT central dispatcher: `CP-NRT/CP-NRT/src/scenario/scenario/src/ScenarioHandler.cpp`
  - CP-NRT UE state: `CP-NRT/CP-NRT/src/ueContext/UeContext.hpp`
  - CP-NRT bearer builder: `CP-NRT/CP-NRT/src/scenario/scenario_common/src/msg_builder/BearerSetupReqBuilder.cpp`
  - CP-RT process entry: `CP-RT/CP-RT/src/main/src/Main.cpp`
  - CP-RT NSA FSM: `ue_setup/src/nsa/NsaUeSetupAdmissionControl.cpp`
  - CP-RT SA FSM: `ue_setup/src/sa/SaUeSetupAdmissionControl.cpp`
  - CP-RT UE modify: `src/services/ue_mgmt/ue_procedures/ue_modify/src/modify/UeModifyDone.cpp`
  - CP-RT interfaces: `CP-RT/itf/cp/rt/cprtue/`, `cprtbe/`, `cprtrp/` (.mt files)

  ✅ Key class → file mappings (from codebase analysis):

  **cp_ue:**
  - `ConcreteUeSa` (UE facade): `cu/cp_ue/src/framework/launcher_framework/procedure_launcher/ue_sa/src/ConcreteUeSa.hpp`
  - `UeLauncher`: `cu/cp_ue/src/framework/launcher_framework/ue_launcher/src/UeLauncher.cpp`
  - `ConcreteUeProcedureFactory`: `cu/cp_ue/src/procedures/user_management/ue_procedure_factory_sa/src/`
  - `InitialContextSetupProcedure`: `cu/cp_ue/src/procedures/initial_context_setup/src/`
  - `InterGnbHandoverOnTargetGnbProcedure`: `cu/cp_ue/src/procedures/handover_sa/inter_gnb_handover_target/src/`
  - `PduSessionResourceModifyProcedure`: `cu/cp_ue/src/procedures/pdu_session_resource_modify/src/`
  - `UeContextReleaseActions`: `cu/cp_ue/src/procedures/ue_context_release/src/`

  **cp_if:**
  - `CpIfServiceReceiver` (main dispatch): `cu/cp_if/src/cp_if_service/src/CpIfServiceReceiver.cpp`
  - `ConcreteXnLinkHandler`: `cu/cp_if/src/xn_service/src/ConcreteXnLinkHandler.hpp`
  - `X2APHandler`: `cu/cp_if/src/x2_service/src/X2APHandler.cpp`
  - `ICpIfFaultReporter`: `cu/cp_if/src/libs/cp_if_fault_reporter/include/`

  **cp_cl:**
  - `ConcreteDuConfigurationUpdateProcedure`: `cu/cp_cl/src/procedures/procedures/src/`
  - `DistributedUnitsService`: `cu/cp_cl/src/distributed_units_service/.../src/`
  - `ConcreteCellUpdateFailures`: `cu/cp_cl/src/` (fault reporting)
  - `CellContext` / `CellContexts`: `cu/cp_cl/src/types/include/cpcl_types/`

  **cp_nb:**
  - `ScaleFaultReporter`: `cu/cp_nb/src/scale_adm/src/ScaleFaultReporter.cpp`
  - `SaServiceImpactedAlFaultReporter`, `AnrService`, `CpE2DownHandler`, `NetworkPlan.cpp`: `cu/cp_nb/src/`

  **cp_e2:**
  - `CpE2LinkHandler`: handles E2 setup faults (`sendE2SetupResponseTimeOutFaultAlarmReport`)

  **cp_sb:** (no fault manager — SRB/bearer mgmt, security, PDCP focused)
  - Located under `cu/cp_sb/src/bearer_management/`, `security/`, `pdcp/`
```

5.7  Important rules or gotchas?
      ✅ (known)
      - NSA bearer setup: PMQAP expected template built inside L2 procedure — cannot inject externally without interface change
      - Energy saving: configuration change resets counter — test timing must account for this
      - `f_UT_delay` values in TTCN3 must exceed actual operation duration
      ✅ Additional gotchas (from codebase and RAIN log analysis):
      - **CP-RT ThreadGuard changes require guild permission** — `I_ECE_CP_GUILD_CPRT_COMM`
      - **Missing DuUeId silently skips F1 release** — does NOT assert, just logs and completes
      - **L2 NRT pool removal before DRB/SRB delete → GSL assertion failure** in release FSM
      - **CP-IF unknown message → LOG_ERROR only** — no crash, but message is silently dropped
      - **Missing handler in dispatcher → LOG_WARNING** — not an assertion, message lost silently
      - **NTS restart causes lost Energy Saving state** — observed in RAIN logs
      - **OAMFM faultId=1868 cancel on non-existent fault** — benign warning in RAIN logs
      - **HiSgnlDu_SrbSendResp timeout during UeContextRelease with cDRX** — expected behavior,
        not a bug (ACK from UE may not be received)
      - **UE ID mapping errors [TEAM PROVIDED]:** same UE has different IDs on different interfaces  
        (C-RNTI on Uu, gNB-CU-UE-F1AP-ID on F1, AMF-UE-NGAP-ID on NG). Using wrong ID on wrong  
        interface is a common bug. Always check UeContext ID mapping.
      - **Boost.MSM stuck FSM [TEAM PROVIDED]:** FSM can get "stuck" in a state when it receives an
        unexpected event with no defined transition. Debugging requires tracing the FSM event queue.

5.7b COMMON INVESTIGATION PITFALLS & ANTI-PATTERNS (consolidated quick reference)
      ✅

      **Silent Failures (no crash, no assertion — just wrong behavior):**
      - Missing `DuUeId` silently skips F1 release procedure → hung UE context on DU side (§5.7)
      - Missing message handler in dispatcher → `LOG_WARNING` + message dropped → upstream timeout (§5.7)
      - CP-IF unknown message → `LOG_ERROR` only, no crash → message silently lost (§5.7)
      - OAMFM `faultId=1868` cancel on non-existent fault → benign warning, not a real issue (§5.7)

      **State Loss on Restart:**
      - NTS process restart loses Energy Saving cell state → cells stuck in/out of ES (§5.7, §16.6)
        Always check OAM logs for NTS restart events when debugging ES issues
      - C-Plane is stateless for UE contexts — all active UE contexts lost on process restart (§5.8)
      - CP-RT HA data survives restart only if `rdHighAvailabilityEnabled` is on and `HaRecoverableStruct` is used (§16.2)

      **Test-Induced Failures (false positives from test setup, not product bugs):**
      - `f_UT_delay` values too short → race condition with SUT → intermittent test failure (§3.6, §5.7)
      - Configuration change mid-test resets ES counter to 1/30 → false "not ready to switch off" (§5.7)
      - `GTEST_SHUFFLE=1` exposes test-ordering dependencies, not always product races

      **Concurrency Traps (CP-RT specific):**
      - ThreadGuard changes require guild team approval — unauthorized changes will be rejected (§5.7)
      - L2 NRT pool removal before DRB/SRB delete → `gsl::Expects()` assertion failure in release FSM (§5.7)
      - `HiSgnlDu_SrbSendResp` timeout during `UeContextRelease` with cDRX → expected behavior, not a bug (§5.7)
      - Version atomic mismatch between threads → stale cell/NIDD config → wrong decisions (§16.2)

      **UE ID Confusion:**
      - Same UE has different IDs on different interfaces: C-RNTI (Uu), gNB-CU-UE-F1AP-ID (F1),
        AMF-UE-NGAP-ID (NG), gNB-DU-UE-F1AP-ID (F1 DU-side). Using wrong ID on wrong interface is
        a common bug. Always verify UeContext ID mapping (§5.7)

      **Boost.MSM Traps:**
      - FSM receives unexpected event with no defined transition → FSM stuck in current state,
        no error, no crash. Debugging requires tracing the FSM event queue and comparing against
        the transition table (§5.7)

      **Log Analysis Traps:**
      - Large RAIN logs contain multiple scenario instances (some OK, some NotOK) — always use
        temporal anchoring (CPLANE_Agent.md Phase 4) to identify the correct scenario instance
      - OAM processes (NTS, REM, CPCONFIG) log in the same file as C-Plane — filter by pod prefix
      - Log format differs between lab (Format A) and production (Format B) — always detect first (§10.6)

5.8  Context preserved across restarts?
      ✅ (partial — from codebase analysis)

```
  **cp_ue — UE ID persistence via SDL:**
  - `CplaneUe::createUeIdsSdlSaver()` → `cpue_recovery::IUeIdsSdlSaver`
  - `cpue_recovery_storage::IUeIdsItemStorage` / `createUeIdsItemStorage` in `CpUeWithDependencies.cpp`
  - Implementation: `ConcreteUeIdsSdlSaver.cpp`
  - SDL notification: `ConcreteSdlNotificationService_SdlAccess.cpp`
  - Per-UE `restoreSnssaiIdPlmnMaps`, `restoreOldDuIds`, `restoreNSAUeInformationDuringFailure`
    (procedural rollback, not full checkpoint)

  **CP-RT — HA/recovery mode:**
  - `CprtApp.cpp` and `F1MgmtService.cpp` contain recovery logic
  - `CellCalculatorMode::recovery` in `Cell.hpp`
  - `InternalEventMsgIds.hpp`: `recoveryTriggerIndMsgId`

  **CP-NRT — HA/recovery scenarios:**
  - `ScenarioHandler.cpp`: `UpUeInstanceRecovery`
  - `DeltaNetworkPlanRecoveryAction.cpp`
  - Persistence flag on CM messages: `PERSISTENT` in `NetworkPlanUpdateProcedure.cpp`

  **General restart behavior [TEAM PROVIDED]:**
  - C-Plane is designed to be **stateless regarding UE contexts** — all UE state is held in memory
  - Upon process restart (crash or planned), all active UE contexts are lost
  - Recovery: re-establish NG/F1/E1 Setup; UEs experience RLF and initiate RRCReestablishment;
    CU-CP has no prior context → rejects → UE goes to RRC_IDLE → fresh connection
  - Exception: config data (cell config, IPsec keys) is persistent and re-read from OAM at startup
```

5.9  Key object/data mappings?
      ✅ (from codebase analysis)

```
  **UE ↔ DRBs / PDU sessions (cp_ue):**
  - `PduSession` struct contains `std::vector<Drb> drbs` + `findDrbIdByQosFlowId()`
    File: `cu/cp_ue/src/types/cpue_types/include/cpue_types/PduSession.hpp`
  - `UePduSessionView` aggregates `std::vector<types::cp_ue::PduSession> pduSessions`
    File: `cu/cp_ue/src/procedures/user_management/user_context_data/include/user_context_data/UePduSessionView.hpp`
  - NIDD config DRB table: `NrDrbContainer` maps `NrDrbId` → `NrDrb` parameters

  **UE ↔ identifiers (cp_ue):**
  - `UeDispatcherProviderProxy`: `std::unordered_map<types::UeIdCu, MessageDispatcherProxiesPtr>`
  - PCMD: `ConcreteSessionContainerProvider`: `unordered_map<UeIdCu, ...>`
  - Power mode: `UlFullPowerModeCounterUpdater`: `unordered_map<UeIdCu, UePowerModeInNrCell>`

  **Cell ↔ state (cp_cl):**
  - `CellContexts`: maps `NRCellIdentity` → `CellContext` (operational state, activation flags, ES fields)
    File: `cu/cp_cl/src/types/include/cpcl_types/CellContexts.hpp`
  - No UE list in `CellContext` — cell context is operational data only

  **Cell ↔ S-NSSAI [TEAM PROVIDED]:**
  - `CellContext` in cp_cl contains list of supported S-NSSAIs (Network Slice Selection Assistance Info)
  - Used during UE admission control to ensure UE's requested slice is supported by the cell

  **Internal UE ID ↔ Interface UE IDs [TEAM PROVIDED]:**
  - Central map (UeIdRepository) maps globally unique internal UE ID to interface-specific IDs:
    internal_ue_id ↔ amf_ue_ngap_id, gnb_cu_ue_f1ap_id, gnb_du_ue_f1ap_id
  - Essential for correlating messages for same UE across different protocol stacks

  **CP-NRT UE context:**
  - `cpnrt::UeContext`: DRBs, PDU sessions, NSA/SA type, E1 IDs, HO state, security, NIDD
```

================================================================================
6. DOMAIN KNOWLEDGE — DEPENDENCIES & SUBSCRIPTIONS
================================================================================

6.1  Subscriptions or registrations required?
      ✅ (from codebase analysis)

```
  **cp_if message handler registration:**
  - `CpIfServiceReceiver.cpp`: large `switch (cpIfRequest.request_case())` dispatches protobuf ZMQ messages
    to `mainIfServiceDispatcher`, `cpCellHandler`, `cpIfServiceDispatcher` — NOT a plugin table
  - Xn service: `xnServiceDispatcher.registerHandler([this](const messages::...) { handle(msg); })`
    — typed lambda per message in `ConcreteXnServiceConfigHandler.cpp`
  - X2 service: `registerHandler` + `dispatch(LteEnb&, const Msg&)` in `X2APHandler.cpp`
  - Generic dispatcher: `DispatcherImpl.hpp` — `Persistent<Msg>`, invokes handler if set

  **CP-RT response handler registration:**
  - FSM states register/deregister for async responses via `ResponseMsgHandler`
  - UT patterns: `expectDeregister`* — pairing register/deregister is mandatory

  **OAM configuration subscriptions [TEAM PROVIDED]:**
  - cp_cl and other components subscribe to MO update notifications from OAM agent
  - Pattern: `moManager.subscribe("NRCell", &handler::onCellConfigUpdate)`
  - This is how configuration changes are received at runtime

  **Internal timer registration [TEAM PROVIDED]:**
  - Procedures requiring timeouts register a timer with central TimerManager service
  - Provide callback function or event to post upon expiry
```

6.2  What happens if a subscription is missing?
      ✅ (from codebase analysis)

```
  - **cp_if unknown request:** `LOG_ERROR_MSG("Unknown message received in CP-IF service")` → message dropped
    File: `CpIfServiceReceiver.cpp` (default case in switch)
  - **Xn unknown message:** `LOG_ERROR_MSG("XnService received unknown message!")` in `XnServiceReceiver.cpp`
  - **Generic dispatcher (DispatcherImpl.hpp):** missing handler → `LOG_WARNING_MSG("cannot find handler for {}")` → message lost
  - **No crash/assert** for missing handlers — but the message is silently dropped, leading to timeouts upstream
  - This matches the pattern: missing handler → message not processed → silence → eventual timeout

  **Additional missing-subscription symptoms [TEAM PROVIDED]:**
  - **Missing OAM subscription:** component won't receive config updates; continues with stale config;
    symptom: feature enabled via OAM doesn't work, parameter change has no effect
  - **Missing timer registration:** procedure never times out on failure;
    symptom: UE context or resource "stuck"/"hung" indefinitely if peer never responds → resource leak
```

================================================================================
7. BOUNDARIES & ESCALATION
================================================================================

7.1  Adjacent components out of scope and when to escalate?
      ✅ (see CPLANE_RULES.md §6 — Scope Boundary)

7.2  Evidence types for ownership?
      ✅
      - Log prefix / process name
      - TTCN3 failing assertion (which component's receive failed)
      - Protocol interface spec (which side violated the contract)
      - Stack trace (which library is the crash site)
      - 3GPP spec (which entity performs the failing operation)

7.3  When root cause is external: what must the agent provide?
      ✅
      1. Component name
      2. Evidence (cited from logs/code/spec)
      3. Reassignment recommendation with justification

7.4  When root cause spans multiple components?
      ✅
      - Identify all involved components
      - Use ICFS / 3GPP spec to determine which side violated the contract
      - State which side is more likely at fault

================================================================================
8. INVESTIGATION METHODOLOGY
================================================================================

8.1  Problem classification?
      ✅ (documented in CPLANE_Agent.md §3, Phase 1)
      Categories: Fault/Alarm, Crash, Hang/Timeout, Unexpected Behavior, Performance/KPI,
      Configuration Issue, Regression, Intermittent/Flaky, Memory/Resource, Other

8.2  Search targets per classification?
      ✅ (documented in CPLANE_RULES.md §16.1 and CPLANE_Agent.md Phase 4)

8.3  Search keys always extracted?
      ✅ (documented in CPLANE_Agent.md Phase 2, CPLANE_Agent.md §3 Phase 2)

8.4  Evidence workspace and HALT condition?
      ✅
      HALT: no logs AND no stack trace AND no clear actual result → Missing Context Report

8.5  Candidate shortlist format?
      ✅ Max 10, columns: File | Symbol/Function | Why Relevant | Evidence Tag

8.6  Hypotheses: min/max, required content?
      ✅ Min 2, max 5. Each: Causal Chain (A→B→symptom), supporting/contradicting, confidence %

8.7  Component-specific evaluation questions?
      ✅ (CPLANE_Agent.md Phase 7):
      - Alignment with 3GPP protocol flow?
      - NSA vs SA variant accounted for?
      - Threading/concurrency model safe?
      - Component boundary correct?
      - TTCN3 → C++ code path traceable?

8.8  Primary solution proposal: required content?
      ✅ Diff-style change, exact paths, causal chain, risk (NSA/SA compat, affected components)

8.9  Validation plan elements?
      ✅ Existing UTs, existing SCTs, new tests, repro checklist, post-fix monitoring, rollback risk

8.10 Spec alignment: how to verify?
      ✅ Identify relevant 3GPP TS; compare code vs spec sequence diagrams; flag deviations

8.11 Max iterations and confidence threshold?
      ✅ Max 3 search-refine iterations; < 60% confidence after 3 → Missing Context Report

8.12 Implicit permissions?
      ✅ When log analysis is needed, assume implicit permission to access and process log files

================================================================================
9. CONFIDENCE & EVIDENCE TAGGING
================================================================================

9.1  Evidence tags?
      ✅
      - [OBSERVED]: directly seen in logs/code/PR
      - [INFERRED]: logically derived
      - [ASSUMED]: no direct evidence — flag clearly

9.2  Positive factors?
      ✅ (CPLANE_Agent.md §4):
      Stack trace matches cp_* file (+25), TTCN3 maps to C++ path (+15),
      Regression commit correlates (+15), Historical PR (+10),
      Logger output matches (+10), 3GPP spec confirms (+10), Variant accounted (+5)

9.3  Negative factors?
      ✅ (CPLANE_Agent.md §4):
      Missing logs (-15), Cannot reproduce (-15), Multiple competing hypotheses (-10),
      Interface boundary ambiguity (-10), Missing version/config (-5), No test history (-5)

9.4  Score computation?
      ✅ Σ(positive) − Σ(negative), clamped [0, 100]. Show calculation explicitly.

9.5  Engineering guardrails?
      ✅ (CPLANE_Agent.md §5, CPLANE_RULES.md §21 — 12 rules documented)

================================================================================
10. FIX PLACEMENT & CONVENTIONS
================================================================================

10.1 Fix placement principle?
      ✅
      - Fix at the layer that owns responsibility (cp_* component that owns the failing logic, not the caller)
      - Fault reporting goes through component-specific facades: cp_if uses `ICpIfFaultReporter`,
        cp_cl uses `ConcreteCellUpdateFailures`, CP-RT uses `IFaultManager`, CP-NRT uses `fmProxy`
      - Handler registration is per-component — fix missing handler in the component that should handle the message
      - ThreadGuard changes in CP-RT require guild permission (`I_ECE_CP_GUILD_CPRT_COMM`)

```
  **Additional fix placement rules [TEAM PROVIDED]:**
  - **Respect Abstraction Layers:** do not bypass established interfaces. If CP-NRT needs info from
    CP-RT, a proper SysCom message interface (.mt file) must be defined. No backdoors or shared memory.
  - **Follow the Protocol:** protocol-related issues → fix in the handler for that protocol
    (e.g. NGAP issue → fix in NgapHandler, not in a caller)
  - **Fix at Source of Truth:** if cp_ue provides incorrect data to cp_sb, fix in cp_ue, not cp_sb
```

10.2 Methods/flows that must be reused?
      ✅ (partial — from codebase patterns)
      - NSA bearer setup must use `performL2HiCuBearerSetupProcedure` — do not bypass
      - Builder patterns enforce reuse: `NrdcRestrictionBuilder`, `FeatureFlagsBuilder` (cp_cl),
        `HandoverRequiredBuilder` (cp_ue), `BearerSetupReqBuilder` (CP-NRT)
      - CP-RT port handlers "Must be persistent" (`IDispatcher.hpp`, `ISyscomPortMsgHandler.hpp`)
      - CP-RT ThreadGuard read/write guards must be used for cross-thread config access
      - No documented `do not bypass` comments found as a systematic pattern; reuse is enforced
        by API design (interfaces, factories, builders) rather than prose comments

```
  **Additional must-reuse patterns [TEAM PROVIDED]:**
  - UE Context creation/deletion: always use UeContextFactory / UeContextManager to ensure
    all related resources are correctly handled
  - Fault reporting: always use centralized FaultManager client — never just log to stdout
  - Message builders: for complex outgoing protocol messages, always use designated builder classes
    (e.g. `BearerSetupReqBuilder`) to ensure all mandatory fields are populated
```

10.3 Sub-components rule?
      ✅ Fix must apply to all relevant variants (NSA + SA) unless proven variant-specific

10.4 Coding conventions?
      ✅
      - C++(modern style), compiled with CMake + Ninja
      - Clang-format: `ninja format` or `scripts/format_code.sh --cp-cu`
      - TTCN3 for SCT tests (.ttcn3 files)
      ✅ Additional conventions (from codebase analysis):
      - **Includes:** `#include "module/Header.hpp"` (double quotes) for project headers;
        `#include <cstdint>` (angle brackets) for STL/external
      - **Error handling:** widespread `std::optional`, `CompletionStatus` callbacks, logging;
        `gsl_assert` (`Expects()`/`Ensures()`) for preconditions/postconditions in critical paths;
        NO `std::expected`; dispatcher missing handler → warning log, not exception
      - **PascalCase** for classes, **camelCase** for methods/variables
      - **Interface prefix:** `I`* (e.g. `IFaultManager`, `INiddConfig`, `IUeSaFactory`)
      - **C++ style [TEAM PROVIDED]:** follows Google C++Style Guide with Nokia-specific adaptations
      - `**nullptr`** instead of `NULL` or `0`; use `override` and `final` for virtual functions
      - **Include ordering:** corresponding header, C system headers, C++ system headers,
        other library headers, project headers
      - **Error handling principle:** exceptions for fatal unrecoverable errors (e.g. config file missing);
        error codes / `std::optional` / `CompletionStatus` for recoverable procedural errors;
        do NOT use exceptions for control flow

10.5 Directory and file layout?
      ✅
      - Component impl: cu/cp_*/src/
      - Component headers: cu/cp_*/include/ (likely — confirm with team)
      - SCT tests: sct/
      - Shared libs: cu/libs/
      ✅ Directory layout confirmed (from codebase analysis):
      - **No repo-wide top-level `include/` per component** — headers live alongside code under `src/` subtrees
        (e.g. `src/procedures/initial_context_setup/include/initial_context_setup/`)
      - **No single root `tests/` directory** — tests under `src/**/tests/` per sub-module
      - Layout per component: `cu/<comp>/src/` + `cu/<comp>/sct/` (TTCN3); CMake manages subdirectories
      - cp_ue: `src/` (boundary, controller, framework, procedures, types, services, cpue_utils)
      - cp_if: `src/` (cp_if_service, f1_service, e1_service, xn_service, x2_service, libs)
      - cp_cl: `src/` (admission_control, procedures, storage_service, distributed_units_service, types)
      - cp_sb: `src/` (bearer_management, security, pdcp)
      - cp_nb: `src/` (scale_adm, network_plan, anr_service)
      - cp_e2: `src/`

10.6 Logging: logger name, levels?
      ✅ (from codebase analysis)

```
  **CU shared logger macros (cp_ue and cu/ components):**
  - `LOG_DEBUG_MSG`, `LOG_INFO`, `LOG_WARNING_MSG`, `LOG_ERROR_MSG` (fmt + severity)
  - File: `cu/libs/logger/include/logger/logger.hpp`
  - UE-scoped macros: `LOG_UE_INFO`, `LOG_UE_WARNING`, `LOG_UE_DEBUG`, `LOG_UE_ERROR`
    (auto-prepend UE ID via `getUeIdCu()`/`getPrintableIds()`)
    File: `cu/cp_ue/src/types/cpue_types/include/cpue_types/UeLogging.hpp`

  **CP-RT logger (stream-style):**
  - `CPLANE_DEBUG`, `CPLANE_INFO`, `CPLANE_WARN`, `CPLANE_ERROR`
  - Specialized: `CPLANE_*_MSG_SEND`, `CPLANE_*_MSG_RECV`, `CPLANE_DEBUG_CELL`
  - File: `CP-RT/CP-RT/src/common/logger/include/logger/CplaneLogger.hpp`
  - Subsystem name: `constexpr char gScName[] = "cp_rt"` in `CprtLogger.hpp`
  - Tags: `FunctionalityTag`, `ResourceTag` for structured log prefixes

  **Log level override (tests):**
  - CU UT: `std::getenv("LOG_LEVEL")` in `cu/tests/ut_main/ut_main.cpp`
  - CP-RT UT: `getenv("DEBUG_LOG")`, `getenv("BACKTRACE_ON_ERROR_LOG")` in `CP-RT/CP-RT/UT/ut_main/ut_main.cpp`
  - CP-NRT UT: `getenv("DEBUG_LOG")` in `CP-NRT/CP-NRT/tests/ut/ut_main/ut_main.cpp`

  **Logging convention [TEAM PROVIDED]:**
  - Function entry/exit → DBG level (with key parameters)
  - Important state transitions or decisions → INF level
  - Failure/recovery paths → WRN or ERR level
  - Each component/module uses a specific logger name as primary filter
    (e.g. `cp_ue`, `cp_if_du`, `cp_rt_ue`)

  **Two log formats exist — always identify which one first:**

  Format A (Lab / SCT / HO.log):
  `<hex> ASC-<sicad>-<n>-<process> <ISO-timestamp>Z <LEVEL>/<module>/<file>:<line> <message>`
  - CP-RT: `ASC-1515-2-Cprt ... 85-cp_rt_ue DBG/cp_rt/FileName.cpp:line [ueIdCu:X,ueIdDu:Y,intUeIdDu:Z] message`
  - cp_ue: `ASC-151C-2-cp_ue ... 64-cp_ue DBG/cp_ue/FileName.cpp:line message`

  Format B (Production / RAIN):
  `<hex> po-<proc>-<inst>-ctr-<comp>-<EID>-<n>-<Binary> <ISO-timestamp>Z <thread_hex>-<thread_name> <LEVEL>/<module>/<file>:<line> <message>`
  - CP-RT: `po-cprt-0-ctr-cprt-E400-0-Cprt ... EF-cp_rt_ue WRN/cp_rt/...`
  - CP-RT main: `po-cprt-0-ctr-cprt-E400-0-Cprt ... DD-cp_rt INF/cp_rt/...`
  - CP-IF-DU: `po-cprt-0-ctr-cprt-E400-0-Cprt ... DC-cp_if_du ...`
  - CPCONFIG: `po-oamconfig-0-ctr-oamconfig-E010-0-CPCONFI ... 127-CPCONFIG INF/...`
  - NTS: `po-oamconfig-0-ctr-oamconfig-E010-0-NTS ... D2-NTS INF/...`

  Format detection: `grep -q "^.. ASC-" <log> && echo "Format A" || echo "Format B"`

  Log levels: `DBG`, `INF`, `WRN`, `ERR`
  UE context tag: `[ueIdCu:X,ueIdDu:Y,intUeIdDu:Z]`
  Cell context tag: `[CELL] nrCellIdentity:XXXXX`

  Cross-process message tracing:
  - Send: `message sent itf::cp::cpue_cprt::SCpUeCpRtSyscomCommunicationEnvelope(0xMSGID), size: N bytes`
  - Recv: `message recv itf::cp::cpue_cprt::SCpUeCpRtSyscomCommunicationEnvelope(0xMSGID)`
  - grep hint: `ueIdCu:X` to trace all log lines for a UE across processes
```

================================================================================
11. TESTING & SPECIFICATIONS
================================================================================

11.1 Test framework and markers?
      ✅
      - Unit tests: GTest (C++), ninja *UT
      - SCT tests: TTCN3, ninja sct_run**
      - Baskets: @wip, @stable (via SCT_TEST_BASKET)
      - Patterns: SCT_TEST_PATTERNS="Module.testCase"*

11.2 Test patterns and simulators?
      ✅ (partial — see CPLANE_RULES.md §14.6)
      Known patterns: bearerSetupProcedureOk, cuBearerContextSetupProcedureNsa,
      performL2HiCuBearerSetupProcedure, f_UT_delay
      ✅ SCT simulators (from codebase analysis):
      - **SdlSimulator**: SDL key-value store simulation (`sct/libraries/Sdl/Sdl.ttcn3`)
      - **SdlUserInterface**: creates `SdlSimulator` (`sct/libraries/Sdl/SdlUserInterface.ttcn3`)
      - **PmAgentStubMulti**: PM agent stub for counter tests (`sct/procedures/PmCounters/`)
      - **TmStub**: trace management stub
      - **SDL Async Simulator**: configurable via `SDL_ASYNC_SIMULATOR_CONFIG` env var (`libs/sdl_simulator/`)
      - **TM Stub**: via `cu/libs/tm_stub/`
      - SCT composition: `CpUeMain` extends SUT with ports to CpIf (F1/E1/X2/Xn/Ng receivers),
        CpCell, CpNb, CpUe, SDL user, PmAgent stub, GenApi, Pcmd
        File: `cu/cp_ue/sct/control/Components.ttcn3`
      - No separate "AMF simulator" or "DU simulator" C++ classes — simulated environment is built
        from TTCN3 protocol ports, SDL stubs, and PM stubs

```
  **SCT conceptual simulator roles [TEAM PROVIDED]:**
  (These are logical roles within the TTCN3 harness, NOT standalone C++ classes)
  - AMF Simulator: mocks AMF to send/receive NGAP messages
  - DU Simulator: mocks DU to send/receive F1AP and RRC messages
  - CU-UP Simulator: mocks CU-UP to send/receive E1AP messages
  - Peer gNB Simulator: mocks peer gNB to send/receive XnAP messages

  **Additional test patterns [TEAM PROVIDED]:**
  - `checkUeContextInGnb(ueId)`: query internal test interface to verify UE context state
```

11.3 Product/feature specs?
      ✅ (partial)
      - [3GPP TS 38.331 (NR RRC)](https://portal.3gpp.org/desktopmodules/Specifications/SpecificationDetails.aspx?specificationId=3197)
      - [3GPP TS 38.401 (NG-RAN Architecture)](https://portal.3gpp.org/desktopmodules/Specifications/SpecificationDetails.aspx?specificationId=3219)
      - [3GPP TS 38.413 (NGAP)](https://portal.3gpp.org/desktopmodules/Specifications/SpecificationDetails.aspx?specificationId=3223)
      - [3GPP TS 38.423 (XNAP)](https://portal.3gpp.org/desktopmodules/Specifications/SpecificationDetails.aspx?specificationId=3228)
      - [3GPP TS 38.463 (E1AP)](https://portal.3gpp.org/desktopmodules/Specifications/SpecificationDetails.aspx?specificationId=3233)
      - [3GPP TS 38.473 (F1AP)](https://portal.3gpp.org/desktopmodules/Specifications/SpecificationDetails.aspx?specificationId=3257)
      - [3GPP TS 37.340 (Multi-RAT DC / EN-DC)](https://portal.3gpp.org/desktopmodules/Specifications/SpecificationDetails.aspx?specificationId=3198)
      - Internal PFS/ICFS: YES, they exist [TEAM PROVIDED, confirmed]
        Location: stored in a dedicated documentation repository (Confluence space or SharePoint)
        managed by the system architecture team — NOT in the code repository.
        Search examples: "C-Plane PFS for 5G24R1", "ICFS for F1 interface"

11.4 Test parametrization?
      ✅ BTSs["CONFIG_ID"] for BTS variant parametrization

11.5 Test-specific flags and simulators?
      ✅ (from codebase analysis)

```
  **SCT environment variables (CMake + runner):**
  - `SCT_TEST_PATTERNS="Module.testCase"` — run specific SCT test
  - `SCT_TEST_BASKET="wip"` or `"stable"` — select test basket
  - `SCT_TTCN3_REPEAT_COUNT=N` — repeat SCT for flakiness detection
  - `SCT_FORCE_CLASSICAL_DEPLOYMENT` — used in CP-NRT `ScenarioContext.cpp` (getenv)
  - CMake variables: `SCT_`* in `tools/sct/ttcn3_cplane_tools_sct.cmake`, `sct/cplane_sct.cmake`

  **UT environment variables:**
  - `GTEST_SHUFFLE=1` + `GTEST_REPEAT=N` — race condition detection
  - `LOG_LEVEL` — CU UT logger severity (`cu/tests/ut_main/ut_main.cpp`)
  - `DEBUG_LOG` — CP-RT and CP-NRT UT debug logging
  - `BACKTRACE_ON_ERROR_LOG` — CP-RT UT backtrace on error
  - `GENERATOR_INITIAL_VALUE` — SCT generator plugin (`sct/plugins/generator/src/generator.cpp`)
  - `SDL_ASYNC_SIMULATOR_CONFIG` — SDL simulator config (`libs/sdl_simulator/`)

  **R&D parameters (runtime knobs):**
  - Central list: `cu/libs/app_configuration/src/ConfigurationLoader.cpp`
    Contains: `enablePrachWorkaround`, `bindToAddress` (for SCT), `maxNoCpUeVms`,
    periodic counter disables for cp_cl/cp_ue, etc.
  - `rdStateHistoryBufferRecordsInCpUe` — R&D param with static_assert on default
    File: `cu/cp_ue/src/shb/logger/src/LoggerFactory.cpp`

  **Feature flags (product/config, not compile-time):**
  - `FeatureFlags` / `FeatureFlagsBuilder` (cp_cl tests) — `HigherPrioFreqHo`,
    `ActMeasBasedSCellAdditionSA`, `NrdcRestrictionBuilder::withNrdcFeatureFlag`
  - `CaHandlerFeatureFlags` (cp_cl CA/admission)

  **Additional test flags [TEAM PROVIDED]:**
  - `SCT_TEST_BASKET="@regression"` — regression test basket (in addition to @wip, @stable)
  - `SCT_LOG_LEVEL=DEBUG` — increase verbosity during SCT test run
  - Test-only parameters: `setParameter("mockE1SetupFailure", "true")` — read by C-Plane code
    only in test build (`#ifdef TEST_BUILD`)
```

================================================================================
12. OUTPUTS & TEMPLATES
================================================================================

12.1 Report types?
      ✅ Investigation Report, Escalation Report, Missing Context Report

12.2 Investigation Report sections?
      ✅ 13 sections (documented in CPLANE_RULES.md §19.1 and CPLANE_Agent.md Template 1)

12.3 Escalation Report?
      ✅ 6 sections (documented in CPLANE_RULES.md §19.2 and CPLANE_Agent.md Template 2)

12.4 Missing Context Report?
      ✅ 5 sections (documented in CPLANE_RULES.md §19.3 and CPLANE_Agent.md Template 3)

12.5 Solution Quality Checklist?
      ✅ (CPLANE_RULES.md §20 — 6 items)

12.6 Propose-first policy?
      ✅ Agent MUST propose before implementing. Never apply changes without user agreement.

================================================================================
13. TOOLS & DATA REQUESTS
================================================================================

13.1 When PR lacks repro or logs: what data to request?
      ✅ (CPLANE_Agent.md Guardrail #12)
      Propose: specific log levels to enable, specific TTCN3 basket/pattern to run,
      R&D flags to activate, GTEST_SHUFFLE/GTEST_REPEAT to detect races,
      SCT_TTCN3_REPEAT_COUNT for SCT flakiness

13.2 Debugging tools and utilities?
      ✅ (from CplaneSwArch_DebuggingLogging.adoc, verified against codebase)

```
  **cplane-tools** (online R&D parameter modification, ZMQ-based):
  - Location: `cplane/tools/`
  - `set_logging_level`: changes log level at runtime without restart
  - `set_overload_high_threshold`: adjusts overload threshold at runtime
  - CU-side handler: `CplaneControlCommandHandler` in `cu/libs/deployment_common/`
    Used by all cu/ runners (CplaneUeRunner, CplaneNbRunner, CplaneCellRunner, etc.)

  **Snapshot collection** (troubleshooting data packages):
  - Profiles: 0=All, 1=Crash&Recovery, 2=U+C Plane, 3=C-Plane only, 4=HW/SW config, 5=RU only
  - Triggered via: WebUI, REST API, or event-triggered (fault-triggered snapshot)
  - File format: `Snapshot_<NEName>-<NEID>_<SWRelease>_YYYYMMDD-hhmm_<RequestID>.zip`
  - Scope: CU only, DU only, CU+DUs (max 5 DUs in Cloud)
  - C-plane logs in snapshot: syslog files collected by AaTrblServer

  **External debugging tools:**
  - EMIL: C-plane L3 diagnostics (relies on AaTrace/SysCom mirroring; cannot decode MuLTI-based itfs)
  - Wireshark + LuaShark plugin: decode gNB internal traffic (generated with each build, covers all MuLTI messages)
  - MFA (Message Flow Analyzer): message sequence charts for SCT
  - Log-and-Trace: feature-flag-based logging with separate process for flag management
    (minimizes real-time penalty; feature flags at `/var/preserve/feature_log_activation.txt`)

  **Crash artifacts:**
  - Crash signature in journal: `journalctl -u ccsrt`
  - Artifacts in RPRAM (`/var/tmp`): `CCS-RT_crashdumps___SLOT_ID_____BOARD_ID_____NODE_ID__.tar`
  - RPRAM survives reboot (wiped only on power-off)
  - Core dump investigation: GDB

  **Application termination** (CNI-69510, verified for CU only):
  - genAPI `ControllableProcess` + `setTerminateCb()` for SIGTERM handling
  - `AaStartupDisableCCSShutdownSignalHandler()` suppresses CCS signal handler (CU only; CP-NRT does NOT use this)
  - 3-second timeout for clean shutdown before forceful termination by CCSDaemon
  - `AaStartupEeShutdown()` for CCS cleanup (both CU and CP-NRT)

  **Common libraries** (cu/libs/ — all verified present):
    fault_manager, timer_service, state_machines, message_gateway, sdl_communication,
    high_availability, thread_watchdog, deployment_common, app_configuration, logger,
    messages, nidd_configuration, database, endpoints, zmq_helpers, sctp, types, utils,
    pcmd, pm_services, fm_proxy, async_join, id_allocator, watchdog, traffic_monitor
```

================================================================================
14. SUB-COMPONENTS / PROTOCOL VARIANTS
================================================================================

14.1 Sub-components or variants?
      ✅
      - NSA (Non-Standalone / EN-DC): MR-DC procedures, LTE anchor, cp_sb/cp_if NSA code paths
      - SA (Standalone): independent 5G procedures
      Per-component: cp_ue, cp_sb, cp_if, cp_nb, cp_cl, cp_e2 (each has distinct logic)

14.2 Active variant detection?
      ✅ (partial) — detected at runtime from configuration attributes
      ✅ NSA/SA detection (from codebase analysis):
      - **Cell level:** `types::CellDepType` — `standalone`, `nonStandalone`, `nonStandaloneAndStandalone`
      - **Helper function:** `isSaCellDepType(cellDepType)` in `CellParamsUtils.hpp`
      - **UE level:** `NsaUEInformation::isNsaFullRrcConfigTriggered()` in `NsaUEInformation.hpp`
      - **Bearer level:** `isNsa3xBearerAllowed` in `INrDrbContainer.hpp`
      - **CP-NRT:** `types::UeContextType` in `cpnrt::UeContext`; `itf::TypeOfBearer::NSA` vs `::SA`
      - No single `isNsa()` flag — determined from cell deployment type + UE info + service tree

14.3 Fix applies to all variants unless proven specific?
      ✅ A fix in NSA path MUST be applied to SA path too, unless proven variant-specific.

================================================================================
15. CURSOR-SPECIFIC ADDITIONS (not in original framework)
================================================================================

15.1 Subagent spawning rules?
      ✅ (CPLANE_Agent.md — Subagent Spawning Strategy):
      - Large logs → shell subagent with rg
      - Multi-component search → parallel explore subagents per cp_* directory
      - Build verification → shell subagent (non-blocking)
      - Cross-component → note involved cp_* components, search each

15.2 Tool mapping per investigation phase?
      ✅ (CPLANE_Agent.md — Cursor Tool Mapping table)

15.3 Build commands reference?
      ✅ AGENTS.md at /workspace/cplane/cu/AGENTS.md

15.4 Rule activation?
      ✅ .cursor/rules/cplane_pr_investigation.mdc — activated on cplane/** files

================================================================================
16. CP-NRT AND CP-RT SPECIFIC KNOWLEDGE (NEW SECTION — NOT IN ORIGINAL FRAMEWORK)
================================================================================

16.1 CP-NRT architecture summary?
      ✅
      - Binary: `cp-nrt`
      - Root CMake: `CP-NRT/CMakeLists.txt` → `project(cp-nrt)`
      - Pattern: Scenario-driven. `ScenarioHandler` dispatches to specific scenario classes.
      - Key scenario types: bearer (setup/modify/error_ind), oam (deltaplan), pool_config, trsw_addr_config
      - UE state: `cpnrt::UeContext` (DRBs, PDU sessions, NSA/SA type, E1 IDs, HO, security, NIDD)
      - CU-UP selection: `CuUpPicker`
      - State machines: `BaseStateMachine` (Boost.MSM base)
      - NSA: `TypeOfBearer::NSA`; SA: `TypeOfBearer::SA` (in `BearerSetupReqBuilder`)
      - Test: GTest, `ninja ut`, layout `CP-NRT/CP-NRT/tests/ut/`
      - Resiliency model: 2N

```
  ✅ CP-NRT threading model (from CPNRT_Design_Document.adoc, verified against code):
  - **Engine (ScenarioLoop):** single main thread running application logic. Pops scenarios from
    ScenarioQueue, runs concurrency pre-check, then `scenario->handle(scenarioHandler)`.
    Code name: `cpnrt::ScenarioLoop` (not "Engine" class — doc concept name)
  - **ScenarioQueue:** thread-safe producer-consumer queue (mutex-protected). Proxies push,
    ScenarioLoop pops with 100ms timeout.
  - **Proxy threads** (each has dedicated thread for receiving; send from Engine thread):
    | Proxy                                             | Role                                              | Verified             |
    | ------------------------------------------------- | ------------------------------------------------- | -------------------- |
    | E1SctpReceiverProxy / E1SctpSenderProxy           | SCTP E1AP messages                                | ✅                    |
    | E1SyscomReceiverProxy / E1SyscomSenderProxy       | SysCom E1AP (classical optimization)              | ✅                    |
    | OamProxy (doc: "OamCmProxy")                      | OAM config management                             | ✅ (name: OamProxy)   |
    | L2HiProxy                                         | L2 HI interface                                   | ✅                    |
    | TrswProxy + TrswFirewallProxy + TrswIpsecProxy    | TRSW services (multiple)                          | ✅                    |
    | PmAgentProxy                                      | PM/LOM                                            | ✅                    |
    | TraceControllerService (doc: "TraceControlProxy") | Trace service                                     | ✅ (TcProxy/TccProxy) |
    | RndDispatcherProxy                                | R&D params, SCT timer forward                     | ✅                    |
    | ServiceDiscoveryProxy                             | DHA service discovery                             | ✅                    |
    | OamFmProxy                                        | Fault management (send only, no dedicated thread) | ✅                    |
  - **Concurrency Framework:** `ConcurrencyFrwk` with `ConcurrencyHandler::registerInfoLists()`;
    maintains ongoing procedure list, action policies (process/queue/discard/reject/abort-and-process),
    concurrency queue with audit timeouts. Called via `concurrencyFrwk.preHandleScenario()`.
  - **E1 Setup retry:** timeout → `E1SetupTimeoutScenario` → `E1SetupRestartScenario` → retry.
    Configurable timer and fault/alarm threshold (`e1NbSetupRetryForFault`).
  - **Exception handling:** some scenarios wrap `run()` in try/catch (e.g. BearerSetupReqScenario,
    BearerModifyReqScenario); NOT universal across all scenarios despite doc recommendation.
  - **HA:** SDL for UE IDs/key info, watchdog via GenAPI::ControllableProcess, DHA for VNFC supervision.
  - **R&D parameters:** CCS R&D service based (domain: RAD_SW_DOMAIN for CP-NRT) +
    static config file `cp-nrt.enb_conf.ini` (not recommended for non-static params).
  - **Tooling:** CCS (AaSysCom, AaSysTime, AaSysLog, AaConfig, AaStartup), MuLTI, Assassin (E1AP),
    GTest/GMock (UT), TTCN3 (SCT)
```

16.2 CP-RT architecture summary?
      ✅
      - Binary: `Cprt`
      - Root CMake: `CP-RT/CP-RT/CMakeLists.txt` → `project(5G-CP-RT)`
      - Pattern: Multi-threaded with dedicated thread apps. Boost.MSM FSMs per UE/cell procedure.
      - NSA/SA split: explicit `src/nsa/` and `src/sa/` directories under `ue_setup/`
      - Key FSMs: `UeContextSetupFsm` (NSA), `SAUeContextSetupFsm` (SA), `UeContextReleaseFsm`, `UeScellAdditionFsm`, `BeamConfigUpdateFsm`
      - Interfaces: `.mt` files at `CP-RT/itf/cp/rt/` (cprtue, cprtbe, cprtrp)
      - Built with: `assassin-f1ap`, `assassin-x2ap`, `assassin-nrrrc`, MuLTI codegen
      - Test: GTest, `ninja ut`, layout `CP-RT/CP-RT/UT/` + `tests/ut/nsa/` and `tests/ut/sa/` per service
      - Tooling: CCS (AaSysCom, AaSysTime, AaSysLog, AaConfig, AaStartup, AaFile), RCP SDL,
        MuLTI, boost::MSM, GTest/GMock, 3rd party: JsonCpp, Expat, GSL, YAS, Protobuf

```
  ✅ CP-RT threading model (from CPRT_Design_Document.adoc, verified against code):
    | Thread              | Class                                      | OS Name    | Role                                                                     |
    | ------------------- | ------------------------------------------ | ---------- | ------------------------------------------------------------------------ |
    | Main                | `main()` in Main.cpp                       | —          | Placeholder: init SDL, start CpIfDuThread + CprtThread, then idle        |
    | CpIfDuThread        | `CpIfDuThread` → `CpIfDuApp`               | `cp_if_du` | F1AP SCTP communication, message receive/send via F1                     |
    | CpRtThread          | `CprtThread` → `CprtApp`                   | `cp_rt`    | Common/cell procedures (admission, RRM, cell mgmt); starts child threads |
    | CpRtUeThread(s)     | `CprtUeThread` → `CprtUeApp`               | `cprtue`   | UE procedures (setup, mobility, release); multiple instances             |
    | CpRtCenUeThread     | `CpRtCenUeThread` → `CpRtCenUeApp`         | —          | F1AP SysCom for UE-specific + Paging + CcchDataReceiveInd                |
    | CpRtBeThread        | `CprtBeThread` → `CprtBeApp`               | `cprt_be`  | High-CPU tasks (PMI beam calculation)                                    |
    | CpRtRPThread        | `CprtRPThread` → `CprtRPApp`               | —          | Optional (R&D flag `rdEnableCpRtRpThread`); RAN parameters               |
    | CpRtTraceMgmtThread | `CprtTraceMgmtThread` → `CprtTraceMgmtApp` | —          | RCP trace controller interface                                           |
    | CpRtSdlThread       | `CprtSdlThread`                            | —          | SDL communication (only when HA enabled)                                 |

  ✅ CP-RT threading diagram:

  ┌─────────────────────────────────────────────────────────────┐
  │                     Cprt Process (Binary)                    │
  │                                                              │
  │  ┌──────────┐    ┌───────────────────────────────────────┐  │
  │  │ Main     │───▶│ CpIfDuThread (CpIfDuApp)              │  │
  │  │ thread   │    │ OS: cp_if_du                           │  │
  │  │          │    │ Role: F1AP SCTP I/O with gNB-DU        │  │
  │  │ init SDL │    └──────┬──────────────┬──────────────────┘  │
  │  │ then     │           │ SysCom       │ SysCom              │
  │  │ idle     │           │ (paging)     │ (UE-assoc F1AP)     │
  │  │          │           ▼              ▼                     │
  │  │          │    ┌──────────────┐ ┌──────────────────────┐  │
  │  │          │───▶│ CpRtThread   │ │ CpRtUeThread(s)      │  │
  │  │          │    │ (CprtApp)    │ │ (CprtUeApp) ×N       │  │
  │  │          │    │ OS: cp_rt    │ │ OS: cprtue            │  │
  │  │          │    │              │ │                        │  │
  │  │          │    │ Cell mgmt    │ │ UE FSMs (setup/       │  │
  │  │          │    │ RRM / AC     │ │ modify/release/HO)    │  │
  │  │          │    │ Config       │ │                        │  │
  │  │          │    │ Overload     │ │ Version sync via       │  │
  │  │          │    │              │ │ atomics + SysCom ind   │  │
  │  │          │    └──────────────┘ └──────────────────────┘  │
  │  │          │           │                                    │
  │  │          │    ┌──────┴──────────────────────────────┐    │
  │  │          │───▶│ CpRtBeThread  │ CpRtRPThread (opt.) │    │
  │  │          │    │ (CprtBeApp)   │ (CprtRPApp)         │    │
  │  │          │    │ Beam calc     │ RAN params           │    │
  │  └──────────┘    └────────────────────────────────────┘    │
  │                                                              │
  │  Shared data protection: ThreadGuard (4 shared_mutex)        │
  │  Inter-thread comm: SysCom messages only (no shared memory)  │
  └──────────────────────────────────────────────────────────────┘

  ✅ CP-RT mutex/lock discipline (from CPRT_Design_Principle_And_Guideline.adoc, verified):
  - **Do NOT use mutex arbitrarily** — requires CP-RT Chapter Team approval
    (mailto: I_ECE_CP_GUILD_CPRT_CPNRT@internal.nsn.com)
  - **ThreadGuard.cpp** (4 shared_mutex, not 3 as in older doc):
    `cellConfigLock`, `traceSessionLock`, `l2NrtPoolConfigLock`, `niddConfigLock`
    Accessors: `createCellConfigReadGuard()`/`createCellConfigUpdateGuard()`, etc.
  - **PmCounterUpdater.hpp**: additional `std::mutex` for PM counters
  - RAII required for all resource management (system: memory, timer, lock; app: CSI-RS, handlers)

  ✅ CP-RT RRM 4-layer architecture (from CPRT_Radio_Resource_Management.adoc, verified):
    Layer 1 — **RadioResourceMgmtService**: module interface, message handling, counter pegging
    Layer 2 — **Procedure-specific Handlers**: translate to common AC activities
      `SaInitialAccessAllocationHandler`, `SaHandoverAllocationHandler`,
      `NsaUeSetupAllocationHandler`, `ModifyAllocationHandler`,
      `InterGnbCaExtDuScellAdditionAllocationHandler`, `NrdcUeSetupAllocationHandler`
    Layer 3 — **Resource Managers**: `RadioResourceManager` (IRadioResourceManager), `BearerResourceManager`
      `PcellUserAdmitter`, `ScellUserAdmitter`
    Layer 4 — **Support Classes**: allocation algorithms, data classes/repositories
    Factory: `RadioResourceMgmtFactory`
    AC interface: `CpRtUe_AdmissionControlReq` (allocate/modify), `CpRtUe_UeResourceReleaseReq` (release)
    Resources managed: CSI-RS, pCSI (periodic CSI), SR, HARQ (F1/F3), pSRS

  ✅ CP-RT UE Management design (verified):
  - **Front-end Service** per F1 message (e.g. `UeContextModificationService`):
    validates F1 message, translates to operation-based internal events, detects invalid combos
  - **Task/Transaction pattern**: Tasks encapsulate business functions (single responsibility);
    Transactions are minimum building blocks reused across tasks (e.g. `BearerTransaction`)
  - **DynamicCombinedOperationsTask**: sequencer for multi-operation F1 messages;
    plugs in operation tasks dynamically, manages sequence/parallel, combines results
  - **UE/FSM Context discipline**: physical channel resources in UeContext (not FSM context);
    temporary FSM state flags do NOT belong in UeContext (needs chapter review)

  ✅ CP-RT Cell Procedure Concurrency Framework (verified):
  - `CellMgmtService`: front-end with `scheduleEvent()`, `finishTask()`, `startTask()`
  - `CellConcurrencyRules.cpp`: rules per incoming event vs ongoing procedure
  - Actions: process, queue, reject
  - Ongoing procedures: `CellProcedureWithUplane`, `WaitingForCuConfigurationUpdate`,
    `PostCuConfigurationUpdate`, `CellParallelProcedure`, `WaitForDuConfigurationUpdateAck`,
    `F1SetupProcedure`
  - Events queue for deferred processing; `finishTask()` pops and re-schedules

  ✅ CP-RT High Availability framework (from design doc, verified):
  - `HaRecoverableStruct<Data>` template: wraps SDL-stored data with `readOnly()`/`readWrite()` API
  - `HaService` per thread: manages SDL transactions, error handling, data queues
  - **YAS** serialization library for custom types (member `serialize()` function)
  - `rdHighAvailabilityEnabled` R&D flag: when false, HaRecoverableStruct is a plain wrapper (no SDL overhead)
  - Recommendation: store POD data, not smart pointers or objects; separate data from objects
  - Recovery startup: `fetchFromSdlCache()` on `HaRecoverableStruct` fields
```

16.3 Log format for CP-NRT and CP-RT?
      ✅ The C-Plane components use two primary log formats, one for lab/SCT environments
      and another for production/RAIN environments. The detailed formats, fields, detection
      methods, log levels, context tags, and cross-process tracing patterns are documented
      in Section 10.6.

16.6 Energy Saving (ES) multi-process architecture?
      ✅ (from RAIN log analysis — PR879981)

```
  ES spans multiple processes. C-Plane owns cp_cl logic; OAM owns cell MO lifecycle:

  | Process   | RAIN Pod                 | ES Role                                                                                                       |
  | --------- | ------------------------ | ------------------------------------------------------------------------------------------------------------- |
  | NTS/NRTS  | `po-oamconfig-…-NTS`     | CellEnergySavingHandler, CellEnergySavingFaultToleranceManager, ExitEnergySavingHandler, SingleCellController |
  | REM       | `po-oamfh-…-REM`         | ConfigureEnergySavingModeTrigger, deep sleep timer                                                            |
  | CPCONFIG  | `po-oamconfig-…-CPCONFI` | Cell MO state (energySavingState), NrcellRAsyncScenario, ExitEnergySavingNotif                                |
  | emservice | `po-oamasm-…-oamembe`    | ES status reporting (energySavingMode, energySavingState via JsonPayloadParser)                               |
  | CP-RT     | `po-cprt-…-Cprt`         | Cell activation/deactivation (AntennaCarrierActivationReq)                                                    |

  ES state values observed in RAIN logs:
  - `energySavingState`: `notEnergySaving`, (presumably `energySaving`)
  - `energySavingMode`: `NORMAL`
  - RMOD states checked by ExitEnergySavingHandler: `SLEEP`, `POWEROFFBYES`

  CRITICAL: NTS can be killed and restarted mid-test, causing potential ES state loss.
  When investigating "cell remains in ES" issues, always check for NTS restart events.

  ✅ ES multi-process interaction diagram:

  ┌─────────────────────────────────────────────────────────────────┐
  │                    OAM Processes (out of C-Plane scope)          │
  │                                                                  │
  │  ┌──────────┐   ┌──────────┐   ┌───────────┐   ┌───────────┐  │
  │  │   NTS    │   │   REM    │   │ CPCONFIG  │   │ emservice │  │
  │  │          │   │          │   │           │   │           │  │
  │  │ ES       │   │ ES mode  │   │ Cell MO   │   │ ES status │  │
  │  │ handler  │   │ trigger  │   │ state     │   │ reporting │  │
  │  │ fault    │   │ deep     │   │ energySav │   │           │  │
  │  │ tolerance│   │ sleep    │   │ ingState  │   │           │  │
  │  └────┬─────┘   └────┬─────┘   └─────┬─────┘   └───────────┘  │
  │       │              │               │                          │
  └───────┼──────────────┼───────────────┼──────────────────────────┘
          │              │               │
          ▼              ▼               ▼
  ┌───────────────────────────────────────────────────────────────┐
  │                    C-Plane Processes (in scope)                │
  │                                                                │
  │  ┌──────────────────────┐   ┌───────────────────────────────┐ │
  │  │  cp_cl (CU-CP)       │   │  CP-RT (gNB-DU side)          │ │
  │  │                      │   │                                │ │
  │  │  CpEnergySavingState │   │  EnergySavingAlgorithm         │ │
  │  │  on CellContext       │   │  MaxValueSOffStrategy          │ │
  │  │                      │   │  SwitchStrategiesProvider       │ │
  │  │  DuCellSwitching     │   │                                │ │
  │  │  IndicationProcedure │   │  Cell activation/deactivation  │ │
  │  │                      │   │  AntennaCarrierActivationReq   │ │
  │  │  Admission control   │   │  F1AP cell setup               │ │
  │  └──────────────────────┘   └───────────────────────────────┘ │
  └───────────────────────────────────────────────────────────────┘
```

16.4 NSA vs SA in CP-RT?
      ✅
      - Explicit dir split: `ue_setup/src/nsa/` vs `ue_setup/src/sa/`
      - Test split: `tests/ut/nsa/` vs `tests/ut/sa/`
      - Key NSA files: `NsaUeSetupAdmissionControl.cpp`, `UeContextSetupFsm.hpp`
      - Key SA files: `SaUeSetupAdmissionControl.cpp`, `SAUeContextSetupFsm.hpp`, `SAHandoverUeContextSetupFsm.hpp`
      - CRITICAL: Fix in NSA MUST be verified against SA and vice versa

16.5 NSA vs SA in CP-NRT?
      ✅
      - `cpnrt::UeContext` carries `types::UeContextType` and E-UTRAN DRB lists
      - `BearerSetupReqBuilder.cpp` uses `itf::TypeOfBearer::SA` vs `::NSA`
      - `CuUpPicker.cpp`: NSA-specific IPsec policy
      - `ContinueDeltaPlanScenario.cpp`: handles E1 reset for NSA UEs

================================================================================
17. PCMD & TRACE (CROSS-COMPONENT DOMAIN)
================================================================================

17.1 What is PCMD?
      ✅ (from codebase analysis)
      PCMD (Per-Call Measurement Data) is a cross-component domain spanning all C-Plane processes.
      It provides vendor-specific measurement records for network optimization and trace activation.
      Two trace types: MBA (Management-Based, cell-wide) and SBA (Signaling-Based, per-UE via NGAP).

17.2 PCMD data flow?
      ✅ (from codebase analysis)
      1. Trace Controller NR (external) → cp_cl: resource start/stop via SysCom
      2. cp_cl ManagementService: cell registration, trace params → cp_ue
      3. cp_ue ConcreteUePcmdSession: collect() events into PcmdTicket during UE procedures
      4. cp_ue sendTicket(): builds AppVendorRecordInd → sends via CpUeTraceControllerNrSender
      5. CP-NRT TraceControllerService: SBA/MBA sessions, PcmdRecordsService for CU-UP side
      6. CP-RT PcmdHelper: F1AP cause classification; CprtTraceMgmtApp: RCP trace management

17.3 Key PCMD classes?
      ✅ (from codebase analysis)
      - cu/libs/pcmd: TraceControllerNrSender, TraceControllerNrReceiver, PcmdDispatcher
      - cp_ue: PcmdService, ConcreteUePcmdSession, PcmdTicket, CpUeTraceControllerNrSender
      - cp_cl: ManagementService, ConcreteManagementService, CpClService, CellConfigService
      - CP-NRT: TraceControllerService, UePcmdSessionManager, PcmdRecordsService
      - CP-RT: PcmdHelper, CprtTraceMgmtApp, CprtTraceMgmtThread

      Full details: CPLANE_RULES.md §14b

================================================================================
18. OTHER CP-RT / CP-NRT SERVICES
================================================================================

18.1 Additional CP-RT services?
      ✅ (from codebase analysis)
      - Positioning: NR positioning measurement via F1AP + L2 PS (positioning_mgmt/)
      - PWS: ETWS/CMAS via F1AP WriteReplaceWarningRequest (public_warning_system/)
      - Auto Access Barring: automatic UAC barring on CU/DU overload (auto_access_barring/)
      - ML Management: external ML plane integration (ml_mgmt/)
      - Load Reporting (F1): DL/UL GBR, RRC/PUCCH load calculators (load_report_mgmt/)
      - L2 PS Management: PWS offline storage forwarding (l2ps_mgmt/)
      - Slice-Aware Admission: per-cell UE context for slice/RG limits (common/slice_aware/)
      - Paging: F1AP paging via CpRtCenUeApp + PagingHandler (cprt_cen_ue_mgmt/)

      Full details: CPLANE_RULES.md §14c

18.2 Additional CP-NRT services?
      ✅ (from codebase analysis)
      - Dynamic Data Path Supervision (DPS): GTP-U path supervision via TRSW
      - Dynamic Firewall: runtime TRSW firewall open/close for IP connections
      - Load Manager: L2 HI load measurement report handling

      Full details: CPLANE_RULES.md §14d

# ================================================================================

END OF QUESTION FRAMEWORK (CPLANE FILL)