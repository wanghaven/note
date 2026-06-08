---
title: "5G 帧结构、物理资源与物理信道"
source: "https://marshallcomm.cn/2017/12/17/nr-v200-l1-channel-modulation/"
published: 2017-12-17
created: 2025-12-12
---
## 帧结构与物理资源

## 概述

  
在本规范中，除非另有说明，时域中各个域的大小表示为若干时间单位$ { {T} *{}}={1}/{( )}; $，其中$ =480 $，$ { {N}* {}}=4096 $。常量$ ={ { {T} *{}}}/{ { {T}* {}}};=64 $，其中$ { {T} *{}}={1}/{( )}; $，$ =15 $，$ { {N}* {}}=2048 $。

## 参数集

  
如Table 4.2-1所示，NR支持多种OFDM参数集。部分载波带宽（carrier bandwidth part，BWP）的$$和CP由高层参数给定，其中下行链路由 *DL\_BWP\_mu* 和 *DL\_BWP\_cp* 给定，上行链路由 *UL\_BWP\_mu* 和 *UL\_BWP\_cp* 给定。

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171217/103110923.png)

## 帧结构

### 帧和子帧

  
一帧的时域为$ { {T} *{}}=( {}/{100}; )=10 $，一帧包含10个子帧，每个子帧时域为$ { {T}* {}}=( {}/{1000}; )=1 $。每个子帧内连续的OFDM符号数为$ N\_{} <sup>{,}=N_{}</sup> {}N\_{}^{,} $。每帧分为两个相等大小的半帧，每个半帧包含5个子帧，即半帧0由子帧0-4组成，半帧1由子帧5-9组成。

根据\[38.133\]，来自UE的上行帧应在UE对应的下行帧开始前传输。

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171217/103249131.png)

### 时隙

  
对于子载波间隔配置$ $，时隙在子帧内按递增顺序编号为$ n\_{}^{}{ 0,...,N\_{}^{}-1 } $，在帧内按递增顺序编号为$ n\_{}^{}{ 0,...,N\_{}^{}-1 } $。一个时隙内有$ N\_{}^{} $个连续的OFDM符号，其中$ N\_{}^{} $的值取决于CP长度，CP长度由Tables 4.3.2-1 and 4.3.2-2给定。一个子帧内的起始时隙与这个子帧内起始OFDM符号在时间上对齐。

时隙内的OFDM符号被分为“downlink”（在Table 4.3.2-3中表示为D）、“flexible”（表示为X）或“uplink”（表示为U）。

在下行时隙，UE应假定下行传输仅发生在downlink符号或flexible符号。

在上行时隙，UE应仅在uplink符号或flexible符号发送。

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171217/103550091.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171217/103613538.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171217/103715352.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171217/103753007.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171217/103829112.png)

## 物理资源

### 天线端口

  
天线端口定义为，在同一个天线端口上，传输某一符号的信道可以从传输另一个符号的信道推知。

若在一个天线端口上传输的某一符号的信道的大尺度特性，可以从另一个天线端口上传输的某一符号的信道推知，则这两个天线端口被称为是 **准共定位（quasi co-located，QCL）** 的。大尺度特性包括一个或多个时延扩展，多普勒扩展，多普勒频移，平均增益，平均时延，空间Rx参数。

### 资源格

  
对于每个参数集和载波，资源格（Resource grid）定义为$ N\_{x} <sup>{}N_{}</sup> {} $个子载波和$ N\_{}^{,} $个OFDM符号，起始公共资源块（commonresourceblock）$ N\_{}^{,} $由高层信令指示。表示DL（downlink）或UL（uplink），在不会产生混淆时，下标可省略。每个天线端口$ p $、每个子载波间隔配置$ $以及每个传输方向（上行或下行），对应一个资源格。

### 资源粒子

  
天线端口$ p $和子载波间隔配置$ $的资源格中的每个元素被称为资源粒子（resourceelement），并且由索引对$ { {( k,l )} *{p,}} $唯一地标识，其中$ k $是频域索引，$ l $是时域符号索引。资源粒子$ { {( k,l )}* {p,}} $对应的复数值为$ a\_{k,l}^{(p,)} $。在不会产生混淆时，或在没有指定某一天线端口或子载波间隔时，索引$ p $和$ $可以省略，表示为$ a\_{k,l}^{(p)} $或$ { {a}\_{k,l}} $。

