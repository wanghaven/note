# L1 timing window definitions:
## Requirement
### [TDD FR1](https://dn-prod.ext.net.nokia.com/rm/resources/BI_YWv-4F5EEfCLrcnPCspVyQ?oslc_config.context=https://dn-prod.ext.net.nokia.com/gc/configuration/9)
#### Request messages: 

| Message                      | Transmission Window (L2)            |                                     | Reception Window (L1) |             |
| ---------------------------- | ----------------------------------- | ----------------------------------- | --------------------- | ----------- |
|                              | A [us]                              | B [us]                              | A’ [us]               | B’ [us]     |
| UlData_PucchReceiveReq       | (pucchSlotOffsetMax + 2) * 500 + 50 | (pucchSlotOffsetMin + 1) * 500 + 20 | A - T56_Min           | B - T56_Max |
| UlData_PuschReceiveReq       | (puschSlotOffsetMax + 2) * 500 + 50 | (puschSlotOffsetMin + 1) * 500 + 20 | A - T56_Min           | B - T56_Max |
| UlData_PrachReceiveReq       | 4000 + 50                           | 500 + 20                            | A - T56_Min           | B - T56_Max |
| UlData_SrsReceiveReq (A-SRS) | (srsSlotOffsetMax + 2) * 500 + 50   | (srsSlotOffsetMin + 1) * 500 + 20   | A - T56_Min           | B - T56_Max |
| UlData_EmptyReceiveReq       |                                     |                                     |                       |             |
#### Response messages:


## Source code: ctrl\common\systemDefinition\TimingWindows.hpp

