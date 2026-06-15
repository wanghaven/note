---
title: learn-claude-code-agent-harness
date: 2026-06-12
tags: [AI-Agent, Agent-Harness, claude-code, Architecture]
status: in-progress
aliases: [Agent Harness 学习记录, learn-claude-code]
---

# Agent Harness 基础架构（s01-s06）

## Related

- [[learn-claude-code]]
- [[AI Agent]]
- [[Agent Harness]]

## Learning Goal

理解一个 Coding Agent Harness 如何从最小执行闭环，逐步演进出工具系统、权限边界、扩展点、显式计划能力和子 Agent 上下文隔离。

重点不是记住每行代码，而是掌握一个核心判断：**主循环保持稳定，新增能力通过分层机制接入。**

## Progress

| 章节 | 主题                 | 状态   | 架构增量                   |
| ---- | -------------------- | ------ | -------------------------- |
| s01  | Agent Loop           | 完成   | LLM 与工具结果回灌形成闭环 |
| s02  | Tool Use             | 完成   | 工具注册与分发             |
| s03  | Permission           | 完成   | 工具执行前的安全闸门       |
| s04  | Hooks                | 完成   | 生命周期扩展点             |
| s05  | TodoWrite / Plan     | 完成   | 显式任务计划与 reminder    |
| s06  | Subagent             | 完成   | 独立 messages[] 与任务委派 |
| s07+ | Skill Loading 及以后 | 待学习 | 按需加载上下文知识         |

## Plan

- [x] s01：理解最小 Agent Loop
- [x] s02：理解工具分发机制
- [x] s03：理解权限检查为什么必须在执行路径上
- [x] s04：理解 hook 如何避免主循环膨胀
- [x] s05：理解计划如何从模型记忆外化为结构化状态
- [x] s06：理解 Subagent 如何解决大任务上下文污染
- [ ] s07：理解 Skill Loading 如何按需注入知识

## Problem Statement

LLM 本身只能生成文本，不能稳定地“执行 -> 观察 -> 再执行”。Agent Harness 要解决的是运行时问题：把模型决策、工具执行、结果反馈和下一轮推理串起来。

随着功能增加，系统会遇到四类工程压力：

- 能力扩展：只有 `bash` 太粗糙，需要专用工具。
- 安全控制：工具能改文件、跑命令，就必须在执行前做权限判断。
- 可维护性：日志、权限、通知等逻辑不能都塞进 `agent_loop`。
- 任务稳定性：多步任务不能只靠模型记忆，需要显式计划状态。
- 上下文污染：大任务中的探索过程会占满主对话，需要把中间推理隔离出去。

## Core Design

Agent Harness 的核心不是一条直线，而是一个围绕 `messages` 反复推进的控制循环。`messages` 是唯一贯穿始终的状态容器：用户输入、assistant 的 `tool_use`、工具执行结果都会被追加进去，然后再次发送给 LLM。

```text
messages -> LLM -> assistant message -> tool execution -> tool_result user message -> messages -> LLM
```

s01 到 s06 的演进是在这个循环的固定位置插入机制，而不是推翻循环：

```text
Agent Loop -> Tool System -> Permission Gate -> Hook System -> Planning State -> Subagent Context Isolation
```

核心原则：**loop 负责维护消息闭环和工具调度；工具、权限、hook、plan、subagent 都是在循环的明确插入点上扩展。**

## Chapter Diagrams

s01-s05 已改为优先嵌入 SVG，draw.io 源文件作为可编辑源保留。特别注意：`stop_reason` 判断属于 Harness 控制逻辑，不属于 LLM 内部逻辑，所以图中单独画成 Harness decision 节点。

### s01 Agent Loop

![[diagrams/s01-agent-loop.svg]]

![[diagrams/s01-agent-loop-sequence.svg]]

### s02 Tool Use

![[diagrams/s02-tool-dispatch.svg]]

![[diagrams/s02-tool-dispatch-sequence.svg]]

### s03 Permission

