# 🗺️ AI 学习与实验进阶知识库总纲

> [!abstract] 核心学习理念
> **从底层手工造轮子开始，逐步过渡到工业级框架，最终落地大模型工程。**
> 坚持以 Python 代码实验驱动理论理解，每日成果及时复盘并向外建立双向链接。

---

## 📊 总体进度看板

- [ ] **阶段一：纯 NumPy 实现 CNN** (预计: 2-3周) · `进度: 95% (MLP + CNN 均已跑通，待收尾复盘)`
- [ ] **阶段二：PyTorch 与 ResNet 工业实战** (预计: 2-3周) · `进度: 0%`
- [ ] **阶段三：Transformer 架构破壁** (预计: 3-4周) · `进度: 0%`
- [ ] **阶段四：LLM 微调与大模型生态** (预计: 4-6周) · `进度: 0%`

> [!tip] 更新日志（2026-06-08）
> 阶段一两大里程碑均已落地：`mlp/`（双层 MLP，含超参实验/错误分析/优化/OOD）与 `cnn/`（纯 NumPy 卷积，**测试集 98.51%**）。
> 阶段一剩余工作主要是复盘沉淀与对比 MLP/CNN 的鲁棒性结论，随后即可进入阶段二。

---

## 🎯 阶段一：深扎底层逻辑 —— 纯 NumPy 实现 CNN
- **核心工具：** Python 3.10+, NumPy (拒绝任何自动求导框架)
- **开发环境：** 本地 Ubuntu/windows + Cursor / VS Code

### 📅 计划安排与 Checklist
- [x] **Step 1: MLP 跑通 MNIST (已搞定！)** —— 见 `mlp/`，测试集 ~98%
	- [x] 搭建基础多层感知机架构
	- [x] 实现 Forward & Backward 链式法则
	- [x] 额外完成：超参实验 / 错误分析 / 优化 / 数据增强鲁棒性 / OOD 检测
- [x] **Step 2: 掌握 3D/4D 张量与滑动窗口操作 (已搞定！)**
	- [x] 推导卷积前向传播：理解输入形状 `[Batch, Channel, Height, Width]`
	- [x] 掌握滑动窗口的 index 变换逻辑（用 **im2col / col2im** 把卷积转成矩阵乘，向量化加速）
- [x] **Step 3: 纯 NumPy 编写 Conv2D & MaxPool2D 算子 (已搞定！)** —— 见 `cnn/cnn.py`
	- [x] 实现 `Conv2D.forward()` 和 `MaxPool2D.forward()`
	- [x] **核心硬核任务**：推导并实现 `Conv2D.backward()` 梯度回传（含 MaxPool 掩码反池化、ReLU 掩码）
	- [x] 优化器实现 Adam，配合 L2 正则与 FC 层 Dropout
- [x] **Step 4: 整合模型并跑通 MNIST 识别 (已搞定！)** —— 见 `cnn/train_eval.py`
	- [x] 组装结构：`Input -> Conv2D(3x3,32) -> ReLU -> MaxPool2D(2x2) -> FC -> Softmax`
	- [x] 绘制验证集 Accuracy 曲线，**测试集准确率 98.51%（错误 149/10000）**
	- [x] 额外完成：错误/混淆矩阵分析、CNN 平移不变性与"训练时增强"鲁棒性对比（`cnn/augment_eval.py`）
- [ ] **Step 5: 收尾复盘（待办，预计 1-2 天）**
	- [ ] 整理 MLP vs CNN 在 clean / rotate / shift / scale 下的鲁棒性对照结论
	- [ ] 把"卷积带来的平移不变性""感受野""参数共享"等概念沉淀进 Obsidian
	- [ ] 补全 `cnn/README.md`（参照 `mlp/README.md` 的结构）

