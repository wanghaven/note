
**核心流程**：LM Studio 负责在本地运行模型并创建一个API 服务器，Obsidian Copilot 插件向本地大模型API发送请求。

---

## 步骤一：配置本地服务器 (LM Studio)

首先，我们需要在 LM Studio 中下载并运行模型。

1.  **下载并安装**：前往 [LM Studio 官网](https://lmstudio.ai/) 下载并安装对应您操作系统的软件。

2.  **搜索并下载模型**：
    *   打开 LM Studio，点击左侧的放大镜图标 `(Search)`。
    *   在搜索框中输入推荐的模型，例如 `qwen3-8b-instruct-gguf`。
    *   在右侧的结果列表中，选择一个 `GGUF` 格式的文件下载。推荐选择带有 `Q4_K_M` 或 `Q5_K_M` 标识的版本，这是性能和文件大小的良好平衡点。

3.  **加载模型并启动服务**：
    *   点击左侧的开发者图标 。
    *   在顶部选择您刚刚下载的模型。
    *   模型加载完成后，点击 `Start Server` 按钮。
    *   启动成功后，您会看到服务器日志，底部会显示服务正在 `http://localhost:1234/v1` 地址上运行。
    * 在Settings里，打开`启用CORS`开关

> **注意**：在进行下一步之前，请**务必保持 LM Studio 运行**且服务器已启动。

---

## 步骤二：配置 Obsidian Copilot 插件

现在，我们设置 Obsidian 的 Copilot 插件，使其连接到 LM Studio 提供的本地服务。

1.  **安装插件**：在 Obsidian 的第三方插件市场中搜索并安装 `Copilot`。

2.  **配置插件设置**：
    *   进入 `设置` -> `第三方插件` -> `Copilot`。
    *   点击Model，在列表下方点击`Add Custom Model`
    *   随后会出现新的配置项，请按下表进行填写：

| 设置项 | 填写内容 | 说明 |
| :--- | :--- | :--- |
| **API Endpoint** | `http://localhost:1234/v1/chat/completions` | **必须完全一致**，指向 LM Studio 服务的具体路径。 |
| **API Key** | (留空) | 本地服务不需要密钥，可留空。 |
| **Model Name** | 与模型名一致，Qwen-3-8b-instruct | 可留空，插件会自动使用 LM Studio 加载的模型。 |

3.  **保存并测试**：
    *   点击Verify，成功后点击Add Model。
    *   回到Basic界面，把Default chat model更换为刚才添加的model。
    *   打开 Obsidian 的 Copilot 聊天窗口。
    *   发送一条消息，如“你好”。
    *   如果一切正常，您会收到来自本地模型的回复。同时，您可以在 LM Studio 的服务器日志中看到请求和处理过程。

---

## 故障排查 (Troubleshooting)

如果无法收到回复，请检查：

-   **LM Studio 服务器是否已启动？**
-   **模型是否已在 LM Studio 中成功加载？**
-   **Obsidian Copilot 中的 `API Endpoint` 地址是否填写完全正确？** (这是最常见的错误)
-   您的电脑性能是否足够支持运行该模型？

至此，您已成功搭建起一套完全私有的个人知识库 AI 助理。