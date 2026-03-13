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

### Installation Steps

Execute these three steps on your VPS:

```bash
# 1. Install 'uv' (Fastest way to get Python running)
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.cargo/env

# 2. Clone this customization & run setup
git clone https://github.com/hextrump/iseebi.git
cd iseebi && bash setup.sh
```

*(The `setup.sh` script will automatically clone the official HKUDS/nanobot engine and apply the Iseebi patch.)*

### Configuration
After installation, edit your environment variables:
```bash
nano /root/nanobot/.env
```
Fill in your `DASHSCOPE_API_KEY` and `TELEGRAM_BOT_TOKEN`, then restart:
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