![[diagrams/s03-permission.svg]]

![[diagrams/s03-permission-sequence.svg]]

### s04 Hooks

![[diagrams/s04-hooks.svg]]
![[s04-hooks-sequence.svg]]
### s05 TodoWrite

![[diagrams/s05-todowrite.svg]]
![[s05-todowrite-sequence.svg]]
### s06 Subagent

![[diagrams/s06-subagent.svg]]
![[diagrams/s06-subagent-sequence.svg]]

## Design Evolution

| 阶段 | 核心变化                           | 设计意义                   |
| ---- | ---------------------------------- | -------------------------- |
| s01  | `while True` + `tool_result`       | 让模型具备连续行动能力     |
| s02  | `TOOLS` + `TOOL_HANDLERS`          | 把能力做成可注册工具       |
| s03  | `check_permission()`               | 安全控制进入执行路径       |
| s04  | `HOOKS` + `trigger_hooks()`        | 横切逻辑从 loop 中移出     |
| s05  | `todo_write` + `rounds_since_todo` | 计划从隐式记忆变成显式状态 |
| s06  | `task` + `spawn_subagent()`        | 大任务拆分到独立上下文     |

## Chapter Notes

### s01 Agent Loop

最小 Agent Harness 的本质是循环：模型要用工具就执行工具，并把结果作为新消息喂回模型；模型不再用工具就停止。

这里的关键不是 `bash`，而是 **tool result feedback loop**。Harness 承担“连接真实世界”的职责，模型承担“决定下一步”的职责。

### s02 Tool Use

s02 把工具执行从硬编码 `run_bash()` 改成分发表：

```python
handler = TOOL_HANDLERS.get(block.name)
output = handler(**block.input)
```

这形成了一个重要 contract：模型返回的 `name` 必须能映射到 handler，`input` 的字段必须匹配 handler 参数。

调试 `read_file` 时已经验证了这一点：`input.path` 不需要先取文件名，而是通过 `handler(**block.input)` 直接传给 `run_read(path=...)`。

### s03 Permission

s03 的重点是：安全必须在工具执行前发生。

prompt 可以提示模型不要做危险事，但真正可靠的控制点在 Harness：执行 handler 之前先经过 deny list、规则匹配和用户审批。

### s04 Hooks

s04 把权限检查、日志等逻辑挂到 hook 上，而不是继续写进 `agent_loop`。

这一步的架构意义很大：主循环变成稳定内核，hook 成为扩展入口。后续新增日志、审批、统计、清理动作时，不需要继续改 loop 主干。

### s05 TodoWrite / Plan

s05 新增的 `todo_write` 不是执行工具，而是 planning tool。它维护 `CURRENT_TODOS`，让任务计划从模型内部记忆变成可观察的外部状态。

`rounds_since_todo` 是一个简单监督机制：连续几轮没有更新 todo，就注入 `<reminder>Update your todos.</reminder>`。

实践中看到：即使 SYSTEM prompt 要求“先计划”，模型仍可能先调用 `read_file` / `glob`。这说明 prompt guidance 不等于 runtime enforcement，reminder 这种运行时机制更接近工程控制。

另一个实践点是路径问题：从 `workspace` 启动时，`WORKDIR = Path.cwd()` 会导致相对路径解析到 `workspace` 下。这个问题不属于 tool dispatch，而属于运行时工作目录选择。

### s06 Subagent

s06 新增 `task` 工具，父 Agent 通过普通 tool dispatch 调用 `spawn_subagent(description)`。这说明 Subagent 不是主循环外的特殊通道，而是工具系统的自然扩展。

子 Agent 的关键设计是 **fresh messages[]**：

```python
messages = [{"role": "user", "content": description}]
```

它用自己的 `SUB_SYSTEM` 和自己的 while loop 完成子任务。结束后只通过 `extract_text()` 把最后的文本摘要返回给父 Agent，中间的 `messages` 全部丢弃。

