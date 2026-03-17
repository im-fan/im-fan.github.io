---
title: MCP学习文档
date: 2026-03-17
tags:
- VibeCoding,AICoding
categories:
- AI
---


## ClaudeCode
### 安装
```shell
# 国内镜像源
npm config set registry https://registry.npmmirror.com
# 原始链接
npm install -g @anthropic-ai/claude-code
```

### 配置
- 系统变量(初始化用，然后就可以选择屏蔽掉，后续用的是settings.json中的配置)
```shell
#claude-code 自有模型配置
export ANTHROPIC_BASE_URL=http://localhost:1234 或者 https://xxx/anthropic
export ANTHROPIC_AUTH_TOKEN=sk-xxx
export ANTHROPIC_MODEL=qwen3.5-plus
```

- 全局配置
> 新建/更新settings.json,位于~/.claude
```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://xxx/anthropic",
    "ANTHROPIC_API_KEY": "sk-xxxx",
    "ANTHROPIC_MODEL": "qwen3.5-plus"
  },
  "allowedModels": [
    "glm-5",
    "kimi-k2.5",
    "MiniMax-M2.5",
    "qwen3-coder-plus",
    "qwen3.5-plus"
  ],
  "theme": "system",
  "editor": "sublime",
  "shell": "zsh",
  "autoAccept": false,
  "autoEdit": false,
  "verbosity": "normal",
  "maxSessionTurns": 100,
  "history": {
    "maxSize": 1000,
    "save": true
  },
  "mcpServers": {},
  "context": {
    "maxBytes": 500000,
    "fileLimit": 100
  },
  "notifications": {
    "enabled": false
  },
  "customInstructions": "保持代码简洁，避免过度工程化。修改文件前先读取，使用 Edit 而非 Write 进行小改动。优先使用专用工具（Read/Write/Edit/Glob/Grep）而非 Bash 执行文件操作。",
  "diffEnabled": true,
  "fuzzyMatch": true
}
```

### 使用
```textmate
1.打开Iterm或其他终端工具
2.进入项目目录，执行claude
3.开始使用
```

## Codex
### 安装
```shell
npm install -g @openai/codex --registry=https://registry.npmmirror.com
```

### 配置
> 新建/更新config.toml,位于~/.codex
```toml
# =====================================================
# 模型元数据配置 (必须在 model 引用之前定义)
# =====================================================
[model_metadata.qwen3.5-plus]
context_window = 131072
max_output_tokens = 8192
supports_vision = false
supports_function_calling = true

# =====================================================
# 全局配置
# =====================================================
# 当前使用的模型
model = "qwen3.5-plus"
# 当前使用的模型提供商（对应下方 [model_providers.*]）
model_provider = "vapi"
# 推理努力程度：low | medium | high
model_reasoning_effort = "medium"
# 默认 API 基础 URL
base_url = "https://xxx/v1"
# API 格式：chat | responses
wire_api = "responses"

# =====================================================
# 模型提供商配置
# =====================================================
# 使用说明：
# 1. 切换模型只需修改 model_provider 为下方对应的 provider 名称
# 2. API Key 建议通过环境变量设置，在对应 provider 下配置 env_key
# 3. wire_api: "chat" = OpenAI 兼容格式，"responses" = Anthropic 格式

# --- 阿里云通义千问 ---
[model_providers.vapi]
name = "VAPI"
base_url = "https://xxx/v1"
# env_key = "DASHSCOPE_API_KEY"
wire_api = "responses"

# --- OpenAI (GPT-4 / GPT-4o / o1 系列) ---
[model_providers.openai]
name = "OpenAI"
base_url = "https://api.openai.com/v1"
# env_key = "OPENAI_API_KEY"
wire_api = "responses"
# 可用模型：gpt-4o, gpt-4o-mini, gpt-4-turbo, o1, o3-mini

# --- Ollama (本地模型) ---
[model_providers.ollama]
name = "Ollama"
base_url = "http://localhost:11434/v1"
wire_api = "responses"

```

### 使用
```textmate
1.打开Iterm或其他终端工具
2.进入项目目录，执行codex
3.填入apiKey
4.开始使用
```

### 相关资源
- [Claude-code中文站](https://claude-zh.cn/guide/getting-started)
- [Codex教程](https://www.runoob.com/codex/codex-install.html)
