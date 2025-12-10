# DL FD Scheduler

```plantuml
title L2PS Dl FD Scheduler

box "dl::sch" #LightGray
    participant "MainComponent" as DlMainComponent
end box

box dl::sch::fd #Lavender
    participant "MainComponent" as MainComponent
    participant "Scheduler" as Scheduler
    participant "SibScheduler" as SibScheduler
    participant "PagingScheduler" as PagingScheduler
    participant "UeScheduler" as UeScheduler
    participant "Xpdcch" as Xpdcch
    participant "Msg2Scheduler" as Msg2Scheduler
    participant "NewTxScheduler" as NewTxScheduler
    participant "ReTxScheduler" as ReTxScheduler
    participant "TbSizeCalculation" as TbSizeCalculation
end box

participant "L2-LO" as L2LO
participant "L1-DU" as L1DU

DlMainComponent --> MainComponent: internal::FdScheduleReq
group processFdScheduleReq()
    group postProcessFdScheduler()
        loop each subcell
            MainComponent -> Scheduler: schedule()
            Scheduler -> SibScheduler: scheduleSib()
            Scheduler -> PagingScheduler: schedulePaging()        
            Scheduler -> UeScheduler: scheduleUes()
            loop each scheduled UE
                alt not isRaMsg2TxPending
                    alt newTx
                        UeScheduler -> NewTxScheduler: scheduleNewTx()
                        NewTxScheduler -> TbSizeCalculation: calculateTbs()
                    else
                        UeScheduler -> ReTxScheduler: prepareReTxScheduling()
                        UeScheduler -> ReTxScheduler: scheduleReTx()
                    end
                else
                    UeScheduler -> Msg2Scheduler: scheduleMsg2()
                end
            end
        end
    end
    MainComponent -> MainComponent: updatePdschPrbUsed()
    MainComponent -> MainComponent: sendFdScheduleResp()
end

MainComponent --> DlMainComponent: internal::FdScheduleResp
```




