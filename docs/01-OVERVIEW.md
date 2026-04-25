# Auto Vibe Coding - 多Agent飞轮自测 + 自动验证系统

> 构建 AI 全自动编码飞轮：多Agent协作 → 自测自验 → 智能修复 → 持续迭代

## 核心价值

```
┌─────────────────────────────────────────────────────────────────────┐
│                    MULTI-AGENT FLYWHEEL SYSTEM                       │
│                                                                     │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    │
│   │  Scout   │───▶│ Architect│───▶│  Dev     │───▶│  QA      │    │
│   │  Agent   │    │  Agent   │    │  Agents  │    │  Agent   │    │
│   └──────────┘    └──────────┘    └──────────┘    └──────────┘    │
│        │                                            │              │
│        │            ┌──────────┐                    │              │
│        └───────────▶│ Verifier │◀───────────────────┘              │
│                     │  Agent   │                                     │
│                     └────┬─────┘                                     │
│                          │                                           │
│                     ┌─────▼─────┐                                    │
│                     │  Fixer   │                                    │
│                     │  Agent   │                                    │
│                     └─────┬─────┘                                    │
│                           │                                          │
│         ┌─────────────────┼─────────────────┐                        │
│         ▼                 ▼                 ▼                        │
│   ┌──────────┐      ┌──────────┐      ┌──────────┐                 │
│   │  Commit  │      │  Retest  │      │  Deploy  │                 │
│   │  & Push  │      │  & Gate  │      │  & Mon   │                 │
│   └──────────┘      └──────────┘      └──────────┘                 │
│                                                                     │
│                    [FLYWHEEL CONTINUOUS LOOP]                        │
└─────────────────────────────────────────────────────────────────────┘
```

## 系统架构

### 核心组件

| 组件 | 职责 | 关键技术 |
|------|------|----------|
| **Scout Agent** | 问题发现、需求分析 | RAG + 语义搜索 |
| **Architect Agent** | 系统设计、技术选型 | 思维链推理 |
| **Dev Agent(s)** | 代码实现、单元测试 | 多Agent并行 |
| **QA Agent** | 测试设计、边界分析 | 模糊测试 |
| **Verifier Agent** | 结果验证、假阳性过滤 |  adversarial验证 |
| **Fixer Agent** | 自动修复、提交代码 | Git操作 |
| **Learner Agent** | 模式学习、知识积累 | 向量数据库 |

### 验证策略层级

```
Layer 1: Syntax & Schema Validation     (即时)
Layer 2: Unit & Integration Tests       (快速)
Layer 3: Semantic & Logic Verification  (深度)
Layer 4: Adversarial Challenge          (严格)
Layer 5: Human Review Gate               (审批)
```

## 关键设计原则 (Anthropic Best Practices)

### 1. 并行化策略
- Lead Agent 一次性生成 3-5 个 SubAgent
- 每个 SubAgent 有独立 context window
- 关键信息的蒸馏压缩返回

### 2. 假阳性过滤 (Claude Code Review 核心)
- 每个 Bug 发现必须经过"试图证伪"步骤
- 只有无法被推翻的发现才上报
- **工程师标记错误率 < 1%**

### 3. 动态适应
- 根据中间结果决定是否需要更多 Agent
- 简单任务用 1 Agent，复杂研究用 10+ Agent
- 失败模式自诊断和提示词重写

### 4. 规模规则嵌入
- 防止简单任务过度投资
- 教 Lead Agent 如何委托

## 快速开始

```bash
cd ~/auto-vibe-coding
./scripts/init.sh
./scripts/run-flywheel.sh --task "实现用户登录功能"
```

## 项目结构

```
auto-vibe-coding/
├── docs/                    # 完整文档
│   ├── 01-OVERVIEW.md       # 本文件 - 系统概览
│   ├── 02-ARCHITECTURE.md   # 详细架构设计
│   ├── 03-AGENTS.md         # 各Agent职责定义
│   ├── 04-VERIFICATION.md   # 验证策略详解
│   ├── 05-BEST-PRACTICES.md # Anthropic最佳实践
│   ├── 06-REFERENCE-PROJECTS.md  # 参考项目分析
│   └── 07-IMPLEMENTATION.md # 实施路线图
├── src/                     # 源代码
├── configs/                 # 配置文件
└── scripts/                # 运行脚本
```

## 参考项目

| 项目 | Stars | 特点 |
|------|-------|------|
| [RuFlo](https://github.com/ruvnet/ruflo) | 33k | 100+Agent, 自优化, 企业级 |
| [Agent Orchestrator](https://github.com/ComposioHQ/agent-orchestrator) | 6.5k | CI/CD自愈, 并行worktree |
| [Bug Hunter](https://github.com/codexstar69/bug-hunter) | 121 | 三Agent辩论, adversarial验证 |
| [vibecosystem](https://github.com/vibeeval/vibecosystem) | 471 | 138Agent, 自学习pipeline |
| [AlphaSwarm.sol](https://github.com/alehdezp/alphaswarm-sol) | - | 自测harness, 知识图谱 |
| [promptfoo](https://github.com/promptfoo/promptfoo) | 20k | LLM测试, 红队 |

## License

MIT
