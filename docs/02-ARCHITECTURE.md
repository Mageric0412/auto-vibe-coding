# 架构设计 - Multi-Agent Flywheel System

## 整体架构图

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                           FLYWHEEL CONTROL PLANE                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   Router    │  │  Context    │  │   Memory    │  │   Config    │        │
│  │   Manager   │  │   Manager   │  │   Store     │  │   Store     │        │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │
└──────────────────────────────────────────────────────────────────────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        ▼                           ▼                           ▼
┌───────────────┐           ┌───────────────┐           ┌───────────────┐
│   RESEARCH    │           │   EXECUTION   │           │   VERIFICATION│
│   PHASE       │           │   PHASE       │           │   PHASE       │
│               │           │               │           │               │
│ ┌───────────┐ │           │ ┌───────────┐ │           │ ┌───────────┐ │
│ │  Scout    │ │           │ │   Dev     │ │           │ │  QA       │ │
│ │  Agent    │ │           │ │  Agent    │ │           │ │  Agent    │ │
│ └───────────┘ │           │ └───────────┘ │           │ └───────────┘ │
│ ┌───────────┐ │           │ ┌───────────┐ │           │ ┌───────────┐ │
│ │ Architect │ │           │ │  Dev      │ │           │ │ Verifier  │ │
│ │  Agent    │ │           │ │  Agent 2  │ │           │ │  Agent    │ │
│ └───────────┘ │           │ └───────────┐ │           │ └───────────┘ │
│ ┌───────────┐ │           │ ┌───────────┐ │           │ ┌───────────┐ │
│ │  PM       │ │           │ │  Dev      │ │           │ │ Fixer     │ │
│ │  Agent    │ │           │ │  Agent N  │ │           │ │  Agent    │ │
│ └───────────┘ │           │ └───────────┘ │           │ └───────────┘ │
└───────────────┘           └───────────────┘           └───────────────┘
        │                           │                           │
        └───────────────────────────┼───────────────────────────┘
                                    ▼
                    ┌───────────────────────────────┐
                    │      LEARNER & OPTIMIZER       │
                    │  ┌─────────┐  ┌─────────────┐ │
                    │  │ Pattern │  │   Vector    │ │
                    │  │ Miner   │  │   Store     │ │
                    │  └─────────┘  └─────────────┘ │
                    └───────────────────────────────┘
```

## 核心模块详解

### 1. Flywheel Control Plane

#### Router Manager
```python
# 任务路由决策
class RouterManager:
    def route(self, task: Task) -> AgentConfig:
        complexity = self.assess_complexity(task)
        if complexity < 3:
            return AgentConfig(agents=1, tools=10)
        elif complexity < 7:
            return AgentConfig(agents=3, tools=15)
        else:
            return AgentConfig(agents=5, tools=25)
```

#### Context Manager
- **上下文窗口管理**: SubAgent 压缩返回信息
- **意图追踪**: 维护多轮对话状态
- **上下文注入**: 动态注入相关知识

#### Memory Store
```
┌─────────────────────────────────────────┐
│           MEMORY HIERARCHY              │
├─────────────────────────────────────────┤
│  Working Memory (当前任务)              │
│  └─ 最近 20 个 Agent 交互               │
├─────────────────────────────────────────┤
│  Session Memory (本次运行)              │
│  └─ 任务历史、决策轨迹、发现汇总        │
├─────────────────────────────────────────┤
│  Long-term Memory (持久化)              │
│  └─ 成功模式、失败案例、最佳实践        │
└─────────────────────────────────────────┘
```

### 2. Research Phase

```
Task Input
    │
    ▼
┌─────────────────────────────────────────┐
│           SCOUT AGENT                    │
│  • 问题空间探索                         │
│  • 关键技术识别                         │
│  • 相关案例收集                         │
│  • RAG 检索 (向量 + BM25)              │
└─────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────┐
│           ARCHITECT AGENT                │
│  • 系统设计评审                         │
│  • 技术选型决策                         │
│  • 风险识别                             │
│  • 实施计划生成                         │
└─────────────────────────────────────────┘
    │
    ▼
    └──── Parallel ────┐
         ┌─────────────┼─────────────┐
         ▼             ▼             ▼
   ┌──────────┐  ┌──────────┐  ┌──────────┐
   │ SubDev 1 │  │ SubDev 2 │  │ SubDev N │
   │ (Backend)│  │(Frontend) │  │ (DevOps) │
   └──────────┘  └──────────┘  └──────────┘
```

### 3. Execution Phase

#### Dev Agent 并行策略
```yaml
# configs/agent-config.yaml
dev_agents:
  parallelism: 3          # 并行数量
  max_per_agent: 20       # 每个Agent最大工具调用
  context_budget: 15k     # SubAgent context 限制

  retry_policy:
    max_attempts: 3
    backoff: exponential
    circuit_breaker: 5    # 连续失败后熔断
```

#### 任务分配策略
```
UCB1 (Upper Confidence Bound) 用于 Agent 选择:
  score = avg_success_rate + sqrt(2 * ln(total_attempts) / agent_attempts)

