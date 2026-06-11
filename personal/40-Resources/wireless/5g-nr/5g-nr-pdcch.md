---
title: "5G PDCCH"
source: "https://marshallcomm.cn/2017/12/30/nr-v200-l1-pdcch/"
published: 2017-12-30
created: 2025-12-12
---
## CCE
  
PDCCH由一个或多个控制信道单元（control-channel element，CCE）组成，见Table 7.3.2.1-1。

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171230/110738019.png)

## CORESET

  
控制资源集（control-resource set，CORESET）由$ N\_{}^{} $个频域RBs和$ N\_{}^{}{ 1,2,3 } $个时域符号组成，$ N\_{}^{} $的值由高层参数∗CORESET−freq−dom∗给定，$ N\_{}^{} $的值由高层参数∗CORESET−time−dur∗给定，其中仅当高层参数∗DL−DMRS−typeA−pos=3∗时才支持$ N\_{}^{}=3 $。

1个CCE由6个资源粒子组（resource-element group，REG）组成，1个REG等于1个OFDM符号上的1个RB。CORESET内的REGs以时域优先的方式按升序编号，从CORESET中第1个OFDM符号且编号最小的RB以0开始编号。

UE可配置多个CORESETs，每个CORESET仅对应一种CCE-to-REG映射。

CORESET中CCE-to-REG映射可以是交织的或非交织的，这由高层参数 *CORESET-CCE-REG-mapping-type* 来配置，并且由REG捆绑（REG bundle）来描述：

- REG bundle $i$ 定义为一组REGs $ { iL,iL+1,...,iL+L-1 } $，其中$ L $是REGbundle大小，$ i=0,1,...,{N\_{}^{}}/{L};-1 $，且$ N\_{} <sup>{}=N_{}</sup> {}N\_{}^{} $是CORESET中REG的数目；
- CCE $j$ 由一组REG bundles $ { f({6j}/{L};),f({6j}/{L};+1),...,f({6j}/{L};+{6}/{L};-1) } $组成，其中$ f() $是交织器

对于非交织CEE-to-REG映射，$ L=6 $且$ f(j)=j $。

对于交织CEE-to-REG映射，当$ N\_{}^{}=1 $时，有$ L{ 2,6 } $；当$ N\_{}^{}{ 2,3 } $时，有$ L{ N\_{}^{},6 } $，其中$ L $由高层参数 *CORESET-REG-bundle-size* 配置。交织器定义为

$$
f(j)=(rC+c+nshift)mod(NREGCORESET/L)j=cR+rr=0,1,...,R−1c=0,1,...,C−1C=⌈NREGCORESET/(LR)⌉
$$

其中 $R2,3,6$ 由高层参数 *CORESET-interleaver-size* 给定，且

- $ { {n} *{}} $是物理层小区ID$ N* {}^{} $ 的函数
- $n0,1,...,274$ 是高层参数 *CORESET-shift-index* 的函数

UE可假定（频域预编码颗粒度）

- 如果高层参数 *CORESET-precoder-granularity* 等于CORESET-REG-bundle-size，则在REG bundle中，在频域上使用相同的预编码；
- 如果高层参数 *CORESET-precoder-granularity* 等于CORESET频域大小，则在CORESET中的连续RBs内的所有REGs中，在频域上使用相同的预编码

对于PBCH配置的CORESET， $L=6$ 。

## 加扰

  
UE应假定比特块$ b(0),...,b(M\_{}^{ {}}-1) $在调制前进行加扰，其中$ M\_{}^{ {}} $是PDCCH传输的比特数，加扰后的比特块为$ (0),...,(M\_{}^{ {}}-1) $

$$
b~(i)=(b(i)+c(i))mod2
$$

其中扰码序列 $c(i)$ 在38.211的5.2.1节给定。

## 调制

  
UE应假定比特块$ (0),...,({ {M} *{}}-1) $采用QPSK调制，得到复值调制符号块$ d(0),...,d({ {M}* {}}-1) $。QPSK调制见38.211的5.1.3节。

## 物理资源映射

  
在用于所监测的PDCCH的REGs中，UE应假定复值符号块$ d(0),...,d({ {M} *{}}-1) $乘以幅值因子$ { {}* {}} $，并按照先$ k $再$ l $的递增顺序依次映射到资源粒子$ { {( k,l )}\_{p,}} $。

## UE接收控制信息的过程

  
如果UE配置了辅小区群（Secondary Cell Group，SCG），则UE应对主小区群（Master Cell Group，MCG）和SCG应用本章所描述的过程

