#!/bin/bash
# scripts/init.sh - Auto Vibe Coding 初始化脚本

set -e

echo "🚀 Initializing Auto Vibe Coding..."

# 检查依赖
echo "📦 Checking dependencies..."

if ! command -v python >/dev/null 2>&1; then
    echo "❌ Python is required but not installed."
    exit 1
fi

if ! command -v poetry >/dev/null 2>&1; then
    echo "⚠️  Poetry not found. Installing..."
    curl -sSL https://install.python-poetry.org | python -
fi

# 安装依赖
echo "📦 Installing dependencies..."
poetry install --no-interaction || true

# 初始化配置
echo "⚙️  Initializing configuration..."
if [ ! -f configs/flywheel-config.yaml ]; then
    if [ -f configs/flywheel-config.yaml.example ]; then
        cp configs/flywheel-config.yaml.example configs/flywheel-config.yaml
        echo "✅ Created configs/flywheel-config.yaml"
    fi
fi

# 创建必要目录
echo "📁 Creating directories..."
mkdir -p memory/{patterns,failures,rules}
mkdir -p logs
mkdir -p output

# 环境检查
echo "🔍 Verifying environment..."
poetry run python -c "import langgraph; print('✅ langgraph')" 2>/dev/null || echo "⚠️  langgraph not installed"
poetry run python -c "import anthropic; print('✅ anthropic')" 2>/dev/null || echo "⚠️  anthropic not installed"
poetry run python -c "import chromadb; print('✅ chromadb')" 2>/dev/null || echo "⚠️  chromadb not installed"

echo ""
echo "✅ Initialization complete!"
echo ""
echo "Usage:"
echo "  ./scripts/run-flywheel.sh --task \"your task description\""
echo ""
