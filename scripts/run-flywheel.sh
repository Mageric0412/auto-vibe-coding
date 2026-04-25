#!/bin/bash
# scripts/run-flywheel.sh - 运行飞轮

set -e

TASK="${1:-}"
CONFIG="${2:-configs/flywheel-config.yaml}"

if [ -z "$TASK" ]; then
    echo "Usage: $0 --task \"your task description\" [--config config.yaml]"
    echo ""
    echo "Examples:"
    echo "  $0 --task \"实现用户登录功能\""
    echo "  $0 --task \"修复支付模块的并发问题\""
    echo "  $0 --task \"优化数据库查询性能\""
    exit 1
fi

# 解析参数
shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --task)
            TASK="$2"
            shift 2
            ;;
        --config)
            CONFIG="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "🚀 Starting Flywheel..."
echo "📋 Task: $TASK"
echo "⚙️  Config: $CONFIG"
echo ""

# 运行飞轮
poetry run python -m src.core.flywheel \
    --task "$TASK" \
    --config "$CONFIG" \
    --verbose

echo ""
echo "✅ Flywheel completed!"