- 当这一过程应用于 **MCG** 时，本章所提及的‘secondary cell’，‘secondary cells’，‘serving cell’，‘serving cells’是分别属于 **MCG** 的secondary cell，secondary cells，serving cell，serving cells。
- 当这一过程应用于 **SCG** 时，本章所提及的‘secondary cell’，‘secondary cells’，‘serving cell’，‘serving cells’是分别属于 **SCG** 的secondary cell，secondary cells（不包括PSCell），serving cell，serving cells。本章所提及的‘primary cell’指的是SCG的PSCell。

UE将根据对应的搜索空间，监测每个激活的服务小区上激活的DL BWP上的一个或多个CORESET（控制资源集）中的一组PDCCH候选。监测搜索空间意味着UE根据所监测的DCI格式对每个PDCCH候选进行译码。

UE可以通过高层参数 *SSB-periodicity-serving-cell* 配置用于在服务小区中发送SSB的半帧的周期。如果UE接收到 *SSB-transmitted-SIB1* 但未接收到 *SSB-transmitted* ，并且如果用于PDCCH接收的RE与对应于由 *SSB-transmitted-SIB1* 指示的SSB索引的RE重叠，则UE通过排除与由 *SSB-transmitted-SIB1* 指示的SSB索引相对应的RE来接收PDCCH。如果UE接收到 *SSB-transmitted* ，并且如果用于PDCCH接收的RE与对应于由 *SSB-transmitted* 指示的SSB索引的RE重叠，则UE通过排除与 *SSB-transmitted* 所指示的SSB索引相对应的RE来接收PDCCH。

## 确定PDCCH分配的UE过程

  
PDCCH搜索空间定义为UE监测的一组PDCCH候选。搜索空间可以是公共搜索空间（CSS）或UE特定搜索空间（USS）。UE将在以下一个或多个搜索空间中的连续接收时隙中监测PDCCH候选

- 在PCell上，CRC通过SI-RNTI加扰的DCI格式的Type0-PDCCH公共搜索空间
- 在PCell上，CRC通过SI-RNTI加扰的DCI格式的Type0A-PDCCH公共搜索空间
- 在PCell上，CRC通过RA-RNTI或TC-RNTI或C-RNTI加扰的DCI格式的Type1-PDCCH公共搜索空间
- 在PCell上，CRC通过P-RNTI加扰的DCI格式的Type2-PDCCH公共搜索空间
- 在PCell上，CRC通过INT-RNTI或SFI-RNTI或TPC-PUSCH-RNTI或TPC-PUCCH-RNTI或TPC-SRS-RNTI或C-RNTI或CS-RNTI(s)加扰的DCI格式的Type3-PDCCH公共搜索空间
- CRC通过C-RNTI或CS-RNTI(s)加扰的DCI格式的UE特定搜索空间

通过用于PDCCH接收的高层参数 *RMSI-PDCCH-Config* 和 *RMSI-sc* 提供的子载波间隔，为UE提供用于Type0-PDCCH公共搜索空间的CORESET的配置。UE确定Type0-PDCCH公共搜索空间的CORESET和监测时机。Type0-PDCCH公共搜索空间由表10.1-1中给出的CCE聚合等级和每个CCE聚合等级的候选数量来定义。

UE可假定与Type0-PDCCH和Type2-PDCCH公共搜索空间中的PDCCH接收和相应的PDSCH接收相关联的DM-RS天线端口，以及与SSB接收相关联的DM-RS天线端口是关于延迟扩展，多普勒扩展，多普勒频移，平均延迟和空间Rx参数QCL的。

Type0A-PDCCH或Type-2 PDCCH公共搜索空间的CORESET与Type0-PDCCH公共搜索空间的CORESET相同。UE通过高层参数 *osi-SearchSpace* 获得Type0A-PDCCH公共搜索空间的配置。UE通过高层参数 *paging-SearchSpace* 获得Type2-PDCCH公共搜索空间的配置。

用于Type0A-PDCCH或Type1-PDCCH或Type-2公共搜索空间的PDCCH子载波间隔和CP长度与用于Type0-PDCCH公共搜索空间的PDCCH相同。

UE可假定与Type0A-PDCCH公共搜索空间中的PDCCH接收相关联的DM-RS天线端口和与SSB接收相关联的DM-RS天线端口是关于延迟扩展，多普勒扩展，多普勒频移，平均延迟和空间Rx参数QCL的。

UE可假定在Type1-PDCCH公共搜索空间中，与PDCCH接收和相应的PDSCH接收相关联的DM-RS天线端口，和相应的PRACH相关联的SSB接收的DM-RS天线端口是QCL的。

