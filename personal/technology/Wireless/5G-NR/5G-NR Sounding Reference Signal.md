---
title: 5G Sounding Reference Signal
source: https://marshallcomm.cn/2020/11/21/r15_sounding_reference_signal/
published: 2020-11-21
created: 2025-12-12
---
Note: 本文基于 3GPP Rel15 (2020-09) 版本规范。

SRS 用于上行信道信息获取、满足信道互易性时的下行信道信息获取以及上行波束管理。

NR 定义了 3 种类型的 SRS 传输：周期性 SRS，半持续性 SRS 和非周期性 SRS，通过为 SRS 资源集和 SRS 资源配置关于时域类型的高层参数 resourceType 来实现。

**SRS 资源集配置**

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112101.png)

**SRS 资源配置**

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112102.png)

- 周期性 SRS。时域类型被配置为周期 SRS 资源的所有参数由高层信令配置，UE根据所配置的参数进行周期性发送。同一个 SRS 资源集内的所有 SRS 资源具有相同的周期性。考虑到 NR 系统支持各种子载波间隔，不同子载波间隔对应的时隙时长不同，周期 SRS 资源的周期以及周期内的偏移以时隙为单位进行配置。周期 SRS 资源可配置的最小周期为 1 个时隙，最大周期为 2560 个时隙。
- 半持续性 SRS。时域类型被配置为半持续 SRS 资源在激活期间也是周期性发送。它与周期性 SRS 的区别在于 UE 在接收到关于半持续 SRS 资源的高层信令配置后不发送 SRS，只有在接收到 MAC 层发送的关于半持续 SRS 资源的激活信令后才开始周期性地发送半持续 SRS 资源对应的 SRS ，在收到 MAC 层发送的半持续 SRS 资源的去激活命令后停止发送 SRS。因此，相对于周期性 SRS 资源，半持续 SRS 资源的配置以及激活、去激活相比高层信令（RRC信令）更快，更灵活，适用于要求时延较低的业务的快速传输。与周期性 SRS 资源类似，基站通过高层信令为半持续 SRS 资源配置周期和周期内的偏移，同一个 SRS 资源集内的所有SRS资源具有相同的周期性。
- 非周期性 SRS。时域类型被配置为非周期 SRS 资源通过 DCI 信令激活。UE 每接收到一次触发非周期 SRS 资源的 SRS 触发信令，UE 进行一次所触发的 SRS 资源对应的 SRS 发送。DCI 中的 SRS 触发信令包含 2 个比特（如表 Table 7.3.1.1.2-24 所示），2 个比特可表示的 4 个状态。其中中的 1 个状态表示不触发非周期 SRS 发送，其他 3 个状态分别表示触发第一、第二、第三个 SRS 资源组；一个状态可以触发一个或多个 SRS 资源集，一个状态对应的多个 SRS 资源集可以对应多个载波。

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112103.png)

## SRS 资源定义

SRS 资源由「天线端口数目 $NapSRS$ ，连续的 OFDM 符号数目 $NsymbSRS$ ，时域起始符号 $l0$ 和频域起始位置 $k0$ 」四个信息共同确定。

**天线端口数目 $NapSRS$** ： $NapSRS$ 取值范围 $1,2,4$ ，天线端口索引表示为 ${pi}i=0NapSRS−1$ ，其中 $pi=1000+i$ 。

- 如果高层参数 SRS-ResourceSet 中的 usage 未配置为 “nonCodebook”，则 $NapSRS$ 由 nrofSRS-Ports 确定。
- 如果高层参数 SRS-ResourceSet 中的 usage 配置为 “nonCodebook”，则 $NapSRS$ 取决于 section 5.2.

**连续的 OFDM 符号数目 $NsymbSRS$** ：由高层参数 resourceMapping 中的 nrofSymbols 确定。

**时域起始符号 $l0$** ： $l0=Nsymbslot−1−loffset$ ，其中 $loffset∈{0,1,…,5}$ 并且 $loffset≥NsymbSRS−1$ 。

当遍历所有可能的 $loffset$ 取值后，可知 SRS 在一个时隙内的起始符号 $l0$ 的可能取值是 symbol 8~13。即 symbol 8~13 是时隙内的 SRS 资源区域。

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112104.png)

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112105.jpg)

**频域起始位置 $k0$** ：SRS 的频域起始子载波。

