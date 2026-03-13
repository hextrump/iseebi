#!/bin/bash
# Iseebi Nanobot Patcher & Setup
# This script applies Iseebi customizations to an official Nanobot installation.

set -e

NANOBOT_DIR="../nanobot"

echo "🦐 Starting Iseebi setup..."

# 1. Check if nanobot official exists
if [ ! -d "$NANOBOT_DIR" ]; then
    echo "❌ Error: Nanobot directory not found at $NANOBOT_DIR"
    echo "Please run: git clone https://github.com/v8pai/nanobot.git first."
    exit 1
fi

# 2. Patch the core files
echo "⚡ Patching telegram.py..."
if [ -f "telegram.py" ]; then
    cp telegram.py "$NANOBOT_DIR/nanobot/channels/telegram.py"
    echo "✅ Applied Iseebi optimized telegram.py patch."
else
    echo "❌ Error: telegram.py not found in current directory."
    exit 1
fi

# 3. Setup Virtual Environment in Nanobot dir
cd "$NANOBOT_DIR"
if [ ! -d ".venv" ]; then
    echo "🛠️ Creating virtual environment..."
    python3 -m venv .venv
    .venv/bin/pip install --upgrade pip
fi

echo "📥 Installing dependencies..."
.venv/bin/pip install httpx loguru python-telegram-bot pydantic-settings gitpython ffmpeg-python

# 4. Configure .env
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

# 5. Launch
echo "🔄 Starting Nanobot Gateway..."
pkill -f "nanobot gateway" || true
nohup .venv/bin/python -m nanobot gateway > nanobot.log 2>&1 &

echo "✨ Iseebi is now installed and running!"
echo "Check logs: tail -f nanobot.log"
