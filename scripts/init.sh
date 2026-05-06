#!/bin/bash
# scripts/init.sh - Auto Vibe Coding 一键初始化
# 用法: ./scripts/init.sh

set -e

echo "🚀 Initializing Auto Vibe Coding..."

# 1. 复制 skills 到 Claude Code（注入项目路径）
echo "🔗 Installing skills to ~/.claude/skills/..."

mkdir -p "$HOME/.claude/skills"

for skill in skills/*.md; do
    name=$(basename "$skill")
    dest="$HOME/.claude/skills/$name"
    sed "s|__AVC_HOME__|$PWD|g" "$skill" > "$dest"
    echo "   ✅ $name -> ~/.claude/skills/$name (paths resolved)"
done

# 2. 复制配置文件（如果不存在）
echo "⚙️  Setting up configuration..."
if [ ! -f configs/flywheel-config.yaml ]; then
    if [ -f configs/flywheel-config.yaml.example ]; then
        cp configs/flywheel-config.yaml.example configs/flywheel-config.yaml
        echo "   ✅ Created configs/flywheel-config.yaml"
    fi
else
    echo "   ⏭️  configs/flywheel-config.yaml already exists, skipped"
fi

# 3. 创建数据和日志目录
echo "📁 Creating storage directories..."
mkdir -p memory/{patterns,failures,rules}
mkdir -p logs
mkdir -p output
echo "   ✅ Created memory/ logs/ output/"

echo ""
echo "✅ Setup complete! You can now use:"
echo "  /self-test    - Quick self-test of current code"
echo "  /flywheel     - Start the full multi-agent flywheel"
echo "  /verify-sandbox - Sandbox isolation verification"
echo ""
echo "💡 Skills installed with resolved paths. Re-run init.sh after git pull to update."
echo ""
echo "   ./scripts/init.sh    # re-run after git pull to sync skills"
