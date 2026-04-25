# Anthropic 最佳实践

## 核心原则

### 1. 并行化设计 (Parallelization)

Anthropic 内部多Agent研究系统的核心设计:

```
┌──────────────────────────────────────────────────────────────┐
│                    PARALLEL AGENT SPAWNING                   │
│                                                              │
│   Lead Agent receives task                                    │
│           │                                                  │
│           ▼                                                  │
│   ┌─────────────────────────────────────────────────────┐   │
│   │  Decision: How many SubAgents?                      │   │
│   │                                                      │   │
│   │  Simple task (1-3 complexity): 1 agent             │   │
│   │  Medium task (4-6 complexity): 3 agents             │   │
│   │  Complex task (7+ complexity): 5+ agents            │   │
│   └─────────────────────────────────────────────────────┘   │
│           │                                                  │
│           ▼                                                  │
│   ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐              │
│   │ SA1 │  │ SA2 │  │ SA3 │  │ SA4 │  │ SA5 │              │
│   │     │  │     │  │     │  │     │  │     │              │
│   └─────┘  └─────┘  └─────┘  └─────┘  └─────┘              │
│      │         │         │         │         │             │
│      └─────────┴─────────┴─────────┴─────────┘             │
│                           │                                  │
│                           ▼                                  │
│   ┌─────────────────────────────────────────────────────┐   │
│   │  INFORMATION COMPRESSION                            │   │
│   │  • SubAgent returns distilled key insights only     │   │
│   │  • Lead Agent aggregates and synthesizes            │   │
│   │  • Compression ratio: ~10:1                        │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### 2. 信息蒸馏压缩 (Compression)

SubAgent 返回策略:

```python
class SubAgentReturnStrategy:
    """
    SubAgent 应该只返回最关键的 tokens
    """

    def compress_return(self, full_context: dict) -> dict:
        return {
            # 关键发现 (最多 5 条)
            "key_findings": self.extract_top_n(
                full_context.get("findings", []),
                n=5,
                by="importance"
            ),

            # 决策摘要
            "decision_summary": self.summarize(
                full_context.get("reasoning", [])
            ),

            # 需要 Lead 关注的问题
            "issues_for_lead": full_context.get("blockers", []),

            # 置信度
            "confidence": full_context.get("confidence", 0.5),

            # 工具使用统计 (用于监控)
            "tool_usage": {
                "total_calls": full_context.get("tool_calls", 0),
                "within_budget": full_context.get("tool_calls", 0) < 20
            }
        }
```

### 3. 动态适应 (Dynamic Adaptation)

```python
class DynamicAgentManager:
    """
    根据中间结果动态调整 Agent 策略
    """

    def should_spawn_more_agents(self, current_results: dict) -> bool:
        """
        决策是否需要更多 Agent
        """
        progress = current_results.get("progress", 0)
        budget_used = current_results.get("budget_used", 0)

        # 如果进度不足且预算充足，考虑扩展
        if progress < 0.3 and budget_used < 0.5:
            # 检查是否有新的任务类型适合新 Agent
            if self.has_uncovered_areas():
                return True

        return False

    def should_adjust_strategy(self, results: dict) -> str:
        """
        调整策略
        """
        if results.get("false_positive_rate", 0) > 0.3:
            return "INCREASE_VERIFICATION"
        elif results.get("timeout_rate", 0) > 0.2:
            return "REDUCE_COMPLEXITY"
        elif results.get("miss_rate", 0) > 0.1:
            return "EXPAND_SEARCH"
        return "CONTINUE"
```

### 4. 假阳性过滤 (False Positive Filtering)

Claude Code Review 的核心设计:

```python
"""
假阳性过滤的核心原则:
1. 每个发现都必须经过"试图证伪"的步骤
2. 只有无法被推翻的发现才上报
3. 反馈循环: 工程师标记的误报用于优化模型
"""

