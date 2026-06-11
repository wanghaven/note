---
title: Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift —— 全文翻译与详细解析
date: 2026-06-11
tags:
  - personal/resource
  - ai-ml
status: draft
aliases:
  - Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift —— 全文翻译与详细解析
---

# Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift —— 全文翻译与详细解析

> [!info] 论文信息
> - **标题**：Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift（批归一化：通过减少内部协变量偏移来加速深度网络训练）
> - **作者**：Sergey Ioffe, Christian Szegedy（Google Inc.）
> - **发表**：ICML 2015 · [arXiv:1502.03167](https://arxiv.org/abs/1502.03167)
> - **历史地位**：深度学习训练的「基础设施」级技术。让深网络可以用更大学习率、更不挑初始化、训练更快更稳，几乎成为 CNN 标配。

> [!abstract] 本文档说明
> 按「**原文 → 中文翻译 → 详细解析**」三段式逐节组织。原文摘自 arXiv PDF，长段做了节选。解析为译注补充。

---

## 摘要 Abstract

> [!quote] 原文
> Training Deep Neural Networks is complicated by the fact that the distribution of each layer's inputs changes during training, as the parameters of the previous layers change. This slows down the training by requiring lower learning rates and careful parameter initialization, and makes it notoriously hard to train models with saturating nonlinearities. We refer to this phenomenon as internal covariate shift, and address the problem by normalizing layer inputs... Batch Normalization allows us to use much higher learning rates and be less careful about initialization. It also acts as a regularizer, in some cases eliminating the need for Dropout. Applied to a state-of-the-art image classification model, Batch Normalization achieves the same accuracy with 14 times fewer training steps... reaching 4.9% top-5 validation error... exceeding the accuracy of human raters.

**中文翻译**

训练深度神经网络很复杂，因为随着前面各层参数的变化，**每一层输入的分布在训练过程中也在不断变化**。这迫使我们使用更低的学习率、更小心的参数初始化，从而拖慢训练；也使得带**饱和非线性**（如 sigmoid）的模型出了名地难训。我们把这一现象称为**内部协变量偏移（internal covariate shift）**，并通过**归一化层输入**来解决它。我们方法的力量来自：把归一化变成模型架构的一部分，并对**每个训练 mini-batch** 执行归一化。

批归一化（Batch Normalization, BN）让我们能用**高得多的学习率**，也不必那么小心地初始化。它还起到**正则化**作用，某些情况下甚至可以省掉 Dropout。应用于一个当时最先进的图像分类模型后，BN 用 **少 14 倍的训练步数**就达到了相同精度，并大幅超越原模型。用 BN 网络的集成，我们把 ImageNet 分类的最佳结果提升到 **4.9% top-5 验证误差**（4.8% 测试误差），**超过了人类评定者的准确率**。

**详细解析**

- 一句话概括：**「在每一层激活进入非线性之前，按 mini-batch 把它归一化成均值 0、方差 1，再用两个可学习参数 $\gamma,\beta$ 缩放平移。」**
- 解决的核心痛点：深网络里，底层参数稍变，上层输入分布就剧烈漂移（内部协变量偏移），上层得不停「追着分布跑」，训练又慢又不稳。
- 四大好处贯穿全文：① 可用大学习率 → 训练快；② 不挑初始化；③ 自带正则化（可减/免 Dropout）；④ 让 sigmoid 等饱和非线性也能训得动。

---

## 1 引言 Introduction

> [!quote] 原文
> Consider a layer with a sigmoid activation function $z = g(Wu + b)$... As $|x|$ increases, $g'(x)$ tends to zero. This means that for all dimensions of $x = Wu+b$ except those with small absolute values, the gradient flowing down to $u$ will vanish and the model will train slowly... This effect is amplified as the network depth increases. In practice, the saturation problem and the resulting vanishing gradients are usually addressed by using ReLU, careful initialization, and small learning rates. If, however, we could ensure that the distribution of nonlinearity inputs remains more stable as the network trains, then the optimizer would be less likely to get stuck in the saturated regime, and the training would accelerate.

**中文翻译**

考虑一个带 sigmoid 激活的层 $z = g(Wu + b)$，其中 $g(x) = \frac{1}{1+e^{-x}}$。当 $|x|$ 增大时，$g'(x)$ 趋于 0。这意味着：除了 $x = Wu+b$ 中绝对值较小的那些维度，其余维度流向 $u$ 的梯度都会**消失**，模型训练变慢。而由于 $x$ 受 $W、b$ 以及**下方所有层**参数的影响，训练中这些参数的变化很可能把 $x$ 的许多维度推入非线性的**饱和区**，拖慢收敛——**网络越深，这一效应被放大得越厉害**。

实践中，饱和与梯度消失问题通常靠 ReLU、小心的初始化、小学习率来缓解。然而，**如果我们能保证非线性输入的分布在训练中保持更稳定，优化器就更不容易卡在饱和区，训练就会加速**——这正是 BN 的出发点。

**详细解析**

- **内部协变量偏移（ICS）的定义**：训练过程中，由于网络参数变化，网络内部节点激活值分布发生改变。
- **为什么 ICS 有害**：① 上层要不断适应下层喂来的「漂移的分布」，效率低；② 激活容易漂进 sigmoid/tanh 的饱和区，梯度消失。
- BN 的思路不是绕开（ReLU + 调参），而是**主动把每层输入的分布钉死**在均值 0、方差 1 附近。
- > 注：后续研究（如 Santurkar et al. 2018）质疑「ICS 是 BN 起效主因」这一解释，认为 BN 真正的作用是**平滑了优化曲面（loss landscape）**。但 BN 的有效性本身毫无争议。

---

## 3 通过 Mini-Batch 统计量做归一化 Normalization via Mini-Batch Statistics（核心）

> [!quote] 原文
> ...instead of whitening the features in layer inputs and outputs jointly, we will normalize each scalar feature independently, by making it have the mean of zero and the variance of 1. For a layer with d-dimensional input $x = (x^{(1)} \dots x^{(d)})$, we will normalize each dimension
> $$\hat{x}^{(k)} = \frac{x^{(k)} - E[x^{(k)}]}{\sqrt{\mathrm{Var}[x^{(k)}]}}$$
> Note that simply normalizing each input of a layer may change what the layer can represent... To address this, we make sure that the transformation inserted in the network can represent the identity transform. To accomplish this, we introduce, for each activation $x^{(k)}$, a pair of parameters $\gamma^{(k)}, \beta^{(k)}$, which scale and shift the normalized value:
> $$y^{(k)} = \gamma^{(k)} \hat{x}^{(k)} + \beta^{(k)}$$
> ...by setting $\gamma^{(k)} = \sqrt{\mathrm{Var}[x^{(k)}]}$ and $\beta^{(k)} = E[x^{(k)}]$, we could recover the original activations, if that were the optimal thing to do.

**中文翻译**

由于对每层输入做完整「白化」（whitening，即去相关 + 归一化）代价高昂且并非处处可微，我们做两个必要的简化。

**简化一**：不联合白化各特征，而是**对每个标量特征独立归一化**，使其均值为 0、方差为 1。对 $d$ 维输入 $x = (x^{(1)} \dots x^{(d)})$，逐维归一化：

$$\hat{x}^{(k)} = \frac{x^{(k)} - E[x^{(k)}]}{\sqrt{\mathrm{Var}[x^{(k)}]}}$$

注意：仅仅归一化可能**改变该层能表达的内容**（例如把 sigmoid 的输入限制在线性区，丧失非线性能力）。为解决这一点，我们确保插入的变换**能表示恒等变换**：为每个激活 $x^{(k)}$ 引入一对**可学习参数** $\gamma^{(k)}, \beta^{(k)}$，对归一化值做缩放和平移：

$$y^{(k)} = \gamma^{(k)} \hat{x}^{(k)} + \beta^{(k)}$$

这对参数与原模型参数一起学习，**恢复了网络的表达能力**。事实上，若令 $\gamma^{(k)} = \sqrt{\mathrm{Var}[x^{(k)}]}$、$\beta^{(k)} = E[x^{(k)}]$，就能恢复原始激活——如果那样做是最优的话。

**简化二**：批设定下本应用整个训练集来归一化，但这对随机优化不现实。因此**用每个 mini-batch 来估计每个激活的均值和方差**。这样归一化所用的统计量也能**完整参与梯度反向传播**。

> [!quote] 算法 1（Batch Normalizing Transform）
> 输入：mini-batch 上的 $x$ 值 $B = \{x_1 \dots x_m\}$；待学习参数 $\gamma, \beta$。
> $$\mu_B \leftarrow \frac{1}{m}\sum_{i=1}^{m} x_i \qquad \text{(mini-batch 均值)}$$
> $$\sigma_B^2 \leftarrow \frac{1}{m}\sum_{i=1}^{m} (x_i - \mu_B)^2 \qquad \text{(mini-batch 方差)}$$
> $$\hat{x}_i \leftarrow \frac{x_i - \mu_B}{\sqrt{\sigma_B^2 + \epsilon}} \qquad \text{(归一化)}$$
> $$y_i \leftarrow \gamma \hat{x}_i + \beta \equiv \mathrm{BN}_{\gamma,\beta}(x_i) \qquad \text{(缩放与平移)}$$
> 其中 $\epsilon$ 是为数值稳定加到方差上的小常数。

**中文翻译（算法说明）**

我们把变换 $\mathrm{BN}_{\gamma,\beta}: x_{1\dots m} \to y_{1\dots m}$ 称为**批归一化变换**。注意 $\mathrm{BN}_{\gamma,\beta}(x)$ **不是独立处理每个样本**，而是同时依赖于当前样本与 mini-batch 中的其他样本。归一化后的 $\hat{x}$ 是变换内部量，其分布（忽略 $\epsilon$、且 mini-batch 各元素同分布时）均值为 0、方差为 1。

**详细解析**

- **两个简化是 BN 能落地的关键**：① 逐维独立归一化（而非昂贵的协方差白化）；② 用 mini-batch 统计量代替全集统计量。
- **$\gamma, \beta$ 为什么不可或缺**：如果只做归一化，会强行把激活压到均值 0、方差 1，可能破坏该层已学到的有用分布（比如把 sigmoid 困在近似线性区）。$\gamma, \beta$ 让网络**有能力学回任何它需要的均值/方差，甚至完全抵消归一化（恒等变换）**。这是「归一化但不损失表达力」的精髓。
- **关键洞察：归一化必须是可微的、参与反向传播的**。论文第 2 节专门论证：如果在梯度步之外「偷偷」归一化（不让梯度感知到归一化对参数的依赖），会导致参数（如 bias $b$）无限增长而 loss 不变——模型爆炸。BN 把归一化嵌进计算图，梯度穿过 $\mu_B, \sigma_B^2$，从根本上避免了这个问题（论文给出了完整的链式法则梯度公式）。

### 3.1 训练与推理 Training and Inference

> [!quote] 原文
> The normalization of activations that depends on the mini-batch allows efficient training, but is neither necessary nor desirable during inference; we want the output to depend only on the input, deterministically. For this, once the network has been trained, we use the normalization
> $$\hat{x} = \frac{x - E[x]}{\sqrt{\mathrm{Var}[x] + \epsilon}}$$
> using the population, rather than mini-batch, statistics... We use the unbiased variance estimate $\mathrm{Var}[x] = \frac{m}{m-1} \cdot E_B[\sigma_B^2]$...

**中文翻译**

依赖 mini-batch 的归一化让训练高效，但在**推理时既不必要也不可取**——我们希望输出只确定地依赖于输入（同一张图无论和谁一个 batch，结果都应一样）。因此，训练完成后，我们改用**总体（population）统计量**而非 mini-batch 统计量来归一化：

$$\hat{x} = \frac{x - E[x]}{\sqrt{\mathrm{Var}[x] + \epsilon}}$$

其中用无偏方差估计 $\mathrm{Var}[x] = \frac{m}{m-1} \cdot E_B[\sigma_B^2]$（对训练期各 mini-batch 的样本方差取期望）。由于推理时均值、方差固定，归一化退化为一个**简单的线性变换**，还能和 $\gamma, \beta$ 合并成单个线性变换，融入前一层。

**详细解析**

- **训练/推理行为不同，是 BN 最容易踩坑的地方**：训练用「当前 batch 的均值/方差」，推理用「训练期累积的全局均值/方差」（实践中常用**滑动平均**在线维护）。
- 推理时 BN = 固定的线性变换，可以和卷积/全连接层**融合（fold）**，零额外开销。这是部署优化的常见操作。
- 这也解释了 BN 对 batch size 敏感：batch 太小，mini-batch 统计量噪声大，效果变差（后来 GroupNorm/LayerNorm 等就是为小 batch 场景提出的替代品）。

### 3.2 卷积网络中的 BN

> [!quote] 原文
> ...we add the BN transform immediately before the nonlinearity, by normalizing $x = Wu + b$... Note that, since we normalize $Wu+b$, the bias $b$ can be ignored since its effect will be canceled by the subsequent mean subtraction (the role of the bias is subsumed by $\beta$)... For convolutional layers, we additionally want the normalization to obey the convolutional property – so that different elements of the same feature map, at different locations, are normalized in the same way... we learn a pair of parameters $\gamma^{(k)}$ and $\beta^{(k)}$ per feature map, rather than per activation.

**中文翻译**

我们把 BN 变换加在**非线性之前**，归一化 $x = Wu + b$（而不是归一化层输入 $u$，因为 $u$ 通常是上一个非线性的输出，分布形状在训练中易变；而 $Wu+b$ 更可能呈对称、非稀疏、"更高斯"的分布，归一化它更可能得到稳定分布）。

由于我们归一化 $Wu+b$，**偏置 $b$ 可以省略**——它的作用会被随后的减均值抵消，其角色由 $\beta$ 接管。于是 $z = g(Wu+b)$ 被替换为 $z = g(\mathrm{BN}(Wu))$。

对**卷积层**，我们要让归一化遵循**卷积特性**：同一特征图（feature map）在不同空间位置的元素应以**相同方式**归一化。为此，我们对一个 mini-batch 内、**所有空间位置**的激活联合归一化——对 batch 大小 $m$、特征图尺寸 $p \times q$，有效 batch 大小为 $m' = m \cdot pq$。并且**每个特征图学一对 $\gamma, \beta$**（而非每个激活一对）。

**详细解析**

- **位置**：BN 放在「线性变换之后、激活函数之前」（`Conv/FC → BN → ReLU`）是原论文的做法，也是最常见的用法。
- **省 bias**：用了 BN 的层，前面的卷积/全连接不需要 bias，因为 $\beta$ 已经承担了平移。
- **卷积版 BN 的关键**：按「**每通道（per feature map）**」而非「每个像素激活」来统计和缩放，符合卷积的平移共享特性，参数量也小。这是 CNN 里 BN 的标准实现。

### 3.3 / 3.4 为何能用大学习率 & 自带正则化

> [!quote] 原文
> Batch Normalization also makes training more resilient to the parameter scale... for a scalar $a$, $\mathrm{BN}(Wu) = \mathrm{BN}((aW)u)$ and we can show that $\frac{\partial \mathrm{BN}((aW)u)}{\partial u} = \frac{\partial \mathrm{BN}(Wu)}{\partial u}$, $\frac{\partial \mathrm{BN}((aW)u)}{\partial(aW)} = \frac{1}{a} \cdot \frac{\partial \mathrm{BN}(Wu)}{\partial W}$. The scale does not affect the layer Jacobian nor, consequently, the gradient propagation. Moreover, larger weights lead to smaller gradients, and Batch Normalization will stabilize the parameter growth.
> ...When training with Batch Normalization, a training example is seen in conjunction with other examples in the mini-batch, and the training network no longer producing deterministic values for a given training example... Whereas Dropout is typically used to reduce overfitting, in a batch-normalized network we found that it can be either removed or reduced in strength.

**中文翻译**

**对参数尺度更鲁棒（→ 可用大学习率）**：BN 对权重缩放不敏感。对标量 $a$，有 $\mathrm{BN}(Wu) = \mathrm{BN}((aW)u)$，且可证：

$$\frac{\partial \mathrm{BN}((aW)u)}{\partial u} = \frac{\partial \mathrm{BN}(Wu)}{\partial u}, \qquad \frac{\partial \mathrm{BN}((aW)u)}{\partial (aW)} = \frac{1}{a} \cdot \frac{\partial \mathrm{BN}(Wu)}{\partial W}$$

权重的尺度不影响层的雅可比，因而不影响梯度传播。更妙的是，**更大的权重反而导致更小的梯度**，于是 BN 会自动稳定参数增长，防止大学习率引发的爆炸。

**正则化效果**：用 BN 训练时，一个样本是**和 mini-batch 里其他样本一起**被看到的，网络对某个样本不再产生确定性输出（因为归一化统计量随 batch 组成而抖动）。实验发现这有利于泛化。因此 Dropout 在 BN 网络里可以**移除或减弱**。

**详细解析**

- **大学习率的数学保证**：传统网络里大学习率会放大权重→放大梯度→爆炸；BN 让「权重尺度」与「梯度传播」解耦（缩放权重不改梯度方向，且大权重自动配小梯度），从而打破这个恶性循环。这是 BN 能训练快 14 倍的核心机理之一。
- **正则化来自 batch 噪声**：每个样本的归一化依赖于「它恰好和谁同 batch」，引入了随机扰动，类似 Dropout 的随机性，故有正则效果。这也是为何 BN 常能减少对 Dropout 的依赖。

---

## 4 实验 Experiments

### 4.1 MNIST 上的激活分布演化

**中文翻译（要点）**：用一个简单的 3 层全连接 + sigmoid 网络在 MNIST 上验证。加 BN 后：① 测试精度更高、收敛更快；② 跟踪某个 sigmoid 输入的 {15,50,85} 分位数发现——**无 BN 时分布随训练剧烈漂移（均值方差都在变），有 BN 时分布稳定得多**，直接印证了「减少内部协变量偏移」。

### 4.2 ImageNet 分类（BN-Inception）

> [!quote] 原文（加速 BN 网络的配方）
> Increase learning rate... Remove Dropout... Reduce the L2 weight regularization... Accelerate the learning rate decay... Remove Local Response Normalization... Shuffle training examples more thoroughly... Reduce the photometric distortions.

**中文翻译（充分发挥 BN 的改造清单）**

仅仅加上 BN 还不够，作者进一步改造网络与训练：① **提高学习率**；② **移除 Dropout**；③ **L2 权重正则减弱 5 倍**；④ **学习率衰减加快 6 倍**（因为训得更快）；⑤ **移除局部响应归一化 LRN**；⑥ **更彻底地打乱训练样本**（增强 BN 的正则随机性，约 +1% 验证精度）；⑦ **减少光度畸变增强**（因为训练更快、每个样本看得更少，让模型看更"真实"的图）。

**表（达到 Inception 72.2% 精度所需训练步数 / 最高精度）**

| 模型 | 达到 72.2% 所需步数 | 最高精度 |
| --- | --- | --- |
| Inception（基线） | 31.0 ×10⁶ | 72.2% |
| BN-Baseline（仅加 BN） | 13.3 ×10⁶ | 72.7% |
| **BN-x5**（学习率 ×5） | **2.1 ×10⁶** | 73.0% |
| **BN-x30**（学习率 ×30） | 2.7 ×10⁶ | **74.8%** |
| BN-x5-Sigmoid（用 sigmoid） | — | 69.8% |

> [!quote] 原文
> By only using Batch Normalization (BN-Baseline), we match the accuracy of Inception in less than half the number of training steps... BN-x5 needs 14 times fewer steps than Inception to reach the 72.2% accuracy... We also verified that... deep networks with Batch Normalization [can] be trained when sigmoid is used... BN-x5-Sigmoid achieves the accuracy of 69.8%. Without Batch Normalization, Inception with sigmoid never achieves better than 1/1000 accuracy.

**中文翻译（结果要点）**

- 仅加 BN（BN-Baseline）就用**不到一半步数**达到基线精度；配合上述改造，**BN-x5 用少 14 倍的步数**达到 72.2%。
- BN-x30 初期略慢但最终精度更高，达 74.8%。
- **最震撼的对照**：BN-x5-Sigmoid（用 sigmoid 非线性）能达 69.8%；而**不带 BN 的 sigmoid Inception 永远只有约 1/1000 的随机精度**——BN 让饱和非线性也能训练深网络。
- **集成**：6 个 BN 网络集成达到 **4.9% top-5 验证误差（4.82% 测试误差）**，刷新 ImageNet 纪录并超过人类评定者。

**详细解析**

- 「14 倍加速」和「超过人类」是当年的爆点，BN 由此迅速成为 CNN 标配。
- BN-x5-Sigmoid 的意义：它证明 BN 直接攻击了「饱和非线性难训」这一历史顽疾——虽然 ReLU 也能解决梯度消失，但 BN 提供了正交且更普适的工具。

---

## 5 结论 Conclusion

> [!quote] 原文
> ...Our proposed method draws its power from normalizing activations, and from incorporating this normalization in the network architecture itself. This ensures that the normalization is appropriately handled by any optimization method that is being used to train the network... Batch Normalization adds only two extra parameters per activation, and in doing so preserves the representation ability of the network... The resulting networks can be trained with saturating nonlinearities, are more tolerant to increased training rates, and often do not require Dropout for regularization... Our future work includes applications of our method to Recurrent Neural Networks...

**中文翻译**

我们提出了一种大幅加速深网络训练的新机制。其力量来自：**归一化激活**，并把这种归一化**纳入网络架构本身**——这确保了无论用何种优化方法，归一化都能被正确处理。为支持深度学习常用的随机优化，我们对每个 mini-batch 做归一化，并让梯度穿过归一化参数反向传播。BN 每个激活只增加两个额外参数（$\gamma, \beta$），同时保留了网络的表达能力。

由此得到的网络：**能用饱和非线性训练、对更大学习率更容忍、且常常不再需要 Dropout 做正则**。仅仅把 BN 加进当时最先进的图像分类模型就能显著加速训练；进一步提高学习率、移除 Dropout 等改造后，用极少的训练步数就达到甚至超越了原 SOTA。未来工作包括把 BN 应用于 RNN（其内部协变量偏移和梯度问题可能尤为严重）等。

**详细解析**

- 「把归一化做成架构的一部分、并让它可微」是本文方法论上最深刻的贡献——后续 LayerNorm、GroupNorm、InstanceNorm、RMSNorm 等一系列归一化技术都沿袭这一思路。
- 论文预言的 RNN 方向，后来催生了 Layer Normalization（Transformer 用的就是它，因为 BN 不适合变长序列和小 batch）。

---

## 附录：核心公式与要点速查

| 项 | 内容 |
| --- | --- |
| mini-batch 均值 | $\mu_B = \frac{1}{m}\sum_i x_i$ |
| mini-batch 方差 | $\sigma_B^2 = \frac{1}{m}\sum_i (x_i-\mu_B)^2$ |
| 归一化 | $\hat{x}_i = \dfrac{x_i - \mu_B}{\sqrt{\sigma_B^2 + \epsilon}}$ |
| 缩放平移（可学习） | $y_i = \gamma \hat{x}_i + \beta$ |
| 推理（用总体统计量） | $\hat{x} = \dfrac{x - E[x]}{\sqrt{\mathrm{Var}[x]+\epsilon}}$，$\mathrm{Var}[x]=\frac{m}{m-1}E_B[\sigma_B^2]$ |
| 放置位置 | `Conv/FC(去bias) → BN → 非线性(ReLU)` |
| 卷积版 | 每个特征图（通道）一对 $\gamma,\beta$，跨 batch 与所有空间位置统计 |
| 四大收益 | 大学习率 / 不挑初始化 / 自带正则(减免 Dropout) / 可训饱和非线性 |
| 注意点 | 训练用 batch 统计量、推理用全局统计量；对小 batch 敏感 |

---

> [!tip] 脉络与延伸
> - 同期/相关：[ResNet (He 2015)](https://arxiv.org/abs/1512.03385)（残差 + BN 是训练超深网络的黄金组合）、[GoogLeNet/Inception (2014)](https://arxiv.org/abs/1409.4842)
> - 后继归一化技术：Layer Normalization（Transformer 采用）、Group Normalization（小 batch 友好）
> - 再思考 BN 为何有效：How Does Batch Normalization Help Optimization? (Santurkar et al. 2018, [arXiv:1805.11604](https://arxiv.org/abs/1805.11604))

## Related

- [[navigation-ai-ml]]
- [[AI]]
- [[Machine Learning]]