这带来一个重要边界：**上下文隔离，不是副作用隔离。** 子 Agent 的中间推理不会污染父上下文，但它通过 `bash/read/write/edit/glob` 对工作目录造成的文件系统副作用会保留。

s06 还做了三个保护性取舍：

- 子 Agent 的 `SUB_TOOLS` 不包含 `task`，防止递归 spawn。
- 子 Agent 最多跑 30 轮，避免无限循环。
- 子 Agent 工具调用仍走 `PreToolUse` / `PostToolUse` hook，权限策略不会因为委派而失效。

对应图示可从两个角度看：

- Architecture：主 Agent 负责编排与结果回灌，Subagent 负责独立子任务循环，中间上下文不回灌父上下文。
- Sequence：`task(description)` 先触发 `spawn_subagent`，子循环完成工具调用与 hook 检查后只返回 summary text 给父 Agent，父 Agent 继续主循环。

## Reusable Pattern

### Pattern

Stable Core Loop + Layered Capabilities

### Context

适用于需要让 LLM 调用工具、访问文件系统、执行命令，并持续推进任务的 Agent 系统。

### Problem

如果把工具、权限、日志、计划全部写进主循环，Agent 会很快变成难以维护的脚本。

### Solution

保留一个最小 loop，把能力拆成层：

- Tool System: 扩展模型能做什么
- Permission Gate: 决定哪些操作能执行
- Hook System: 注入横切逻辑
- Planning State: 管理多步任务进度
- Subagent: 隔离探索过程，只把结论交还主上下文

### Tradeoffs

- 教学版简单直观，但全局状态如 `CURRENT_TODOS` 无持久化。
- `rounds_since_todo >= 3` 是启发式规则，不是严格计划系统。
- `Path.cwd()` 适合 demo，但真实项目应明确 workspace root。
- hook 返回值在教学版中较简单，生产系统需要结构化结果。
- s06 的 Subagent 是同步等待模型，适合理解上下文隔离；生产系统通常还需要 async、取消传播、权限冒泡和缓存优化。

## Production Perspective

Claude Code / Cursor / OpenAI Agents SDK 的生产实现会更复杂，但方向一致：

- loop 仍是核心，只是增加更多恢复路径和中断处理。
- tool 不只是函数，而是 schema、validation、permission、execution 的组合。
- hook 不止几个事件，而是覆盖 session、permission、compact、subagent 等生命周期。
- TodoWrite 适合轻量任务；更大的任务需要持久化 Task System、依赖图和上下文隔离。
- Claude Code 的真实 Subagent 不只有 fresh messages[]，还存在 fork/prompt-cache 友好的路径；教学版刻意省略这些优化，先突出“中间上下文不回灌父 Agent”的核心思想。

## Architecture Impact

| Dimension       | Impact                                                                                               |
| --------------- | ---------------------------------------------------------------------------------------------------- |
| Extensibility   | 工具和 hook 让能力可以注册进入系统。                                                                 |
| Maintainability | 主循环保持小，横切逻辑外移。                                                                         |
| Safety          | 权限检查位于执行前，而不是依赖模型自觉。                                                             |
| Observability   | tool log、debug JSON、todo state 可以还原执行过程。                                                  |
| Scalability     | s06 通过子 Agent 隔离中间探索过程，但仍是同步单机模型，后续需要 async/task system 才能支撑更大规模。 |

## Key Insights

本阶段最核心的收获是：Agent 能否稳定完成任务，主要取决于 Harness 的运行时架构，而不是 prompt 技巧。s01-s06 的演进证明了一个可复用模式：保持主 loop 稳定，把工具、权限、hooks、plan、subagent 作为分层机制逐步接入。这样既能持续扩展能力，也能维持安全边界和可维护性；其中 subagent 重点解决上下文污染问题，权限控制仍必须统一落在工具执行路径上。

## One Sentence Summary

s01-s06 展示了一个 Agent Harness 如何从最小执行闭环演进为具备工具分发、权限控制、hook 扩展、显式计划状态和子 Agent 上下文隔离的分层运行时。