class FalsePositiveFilter:
    def filter(self, findings: List[Finding]) -> List[Finding]:
        verified = []

        for finding in findings:
            # 1. 尝试证伪
            can_disprove = self.attempt_disproof(finding)

            # 2. 如果无法推翻，则确认
            if not can_disprove:
                confirmed = self.confirm_with_referee(finding)
                if confirmed:
                    verified.append(finding)
            # 3. 如果推翻了，记录为假阳性并反馈

        return verified

    def attempt_disproof(self, finding: Finding) -> bool:
        """
        尝试构造反例推翻发现
        """
        # 分析发现的上下文
        context = finding.get_context()

        # 尝试构造不触发问题的场景
        counter_examples = [
            self.try_safe_input(finding),        # 尝试安全输入
            self.try_existing_mitigation(finding), # 检查现有缓解
            self.try_edge_case(finding),          # 边界条件
        ]

        return any(counter_examples)
```

### 5. 规模规则嵌入 (Scaling Rules Embedded)

```python
SCALING_RULES = """
任务规模 → Agent 配置映射规则:

| 复杂度 | 代码量 | Agent数 | 工具调用限制 | 验证层级 |
|--------|--------|---------|--------------|----------|
| 1-3    | <100行 | 1       | 10           | 1-2      |
| 4-6    | 100-500| 3       | 15/Agent     | 2-3      |
| 7-9    | 500-2k | 5       | 20/Agent     | 3-4      |
| 10+    | >2k    | 10+     | 自适应       | 4-5      |

防止过度投资规则:
- 简单任务不允许启动多个 Agent
- 每个 Agent 有独立的 context budget
- 超出预算必须汇报并请求授权
"""
```

## Prompt 工程最佳实践

### 1. 先广后窄 (Broad-to-Narrow)

```python
TWO_PHASE_APPROACH = """
Phase 1: 探索 (Exploration)
---
使用简短查询探索全貌:

  "分析这个代码库的架构，识别主要组件和它们的关系。
   重点关注:
   - 模块划分
   - 数据流
   - 依赖关系"

Phase 2: 聚焦 (Focus)
---
基于 Phase 1 的发现，深入特定领域:

  "基于以上分析，深入分析用户认证模块。
   识别:
   - 认证流程
   - 潜在的安全漏洞
   - 建议的改进"
"""
```

### 2. 委托指导 (Delegation Guidance)

```python
DELEGATION_PROMPT = """
你是一个 Lead Agent，负责协调多个 SubAgent。

给 SubAgent 的任务描述必须包含:

1. 任务目标 (Goal)
   "分析代码库中的错误处理模式"

2. 输出格式 (Output Format)
   "返回 JSON 格式:
   {
     'patterns': [...],
     'issues': [...],
     'recommendations': [...]
   }"

3. 工具指南 (Tool Guidelines)
   "使用 search_code 搜索 'try/catch' 模式，
   使用 read_file 读取关键文件"

4. 明确边界 (Clear Boundaries)
   "只分析 error handling，不要涉及性能优化"
"""
```

### 3. 让 Agent 改进自己 (Self-Improvement)

Anthropic 发现 Claude 4 可以诊断并重写提示词:

```python
SELF_IMPROVEMENT_LOOP = """
给定失败模式，Agent 可以:

1. 诊断问题
   "分析上次失败的原因:
   - 是提示词不清晰？
   - 是上下文不足？
   - 是工具配置错误？"

2. 生成改进建议
   "建议修改:
   - 添加具体例子
   - 增加输出格式约束
   - 明确边界条件"

3. 验证改进
   "用改进后的提示词重新执行，对比结果"
"""
```

### 4. 扩展思考模式 (Extended Thinking)

```python
EXTENDED_THINKING_PROMPT = """
在执行复杂任务时，使用 scratchpad 记录推理过程:

<s scratchpad>
当前状态: 正在分析 X 模块
已发现: A, B
假设: C 可能导致 D
下一步: 验证假设 C → D
风险: 可能在 E 方面有误判
</s>

这样可以:
1. 控制推理过程
2. 在上下文不足时回退
3. 追踪决策路径
4. 便于审计和优化
"""
```

## Claude Code Review 架构

```
┌──────────────────────────────────────────────────────────────────────┐
│                    CLAUDE CODE REVIEW SYSTEM                          │
│                                                                      │
│   PR Submitted                                                        │
│       │                                                                │
│       ▼                                                                │
│   ┌────────────────────────────────────────────────────────────┐      │
│   │                    INDEXING PHASE                          │      │
│   │  • Clone repo                                              │      │
│   │  • Build full codebase context                             │      │
│   │  • Identify changed files                                   │      │
│   │  • Load related code (imports, tests, callers)            │      │
│   └────────────────────────────────────────────────────────────┘      │
│       │                                                                │
│       ▼                                                                │
│   ┌────────────────────────────────────────────────────────────┐      │
│   │               MULTI-AGENT PARALLEL REVIEW                   │      │
│   │                                                             │      │
│   │   ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐    │      │
│   │   │Security │  │ Logic   │  │Performance│ │ Style   │    │      │
│   │   │Reviewer │  │Reviewer │  │ Reviewer  │ │Reviewer │    │      │
│   │   └─────────┘  └─────────┘  └─────────┘  └─────────┘    │      │
│   │                                                             │      │
│   │   Each reviewer has full codebase context                  │      │
│   │   Reviews in parallel, no interference                     │      │
│   └────────────────────────────────────────────────────────────┘      │
│       │                                                                │
│       ▼                                                                │
│   ┌────────────────────────────────────────────────────────────┐      │
│   │                  VERIFICATION GATE                          │      │
│   │  • False positive filtering                                 │      │
│   │  • Attempts to disprove each finding                        │      │
│   │  • Only confirmed findings reported                         │      │
│   └────────────────────────────────────────────────────────────┘      │
│       │                                                                │
│       ▼                                                                │
│   ┌────────────────────────────────────────────────────────────┐      │
│   │                    REPORTING                                 │      │
│   │  • Group findings by severity                               │      │
│   │  • Link to relevant code                                    │      │
│   │  • Provide actionable fix suggestions                       │      │
│   └────────────────────────────────────────────────────────────┘      │
│       │                                                                │
│       ▼                                                                │
│   Engineer Reviews & Labels Findings                                 │
│       │                                                                │
│       ▼                                                                │
│   Feedback Loop → Model Improvement                                   │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### 关键数据点