## SRS 序列生成

SRS 序列基于Zadoff-Chu 序列产生：

$$
r(pi)(n,l′)=ru,v(αi,δ)(n)
$$

$$
0≤n≤Msc,bSRS−1
$$

$$
l′∈{0,1,…,NsymbSRS−1}
$$

$ru,v(αi,δ)(n)$ 是 扩展 ZC 序列，序列长度为 $Msc,bSRS$ ，其中 $δ=log2(KTC)$ ， $αi$ 是对应于天线端口 $pi$ 的循环移位。 $l′$ 是 SRS 资源的 OFDM 符号索引。传输梳齿数目 $KTC$ 由高层参数 transmissionComb 确定，循环移位 $αi$ 由下式给出：

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112106.png)

如果传输梳齿数目 $KTC=4$ ，则最大循环移位数目 $nSRScs,max=12$ ；如果传输梳齿数目 $KTC=2$ ，则最大循环移位数目 $nSRScs,max=8$ 。 $nSRScs∈{0,1,…,nSRScs,max−1}$ 由高层参数 transmissionComb 给定。

循环移位 $αi$ 是 $nSRScs$ 和 $pi$ 的函数，即使高层给定了 $nSRScs$ ，不同的天线端口 $pi$ 也会使得循环移位 $αi$ 不同。也就是说，同一个 UE 的不同天线端口所使用的 SRS 序列不同，每个天线端口对应的 SRS 序列是通过不同的循环移位得到的。

例如，假设 SRS 天线端口数目 $NapSRS=4$, $nSRScs,max=8$ ，并且给定 $nSRScs=0$ 。根据低峰均比序列的定义 $ru,v(α,δ)(n)=ejαnr¯u,ν(n)$ ， $ejαn$ 表示对频域序列进行相位偏移，等效为时域的循环移位。这里假定基序列 $r¯u,ν(n)$ 保持不变，则唯一变化的是相位偏移量 $ejαn$ 。尽管数学上称为频域的相位偏移，但 NR 标准统称为循环移位（cyclic shift）。

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112107.png)

为了干扰随机化，5G NR 系统支持 SRS 序列跳和序列组跳，是否开启这项功能由高层参数 groupOrSequenceHopping 决定。

SRS 的基序列被分成若干组，每组包含若干序列。如果基站给终端配置为 groupOrSequenceHopping = neither，则每次终端发送的 SRS 序列不变；如果基站给终端配置为 groupOrSequenceHopping = groupHopping or sequenceHopping，则每次终端发送上行 SRS 时按照以下规则采用不同的序列。

序列组号定义为 $u=(fgh(ns,fμ,l′)+nIDSRS) mod 30$ ，序列号 $v$ 取决于高层参数 groupOrSequenceHopping 的值。SRS 序列标识 $nIDSRS$ 由高层参数 sequenceId 给定，取值范围为 0~1023。

在协议讨论阶段，RAN1#89 次会议同意使用 SRS sequence ID 来生成 SRS 序列。序列组号 $u$ 是 SRS sequence ID 的函数，而 SRS sequence ID 是 UE 特定的信息。这意味着 NR SRS 序列本身带有 UE 信息，而 LTE SRS 序列的生成是不带有 UE 信息的。这样做的好处是，即使两个 UE 使用了完全相同的时频域资源发送 SRS，由于 SRS sequence ID 不同，又由于 ZC 序列良好的互相关特性，那么两个 SRS 序列也具有较好的正交性。

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112108.png)

下面回到序列跳和组跳的讨论。

如果 groupOrSequenceHopping = neither，表示 SRS既不序列跳，也不序列组跳，此时有

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112109.png)

如果 groupOrSequenceHopping = groupHopping，表示 SRS 只进行序列组跳，此时有

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112110.png)

其中 $c(i)$ 表示伪随机序列，伪随机序列在每个无线帧的起始点使用 $cinit=nIDSRS$ 进行初始化。

如果 groupOrSequenceHopping = sequenceHopping，表示 SRS 只进行序列跳，此时有

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112111.png)

其中 $c(i)$ 表示伪随机序列，伪随机序列在每个无线帧的起始点使用 $cinit=nIDSRS$ 进行初始化。

## 映射到物理资源

## SRS 频域资源