```cpp
// UL receive request message reception windows (L1) are calculated as follows:
// earliestUs = A - T56_Min
// latestUs   = B - T56_Max
// where A and B are the values of the transmission windows (L2), T56_Min = 0 and T56_Max = 20us

// Definition of L2->L1 transportation delay values (5G_L1_IF_15189)
constexpr uint32_t T56_Min = 0;
constexpr uint32_t T56_Max = 20;

//request timing advance 5G_L1_8450
constexpr uint32_t UlDataPucchReceiveReqEarliestUsScs30     = 8550;
constexpr uint32_t UlDataPucchReceiveReqLatestUsScs30       = 500;
constexpr uint32_t UlDataPuschReceiveReqEarliestUsScs30     = 17050;
constexpr uint32_t UlDataPuschReceiveReqLatestUsScs30       = 500;
constexpr uint32_t UlDataPuschL1ruReceiveReqEarliestUsScs30 = 17050;
constexpr uint32_t UlDataPuschL1ruReceiveReqLatestUsScs30   = 1400;
constexpr uint32_t UlDataPrachReceiveReqEarliestUsScs30     = 4050;
constexpr uint32_t UlDataPrachReceiveReqLatestUsScs30       = 500;
constexpr uint32_t UlDataSrsReceiveReqEarliestUsScs30       = 17050;
constexpr uint32_t UlDataSrsReceiveReqLatestUsScs30         = 250;
constexpr uint32_t UlDataEcpri72eSrsReceiveReqLatestUsScs30 = 1345;
constexpr uint32_t UlDataRimReceiveReqEarliestUsScs30       = 3550;
constexpr uint32_t UlDataRimReceiveReqLatestUsScs30         = 1000;
constexpr uint32_t UlDataEcpri72eRimReceiveReqLatestUsScs30 = 1500; //5G_L1_IF_15166
constexpr uint32_t UlDataFhPuschReceiveRespLatestUsScs30    = 1800;

constexpr uint32_t UlDataPucchReceiveReqEarliestUsScs120     = 2299;
constexpr uint32_t UlDataPucchReceiveReqLatestUsScs120       = 250;
constexpr uint32_t UlDataPuschReceiveReqEarliestUsScs120     = 4424;
constexpr uint32_t UlDataPuschReceiveReqLatestUsScs120       = 250;
constexpr uint32_t UlDataPuschL1ruReceiveReqEarliestUsScs120 = 4424;
constexpr uint32_t UlDataPuschL1ruReceiveReqLatestUsScs120   = 250;
constexpr uint32_t UlDataPrachReceiveReqEarliestUsScs120     = 2299;
constexpr uint32_t UlDataPrachReceiveReqLatestUsScs120       = 250;
constexpr uint32_t UlDataSrsReceiveReqEarliestUsScs120       = 4424;
constexpr uint32_t UlDataSrsReceiveReqLatestUsScs120         = 250;

constexpr uint32_t UlDataPucchReceiveReqEarliestUsScs15     = 5800;
constexpr uint32_t UlDataPucchReceiveReqLatestUsScs15       = 750;
constexpr uint32_t UlDataPuschReceiveReqEarliestUsScs15     = 4800; 
constexpr uint32_t UlDataPuschReceiveReqLatestUsScs15       = 1100;
constexpr uint32_t UlDataPuschL1ruReceiveReqEarliestUsScs15 = 4800;
constexpr uint32_t UlDataPuschL1ruReceiveReqLatestUsScs15   = 1750;
constexpr uint32_t UlDataPrachReceiveReqEarliestUsScs15     = 1800;
constexpr uint32_t UlDataPrachReceiveReqLatestUsScs15       = 750;
constexpr uint32_t UlDataSrsReceiveReqEarliestUsScs15       = 9800;
constexpr uint32_t UlDataSrsReceiveReqLatestUsScs15         = 750;

// nrDL request timing advance based on: 10375865, 10357849 (old id: 5G_L1_IF_123, 5G_L1_5040)
// all requests except payloadTb have the same windows,
// so they are grouped to 'data' (payloadTb) and 'control' (everything else)
// common for non 7-2e
constexpr uint32_t DlSendReqControlEarliestUsScs15  = 1800 - T56_Min; //as per 5G_L1_IF_126 for CB013338-A
constexpr uint32_t DlSendReqControlLatestUsScs15    = 770 - T56_Max;
constexpr uint32_t DlSendReqDataEarliestUsScs15     = 1800 - T56_Min; //as per 5G_L1_IF_126 for CB013338-A
constexpr uint32_t DlSendReqDataLatestUsScs15       = 570 - T56_Max;
constexpr uint32_t DlSendReqControlEarliestUsScs30  = 4050 - T56_Min; //as per 5G_L1_IF_126 for CB013338-A
constexpr uint32_t DlSendReqControlLatestUsScs30    = 520 - T56_Max;
constexpr uint32_t DlSendReqDataEarliestUsScs30     = 4050 - T56_Min; //as per 5G_L1_IF_126 for CB013338-A
constexpr uint32_t DlSendReqDataLatestUsScs30       = 320 - T56_Max;
constexpr uint32_t DlSendReqControlEarliestUsScs120 = 424 - T56_Min; //as per 5G_L1_IF_126 for CB013338-A
constexpr uint32_t DlSendReqControlLatestUsScs120   = 245 - T56_Max;
constexpr uint32_t DlSendReqDataEarliestUsScs120    = 298 - T56_Min; //as per 5G_L1_IF_126 for CB013338-A
constexpr uint32_t DlSendReqDataLatestUsScs120      = 120 - T56_Max;
// Timing window calculation for mixed CPRI and eCPRI fronthaul mode
// For DlData_PdschPayloadTbSendReq: [1050 - T56_Min + T6a_Min, T6a_Min - 200]
// Other messages:                   [1050 - T56_Min + T6a_Min, T6a_Min]
constexpr uint32_t DlSendReqEarliestUsScs15MixedFh         = 1050 - T56_Min; //as per DNG Id 12577980 for CB014054-G
constexpr uint32_t DlSendReqDataLatestUsScs15MixedFh       = 0;
constexpr uint32_t DlSendReqDataLatestOffsetUsScs15MixedFh = 200;
// 72e
constexpr uint32_t DlSendReqControlEarliestUsScs30_72e = 3550 - T56_Min; //as per 5G_L1_IF_126 for CB013338-A
constexpr uint32_t DlSendReqControlLatestUsScs30_72e   = 520 - T56_Max;
constexpr uint32_t DlSendReqDataEarliestUsScs30_72e    = 3550 - T56_Min; //as per 5G_L1_IF_126 for CB013338-A
constexpr uint32_t DlSendReqDataLatestUsScs30_72e      = 320 - T56_Max;
```