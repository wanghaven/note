## class diagram
```plantuml 
@startuml l2ps_srsbm
skinparam linetype ortho
skinparam linetype polyline
set namespaceSeparator ::

!QueueFsmName = "common::emBase::EmFsm<QueueFsmImpl> "
!CommonFsmName = "common::stateMachine::Fsm<SmlFsm> "
!QueFsmData = "QueueFsmImpl::Data "

package l2ps::srsBm{
    namespace dl{
        class DlSrsBmManager 
        {
            -SrsBmDataHandler srsBmDataHandler
            -BeamSelection dlSrsBmSelection
            -SrsBmTimerHandler srsBmTimerHandler
            -UeStatesHandler ueStatesHandler
            -SrsReceiveRespBmPsHandler srsReceiveRespBmPsHandler
        }
        class UeStatesHandler
        class SrsBmTimerHandler
        class BeamSelection
        class SrsReceiveRespBmPsHandler
        class BeamCalculatorManager
        {
            -std::unique_ptr<BeamBaseCalculator> dlBeamCalculator
            -std::unique_ptr<BeamBaseCalculator> dlTaperingBeamCalculator
            -std::unique_ptr<BeamBaseCalculator> lbMMimoPowerSavingDlSrsBmCalculator
        }

        class BeamBaseCalculator
        class SrsBmDataHandler 
        {
            -std::shared_ptr<SrsBmUeDbBase> srsBmUeDb
            -SbSrsComaCorrCalculator corrCalculator
        }
        class SrsBmUeDbBase 
        class "<font color=red>SrsBmUeDbDl</font>" as SrsBmUeDbDl
        class SbSrsComaCorrCalculator
        {
            -std::shared_ptr<SrsComaCorrDbBase> corrDb
        }
        class SrsComaCorrDbBase

        DlSrsBmManager *-l- UeStatesHandler
        DlSrsBmManager *-- BeamSelection
        DlSrsBmManager *-- SrsBmTimerHandler
        DlSrsBmManager *-- SrsBmDataHandler            
        DlSrsBmManager *-r- SrsReceiveRespBmPsHandler

        BeamSelection *-- BeamCalculatorManager
        BeamCalculatorManager o--"3" BeamBaseCalculator
        SrsBmDataHandler o-- SrsBmUeDbBase
        SrsBmUeDbDl -u-|> SrsBmUeDbBase
        SrsBmDataHandler *-- SbSrsComaCorrCalculator
        SbSrsComaCorrCalculator o-- SrsComaCorrDbBase
    }

    namespace ul{
        class UlSrsBmManager
        {
            -SrsBmDataHandler srsBmDataHandler
            -BeamSelection ulSrsBmSelection
            -SrsBmTimerHandler srsBmTimerHandler
            -UeStatesHandler ueStatesHandler
            -SrsReceiveRespBmPsHandler srsReceiveRespBmPsHandler            
        }
        class UeStatesHandler
        class SrsBmTimerHandler
        class BeamSelection
        class SrsReceiveRespBmPsHandler
        class BeamCalculatorManager
        {
            -std::unique_ptr<BeamBaseCalculator> dlBeamCalculator
            -std::unique_ptr<BeamBaseCalculator> dlTaperingBeamCalculator
        }
        class BeamBaseCalculator
        class SrsBmDataHandler 
        {
            -std::shared_ptr<SrsBmUeDbBase> srsBmUeDb
        }
        class SrsBmUeDbBase
        class "<font color=red>SrsBmUeDbUl</font>" as SrsBmUeDbUl
        
        UlSrsBmManager *-l- UeStatesHandler
        UlSrsBmManager *-- BeamSelection
        UlSrsBmManager *-- SrsBmTimerHandler
        UlSrsBmManager *-- SrsBmDataHandler            
        UlSrsBmManager *-r- SrsReceiveRespBmPsHandler
        BeamSelection *-- BeamCalculatorManager
        BeamCalculatorManager o--"2" BeamBaseCalculator
        SrsBmDataHandler o-- SrsBmUeDbBase
        SrsBmUeDbUl -u-|> SrsBmUeDbBase
    }

    namespace db {
        class "<font color=red>SrsBmCellDb</font>" as SrsBmCellDb
    }

    class Eo
	{
        -QueueFsmName fsm
        -std::shared_ptr<MainComponentSrsBm> mainComponentSrsBm
        -::common::emBase::EmQueue queue;
        -::common::emBase::EmQueue queueSchTime;

        start() {queue.setQueueState(fsm); queueSchTime.setQueueState(fsm)} 'set fsm as queue context'
    }

    class QueueFsm as "QueueFsmName" 
    {
        -CommonFsmName fsm
    }

    class MainComponentSrsBm
    {
        -DlSrsBmManager dlSrsBmManager
        -UlSrsBmManager ulSrsBmManager
        -db::SrsBmCellDb srsBmCellDb    
    }

    Eo *-u- QueueFsm 
    Eo o-r- MainComponentSrsBm 
    MainComponentSrsBm *-u- db::SrsBmCellDb
    MainComponentSrsBm *-d- ul::UlSrsBmManager
    MainComponentSrsBm *-d- dl::DlSrsBmManager
    
    namespace common{
        class SrsBmManager            
        class SrsBmDataHandler
        class SrsBmTimerHandler 
        class SrsBeamCalculator
        class SrsBmUeDb<typename T> 
        class SrsBmMath
        abstract SrsBmUeDbBase

        SrsBmManager *.. SrsBmUeDbBase
        SrsBmManager *.. SrsBmDataHandler
        SrsBmManager *.. SrsBmTimerHandler
        SrsBmUeDb -[#Navy]-|> SrsBmUeDbBase            
    }

    dl::DlSrsBmManager --[#Navy]-|> common::SrsBmManager
    dl::DlSrsBmUeDb --[#Navy]-|> common::SrsBmUeDb
    dl::SrsBmDataHandler --[#Navy]-|> common::SrsBmDataHandler
    dl::SrsBmTimerHandler --[#Navy]-|> common::SrsBmTimerHandler
    dl::DlSrsBeamCalculator --[#Navy]-|> common::SrsBeamCalculator

    ul::UlSrsBmManager --[#Navy]-|> common::SrsBmManager
    ul::UlSrsBmUeDb --[#Navy]-|> common::SrsBmUeDb
    ul::UlSrsBmDataHandler --[#Navy]-|> common::SrsBmDataHandler
    ul::UlSrsBmTimerHandler --[#Navy]-|> common::SrsBmTimerHandler
    ul::UlSrsBeamCalculator --[#Navy]-|> common::SrsBeamCalculator

    class Fsm as "CommonFsmName"
	{
        -SmlFsm::Data data
    }    

    struct FsmData as "QueFsmData"
	{
        -QueueStateStartup startupSrsBmHandler
        -QueueStateDefault defaultSrsBmHandler
        -QueueStateDelete deleteSrsBmHandler
    }

    class QueueStateStartup
    {
        -std::shared_ptr<>& mainComponentSrsBm
        +handleCellSetupReq() #construct share_ptr mainComponentSrsBm
    }

    Eo o-u- QueueStateStartup
    QueueFsm *-r- Fsm
    Fsm *-r- FsmData
    FsmData *-r- QueueStateStartup
    QueueStateStartup -d-> MainComponentSrsBm
}
@enduml