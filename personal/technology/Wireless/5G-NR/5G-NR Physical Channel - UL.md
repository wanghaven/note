---
title: "5G-NR物理信道与调制-上行链路v1.1.0"
source: "https://marshallcomm.cn/2017/10/23/nr-v110-l1-channel-modulation-ul/"
published: 2017-10-23
created: 2025-12-12
description: "上接《5G-NR物理信道与调制v1.1.0》上行链路 Scope References Definitions, symbols and abbreviations 帧结构与物理资源 通用函数 上行链路 概述 物理信道概述 上行链路物理信道对应于一组资源粒子（REs）的集合，用于承载源自高层的信息。本规范定义了如下上行信道：  物理上行共享信道（PUSCH） 物理上行控制"
---
## 帧结构与物理资源

## 通用函数

## 上行链路

## 概述

### 物理信道概述

  
上行链路物理信道对应于一组资源粒子（REs）的集合，用于承载源自高层的信息。本规范定义了如下上行信道：

- 物理上行共享信道（PUSCH）
- 物理上行控制信道（PUCCH）
- 物理随机接入信道（PRACH）

### 物理信号概述

  
上行物理信号是物理层使用的，但不承载任何来自高层信息的信号。本规范定义了如下上行物理信号：

- 解调参考信号（Demodulation reference signals，DM-RS）
- 相位跟踪参考信号（Phase-tracking reference signals，PT-RS）
- 探测参考信号（Sounding reference signal，SRS）

### 物理资源

  
当UE进行上行传输时，使用的帧结构和物理资源在第4章定义。

定义下列天线端口用于上行链路：

- PUSCH相关的DMRS使用以1000为起始的天线端口
- PUCCH相关的DMRS使用以2000为起始的天线端口
- SRS使用以3000为起始的天线端口
- PRACH使用天线端口4000

## 物理信道

### PUSCH

#### 加扰

  
对于每个码字$ q $，比特块$ { {b}^{(q)}}(0),...,{ {b} <sup>{(q)}}(M_{}</sup> {(q)}-1) $在调制之前应当被加扰，其中$ M\_{}^{(q)} $是在物理信道上传输的码字$ q $的比特数。加扰的比特块$ { {}^{(q)}}(0),...,{ {} <sup>{(q)}}(M_{}</sup> {}-1) $由下式得到

$$
b~(q)(i)=(b(q)(i)+c(q)(i))mod2
$$

其中加扰序列 $c(q)(i)$ 在5.2节给定。

#### 调制

  
对于每个码字$ q $，加扰比特块$ { {}^{(q)}}(0),...,{ {} <sup>{(q)}}(M_{}</sup> {}-1) $应按照5.1节所描述的方法进行调制，调制方案见Table6.3.1.2−1，得到复值调制符号块$ { {d}^{(q)}}(0),...,{ {d} <sup>{(q)}}(M_{}</sup> {}-1) $。

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171023/184452630.png)

#### 层映射

  
每个码字的复值调制符号根据Table 7.3.1.3-1应被映射到至多4个层。码字$ q $的复值调制符号$ { {d}^{(q)}}(0),...,{ {d} <sup>{(q)}}(M_{}</sup> {}-1) $应被映射到层$ x(i)={ {}^{T}} $，$ i=0,1,...,M\_{}^{}-1 $，其中$ $是层数，$ M\_{}^{} $是每层的调制符号数。

#### TF预编码

  
如果不启用TF预编码（transform precoding），对于每个$,1,...,$有$ { {y}^{()}}(i)={ {x}^{()}}(i) $。

如果启用TF预编码，此时$ $，则单层$ $下复值符号块$ { {x}^{(0)}}(0),...,{ {x} <sup>{(0)}}(M_{}</sup> {}-1) $被分为$ {M\_{} <sup>{}}/{M_{}</sup> {}}; $个集，每个集对应1个OFDM符号。TF预编码由下列方法得到

$$
y(0)(l⋅MscPUSCH+k)=1MscPUSCH∑i=0MscPUSCH−1x(0)(l⋅MscPUSCH+i)e−j2πikMscPUSCHk=0,...,MscPUSCH−1l=0,...,Msymblayer/MscPUSCH−1
$$

得到复值符号块$ { {y}^{(0)}}(0),...,{ {y} <sup>{(0)}}(M_{}</sup> {}-1) $。$ M\_{} <sup>{}=M_{}</sup> {}N\_{}^{} $，其中$ M\_{}^{} $表示PUSCH带宽（RB），应满足

