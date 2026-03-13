#!/bin/bash
# Iseebi Nanobot Patcher & Setup (UV Optimized)
# This script applies Iseebi customizations using the ultra-fast 'uv' package manager.

set -e

NANOBOT_REPO="https://github.com/HKUDS/nanobot"
NANOBOT_DIR="../nanobot"

echo "🦐 Starting Iseebi setup (UV Mode)..."

# 1. Install UV if missing
if ! command -v uv &> /dev/null; then
    echo "📦 Installing 'uv' package manager..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # Standard uv installer location
    if [ -f "$HOME/.local/bin/env" ]; then
        source "$HOME/.local/bin/env"
    elif [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
    fi
    # Force add to PATH just in case sourcing fails in some shells
    export PATH="$HOME/.local/bin:$PATH"
fi

# 2. Clone Official Repository if missing
if [ ! -d "$NANOBOT_DIR" ]; then
    echo "git cloning official Nanobot from HKUDS..."
    git clone $NANOBOT_REPO $NANOBOT_DIR
fi

# 3. Patch the core files
echo "⚡ Patching telegram.py..."
if [ -f "telegram.py" ]; then
    cp telegram.py "$NANOBOT_DIR/nanobot/channels/telegram.py"
    echo "✅ Applied Iseebi optimized telegram.py patch."
else
    echo "❌ Error: telegram.py not found in current directory."
    exit 1
fi

# 4. Setup with UV
cd "$NANOBOT_DIR"
echo "🛠️ Creating environment and installing dependencies via uv..."
# Install latest python and dependencies in a managed venv
uv venv
source .venv/bin/activate
uv pip install -e .
uv pip install httpx loguru python-telegram-bot pydantic-settings gitpython ffmpeg-python

# 5. Configure .env and global nanobot config
if [ ! -f ".env" ]; then
    echo "⚠️ .env file not found. Creating a template..."
    cat <<EOF > .env
# --- Iseebi Japanese Tutor Settings ---
# Enable the Telegram channel (MANDATORY)
NANOBOT_CHANNELS__TELEGRAM__ENABLED=true

# Your API Keys (Get from https://dashscope.aliyun.com/)
DASHSCOPE_API_KEY=your_api_key_here

# Internal Mappings (Do not change unless you know what you are doing)
NANOBOT_PROVIDERS__OPENAI__API_KEY=your_api_key_here
NANOBOT_PROVIDERS__OPENAI__API_BASE=https://dashscope.aliyuncs.com/compatible-mode/v1
NANOBOT_AGENTS__DEFAULTS__MODEL=qwen-max
NANOBOT_AGENTS__DEFAULTS__PROVIDER=openai

# Telegram Config
NANOBOT_CHANNELS__TELEGRAM__ENABLED=true
NANOBOT_CHANNELS__TELEGRAM__TOKEN=your_bot_token_here
NANOBOT_CHANNELS__TELEGRAM__ALLOW_FROM=["*"]
NANOBOT_CHANNELS__TELEGRAM__GROUP_POLICY=open

# Voice Engine Settings
QWEN_TTS_MODEL=qwen3-tts-flash
QWEN_TTS_VOICE=Cherry
EOF
    echo "✅ Created .env template. PLEASE EDIT IT with your actual keys."
else
    # Ensure channel is enabled and group policy is set to open
    if ! grep -q "NANOBOT_CHANNELS__TELEGRAM__ENABLED=true" .env; then
        echo "NANOBOT_CHANNELS__TELEGRAM__ENABLED=true" >> .env
    fi
    if ! grep -q "NANOBOT_CHANNELS__TELEGRAM__ALLOW_FROM" .env; then
        echo 'NANOBOT_CHANNELS__TELEGRAM__ALLOW_FROM=["*"]' >> .env
    fi
    if ! grep -q "NANOBOT_CHANNELS__TELEGRAM__GROUP_POLICY=open" .env; then
        echo "NANOBOT_CHANNELS__TELEGRAM__GROUP_POLICY=open" >> .env
    fi
fi

# 6. Global Nanobot Config (satisfies core startup check)
mkdir -p ~/.nanobot
if [ ! -f ~/.nanobot/config.json ]; then
    echo "🛠️ Initializing global nanobot config..."
    cat <<EOF > ~/.nanobot/config.json
{
  "providers": {
    "openai": {
      "api_key": "YOUR_API_KEY_HERE",
      "api_base": "https://dashscope.aliyuncs.com/compatible-mode/v1"
    }
  },
  "agents": {
    "defaults": {
      "model": "qwen-max",
      "provider": "openai"
    }
  }
}
EOF
    echo "✅ Created ~/.nanobot/config.json. (Core engine needs at least one key to start)"
fi

# 7. Launch
echo "🔄 Starting Nanobot Gateway..."
pkill -f "nanobot gateway" || true
nohup .venv/bin/python -m nanobot gateway > nanobot.log 2>&1 &

echo "✨ Iseebi is now installed and running via UV!"
echo "Check logs: tail -f nanobot.log"
