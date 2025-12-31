## System Architecture
### High-Level Data Flow
```plantuml
@startuml
rectangle "**L1-UL**" as L1 {
  rectangle "**SRS Receiption**:\nStore channel matrix H (2 PRB granularity)\nCalculate UE-UE correlation: corr(UE_i, UE_j) " as SrsReception
}

rectangle "L2-PS Scheduler" as L2 {
  rectangle "**HandleSrsRtBfPsUeCorrelation**:\nUpdate correlation table" as SrsRespHandler

  rectangle "Post (Slot N)" as POST {
    rectangle "**buildPairingGroups()**\nGroup UEs with Low correction\nMax 4 groups, max 4 UEs per group" as buildPG
  }
  rectangle "PRE (Slot N+1)" as PRE {
    rectangle "**selectUeToBoostPriority()**\nSelect all UEs from each group to CS1List\nUse token buckets for fairness" as SelectUe
  }    
  rectangle "TD (Slot N+1)" as TD {
    rectangle "**updatePairGroupUeSubPriorit()**\nApply priority boost" as UpdateSubPriority
  }
  rectangle "FDM (Slot N+1)" as FDM {
    rectangle "**generateVirtualUes()**\nGenerate MU VUEs" as GenVitualUe
  }
  
  SelectUe -[hidden]l- UpdateSubPriority
  UpdateSubPriority -[hidden]l- GenVitualUe
}
SrsReception -d-> SrsRespHandler : SrsReceiveRespRtBfPs (ueCorrelation(i, j))
SrsRespHandler -d-> buildPG
buildPG -d-> SelectUe
SelectUe -r-> UpdateSubPriority
UpdateSubPriority -r-> GenVitualUe

@enduml
```
### Component Diagram
```plantuml
@startuml
skinparam classAttributeIconSize 0

package "CellDynamicData" {

  class "**PairingGroupHandler**" as PairingGroupHandler {
    --
    +buildPairingGroups()
    +updateCorrelation()
    +getGroupByRnti(rnti)
  }

  class PairingGroupData {
    +pairUeList : vector<Rnti>
    +tokenBucket : uint8_t
    --
    +isEmpty() : bool
  }

  class PairingGroupArray {
    pairingGroup[4]
  }

  PairingGroupArray "1" *-- "4" PairingGroupData

  class SrsRtBfUeCorrelationTable {
    +getCorrelation(rnti1, rnti2) : float
  }

  class CorrelationEntry {
    +avgCorrelation : float
    +invalidCount : uint8_t
  }

  SrsRtBfUeCorrelationTable "1" *-- "32x32 (lower triangle)" CorrelationEntry

  class HighBufferSbBfUeList {
    unordered_set<Rnti>
  }

  PairingGroupHandler *-- PairingGroupArray
  PairingGroupHandler *-- SrsRtBfUeCorrelationTable
  PairingGroupHandler *-- HighBufferSbBfUeList
}

class PairingGroupUeSelector <<PRE Phase>> {
  +selectUeToBoostPriority()
  +selectNormalBoostPGUe()
  +selectHighPriorityBoostPGUe()
}

class Rat1ZfVirtualUeGenerator <<FDM Phase>> {
  +generateVirtualUes()
  +buildVirtualByRootUe()
  +copyZfMuUeFromCandidateList()
}

PairingGroupUeSelector ..> PairingGroupHandler : uses
Rat1MuMimoExhaustiveScheduler ..> PairingGroupHandler : consumes PG info

@enduml
```
## Integration to scheduling phase
### POST
**Function:** `PairingGroupHandler::buildPairingGroups()`

***Source code:***
```cpp
void PairingGroupHandler::buildPairingGroups(const l2ps::utils::Xsfn& currentXsfn)
{
    ...
    for (auto it = highBufferSbBfUeList().begin(); it != highBufferSbBfUeList().end();) // N: number of SB-BF users
    {
        ...
        if (tryAddCandidate(it->key.getUeDataRef(), isLastCandidate))
        {
            it = highBufferSbBfUeList().erase(it);
        }
        else
        {
            ++it;
        }
    }
    clearSingleUeGroups();
    processGroupsWithTwoUes(currentXsfn);
}

bool PairingGroupHandler::tryAddCandidate(const std::reference_wrapper<Ue>& ueDataRef, bool isLastCandidate)
{
    for (auto& pairGroupIndexInfo : pairGroupIndexArray) // G: Number of PairGroup
    {
        ...
        if (group.addUe(ueDataRef, srsRtBfUeCorrelationTable(), dlMuMimoZfCorrThd))
        {
            ...
            return true;
        }
    }
    return false;
}

bool PairingGroupData::addUe(
    const UeDataRef& ueDataRef,
    SrsRtBfUeCorrelationTable& srsRtBfUeCorrelationTable,
    float dlMuMimoZfCorrThd,
    bool needCheckCorrelation)
{
    ...
    if (needCheckCorrelation and
        not checkCorrelationWithExistingUes<true>(newAddUe, srsRtBfUeCorrelationTable, dlMuMimoZfCorrThd)) // U: Max 4 UEs per Group
    {
        return false;
    }
    ...
    return true;
}
```
**Algorithm:**
1. Clear existing groups
2. For each candidate UE in `highBufferSbBfUeList`:
   - Try to add UE to existing group (correlation check)
   - If no suitable group, create new group (max 4 groups)
