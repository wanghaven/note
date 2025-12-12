---
title: "5G-NR物理信道与调制-下行链路v1.1.0"
source: "https://marshallcomm.cn/2017/10/24/nr-v110-l1-channel-modulation-dl/"
published: 2017-10-24
created: 2025-12-12
description: "上接《5G-NR物理信道与调制v1.1.0》下行链路 Scope References Definitions, symbols and abbreviations 帧结构与物理资源 通用函数 上行链路 5G-NR物理信道与调制-上行链路v1.1.0 下行链路 概述 物理信道概述 下行链路物理信道对应于一组资源粒子（REs）的集合，用于承载源自高层的信息。本规范定义了如下下"
---
## 帧结构与物理资源

## 通用函数

## 上行链路

  
[5G-NR物理信道与调制-上行链路v1.1.0](http://marshallcomm.cn/2017/10/23/nr-v110-l1-channel-modulation-ul/)

## 下行链路

## 概述

### 物理信道概述

  
下行链路物理信道对应于一组资源粒子（REs）的集合，用于承载源自高层的信息。本规范定义了如下下行信道：

- 物理下行共享信道（PDSCH）
- 物理广播信道（PBCH）
- 物理下行控制信道（PDCCH）

### 物理信号概述

  
下行物理信号是物理层使用的但不承载任何来自高层信息的信号。本规范定义了如下下行物理信号：

- 解调参考信号（Demodulation reference signals，DM-RS）
- 相位跟踪参考信号（Phase-tracking reference signals，PT-RS）
- 信道状态信息参考信号（Channel-state information reference signal，CSI-RS）
- 主同步信号（Primary synchronization signal，PSS）
- 辅同步信号（Secondary synchronization signal，SSS）

## 物理资源

  
当接收下行链路发送的数据时，UE应假定采用第4章定义的帧结构和物理资源。

定义下列天线端口用于下行链路：

- PDSCH相关的DM-RS使用以1000为起始的天线端口
- PDCCH相关的DM-RS使用以2000为起始的天线端口
- CSI-RS使用以3000为起始的天线端口
- SS/PBCH块传输使用以4000为起始的天线端口

## 物理信道

### PDSCH

#### 加扰

  
对于每个码字$ q $，UE应假定比特块$ { {b}^{(q)}}(0),...,{ {b} <sup>{(q)}}(M_{}</sup> {(q)}-1) $，其中$ M\_{}^{(q)} $物理信道发送的码字$ q $的比特数，在调制之前被加扰，根据以下方式得到加扰比特块$ { {}^{(q)}}(0),...,{ {} <sup>{(q)}}(M_{}</sup> {}-1) $

$$
b~(q)(i)=(b(q)(i)+c(q)(i))mod2
$$

其中加扰序列 $c(q)(i)$ 由5.2节给定。

#### 调制

  
对于每个码字$ q $，UE应假定加扰比特块$ { {}^{(q)}}(0),...,{ {} <sup>{(q)}}(M_{}</sup> {}-1) $按照5.1节的描述进行调制，调制方案详见Table7.3.1.2−1，得到复值调制符号块$ { {d}^{(q)}}(0),...,{ {d} <sup>{(q)}}(M_{}</sup> {}-1) $。

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171024/194746226.png)

#### 层映射

  
UE应假定每个码字的复值调制符号根据Table 7.3.1.3-1被映射到1个或多个层。码字$ q $的复值调制符号$ { {d}^{(q)}}(0),...,{ {d} <sup>{(q)}}(M_{}</sup> {}-1) $应被映射到层$ x(i)={ {}^{T}} $，$ i=0,1,...,M\_{}^{}-1 $，其中$ $是层数，$ M\_{}^{} $是每层的调制符号数。

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171026/130637932.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171026/130648907.png)

#### 预编码

  
预编码是透明的，

$$
[⋮y(p)(i)⋮]=[x(0)(i)⋮x(υ−1)(i)]
$$

其中 $P=$ 。

#### 物理资源映射

  
UE应假定用于物理信道传输的每个天线端口，复值符号块$ { {y}^{(p)}}(0),...,{ {y} <sup>{(p)}}(M_{}</sup> {}-1) $符合TS38.214中的下行功率分配规定，并从$ { {y}^{(p)}}(0) $开始映射到资源粒子$ ( k,l ) $，这些REs应满足下列所有条件：

