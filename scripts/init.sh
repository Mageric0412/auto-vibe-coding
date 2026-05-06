#!/bin/bash
# scripts/init.sh - Auto Vibe Coding 一键初始化
# 用法: ./scripts/init.sh

set -e

echo "🚀 Initializing Auto Vibe Coding..."

# 1. 符号链接 skills 目录到 Claude Code
echo "🔗 Installing skills to ~/.claude/skills/..."

mkdir -p "$HOME/.claude/skills"

# 清理旧的平铺 .md 文件（如果有）
for old in "$HOME/.claude/skills"/*.md; do
    [ -e "$old" ] && rm -f "$old"
done

for skill_dir in skills/*/; do
    name=$(basename "$skill_dir")
    dest="$HOME/.claude/skills/$name"
    [ -e "$dest" ] || [ -L "$dest" ] && rm -rf "$dest"
    ln -s "$PWD/$skill_dir" "$dest"
    echo "   ✅ $name -> ~/.claude/skills/$name"
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
echo "💡 Skills are symlinked to ~/.claude/skills/ — git pull updates are automatic."
echo ""
