# 飞轮方法论：Multi-Agent Self-Testing Flywheel

> 综合学术界（CodeX-Verify, AgentForge, ReVeal, BitsAI-CR）和工业界（Anthropic, Datadog, ByteDance, wow-harness, Sellier）的最佳实践

---

## 1. MAPE 飞轮模型

飞轮本质是一个 MAPE 控制环（Monitor → Analyze → Plan → Execute），每次旋转将错误反馈转化为改进。

```
                    ┌──────────────────────────┐
                    │     MAPE FLYWHEEL         │
                    │                            │
    ┌──────────┐    │    ┌──────────────┐       │
    │ MONITOR  │────────▶│   ANALYZE    │       │
    │ 收集信号 │         │ 根因分类     │       │
    └──────────┘         └──────┬───────┘       │
         ▲                      │                │
         │                      ▼                │
    ┌──────────┐         ┌──────────────┐       │
    │ EXECUTE  │◀────────│    PLAN      │       │
    │ 修复/部署│         │ 改进策略     │       │
    └──────────┘         └──────────────┘       │
                    │                            │
                    └──────────────────────────┘
```

### 信号来源

| 信号 | 即时性 | 可靠性 | 获取方式 |
|------|--------|--------|----------|
| Lint/Type errors | 秒级 | 100% | 编译器/工具 |
| 测试失败 | 秒-分钟 | 99% | 测试框架 |
| Sandbox执行 | 秒级 | 100% | Docker隔离运行 |
| Hunter发现 | 分钟级 | 70-80% | Agent扫描 |
| Adversarial验证 | 分钟级 | 90%+ | Skeptic+Referee |
| 构建失败 | 分钟级 | 100% | CI/CD |
| 生产遥测 | 小时-天级 | 95% | 监控系统 |

---

## 2. 收敛数学

### 2.1 EmergentMind 收敛公式

```
Acc_t = Upp − α^t × (Upp − Acc_0)

其中:
  Acc_t  = 第 t 轮的准确度
  Upp    = 准确度上界（通常 0.85-0.95）
  Acc_0  = 初始准确度
  α      = 衰减因子 (0 < α < 1，通常 0.3-0.7)
  t      = 迭代轮次
```

**关键含义**：
- 边际收益严格递减：每轮的新发现比上一轮少
- 存在实际上界：不可能无限改进
- 最优停止点 ≈ 3-5 轮（当 |Acc_t+1 − Acc_t| < ε 时）

### 2.2 CodeX-Verify 多Agent收益递减实证

| Agent组合 | 准确率 | 边际增益 |
|-----------|--------|----------|
| 1 Agent | 32.8% | — |
| 2 Agents | 47.7% | +14.9pp |
| 3 Agents | 61.2% | +13.5pp |
| 4 Agents | 72.4% | +11.2pp |

**观察**：边际增益从 14.9pp → 11.2pp，严格递减。

### 2.3 最优停止策略

```
停止条件 (满足任一):
1. 连续 2 轮无新 CONFIRMED finding
2. 当前轮边际改进 < ε (通常 ε = 0.02)
3. 达到最大轮次 MAX_ROUNDS = 5

理论上界估算:
  Acc_0 ≈ 0.5 (初始代码质量)
  Upp   ≈ 0.9 (在给定技术栈下可达到的最佳)
  α     ≈ 0.5 (中等衰减)

  t=1: 0.500 + 0.5×0.4 = 0.700
  t=2: 0.700 + 0.5×0.2 = 0.800
  t=3: 0.800 + 0.5×0.1 = 0.850
  t=4: 0.850 + 0.5×0.05 = 0.875
  t=5: 0.875 + 0.5×0.025 = 0.8875

→ 5轮后增益 < 2%，不值得继续
```

---

## 3. Generator ≠ Evaluator 原则

**核心洞察**（来自 Anthropic、CodeX-Verify、wow-harness 的一致结论）：

> 生成代码的 Agent 绝不能同时验证自己的代码。
> 自评准确率远低于独立评估。