$$
MRBPUSCH=2α2⋅3α3⋅5α5
$$

其中$ { {} *{2}},{ {}* {3}},{ {}\_{5}} $是非负整数集。

#### 预编码

  
矢量块$ { {}^{T}} $，$ i=0,1,...,M\_{}^{}-1 $应根据下式进行预编码

$$
[z(0)(i)⋮z(P−1)(i)]=W[y(0)(i)⋮y(υ−1)(i)]
$$

其中，$ i=0,1,...,M\_{}^{}-1 $，$ M\_{} <sup>{}=M_{}</sup> {} $。

对基于非码本的传输，预编码矩阵 $W$ 根据TS38.214中6.1.1节的描述得到。

对基于码本的传输，预编码矩阵 $W$ 由Table 6.3.1.5-1给定，其中TPMI index从调度上行传输的DCI中获得。

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171023/185715105.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171023/185758254.png)

#### 物理资源映射

  
对于PUSCH传输所使用的每个天线端口，复值符号块$ { {z}^{(p)}}(0),...,{ {z} <sup>{(p)}}(M_{}</sup> {}-1) $应乘以一个幅值因子$ { {} *{}} $，以符合TS38.213对发送功率$ { {P}* {}} $的规定，并且从$ { {z}^{(p)}}(0) $开始映射到资源粒子$ { {( k,l )}\_{p,}} $。这些REs满足下列条件：

- 这些REs存在于用于传输的已分配的资源中，
- 如果启用TF预编码，they are not in the OFDM symbols used for transmission
- 如果不启用TF预编码，they are not in the OFDM symbols used for transmission of the associated DM-RS

如果不启用TF预编码，或者如果是TF预编码但不进行跳频，那么对于其他目的的资源粒子$ { {( k,l )} *{p,}} $映射是不进行保留的，资源映射顺序为先天线端口$ p $，再频域子载波索引$ k $，然后是时域符号索引$ l $，初始值$ l={ {l}* {0}} $。

### PUCCH

  
PUCCH支持多种格式，如Table 6.3.2-1所示。对于单个UE，支持采用格式0或格式2的2个PUCCH同时传输，或支持采用格式1或格式3的其中一个PUCCH与采用格式0或格式2的其中一个PUCCH同时传输。

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171023/193240943.png)

#### PUCCH格式0

##### 序列选择

  
定义一组序列$ { 
$$
x0(n)x1(n)x2(n)x3(n)
$$

} $，每组序列长度为12。

比特块$ b(0),...,b({ {M} *{}}-1) $，其中$ { {M}* {}}{ 1,2 } $是PUCCH发送的比特数，应根据下列方法选择发送序列

$$
y(n)=xj(n)j=∑i=0Mbit−1b(i)⋅2i
$$

##### 物理资源映射

  
序列$ y(n) $应乘以一个幅值因子$ { {} *{}} $，以符合TS38.213对发送功率$ { {P}* {}} $的规定，并且从$ y(0) $开始映射到资源粒子$ 开始映射到资源粒子 $，在天线端口$ p=2000 $上，按递增顺序先$ k $后$ l$映射。

#### PUCCH格式1

##### 序列调制

  
比特块$ b(0),...,b({ {M} *{}}-1) $应按5.1节的描述进行调制，若$ { {M}* {}}=1 $则使用BPSK，若$ { {M}\_{}}=2 $则使用QPSK，得到复值符号$ d(0) $。

复值符号$ d(0) $按如下方式乘以序列$ r\_{u,v}^{({ {}\_{p}})}(n) $

$$
y(n)=d(0)⋅ru,v(α)(n)n=0,1,...,Nseq−1
$$

复值符号块$ y(0),...,y({ {N} *{}}-1) $应根据如下方式使用正交序列$ { {w}* {i}}(m) $进行块扩展（block-wise spread）

$$
z(m′NseqNSF+mNseq+n)=wi(m)⋅y(n)n=0,1,...,Nseq−1m=0,1,...,NSFm′−1m′={0no frequency hopping0,1frequency hopping enabled
$$

其中$ { {N} *{}}=N* {}^{} $。

正交序列 $wi(m)$ 在Table 6.3.2.2.1-1中给定。

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171023/193946445.png)

##### 物理资源映射

  
序列$ { {z}^{(p)}}(n) $应乘以一个幅值因子$ { {} *{}} $，以符合TS38.213对发送功率$ { {P}* {}} $的规定，并从$ { {z}^{(p)}}(0) $开始映射到资源粒子$ { {( k,l )}\_{p,}} $，这些REs应满足下列条件：

