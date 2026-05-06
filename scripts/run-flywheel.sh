#!/bin/bash
# scripts/run-flywheel.sh - 运行飞轮

set -e

TASK=""
CONFIG="configs/flywheel-config.yaml"

# 解析参数
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
            TASK="$1"
            shift
            ;;
    esac
done

if [ -z "$TASK" ]; then
    echo "Usage: $0 --task \"your task description\" [--config config.yaml]"
    echo ""
    echo "Examples:"
    echo "  $0 --task \"实现用户登录功能\""
    echo "  $0 \"实现用户登录功能\""
    exit 1
fi

echo "🚀 Flywheel - Multi-Agent Self-Testing System"
echo "📋 Task: $TASK"
echo ""

echo "This project uses prompt-based Agent/Skill files. To run the flywheel:"
echo ""
echo "  1. Run the one-command setup:"
echo "     ./scripts/init.sh"
echo ""
echo "  2. Run in Claude Code:"
echo "     /flywheel --task \"$TASK\""
echo ""
echo "  3. Or paste the prompt files to any AI agent:"
echo "     cat FLYWHEEL.md agents/hunter.md agents/skeptic.md agents/referee.md agents/fixer.md"
echo ""
echo "See README.md and METHODOLOGY.md for full usage guide."
