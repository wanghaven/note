
# 教程：在 Obsidian 中集成 Open WebUI 作为 AI 聊天中心

## 目标

如何通过 Docker 在本地运行 **Open WebUI**，并使用 **Custom Frames** 插件将其无缝嵌入到 Obsidian 的侧边栏中。最终目标是在 Obsidian 内部创建一个功能强大、可连接多种 AI 模型（云端 API 或本地 LLM）的统一聊天界面，从而极大地提升工作效率，减少应用切换。

## 前提条件

1.  **[Obsidian](https://obsidian.md/)**：已安装并正常运行。
2.  **[Docker Desktop](https://www.docker.com/products/docker-desktop/)**：已在您的电脑上安装并成功启动。这是运行 Open WebUI 最简单、最可靠的方式。

---

## 流程步骤

### 第一步：安装并运行 Open WebUI

首先，我们需要让 Open WebUI 服务在您的电脑后台运行起来。

1.  **打开终端**：
    *   **Windows**: 打开 `PowerShell` 或 `CMD`。
    *   **macOS/Linux**: 打开 `Terminal`。

2.  **运行 Docker 命令**：
    复制以下整段命令，粘贴到终端中并按回车。此命令会自动下载 Open WebUI 镜像并以最佳配置启动它。

    ```bash
    docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
    ```

    > [!NOTE] 命令参数解释
    > - `-d`: 在后台运行容器。
    > - `-p 3000:8080`: 将你电脑的 `3000` 端口映射到容器的 `8080` 端口。
    > - `-v open-webui:/app/backend/data`: 将容器的数据（设置、聊天记录等）持久化保存在本地，防止丢失。
    > - `--name open-webui`: 为容器命名，方便管理。
    > - `--restart always`: 电脑重启后，Docker 会自动启动此容器。

3.  **验证运行状态**：
    *   等待 2-5 分钟，让容器完成首次初始化。
    *   在浏览器中访问 `http://localhost:3000`。
    *   如果看到 Open WebUI 的欢迎界面，请根据提示创建您的第一个管理员账户。

### 第二步：在 Obsidian 中配置 Custom Frames 插件

接下来，我们将把 Open WebUI 的界面“搬”进 Obsidian。

1.  **安装插件**：
    *   在 Obsidian 中，进入 `设置` > `社区插件`。
    *   关闭 `安全模式`，然后点击 `浏览`。
    *   搜索 `Custom Frames`，点击 `安装` 并 `启用`。

2.  **创建 WebUI 框架**：
    *   进入 `设置` > `Custom Frames`。
    *   点击 `Add Frame` 并填写以下信息：
        *   **Frame Name**: `AI Chat` (或任何你喜欢的名字)
        *   **Icon**: 选择一个易于识别的图标（如对话气泡）。
        *   **URL**: `http://localhost:3000`
        *   **Open in**: 推荐选择 `Sidebar`，这会将其固定在右侧边栏。

3.  **打开窗格**：
    *   按下 `Ctrl+P` (或 `Cmd+P`) 打开命令面板。
    *   输入 `AI Chat`，选择 `Custom Frames: Open AI Chat`。
    *   现在，您的 Open WebUI 界面应该已经出现在 Obsidian 的侧边栏了。

### 第三步：在 Open WebUI 中连接 AI 模型

最后一步是让你的 Open WebUI 真正拥有一个“大脑”。

1.  **进入 Open WebUI 设置**：
    *   在 Obsidian 内的 Open WebUI 窗格中，点击左下角的设置图标，进入 `设置`。

2.  **连接模型**：
    *   点击左侧的 `外部连接` 菜单。
    *   **连接云端 API** (如 OpenAI, Gemini, Claude):
        *   找到对应的服务商（如 `OpenAI API`）。
        *   打开开关，将您的 **API 密钥** 粘贴进去。
        *   在 `模型` 区域添加您想用的模型名称 (如 `gpt-4o`)。
        *   点击 `保存`。
    *   **连接本地模型** (如 LM Studio, Ollama):
        *   找到对应的服务商（如 `Ollama API`）。
        *   打开开关，确保 **API 地址** 指向您的本地服务器 (默认的 `http://host.docker.internal:11434` 通常适用于 Ollama)。
        *   点击 `保存`。

3.  **开始使用**：
    *   回到 Open WebUI 聊天主界面，从模型下拉列表中选择您刚刚配置好的模型，即可开始对话。

> [!SUCCESS] 完成！
> 您现在拥有一个完全集成在 Obsidian 内部的、功能强大的 AI 聊天工作站。您可以随时在不同的云端和本地模型之间切换，享受无缝的工作体验。

---

## 常见问题与故障排除

> [!bug] 问题：访问 `localhost:3000` 时浏览器报错 `ERR_EMPTY_RESPONSE` 或显示空白页面。
> **原因**: 这是最常见的问题。通常是因为 Open WebUI 容器在**首次启动时需要几分钟时间进行初始化**，而此时 Web 服务尚未就绪。
> **解决方案**:
> 1. **耐心等待**：在第一次运行 Docker 命令后，请耐心等待 3-5 分钟。
> 2. **强制刷新**：在浏览器中按下 `Ctrl+F5` (或 `Cmd+Shift+R`) 来清除缓存并强制重新加载页面。
> 3. **重启容器**：如果等待后仍无效，请在 Docker Desktop 中找到 `open-webui` 容器，点击 `Stop` 按钮，然后再点击 `Start` 按钮。