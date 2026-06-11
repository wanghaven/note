# 8 Per Call Measurement Data (PCMD) Measurements

## 8.0-2 Per Call Measurement Data (PCMD) Measurements PCMD overview (ID: 11230366)

**8.0-2.0-3**  (ID: `11230388`)

Per Call Measurement Data (PCMD) Measurements
Per Call Measurement Data (PCMD) records provide per call measurements/statistics data which can be used for troubleshooting and performance monitoring (KPIs).

5GNB collects PCMD data fields and sends them to a PCMD Trace Collection Entity (TCE) tool via TCP connection. The final PCMD call record is created by the TCE, which combines PCMD data provided by 5GNB (in NSA case also by eNB) to aggregate and derive statistical data about each call. TCE Nokia product for 5G is e.g. CA4MN.

Customer can use PCMD records for troubleshooting. Unlike in case of PM counters, PCMD reports offer UE level granularity allowing to focus e.g. on specific UE model, bearer configuration or mobility scenario.

**[Before CNI-122508-B] Via 'PCMD Trace Report Framework', the data defined for conventional PCMD purposes can be also delivered for internal troubleshooting as described in 5G\_UP\_ALG\_14995\_replaced([11230394](https://dn-prod.ext.net.nokia.com/rm/resources/BI_kyt_I_vSEe-AqvopbP1qhQ)).** [End CNI-122508-B]\*\*\*\*

PCMD records and fields are defined as part of CP2, see 5G\_UP\_ALG\_6600\_replaced([11230420](https://dn-prod.ext.net.nokia.com/rm/resources/BI_kyt_J_vSEe-AqvopbP1qhQ)).

PCMD Customer Documentation is stored: <https://doc.networks.nokia.com/product/Single_RAN/134-074855.00/release/22R2-SR/833-068812.00/document/5G_Tracing_in_SRAN/SingleRanSystem--tracing_5g_sran/topic/287857335>

and can be also found in Discovery Center: <https://skylabx.int.net.nokia.com/default>

Trainings in WebNEI (PCMD Essentials):

<https://webnei.emea.nsn-net.net/#/>

<https://feature-corner.nsn-net.net/?q=PCMD>

---

## 8.0-3 Per Call Measurement Data (PCMD) Measurements PCMD Trace Report Framework overview (up to 25R3) (ID: 11230394)

**8.0-3.0-3**  (ID: `11230413`)

Per Call Measurement Data (PCMD) Measurements
**[Before CNI-122508-B]**

'PCMD Trace Report Framework' refers to an internal trace collection mechanism for testability purposes. Via it, PCMD measurement data defined for conventional PCMD [5G\_UP\_ALG\_6600\_replaced([11230420](https://dn-prod.ext.net.nokia.com/rm/resources/BI_kyt_J_vSEe-AqvopbP1qhQ))] can be sent to an external tester address upon request. This framework is independent from TC (bypasses the TC) and meant for internal troubleshooting.

The 'PCMD Trace Report Framework' shall support delivery of measurements collected for periodic U-Plane PCMD records.

For more information on the 'PCMD Trace Report Framework' see 5G\_UP\_3543\_replaced([11400709](https://dn-prod.ext.net.nokia.com/rm/resources/BI_ugF-N_vkEe-AqvopbP1qhQ)).

**[End CNI-122508-B]**

---

## 8.0-4 Per Call Measurement Data (PCMD) Measurements PCMD Measurements (ID: 11230420)

**8.0-4.0-2**  (ID: `11230433`)

Per Call Measurement Data (PCMD) Measurements
PCMD records and fields are described as vendor extensions in '5G Trace Content' module ([RAN SFS/Performance Monitoring SFS/5G Trace Content](https://dn-prod.ext.net.nokia.com/rm/resources/MD_FK-P1QpAEfCT35inaBGo7g)) in chapter [12455982: Layer L2](https://dn-prod.ext.net.nokia.com/rm/resources/BI_FLKdHQpAEfCT35inaBGo7g?oslc_config.context=https%3A%2F%2Fdn-prod.ext.net.nokia.com%2Fgc%2Fconfiguration%2F9).

PCMD records and fields in Discovery Center: <https://doc.networks.nokia.com/product/Single_RAN/134-074855.00/release/22R3-SR/833-068814.00/collection/tracingMessagesAndPcmdRecords/0>

For 5G PCMD architecture and the measurement collection mechanism see [11392191](https://dn-prod.ext.net.nokia.com/rm/resources/BI_ufcd_vvkEe-AqvopbP1qhQ).

**[CB007227-B] PCMD is supported also in gNB-CU-UP** [End CB007227-B]\*\*\*\*

**[CB007227-F] PCMD is supported also in gNB-DU (L2NRT)** [End CB007227-F]\*\*\*\*

---
