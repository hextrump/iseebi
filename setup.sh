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
    source $HOME/.cargo/env
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

# 5. Configure .env
if [ ! -f ".env" ]; then
    echo "⚠️ .env file not found. Creating a template..."
    cat <<EOF > .env
# --- Iseebi Japanese Tutor Settings ---
DASHSCOPE_API_KEY=your_api_key_here
TELEGRAM_BOT_TOKEN=your_bot_token_here

# Group Interaction Policy
NANOBOT_CHANNELS__TELEGRAM__GROUP_POLICY=open

# Voice Engine Settings
QWEN_TTS_MODEL=qwen3-tts-flash
QWEN_TTS_VOICE=Cherry
QWEN_TTS_LANGUAGE_TYPE=Japanese
EOF
    echo "✅ Created .env template. PLEASE EDIT IT with your actual keys."
else
    # Ensure group policy is set to open
    if ! grep -q "NANOBOT_CHANNELS__TELEGRAM__GROUP_POLICY=open" .env; then
        echo "NANOBOT_CHANNELS__TELEGRAM__GROUP_POLICY=open" >> .env
        echo "✅ Enabled open group policy in .env."
    fi
fi

# 6. Launch
echo "🔄 Starting Nanobot Gateway..."
pkill -f "nanobot gateway" || true
nohup .venv/bin/python -m nanobot gateway > nanobot.log 2>&1 &

echo "✨ Iseebi is now installed and running via UV!"
echo "Check logs: tail -f nanobot.log"
