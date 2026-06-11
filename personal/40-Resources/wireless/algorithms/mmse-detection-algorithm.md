---
title: "MMSE 检测算法推导"
source: "https://marshallcomm.cn/2018/12/22/algorithm-mmse-detection/"
published: 2018-12-22
created: 2025-12-12

---

考虑发送端具有 $Nt$ 根发送天线，接收端具有 $Nr$ 根接收天线，在一个时隙内信道为准静态平坦衰落情况下，接收信号可表示为

$$
(1)y=Hx+n
$$

其中 $H∈CNr×Nt$ 是 MIMO 信道矩阵， $x∈CNt×1$ 是发送信号向量， $n∈CNr×1$ 是与发送信号向量不相关的加性噪声向量，假设噪声向量均值为零。

## 预备知识

向量 $x$ ， $n$ 有如下自相关矩阵

$$
(2)Rx=E[xxH]
$$

$$
(3)Rn=E[nnH]
$$

已假设向量 $x$ ， $n$ 不相关，则 $x$ ， $n$ 互相关矩阵为 $0$ 矩阵

$$
(4)Rxn=E[xnH]=0Nt×Nr
$$

$$
(5)Rnx=E[nxH]=0Nr×Nt
$$

接收信号向量 $y$ 的自相关矩阵

$$
(6)Ry=E[yyH]=E[(Hx+n)(Hx+n)H]=E[HxxHHH+HxnH+nxHHH+nnH]=HE[xxH]+HE[xnH]+E[nxH]HH+E[nnH]=HRxHH+Rn
$$

这些相关矩阵将在下面的推导中使用。

## MMSE检测算法

接收端估计的信号为

$$
(7)x^=Wy
$$

则估计信号的误差为

$$
(8)e=x^−x=Wy−x
$$

估计信号的均方误差为

$$
(9)eMSE=E‖Wy−x‖2
$$

**MMSE 检测算法以最小均方误差为准则，最小化实际发送的符号和检测器输出估计值之间的均方误差。当 $eMSE$ 达到最小时，接收信号 $y$ 的加权矩阵 $W$ 为 $WMMSE$** ：

$$
(10)WMMSE=arg⁡minw⁡ E‖Wy−x‖2
$$

推导 $WMMSE$ 有两种方法，一是利用正交性原理，能够很方便地推出结果；二是从式（9）出发，对 $WMMSE$ 求导，并令导函数为 0，转化为求极值问题。

## 推导方法一：正交性原理

正交性原理：估计误差 $e$ 是一个随机变量，定义代价函数为均方误差 $eMSE=E‖Wy−x‖$ ，则使均方误差 $eMSE$ 获得最小值的条件是：

$$
(11)E[e0yH]=0
$$

此时的 $e0$ 是在均方误差意义上的最小值。这就是正交性原理。

将式（8）带入式（11）得

$$
(12)E[(WMMSEy−x)yH]=0
$$

下面对式（12）化简：

$$
(13)E[WMMSEyyH−xyH]=0
$$

$$
(14)E[WMMSE(Hx+n)(Hx+n)H−x(Hx+n)H]=0
$$

$$
(15)E[WMMSE(Hx+n)(xHHH+nH)−x(xHHH+nH)]=0
$$

$$
(16)E[WMMSE(HxxHHH+HxnH+nxHHH+nnH)−(xxHHH+xnH)]=0
$$

$$
(17)WMMSE(HE[xxH]HH+HE[xnH]+[nxH]HH+E[nnH])−([xxH]HH+E[xnH])=0
$$

$$
(18)WMMSE(HE[xxH]HH+E[xxH]HH)=0
$$

最后导出 $WMMSE$ 为

$$
(19)WMMSE=RxHH(HRxHH+Rn)−1
$$

## 推导方法二：矩阵求导

如果不使用正交性原理，要想找到使 $eMSE$ 最小的 $WMMSE$ ，步骤是 step 1）对 $eMSE$ 求导，step 2）令 $eMSE$ 的导函数等于 0，并求得极值点。

式（9）可重写为

$$
(20)eMMSE=E‖Wy−x‖2=E{tr[(Wy−x)(Wy−x)H]}=E{tr[WyyHWH−WyxH−xyHWH+xxH]}=tr{WE[yyH]WH−WE[yxH]−E[xyH]WH+E[xxH]}
$$

式（20）第一项：

$$
(21)WE[yyH]WH=WRyWH
$$

式（20）第二项：

$$
(22)WE[yxH]=WE[(Hx+n)xH]=WE[HxxH+nxH]=WHRx
$$

式（20）第三项：

$$
(23)E[xyH]WH=E[x(Hx+n)H]WH=E[xxHHH+xnH]WH=RxHHWH
$$

将式（2），式（21~23）带入式（20）可得

$$
(24)eMSE=tr{WRyWH−WHRx−RxHHWH+Rx}
$$

对 $eMSE$ 求 $W$ 的偏导：

$$
(25)∂eMSE∂W=∂tr{WRyWH−WHRx−RxHHWH+Rx}∂W
$$

式（25）分子第一项的偏导为：

$$
(26)∂tr{WRyWH}∂W=(RyWH)T=W∗RyT
$$

式（25）分子第二项的偏导为：

$$
(27)∂tr{WHRx}∂W=(HRx)T
$$

式（25）分子第三项的偏导为：

$$
(28)∂tr{RxHHWH}∂W=0
$$

式（25）分子第四项的偏导为：

$$
(29)∂tr{Rx}∂W=0
$$

将式（26~29）带入式（25）得

$$
(30)∂eMSE∂W=W∗RyT−(HRx)T
$$

令 $eMSE$ 导函数等于 $0$

$$
(31)W∗RyT−(HRx)T=0
$$

对上式等号两边同时取复共轭：

$$
(32)WRyH=(HRx)H
$$

由于自相关矩阵是 **Hermitian** 矩阵，即 $RyH=Ry$ ， $RxH=Rx$ ，则上式改写为

$$
(33)WRy=RxHH
$$

则有

$$
(34)W=RxHHRy−1
$$

将式（6）带入上式得

$$
WMMSE=RxHH(HRxHH+Rn)−1
$$

由此看见，用矩阵求导的方法得到的式（35）和用正交性原理得到的式（19）相同。

若令

$$
Rx=E[xxH]=I
$$

$$
Rn=E[nnH]=σ2I
$$

带入式（35）得到

$$
(36)WMMSE=HH(HHH+σ2I)−1
$$

完毕。