### 🔗 实验物资与参考
- **项目目录：** [wanghaven/neuralnetworks](https://github.com/wanghaven/neuralnetworks) · 本地 `c:\work\code\others\neuralnetworks`
	- MLP 子项目：`mlp/`（`mlp.py` 模型 + `experiments.py` / `analyze_errors.py` / `optimize.py` / `ood_detection.py`）
	- CNN 子项目：`cnn/`（`cnn.py` 模型 + `train_eval.py` 训练评估 + `augment_eval.py` 增强鲁棒性）
- **必看课程（强烈推荐按顺序）：**
	- [[斯坦福 CS231n]] —— [课程主页](https://cs231n.github.io/) | [卷积网络笔记](https://cs231n.github.io/convolutional-networks/) | [反向传播笔记](https://cs231n.github.io/optimization-2/)（理解 im2col 与卷积反传的最佳材料，对应 Assignment 2）
	- [3Blue1Brown - 神经网络系列（视频，直觉建立）](https://www.youtube.com/playlist?list=PLZHQObOWTQDNU6R1_67000Dx_ZCJB-3pi) | [B 站搬运](https://www.bilibili.com/video/BV1bx411M7Zx)
	- [Andrej Karpathy - Neural Networks: Zero to Hero（micrograd 手撕反向传播）](https://www.youtube.com/playlist?list=PLAqhIrjkxbuWI23v9cThsA9GvCAUhRvKZ)
- **卷积/im2col 原理详解：**
	- [CS231n 卷积层实现讲义（im2col 推导）](https://cs231n.github.io/convolutional-networks/#conv)
	- [图解卷积算术 - A guide to convolution arithmetic](https://github.com/vdumoulin/conv_arithmetic)（带动图，秒懂 padding/stride/output 尺寸）
	- [《动手学深度学习》卷积神经网络章节](https://zh.d2l.ai/chapter_convolutional-neural-networks/index.html)
- **数学基础查漏补缺：** [反向传播算法图解 - colah's blog](https://colah.github.io/posts/2015-08-Backprop/) | [矩阵求导 The Matrix Calculus You Need For Deep Learning](https://explained.ai/matrix-calculus/)
- **每日笔记索引：** [[阶段一每日实验复盘]]

---

## 🎯 阶段二：工业级工程跨越 —— PyTorch 与 ResNet
- **核心工具：** PyTorch, torchvision, Local GPU/CPU
- **开发环境：** 本地Linux + CUDA 环境配置

### 📅 计划安排与 Checklist
- [ ] **Step 1: 框架重构与 Autograd 对比体验** (预计 3 天)
	- [ ] 用 PyTorch `nn.Module` 重写上一阶段的 CNN
	- [ ] 对比手写反向传播，体验 `loss.backward()` 和 `optimizer.step()` 的底层封装
- [ ] **Step 2: 攻克残差连接 (Skip Connection)** (预计 4 天)
	- [ ] 深入阅读李沐团队教材，理解残差克服梯度消失的数学原理
	- [ ] 自定义实现一个 `ResidualBlock` 模块
- [ ] **Step 3: 挑战彩色数据集 CIFAR-10** (预计 5 天)
	- [ ] 编写数据加载器（DataLoader）和数据增强（Data Augmentation）
	- [ ] 搭建完整的 **ResNet-18** 架构并完成训练

### 🔗 实验物资与参考
- **本地项目目录：** 建议在仓库内新建 `cnn_pytorch/` 子项目，与 `cnn/` 平级，便于"手写 vs 框架"直接对照
- **权威教材：** [[动手学深度学习-李沐]]
	- [D2L 在线书（中文）](https://zh.d2l.ai/) | [现代卷积网络 / ResNet 章节](https://zh.d2l.ai/chapter_convolutional-modern/resnet.html)
	- [李沐《动手学深度学习》B 站精讲视频](https://space.bilibili.com/1567748478/channel/seriesdetail?sid=358497)
- **官方文档与教程：**
	- [PyTorch 60 Minute Blitz（入门必做）](https://pytorch.org/tutorials/beginner/deep_learning_60min_blitz.html)
	- [Autograd 机制详解](https://pytorch.org/tutorials/beginner/basics/autogradqs_tutorial.html)（对照你手写的 backward 体会自动求导）
	- [torchvision 数据集与变换（CIFAR-10 / transforms）](https://pytorch.org/vision/stable/index.html)
	- [PyTorch 训练分类器官方教程（CIFAR-10）](https://pytorch.org/tutorials/beginner/blitz/cifar10_tutorial.html)
- **残差网络原论文：** [Deep Residual Learning for Image Recognition (He et al., 2015)](https://arxiv.org/abs/1512.03385)
- **CUDA/环境配置：** [PyTorch 本地安装选择器](https://pytorch.org/get-started/locally/)
- **每日笔记索引：** [[阶段二每日实验复盘]]

---

## 🎯 阶段三：跨越分水岭 —— Transformer 架构剖析
- **核心工具：** PyTorch, `einops` (极力推荐的张量维度管理神器)
- **开发环境：** **Google Colab** (白嫖云端 T4/A100 算力)

### 📅 计划安排与 Checklist
- [ ] **Step 1: 降维打击 —— 自注意力机制 (Self-Attention)** (预计 5 天)
	- [ ] 推导 $Q, K, V$ 矩阵乘法及常数缩放 $\sqrt{d_k}$ 的必要性
	- [ ] 纯手敲 `MultiHeadAttention` 模块，严密监控 Tensor 维度变换
- [ ] **Step 2: 拼装 Transformer 语言模型** (预计 7 天)
	- [ ] 实现 Positional Encoding（位置编码）与 Layer Normalization
	- [ ] 编写类似 GPT 的字符级文本生成器（Character-level Language Model）

### 🔗 实验物资与参考
- **云端实验工作区：** [Google Colab Dashboard](https://colab.research.google.com/)（白嫖 T4） | 备选 [Kaggle Notebooks（每周 30h GPU）](https://www.kaggle.com/code)
- **原始论文：** [Attention Is All You Need (Vaswani et al., 2017)](https://arxiv.org/abs/1706.03762)
- **顶流图解：**
	- [The Illustrated Transformer](https://jalammar.github.io/illustrated-transformer/)（建立直观空间想象，必读）
	- [The Annotated Transformer（论文逐行配 PyTorch 代码）](https://nlp.seas.harvard.edu/annotated-transformer/)
- **保姆级源码视频：**
	- [Andrej Karpathy - Let's build GPT: from scratch](https://www.youtube.com/watch?v=kCc8FmEb1nY)（经典神作，建议反复逐帧观看）
	- [Karpathy - nanoGPT 代码仓库](https://github.com/karpathy/nanoGPT)
- **张量维度神器：** [einops 官方文档与教程](https://einops.rocks/)
- **进阶可视化：** [Transformer Explainer（交互式可视化）](https://poloclub.github.io/transformer-explainer/)
- **每日笔记索引：** [[阶段三每日实验复盘]]

---

## 🎯 阶段四：拥抱大模型与应用生态 —— LLM 微调与部署
- **核心工具：** `transformers`, `peft` (LoRA), `vLLM` / `llama.cpp`
- **开发环境：** Google Colab (微调训练) + 本地 Ubuntu (量化与推理加速)

### 📅 计划安排与 Checklist
- [ ] **Step 1: 玩转 Hugging Face 社区生态** (预计 4 天)
	- [ ] 掌握 Tokenizer（分词器）的底层机理与编解码流程
	- [ ] 成功在本地/Colab 跑通千亿/百亿级小模型（如 Qwen-1.5B）的推理
- [ ] **Step 2: 实战大模型高效微调 (LoRA/PEFT)** (预计 8 天)
	- [ ] 准备一份特定领域的问答（QA）数据集
	- [ ] 冻结大模型基座，插入 LoRA 层，在 Colab 上完成高效参数微调（SFT）
- [ ] **Step 3: 极致优化与底层部署** (预计 5 天)
	- [ ] 探索模型量化技术（INT8/INT4），使用 `llama.cpp` 或 `vLLM` 压榨系统 I/O
	- [ ] 封装标准的 OpenAI 兼容 API 接口，为其对接前端应用

### 🔗 实验物资与参考
- **官方实战课：**
	- [Hugging Face LLM Course（原 NLP Course，已更新 LLM 内容）](https://huggingface.co/learn/llm-course)
	- [transformers 库快速上手](https://huggingface.co/docs/transformers/quicktour)
- **高效微调（LoRA / PEFT）：**
	- [PEFT 官方文档](https://huggingface.co/docs/peft) | [LoRA 原论文](https://arxiv.org/abs/2106.09685)
	- [unsloth（单卡高速微调，含 Colab 模板）](https://github.com/unslothai/unsloth)
	- [TRL - SFT/DPO 微调库](https://huggingface.co/docs/trl)
- **量化与本地部署：**
	- [GitHub - bitsandbytes（4/8-bit 量化）](https://github.com/bitsandbytes-foundation/bitsandbytes)
	- [llama.cpp（GGUF 量化与 CPU/边缘推理）](https://github.com/ggml-org/llama.cpp)
	- [vLLM（高吞吐推理 + OpenAI 兼容 API）](https://docs.vllm.ai/)
	- [Ollama（一键本地跑开源模型）](https://ollama.com/)
- **可选小模型：** [Qwen2.5 系列](https://huggingface.co/Qwen) | [Llama 3.x](https://huggingface.co/meta-llama)
- **每日笔记索引：** [[阶段四每日实验复盘]]

---

## 🌐 通用学习资源速查（跨阶段常翻）

### 课程 / 教材
- [《动手学深度学习》(D2L) - 李沐（中文，PyTorch 版）](https://zh.d2l.ai/)
- [斯坦福 CS231n - 视觉识别中的卷积网络](https://cs231n.github.io/)
- [吴恩达 Deep Learning Specialization（Coursera）](https://www.coursera.org/specializations/deep-learning)
- [fast.ai - Practical Deep Learning for Coders](https://course.fast.ai/)
- [神经网络与深度学习（Michael Nielsen，免费电子书）](http://neuralnetworksanddeeplearning.com/)

### 直觉 / 可视化
- [3Blue1Brown 神经网络系列](https://www.youtube.com/playlist?list=PLZHQObOWTQDNU6R1_67000Dx_ZCJB-3pi)
- [CNN Explainer（交互式卷积可视化）](https://poloclub.github.io/cnn-explainer/)
- [TensorFlow Playground（浏览器里调神经网络）](https://playground.tensorflow.org/)

### 工具 / 社区
- [Hugging Face（模型/数据集/课程）](https://huggingface.co/)
- [Papers With Code（论文配代码与榜单）](https://paperswithcode.com/)
- [arXiv Sanity / arXiv cs.LG](https://arxiv.org/list/cs.LG/recent)
- [Weights & Biases（实验追踪与可视化）](https://wandb.ai/)

### 中文社区与博客
- [李宏毅机器学习课程（B 站）](https://www.bilibili.com/video/BV1Wv411h7kN)
- [知乎「深度学习」话题](https://www.zhihu.com/topic/19813032)

---

## 📝 每日复盘黄金模板 (建议每次新建复盘笔记时引用)
```markdown
### 📆 学习日期：2026-0X-0X
- [ ] **今日核心实验项：** - [ ] **核心代码片段 (Tensor 维度控制)：**
- [ ] **踩坑记录与 Debug 灵感：** - [ ] **沉淀到 Obsidian 知识库的概念：** ```