对应 SRS 资源的每个 OFDM 符号 $l′$ 和天线端口 $pi$ ，需要先将 SRS 序列 $r(pi)(n,l′)$ 乘以幅度扩展因子 $βSRS$ 以符合 38.213 规定的传输功率。然后对每个天线端口 $pi$ ，从 $r(pi)(0,l′)$ 开始在一个时隙内根据下式映射到资源粒子 $(k,l)$ ：

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112112.png)

SRS 序列长度等于 SRS 资源在一个符号内占用的子载波数目，具体定义为

$$
Msc,bSRS=mSRS,bNscRBKTC
$$

$mSRS,b$ 通过查 Table 6.4.1.4.3-1 得到，其中 $b=BSRS$ 。 $BSRS∈{0,1,2,3}$ 由高层参数 freqHopping 中的字段 b-SRS 给定， $CSRS∈{0,1,...,63}$ 由高层参数 freqHopping 中的 c-SRS 给定。查表时通过 $CSRS$ 选中某一行，再通过 $BSRS$ 选中某一列，即可最终确定 SRS 的带宽信息。 根据 Table 6.4.1.4.3-1，NR 系统支持 64 种 SRS 带宽配置方式，一个 SRS 资源可配置的最小带宽为 4 个 RB，最大带宽为 272 个RB。

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112113.png)

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112114.png)

确定了 SRS 资源的带宽信息后，还需要确定 SRS 的频域起始位置。SRS 的频域起始位置 $k0(pi)$ 定义如下：

$$
k0(pi)=k¯0(pi)+∑b=0BSRSKTCMsc,bSRSnb
$$

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112115.png)

频域移位值 $nshift$ 用来调整 SRS 资源和 CRB 的 4 的倍数网格对齐，它包含在高层参 freqDomainShift 中。如果 $NBWPstart≤ nshift$ ，则 $k0(pi)=0$ 的参考点是 CRB 0 的子载波 0；如果 $NBWPstart>nshift$ ，则 $k0(pi)=0$ 的参考点是 BWP 的最低编号的子载波。

传输梳齿偏移量 $k¯TC∈{0,1,…,KTC−1}$ 由高层参数 transmissionComb 给定。 $nb$ 是频域位置索引。

SRS 是否跳频由高层参数 freqHopping 中的字段 b-hop 决定。 $bhop$ 取值范围 0~3。

如果 $bhop≥ BSRS$ ，则 SRS 跳频关闭，频域位置索引 $nb$ 保持为常量（除非被重新配置）。此时，对于 SRS 资源中的全部 $NsymbSRS$ 个 OFDM 符号， $nb$ 的值定义为：

$$
nb=⌊4nRRCmSRS,b⌋ mod Nb
$$

其中 $nRRC$ 由高层参数 freqDomainPosition 给定。 $mSRS,b$ 和 $Nb$ 的值通过给定的 $CSRS$ 和 $b=BSRS$ 查 Table 6.4.1.4.3-1 得到。

如果 $bhop<BSRS$ ，则 SRS 跳频打开，频域位置索引 $nb$ 由下式定义：

