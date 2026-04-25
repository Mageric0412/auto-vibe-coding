# Auto Vibe Coding - 多Agent飞轮自测系统

> AI 全自动编码飞轮：多Agent协作 → 自测自验 → 智能修复 → 持续迭代

## 核心特性

- **多Agent协作**: Scout、Architect、Dev、QA、Verifier、Fixer 协同工作
- **分层验证**: 5层验证体系，从语法检查到 Adversarial 挑战
- **假阳性过滤**: Claude Code Review 同款机制，工程师误标率 < 1%
- **自学习Pipeline**: 从错误中学习，自动生成规则
- **自动修复闭环**: 发现 → 验证 → 修复 → 提交

## 快速开始

```bash
# 克隆项目
cd ~/auto-vibe-coding

# 初始化
./scripts/init.sh

# 运行飞轮
./scripts/run-flywheel.sh --task "实现用户登录功能"
```

## 文档结构

| 文档 | 内容 |
|------|------|
| [01-OVERVIEW](docs/01-OVERVIEW.md) | 系统概览 |
| [02-ARCHITECTURE](docs/02-ARCHITECTURE.md) | 架构设计 |
| [03-AGENTS](docs/03-AGENTS.md) | Agent 职责定义 |
| [04-VERIFICATION](docs/04-VERIFICATION.md) | 验证策略 |
| [05-BEST-PRACTICES](docs/05-BEST-PRACTICES.md) | Anthropic 最佳实践 |
| [06-REFERENCE-PROJECTS](docs/06-REFERENCE-PROJECTS.md) | 参考项目 |
| [07-IMPLEMENTATION](docs/07-IMPLEMENTATION.md) | 实施路线图 |

## 架构图

```
┌─────────────────────────────────────────────────────────────────────┐
│                    MULTI-AGENT FLYWHEEL SYSTEM                       │
│                                                                     │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐        │
│   │  Scout   │───▶│ Architect│───▶│  Dev     │───▶│  QA      │        │
│   │  Agent   │    │  Agent   │    │  Agents  │    │  Agent   │        │
│   └──────────┘    └──────────┘    └──────────┘    └──────────┘        │
│        │                                            │                │
│        │            ┌──────────┐                    │                │
│        └───────────▶│ Verifier │◀───────────────────┘                │
│                     │  Agent   │                                     │
│                     └────┬─────┘                                     │
│                          │                                           │
│                     ┌─────▼─────┐                                    │
│                     │  Fixer   │                                    │
│                     │  Agent   │                                    │
│                     └─────┬─────┘                                    │
│                           │                                          │
│                           ▼                                          │
│                    [FLYWHEEL CONTINUOUS LOOP]                        │
└─────────────────────────────────────────────────────────────────────┘
```

## 参考项目

| 项目 | Stars | 特点 |
|------|-------|------|
| [RuFlo](https://github.com/ruvnet/ruflo) | 33k | 100+Agent, 自优化 |
| [Agent Orchestrator](https://github.com/ComposioHQ/agent-orchestrator) | 6.5k | CI/CD自愈 |
| [Bug Hunter](https://github.com/codexstar69/bug-hunter) | 121 | 三Agent辩论 |
| [vibecosystem](https://github.com/vibeeval/vibecosystem) | 471 | 138Agent自学习 |
| [promptfoo](https://github.com/promptfoo/promptfoo) | 20k | LLM测试 |

## License

MIT
