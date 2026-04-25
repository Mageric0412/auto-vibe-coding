# 参考项目详解

## 项目对比表

| 项目 | Stars | Agent数 | 自测 | 验证循环 | 自动修复 | 架构特点 |
|------|-------|---------|------|----------|----------|----------|
| [RuFlo](https://github.com/ruvnet/ruflo) | 33k | 100+ | Yes | Yes | Yes | 企业级mesh |
| [Agent Orchestrator](https://github.com/ComposioHQ/agent-orchestrator) | 6.5k | 多 | Yes | CI反馈 | Yes | Git worktree |
| [Bug Hunter](https://github.com/codexstar69/bug-hunter) | 121 | 3 | Yes | 8-stage | Yes | Adversarial |
| [vibecosystem](https://github.com/vibeeval/vibecosystem) | 471 | 138 | Yes | Dev-QA | Partial | 自学习 |
| [AlphaSwarm.sol](https://github.com/alehdezp/alphaswarm-sol) | - | 24 | Yes | Yes | Planned | 知识图谱 |
| [promptfoo](https://github.com/promptfoo/promptfoo) | 20k | - | Yes | Yes | No | 测试框架 |
| [PentestAI](https://github.com/vxcontrol/pentagi) | 15.6k | 多 | Limited | Limited | Limited | 安全渗透 |

---

## 1. RuFlo (原 Claude Flow) - 企业级多Agent编排 ⭐⭐⭐⭐⭐

**GitHub**: https://github.com/ruvnet/ruflo
**Stars**: 33,203 | **Forks**: 3,759

### 核心特性

```
┌─────────────────────────────────────────────────────────────────────┐
│                         RuFlo Architecture                            │
│                                                                      │
│  User Input                                                          │
│      │                                                               │
│      ▼                                                               │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    RuFlo Core                                 │   │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐        │   │
│  │  │  Router │  │ Memory  │  │ Swarm   │  │ SONA    │        │   │
│  │  │         │  │ Manager │  │ Manager │  │ (优化)   │        │   │
│  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│      │                                                               │
│      ▼                                                               │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐             │
│  │ 100+    │  │ Vector  │  │ Consensus│  │  MCP    │             │
│  │ Agents  │  │ Store   │  │ Engine   │  │ Server  │             │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘             │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 关键组件

| 组件 | 功能 | 技术亮点 |
|------|------|----------|
| **SONA** | 自优化模式学习 | < 0.05ms 延迟 |
| **EWC++** | 弹性权重巩固 | 防止灾难性遗忘 |
| **HNSW** | 向量搜索 | 分层可导航小世界 |
| **Raft/BFT** | 共识引擎 | 容错一致性 |

### 拓扑支持

```python
TOPOLOGY_TYPES = {
    "mesh": "全连接，每个Agent与其他所有Agent通信",
    "hierarchical": "树状结构，父节点协调子节点",
    "ring": "环形通信，相邻节点交换信息",
    "star": "中心节点协调，外围节点执行"
}
```

### 适用场景
- ✅ 企业级大规模部署
- ✅ 需要容错和高可用
- ✅ 多团队协作环境

---

## 2. Agent Orchestrator - CI/CD 自愈 ⭐⭐⭐⭐

**GitHub**: https://github.com/ComposioHQ/agent-orchestrator
**Stars**: 6,494

### 核心特性

```
开发者提交 PR
      │
      ▼
┌─────────────────────────────────────────────────────────────┐
│                   ORCHESTRATOR                               │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  Worktree Manager (隔离 git worktree)                 │  │
│  │  每个 Issue/MR 分配独立工作目录                       │  │
│  └─────────────────────────────────────────────────────┘  │
│      │                                                      │
│      ▼                                                      │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐                    │
│  │ Claude  │  │ Codex   │  │ Aider   │  ← 多Agent并行     │
│  │ Code    │  │         │  │         │                    │
│  └─────────┘  └─────────┘  └─────────┘                    │
│      │                                                      │
│      ▼                                                      │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  Reactions Handler                                   │  │
│  │  • CI 失败 → 自动路由到 Agent                        │  │
│  │  • Review 评论 → 自动处理                           │  │
│  └─────────────────────────────────────────────────────┘  │
│      │                                                      │
│      ▼                                                      │
│  自动创建 PR → 人工审核                                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 关键创新

```yaml
隔离执行:
  每个任务在独立 git worktree 运行
  避免并行任务相互干扰

反应式触发:
  CI_failure → spawn fix_agent
  review_comment → route_to_agent
  rebase_needed → auto_rebase
```

### 适用场景
- ✅ GitLab/GitHub CI 集成
- ✅ 需要 PR 自动修复
- ✅ 隔离环境运行

---

## 3. Bug Hunter - Adversarial 三方辩论 ⭐⭐⭐⭐

**GitHub**: https://github.com/codexstar69/bug-hunter
**Stars**: 121

### 核心架构 - 三Agent辩论

```
┌─────────────────────────────────────────────────────────────────────┐
│                    BUG HUNTER 8-STAGE PIPELINE                       │
│                                                                      │
│  Stage 1: TRIAGE        ──▶ 风险分类 (<2s, 零AI成本)                 │
│  Stage 2: RECON         ──▶ 技术栈发现, 攻击面识别                   │
│  Stage 3: HUNTER        ──▶ 深度扫描: 逻辑错误, 安全漏洞            │
│  Stage 4: SKEPTIC ─┐     ──▶ 反驳: 尝试推翻 Hunter 的每个发现        │
│  Stage 5: REFEREE  │     ──▶ 裁判: 独立判决，确认/拒绝              │
│  Stage 6: FIX PLAN  │     ──▶ 修复计划: 优先级排序                   │
│  Stage 7: FIXER     ─┘     ──▶ 顺序修复 (专用 git 分支)            │
│  Stage 8: VERIFY         ──▶ 测试每个修复                                                   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Agent 评分系统

```python
SCORING = {
    "hunter": {
        "report_real_bug": +1,
        "false_positive": -1
    },
    "skeptic": {
        "disprove_false_positive": +1,
        "miss_real_bug": -2  # 双倍惩罚
    },
    "referee": {
        "accurate_verdict": +1,
        "blind_trust": -1
    }
}
```

### 安全分类

```yaml
Security Standards:
  - STRIDE: Spoofing, Tampering, Repudiation, Info Disclosure, DoS, Elevation
  - CWE: Common Weakness Enumeration
  - CVSS: Vulnerability severity scoring (0-10)
```

### 适用场景
- ✅ 安全敏感代码审计
- ✅ 需要严格验证
- ✅ 零容忍假阳性

---

## 4. vibecosystem - 138 Agent 自学习生态 ⭐⭐⭐⭐

**GitHub**: https://github.com/vibeeval/vibecosystem
**Stars**: 471

### 核心架构

```
Phase 1 (Discovery):     scout + architect + project-manager
Phase 2 (Development):  backend-dev + frontend-dev + devops + specialists
Phase 3 (Review):       code-reviewer + security-reviewer + qa-engineer
Phase 4 (QA Loop):      verifier + tdd-guide (max 3 retry → escalate)
Phase 5 (Final):       self-learner + technical-writer
```

### 自学习 Pipeline

```python
ERROR_LEARNING_PIPELINE = """
1. Error happens
       │
       ▼
2. Passive Learner captures:
   - Error pattern
   - Context (code, stack, user)
   - Frequency

3. Consolidator groups and counts:
   - Similar errors merged
   - Confidence calculated

4. If confidence >= 5:
   → Auto-inject into agent context

5. If 2+ projects, 5+ total occurrences:
   → Cross-project promotion

6. If 10x repeat:
   → Permanent .md rule file created
"""
```

### 关键数字

| 指标 | 数值 |
|------|------|
| Agent 数量 | 138 |
| Skills | 295 |
| Hooks | 73 |
| Dev-QA 重试上限 | 3 次 |

### 适用场景
- ✅ 需要跨项目学习
- ✅ 大规模自动化开发
- ✅ 持续优化的团队

---

## 5. AlphaSwarm.sol - 自测 Harness ⭐⭐⭐

**GitHub**: https://github.com/alehdezp/alphaswarm-sol

### 核心创新

```python
SELF_TESTING_HARNESS = """
目标: 验证 Agent 工作流本身的质量

Pipeline:
1. Run scenario
2. Capture transcript and tool events
3. Extract graph queries and evidence references
4. Score reasoning quality
5. Detect missing or fake evidence
6. Compare against expected behavior
7. Generate recommendations
"""
```

### 行为安全知识图谱 (BSKG)

```
证据链接的报告流程:
contract code
    → graph build
    → pattern candidates
    → task/bead creation
    → attacker investigation
    → defender challenge
    → verifier arbitration
    → evidence-linked report
    → transcript capture
    → reasoning evaluation
    → planning feedback
```

### 适用场景
- ✅ 智能合约审计
- ✅ 需要可解释的 AI 决策
- ✅ 研究级别的验证

---

## 6. promptfoo - LLM 测试框架 ⭐⭐⭐⭐⭐

**GitHub**: https://github.com/promptfoo
**Stars**: 20,549

### 核心功能

```yaml
Testing Capabilities:
  - Prompt 测试
  - Agent 测试
  - RAG 评估
  - Red teaming
  -  vulnerability scanning

Providers:
  - OpenAI
  - Anthropic (Claude)
  - Google (Gemini)
  - Local models
```

### 使用场景

```bash
# 基础测试
promptfoo eval --config promptfooconfig.yaml

# Red team
promptfoo redteam --config redteam.yaml

# Compare providers
promptfoo compare --models gpt-4 claude-3-opus
```

### 适用场景
- ✅ LLM 应用测试
- ✅ Red team 安全测试
- ✅ 多模型对比

---

## 7. claude-code-agent-hooks - 自我验证 ⭐⭐⭐

**GitHub**: https://github.com/abean23/claude-code-agent-hooks
**Stars**: 1

### 三层验证

```python
VALIDATION_LAYERS = [
    ("syntax", "语法检查"),
    ("schema", "JSON Schema 验证"),
    ("semantic", "语义验证")
]

DEFENSE_IN_DEPTH = """
防御纵深:
1. Syntax validation (即时)
2. Schema validation (快速)
3. Semantic validation (深度)

每层失败都有明确分类:
- Malformed IR → correction_attempted flag
- 防止无限循环掩盖真实 bug
"""
```

### 适用场景
- ✅ Claude Code 集成
- ✅ 简单任务验证
- ✅ Claude Code 自定义

---

## 推荐组合方案

### 方案 A: 小型项目 (个人/小团队)
```
Agent Orchestrator (主) + Bug Hunter (安全)
```

### 方案 B: 中型项目 (Startup)
```
RuFlo (编排) + Bug Hunter (验证) + vibecosystem (学习)
```

### 方案 C: 大型企业
```
RuFlo (核心) + promptfoo (测试) + 自定义 Security Agent
```

### 方案 D: 研究/安全
```
AlphaSwarm (知识图谱) + Bug Hunter (辩论) + promptfoo (测试)
```
