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

echo "🚀 Flywheel - Multi-Agent Self-Testing System"
echo "📋 Task: $TASK"
echo ""

echo "This project uses prompt-based Agent/Skill files. To run the flywheel:"
echo ""
echo "  1. Copy skills to Claude Code:"
echo "     cp skills/*.md ~/.claude/skills/"
echo ""
echo "  2. Run in Claude Code:"
echo "     /flywheel --task \"$TASK\""
echo ""
echo "  3. Or paste the prompt files to any AI agent:"
echo "     cat FLYWHEEL.md agents/hunter.md agents/skeptic.md agents/referee.md agents/fixer.md"
echo ""
echo "See README.md and METHODOLOGY.md for full usage guide."
