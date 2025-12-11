## class diagram
```plantuml 
@startuml l2ps_srsbm

' skinparam linetype ortho
' skinparam linetype polyline
set namespaceSeparator ::

' ========================================
' Core Boost.SML Template
' ========================================
package boost {
  class "sml::sm<Table, ProcessQueue>" as BoostSm <<template>> {
    + process_event(event)
    + visit_current_states(visitor)
    + is(state) : bool
  }
}

' ========================================
' Common Package
' ========================================
namespace common {
  class "stateMachine::Fsm<SmlFsm>" as FsmTemplate <<template>> {
    - data : SmlFsm::Data
    - fsm : boost::sml::sm<SmlFsm::Table, std::queue>
    + processEvent(event)
  }

  class "emBase::EmFsmBase" as EmFsmBase {
    + processEvent(EmFsmEvent&) : virtual void
  }

  class "emBase::EmFsm<FsmImpl>" as EmFsmTemplate <<template>> {
    - fsm : stateMachine::Fsm<FsmImpl>
    --
    + processEvent(EmFsmEvent&) : virtual void
  }
  
  ' Template parameter relationships
  FsmTemplate o-l- BoostSm : <<bind>>\n<Table=SmlFsm::Table>
  EmFsmTemplate *-l- FsmTemplate : <<instantiate>>\nstateMachine::Fsm<FsmImpl>
  EmFsmTemplate -u-|> EmFsmBase
}

' ========================================
' L2PS Package
' ========================================
package l2ps {
  namespace srsBm {
    ' ========================================
    ' EM Namespace - FSM Implementation
    ' ========================================
    namespace em {
      ' FSM Implementation Structure
      class "QueueFsmImpl" as QueueFsmImpl <<template>> {
        {static} + Data : struct
        {static} + Table : struct
      }
      
      class "QueueFsmImpl::Data" as QueueFsmData <<concrete>> {
        + startupSrsBmHandler : QueueStateStartup
        + defaultSrsBmHandler : QueueStateDefault
        + deleteSrsBmHandler : QueueStateDelete
        --
        + Data(mainComponentSrsBm)
      }

      class "QueueStateStartup" as QueueStateStartup {
        + handleEvent()
      }
      
      class "QueueStateDefault" as QueueStateDefault {
        + handleEvent()
      }

      class "QueueStateDelete" as QueueStateDelete {
        + handleEvent()
      }

    
      class "QueueFsmImpl::Table" as QueueFsmTable <<concrete>> {
        + operator()() : auto
        --
        Transition table:
        * startUpState → defaultState
        * defaultState → deleteState
        * deleteState → startUpState
        * any state → X (on StopEvent)
      }

      ' Type Alias
      class "QueueFsm" as QueueFsm <<typedef>> {
        using QueueFsm = emBase::EmFsm<QueueFsmImpl>
      }

      class "Eo" as Eo {
        - fsm : QueueFsm
        - mainComponentSrsBm : std::shared_ptr<MainComponentSrsBm>
        - queue : ::common::emBase::EmQueue
        - queueSchTime : ::common::emBase::EmQueue
        --
        + start()
      }
    }

    ' ========================================
    ' Management Namespace
    ' ========================================
    namespace management {
      class "MainComponentSrsBm" as MainComponentSrsBm {
        - dlSrsBmManager : DlSrsBmManager
        - ulSrsBmManager : UlSrsBmManager
        - srsBmCellDb : db::SrsBmCellDb
      }
    }

    ' ========================================
    ' DB Namespace
    ' ========================================
    namespace db {
      class "cell::SrsBmCell" as SrsBmCell {
        - common : CellInfoCommon
        - dl : DlBfInfoSrs
        - ul : UlBfInfoSrs
      }
      
      class "cell::SrsBmCellDb" as SrsBmCellDb {
        - srsBmCell : SrsBmCell
      }
    }

    ' ========================================
    ' DL Namespace - Downlink SRS Beam Management
    ' ========================================
    namespace dl {
      class "DlSrsBmManager" as DlSrsBmManager {
        - srsBmDataHandler : SrsBmDataHandler
        - dlSrsBmSelection : BeamSelection
        - srsBmTimerHandler : SrsBmTimerHandler
        - ueStatesHandler : UeStatesHandler
        - srsReceiveRespBmPsHandler : SrsReceiveRespBmPsHandler
      }
      
      class "UeStatesHandler" as DlUeStatesHandler
      class "SrsBmTimerHandler" as DlSrsBmTimerHandler
      class "BeamSelection" as DlBeamSelection
      class "SrsReceiveRespBmPsHandler" as DlSrsReceiveRespBmPsHandler
      
      class "BeamCalculatorManager" as DlBeamCalculatorManager {
        - dlBeamCalculator : std::unique_ptr<BeamBaseCalculator>
        - dlTaperingBeamCalculator : std::unique_ptr<BeamBaseCalculator>
        - lbMMimoPowerSavingDlSrsBmCalculator : std::unique_ptr<BeamBaseCalculator>
      }

      class "BeamBaseCalculator" as DlBeamBaseCalculator
      
      class "SrsBmDataHandler" as DlSrsBmDataHandler {
        - srsBmUeDb : std::shared_ptr<SrsBmUeDbBase>
        - corrCalculator : SbSrsComaCorrCalculator
      }
      
      class "SrsBmUeDbBase" as DlSrsBmUeDbBase <<typedef>>
      class "<font color=red>SrsBmUeDbDl</font>" as SrsBmUeDbDl
      
      class "SbSrsComaCorrCalculator" as SbSrsComaCorrCalculator {
        - corrDb : std::shared_ptr<SrsComaCorrDbBase>
      }
      
      class "SrsComaCorrDbBase" as SrsComaCorrDbBase
    }

    ' ========================================
    ' UL Namespace - Uplink SRS Beam Management
    ' ========================================
    namespace ul {
      class "UlSrsBmManager" as UlSrsBmManager {
        - srsBmDataHandler : UlSrsBmDataHandler
        - ulSrsBmSelection : UlBeamSelection
        - srsBmTimerHandler : UlSrsBmTimerHandler
        - ueStatesHandler : UeStatesHandler
      }
      
      class "UeStatesHandler" as UlUeStatesHandler
      class "SrsBmTimerHandler" as UlSrsBmTimerHandler
      class "BeamSelection" as UlBeamSelection
      class "SrsReceiveRespBmPsHandler" as UlSrsReceiveRespBmPsHandler
      
      class "BeamCalculatorManager" as UlBeamCalculatorManager {
        - dlBeamCalculator : std::unique_ptr<BeamBaseCalculator>
        - dlTaperingBeamCalculator : std::unique_ptr<BeamBaseCalculator>
      }
      
      class "BeamBaseCalculator" as UlBeamBaseCalculator
      
      class "SrsBmDataHandler" as UlSrsBmDataHandler {
        - srsBmUeDb : std::shared_ptr<SrsBmUeDbBase>
      }
      
      class "SrsBmUeDbBase" as UlSrsBmUeDbBase
      class "<font color=red>SrsBmUeDbUl</font>" as SrsBmUeDbUl
    }


    ' em Relationships
    QueueFsmImpl +-d- QueueFsmData : nested
    QueueFsmImpl +-d- QueueFsmTable : nested

    QueueFsmData *-u- QueueStateStartup
    QueueFsmData *-u- QueueStateDefault
    QueueFsmData *-u- QueueStateDelete

    QueueFsm -u-|> EmFsmTemplate : <<bind>>\n<FsmImpl=QueueFsmImpl>
    QueueFsm .r.> QueueFsmImpl : <<template arg>>

    Eo *-u- QueueFsm

    ' DL Relationships
    DlSrsBmManager *-d- DlUeStatesHandler
    DlSrsBmManager *-d- DlSrsBmTimerHandler
    DlSrsBmManager *-d- DlSrsBmDataHandler
    DlSrsBmManager *-d- DlBeamSelection
    DlSrsBmManager *-d- DlSrsReceiveRespBmPsHandler

    ' UL Relationships
    UlSrsBmManager *-l- UlUeStatesHandler
    UlSrsBmManager *-d- UlBeamSelection
    UlSrsBmManager *-d- UlSrsBmTimerHandler
    UlSrsBmManager *-d- UlSrsBmDataHandler
    UlSrsBmManager *-d- UlSrsReceiveRespBmPsHandler
    UlBeamSelection *-d- UlBeamCalculatorManager
    UlBeamCalculatorManager o-d-"2" UlBeamBaseCalculator
    UlSrsBmDataHandler o-d- UlSrsBmUeDbBase
    SrsBmUeDbUl -u-|> UlSrsBmUeDbBase

    ' db relation
    SrsBmCellDb *-l- SrsBmCell

    ' ========================================
    ' Cross-namespace Relationships
    ' ========================================
    Eo o-d- MainComponentSrsBm
    MainComponentSrsBm *-d- UlSrsBmManager
    MainComponentSrsBm *-d- DlSrsBmManager
    MainComponentSrsBm *-u- SrsBmCellDb

    DlBeamSelection *-d- DlBeamCalculatorManager
    DlBeamCalculatorManager o-d-"3" DlBeamBaseCalculator
    DlSrsBmDataHandler o-d- DlSrsBmUeDbBase
    SrsBmUeDbDl -u-|> DlSrsBmUeDbBase
    DlSrsBmDataHandler *-d- SbSrsComaCorrCalculator
    SbSrsComaCorrCalculator o-d- SrsComaCorrDbBase
  }
}

@enduml