- 它们在已分配的用于传输的RB中
- 根据TS38.214中5.1.2.2.3节，它们被声明为可用于PDSCH
- 根据7.4.1.5节，它们不能用于CSI-RS
- 根据TS38.214中5.1节，它们不为SS/PBCH保留

映射过程中不保留用于其他目的资源粒子$ { {( k,l )} *{p,}} $，并按递增顺序先$ k $后$ l $映射，起始符号$ l={ {l}* {0}} $根据TS38.213的描述得到。

UE可假定在一个PRB bundle内在频域上使用相同的预编码，1个PRB bundle由2个或4个PRBs组成，PRB bundle基于绝对资源格进行定义。PRB bundle大小如果由高层参数配置，那么由参数 *PDSCH-bundle-size* 进行配置，否则通过DCI调度传输配置。

### PDCCH

#### 控制信道单元（CCE）

  
PDCCH有1个或多个CCE组成，如Table 7.3.2.1-1所示。

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171026/132353562.png)

#### 控制资源集（CORESET）

  
控制资源集（CORESET）在频域上由$ N\_{}^{} $个RB组成，在时域上由$ N\_{}^{}{ 1,2,3 } $个符号组成。$ N\_{}^{} $由高层参数∗CORESET−freq−dom∗给定，$ N\_{}^{} $由高层参数∗CORESET−time−dur∗给定。仅当高层参数∗DL−DMRS−typeA−pos∗=3时，支持$ N\_{}^{}=3 $。

1个CCE由6个REGs组成，1个REG等于1个OFDM符号上的1个RB。CORESET内的REGs按时域优先的顺序编号，从第1个OFDM符号且最低编号的RB以0开始编号。

UE可配置多个CORESETs，每个CORESET只与一个种CCE-to-REG映射关联。

在CORESET内，CCE-to-REG映射可以交织也可以不交织，这由高层参数 *CORESET-Trans-type* 来配置，并且由REG bundles来描述：

- REG bundle $i$ 定义为一组REGs $ { iL,iL+1,...,iL+L-1 } $，其中REGbundle大小$ L $由高层参数∗CORESET−REG−bundle−size∗来配置，$ i=0,1,...,{N\_{}^{}}/{L};-1 $是CORESET内REGs的数目。
- CCE $j$ 由REG bundles $ { f({6j}/{L};),f({6j}/{L};+1),...,f({6j}/{L};+{6}/{L};-1) } $组成，其中$ f() $是交织器。

对于非交织的CCE-to-REG映射，有$ L=6 $且$ f(j)=j $。

对于交织的CCE-to-REG映射，对于$ N\_{}^{}=1 $，有$ L{ 2,6 } $；对于$ N\_{}^{}{ 2,3 } $，有$ L{ N\_{}^{},6 } $。

UE可假定

- 如果高层参数 *CORESET-wideband-bundle* 没有对CORESET进行设置，那么在1个REG bundle内的频域上使用相同的预编码
- 如果高层参数 *CORESET-wideband-bundle* 对CORESET进行了设置，那么在整个CORESET内的频域上使用相同的预编码

#### 加扰

#### 调制

  
UE应假定比特块$ (0),...,({ {M} *{}}-1) $按照5.1.3节的描述进行QPSK调制，得到复值调制符号块$ d(0),...,d({ {M}* {}}-1) $。

#### 物理资源映射

  
UE应假定复值调制符号块$ d(0),...,d({ {M} *{}}-1) $乘以一个幅值因子$ { {}* {}} $，并在用于监测PDCCH的CCEs上先$ l $后$ k $按递增顺序映射到资源粒子$ { {( k,l )}\_{p,}} $。

### PBCH

#### 加扰

  
UE应假定比特块$ { {b}^{(q)}}(0),...,{ {b} <sup>{(q)}}(M_{}</sup> {(q)}-1) $，其中$ { {M} *{}} $是PBCH发送的比特数，应根据以下方式在调制之前进行加扰，得到加扰比特块$ (0),...,({ {M}* {}}-1) $

$$
b~(q)(i)=(b(q)(i)+c(q)(i))mod2
$$