$$
nb={⌊4nRRCmSRS,b⌋ mod  Nbb≤bhop(Fb(nSRS)+⌊4nRRCmSRS,b⌋) mod  Nbotherwise
$$

其中 $Nb$ 通过查 Table 6.4.1.4.3-1 得到， $Fb(nSRS)$ 由下式得到：

$$
Fb(nSRS)={(Nb/2)⌊nSRSmodΠb′=bhopbNb′Πb′=bhopb−1Nb′⌋+⌊nSRSmodΠb′=bhopbNb′2Πb′=bhopb−1Nb′⌋if Nb even  ⌊Nb/2⌋⌊nSRS/Πb′=bhopb−1Nb′⌋if Nb odd
$$

无论 $Nb$ 取任何值， $Nbhop=1$ 。

$nSRS$ 用于 SRS 传输的计数。如果高层参数 resourceType 被配置为 “aperiodic”，则在时隙内发送 $NsymbSRS$ 个符号的 SRS 资源为 $nSRS=⌊l′R⌋$ 。重复因子 $R≤ NsymbSRS$ 由高层参数 resourceMapping 中的字段 repetitionFactor 给定。

如果高层参数 resourceType 被配置为 “semi-persistent”或 “periodic”，则对于满足 $(Nslotframe,μnf+ns,fμ−Toffset)modTSRS=0$ 的时隙，SRS 计数器由下式给定：

$$
nSRS=(Nslotframe,μnf+ns,fμ−ToffsetTSRS)⋅(NsymbSRSR)+⌊l′R⌋
$$

## SRS 时域资源

以时隙表示的 SRS 周期 $TSRS$ 和时隙偏移量 $Toffset$ 根据高层参数 periodicityAndOffset-p 或 periodicityAndOffset-sp 确定。如果 resourceType = “periodic”，则对应 periodicityAndOffset-p；如果 resourceType = “semi-persistent”，则对应 periodicityAndOffset-sp。在配置的SRS资源中可用于 SRS 传输的候选时隙需要满足 $(Nslotframe,μnf+ns,fμ−Toffset)modTSRS=0$ 。

## UE 探测过程

UE可以被高层参数 SRS-ResourceSet 配置一个或多个 SRS 资源集。对于每个 SRS 资源集，UE 可以被高层参数 SRS-Resource 配置 $K≥1$ 个 SRS 资源，其中 $K$ 的最大值由 UE 能力指示。SRS 资源集的用途由高层参数 SRS-ResourceSet 中的字段 usage 确定。

当高层参数 usage 被配置为 beamManagement，则在给定的时刻每个 SRS 集中只能有一个 SRS 资源，但在同一 BWP 中具有相同时域行为的不同 SRS 资源集中的 SRS 资源可以同时发送。

对于非周期性 SRS，DCI 字段的至少一种状态用于从已配置的 SRS 资源集中选择至少一种。

下列 SRS 参数可由较高层参数 SRS-Resource 半静态配置。

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112116.png)

UE 由高层参数 SRS-Resource 中的字段 resourceMapping 来配置 SRS 资源，该 SRS 资源位于时隙内最后 6 个符号的区域，并占用 $NS∈{1,2,4}$ 个连续符号。

当 PUSCH 和 SRS 在同一个时隙中发送时，则 UE只能在 PUSCH 和相应的 DM-RS 发送完之后才能发送 SRS。

对于配置有一个或多个 SRS 资源配置的 UE，当高层参数 SRS-Resource 中的字段 resourceType 被配置为 “periodic” 时有如下定义：

- 如果配置给 UE 的高层参数spatialRelationInfo 中包含了参考 “ssb-Index”，则 UE 发送目标 SRS 资源时，将使用与接收参考信号 SSB 相同的空间域传输过滤器。
- 如果配置给 UE 的高层参数spatialRelationInfo 中包含了参考 “csi-RS-Index”，则 UE 发送目标 SRS 资源时，将使用与接收周期性 CSI-RS 或者半持续性 CSI-RS 相同的空间域传输过滤器。
- 如果配置给 UE 的高层参数spatialRelationInfo 中包含了参考 “srs”，则 UE 发送目标 SRS 资源时，将使用与接收周期性 SRS 相同的空间域传输过滤器。

对于配置有一个或多个 SRS 资源配置的 UE，当高层参数 SRS-Resource 中的字段 resourceType 被配置为 “semi-persistent” 时有如下定义：

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112117.png)

如果 UE 具有激活的半持续性 SRS 资源配置，并且没有收到去激活命令，则在激活的 UL BWP 中半持续性 SRS 资源配置被认为处于激活状态，否则被认为是暂停状态。

对于配置有一个或多个 SRS 资源配置的 UE，当高层参数 SRS-Resource 中的字段 resourceType 被配置为 “aperiodic” 时有如下定义：

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112118.png)

一个 SRS 可以周期性发送、半持续性发送或非周期性发送，但在一个 SRS 资源集中的所有 SRS的时域行为都必须是同一类型。也就是说，周期性、半持续性或非周期性是 SRS 资源集的特性，而不是某个 SRS 资源的特性。

DCI format 0\_1 和 DCI format 1\_1 中的SRS request 字段指示了 Table 7.3.1.1.2-24 中被触发的 SRS 资源集。DCI format 2\_3 中 2-bit 的 SRS request 字段，如果 UE 被高层参数 srs-TPC-PDCCH-Group 设置为 “typeB”，则该字段用于指示被触发的 SRS 资源集；如果 UE 被高层参数 srs-TPC-PDCCH-Group 设置为 “typeA”，则该字段用于指示通过高层配置的一组服务小区上进行SRS传输。

## SRS 的冲突处理