| 指标 | 数值 |
|------|------|
| 工程师标记错误率 | < 1% |
| 大 PR (>1000行) 发现率 | 84% |
| 平均问题数/PR | 7.5 |
| 覆盖维度 | 安全、逻辑、性能、风格 |

## 自我改进机制

```python
class SelfImprovementEngine:
    """
    Agent 自我诊断和优化
    """

    def diagnose_failure(self, task: str, result: dict) -> Diagnosis:
        """
        分析失败原因
        """
        if result.get("timeout"):
            return Diagnosis(
                cause="budget_exceeded",
                suggestion="reduce_scope or increase_budget"
            )

        if result.get("false_positive_high"):
            return Diagnosis(
                cause="verification_insufficient",
                suggestion="add_adversarial_challenge_layer"
            )

        if result.get("miss_rate_high"):
            return Diagnosis(
                cause="context_narrow",
                suggestion="expand_search_space"
            )

    def rewrite_prompt(self, original_prompt: str, diagnosis: Diagnosis) -> str:
        """
        基于诊断重写提示词
        """
        # 根据诊断结果调整
        if "context_narrow" in diagnosis.cause:
            return original_prompt + "\n\n[IMPORTANT] Broaden your search..."

        if "verification_insufficient" in diagnosis.cause:
            return original_prompt + "\n\n[IMPORTANT] Verify each claim..."

        return original_prompt
```

## 决策清单

```markdown
## Multi-Agent 系统设计检查清单

### 启动前检查
- [ ] 任务复杂度评估完成
- [ ] Agent 数量已确定
- [ ] Context budget 已分配
- [ ] 工具集已配置

### 执行中监控
- [ ] SubAgent 信息蒸馏正常
- [ ] 无上下文溢出
- [ ] 假阳性率监控中
- [ ] 动态调整机制就绪

### 完成后复盘
- [ ] 验证通过率统计
- [ ] 假阳性反馈已收集
- [ ] 性能瓶颈识别
- [ ] 优化建议生成
```
