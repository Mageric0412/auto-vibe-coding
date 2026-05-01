# Auto Vibe Coding - Multi-Agent Flywheel

可直接使用的 Agent / Skill 提示词，实现多Agent飞轮 "执行→自测→找问题→推翻假阳性→修复→再验证" 的闭环。

## 快速使用

### 方式1: 在 Claude Code 中调用

```bash
cp ~/auto-vibe-coding/skills/* ~/.claude/skills/
```

然后直接：
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
├── FLYWHEEL.md                    # 🎯 飞轮编排者 - 先看这个
├── agents/                        # 角色化 Agent 提示词
│   ├── hunter.md                  # 问题猎人 - 找 bug
│   ├── skeptic.md                 # 怀疑论者 - 推翻假阳性
│   ├── referee.md                 # 裁判 - 终裁
│   └── fixer.md                   # 修复者 - 修 bug
├── skills/                        # 可调用技能
│   ├── self-test.md               # 快速自测
│   └── flywheel.md                # 完整飞轮
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

## 三个关键设计

1. **假阳性过滤** - 每个发现必须经过"试图证伪"步骤，参考 Claude Code Review 机制
2. **证据驱动** - 所有声明必须有代码引用 / 测试输出 / Git 状态
3. **收敛判定** - 连续 2 轮无新发现即停止，不是无限循环

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
