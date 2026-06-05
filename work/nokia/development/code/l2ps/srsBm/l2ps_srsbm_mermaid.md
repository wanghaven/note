# L2PS SRS BM Mermaid Class Diagrams

本文档根据 [l2ps_srsbm.md](l2ps_srsbm.md) 中的 PlantUML 类图整理而来，并拆分为多张 Mermaid 类图，便于在 Obsidian / VS Code 中查看。

## 1. Top-Level Overview

```mermaid
classDiagram
direction TB

namespace l2ps_srsBm_em {
  class Eo {
    -QueueFsm fsm
    -shared_ptr~MainComponentSrsBm~ mainComponentSrsBm
    -EmQueue queue
    -EmQueue queueSchTime
    +start()
  }

  class QueueFsm["QueueFsm"] {
    <<typedef>>
    using QueueFsm = EmFsm~QueueFsmImpl~
  }
}

namespace l2ps_srsBm_management {
  class MainComponentSrsBm {
    -DlSrsBmManager dlSrsBmManager
    -UlSrsBmManager ulSrsBmManager
    -SrsBmCellDb srsBmCellDb
  }
}

namespace l2ps_srsBm_dl {
  class DlSrsBmManager
}

namespace l2ps_srsBm_ul {
  class UlSrsBmManager
}

namespace l2ps_srsBm_db {
  class SrsBmCellDb
  class SrsBmCell
}

Eo *-- QueueFsm
Eo o-- MainComponentSrsBm
MainComponentSrsBm *-- DlSrsBmManager
MainComponentSrsBm *-- UlSrsBmManager
MainComponentSrsBm *-- SrsBmCellDb
SrsBmCellDb *-- SrsBmCell
```

## 2. Common FSM Template And Queue FSM

```mermaid
classDiagram
direction LR

namespace boost {
  class BoostSm["sml.sm<Table, ProcessQueue>"] {
    <<template>>
    +process_event(event)
    +visit_current_states(visitor)
    +is(state) bool
  }
}

namespace common_stateMachine {
  class FsmTemplate["stateMachine.Fsm<SmlFsm>"] {
    <<template>>
    -SmlFsm.Data data
    -boost.sml.sm~SmlFsm.Table, queue~ fsm
    +processEvent(event)
  }
}

namespace common_emBase {
  class EmFsmBase {
    +processEvent(EmFsmEvent&) void
  }

  class EmFsmTemplate["emBase.EmFsm<FsmImpl>"] {
    <<template>>
    -stateMachine.Fsm~FsmImpl~ fsm
    +processEvent(EmFsmEvent&) void
  }
}

namespace l2ps_srsBm_em {
  class QueueFsmImpl {
    <<template>>
    +Data struct
    +Table struct
  }

  class QueueFsmData["QueueFsmImpl.Data"] {
    <<concrete>>
    +QueueStateStartup startupSrsBmHandler
    +QueueStateDefault defaultSrsBmHandler
    +QueueStateDelete deleteSrsBmHandler
    +Data(mainComponentSrsBm)
  }

  class QueueFsmTable["QueueFsmImpl.Table"] {
    <<concrete>>
    +operator()() auto
  }

  class QueueStateStartup {
    +handleEvent()
  }

  class QueueStateDefault {
    +handleEvent()
  }

  class QueueStateDelete {
    +handleEvent()
  }

  class QueueFsm["QueueFsm"] {
    <<typedef>>
    using QueueFsm = emBase.EmFsm~QueueFsmImpl~
  }
}

FsmTemplate o-- BoostSm : bind Table=SmlFsm.Table
EmFsmTemplate *-- FsmTemplate : instantiate Fsm~FsmImpl~
EmFsmTemplate --|> EmFsmBase

QueueFsmImpl *-- QueueFsmData : nested
QueueFsmImpl *-- QueueFsmTable : nested
QueueFsmData *-- QueueStateStartup
QueueFsmData *-- QueueStateDefault
QueueFsmData *-- QueueStateDelete
QueueFsm --|> EmFsmTemplate : bind FsmImpl=QueueFsmImpl
QueueFsm ..> QueueFsmImpl : template arg
```

## 3. Queue FSM Transition Table

```mermaid
stateDiagram-v2
direction LR

[*] --> startUpState
startUpState --> defaultState
defaultState --> deleteState
deleteState --> startUpState

startUpState --> X : StopEvent
defaultState --> X : StopEvent
deleteState --> X : StopEvent
X --> [*]
```

## 4. DL SRS BM