PUCCH 和 SRS 在相同载波条件下，

- 当半持续和周期 SRS 与仅携带 CSI 报告的 PUCCH 被配置在相同的符号时，或者当半持续和周期 SRS 与仅携带 L1-RSRP 报告的 PUCCH 被配置在相同的符号时, UE 不应发送 SRS。
- 当半持续性 SRS 或周期性 SRS 或非周期性 SRS 被触发后，与携带 HARQ-ACK 和/或 SR 的 PUCCH 在相同符号发送时，UE 不应发送 SRS。
- 对由于与 PUCCH 重叠而不发送 SRS 的情况，仅丢弃与 PUCCH 重叠的 SRS 符号。
- 非周期性 SRS 被触发后，与携带半持续/周期 CSI 报告或仅携带半持续/周期 L1-RSRP 报告的 PUCCH 在相同符号时，UE 不应发送 PUCCH。

在带内载波聚合或带间CA频带组合的情况下，详见协议原文：

> In case of intra-band carrier aggregation or in inter-band CA band combination if simultaneous SRS and PUCCH/PUSCH transmissions are not supported by UE, the UE is not expected to be configured with SRS from a carrier and PUSCH/UL DM-RS/UL PT-RS/PUCCH formats from a different carrier in the same symbol. In case of intra-band carrier aggregation or in inter-band CA band combination if simultaneous SRS and PRACH transmissions are not supported by UE, the UE shall not transmit simultaneously SRS resource(s) from a carrier and PRACH from a different carrier.

如果在配置了周期/半持续 SRS 传输的 OFDM 符号上触发了由高层参数 resourceType 配置 “aperiodic”SRS资源，UE 应发送非周期 SRS 资源，仅丢弃在该符号内重叠的周期/半持续 SRS，仍然会发送不与非周期 SRS 重叠的周期/半持续 SRS 符号。

如果在配置有周期性 SRS 传输的OFDM符号上触发了由高层参数 resourceType 配置的“semi-persistent”的SRS资源，UE应发送半持续 SRS 资源，仅丢弃在符号内重叠的周期性 SRS，仍然发送不与半持续 SRS 资源重叠的周期 SRS符号。

当 UE 被高层参数 SRS-ResourceSet 中的字段 usage 配置为 “antennaSwitching”，并且根据 Table 6.2.1.2-1 配置 Y 个符号的保护周期时，如果在保护周期内 UE 被配置了 SRS，则 UE 应使用与上述相同的优先级规则。

## UE SRS 跳频过程

对于给定的 SRS 资源，UE 由高层参数 SRS-Resource::resourceMapping 中的字段 repetitionFactor 配置重复因子 $R∈{1,2,4}$ ，其中 $R≤Ns$ 。如果未配置每个时隙内 SRS 资源内的跳频（R = Ns），每个时隙中的 SRS 资源的每个天线端口在所有 $Ns$ 个符号中被映射到相同的 PRB 集合中的相同的子载波集合。

如果每个时隙的 SRS 资源内的跳频配置没有重复（R = 1），根据 SRS 跳频参数 $BSRS$ ， $CSRS$ 和 $bhop$ ，每个时隙中 SRS 资源的每个天线端口被映射到每个 OFDM 符号中的不同子载波集合，其中对于不同的子载波集合，假定具有相同的传输梳齿。

当每个时隙的 SRS 资源都配置了跳频和重复（Ns = 4，R = 2）时，每个时隙中的 SRS 资源的每个天线端口都被映射到每对 R 个相邻 OFDM 符号中相同的一组子载波，并且根据 SRS 的跳频参数 $BSRS$ ， $CSRS$ 和 $bhop$ 在两对间跳频。

UE可以被配置 Ns = 2 or 4 个相邻符号的非周期 SRS 资源并在 BWP 内进行时隙内跳频，其中当跳频配置为 $R=1$ 时，在 $Ns$ 个符号上以相等大小的 sub-band 来探测全跳频带宽。UE可以被配置 $Ns=4$ 个相邻符号非周期 SRS 资源并在 BWP 内进行时隙内跳频，其中当跳频配置为R = 2时，在两对 R 个相邻的 OFDM 符号之间以相等大小的 sub-band来探测全跳频带宽。SRS 资源的每个天线端口被映射到每对 R 个相邻的 OFDM 符号中相同的子载波集合。