每次选择得分最高的 Agent
```

### 4. Verification Phase

#### 多层验证架构
```python
verification_pipeline = [
    # Layer 1: 即时
    ("syntax", SyntaxValidator, "1s"),
    ("schema", SchemaValidator, "2s"),

    # Layer 2: 快速测试
    ("unit", UnitTestRunner, "30s"),
    ("integration", IntegrationTestRunner, "2m"),

    # Layer 3: 深度验证
    ("semantic", SemanticAnalyzer, "5m"),
    ("fuzz", FuzzTester, "10m"),

    # Layer 4: Adversarial
    ("adversarial", AdversarialChallenger, "15m"),
]
```

#### Adversarial Challenge 流程 (Bug Hunter 模式)
```
┌──────────────────────────────────────────────────────────┐
│              ADVERSARIAL VERIFICATION LOOP               │
│                                                          │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐              │
│  │ Hunter  │───▶│ Skeptic │───▶│ Referee │              │
│  │ Agent   │    │ Agent   │    │ Agent   │              │
│  └─────────┘    └─────────┘    └─────────┘              │
│      │              │              │                     │
│      │  Report Bug  │  Disprove?   │  Final Verdict      │
│      ▼              ▼              ▼                     │
│  [Finding] ────▶ [Challenge] ───▶ [Confirmed/Rejected]   │
│                                                          │
│  Scoring:                                                 │
│  • Hunter: +1 for real bugs, -1 for false positives      │
│  • Skeptic: +1 for disproving, -2 for missing real bugs │
│  • Referee: +1 for accurate verdict                     │
└──────────────────────────────────────────────────────────┘
```

### 5. Learner & Optimizer

#### 模式学习 Pipeline (vibecosystem 模式)
```
Error happens
    │
    ▼
┌─────────────────────────────────────────┐
│        PASSIVE LEARNER                  │
│   • 捕获错误模式                         │
│   • 记录上下文                           │
│   • 统计频率                            │
└─────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────┐
│        CONSOLIDATOR                     │
│   • 分组计数                            │
│   • 相似模式合并                        │
│   • 置信度计算                          │
└─────────────────────────────────────────┘
    │
    ▼ confidence >= 5
┌─────────────────────────────────────────┐
│        AUTO-INJECT                      │
│   • 注入到相关Agent上下文               │
│   • 触发阈值: 2+项目, 5+总次数          │
└─────────────────────────────────────────┘
    │
    ▼ 10x repeat
┌─────────────────────────────────────────┐
│        PERMANENT RULE                   │
│   • 创建 .md 规则文件                   │
│   • 跨项目推广                          │
└─────────────────────────────────────────┘
```

## 数据流

```
┌─────────────────────────────────────────────────────────────────────┐
│                         DATA FLOW                                    │
│                                                                      │
│  User Input                                                         │
│      │                                                               │
│      ▼                                                               │
│  ┌─────────────────┐                                                │
│  │  Task Parser    │──▶ Intent + Entities                           │
│  └─────────────────┘                                                │
│          │                                                           │
│          ▼                                                           │
│  ┌─────────────────┐     ┌─────────────────┐                        │
│  │  Context Loader │◀───▶│  Vector Store   │ (RAG)                  │
│  └─────────────────┘     └─────────────────┘                        │
│          │                                                           │
│          ▼                                                           │
│  ┌─────────────────┐                                                │
│  │  Agent Router   │──▶ 分配 Agent                                  │
│  └─────────────────┘                                                │
│          │                                                           │
│          ▼                                                           │
│  ┌─────────────────────────────────────────┐                        │
│  │         Agent Execution Loop            │                        │
│  │  ┌─────┐   ┌─────┐   ┌─────┐           │                        │
│  │  │Action│──▶│Observation│──▶│思考│           │                        │
│  │  └─────┘   └─────┘   └─────┘           │                        │
│  └─────────────────────────────────────────┘                        │
│          │                                                           │
│          ▼                                                           │
│  ┌─────────────────┐     ┌─────────────────┐                        │
│  │  Verifier       │◀───▶│  Test Suite      │                        │
│  └─────────────────┘     └─────────────────┘                        │
│          │                                                           │
│          ▼                                                           │
│  ┌─────────────────┐     ┌─────────────────┐                        │
│  │  Fixer (if bug) │───▶│  Git Commit     │                        │
│  └─────────────────┘     └─────────────────┘                        │
│          │                                                           │
│          ▼                                                           │
│  ┌─────────────────┐     ┌─────────────────┐                        │
│  │  Memory Writer  │───▶│  Pattern Store  │                        │
│  └─────────────────┘     └─────────────────┘                        │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## 技术栈建议

| 层级 | 技术选型 | 备选 |
|------|----------|------|
| Agent 框架 | LangGraph | AutoGen, CrewAI |
| LLM | Claude 3.5+ | GPT-4o, Gemini |
| 向量存储 | ChromaDB | Qdrant, Pinecone |
| Git 操作 | GitPython | dulwich |
| 测试运行 | pytest | jest, go test |
| 代码分析 | Tree-sitter | AST |
| 监控 | LangSmith | Weights & Biases |

## 配置示例

```yaml
# configs/flywheel-config.yaml
flywheel:
  name: auto-vibe-coding
  version: 1.0

agents:
  max_parallel: 5
  timeout_per_agent: 300  # seconds
  context_budget_per_agent: 15000  # tokens

verification:
  layers:
    - name: syntax
      timeout: 5
      fail_fast: true
    - name: unit_test
      timeout: 60
      fail_fast: true
    - name: integration_test
      timeout: 180
      fail_fast: false
    - name: adversarial
      timeout: 300
      fail_fast: false

flywheel:
  max_iterations: 10
  convergence_threshold: 0.95
  self_healing: true

learning:
  auto_inject_threshold: 5
  cross_project_promotion: 2  # projects
  permanent_rule_threshold: 10
```

## 故障处理

| 故障场景 | 处理策略 |
|----------|----------|
| Agent 超时 | 熔断 + 重试 (指数退避) |
| 测试失败 | 自动定位 + Fixer Agent |
| 循环依赖 | 图分析 + 拓扑排序 |
| 假阳性泛滥 | 强制 adversarial 验证 |
| 上下文溢出 | 压缩 + 摘要返回 |
