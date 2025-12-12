---
title: NR PRG
source: https://marshallcomm.cn/2020/03/07/nr_prg/
published: 2020-03-07
created: 2025-12-12
---
## PRG

PRG（Precoding Resource Block Group）是预编码资源块组，由一组频域连续的 RB 组成，这些连续的 RB 具有相同的预编码。

PRG size 的确定涉及到 a) UE能力，b) RRC配置，c) UE 所调度的连续 PRB 数目。

### dynamicPRB-BundlingDL

***dynamicPRB-BundlingDL*** 用于指示 UE 是否支持基于 DCI 来指示 PDSCH 接收的 PRG size。

如果 gNB 收到 UE 上报的 Phy-ParametersCommon:: dynamicPRB-BundlingDL，则表明 UE 支持基于 DCI 来指示 PDSCH 接收的 PRG size。

```
dynamicPRB-BundlingDL        ENUMERATED {supported}           OPTIONAL,
```

### prb-BundlingType

PDSCH-Config:: prb-BundlingType 用于RRC配置PRG size。

```
prb-BundlingType            CHOICE {

​    staticBundling             SEQUENCE {

​      bundleSize               ENUMERATED { n4, wideband }                 OPTIONAL  -- Need S

​    },

​     dynamicBundling           SEQUENCE {

​      bundleSizeSet1             ENUMERATED { n4, wideband, n2-wideband, n4-wideband }    OPTIONAL,  -- Need S

​      bundleSizeSet2             ENUMERATED { n4, wideband }                 OPTIONAL  -- Need S

​    }

 },
```
```
prb-BundlingType

Indicates the PRB bundle type and bundle size(s) (see TS 38.214 [19], clause 5.1.2.3). If *dynamic* is chosen, the actual *bundleSizeSet1 or bundleSizeSet2* to use is indicated via DCI. Constraints on *bundleSize(Set)* setting depending on *vrb-ToPRB-Interleaver* and *rbg-Size* settings are described in TS 38.214 [19], clause 5.1.2.3. If a *bundleSize(Set)* value is absent, the UE applies the value *n2*.
```

### consecutively scheduled bandwidth in frequency

UE所调度的连续 PRB 数目将与 (BWP size)/2 进行比较。

## PRG size

PRG size 有 {n2, n4, wideband} 三种可能，具体配置策略如下。

对于 DCI format 1\_0 调度的 PDSCH ，固定配置为 **PRG size = n2** 。

对于 DCI format 1\_1 调度的 PDSCH，PRG size如下：

1. 如果 UE 没有 dynamicPRB-BundlingDL 能力，则 gNB 只能采用 RRC 静态配置 PRG size。此时 prb-BundlingType为staticBundling。
- 如果配置 bundleSize = n4，则 **PRG size = n4**
- 如果配置 bundleSize = wideband，则 **PRG size = wideband**
1. 如果UE有 dynamicPRB-BundlingDL 能力，则 gNB 可采用 1）RRC + DCI 动态配置 PRG size，或 2）RRC静态配置 PRG size。
- 1）RRC + DCI 动态配置，此时 prb-BundlingType 为 dynamicBundling。
	- DCI 字段 *PRB bundling size indicator* 用一个 bit 来指示 bundleSizeSet1 或 bundleSizeSet2 。值为 1 表示使用 bundleSizeSet1，值为 0 表示使用 bundleSizeSet2。
		- bundleSizeSet1 = {n4, wideband, n2-wideband, n4-wideband}
		- bundleSizeSet2 = {n4, wideband}
	- 如果 DCI 字段 *PRB bundling size indicator* 指示bundleSizeSet1
		- 如果配置 bundleSizeSet1 = n4，则 **PRG size = n4**
		- 如果配置 bundleSizeSet1 = wideband，则 **PRG size = wideband**
		- 如果配置 bundleSizeSet1 = n2-wideband，则
			- 如果 UE 所调度的连续 PRB 数目 > (BWP size)/2，则 **PRG size = wideband** ；否则， **PRG size = n2** 。
		- 如果配置 bundleSizeSet1 = n4-wideband，则
			- 如果 UE 所调度的连续 PRB 数目 > (BWP size)/2，则 **PRG size = wideband** ；否则， **PRG size = n4** 。
	- 如果 DCI 字段 *PRB bundling size indicator* 指示bundleSizeSet2
		- 如果配置 bundleSizeSet2 = n4，则 **PRG size = n4**
		- 如果配置 bundleSizeSet2 = wideband，则 **PRG size = wideband**
- 2）RRC 静态配置，同 a
1. 如有 gNB 没有配置 bundleSize(Set)，则默认 **PRG size = n2** 。
2. PRG size限制条件
- 如果RBG = 2 或 vrb-ToPRB-Interleaver = n2，则 **不能配置PRG size = n4** 。

Note: 当 PRG size 配置为 wideband 时，意味着 PRG size 等于 UE 所调度的连续 PRB 数目，分配给 UE 的资源必须是连续的 PRB。在这些连续的 PRB 上使用相同的预编码。

### References

- 3GPP Spec. 38.211
- 3GPP Spec. 38.212
- 3GPP Spec. 38.214
- 3GPP Spec. 38.331
- 3GPP Spec. 38.306