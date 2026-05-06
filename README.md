# Auto Vibe Coding - Multi-Agent Flywheel

可直接使用的 Agent / Skill 提示词，实现多Agent飞轮 "执行→自测→找问题→推翻假阳性→修复→再验证" 的闭环。

## 快速使用

### 方式1: 在 Claude Code 中调用

```bash
cd auto-vibe-coding
./scripts/init.sh
```

然后直接用：
```
/self-test                    # 快速自测当前代码
/flywheel                     # 启动完整飞轮
```

### 方式2: 复制粘贴给任何 AI

直接把文件内容粘贴给 Claude / ChatGPT / Codex / Gemini 即可。

### 方式3: 使用独立 Agent

把 `agents/` 下的角色提示词分别喂给不同的 Agent 实例。

## 文件结构

```
auto-vibe-coding/
├── README.md                      # 本文件
├── METHODOLOGY.md                 # 📚 综合方法论（必读）
├── FLYWHEEL.md                    # 🎯 飞轮编排者 - 先看这个
├── agents/                        # 角色化 Agent 提示词
│   ├── hunter.md                  # 问题猎人 - 找 bug
│   ├── skeptic.md                 # 怀疑论者 - 推翻假阳性
│   ├── referee.md                 # 裁判 - 终裁
│   ├── fixer.md                   # 修复者 - 修 bug
│   ├── security.md                # 安全审计 - OWASP/CWE
│   └── performance.md             # 性能分析 - 复杂度/泄漏
├── skills/                        # 可调用技能
│   ├── self-test.md               # 快速自测
│   ├── flywheel.md                # 完整飞轮
│   └── verify-sandbox.md          # 沙箱隔离验证
├── references/
│   └── PAPERS.md                  # 论文/项目索引
├── examples/
│   └── demo-session.md            # 完整执行演示
├── configs/
└── scripts/
```

## 核心流程

```
你的代码 → Self-Test → Hunter 找问题 → Skeptic 推翻假阳性
                                              ↓
                                          Referee 裁决
                                              ↓
                                          Fixer 修复
                                              ↓
                                    回到 Self-Test ──┘
                                    （循环直到收敛）
```

## 关键设计

1. **假阳性过滤** — 每个发现必须经过"试图证伪"（Skeptic+Referee），参考 Claude Code Review 机制
2. **Execution Grounding** — 所有声明必须有可执行验证证据，不接受模型自信（AgentForge 原则）
3. **Generator ≠ Evaluator** — 写代码和审查代码不能是同一个 Agent（CodeX-Verify + wow-harness 共识）
4. **收敛数学** — Acc_t = Upp − α^t(Upp − Acc_0)，边际递减，5轮最优停止
5. **强制执行层级** — Harness(100%) > Hook(80-95%) > Prompt(20-30%)

## 方法论

全部理论基础见 [METHODOLOGY.md](METHODOLOGY.md)：
- MAPE飞轮模型 (Monitor→Analyze→Plan→Execute)
- 收敛数学与最优停止策略
- 验证金字塔 (Static→Sandbox→ModelCheck→Bounded→Empirical)
- 两阶段检测+验证 (BitsAI-CR)
- Sellier四层架构

## 适用场景

- PR Review 自动验证
- Bug 修复后的自测验证
- 功能开发完的自测
- CI 构建失败的自动诊断修复

## 参考

- [Claude Code Review](https://www.anthropic.com/engineering/claude-code-review) - 多Agent 代码审查
- [Anthropic Multi-Agent Research](https://www.anthropic.com/engineering/how-we-built-our-multi-agent-research-system) - 多Agent 研究系统
- [Bug Hunter](https://github.com/codexstar69/bug-hunter) - 三Agent 辩论模式
- [Agent Orchestrator](https://github.com/ComposioHQ/agent-orchestrator) - CI/CD 自愈

## License

MIT