UE可以被配置 $Ns=1$ 个符号的周期或半持续 SRS 资源并在 BWP 内进行时隙间跳频，其中 SRS 资源在每个时隙中占据相同的符号位置。UE可以被配置 Ns = 2 or 4 个符号的周期或半持续 SRS 资源并在 BWP 内进行时隙内和时隙间跳频，其中N 个符号的 SRS 资源在每个时隙中占据相同的符号位置。对于 $Ns=4$ ，当跳频配置为 R = 2 时，SRS 资源的每个天线端口通过每个时隙中的资源的两对 R 个相邻的 OFDM 符号映射到不同子载波集合以支持时隙内和时隙间跳频。对于 $Ns=R$ ，当跳频被配置，SRS 资源的每个天线端口映射到每个时隙中的资源的 R 个相邻 OFDM 符号中的相同一组子载波集合以支持时隙间跳频。

## 用于下行 CSI 获取的 UE 探测过程

当 UE 被高层参数 SRS-ResourceSet 中的字段 usage 配置为 “antennaSwitching”，根据 UE 能力 supportedSRS-TxPortSwitch，基站可以采用如下方式中的一种为 UE 配置用于下行 CSI 获取的 SRS 资源集。在 R15 （V15.11.0） 规范中UE 能力 supportedSRS-TxPortSwitch 包括 't1r2' for 1T2R, 't2r4' for 2T4R, 't1r4' for 1T4R, 't1r4-t2r4' for 1T4R/2T4R, 't1r1' for 1T=1R, 't2r2' for 2T=2R, or 't4r4' for 4T=4R。

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112119.png)

- 对于 1T2R，最多配置两个 SRS 资源集。一个 SRS 资源集中包含两个配置在不同 OFDM 符号的 SRS 资源，每个 SRS 资源有 1 个端口。同一个 SRS 资源集中的不同 SRS 资源使用不同的 UE 天线端口（物理天线）分别发送。当配置两个 SRS 资源集时，这两个 SRS 资源集须通过高层参数 resourceType配置为不同的资源类型。
- 对于 2T4R，最多配置带个 SRS 资源集。一个 SRS 资源集中包含两个配置在不同 OFDM 符号的 SRS 资源，每个 SRS 资源有 2 个端口，其中的一个 SRS 资源由两个 UE 天线端口（物理天线）发送，另一个 SRS 资源则从另外两个 UE 天线端口（物理天线）发送。当配置两个 SRS 资源集时，这两个 SRS 资源集须通过高层参数 resourceType配置为不同的资源类型。
- 对于 1T4R，可以配置零个或一个周期或半持续 SRS 资源集。当配置一个周期或半持续 SRS 资源集时，该资源集内包含 4 个 SRS 资源，每个 SRS 资源包含 1 个端口，不同的 SRS 资源配置在不同的 OFDM 符号上，且使用不同的 UE 天线端口（物理天线）发送。
- 对于 1T4R，可以配置零个或两个非周期 SRS 资源集。当配置两个非周期 SRS 资源集时，由于天线切换需要时间，4 个 SRS 资源不能在一个时隙内发完，因此两个非周期 SRS 资源集要在两个时隙内发送。两个 SRS 资源集共包含 4 个 SRS 资源，每个资源集各包含两个 SRS 资源或者一个 SRS 资源集包含 1 个SRS 资源，另外一个 SRS 资源集包含 3 个 SRS 资源，每个 SRS 资源包含一个端口，不同的 SRS 资源通过不同的 UE 物理天线发送。当配置两个非周期 SRS 资源集时，两个 SRS 资源集需配置相同的功率控制参数，包括 SRS-ResourceSet 中的字段 alpha, p0, pathlossReferenceRS 和 srs-PowerControlAdjustmentStates。UE期望高层参数aperiodicSRS-ResourceTrigger的值或每个SRS-ResourceSet中AperiodicSRS-ResourceTriggerList中的条目的值相同，并且每个SRS-ResourceSet中的高层参数slotOffset的值不同 。
- 对于 1T=1R 或 2T=2R 或 4T=4R，最多配置两个 SRS 资源集。每个 SRS 资源集包含 1 个 SRS 资源，每个 SRS 资源的端口数可以为 1，2或4。

用于天线切换的 SRS 资源集内的多个 SRS 资源两两之间需要留有 Y 个符号的保护时间间隔，在保护时间间隔内，UE 不能发送任何信号。

