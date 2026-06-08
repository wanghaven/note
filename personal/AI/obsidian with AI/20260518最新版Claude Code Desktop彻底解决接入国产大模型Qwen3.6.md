---
title: "20260518最新版Claude Code Desktop彻底解决接入国产大模型Qwen3.6"
source: "https://blog.csdn.net/gaoguosheng/article/details/161228206"
published: 2026-05-19
created: 2026-06-08
description: "文章浏览阅读1.2k次，点赞13次，收藏11次。《ClaudeCodeDesktop最新版接入第三方大模型教程》摘要：针对ClaudeCodeDesktop V1.7196.0版本禁用第三方模型的问题，本文提供CCSwitch网关+开发者模式的解决方案。通过四步实现：1)开启开发者模式；2)CCSwitch配置模型网关（支持通义、DeepSeek等主流模型）；3)绑定本地网关地址；4)实测验证。该方法无需官方订阅，保留原生功能，解决访问限制，支持多模型切换。文中包含详细配置步骤和常见错误排查指南，帮助用户低成本实现大模型自由。（149字）"
---

文章标签：

[#ai](https://so.csdn.net/so/search/s.do?q=ai&t=all&o=vip&s=&l=&f=&viparticle=&from_tracking_code=tag_word&from_code=app_blog_art) [#人工智能](https://so.csdn.net/so/search/s.do?q=%E4%BA%BA%E5%B7%A5%E6%99%BA%E8%83%BD&t=all&o=vip&s=&l=&f=&viparticle=&from_tracking_code=tag_word&from_code=app_blog_art)


![图片](https://i-blog.csdnimg.cn/img_convert/af4313b691f2e72bce6ab6f10d8c0288.png)

上篇我们讲到Claude Code Desktop开发者模式Developer Mode+CC Switch ，无需登录官方账号，就能一键接入DeepSeek、Qwen3.6 等第三方国产大模型！可是这才没过多久，今天更新的 Claude Code DesktopV1.7196.0版本后，如下图：

![图片](https://i-blog.csdnimg.cn/img_convert/515603cfb9a4e9aafb69d9a703244e43.png)

发现又又不能使用第三方大 模型 ，无法下拉第三方模型，会出现如下报错：

![图片](https://i-blog.csdnimg.cn/img_convert/1fe68ef0a7cd43cba794506ba6e35d43.png)

晚上研究了下结合实测踩坑经验，手把手教你通过CC Switch 网关+ Claude Code Desktop配置技巧完成配置，全程图形化操作，小白也能轻松上手～

## 一、为什么要接入第三方大模型？

告别订阅束缚：无需开通 Claude 官方 Pro/Max 订阅，按 token 计费，成本更低；

模型自由选择：支持通义、DeepSeek、智谱等几十款主流大模型，覆盖代码生成、文案创作、多模态等场景；

规避网络限制：通过国内网关直连，解决官方接口访问慢、不稳定问题；

兼容原生体验：保留 Claude Code 桌面版全部功能，无缝切换第三方模型。

## 二、准备工作：安装必备工具

### 1\. 升级 Claude Code Desktop 到最新版

官网地址：https://claude.com/download

安装后自动检测更新，确保为最新版。

### 2\. 安装 CC Switch（模型网关工具）

CC Switch 是开源免费的模型管理工具，支持将第三方模型接口转换为 Claude 兼容协议，一键配置、无缝切换。

下载地址：https://github.com/farion1231/cc-switch

![图片](https://i-blog.csdnimg.cn/img_convert/2fd6abbe67fef9d0e24e752805c8a7a3.png)

## 三、第一步：开启 Claude Code 开发者模式

这是接入第三方模型的核心前提，开启后才能配置网关接口，上一篇已经介绍过了，在此就不再赘述了。

打开 Claude Code Desktop，点击顶部 菜单栏 HELP → Troubleshooting → Enable Developer Mode；

![image](https://i-blog.csdnimg.cn/img_convert/a3348177a0f7c11483193e9cf5d6b8de.png)

弹窗提示「Developer mode allows access to third-party models」，点击Enable，应用自动重启；

![image](https://i-blog.csdnimg.cn/img_convert/a09369c77c63198b28fea350e90fadc3.png)

重启后，菜单栏新增Developer选项，说明开启成功。

![image](https://i-blog.csdnimg.cn/img_convert/cdd36d442a3e17442d6d40708f3c3a29.png)

## 四、第二步：CC Switch 配置第三方模型（以通义 Qwen3.6 为例）

### 1\. 切换到 Claude 模式

打开 CC-Switch，顶部标签栏默认显示「Claude Code」，确认处于Claude 模式（Codex 模式用于 VS Code  Copilot，本文暂不涉及）。

![图片](https://i-blog.csdnimg.cn/img_convert/7cd3b16c6862790b4e8966c0ba2f2155.png)

### 2\. 添加第三方模型供应商

点击右上角+ Add Provider，选择「Custom」（自定义）或预设模板（如通义、DeepSeek）；

![图片](https://i-blog.csdnimg.cn/img_convert/e81d157c1b9eec56f11fbe039270812f.png)

填写核心配置（以通义百炼 Qwen3.6- plus 为例）：

![图片](https://i-blog.csdnimg.cn/img_convert/22492344bf7f019422dbc79ec801c3b1.png)

### 3\. 配置模型映射（关键避坑点）

![图片](https://i-blog.csdnimg.cn/img_convert/b8d86d69f50b102ca6028372acdfc562.png)

### 4\. 启动本地路由网关

![图片](https://i-blog.csdnimg.cn/img_convert/acf8c4704434201470b508c8779e595f.png)

### 

### 5\. 验证 CC-Switch 网关是否正常

终端执行测试命令，检查网关是否能正常转发请求：

```cobol
curl http://127.0.0.1:15721/v1/messages \
```

返回模型回复（如「你好！测试成功，我一切正常」），说明网关配置正常。

![图片](https://i-blog.csdnimg.cn/img_convert/d416bee90ca9a08233753ce059e3c07b.png)

## 五、第三步：Claude Code 绑定 CC-Switch 网关

### 1\. 进入第三方推理配置页面

打开 Claude Code Desktop，点击顶部菜单栏Developer → Configure Third-Party Inference；

![图片](https://i-blog.csdnimg.cn/img_convert/182251a3a5cf1255bade38a6b158766b.png)

选择Gateway（Anthropic-compatible）模式（适配 CC-Switch 网关）。

### 2\. 填写网关信息（直接复制）

按以下要求填写，确保和 CC-Switch 配置一致：

![图片](https://i-blog.csdnimg.cn/img_convert/952a5bfef5db85f88d0d16aef0f2748e.png)

Gateway base URL：http://127.0.0.1:15721（CC-Switch 本地地址，不要加 /v1）；

API Key：任意填写（如test-key，真实密钥已存在 CC-Switch）；

Auth Scheme：选择Bearer；

Model List：新版界面不一样了，手动添加映模型，参考如下。

![图片](https://i-blog.csdnimg.cn/img_convert/a61bbd2001c86ccd7a4c3b163c225655.png)

### 3\. 应用配置并重启

点击右下角Apply Local，保存配置；

![图片](https://i-blog.csdnimg.cn/img_convert/d40dfa94798f955690d94e25eb76d668.png)

完全关闭 Claude Code，重新打开，配置生效。

## 六、第四步：实测使用第三方模型

重启后，Claude Code 右下角模型选择框，选择配置好的qwen3.6-plus；

![图片](https://i-blog.csdnimg.cn/img_convert/e33cd682c4ba3236a06f44f1a7d70e99.png)

图片输入也正常，速度挺快！

![图片](https://i-blog.csdnimg.cn/img_convert/08673e8f54e4cc018e7922936f2f15f8.png)

好了，复活了，可以愉快地继续干活了！！！

## 七、常见问题避坑指南

### 1\. 报错「Configured model not available（HTTP 404）」

原因：模型名不匹配、路径重复或网关未启用；

解决：

- 确认 Claude 端模型名和 CC-Switch「Model Mapping」Key 完全一致；
- Gateway base URL 填 `http://127.0.0.1:15721`，**不要加 /v1**；
- 检查 CC-Switch 供应商是否已「Enable」，状态为「Active」。

### 2\. 开启开发者模式后无 Developer 菜单

原因：版本过低或缓存异常；

解决：升级到最新版，彻底关闭 Claude Code 后重新开启，或重启电脑。

### 3\. 网关测试正常，Claude 端无响应

原因：端口占用或防火墙拦截；

解决：关闭占用 15721 端口的程序，放行 CC-Switch 和 Claude Code 的网络权限。

### 4\. 支持哪些第三方模型？

主流推荐：

通义：Qwen3.6-plus、 Qwen \-turbo；

DeepSeek：DeepSeek-V4、DeepSeek-Coder；

智谱：GLM-4、GLM-3-Turbo；

开源模型：Llama 3、Mistral（需本地部署兼容接口）。

## 八、总结

通过Claude Code 开发者模式 + CC Switch 网关，5 分钟即可低成本接入第三方大模型，既保留原生操作体验，又实现模型自由、成本可控。无需复杂代码，全程图形化配置，无论是个人使用还是团队协作，都能轻松落地。

现在升级到 Claude Code 最新版的小伙伴也不用怕了，按本文步骤配置，告别官方订阅限制，解锁更多大模型玩法吧