其中加扰序列 $c(q)(i)$ 由5.2节给定。

#### 调制

  
UE应假定比特块$ (0),...,({ {M} *{}}-1) $按照5.1节的描述进行QPSK调制，得到复值调制符号块$ { {d}* {}}(0),...,{ {d} *{}}({ {M}* {}}-1) $。

#### 物理资源映射

  
物理资源映射在7.4.3节中描述。

## 物理信号

### 参考信号

#### PDSCH DM-RS

##### 序列生成

  
UE应假定参考信号序列 $r(m)$ 定义为

$$
r(m)=12(1−2⋅c(2m))+j12(1−2⋅c(2m+1))
$$

其中伪随机序列 $c(i)$ 在5.2节中定义。

##### 物理资源映射

  
UE应假定PDSCH DM-RS根据高层参数 *DL-DMRS-config-type* 给定的类型1或类型2进行物理资源映射。

UE应假定序列 $r(m)$ 根据以下方式进行物理资源映射

$$
ak,l(p,μ)=βDMRSwf(k′)⋅wt(l′)⋅r(2m+k′+m0)k={k0+4m+2k′+ΔConfiguration type1k0+6m+k′+ΔConfiguration type2k′=0,1l={l0,l¯}+l′
$$

其中$ { {w} *{}}( { {k}'} ) $，$ { {w}* {}}( { {l}'} ) $和$ $由Tables 7.4.1.1.2-1和7.4.1.1.2-2给定。

第1个DM-RS符号的参考点 $l$ 和位置 $l0$ 依赖于映射类型（mapping type）：

- 对于PDSCH映射类型A：
	- $l$ 定义为起始时隙
	- 如果高层参数 *DL-DMRS-typeA-pos* = 3，则$ { {l} *{0}}=3 $；否则，$ { {l}* {0}}=2 $
- 对于PDSCH映射类型B:
	- $l$ 定义为被调度的PDSCH资源的起始
	- $l0=0$

附加的DM-RS符号的位置由 和时隙内最后一个用于PDSCH的OFDM符号确定，详见Tables 7.4.1.1.2-3和7.4.1.1.2-4。

时域索引$ {l}' $和所支持的天线端口$ p $根据 *DL-DMRS-len* 和Table 7.4.1.1.2-5得到。

在未给定CSI-RS或TRS配置的情况下，UE应假定PDSCH DM-RS和SS/PBCH块是关于多普勒频移、平均时延、时延扩展和空间RX准共定位的（quasi co-located）。

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171026/135602719.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171026/135635903.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171026/135708921.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171026/135739647.png)

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171026/135803943.png)

#### PDSCH PT-RS

##### 序列生成

##### 物理资源映射

  
UE应假定仅当高层参数 *DL-PTRS-presen* t指示PT-RS被使用时，PT-RS仅呈现在用于PDSCH的RB中。

如果PT-RS呈现，UE应假定PDSCH PT-RS按以下方式映射到物理资源

$$
ak,l(p,μ)=βPTRSr(m)l=lDMRS+1+LPTRS⋅l′l′=0,1,2,...
$$

在每 $K$ 个被调度的RBs中，当满足下列条件时，PT-RS在最低编号的被调度的RB上传输

- $l$ 在被分配的用于传输PDSCH的OFDM符号内
- 资源粒子 $(k,l)$ 不用于DM-RS

其中

- $k$ 是RB内的子载波索引
- 对于1个符号的DM-RS，有$ { {l} *{}}={ {l}* {0}} $；对于2个符号的DM−RS，有$ { {l} *{}}={ {l}* {0}}+1 $，其中$ { {l}\_{0}}+1 $在7.4.1.1.2中定义
- $K2,4$ 由TS38.214给定
- $L1,2,4$ 由TS38.214给定

#### PDCCH DM-RS

##### 序列生成

  
UE应假定参考信号序列 $r(m)$ 定义为

$$
r(m)=12(1−2⋅c(2m))+j12(1−2⋅c(2m+1))
$$

其中伪随机序列 $c(i)$ 在5.2节中定义。

##### 物理资源映射

  
UE应假定序列 $r(m)$ 根据以下方式映射到物理资源

$$
ak,l(p,μ)=βDMRS⋅r(m)
$$

