---
title: "5G PRACH与随机接入"
source: "https://marshallcomm.cn/2017/12/29/nr-v200-l1-prach/"
published: 2017-12-29
created: 2025-12-12
---
## PRACH

## 序列生成

  
随机接入前导 $xu,v(n)$ 应根据以下方式生成

$$
xu,v(n)=xu((n+Cv)modLRA)xu(i)=e−jπui(i+1)LRA,i=0,1,...,LRA−1
$$

从而进一步生成频域表示

$$
yu,v(n)=∑m=0LRA−1xu,v(m)⋅e−j2πmnLRA
$$

其中$ { {L} *{}}=839 $或$ { {L}* {}}=139 $取决于表6.3.3.1−1和6.3.3.1−2给定的PRACH前导格式。序列号$ u $根据表6.3.3.1-3和6.3.3.1-4由高层参数 *PRACHRootSequenceIndex* 获得。

循环移位 $Cv$ 为

$$
Cv={vNCSv=0,1,...,⌊LRA/NCS⌋−1,NCS≠0for unrestricted sets0NCS=0for unrestrictedsetsdstart⌊v/nshiftRA⌋+(vmodnshiftRA)NCSv=0,1,...,w−1for restricted sets type A and Bd¯¯start+(v−w)NCSv=w,...,w+n¯¯shiftRA−1forrestricted sets type Bd¯¯¯start+(v−w−n¯¯shiftRA)NCSv=w+n¯¯shiftRA,...,w+n¯¯shiftRA+n¯¯¯shiftRA−1for restricted sets type Bw=nshiftRAngroupRA+n¯shiftRA
$$

其中 $N$ 由表6.3.3.1-5到6.3.3.1-7提供，高层参数 *restrictedSetConfig* 决定限制集类型（非限制集，限制集A，限制集B），表6.3.3.1-1和6.3.3.1-2指示不同前导格式所支持的限制集类型。

变量 $du$ 为

$$
du={q0≤q<LRA/2LRA−qotherwise
$$

其中 $q$ 是满足$ ( qu )=1 $的最小非负整数。循环移位的限制集参数取决于$ { {d}\_{u}} $的值。

对于限制集A，参数给定为

- for $ { {N} *{}}<{ { {L}* {}}}/{3}; $

$$
nshiftRA=⌊du/NCS⌋dstart=2du+nshiftRANCSngroupRA=⌊LRA/dstart⌋n¯shiftRA=max(⌊(LRA−2du−ngroupRAdstart)/NCS⌋,0)
$$

- for $L/3;/2;$

$$
nshiftRA=⌊(LRA−2du)/NCS⌋dstart=LRA−2du+nshiftRANCSngroupRA=⌊du/dstart⌋n¯shiftRA=min(max(⌊(du−ngroupRAdstart)/NCS⌋,0),nshiftRA)
$$

对于限制集B，参数给定为

- for $ { {N} *{}}<{ { {L}* {}}}/{5}; $

$$
nshiftRA=⌊du/NCS⌋dstart=4du+nshiftRANCSngroupRA=⌊LRA/dstart⌋n¯shiftRA=max(⌊(LRA−4du−ngroupRAdstart)/NCS⌋,0)
$$

- for $L/5;/;$

$$
nshiftRA=⌊(LRA−4du)/NCS⌋dstart=LRA−4du+nshiftRANCSngroupRA=⌊du/dstart⌋n¯shiftRA=min(max(⌊(du−ngroupRAdstart)/NCS⌋,0),nshiftRA)
$$

- for $ {({ {L} *{}}+{ {N}* {}})}/{4};<{2{ {L}\_{}}}/{7}; $

$$
nshiftRA=⌊(4du−LRA)/NCS⌋dstart=4du−LRA+nshiftRANCSd¯¯start=LRA−3du+ngroupRAdstart+n¯shiftRANCSd¯¯¯start=LRA−2du+ngroupRAdstart+n¯¯shiftRANCSngroupRA=⌊du/dstart⌋n¯shiftRA=max(⌊(LRA−3du−ngroupRAdstart)/NCS⌋,0)n¯¯shiftRA=⌊min(du−ngroupRAdstart,4du−LRA−n¯shiftRANCS)/NCS⌋n¯¯¯shiftRA=⌊((1−min(1,n¯shiftRA))(du−ngroupRAdstart)+min(1,n¯shiftRA)(4du−LRA−n¯shiftRANCS))/NCS⌋−n¯¯shiftRA
$$

- for $2L/7;/3;$

$$
nshiftRA=⌊(LRA−3du)/NCS⌋dstart=LRA−3du+nshiftRANCSd¯¯start=du+ngroupRAdstart+n¯shiftRANCSd¯¯¯start=0ngroupRA=⌊du/dstart⌋n¯shiftRA=max(⌊(4du−LRA−ngroupRAdstart)/NCS⌋,0)n¯¯shiftRA=⌊min(du−ngroupRAdstart,LRA−3du−n¯shiftRANCS)/NCS⌋n¯¯¯shiftRA=0
$$

- for $ {({ {L} *{}}+{ {N}* {}})}/{3};<{2{ {L}\_{}}}/{5}; $

$$
nshiftRA=⌊(3du−NZC)/NCS⌋dstart=3du−NZC+nshiftRANCSd¯¯start=0d¯¯¯start=0ngroupRA=⌊du/dstart⌋n¯shiftRA=max(⌊(LRA−2du−ngroupRAdstart)/NCS⌋,0)n¯¯shiftRA=0n¯¯¯shiftRA=0
$$

- for $2L/5;/2;$

$$
nshiftRA=⌊(NZC−2du)/NCS⌋dstart=2(NZC−2du)+nshiftRANCSd¯¯start=0d¯¯¯start=0ngroupRA=⌊(LRA−du)/dstart⌋n¯shiftRA=max(⌊(3du−LRA−ngroupRAdstart)/NCS⌋,0)n¯¯shiftRA=0n¯¯¯shiftRA=0
$$

对于所有其他 $du$ 的值，限制集中无循环移位。

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171229/112954192.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171229/113036188.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171229/113143413.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171229/113251910.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171229/113318908.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171229/113341808.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171229/113400040.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171229/113418389.png)

## 物理资源映射

  
前导序列应根据以下方式映射到物理资源

$$
ak(p,RA)=βPRACHyu,v(k)k=0,1,...,LRA−1
$$

其中与声明为“保留”的资源重叠的物理资源应计入映射过程但不用于传输，$ { {}\_{}} $是幅值因子，天线端口$ p=4000 $。基带信号的产生应按照38.211的5.3节进行，使用表6.3.3.1−1或表6.3.3.1−2中的参数，$ {k} $由表6.3.3.2-1给出。

随机接入前导只能根据表6.3.3.2-2的高层参数 *PRACHConfigurationIndex* 给定的时间和频率资源上进行传输。该表取决于38.101中定义的FR1或FR2（频率范围FR的定义见本文附录）以及频谱类型。为了表中的时隙编号的目的，应该假定下面的子载波间隔：

- $15$ 用于PRACH前导格式0-3
- $ 15 $用于PRACH前导格式A1，A2，A3，B1，B2，B3，B4，C0，C2，其中$ $是PRACH子载波间隔配置
![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171229/150255196.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171229/150334167.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171229/150402629.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171229/150424741.png)

## 随机接入过程

  
在开始物理随机接入过程之前，L1必须从高层接收一组SSB索引，并且应该向高层提供相应的一组RSRP测量值。

在开始物理随机接入过程之前，L1应从高层接收以下信息：

- 物理随机接入信道（PRACH）传输参数（用于PRACH传输的PRACH前导格式，时间资源和频率资源）的配置。
- 用于确定PRACH前导序列集合中的根序列及其循环移位的参数（逻辑根序列索引表，循环移位（ ）和集合类型（非限制集，限制集A或限制集B））

从物理层的角度来看，L1随机接入过程包括PRACH中的随机接入前导（Msg1）的传输，PDSCH（Msg2）中的随机接入响应（RAR），Msg3 PUSCH和PDSCH中的竞争解决（Msg4）。

如果UE没有被配置有两个UL载波，并且通过“PDCCH order”向UE发起随机接入过程，则随机接入前导传输与由高层发起的随机接入前导传输具有相同的子载波间隔。

如果UE配置有针对服务小区的两个UL载波，并且UE检测到“PDCCH order”，则UE使用检测到的“PDCCH order”的UL/SUL指示域的值来确定用于对应的随机接入前导传输的UL载波，和随机接入前导传输与UE被配置用于对应UL载波的子载波间隔。

## 随机接入前导

  
L1过程在高层请求PRACH传输时被触发。PRACH传输的高层配置包括以下内容：

- 用于PRACH传输的配置\[TS38.211\]
- 前导索引，前导子载波间隔， $P$ ，相应的RA-RNTI和PRACH资源

在所指示的PRACH资源上，使用所选择的PRACH格式和发送功率 $P$ 发送前导序列。

UE确定传输周期 $i$ 服务小区 $c$ 载波 $f$ 上的PRACH的传输功率为：

$$
PPRACH,f,c(i)=min{PCMAX,f,c(i), PPRACH,target+PLf,c}dBm
$$

其中$ { {P} *{f,c}}(i) $是在38.101中定义的传输周期$ i $服务小区$ c $载波$ f $上的UE发送功率，$ { {P}* {}} $是由高层参数∗preambleReceivedTargetPower∗提供的PRACH目标接收功率，$ P{ {L}\_{f,c}} $是由UE计算的服务小区$ c $载波$ f$上的路径损耗，以dB为单位计算为 *referenceSignalPower* ——高层滤波器RSRP，其中RSRP在38.215中定义，高层滤波器的配置则在38.331中定义。 *referenceSignalPower* 等于 *SS-PBCHBlockPower* ，其中 *SS-PBCHBlockPower* 由SIB1提供。

如果UE发送PRACH以传送链路重配置请求，如38.213第6章所述， $P$ 由高层参数 *preambleReceivedTargetPower-BFR* 提供。

如果在随机接入响应窗口内，如2.2节所述，若UE未收到包含着与UE发送的前导序列相对应的前导ID的随机接入响应，则UE应当确定后续PRACH传输的传输功率（如果有的话，如38.321所述）。

## 随机接入响应（RAR)

  
对PRACH响应的传输，UE在高层（38.321）控制的窗口期间尝试检测具有相应RA-RNTI的PDCCH。窗口从Type1-PDCCH公共搜索空间的最早的CORESET的第一个符号开始，也即在前导序列传输的最后一个符号之后$ { {/{ { {T} *{sf}}}; }^{ {}}}/{( N* {} <sup>{}N_{}</sup> {} )}; $个符号。基于Type0-PDCCH公共搜索空间的子载波间隔和CP，窗口长度的时隙数由高层参数 *rar-WindowLength* 提供。

如果UE在窗口内检测到具有对应的RA-RNTI的PDCCH和相应的DL-SCH传输块，则UE将传输块传递到高层。高层针对与PRACH传输相关联的随机接入前导标识（RAPID）解析传输块，并且如果RAPID被识别，则向物理层指示上行授权。UE应接收PDCCH和PDSCH，其中PDSCH包含的DL-SCH传输块具有与PDCCH Type0-PDCCH公共搜索空间的接收相同的子载波间隔和相同的循环前缀，并且与DM-RS天线端口具有QCL性质（38.214）。

除非UE已配置子载波间隔，否则UE使用与提供RAR的PDSCH相同的子载波间隔以接收后续的PDSCH。

如果UE在窗口内未检测到PDDCH或对应的DL-SCH传输块，则UE过程如38.321中所述。

## Msg3 PUSCH

  
高层参数 *msg3-tp* 向UE指示UE是否应当对Msg3 PUSCH传输应用变换预编码（如38.211中所述）。

Msg3 PUSCH传输的子载波间隔由高层参数 *msg3-scs* 提供。UE将在同一个服务小区上发送PRACH和Msg3 PUSCH。

用于Msg3 PUSCH传输的UL BWP由SIB1指示。

## 附录

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171229/151344428.png)

> 本文参考3GPP TS38.211 V2.0.0 (2017-12)