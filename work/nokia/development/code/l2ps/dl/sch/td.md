# DL TD Scheduler

```plantuml
title L2PS DL TD Scheduler

skinparam {
    defaultFontSize 18
    SequenceDividerFontSize 24
    SequenceDividerFontStyle bold
}

participant Platform as Platform

box "dl::sch" #LightGray
    participant "MainComponent" as DlMainComponent
    participant "SlotHandler" as DlSlotHandler
    participant "bfgroup::Scheduler" as DlBfGroupScheduler
    participant "bfgroup::CsiSrScheduler" as DlBfGroupCsiSrScheduler
end box

box "dl::sch::pre" #PowderBlue
    participant "Scheduler" as DlPreScheduler
end box

box "dl::sch::td" #LightBlue
    participant "Scheduler" as DlTdScheduler
    participant "PfMetricDl" as DlTdPfMetricDl
    participant "CarrierScheduler" as DlTdCarrierScheduler
    participant "FdScheduleRespHandler" as DlTdFdScheduleRespHandler
    participant "CommonChannelScheduler" as DlTdCommonChannelScheduler
end box

box pscommon::sch::td #LightSkyBlue
    participant "FdSchedulerProxy" as FdSchedulerProxy
end box


box pscommon::sch::fdm #Moccasin
    participant "Scheduler" as FdmScheduler
end box

box dl::sch::fdm #PeachPuff
    participant "UeSelector" as DlFdmUeSelector
    participant "Scheduler" as DlFdmScheduler
end box

box dl::sch::muMimoEnhance #NavajoWhite
    participant "MuEnhScheduler" as DlFdmMuEnhScheduler
end box

box dl::sch::fd #Lavender
    participant "MainComponent" as DlFdMainComponent
    participant "Scheduler" as DlFdScheduler
end box

Platform --> DlMainComponent: SlotSynchroInd
activate DlMainComponent
group handle(SlotSynchroInd)
    DlMainComponent -> DlSlotHandler: run()
    DlSlotHandler -> DlBfGroupScheduler: scheduleRs()
    DlSlotHandler -> DlBfGroupScheduler: updateCs1ListWithEvents()
    DlBfGroupScheduler -> DlPreScheduler: updateCs1ListWithEvents()
    group scheduleBySlotTypeMode()
        alt SSB Slot
            DlSlotHandler -> DlBfGroupScheduler: scheduleSsBurst()
        end

        alt (DL Slot) or (Pdsch active on SSB Slot)
            note over DlSlotHandler, DlPreScheduler
                **PRE scheduling**
            end note           
            DlSlotHandler -> DlBfGroupScheduler: schedule()
            DlBfGroupScheduler -> DlPreScheduler: schedule()
            DlPreScheduler -> DlPreScheduler: buildCs1List()

            note over DlBfGroupScheduler, DlTdCarrierScheduler
                **TD scheduling**
            end note        
            DlBfGroupScheduler -> DlTdScheduler: schedule()
            DlTdScheduler -> DlTdPfMetricDl: computePfMetric()
            group scheduleCarriers()
                DlTdScheduler -> DlTdCarrierScheduler: initBeforeScheduling()
                DlTdCarrierScheduler -> DlTdCarrierScheduler: buildCs2Lists()
                note over DlTdScheduler, DlFdmMuEnhScheduler
                    **FDM scheduling**
                end note
                DlTdScheduler -> DlTdCarrierScheduler: scheduleCarriers()
                DlTdCarrierScheduler -> FdmScheduler: schedule()
                    group scheduleUesInCs2()
                        group selectUes()
                            loop Ue in Cs2ist
                                FdmScheduler -> DlFdmUeSelector: selectUe()
                            end
                        end
                        
                        group distributeResources()
                            FdmScheduler -> DlFdmScheduler: distributeResources()
                        end

                        group allocateResources()
                            FdmScheduler -> DlFdmScheduler: doMuMimoEnhanceSchedule()
                            DlFdmScheduler -> DlFdmMuEnhScheduler: schedule()
                            DlFdmScheduler -> DlFdmMuEnhScheduler: calculateMuCorrCqi()
                        end
                    end
                DlTdCarrierScheduler -> FdSchedulerProxy: schedule()
                FdSchedulerProxy -> FdSchedulerProxy: scheduleFdEo()
            end
        end
    end
    
    DlSlotHandler -> DlBfGroupScheduler: scheduleAloneSrAndPerCsiReport()
    DlBfGroupScheduler -> DlBfGroupCsiSrScheduler: schedule()    
    deactivate DlMainComponent
end

FdSchedulerProxy --> DlFdMainComponent: internal::FdScheduleReq
activate DlFdMainComponent
note over DlFdMainComponent, DlFdScheduler
    **FD scheduling**
end note
group processFdScheduleReq()
    group postProcessFdScheduler()
        loop each subcell
            DlFdMainComponent -> DlFdScheduler: schedule()
        end
    end
    DlFdMainComponent -> DlFdMainComponent: updatePdschPrbUsed()
    DlFdMainComponent -> DlFdMainComponent: sendFdScheduleResp()
end
deactivate DlFdMainComponent

DlFdMainComponent --> DlMainComponent: internal::FdScheduleResp
note over DlMainComponent, DlTdCommonChannelScheduler
    **Post scheduling**
end note
activate DlMainComponent
group handleAllFdSchedulerResp()
    DlMainComponent -> DlBfGroupScheduler: handle()
    DlBfGroupScheduler -> DlTdScheduler: handle()
    DlTdScheduler -> DlTdFdScheduleRespHandler: handleFdScheduleResp()
    DlTdFdScheduleRespHandler -> DlTdCommonChannelScheduler: schedulePdcch()
    DlTdFdScheduleRespHandler -> DlTdFdScheduleRespHandler: postProcessFdScheduleResp()
    DlTdFdScheduleRespHandler -> DlTdCommonChannelScheduler: schedulePucch()
    DlMainComponent -> DlSlotHandler: postRun()
    DlSlotHandler -> DlBfGroupScheduler: postSchedule()
    DlBfGroupScheduler -> DlPreScheduler: postSchedule()
    DlBfGroupScheduler -> DlTdScheduler : postSchedule()
    DlTdScheduler -> DlTdScheduler: processScheduledUes()
    DlTdScheduler -> DlTdCarrierScheduler: postSchedule()
end
deactivate DlMainComponent
```



