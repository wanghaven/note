---
name: note-summary-drawio
description: Use when creating or updating learn-claude-code summary architecture drawio diagrams (s01+), especially incremental chapter evolution from previous chapter diagrams.
---

# Skill: Learn-Claude-Code Summary Drawio 图规范

## Purpose

用于生成 `learn-claude-code` 的 **summary 架构图**，并保证后续章节按同一视觉与演进逻辑持续扩展。

目标不是“重画新图”，而是“在上一章基础上增量演化”。

---

## Scope

适用于以下类型的图：

- `s01_agent_loop.drawio`
- `s02_tool_use.drawio`
- `s03_Permission.drawio`
- `s04_Hooks.drawio`
- `s05_TodoWrite.drawio`
- `s06_Subagent.drawio`

以及后续 `s07+` 的 summary 架构图。

---

## Core Principle

每章图保持两条主线：

1. **稳定主循环骨架保持不变**
2. **只新增当章机制，并明确标注“Preserved / New”**

不要把图做成全新叙事；要让读者一眼看到“这一章在前一章上加了什么”。

---

## Layout Rules

- **主方向**：左到右（输入 -> 状态 -> LLM -> decision -> 执行 -> 回写）。
- **反馈线**：`tool_result -> messages[]` 用虚线回流。
- **连线风格**：`edgeStyle=orthogonalEdgeStyle`，优先水平/垂直折线，避免斜线与交叉。
- **图层**：先放大容器（如 Parent/Subagent zone），再放主流程节点，最后放局部子模块与 legend。
- **可读性**：节点间距统一，避免文字压线、框重叠。

---

## Visual Style (from s01-s06)

### 1) Base Flow（蓝色）

- 节点：`fillColor=#f0f4ff`, `strokeColor=#1d4ed8`
- 文本：标题深蓝，说明浅蓝
- 用于：`User Query`, `LLM`, 主流程执行块

### 2) Message State（灰色）

- 节点：`fillColor=#f8fafc`, `strokeColor=#475569`
- `messages[]` 统一用虚线边框（`dashPattern=4 2`）

### 3) Decision（浅橙菱形）

- `shape=rhombus`
- `fillColor=#fff8e8`, `strokeColor=#d39b2a`
- 用于：`stop_reason == tool_use?`、todo/limit 等分支判断

### 4) Return（绿色）

- `fillColor=#ecfdf5` 或 `#dcfce7`
- `strokeColor=#15803d`
- 用于：终止或返回结果

### 5) s02+ 增量机制颜色规则

- 从 `s02` 开始，不再固定每类机制的具体颜色值。
- 只要求：**上次改动内容** 与 **本次新增内容** 使用两组明显不同的颜色组合（填充+描边）。
- 同一张图内保持一致：属于“上次改动”的节点统一一组，属于“本次改动”的节点统一另一组。
- 优先保证“可一眼区分演进层次”，而不是坚持某个固定色号。

---

## Mandatory Node Vocabulary

以下核心词汇尽量保持一致（可按章节少量增删）：

- `User Query`
- `messages[]`
- `LLM (content + stop_reason)`
- `stop_reason == "tool_use"?`
- `TOOL_HANDLERS`
- `tool_result append to messages[]`
- `Return Result`

新增能力节点命名优先与代码一致：尽量直接使用代码中的函数名、变量名、工具名（如 `check_permission()`, `trigger_hooks(...)`, `spawn_subagent`, `compact_history`, `TOOL_HANDLERS`）。仅在代码名无法直接用于图标签时，才使用“机制名 + 动作”的表达。

---

## Evolution-by-Chapter Pattern

### s01

- 最小闭环：`messages -> LLM -> decision -> tool -> result -> messages`

### s02

- 保留 s01 闭环
- 新增 `TOOL_HANDLERS` 分发区和 5 工具映射

### s03

- 保留 s02 分发
- 在执行前插入 `check_permission()` 三闸门（deny/rule/approval）

### s04

- 保留 s03 权限逻辑（但语义迁移到 hook）
- 新增 hook 生命周期阶段：`UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `Stop`

### s05

- 保留 s04 hook 分层
- 新增 `todo_write` + `rounds_since_todo` + reminder 注入路径

### s06

- 保留 s05 主流程
- 新增 Parent/Subagent 双区、fresh messages、summary-only return、no recursive task

---

## Legend Rule (Required)

每张 summary 图底部必须包含两条 legend：

- `S0(n-1) Preserved: ...`
- `S0n New: ...`

要求：

- 一条说明继承了什么
- 一条说明新增了什么
- 颜色与对应机制一致（如 preserved 紫/青，new 橙/红等）

---

## Size Control Rule

如果图太大，按以下顺序缩减：

1. 合并重复小节点（如多个工具小块合并成 `base handlers`）
2. 合并文字说明到一个机制块，不逐行拆节点
3. 保留主干路径和分支，不保留次要装饰

不能删掉：

- 主闭环
- 当章新增机制
- Preserved/New legend

---

## File Naming Rule

- 文件名保持章节前缀：`s0X_<topic>.drawio` 或 `s0X-<topic>.drawio`
- `diagram name` 与章节一致（如 `s06_Subagent`）
- 标题统一：`s0X <Topic>`

---

## Generation Workflow

1. 读取上一章 summary 图（作为基底）
2. 读取当前章 `code.py` + `README.md`，抽取“新增机制”
3. 在基底图中新增节点和连线，不重排主骨架
4. 添加/更新 legend（Preserved/New）
5. 自检连线交叉、间距、颜色一致性

---

## Quality Checklist

- [ ] 主循环闭环存在且可追踪
- [ ] 当章新增机制明确可见
- [ ] Preserved/New legend 完整
- [ ] 连线为正交折线，交叉最少
- [ ] 节点无明显重叠，文本不压线
- [ ] 色彩语义与 s01-s06 保持一致
- [ ] 命名使用既有词汇，不引入无关术语

---

## Output Rule

- 图标签保持英文（与现有图一致）
- 说明文本保持英文，但关键机制名保持代码原词
- 需要导出 SVG 时，优先白底与 Obsidian 兼容