### 实证

| 评估方式 | 假阴性率（漏报） | 假阳性率（误报） |
|----------|-----------------|-----------------|
| 自评 | 40-60% | 10-20% |
| 独立Agent评估 | 15-25% | 5-10% |
| Adversarial评估 | 10-15% | <5% |

### 实现方式

1. **Agent角色分离**：Hunter为生成者找bug，Skeptic为发现者做挑战
2. **Schema级隔离**（wow-harness做法）：审查Agent的tool schema**不包含**Write/Edit工具
3. **独立context window**：不同Agent使用独立上下文窗口，互不污染
4. **GAN启发式架构**：Generator vs Discriminator，持续对抗提升

---

## 4. 强制执行层级

```
Harness（机械强制）       ████████████████  100% 合规
    ↓
Hook（代码拦截）          ████████████       80-95% 合规
    ↓
Skill/Agent（角色提示）    ████████           60-80% 合规
    ↓
Prompt（文本指令）         ████                20-30% 合规
```

### 为什么 Prompt 指令不够？

wow-harness 实测数据：
- CLAUDE.md 文本指令合规率：**~20%**
- PreToolUse Hook 拦截合规率：**接近 100%**
- 关键差异：Hook 是**机械强制**，不是"建议"

### 建议实现

```bash
# 最低Level：Prompt指令（FLYWHEEL.md / agents/*.md）
# 中等Level：Hook拦截（git hook / CI gate）
# 最高Level：Harness（定制CLI / Schema隔离）

# 快速Hook示例
#!/bin/bash
# .git/hooks/pre-commit — 飞轮通过才能提交
~/.claude/skills/self-test.sh
if [ $? -ne 0 ]; then
  echo "❌ Self-test failed. Fix issues before commit."
  exit 1
fi
```

---

## 5. 验证金字塔

Datadog + Anthropic 合并的5层验证体系：

```
         ┌────────────┐
        ╱    Layer 5    ╲       Empirical Telemetry
       ╱──────────────────╲     (生产监控, 金丝雀)
      ╱     Layer 4         ╲    Bounded Verification
     ╱────────────────────────╲  (Kani/CBMC, 形式化界)
    ╱       Layer 3            ╲   Model Checking
   ╱──────────────────────────────╲(TLA+/NuSMV, 30-60s)
  ╱         Layer 2               ╲  DST / Sandbox
 ╱──────────────────────────────────╲(Docker隔离执行, ~5s)
╱            Layer 1                ╲ Symbolic/Static
──────────────────────────────────────(Lint/Type/Semgrep)
```

| 层 | 类型 | 时间 | 覆盖率 | 假阳性 |
|----|------|------|--------|--------|
| L1: 静态 | Lint, TypeCheck, Semgrep | <5s | 宽 | 中 |
| L2: 沙箱 | Docker隔离执行测试 | ~30s | 中 | 低 |
| L3: 模型检查 | TLA+/NuSMV | 1-5min | 深/窄 | 极低 |
| L4: 界验证 | Kani (Rust), CBMC (C) | 5-15min | 深/窄 | 极低 |
| L5: 经验 | 生产金丝雀, 监控 | 小时-天 | 真实 | 上下文相关 |

**Agent飞轮聚焦 L1 + L2**；L3-L5 是代码进入生产前的附加关卡。

---

## 6. 两阶段检测+验证（BitsAI-CR 模式）

```
┌─────────────────┐     ┌─────────────────┐
│   RuleChecker   │────▶│  ReviewFilter   │
│   宽进 (高召回)  │     │  严出 (高精准)   │
│                 │     │                 │
│  - 静态规则      │     │  - LLM深度分析   │
│  - 模式匹配      │     │  - 上下文验证    │
│  - 快速扫描      │     │  - 精度过滤      │
└─────────────────┘     └─────────────────┘
     召回率 ~90%              精准率 ~75%
```

