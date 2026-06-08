# Neural Machine Translation by Jointly Learning to Align and Translate —— 全文翻译与详细解析

> [!info] 论文信息
> - **标题**：Neural Machine Translation by Jointly Learning to Align and Translate（通过联合学习对齐与翻译的神经机器翻译）
> - **作者**：Dzmitry Bahdanau, KyungHyun Cho, Yoshua Bengio（Jacobs University / Université de Montréal）
> - **发表**：ICLR 2015 · [arXiv:1409.0473](https://arxiv.org/abs/1409.0473)
> - **历史地位**：**注意力机制（Attention）的开山之作**。提出的模型常被称为 **RNNsearch**。直接启发了后来的 Transformer。

> [!abstract] 本文档说明
> 按「**原文 → 中文翻译 → 详细解析**」三段式逐节组织。原文摘自 arXiv PDF，长段做了节选。解析为译注补充。

---

## 摘要 Abstract

> [!quote] 原文
> ...The models proposed recently for neural machine translation often belong to a family of encoder–decoders and encode a source sentence into a fixed-length vector from which a decoder generates a translation. In this paper, we conjecture that the use of a fixed-length vector is a bottleneck in improving the performance of this basic encoder–decoder architecture, and propose to extend this by allowing a model to automatically (soft-)search for parts of a source sentence that are relevant to predicting a target word, without having to form these parts as a hard segment explicitly. With this new approach, we achieve a translation performance comparable to the existing state-of-the-art phrase-based system on the task of English-to-French translation. Furthermore, qualitative analysis reveals that the (soft-)alignments found by the model agree well with our intuition.

**中文翻译**

近期提出的神经机器翻译模型多属于「编码器-解码器」家族，它们把源句编码成一个**固定长度的向量**，再由解码器从该向量生成译文。本文**猜想：使用固定长度向量正是制约这一基础编码器-解码器架构性能提升的瓶颈**，并提出加以扩展——让模型在预测每个目标词时，**自动地（软）搜索**源句中与之相关的部分，而无需显式地把这些部分切成硬性的片段。借助这一新方法，我们在英译法任务上取得了与现有最先进短语系统相当的翻译性能。此外，定性分析表明，模型找到的（软）对齐与我们的直觉高度吻合。

**详细解析**

- 一句话概括贡献：**「不再把整句压成一个向量，而是让解码器在生成每个词时，回头去源句里『按需检索』最相关的部分。」** 这就是注意力机制。
- **(soft-)search / (soft-)alignment** 是本文的关键词。「软」= 用一个概率分布（权重）对所有源词加权，而非硬性地只选一个对齐位置——这使整个过程**可微、可端到端训练**。
- 这篇论文与 Seq2Seq（2014）是同期工作，但精准地诊断出了 Seq2Seq 的病根（定长向量瓶颈）并给出了根治方案，影响更为深远。

---

## 1 引言 Introduction

> [!quote] 原文
> A potential issue with this encoder–decoder approach is that a neural network needs to be able to compress all the necessary information of a source sentence into a fixed-length vector. This may make it difficult for the neural network to cope with long sentences, especially those that are longer than the sentences in the training corpus... In order to address this issue, we introduce an extension to the encoder–decoder model which learns to align and translate jointly. Each time the proposed model generates a word in a translation, it (soft-)searches for a set of positions in a source sentence where the most relevant information is concentrated... The most important distinguishing feature of this approach from the basic encoder–decoder is that it does not attempt to encode a whole input sentence into a single fixed-length vector. Instead, it encodes the input sentence into a sequence of vectors and chooses a subset of these vectors adaptively while decoding the translation.

**中文翻译**

编码器-解码器方法的一个潜在问题是：神经网络必须把源句的所有必要信息**压缩进一个固定长度的向量**。这会让网络难以应对长句子，尤其是比训练语料中更长的句子。Cho et al. (2014b) 已证明，基础编码器-解码器的性能确实随着输入句长增加而**急剧下降**。

为解决这一问题，我们对编码器-解码器模型做了扩展，使其**联合地学习对齐与翻译**。每当模型生成译文中的一个词时，它就（软）搜索源句中信息最集中的一组位置，然后基于这些位置对应的**上下文向量**以及此前已生成的所有目标词，预测下一个目标词。

本方法与基础编码器-解码器最重要的区别是：它**不试图把整个输入句子编码成单个固定长度向量**，而是把输入句子编码成**一串向量**，并在解码时**自适应地选取这些向量的一个子集**。这把神经翻译模型从「无论句子多长都要把所有信息塞进定长向量」的负担中解放出来。

**详细解析**

- **病因诊断**：Seq2Seq 的定长向量 $c$ 像一个容量固定的「漏斗」，句子越长，信息丢失越严重。论文图 2 直接验证了 RNNencdec 的 BLEU 随句长崩溃，而 RNNsearch 几乎不退化。
- **解法的本质转变**：编码器输出从「**一个**向量」变成「**一串**向量（每个词一个）」，解码器每步动态地决定「这一刻该看源句的哪些词」。容量随句长自动扩展，瓶颈消失。

---

## 2 背景：神经机器翻译 Background

> [!quote] 原文
> In the Encoder–Decoder framework, an encoder reads the input sentence, a sequence of vectors $x = (x_1, \cdots, x_{T_x})$, into a vector $c$. The most common approach is to use an RNN such that
> $$h_t = f(x_t, h_{t-1})$$
> and $c = q(\{h_1, \cdots, h_{T_x}\})$, where $h_t \in \mathbb{R}^n$ is a hidden state at time $t$... Sutskever et al. (2014) used an LSTM as $f$ and $q(\{h_1, \cdots, h_T\}) = h_T$, for instance.
> ...the decoder defines a probability over the translation $y$ by decomposing the joint probability into the ordered conditionals:
> $$p(y) = \prod_{t=1}^{T} p(y_t | \{y_1, \cdots, y_{t-1}\}, c)$$

**中文翻译**

在编码器-解码器框架中，编码器把输入句（向量序列 $x = (x_1, \cdots, x_{T_x})$）读入为一个向量 $c$。最常见的做法是用 RNN：

$$h_t = f(x_t, h_{t-1}), \qquad c = q(\{h_1, \cdots, h_{T_x}\})$$

其中 $h_t \in \mathbb{R}^n$ 是 $t$ 时刻的隐藏状态，$f, q$ 是某些非线性函数。例如 Sutskever et al.(2014) 用 LSTM 作为 $f$，并取 $q(\{h_1, \cdots, h_T\}) = h_T$（即直接取最后一个隐藏状态作为 $c$）。

解码器通过把联合概率分解为有序条件概率，定义译文 $y$ 上的概率：

$$p(y) = \prod_{t=1}^{T} p(y_t \mid \{y_1, \cdots, y_{t-1}\}, c)$$

每个条件概率用 RNN 建模为 $p(y_t \mid \{y_1, \cdots, y_{t-1}\}, c) = g(y_{t-1}, s_t, c)$，其中 $s_t$ 是 RNN 的隐藏状态。

**详细解析**

- 这一节是对 Seq2Seq 范式的形式化复述。**关键点**：传统做法里，$c$ 是**唯一且固定**的，每一步解码用的都是同一个 $c$。下一节的注意力将把这个固定的 $c$ 替换为**逐步变化的 $c_i$**。

---

## 3 学习对齐与翻译 Learning to Align and Translate（核心）

> [!note] 图 1（模型示意）
> 解码器在生成第 $i$ 个目标词 $y_i$ 时，对编码器的一串标注 $(h_1, \dots, h_T)$ 计算一组注意力权重 $\alpha_{i,1}, \dots, \alpha_{i,T}$，加权求和得到该步专属的上下文向量 $c_i$。编码器是**双向 RNN**。

### 3.1 解码器：新的条件概率

> [!quote] 原文
> In a new model architecture, we define each conditional probability in Eq. (2) as:
> $$p(y_i | y_1, \dots, y_{i-1}, x) = g(y_{i-1}, s_i, c_i)$$
> where $s_i$ is an RNN hidden state for time $i$, computed by $s_i = f(s_{i-1}, y_{i-1}, c_i)$. It should be noted that unlike the existing encoder–decoder approach, here the probability is conditioned on a distinct context vector $c_i$ for each target word $y_i$. The context vector $c_i$ is... computed as a weighted sum of these annotations $h_i$:
> $$c_i = \sum_{j=1}^{T_x} \alpha_{ij} h_j$$
> The weight $\alpha_{ij}$ of each annotation $h_j$ is computed by
> $$\alpha_{ij} = \frac{\exp(e_{ij})}{\sum_{k=1}^{T_x} \exp(e_{ik})}, \quad \text{where} \quad e_{ij} = a(s_{i-1}, h_j)$$
> is an alignment model which scores how well the inputs around position $j$ and the output at position $i$ match.

**中文翻译**

在新架构中，我们把每个条件概率定义为：

$$p(y_i \mid y_1, \dots, y_{i-1}, x) = g(y_{i-1}, s_i, c_i)$$

其中 $s_i$ 是解码器 $i$ 时刻的 RNN 隐藏状态，由 $s_i = f(s_{i-1}, y_{i-1}, c_i)$ 计算。**注意：与已有编码器-解码器不同，这里的概率是以一个为每个目标词 $y_i$ 单独计算的上下文向量 $c_i$ 为条件的**（而非共享同一个 $c$）。

上下文向量 $c_i$ 是编码器标注序列 $(h_1, \cdots, h_{T_x})$ 的**加权和**：

$$c_i = \sum_{j=1}^{T_x} \alpha_{ij} h_j$$

每个标注 $h_j$ 的权重 $\alpha_{ij}$ 由 **softmax** 归一化得到：

$$\alpha_{ij} = \frac{\exp(e_{ij})}{\sum_{k=1}^{T_x} \exp(e_{ik})}, \qquad e_{ij} = a(s_{i-1}, h_j)$$

这里 $e_{ij}$ 是一个**对齐模型（alignment model）**，用于打分「源句位置 $j$ 附近的输入」与「位置 $i$ 的输出」匹配得有多好。打分依据是解码器上一隐藏状态 $s_{i-1}$（即将生成 $y_i$ 之前）和源句第 $j$ 个标注 $h_j$。

> [!quote] 原文（续）
> We parametrize the alignment model $a$ as a feedforward neural network which is jointly trained with all the other components... the alignment model directly computes a soft alignment, which allows the gradient of the cost function to be backpropagated through... Intuitively, this implements a mechanism of attention in the decoder. The decoder decides parts of the source sentence to pay attention to. By letting the decoder have an attention mechanism, we relieve the encoder from the burden of having to encode all information in the source sentence into a fixed-length vector.

**中文翻译（续）**

我们把对齐模型 $a$ 参数化为一个**前馈神经网络**，与系统的其他所有组件**联合训练**。注意：不同于传统机器翻译把对齐当作隐变量，这里对齐模型直接计算一个**软对齐**，使得代价函数的梯度可以反向传播穿过它——这个梯度既能训练对齐模型，也能联合训练整个翻译模型。

我们可以把「对所有标注取加权和」理解为计算一个**期望标注**（期望是对所有可能对齐取的）。设 $\alpha_{ij}$ 为目标词 $y_i$ 对齐到（或译自）源词 $x_j$ 的概率，则第 $i$ 个上下文向量 $c_i$ 就是按概率 $\alpha_{ij}$ 对所有标注取的期望。

直觉上，**这在解码器中实现了一种注意力机制**：解码器自己决定该关注源句的哪些部分。让解码器拥有注意力，就把编码器从「必须把源句所有信息塞进定长向量」的重担中解放了出来。

**详细解析**

- **这就是注意力机制的诞生公式**。把它和两年后 Transformer 的 $\mathrm{softmax}(QK^T/\sqrt{d_k})V$ 对照：
  - $\alpha_{ij}$ ↔ 注意力权重（softmax 归一化）；
  - $e_{ij} = a(s_{i-1}, h_j)$ ↔ query 与 key 的相似度分数（这里 query = $s_{i-1}$，key = $h_j$）；
  - $c_i = \sum_j \alpha_{ij} h_j$ ↔ 用权重对 value（$h_j$）加权求和。
  - 区别：Bahdanau 用**加性注意力**（前馈网络 $v_a^\top \tanh(W_a s_{i-1} + U_a h_j)$）算分；Transformer 改用更快的**点积**并加 $\sqrt{d_k}$ 缩放。
- **「软对齐可微」是关键创新**：传统 SMT 把词对齐当作离散隐变量（不可导，需 EM 等特殊算法）；这里用 softmax 把对齐变成连续权重，于是整个系统能用普通反向传播端到端训练。
- **每步一个 $c_i$**：这是与 Seq2Seq 最本质的差异——上下文不再固定，而是「随生成进程动态聚焦」。

### 3.2 编码器：用于标注序列的双向 RNN

> [!quote] 原文
> ...we would like the annotation of each word to summarize not only the preceding words, but also the following words. Hence, we propose to use a bidirectional RNN (BiRNN)... We obtain an annotation for each word $x_j$ by concatenating the forward hidden state $\overrightarrow{h}_j$ and the backward one $\overleftarrow{h}_j$, i.e., $h_j = [\overrightarrow{h}_j^\top ; \overleftarrow{h}_j^\top]^\top$. In this way, the annotation $h_j$ contains the summaries of both the preceding words and the following words.

**中文翻译**

我们希望每个词的标注不仅总结**之前**的词，也总结**之后**的词。因此我们采用**双向 RNN（BiRNN）**：前向 RNN 按正序（$x_1 \to x_{T_x}$）读取，得到前向隐藏状态 $(\overrightarrow{h}_1, \cdots, \overrightarrow{h}_{T_x})$；后向 RNN 按逆序（$x_{T_x} \to x_1$）读取，得到后向隐藏状态 $(\overleftarrow{h}_1, \cdots, \overleftarrow{h}_{T_x})$。我们把两者拼接得到每个词 $x_j$ 的标注：

$$h_j = \left[\overrightarrow{h}_j^\top ; \overleftarrow{h}_j^\top\right]^\top$$

这样标注 $h_j$ 同时包含了**前文和后文**的摘要。由于 RNN 倾向于更好地表示最近的输入，$h_j$ 会聚焦于 $x_j$ 周围的词。

**详细解析**

- **为什么用双向**：注意力要让每个源位置 $j$ 的标注 $h_j$ 成为「以 $x_j$ 为中心的局部上下文摘要」。单向 RNN 的 $h_j$ 只含 $x_1 \dots x_j$（看不到后文），双向拼接后才能同时编码左右上下文。
- 这与 Seq2Seq 的「倒序输入」形成有趣对比：Seq2Seq 用廉价 trick 缓解路径过长，而这里用双向 RNN + 注意力**正面解决**。

---

## 4-5 实验与结果 Experiments & Results

**模型**：对比两类模型——基础的 **RNNencdec**（Cho 2014a，定长向量）与本文的 **RNNsearch**（带注意力）。各训练两次：句长 ≤30（-30）和 ≤50（-50）。每个隐藏层 1000 单元，词嵌入 620 维。用 SGD + Adadelta，minibatch=80，训练约 5 天。

**表 1：测试集 BLEU**

| 模型 | 全部句子 (All) | 无未登录词 (No UNK) |
| --- | --- | --- |
| RNNencdec-30 | 13.93 | 24.19 |
| **RNNsearch-30** | 21.50 | 31.44 |
| RNNencdec-50 | 17.82 | 26.71 |
| **RNNsearch-50** | 26.75 | 34.16 |
| **RNNsearch-50\*** (训练更久) | 28.45 | 36.15 |
| Moses（短语 SMT 基线） | 33.30 | 35.63 |

> [!quote] 原文
> ...in all the cases, the proposed RNNsearch outperforms the conventional RNNencdec. More importantly, the performance of the RNNsearch is as high as that of the conventional phrase-based translation system (Moses), when only the sentences consisting of known words are considered... In Fig. 2, we see that the performance of RNNencdec dramatically drops as the length of the sentences increases. On the other hand, both RNNsearch-30 and RNNsearch-50 are more robust to the length of the sentences. RNNsearch-50, especially, shows no performance deterioration even with sentences of length 50 or more.

**中文翻译（要点）**

- 在所有情形下，**RNNsearch 都超过 RNNencdec**。更重要的是，当只考虑不含未登录词的句子时，RNNsearch 的性能**已与传统短语系统 Moses 相当**（36.15 vs 35.63）——而 Moses 还额外用了 4.18 亿词的单语语料。
- 图 2 显示：RNNencdec 的 BLEU 随句长**急剧下降**；而 RNNsearch（尤其 -50）对句长**鲁棒，长句几乎不退化**。甚至 RNNsearch-30 都超过了 RNNencdec-50，进一步印证了注意力的优势。

**详细解析**

- **定长向量瓶颈被实证**：注意力主要的增益来自长句。短句两者差距小，长句 RNNencdec 崩溃、RNNsearch 稳定——这正是「容量随句长自适应」的直接证据。
- RNNsearch 在「无 UNK」设定下追平了用更多数据的 Moses，是**纯神经 NMT 走向主流的转折点**。

### 5.2 定性分析：对齐可视化

> [!quote] 原文
> The proposed approach provides an intuitive way to inspect the (soft-)alignment between the words in a generated translation and those in a source sentence... we also observe a number of non-trivial, non-monotonic alignments. Adjectives and nouns are typically ordered differently between French and English... the model correctly translates a phrase [European Economic Area] into [zone économique européen]. The RNNsearch was able to correctly align [zone] with [Area], jumping over the two words... The strength of the soft-alignment, opposed to a hard-alignment, is evident... [the man] which was translated into [l' homme]. Any hard alignment will map [the] to [l']... Our soft-alignment solves this issue naturally by letting the model look at both [the] and [man].

**中文翻译**

本方法提供了一种直观的方式来检查译文词与源句词之间的（软）对齐——把注意力权重 $\alpha_{ij}$ 可视化为灰度矩阵（图 3）。从中可见：

- 英法对齐**大体是单调的**（矩阵对角线权重强），但也存在不少**非单调对齐**。例如形容词和名词在法、英中语序不同：模型把 `European Economic Area` 正确译为 `zone économique européenne`——它能把 `zone` 正确对齐到 `Area`（**跳过** `European`、`Economic` 两个词），再逐词回看以补全整个短语。
- **软对齐相对硬对齐的优势**很明显。如 `the man` → `l' homme`：任何硬对齐都会把 `the` 映射到 `l'`，但这没用——要确定 `the` 该译成 `le/la/les/l'`，必须看 `the` **后面**的词。软对齐让模型**同时看 `the` 和 `man`**，自然解决了这个问题；它也天然地处理了源/目标短语长度不一致的情况，无需把词映射到 `[NULL]` 这种反直觉操作。

**详细解析**

- **可解释性是注意力的「副产品大礼包」**：$\alpha_{ij}$ 矩阵直接画出了「翻译每个目标词时模型在看源句的哪里」，与语言学直觉吻合。这一可视化范式被后来所有注意力工作沿用（包括 Transformer 论文的附录）。
- 「跳过两个词去对齐 `zone↔Area`」生动展示了注意力**处理长距离、非单调依赖**的能力——这正是 RNN 顺序结构难以做到的。

---

## 7 结论 Conclusion

> [!quote] 原文
> ...We extended the basic encoder–decoder by letting a model (soft-)search for a set of input words, or their annotations computed by an encoder, when generating each target word. This frees the model from having to encode a whole source sentence into a fixed-length vector, and also lets the model focus only on information relevant to the generation of the next target word... Perhaps more importantly, the proposed approach achieved a translation performance comparable to the existing phrase-based statistical machine translation... One of challenges left for the future is to better handle unknown, or rare words.

**中文翻译**

传统的神经机器翻译（编码器-解码器）把整个输入句编码成定长向量再解码。基于 Cho(2014b) 等的实证，我们猜想定长上下文向量对翻译长句是有问题的。本文提出新架构解决该问题：让模型在生成每个目标词时（软）搜索一组输入词（或编码器算出的标注）。这把模型从「把整句塞进定长向量」中解放出来，也让模型**只聚焦于与生成下一个目标词相关的信息**，对长句性能有重大正面影响。与传统系统不同，**包括对齐机制在内的所有部件都被联合训练**，朝着「产生正确译文的更高对数概率」优化。

实验（英译法）表明，RNNsearch 无论句长都显著超过 RNNencdec，且对源句长度鲁棒得多。定性分析（软对齐可视化）表明模型能正确地把每个目标词与源句中的相关词对齐。也许更重要的是，本方法取得了与现有短语 SMT 相当的性能——考虑到整个神经 MT 家族才刚被提出，这是个惊人的结果。未来的挑战之一是**更好地处理未登录/罕见词**。

**详细解析**

- 「更好处理罕见词」这一遗留挑战，随后由 **BPE / WordPiece 子词切分**（Sennrich 2015）解决。
- **承上启下**：本文确立了「注意力」这一组件。Transformer（2017）把它推到极致——**抛弃 RNN，纯靠（自）注意力**，标题 *Attention Is All You Need* 正是对本文思想的致敬与升华。

---

## 附录：核心公式速查表

| 名称 | 公式 |
| --- | --- |
| 新条件概率 | $p(y_i \mid y_1,\dots,y_{i-1}, x) = g(y_{i-1}, s_i, c_i)$ |
| 解码器状态 | $s_i = f(s_{i-1}, y_{i-1}, c_i)$ |
| 上下文向量（每步不同） | $c_i = \sum_{j=1}^{T_x} \alpha_{ij} h_j$ |
| 注意力权重 | $\alpha_{ij} = \dfrac{\exp(e_{ij})}{\sum_{k=1}^{T_x}\exp(e_{ik})}$ |
| 对齐打分（加性注意力） | $e_{ij} = a(s_{i-1}, h_j) = v_a^\top \tanh(W_a s_{i-1} + U_a h_j)$ |
| 双向标注 | $h_j = [\overrightarrow{h}_j^\top ; \overleftarrow{h}_j^\top]^\top$ |

> [!tip] 与 Transformer 的对应关系
> Bahdanau 加性注意力 $e_{ij}=v_a^\top\tanh(W_a s_{i-1}+U_a h_j)$ → Transformer 缩放点积 $\frac{q\cdot k}{\sqrt{d_k}}$；
> query = $s_{i-1}$，key = value = $h_j$；权重归一化都用 softmax；加权求和得上下文。**机制完全同源，只是打分函数和是否用 RNN 不同。**

---

> [!tip] 脉络
> - 前置：[Seq2Seq (Sutskever 2014)](https://arxiv.org/abs/1409.3215)、[GRU / RNN Encoder-Decoder (Cho 2014)](https://arxiv.org/abs/1406.1078)
> - 后继巅峰：[Attention Is All You Need / Transformer (2017)](https://arxiv.org/abs/1706.03762)
> - 图解：[The Illustrated Transformer](https://jalammar.github.io/illustrated-transformer/)