如果UE能力是“t1r4-t2r4”，则对于一个或多个 SRS 资源集中的所有 SRS 资源，UE应期望配置有相同数量的 SRS 端口（一个或两个）。

如果UE能力是“t1r2”，“t2r4”，“t1r4”，“t1r4-t2r4”并且在同一个时隙内高层参数 usage 为“antennaSwitching”，则 UE 不应被配置或被触发一个以上的SRS资源集。如果UE能力是 “t1r1” 或 “t2r2” 或 “t4r4”并且在同一个符号内高层参数 usage 为“antennaSwitching”，则 UE 不应被配置或被触发一个以上的 SRS 资源集。

Y 的值由 Table 6.2.1.2-1 给出。

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112120.png)

## 低峰均比序列

低峰均比序列 $ru,v(α,δ)(n)$ 由基序列 $r¯u,ν(n)$ 的循环移位 $α$ 根据下式定义：

$$
ru,v(α,δ)(n)=ejαnr¯u,ν(n),0≤n<MZC
$$

其中 $MZC=mNscRB2δ$ 是序列的长度。基于单个基序列，通过不同的 $α$ 和 $δ$ 来定义多个序列。

基序列 $r¯u,ν(n)$ 分别 30 个组，其中 $u∈{0,1,...,29}$ 是组号， $v$ 是某个组内的序列号。分别以下两种情况。

**情况一**

如果序列长度为 $MZC=mNscRB2δ$ ， $12≤m2δ≤5$ ，则每个组只包含一个基序列（ $v=0$ ）。

**情况二**

如果序列长度为 $MZC=mNscRB2δ, 6≤m2δ$ ， 则每个组包含两个基序列（ $v=0,1$ ）。

以 SRS 序列为例，SRS 序列根据带宽和 comb 的配置也有以上两种情况。以下配置属于情况一：

（1）SRS 带宽 4 RB，传输梳齿数目 $KTC=2$, 则 $δ=log2(2)=1$ ， $12≤42≤5$ 。此时序列长度为 $MZC=mNscRB2δ=4∗12/2=24$ 。

（2）SRS 带宽 4 RB，传输梳齿数目 $KTC=4$, 则 $δ=log2(4)=2$ ， $12≤44≤5$ 。此时序列长度为 $MZC=mNscRB2δ=4∗12/4=12$ 。

（3）SRS 带宽 8 RB，传输梳齿数目 $KTC=4$, 则 $δ=log2(4)=2$ ， $12≤84≤5$ 。此时序列长度为 $MZC=mNscRB2δ=8∗12/4=24$ 。

其他配置，如 $KTC=2$ 且 SRS 带宽大于等于 6RB，或 $KTC=4$ 且 SRS 带宽大于等于 12RB 都属于情况二，此时序列长度 $MZC≥3NscRB=36$ 。

## 长度大于等于 36 的基序列

大度大于等于 36 的基序列 $r¯u,ν(n),...,r¯u,ν(MZC−1)$ 采用 Zadoff-Chu 循环扩展，并由下式定义：

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112121.png)

其中

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112122.png)

ZC 序列长度 $NZC$ 是满足 $NZC<MZC$ 的最大质数。

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112123.png)

ZC 序列的长度通常小于基序列的长度，剩余的那部分基序列由 ZC 序列循环扩展得到，首尾相接。例如基序列长度 $MZC=36$ ，则 ZC 序列长度为 $NZC=31$ 。通过对基序列进行循环移位可得到更多的 ZC 序列，当 $NZC=31$ 时，可用的 ZC 序列有 30 个。可用的 ZC 序列数目为 $NZC−1$ 。

## 长度小于 36 的基序列

长度为 $MZC∈{6,12,18,24}$ 的基序列由下式定义：

$$
r¯u,ν(n)=ejϕ(n)π4,0≤n≤MZC−1
$$

其中 (n) 的值由 Tables 5.2.2.2-1 ~ 5.2.2.2-4 给定。

长度为 $MZC=30$ 的基序列由下式定义：

$$
r¯u,ν(n)=e−jπ(u+1)(n+1)(n+2)31,0≤n≤MZC−1
$$

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112124.png)

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112125.png)

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112126.png)

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112127.png)

## 为什么是 ZC 序列

