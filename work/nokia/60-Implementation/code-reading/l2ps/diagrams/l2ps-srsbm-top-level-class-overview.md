---
title: L2PS SRS-BM Top-Level Class Overview
date: 2026-06-11
tags:
  - L2PS SRS-BM Top-Level Class Overview
  - l2ps
  - code-reading
status: draft
last_verified_src_date: '2026-06-11'
last_verified_gnb_git: '45617cfb9a73'
aliases:
  - L2PS SRS-BM Top-Level Class Overview
---

# L2PS SRS-BM Top-Level Class Overview

Verified against `srsBm/em/Eo.hpp` and `srsBm/management/MainComponentSrsBm.hpp` under `/workspace/uplane/L2-PS/src/`. The `MainComponentSrsBm` box lists the main composition edges used in coordination diagrams; additional private timing/state fields exist in the header.

```plantuml
@startuml L2PS SRS-BM Top-Level Class Overview
!pragma graphviz svg
' scale 1920*1080

' skinparam linetype ortho
set namespaceSeparator ::
skinparam classAttributeIconSize 0
skinparam packageStyle rectangle

package l2ps_srsBm_em {
  class Eo {
    -EmQueue queue
    -EmQueue queueSchTime
    -EmQueueDbItem queueDbItem
    -EmQueueDbItem queueDbItemSchTime
    -shared_ptr~MainComponentSrsBm~ mainComponentSrsBm
    -QueueFsm fsm
    +start() EmStatus
    +stop() EmStatus
    +init() bool
  }
  class QueueFsm {
    <<typedef>>
    EmFsm~QueueFsmImpl~
  }
}
package l2ps_srsBm_management {
  class MainComponentSrsBm {
    -SlotConfiguration slotConfiguration
    -SrsBmCellDb srsBmCellDb
    -DlSrsBmManager dlSrsBmManager
    -UlSrsBmManager ulSrsBmManager
    -SlotSynchroManager synchro5GTimeManager
    -Timer750UsController timer750UsController
    -Maybe~ProcessingTimingPatternFacade~ processingTimingPattern
    -TickSlotFacade tickSlotFacade
    -SrsBmSlotMeasurements srsBmSlotMeasurements
    -MeasurementSlotTrigger measurementSlotTrigger
    -SlotSynchroIndContHandler slotSynchroIndContHandler
    -SlotTypeSelectorBase* slotTypeSelectorPtr
    +handleCellSetupReq(msg)
    +handleStartSlotSynchroInd(msg)
    +handleSlotSynchroInd(msg)
    +handleSlotSynchroIndCont(msg)
    +handleSrsReceiveRespBmPs(event)
    +handleUlToSrsSlotTypeSync(msg)
  }
  class SlotSynchroIndContHandler
  class MeasurementSlotTrigger
  class SrsBmSlotMeasurements
}
package l2ps_srsBm_db {
  class SrsBmCellDb
  class SrsBmCell
}
package l2ps_srsBm_dl {
  class DlSrsBmManager
}
package l2ps_srsBm_ul {
  class UlSrsBmManager
}
Eo *-- QueueFsm
Eo o-- MainComponentSrsBm
MainComponentSrsBm *-- SrsBmCellDb
SrsBmCellDb *-- SrsBmCell
MainComponentSrsBm *-- DlSrsBmManager
MainComponentSrsBm *-- UlSrsBmManager
MainComponentSrsBm *-- SrsBmSlotMeasurements
MainComponentSrsBm *-- MeasurementSlotTrigger
MainComponentSrsBm *-- SlotSynchroIndContHandler
SlotSynchroIndContHandler --> DlSrsBmManager
SlotSynchroIndContHandler --> UlSrsBmManager
SlotSynchroIndContHandler --> SrsBmCell
@enduml
```