```mermaid
classDiagram
direction TB

namespace l2ps_srsBm_dl {
  class DlSrsBmManager {
    -SrsBmDataHandler srsBmDataHandler
    -BeamSelection dlSrsBmSelection
    -SrsBmTimerHandler srsBmTimerHandler
    -UeStatesHandler ueStatesHandler
    -SrsReceiveRespBmPsHandler srsReceiveRespBmPsHandler
  }

  class DlUeStatesHandler["UeStatesHandler"]

  class DlSrsBmTimerHandler["SrsBmTimerHandler"]

  class DlBeamSelection["BeamSelection"]

  class DlSrsReceiveRespBmPsHandler["SrsReceiveRespBmPsHandler"]

  class DlBeamCalculatorManager["BeamCalculatorManager"] {
    -unique_ptr~BeamBaseCalculator~ dlBeamCalculator
    -unique_ptr~BeamBaseCalculator~ dlTaperingBeamCalculator
    -unique_ptr~BeamBaseCalculator~ lbMMimoPowerSavingDlSrsBmCalculator
  }

  class DlBeamBaseCalculator["BeamBaseCalculator"]

  class DlSrsBmDataHandler["SrsBmDataHandler"] {
    -shared_ptr~SrsBmUeDbBase~ srsBmUeDb
    -SbSrsComaCorrCalculator corrCalculator
  }

  class DlSrsBmUeDbBase["SrsBmUeDbBase"] {
    <<typedef>>
  }

  class SrsBmUeDbDl["SrsBmUeDbDl"]

  class SbSrsComaCorrCalculator {
    -shared_ptr~SrsComaCorrDbBase~ corrDb
  }

  class SrsComaCorrDbBase
}

DlSrsBmManager *-- DlUeStatesHandler
DlSrsBmManager *-- DlSrsBmTimerHandler
DlSrsBmManager *-- DlSrsBmDataHandler
DlSrsBmManager *-- DlBeamSelection
DlSrsBmManager *-- DlSrsReceiveRespBmPsHandler

DlBeamSelection *-- DlBeamCalculatorManager
DlBeamCalculatorManager o-- "3" DlBeamBaseCalculator
DlSrsBmDataHandler o-- DlSrsBmUeDbBase
SrsBmUeDbDl --|> DlSrsBmUeDbBase
DlSrsBmDataHandler *-- SbSrsComaCorrCalculator
SbSrsComaCorrCalculator o-- SrsComaCorrDbBase
```

## 5. UL SRS BM

```mermaid
classDiagram
direction TB

namespace l2ps_srsBm_ul {
  class UlSrsBmManager {
    -SrsBmDataHandler srsBmDataHandler
    -BeamSelection ulSrsBmSelection
    -SrsBmTimerHandler srsBmTimerHandler
    -UeStatesHandler ueStatesHandler
  }

  class UlUeStatesHandler["UeStatesHandler"]

  class UlSrsBmTimerHandler["SrsBmTimerHandler"]

  class UlBeamSelection["BeamSelection"]

  class UlSrsReceiveRespBmPsHandler["SrsReceiveRespBmPsHandler"]

  class UlBeamCalculatorManager["BeamCalculatorManager"] {
    -unique_ptr~BeamBaseCalculator~ dlBeamCalculator
    -unique_ptr~BeamBaseCalculator~ dlTaperingBeamCalculator
  }

  class UlBeamBaseCalculator["BeamBaseCalculator"]

  class UlSrsBmDataHandler["SrsBmDataHandler"] {
    -shared_ptr~SrsBmUeDbBase~ srsBmUeDb
  }

  class UlSrsBmUeDbBase["SrsBmUeDbBase"]

  class SrsBmUeDbUl["SrsBmUeDbUl"]
}

UlSrsBmManager *-- UlUeStatesHandler
UlSrsBmManager *-- UlBeamSelection
UlSrsBmManager *-- UlSrsBmTimerHandler
UlSrsBmManager *-- UlSrsBmDataHandler
UlSrsBmManager *-- UlSrsReceiveRespBmPsHandler

UlBeamSelection *-- UlBeamCalculatorManager
UlBeamCalculatorManager o-- "2" UlBeamBaseCalculator
UlSrsBmDataHandler o-- UlSrsBmUeDbBase
SrsBmUeDbUl --|> UlSrsBmUeDbBase
```

## 6. DB Model

```mermaid
classDiagram
direction LR

namespace l2ps_srsBm_db {
  class SrsBmCell["cell.SrsBmCell"] {
    -CellInfoCommon common
    -DlBfInfoSrs dl
    -UlBfInfoSrs ul
  }

  class SrsBmCellDb["cell.SrsBmCellDb"] {
    -SrsBmCell srsBmCell
  }
}

SrsBmCellDb *-- SrsBmCell
```