其中$ k=1,5,9 $，$ l=0 $分别是在一组REGs内的频域和时域索引，这组REGs等于

- 如果高层参数 *CORESET-wideband-bundle* 没有对CORESET进行设置，那么这组REGs是UE尝试译码的构成PDCCH的REGs
- 如果高层参数 *CORESET-wideband-bundle* 对CORESET进行了设置，那么这组REGs是UE尝试译码的在整个CORESET内的所有REGs

#### PBCH DM-RS

##### 序列生成

  
UE应假定用于SS/PBCH块的参考信号序列 $r(m)$ 定义为

$$
r(m)=12(1−2⋅c(2m))+j12(1−2⋅c(2m+1))
$$

其中 $c(n)$ 由5.2节给定。加扰序列生成器应在每个SS/PBCH块的开始处通过小区ID $ N\_{}^{} $和$ { {n}\_{}} $被初始化，SS/PBCH块时间索引由PBCH DM-RS承载。

##### 物理资源映射

  
物理资源映射在7.4.3节中定义。

#### CSI-RS

##### 序列生成

  
UE应假定参考信号序列 $r(m)$ 定义为

$$
r(m)=12(1−2⋅c(2m))+j12(1−2⋅c(2m+1))
$$

其中伪随机序列 $c(i)$ 在5.2节中定义。

##### 物理资源映射

  
对于每个CSI-RS成员配置，UE应假定序列 $r(m)$ 按以下方式映射到物理资源

$$
ak,l(p,μ)=βCSIRSwf(k′)⋅wt(l′)⋅r(m)k=k¯+k′l=l¯+l′
$$

下列情况除外

- 与所配置的CORESET重叠的REs应从CSI-RS发送中排除

$ {k}' $和$ {l}' $由Table7.4.1.5.2−1和$ { {w} *{}}( { {k}'} ),{ {w}* {}}( { {l}'} ){,,,} $确定。

时域位置$ l $定义为起始时隙，其中$ {l}{ 5,6,12,13 } $是时隙内CSI−RS的起始符号位置，$ {l} $由高层参数 *CSI-RS-ResourceMapping* 配置。

除单端口之外，频域位置由位图$ or $通过高层参数∗CSI−RS−ResourceMapping∗给定，Table7.4.1.5.2−1中的$ { {k} *{i}} $对应于位图中从$ { {b}* {0}} $开始的第$ i $个集合点，$ { {k} *{i}} $的值由$ { {k}* {i}}=f( i ) $给定，其中$ f( i ) $是第$ i$个集合点的位图中的比特号。CSI-RS频域位置在所配置的PRBs上重复。

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171026/141325803.png)

#### TRS

##### 序列生成

  
UE应假定参考信号序列 $r(m)$ 定义为

$$
r(m)=12(1−2⋅c(2m))+j12(1−2⋅c(2m+1))
$$

其中伪随机序列 $c(i)$ 在5.2节中定义。

##### 物理资源映射

  
TRS（tracking reference signal） burst由4个OFDM符号组成，在2个连续时隙内发送。

UE应假定TRS在1个burst中根据以下方式映射到物理资源

$$
ak,l(p,μ)=βTRSr(m)k=4m+k0
$$

The UE may assume that a TRS burst is quasi co-located with respect to delay spread, average delay, Doppler shift, and Doppler spread with the PDSCH DM-RS.

### 同步信号

#### 物理层小区ID

  
NR有1008个唯一的物理层小区ID，根据下式得到

$$
NIDcell=3NID(1)+NID(2)
$$

其中$ N\_{}^{}{ 0,1,...,335 } $且$ N\_{}^{}{ 0,1,2 } $。

#### PSS

##### 序列生成

  
主同步信号序列 $d(n)$ 定义为

$$
dPSS(n)=1−2x(m)m=(n+43NID(2))mod1270≤n<127
$$

其中

$$
x(i+7)=(x(i+4)+x(i))mod2
$$

且

$$
[x(6)x(5)x(4)x(3)x(2)x(1)x(0)]=[1110110]
$$

##### 物理资源映射

  
物理资源映射在7.4.3节描述。

#### SSS

##### 序列生成

  
辅同步信号序列 $d(n)$ 定义为

