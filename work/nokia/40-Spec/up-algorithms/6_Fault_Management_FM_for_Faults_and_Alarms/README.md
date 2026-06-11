# 6 Fault Management (FM) for Faults and Alarms

## 6.0-2 Fault Management (FM) for Faults and Alarms Concept (ID: 11230051)

**6.0-2.0-1**  (ID: `11230057`)

Fault Management (FM) for Faults and Alarms
When an error occurs, application informs OAM of the faulty situation by reporting a raw fault indication to it as described in 5G\_UP\_2724\_replaced([11391923](https://dn-prod.ext.net.nokia.com/rm/resources/BI_ufbP2fvkEe-AqvopbP1qhQ)). A raw fault launches a specific BTS Fault (several raw faults can launch the same BTS Fault). Each fault has an individual fault ID, which can be used to identify the fault.

Overall there are two categories of BTS Faults:

Customer Faults (external faults)

Faults which may raise one or several alarms, impact services and/or trigger recovery actions. The customer is able to see these faults and alarms via BTS Site Manager/NetAct.

R&D Faults (internal faults)

Faults which are used for internal purposes only, and not reported to the customer. These faults do not raise alarms, impact services or change internal gNB state in any way, which could be visible to the customer.

For the application handling of faults is similar regardless of the category.

---

## 6.0-3 Fault Management (FM) for Faults and Alarms Process (ID: 11230065)

**6.0-3.0-1**  (ID: `11230070`)

Fault Management (FM) for Faults and Alarms
Alarms are defined as part of CP2 feature work. Faults can be defined as part of CP2 and/or CP3.

Each alarm and fault is associated with a Managed Object Class (MOC), see 5G\_UP\_2718\_replaced([11391877](https://dn-prod.ext.net.nokia.com/rm/resources/BI_ufbP0_vkEe-AqvopbP1qhQ)).

Alarms and faults are defined in NIDD, for more details see process guidelines in:

Fault and Alarm Process: <https://confluence.ext.net.nokia.com/display/MANO/Fault+and+Alarm+Process>

5G FM NIDD Process: <https://confluence.ext.net.nokia.com/display/5GSE/FM+NIDD+Process>

In general, one should always consider the need and purpose carefully before introducing a new fault or alarm, and as long as possible concentrate mostly on major failures (e.g. link failures etc.). Some information on situations where an application should raise a fault/alarm is given in ITU standard X.733 (Information technology - Open Systems Interconnection - Systems Management: Alarm reporting function): <http://www.itu.int/rec/T-REC-X.733-199202-I/en>

---

## 6.0-4 Fault Management (FM) for Faults and Alarms Faults and Alarms (ID: 11230078)

**6.0-4.0-1**  (ID: `11230086`)

Fault Management (FM) for Faults and Alarms
User Plane faults and alarms are defined in NIDD (see 5G\_UP\_ALG\_15492\_replaced([11230065](https://dn-prod.ext.net.nokia.com/rm/resources/BI_kysJ8fvSEe-AqvopbP1qhQ)) for guidance).

For how User Plane applications shall report faults see 5G\_UP\_2724\_replaced([11391923](https://dn-prod.ext.net.nokia.com/rm/resources/BI_ufbP2fvkEe-AqvopbP1qhQ)).

---
