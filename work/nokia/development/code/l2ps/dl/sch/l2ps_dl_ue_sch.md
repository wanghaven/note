
```plantuml
' skinparam linetype polyline
' left to right direction
set namespaceSeparator ::

namespace pscommon {
    class emBase::EmFsm {}
    class emBase::EmQueue {}

    class sch::Cs1List {
        -std::vector<itf::Rnti> cs1List
        -PriorityLists priorityLists
    }
    
    emBase::EmFsm -[hidden]- emBase::EmQueue
    emBase::EmQueue -[hidden]- sch::Cs1List    
}

namespace dl {
    namespace db {
        class UeDb {}
        class CellDb {}
        UeDb -[hidden]- CellDb
    }
}

namespace dl::uegroup {
    class Eo {
        -EmQueue queueSchTime
        -EmFsmRouterWithDelay router
        -MainComponent mainComponent
    }

    /' single main component '/
    class sch::MainComponent {
        -SlotHandler slotHandler
        +handle(SlotSynchroInd)
    }

    /' single slot handler '/
    class sch::SlotHandler {
        -cell::Scheduler scheduler

        +schedule(SlotSynchroInd&)
    }

    /' cell specific scheduler '/
    class sch::cell::Scheduler {
        -SchedulerDb schedulerDb
        +schedule()
    }

    class sch::cell::SchedulerDb {            
        -const db::Celldb* cellDbPtr
        -const db::UeDb* ueDbPtr
        -CandidateSets candidateSets
    }

    class sch::cell::CandidateSets {
        -Cs1List cs1List
        -Cs2List cs2List
    }

    class sch::cell::Cs1List {}
    class sch::cell::Cs2List {}

    /' cell specific pre scheduler '/
    class sch::cell::pre::Scheduler { 
        -SchedulerDb& schedulerDb
        -Cs1ListDecision cs1ListDecision
        +schedule()
    }
    
    class sch::cell::Cs1ListDecision {
        -Cs1List& cs1List
        -Notifications checkUeForUpdateQueue
    }

    /' cell specific TD scheduler '/
    class sch::cell::td::Scheduler {
        -SchedulerDb& schedulerDb

        +schedule()
    }

    Eo *-d- sch::MainComponent
    sch::MainComponent *-r- sch::SlotHandler
    sch::SlotHandler *-- "1" sch::cell::Scheduler

    sch::cell::Scheduler *-- sch::cell::pre::Scheduler
    sch::cell::Scheduler *-- sch::cell::SchedulerDb
    sch::cell::Scheduler *-l- sch::cell::td::Scheduler

    sch::cell::pre::Scheduler o-r- sch::cell::SchedulerDb
    sch::cell::td::Scheduler o-l- sch::cell::SchedulerDb


    sch::cell::SchedulerDb *-- sch::cell::CandidateSets
    sch::cell::pre::Scheduler *-- sch::cell::Cs1ListDecision

    sch::cell::CandidateSets *-- sch::cell::Cs1List
    sch::cell::CandidateSets *-- sch::cell::Cs2List
    sch::cell::Cs1ListDecision o-- sch::cell::Cs1List
}

dl::uegroup::sch::cell::SchedulerDb o-r- dl::db::UeDb
dl::uegroup::sch::cell::SchedulerDb o-r- dl::db::CellDb 
dl::uegroup::Eo *-l- pscommon::emBase::EmQueue
dl::uegroup::Eo *-l- pscommon::emBase::EmFsm

dl::uegroup::sch::cell::Cs1List --> pscommon::sch::Cs1List
```