- 它们在被分配的用于传输的RB中
- 它们不能被DM-RS所使用

映射过程中不保留用于其他目的资源粒子$ { {( k,l )}\_{p,}} $，在天线端口$ p=2000 $上，按递增顺序先$ k $后$ l $映射。

#### PUCCH格式2

##### 加扰

  
比特块$ b(0),...,b(M\_{}^{ {}}-1) $，其中$ M\_{}^{ {}} $是物理信道发送的比特数，应在调制前按如下方式被加扰，得到加扰比特块$ (0),...,({ {M}\_{}}-1) $

$$
b~(q)(i)=(b(q)(i)+c(q)(i))mod2
$$

其中加扰序列 $c(q)(i)$ 由5.2节给定。

##### 调制

  
加扰比特块$ (0),...,({ {M} *{}}-1) $应按5.1节的描述进行QPSK调制，得到复值调制符号块$ d(0),...,d({ {M}* {}}-1) $。

##### 物理资源映射

  
调制符号块$ d(0),...,d({ {M} *{}}-1) $应乘以一个幅值因子$ { {}* {}} $，以符合TS38.213对发送功率$ { {P} *{}} $的规定，并从$ d(0) $开始映射到资源粒子$ { {( k,l )}* {p,}} $，这些REs应满足下列条件：

- 它们在被分配的用于传输的RB中
- 它们不能被DM-RS所使用

映射过程中不保留用于其他目的资源粒子$ { {( k,l )}\_{p,}} $，在天线端口$ p=2000 $上，按递增顺序先$ k $后$ l $映射。

#### PUCCH格式3

### PRACH

#### 序列生成

  
随机接入前导 $xu,v(n)$ 按如下方式生成

$$
xu,v(n)=xu((n+Cv)modLRA)xu(i)=e−jπui(i+1)LRA,i=0,1,...,LRA−1
$$

频域表示按以下方式生成

$$
yu,v(n)=∑m=0LRA−1xu,v(m)⋅e−j2πmnLRA
$$

其中$ { {L} *{}}=839 $或$ { {L}* {}}=139 $，并根据随机接入前导格式来确定，详见Tables6.3.3.1−1and6.3.3.1−2。循环移位$ { {C}\_{v}} $为