1962 年 Zadoff 和 Frank 提出了一种循环自相关为零的多相编码（polyphase codes），但编码的长度受限于 p^2。十年后（1972），Chu 基于 Zadoff 和 Frank 的研究成果，提出了一种新的序列构造方法，依然具有完美的零相关性，但序列长度没有限制。这种新的序列就是 Zadoff-Chu 序列。又数十年后，它应用在4G 和 5G 的参考信号中。

Zadoff-Chu 序列一个关键特点是经过离散傅里叶变换，生成的新序列依然是 Zadoff-Chu 序列。Zadoff-Chu 序列的另一个特点是序列在时域和频域的幅度都是恒定的。时域信号的幅度恒定有助于提高功放效率。频域信号的幅度恒定意味着序列经过任意非零循环移位与原序列零相关。这就是说，同一个 Zadoff-Chu 序列在时域上经过不同的循环移位所产生的两个序列信号之间是正交的。时域的循环移位等效于在频域上进行连续的相位旋转。

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112129.png)

虽然 Zadoff-Chu 序列具有以上优点，但它并不能直接在 LTE/NR 系统中被使用。一个原因是 SRS 序列长度并不是质数，另一个原因是 Zadoff-Chu序列长度较短时，没有足够的可用序列。

原始的 Zadoff-Chu 序列可以为任意长度，但人们往往关注 $NZC$ 为质数的情况，因为质数长度会拥有最多可用的 Zadoff-Chu 序列。也就是说，在 Zadoff-Chu序列长度 $NZC$ 为质数的情况下，可以找到 $NZC−1$ 个不同的 Zadoff-Chu序列。因此 SRS 序列采用 Zadoff-Chu序列循环扩展，从长度 $NZC$ 扩展到长度 $MZC$ 。SRS 序列是频域序列，由于是在频域上扩展生成，所以依然保持了完美的循环自相关特性，但在时域上会破坏 Zadoff-Chu序列原有的幅度恒定特性，因此时域幅度上会产生波动。

对于长度超过 36 的 SRS 序列，都会使用扩展 Zadoff-Chu 序列。对于长度小于 36 的 SRS 序列，NR 标准通过计算机穷举法，找到了一组合适的序列，这些频域上平坦的序列具有良好的时域包络特性。长度小于 36 的 SRS 序列不使用 Zadoff-Chu 序列，主要原因是找不到足够的可用 Zadoff-Chu 序列。

David C. Chu 在 1972 年从数学上证明了 Zadoff-Chu 序列具有完美的循环自相关特性。

ZC 序列根据序列长度 N 为偶或奇定义如下：

![](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20201121/2020112128.png)

其中 N 为任意正整数，M 为 相对于 N 的质数， $k=0,1,...,N−1$ 。

自相关函数 ${xm}$ 定义为：

$$
x0=∑k=0N−1akak∗
$$

$$
xm=∑k=0N−m−1akak+m∗+∑k=N−mN−1akak+m−N∗,  j=1,2,...,N−1
$$

已得到证明，无论 N 为偶或奇，ZC 序列的自相关函数 $xm=0$ 。

为便于理解，可采用数值计算的方式验证 ZC 序列的零自相关性和良好的互相关性。ZC 序列具有零相关性是指，同一个基序列的不同循环移位得到任意两个序列之间的相关系数为零，如以下例子，忽略数值计算的误差，可以认为 autoCorr=0。另一方面，理论上两个不同的基序列（M1和M2不同，无循环移位）的互相关系数为 1/sqrt(N)。数值计算得到的 crossCorr=1/sqrt(63)=0.1260。

```
N  = 63;

M1 = 61;

M2 = 59;

m  = 5;

 

% 1. Zadoff-Chu

ak1 = zeros(1,N);

bk1 = zeros(1,N);

for k = 0:N-1

    ak1(k+1) = exp(1j * (M1 * pi * k * (k+1) / N));

    bk1(k+1) = exp(1j * (M2 * pi * k * (k+1) / N));

end

 

% 2. cyclic shift

ak2 = [ak1(1, m+1:end), ak1(1, 1:m)];

 

% 3. autocorrelation

autoCorr = abs(sum(ak1 .* conj(ak2)) / N)

 

% 4. cross correlation

crossCorr = abs(sum(ak1 .* conj(bk1)) / N)
```

Output:

```
autoCorr =

   4.4623e-14

crossCorr =

    0.1260
```