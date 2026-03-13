# 🦐 Iseebi (イセエビ) - Nanobot Japanese Tutor Patch

Iseebi is a high-speed, low-latency "Japanese Tutor" customization for the [Nanobot](https://github.com/v8pai/nanobot) Telegram agent. 

By bypassing the standard event-bus and streaming ASR, LLM, and TTS directly, Iseebi provides a fluid, near-real-time voice conversation experience tailored for language learning.

## ✨ Features

- **Ultra-Low Latency**: Near-instant voice replies by streaming tokens to TTS as they are generated.
- **Smart Chunking**: Sentences are split naturally using punctuation-aware buffering for smooth audio delivery.
- **Context Aware**: Remembers the last 8 turns of conversation and knows the current time (Tokyo).
- **Japanese Tutor Persona**: Sophisticated "recaseting" logic that corrects your Japanese subtly without breaking the conversation flow.
- **Group Chat Ready**: Configured to respond to everyone in Telegram group chats (Privacy Mode: Disabled).

## 🚀 One-Click Deployment

This repository is designed to be used as a "patch" on top of the official Nanobot engine.

### Prerequisites
1. A fresh VPS (Ubuntu/Debian recommended).
2. A Telegram Bot Token from [@BotFather](https://t.me/BotFather) (Ensure **Privacy Mode** is **Disabled**).
3. A [DashScope (Aliyun)](https://dashscope.aliyun.com/) API Key for ASR/LLM/TTS.

## 📦 Installation

This project is a high-performance patch for [HKUDS/nanobot](https://github.com/HKUDS/nanobot).

### 🚀 Standard Installation (Recommended)

Execute these steps on your fresh VPS. This method uses `uv` for ultra-fast environment setup and automatically patches the official core.

```bash
# 1. Install 'uv' (Fastest way to get Python/Pip environment)
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env

# 2. Clone this customization & run setup
git clone https://github.com/hextrump/iseebi.git
cd iseebi && bash setup.sh
```

*(Note: `setup.sh` will handle cloning the official `HKUDS/nanobot` and applying the Iseebi optimization.)*

### 🛠️ Manual Installation (For developers)
If you prefer to set up manually, please follow the [official Nanobot installation guide](https://github.com/HKUDS/nanobot#-install) first:
1. `git clone https://github.com/HKUDS/nanobot.git`
2. `cd nanobot && pip install -e .`
3. Overwrite `nanobot/channels/telegram.py` with the one from this repo.

Fill in your API keys (Your DashScope Key will be used twice):
```bash
# Enable Telegram
NANOBOT_CHANNELS__TELEGRAM__ENABLED=true
NANOBOT_CHANNELS__TELEGRAM__TOKEN=your_bot_token_here

# DashScope (Qwen) Key - Paste the SAME key into both fields below
DASHSCOPE_API_KEY=your_sk_key_here
NANOBOT_PROVIDERS__OPENAI__API_KEY=your_sk_key_here

# Internal Config (Pre-set by script)
NANOBOT_PROVIDERS__OPENAI__API_BASE=https://dashscope.aliyuncs.com/compatible-mode/v1
NANOBOT_AGENTS__DEFAULTS__MODEL=qwen-max
NANOBOT_AGENTS__DEFAULTS__PROVIDER=openai
```
Then restart:
```bash
pkill -f "nanobot gateway"
cd /root/nanobot && nohup .venv/bin/python -m nanobot gateway > nanobot.log 2>&1 &
```

## 🛠️ Repository Structure
- `telegram.py`: The core optimized channel logic.
- `setup.sh`: Automated installer that patches Nanobot and installs dependencies.
- `README.md`: This guide.

## ⚖️ License
This patch follows the same licensing as the original Nanobot project. Use it to level up your Japanese! 🇯🇵