如果SIB1中的参数 *PDCCH-DMRS-Scrambling-ID* 未提供用于Type0A-PDCCH或Type1-PDCCH或Type-2 PDCCH公共搜索空间的DM-RS加扰序列初始化的值，则该加扰序列初始化值为小区ID。

如果UE被配置用于DL BWP操作，则公共搜索空间的上述配置适用于初始激活DL BWP。除了初始激活DL BWP以外，UE可另外为PCell上的每个DL BWP配置Type0-PDCCH，Type0A-PDCCH，Type1-PDCCH或Type2-PDCCH公共搜索空间的CORESET。

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171231/132155978.png)

对于一个服务小区，高层信令为UE提供 $P$ 个CORESET。对于映射有UE特定搜索空间，Type2-PDCCH或Type3-PDCCH公共搜索空间的CORESET $ P $，$ 0p<P $，高层信令提供：

- 高层参数 *CORESET-ID* 提供的CORESET索引；
- 高层参数 *PDCCH-DMRS-Scrambling-ID* 提供的DM-RS加扰序列初始化值；
- 高层参数 *CORESET-time-duration* 提供的连续符号数目；
- 高层参数 *CORESET-freq-dom* 提供的RB数目；
- 高层参数 *CORESET-CCE-to-REG-mapping-type* 提供的CCE-to-REG映射类型；
- 高层参数 *CORESET-REG-bundle-size* 提供的CCE-to-REG交织映射下的REG bundle大小；
- 高层参数 *CORESET-shift-index* 提供的REG bundle交织器的循环移位；
- 天线端口QCL（高层参数TCI-StatesPDCCH提供的一组天线端口QCLs）指示用于PDCCH接收的DM-RS天线端口的QCL信息;
- 通过高层参数 *TCI-PresentInDCI* 指示由CORESET $p$ 中通过PDCCH发送的DCI format1\_0或DCI format1\_1的传输配置指示（TCI）字段的存在或不存在

对于在服务小区的DL BWP中设置的每个CORESET，相应的高层参数 *CORESET-freq-dom* 提供了一个位图（bitmap）。该bitmap的比特与若干非重叠的PRB组具有一对一映射，其中每个PRB组有6个PRBs。带宽为$ N\_{}^{} $个PRBs的DLBWP中的PRB索引按升序编号，其中第一组的第一个PRB的索引为$ 6/{6}; $。

如果UE没有从 *TCI-StatesPDCCH* 提供的一组天线端口QCL中接收到天线端口QCL的指示，则UE假定UE特定搜索空间中与PDCCH接收相关联的DM-RS天线端口与PBCH接收相关联的DM-RS天线端口关于延迟扩展，多普勒扩展，多普勒频移，平均延迟和空间Rx参数是QCL的。

对于UE被配置为在Type0-PDCCH公共搜索空间之外的搜索空间中监测PDCCH的每个服务小区，UE配置如下：

- 高层参数 *search-space-config* 提供的搜索空间集的数目；
- 对于CORESET $p$ 中的每个搜索空间集
	- 高层参数 *Common-search-space-flag* 提供的所述搜索空间集为公共搜索空间集或UE特定搜索空间集的指示；
	- 每个CCE聚合等级 $L$ 下的PDCCH候选数目 $Mp(L)$ ，其中聚合等级1、2、4、8、16分别由高层参数 *Aggregation-level-1* 、 *Aggregation-level-2* 、 *Aggregation-level-4* 、 *Aggregation-level-8* 和 *Aggregation-level-16* 指示。
	- 高层参数 *Monitoring-periodicity-PDCCH-slot* 提供的PDCCH监测周期 $kp$ 个时隙
	- 高层参数 *Monitoring-symbols-PDCCH-within-slot* 提供的PDCCH在时隙内的监测模式，用于指示PDCCH监测时隙内CORESET的第一个符号

UE根据时隙内的PDCCH监测周期，PDCCH监测偏移和PDCCH监测模式来确定PDCCH监测时机。

CCE聚合等级$ L{ 1, 2, 4, 8, 16 } $下的PDCCHUE特定搜索空间$ S\_{ { {k}\_{p}}}^{(L)} $定义为一组CCE聚合等级为$ L$的PDCCH候选。

如果UE为服务小区配置了高层参数 *CrossCarrierSchedulingConfig* ，则载波指示域的值有对应的 *CrossCarrierSchedulingConfig* 的值指示。

对于UE在UE特定搜索空间上监测PDCCH候选的服务小区，如果UE没有配置载波指示域，则UE应在无载波指示域条件下监测PDCCH候选。对于UE在UE特定搜索空间上监测PDCCH候选的服务小区，如果UE配置有载波指示域，则UE将在具有载波指示域条件下监测PDCCH候选。