$$
dSSS(n)=[1−2x0((n+m0)mod127)][1−2x1((n+m1)mod127)]m0=15⌊NID(1)112⌋+5NID(2)m1=NID(1)mod1120≤n<127
$$

其中

$$
x0(i+7)=(x0(i+4)+x0(i))mod2x1(i+7)=(x1(i+1)+x1(i))mod2
$$

且

$$
[x0(6)x0(5)x0(4)x0(3)x0(2)x0(1)x0(0)]=[0000001][x1(6)x1(5)x1(4)x1(3)x1(2)x1(1)x1(0)]=[0000001]
$$

##### 物理资源映射

  
物理资源映射在7.4.3节描述。

### SS/PBCH Block

#### SS/PBCH块的时频域结构

  
在时域上，1个SS/PBCH块由4个OFDM符号组成，在SS/PBCH块内符号按增序从0到3编号，其中PSS、SSS、PBCH以及和PBCH相关的DM-RS位于不同的符号，详见Table 7.4.3.1-1。

在频域上，1个SS/PBCH块由288个连续子载波组成，在SS/PBCH块内子载波按增序从0到287编号。SS/PBCH块内的子载波 $k$ 对应于资源块$ n\_{}^{} $的子载波$ n\_{} <sup>{}N_{}</sup> {}+{ {k} *{0}} $，其中$ { {k}* {0}}{... } $。

对于1个SS/PBCH块，UE应假定

- 天线端口 $p=4000$
- 子载波间隔配置 $0,1,3,4$
- PSS、SSS和PBCH具有相同的CP长度和子载波间隔

UE应假定在SS/PBCH burst set内的同一块时间索引下发送的SS/PBCH blocks是关于多普勒扩展、多普勒频移、平均增益、平均时延和空间RX参数准共定位的。

![mark](https://picture-1257868707.cos.ap-beijing.myqcloud.com/marshallcomm/20171026/142651702.png)

##### SS/PBCH块内PSS的映射

  
UE应假定PSS符号序列$ { {d} *{}}(0),...,{ {d}* {}}(126) $乘以一个幅值因子$ { {} *{}} $，以符合TS38.213对PSS功率分配的规定，并按$ k $的递增顺序映射到资源粒子$ { {( k,l )}* {p,}} $，其中$ k $和$ l $在Table7.4.3.1−1中给定，$ k $和$ l$分别表示SS/PBCH块内的频域和时域索引。

##### SS/PBCH块内SSS的映射

  
UE应假定SSS符号序列$ { {d} *{}}(0),...,{ {d}* {}}(126) $乘以一个幅值因子$ { {} *{}} $，以符合TS38.213对SSS功率分配的规定，并按$ k $的递增顺序映射到资源粒子$ { {( k,l )}* {p,}} $，其中$ k $和$ l $在Table7.4.3.1−1中给定，$ k $和$ l$分别表示SS/PBCH块内的频域和时域索引。

##### SS/PBCH块内PBCH的映射

  
UE应假定PBCH复值符号序列$ { {d} *{}}(0),...,{ {d}* {}}({ {M} *{}}-1) $乘以一个幅值因子$ { {}* {!!!!}} $，以符合TS38.213对PBCH功率分配的规定，并从$ { {d} *{}}(0) $开始映射到资源粒子$ { {( k,l )}* {p,}} $，这些REs满足下列条件：

- 它们不用于PBCH DM-RS

映射过程中不保留用于其他目的资源粒子$ { {( k,l )}\_{p,}} $，并按递增顺序先$ k $后$ l $映射，其中$ k $和$ l$分别是SS/PBCH块内的频域和时域索引，并由Table 7.4.3.1-1给定。

UE应假定SS/PBCH块的DM-RS复值符号序列$ { {r} *{l}}(0),...,{ {r}* {l}}(143) $乘以一个幅值因子$ *{}^{} $，以符合TS38.213对PBCHDM−RS功率分配的规定，并按递增顺序先$ k $后$ l $映射到资源粒子$ { {( k,l )}* {p,}} $，其中$ k $和$ l $分别是SS/PBCH块内的频域和时域索引，并由Table7.4.3.1−1给定，其中$ v=N\_{}^{} $。

#### SS/PBCH块的时域位置

  
UE应对可能的时域位置上的SS/PBCH块进行监测，在TS38.213中描述。