$$
Cv={vNCSv=0,1,...,⌊LRA/NCS⌋−1,NCS≠0for unrestricted sets0NCS=0for unrestrictedsetsdstart⌊v/nshiftRA⌋+(vmodnshiftRA)NCSv=0,1,...,w−1for restricted sets type A and Bd¯¯start+(v−w)NCSv=w,...,w+n¯¯shiftRA−1forrestricted sets type Bd¯¯¯start+(v−w−n¯¯shiftRA)NCSv=w+n¯¯shiftRA,...,w+n¯¯shiftRA+n¯¯¯shiftRA−1for restricted sets type Bw=nshiftRAngroupRA+n¯shiftRA
$$

其中 $N$ 由Tables 6.3.3.1-3到6.3.3.1-5给定，高层参数 *restrictedSetConfig* 决定受限集合类型，Tables 6.3.3.1-1和6.3.3.1-2指示不同前导格式下所支持的受限集合类型。

$du$ 的值为

$$
du={q0≤q<LRA/2LRA−qotherwise
$$

其中$ q $是满足$ ( qu )=1 $的最小非负整数。循环移位的受限集合参数依赖于$ { {d}\_{u}} $。

对于受限集合类型A，参数由下式给定：

- 对于$ { {N} *{}}<{ { {L}* {}}}/{3}; $

$$
nshiftRA=⌊du/NCS⌋dstart=2du+nshiftRANCSngroupRA=⌊LRA/dstart⌋n¯shiftRA=max(⌊(LRA−2du−ngroupRAdstart)/NCS⌋,0)
$$

- 对于 $L/3;/2;$

$$
nshiftRA=⌊(LRA−2du)/NCS⌋dstart=LRA−2du+nshiftRANCSngroupRA=⌊du/dstart⌋n¯shiftRA=min(max(⌊(du−ngroupRAdstart)/NCS⌋,0),nshiftRA)
$$

对于受限集合类型B，参数由下式给定：

- 对于$ { {N} *{}}<{ { {L}* {}}}/{5}; $

$$
nshiftRA=⌊du/NCS⌋dstart=4du+nshiftRANCSngroupRA=⌊LRA/dstart⌋n¯shiftRA=max(⌊(LRA−4du−ngroupRAdstart)/NCS⌋,0)
$$

- 对于 $L/5;/;$

$$
nshiftRA=⌊(LRA−4du)/NCS⌋dstart=LRA−4du+nshiftRANCSngroupRA=⌊du/dstart⌋n¯shiftRA=min(max(⌊(du−ngroupRAdstart)/NCS⌋,0),nshiftRA)
$$

- 对于$ {({ {L} *{}}+{ {N}* {}})}/{4};<{2{ {L}\_{}}}/{7}; $

$$
nshiftRA=⌊(4du−LRA)/NCS⌋dstart=4du−LRA+nshiftRANCSd¯¯start=LRA−3du+ngroupRAdstart+n¯shiftRANCSd¯¯¯start=LRA−2du+ngroupRAdstart+n¯¯shiftRANCSngroupRA=⌊du/dstart⌋n¯shiftRA=max(⌊(LRA−3du−ngroupRAdstart)/NCS⌋,0)n¯¯shiftRA=⌊min(du−ngroupRAdstart,4du−LRA−n¯shiftRANCS)/NCS⌋n¯¯¯shiftRA=⌊((1−min(1,n¯shiftRA))(du−ngroupRAdstart)+min(1,n¯shiftRA)(4du−LRA−n¯shiftRANCS))/NCS⌋−n¯¯shiftRA
$$

- 对于 $2L/7;/3;$

$$
nshiftRA=⌊(LRA−3du)/NCS⌋dstart=LRA−3du+nshiftRANCSd¯¯start=du+ngroupRAdstart+n¯shiftRANCSd¯¯¯start=0ngroupRA=⌊du/dstart⌋n¯shiftRA=max(⌊(4du−LRA−ngroupRAdstart)/NCS⌋,0)n¯¯shiftRA=⌊min(du−ngroupRAdstart,LRA−3du−n¯shiftRANCS)/NCS⌋n¯¯¯shiftRA=0
$$

- 对于$ {({ {L} *{}}+{ {N}* {}})}/{3};<{2{ {L}\_{}}}/{5}; $

$$
nshiftRA=⌊(3du−NZC)/NCS⌋dstart=3du−NZC+nshiftRANCSd¯¯start=0d¯¯¯start=0ngroupRA=⌊du/dstart⌋n¯shiftRA=max(⌊(LRA−2du−ngroupRAdstart)/NCS⌋,0)n¯¯shiftRA=0n¯¯¯shiftRA=0
$$

- 对于 $2L/5;/2;$

$$
nshiftRA=⌊(NZC−2du)/NCS⌋dstart=2(NZC−2du)+nshiftRANCSd¯¯start=0d¯¯¯start=0ngroupRA=⌊(LRA−du)/dstart⌋n¯shiftRA=max(⌊(3du−LRA−ngroupRAdstart)/NCS⌋,0)n¯¯shiftRA=0n¯¯¯shiftRA=0
$$

对于其他所有的 $du$ 值，受限集合则不存在循环移位。

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171023/200450560.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171023/200548356.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171023/200639881.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171023/200723042.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171023/200800085.png)

#### 物理资源映射

  
前导序列应根据以下方式应到到物理资源

$$
ak(p,RA)=βPRACHyu,v(k)k=0,1,...,LRA−1
$$

其中$ { {} *{}} $是幅值因子，用以满足TS38.213对发送功率$ { {P}* {}} $的规定，$ p=4000 $是天线端口。基带信号根据5.3节并使用Table 6.3.3.1-1或Table 6.3.3.1-2中的参数生成。

## 物理信号

### 参考信号

#### PUSCH DM-RS

##### 序列生成

  
如果PUSCH不启用TF预编码，则参考信号序列 $r(m)$ 应根据以下方式生成

$$
r(m)=12(1−2⋅c(2m))+j12(1−2⋅c(2m+1))
$$

其中伪随机序列 $c(i)$ 在5.2节中定义。

如果PUSCH启用TF预编码，则参考信号序列 $r(m)$ 应根据以下方式生成

$$
r(p)(m)=ru,v(α)(m)
$$

其中 $r(p)(m)=ru,v()(m)$ 在5.3节中给定。

##### 物理资源映射

  
PUSCH DM-RS应根据高层参数 *UL-DMRS-config-type* 所配置的类型1或类型2进行物理资源映射。

UE应根据以下方式将序列 $r(m)$ 映射到物理资源：

- 如果不启用TF预编码，

$$
ak,l(p,μ)=βDMRSwf(k′)⋅wt(l′)⋅r(2m+k′+m0)k={k0+4m+2k′+ΔConfiguration type1k0+6m+k′+ΔConfiguration type2k′=0,1l={l0,l¯}+l′
$$

- 如果启用TF预编码，

$$
ak,l(p,μ)=βDMRSwt(l′)⋅ru,v(α)(2m+k′+m0)k=k0+4m+2k′+Δk′=0,1l={l0,l¯}+l′
$$

其中$ { {w} *{}}( { {k}'} ) $、$ { {w}* {}}( { {l}'} ) $和$ $由Tables 6.4.1.1.2-1和6.4.1.1.2-2给定。

$ l $是PUSCH传输的起始符号，$ { {l}\_{0}} $是DM-RS的第1个符号。

附加的DM-RS符号的位置由 $l$ 和时隙内最后一个用于PUSCH的OFDM符号确定，详见Tables 6.4.1.1.2-3和6.4.1.1.2-4。

时域索引$ {l}' $和所支持的天线端口$ p $根据 *UL-DMRS-len* 和Table 6.4.1.1.2-5确定。

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171024/082322325.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171024/082356056.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171024/082436027.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171024/082509888.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171024/084919864.png)

#### PT-RS

##### 序列生成

##### 物理资源映射

#### PUCCH DM-RS

##### PUCCH格式1 DM-RS

###### 序列生成

  
参考信号序列定义为

$$
r(m′NseqNSF+mNseq+n)=wi(m)⋅ru,v(α)(n)n=0,1,...,Nseq−1m=0,1,...,NSFm′−1m′={0no frequency hopping0,1frequency hopping enabled
$$

其中$ { {N} *{}}=N* {}^{} $。正交序列$ { {w}\_{i}}(m) $由Table 6.3.2.2.1-1给定。

###### 物理资源映射

  
参考信号序列应乘以一个幅值因子$ *{}^{} $，以符合TS38.213对发送功率$ P* {}^{} $并在时隙内在天线端口$ p $上，按以下方式从$ r(0) $开始映射到资源粒子$ (k,l) $

$$
ak,l(p,μ)=βDMRSPUCCH1r(m)l=0,2,4,...
$$

其中 $l=0$ 对应于PUCCH发送的第1个OFDM符号。

##### PUCCH格式2 DM-RS

###### 序列生成

  
参考信号序列 $r(m)$ 应按以下方式生成

$$
r(m)=12(1−2⋅c(2m))+j12(1−2⋅c(2m+1))
$$

其中伪随机序列 $c(i)$ 在5.2节定义。

###### 物理资源映射

  
参考信号序列应乘以一个幅值因子$ *{}^{} $，以符合TS38.213对发送功率$ P* {}^{} $的规定，并在时隙内在天线端口$ p $上，按以下方式从$ r(0) $开始映射到资源粒子$ (k,l) $

$$
ak,l(p,μ)=βDMRSPUCCH2r(m)k=3m+1
$$

其中 $k$ 是指相对于发送PUCCH所使用的最低编号的RB。

#### SRS

##### 序列生成

  
探测参考信号序列应按以下方式生成

$$
r(p)(n)=ru,v(α)(n)0≤n≤272⋅NscRB
$$

其中 $ru,v()(n)$ 由5.2.2节给定。

##### 物理资源映射

  
根据TS38.214中6.2.1节，当SRS发送时，序列$ { {r}^{(p)}}( n ) $应乘以一个幅值因子$ { {} *{}} $，以符合TS38.213对发送功率的规定，并在时隙内在天线端口$ p $上，按以下方式从$ r* {}^{p}(0) $开始映射到资源粒子$ (k,l) $

$$
aKTCk′+k0(p),l(p)={1NapβSRSrSRS(p)(k′)k′=0,1,…,Msc,bRS−10otherwise
$$

其中 $N1,2,4$ 是用于发送SRS的天线端口数。

探测参考信号应在上行天线端口$ 3000+i $上发送，其中$ i $是$ i=0 $，$ i=0,1 $或$ i=0,1,2,3 $之一。

$ k\_{0}^{(p)} $是天线端口$ p $上的SRS频域起始位置。SRS序列长度为

$$
Msc,bRS=mSRS,bNscRB/KTC
$$

其中$ b={ {B} *{}} $和$ { {m}* {b}} $由Table 5.5.3.2-1给定。

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171024/083715829.png)

## 下行链路

  
[5G-NR物理信道与调制-下行链路v1.1.0](http://marshallcomm.cn/2017/10/24/nr-v110-l1-channel-modulation-dl/)