3. Consolidate 2-UE groups (merge or keep separate based on correlation)
4. Update token buckets for each group

**Complexity:** O(N × G × C)
- N = number of SB-BF UEs
- G = number of groups (4)
- C = correlation checks (2-3 per UE)

### PRE
**Function:** `PairingGroupUeSelector::selectUeToBoostPriority()`
***Source code***:
```cpp
uint8_t PairingGroupUeSelector::selectUeToBoostPriority(
    uint8_t cs1ListSize,
    const BuildCs1Args& buildCs1Args,
    BoostUeVector& boostUeVec,
    const Cs1UeRntiVec& retxUeRntis,
    const Cs1UeRntiVec& dlMacCeUeRntis,
    const bool rdDlZfMuDisableRankDowngrade)
{
    ...
    auto success = [&](auto& cellConfigData, auto& cellDynamicData)
    {
        auto maxNumUeToBoost = std::min(buildCs1Args.cs1ListMaxSize, buildCs1Args.avgSchedUeNum);
        if (cellConfigData.cellParams().mimoConfigData().dlMuMimoEnhConfig().actDlMuPairingGroup() and
            maxNumUeToBoost > cs1ListSize)
        {
            ...
            realBoostUeNum = selectBoostUeForScheduling(
                cellDynamicData.specific().pairingGroupHandler().pairingGroupArray(),
                boostUeNum,
                cellConfigData.cellParams(),
                buildCs1Args.xsfn,
                boostUeVec,
                retxUeRntis,
                dlMacCeUeRntis,
                rdDlZfMuDisableRankDowngrade);
        }
    };
    db::CellDb::db().forVotedCell(buildCs1Args.nrCellGrpId, std::move(success));
    return realBoostUeNum;
}

uint8_t PairingGroupUeSelector::selectBoostUeForScheduling(
    PairingGroupArray& pairingGroupArray,
    const uint32_t boostUeNum,
    const l2ps::db::Cell& cellParams,
    const l2ps::utils::Xsfn& xsfn,
    BoostUeVector& boostUeVec,
    const Cs1UeRntiVec& retxUeRntis,
    const Cs1UeRntiVec& dlMacCeUeRntis,
    const bool rdDlZfMuDisableRankDowngrade)
{
    ...

    if (pscommon::radParams::RadParamsBase::db().rdDlZfMuSupportReTx())
    {
        selectHighPriorityBoostPGUe(pairingGroupArray, xsfn, retxUeRntis, true, boostUeNum, boostUeParams, boostUeVec);
        selectHighPriorityBoostPGUe(
            pairingGroupArray, xsfn, dlMacCeUeRntis, false, boostUeNum, boostUeParams, boostUeVec);
    }

    auto realBoostUeNum = selectNormalBoostPGUe(pairingGroupArray, boostUeNum, boostUeParams, boostUeVec);
    logPairGroupUeList(boostUeParams.inputPGUeList, boostUeVec);
    return realBoostUeNum;
}

uint8_t PairingGroupUeSelector::selectNormalBoostPGUe(
    PairingGroupArray& pairingGroupArray,
    const uint32_t boostUeNum,
    BoostUeParameters& boostUeParams,
    BoostUeVector& boostUeVec)
{
    const uint32_t totalSize = getPairingGroupUeNumber(pairingGroupArray);
    uint8_t maxIndex = getMaxTokenBucketIndex(pairingGroupArray, boostUeParams.pairingGroupBitFlag);
    for (uint8_t index = 0; index < pairingGroupArray.size() and (boostUeVec.empty()) and
         (maxIndex != l2ps::dl::db::maxPairingGroupNumber);
         ++index)
    {
        boostUeParams.pairingGroupBitFlag.set(maxIndex);
        if (pushUeToBoostUeVec(pairingGroupArray[maxIndex], boostUeNum, boostUeParams, boostUeVec))
        {
            updateTokenForPairingGroup(pairingGroupArray, maxIndex, static_cast<uint8_t>(totalSize));
        }
        maxIndex = getMaxTokenBucketIndex(pairingGroupArray, boostUeParams.pairingGroupBitFlag);
    }
    auto realBoostUeNum = static_cast<uint8_t>(boostUeVec.size());
    boostUeVec.insert(boostUeVec.end(), boostUeParams.nonBoostUeVec.begin(), boostUeParams.nonBoostUeVec.end());
    if (maxIndex != l2ps::dl::db::maxPairingGroupNumber)
    {
        pushNonBoostUeToVec(pairingGroupArray, boostUeParams, maxIndex + 1, boostUeVec);
    }
    return realBoostUeNum;
}
```