**借鉴到飞轮**：
- **Hunter (RuleChecker)**：宽进，全面扫描
- **Skeptic+Referee (ReviewFilter)**：严出，精度过滤
- 数据飞轮：假阳性记录 → 反馈到 Hunter 的检查规则

---

## 7. Execution Grounding 原则（AgentForge）

> "代码变更必须经过隔离执行验证。不能让 Agent 仅凭模型自信就声称'没问题'。"

### 三大Grounding要求

1. **测试输出必须真实**
   ```
   ❌ "I verified the tests pass"
   ✅ [粘贴实际 `npm test` 输出]
   ```

2. **沙箱隔离执行**（AgentForge做法）
   ```bash
   docker run --rm --network=none \
     -v $(pwd):/code:ro \
     node:18-alpine \
     sh -c "cd /code && npm test"
   ```

3. **执行结果与声明对比**
   - Agent说"3 tests pass" → 检查输出中是否有 "3 passed"
   - 不一致 → 标记为 unreliable

---

## 8. ReVeal 迭代自进化

### 核心机制

ReVeal (2025) 证明：显式优化 self-verification 能力，模型可以在推理时持续改进 20+ 轮：

```
Turn 1: Generate code → Verify → Tool Feedback
Turn 2: Refine based on feedback → Re-verify → Tool Feedback
...
Turn N: Converge or max turns
```

### TAPO (Turn-Aware PPO)

- 每轮独立奖励（不只看最终结果）
- 生成奖励 + 验证奖励分离
- 工具反馈排除在损失计算外（稳定训练）

### 飞轮借鉴

- 每轮独立评分（不只看收敛时的状态）
- 记录每轮的改进幅度
- 工具执行结果作为唯一真相源（模型自信不计分）

---

## 9. Sellier 四层架构

```
Workflows  ────  命令/技能层（/flywheel, /self-test）
    ↑
Flywheel   ────  反馈更新规则层（Review → Update Rules）
    ↑
Guardrails ────  门禁层（lint, test, build gate）
    ↑
Guidance   ────  指导层（CLAUDE.md, Agent提示词）
```

**核心理念**：瓶颈不是模型能力，是如何让正确行为可重复。

---

## 10. 飞轮规模决策矩阵

| 任务复杂度 | Agent数 | 每Agent调用 | 验证层 | 最大轮次 |
|-----------|---------|------------|--------|---------|
| 简单 (lint fix) | 1 | 3-5 | L1 only | 1 |
| 中等 (bug fix) | 2-3 | 10-15 | L1+L2 | 3 |
| 复杂 (feature) | 4-5 | 15-20 | L1+L2+L3 | 5 |
| 高安全 (auth/crypto) | 6+ | 20+ | L1-L4 | 5+ |

## 参考

- [CodeX-Verify](https://arxiv.org/abs/2511.16708) — 4Agent并行验证，信息论证明
- [AgentForge](https://arxiv.org/abs/2604.13120) — 执行Grounded验证，Docker沙箱
- [ReVeal](https://arxiv.org/abs/2506.11442) — 迭代自进化，TAPO算法
- [BitsAI-CR](https://conf.researchr.org/details/fse-2025/fse-2025-industry-papers/24/) — 两阶段检测+验证
- [wow-harness](https://github.com/Chachamaru127/claude-code-harness) — 16Hook+8关状态机
- [Sellier](https://dev.to/tacoda/announcing-sellier-4489) — 四层harness架构
- [Anthropic Multi-Agent Harness](https://www.anthropic.com/engineering/building-c-compiler) — C编译器，16Agent并行
- [Datadog Harness-First](https://www.datadoghq.com/blog/ai/harness-first-agents/) — 验证金字塔
- [OpenAI Eval Flywheel](https://developers.openai.com/cookbook/examples/evaluation/building_resilient_prompts_using_an_evaluation_flywheel) — Analyze→Measure→Improve
- [self-improving-agents](https://addyosmani.com/blog/self-improving-agents/) — Addy Osmani综合分析
