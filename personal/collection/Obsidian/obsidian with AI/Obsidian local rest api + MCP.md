# 核心思路
Obsidian 的 Vault 是本地文件夹，但其内部机制（模版、backlinks、metadataCache 等）只有通过 **Obsidian 自身 API** 才能安全调用。  
Local REST API 插件的作用，就是把这些内部 API 暴露为 HTTP 接口，从而可以被 **MCP 客户端**（如 Claude Desktop、Cursor、n8n）调用。  
这样一来，AI 工具不仅能“改文件”，还能“触发 Obsidian 本身的机制”。

---

# 必备工具
| 工具 | 用途 |
|------|------|
| **Obsidian + Local REST API 插件** | 在本地开启 HTTP 接口，暴露 Vault 操作能力 |
| **MCP 客户端**（Claude Desktop / Cursor） | 通过 MCP 协议，把 REST API 封装为 LLM 可调用的工具 |
| **n8n**（可选） | 用于可视化编排，把 MCP 的调用与其他自动化流程结合 |
| **API Key / 权限配置** | Local REST API 支持设置 token，保证访问安全 |

---
# 使用步骤

## 1. 安装 Local REST API 插件
1. 打开 Obsidian 设置 → 社区插件 → 搜索 `Local REST API`  
2. 安装并启用插件  
3. 在插件设置中配置：  
   - 监听端口（默认 27123）  
   - API Key（建议设置，避免无权限访问）

## 2. 确认 API 可用
在浏览器或 curl 中测试：
```bash
curl -H "Authorization: Bearer <API_KEY>" http://localhost:27123/vault
```
返回内容即表示 API 可用。

## 3. 在 MCP 客户端中配置

以 **Claude Desktop** 为例：

1. 在 MCP 配置文件中新增一个 **REST 工具**，指向 Obsidian Local REST API
    
2. 定义常用 endpoints，如：
    - `/vault` → 获取文件列表
    - `/file/{path}` → 读写文件
    - `/command` → 调用 Obsidian 命令（如执行模版）

配置完成后，Claude 就能直接通过自然语言调用 Obsidian 功能。

---

# 典型示例：通过 MCP 调用模版自动创建笔记

## 场景

我想让 AI 生成一个新的日记笔记，并套用 Obsidian 的“每日笔记模版”，而不是 AI 自己生拼文件格式。

## 操作流程

1. AI 向 MCP 发出请求：
    > “在 Obsidian 中创建今天的日记，并使用 `Daily Note Template` 模版”
2. MCP 客户端将请求转为 REST API 调用：
    - 调用 `/command` 接口
    - 执行 Obsidian 插件命令：`templater-obsidian:Create new note from template`
3. Obsidian 内部触发模版插件：
    - 在指定文件夹下创建新笔记
    - 插入模版内容（如日期、预定义结构）
4. AI 再次调用 `/file/{path}`，在生成的笔记中填充额外内容（例如当天的待办或总结）。

---
# 优势对比

|方法|直接改文件|通过 Local REST API + MCP|
|---|---|---|
|创建文件|自己写文件结构|调用 Obsidian 内部命令|
|模版支持|手工插入模版内容|自动触发模版插件|
|插件联动|需要手写逻辑|直接复用 Obsidian 插件生态|
|一致性|可能破坏 metadata 或索引|内部保证一致性|

---


# 总结

- **Local REST API 插件** 是连接“文件操作”和“Obsidian 内部生态”的桥梁
    
- **MCP 客户端** 让 AI 能自然语言调用这些 API，获得远超直接改文件的能力
    
- **典型用法**：调用模版、命令、批量管理笔记，而不是单纯读写文件
    

这使得 Obsidian 既保留了“本地自由”，又能在需要时享受到“受控自动化”的优势。