### 资源块

#### 概述

  
资源块（resource block）定义为 $N=12$ 个连续频域子载波。

#### 参考资源块

  
参考资源块（reference resource block）在频域上从0开始编号。参考资源块0的子载波0对于所有的子载波配置 是公共的，也被称为“参考点A”，并且用作其他资源块格的公共参考点。参考点A从以下高层参数获得

- *PRB-index-DL-common* for a PCell downlink
- *PRB-index-UL-common* for a PCell uplink
- *PRB-index-DL-Dedicated* for an SCell downlink
- *PRB-index-UL-Dedicated* for an SCell uplink
- *PRB-index-SUL-common* for a supplementary uplink

#### 公共资源块

  
公共资源块（common resource block）在子载波间隔配置$ $的频域上从0开始编号。子载波间隔配置$ $下的公共资源块0的子载波0与“参考点A”一致。

对于子载波间隔配置$ $，频域上的公共资源块号$ { {n}\_{}} $与资源粒子$ (k,l) $的关系为

$$
nCRBμ=⌊kNscRB⌋
$$

其中$ k $是相对于子载波间隔配置$ $下的资源格0的子载波0定义的。

#### 物理资源块

  
物理资源块（physical resource block）在BWP中定义，编号为从0到$ N\_{i}^{}-1 $，其中$ i $是BWP数。在BWP$ i $内，PRB与CRB的关系为

$$
nCRB=nPRB+NBWP,istart
$$

其中 $Ni$ 是BWP相对于公共资源块0的起始资源块。

#### 虚拟资源块

  
虚拟资源块（virtual resource block）在BWP中定义，编号为从0到$ N\_{i}^{}-1 $，其中$ i $是BWP数。

### BWP

  
BWP是在给定参数集和给定载波上的一组连续的物理资源块。BWP的起始位置$ N\_{i}^{} $和资源块数$ N\_{i}^{}>0 $应满足$ 0N\_{i} <sup>{}&lt;N_{x}</sup> {} $。

UE可以在下行链路中被配置多达四个BWP，并且在给定时间内只有一个DL BWP处于激活状态。UE不应在激活的BWP之外接收PDSCH，PDCCH，CSI-RS或TRS。

UE可以在上行链路中被配置多达四个BWP，并且在给定时间内只有一个UL BWP处于激活状态。如果UE配置有辅助（supplementary）上行链路，则UE可以在辅助上行链路中另外配置多达四个BWP，并且在给定时间内只有一个辅助UL BWP处于激活状态。UE不应在激活的BWP之外传输PUSCH或PUCCH。

## 载波聚合

  
多个小区的传输可以被聚合起来，除了主小区之外最多可聚合15个次级小区。除非另有说明，本规范中的描述适用于多达16个服务小区中的每一个。

## 通用函数

## 上行链路

## 概述

### 物理信道概述

- 物理上行共享信道（PUSCH）
- 物理上行控制信道（PUCCH）
- 物理随机接入信道（PRACH）

### 物理信号概述

- 解调参考信号（DM-RS）
- 相位跟踪参考信号（PT-RS）
- 探测参考信号（SRS）

## 物理资源

  
当UE进行上行传输时，使用的帧结构和物理资源在第4章定义。

定义下列天线端口用于上行链路：

- PUSCH相关的DMRS使用以1000为起始的天线端口
- PUCCH相关的DMRS使用以2000为起始的天线端口
- PRACH使用天线端口4000

## 下行链路

## 概述

### 物理信道概述

- 物理下行共享信道（PDSCH）
- 物理广播信号（PBCH）
- 物理下行控制信道（PDCCH）

### 物理信号概述

- 解调参考信号（DM-RS）
- 相位跟踪参考信号（PT-RS）
- 信道状态信号参考信号（CSI-RS）
- 主同步信号（PSS）
- 辅同步信号（SSS）

## 物理资源

  
当接收下行链路发送的数据时，UE应假定采用第4章定义的帧结构和物理资源。

定义下列天线端口用于下行链路：

- PDSCH相关的DM-RS使用以1000为起始的天线端口
- PDCCH相关的DM-RS使用以2000为起始的天线端口
- CSI-RS使用以3000为起始的天线端口
- SS/PBCH块传输使用以4000为起始的天线端口

> 本文参考3GPP TS38.211 V2.0.0 (2017-12)