如果UE被配置为监测具有与另一个服务小区中的SCell相对应的载波指示域的PDCCH候选，则UE不期望监测SCell上的PDCCH候选。对于UE监测PDCCH候选的服务小区，UE至少要监测同一个服务小区的PDCCH候选。

对于CORESET $p$ ，与载波指示域的值对应的服务小区的搜索空间的PDCCH候选所对应的CCEs由下式给出：

$$
L⋅{(Yp,kp+⌊mnCI⋅NCCE,pL⋅Mp,max(L)⌋+nCI)mod⌊NCCE,p/L⌋}+i
$$

其中

对于任何公共搜索空间，$ { {Y} *{p,{ {k}* {p}}}}=0 $；

对于UE特定搜索空间，$ { {Y} *{p,{ {k}* {p}}}}=( { {A} *{p}} )D $，$ { {Y}* {p,-1}}={ {n} *{}} $，$ { {A}* {0}}=39827 $，$ { {A}\_{1}}=39829 $，$ D=65537 $；

$i=0,,,,L−1$ ；

如果UE配置有监测PDCCH的服务小区的载波指示域，则$ { {n} *{CI}} $是载波指示域的值；否则，$ { {n}* {CI}}=0 $（包括任何公共搜索空间）；

$ { {N} *{,p}} $是CORESET $p$ 内的CCE数量，编号从0到$ { {N}* {,p}}-1 $；

$ { {m} *{ { {n}* {CI}}}}=0,,...,,M\_{p,{ {n} *{CI}}}^{(L)}-1 $，其中$ M* {p,{ {n} *{CI}}}^{(L)} $是UE被配置为监测$ { {n}* {CI}} $对应的服务小区的聚合等级$ L$的PDCCH候选的数量；

对于任何公共搜索空间，$ M\_{p,} <sup>{(L)}=M_{p,0}</sup> {(L)} $；

对于UE特定搜索空间，$ M\_{p,}^{(L)} $是$ M\_{p,{ {n}\_{CI}}}^{(L)} $的最大值，

$Mp,(L)$ 是CORESET $p$ 中CCE聚合等级 $L$ 的所有配置$ { {n} *{CI}} $值的所有对应DCI格式的$ M* {p,{ {n}\_{CI}}}^{(L)} $的最大值；

RNTI的值 $n$ 在38.212和38.214中定义。

UE配置为在DCI格式大小具有载波指示域和由C-RNTI加扰的CRC的服务小区中监测PDCCH候选，PDCCH候选对于DCI格式大小可以具有载波指示域的一个或多个可能值，应假定具有DCI格式大小的PDCCH候选可以在对应于DCI格式大小的载波指示域的任何可能值的任何PDCCH UE特定搜索空间中的服务小区中被发送。

## 监测Type0-PDCCH公共搜索空间的UE过程

  
UE从表13-1至表13-8中描述的 *RMSI-PDCCH-Config* 的前4个比特中确定Type0-PDCCH公共搜索空间的CORESET的连续RB的数量和连续符号的数量；如表13-9至表13-13中所述，从 *RMSI-PDCCH-Config* 的后4位确定PDCCH监测时机，其中，$ $和$ { {n} *{}} $分别是CORESET的SFN和时隙，$ $和$ { {n}* {}} $分别是SSB的SFN和时隙。

表13-1至表13-8中的偏移量是根据CORESET的子载波间隔定义的，该偏移量是SSB的最小RB索引与用于Type0-PDCCH公共搜索空间的CORESET的最小RB索引之间的差值。表13-1至13-8中的条件A或条件B分别对应于SSB RBs和Type0-PDCCH公共搜索空间的CORESET RBs之间的PRG \[38.214\]对齐或不对齐的情况。

对于第一个SSB和CORESET复用模式，UE在两个连续时隙$ { { {n} *{}},,{ {n}* {}}+1 } $上监测Type0−PDCCH公共搜索空间中的PDCCH。对于具有索引$ i $的SSB，UE决定第一个时隙的索引$ { {n} *{}} $位于一定的系统帧号（SFN），且$ { {n}* {}}=( O+iM )N\_{}^{,} $。若$ /{N\_{}^{,}}; $，则该系统帧号满足$ =0 $；若$ /{N\_{}^{,}}; $，则该系统帧号满足$ =1 $。

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171231/135655440.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171231/135734082.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171231/135823895.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171231/135853964.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171231/140008216.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171231/140121486.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171231/140208704.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171231/140245627.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171231/140336520.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171231/140439064.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171231/140920630.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171231/140959705.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171231/141044288.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171231/141110766.png)