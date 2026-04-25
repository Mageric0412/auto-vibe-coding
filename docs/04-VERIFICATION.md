# 验证策略详解

## 验证层级架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                    VERIFICATION PYRAMID                              │
│                                                                     │
│                         ┌─────────┐                                │
│                        /   Layer 5  \     Human Review Gate         │
│                       /─────────────\                               │
│                      /   Layer 4     \    Adversarial Challenge    │
│                     /─────────────────\                              │
│                    /    Layer 3        \   Semantic & Logic Check   │
│                   /─────────────────────\                           │
│                  /      Layer 2           \  Integration Tests     │
│                 /───────────────────────────\                      │
│                /         Layer 1             \ Quick Validation    │
│               /─────────────────────────────────\                  │
│                                                                     │
│              Speed: Fast ────────────────────────▶ Slow             │
│              Cost: Low ─────────────────────────▶ High              │
│              Coverage: Narrow ──────────────────▶ Wide              │
└─────────────────────────────────────────────────────────────────────┘
```

## Layer 1: 即时验证 (1-5秒)

### 1.1 语法验证
```python
class SyntaxValidator:
    """静态语法检查，无需运行"""

    def validate(self, code: str, language: str) -> ValidationResult:
        if language == "python":
            return self.validate_python_syntax(code)
        elif language == "javascript":
            return self.validate_js_syntax(code)
        # ...

        return ValidationResult(
            passed=True,
            errors=[],
            execution_time_ms=100
        )
```

### 1.2 Schema 验证
```python
class SchemaValidator:
    """结构化输出验证"""

    def validate(self, output: dict, schema: dict) -> ValidationResult:
        # JSON Schema 验证
        # Type checking
        # Required fields presence
        pass
```

## Layer 2: 快速测试 (30秒-2分钟)

### 2.1 单元测试
```bash
# 快速运行变更文件的测试
pytest tests/unit/$(changed_files) -v --tb=short

# 覆盖率检查
pytest --cov=src --cov-report=term-missing
```

### 2.2 集成测试
```python
# 增量集成测试
class IntegrationTestRunner:
    def run_incremental(self, changed_modules: List[str]) -> TestResult:
        # 只测试受影响的模块
        # 隔离外部依赖 (mock)
        # 快速失败策略
```

### 2.3 Lint & Format
```yaml
# .github/verify-lint.yml
lint:
  - name: formatting
    tool: prettier/black
    fail_fast: true

  - name: style
    tool: eslint/pylint
    fail_fast: true

  - name: security
    tool: semgrep
    fail_fast: true
```

## Layer 3: 深度验证 (5-15分钟)

### 3.1 语义分析
```python
class SemanticAnalyzer:
    """
    检查代码逻辑层面的问题:
    - 空指针引用
    - 资源泄漏
    - 竞态条件
    - 逻辑错误
    """

    def analyze(self, code: str) -> List[Finding]:
        findings = []

        # 控制流分析
        findings.extend(self.check_control_flow(code))

        # 数据流分析
        findings.extend(self.check_data_flow(code))

        # 上下文敏感分析
        findings.extend(self.check_context_sensitive(code))

        return findings
```

### 3.2 模糊测试 (Fuzz Testing)
```python
class FuzzTester:
    """
    使用随机输入探测边界条件
    """

    def fuzz(self, target_function, iterations=1000) -> FuzzResult:
        crash_inputs = []

        for i in range(iterations):
            # 生成随机输入
            input_data = self.generate_random_input(target_function)

            # 执行并监控
            try:
                result = target_function(input_data)
            except Exception as e:
                crash_inputs.append({
                    "input": input_data,
                    "exception": str(e)
                })

        return FuzzResult(crashes=crash_inputs)
```

### 3.3 突变测试 (Mutation Testing)
```python
# 验证测试质量
# 随机引入bug，看测试能否发现

mutant_score = (
    mutants_killed / total_mutants
)  # > 0.8 为好

# Jabbt/Jester 等工具
```

## Layer 4: Adversarial 验证 (15-30分钟)

### 4.1 三Agent辩论机制 (Bug Hunter 模式)

```
┌─────────────────────────────────────────────────────────────┐
│              ADVERSARIAL VERIFICATION FLOW                  │
│                                                             │
│  Step 1: HUNTER REPORTS                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Hunter Agent:                                        │   │
│  │ "这段代码存在 SQL 注入漏洞"                           │   │
│  │ Evidence:                                            │   │
│  │   - Line 42: user_input directly in query           │   │
│  │   - No parameterized query                           │   │
│  │   - Attack vector: ' OR 1=1 --                       │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│                          ▼                                  │
│  Step 2: SKEPTIC CHALLENGES                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Skeptic Agent:                                       │   │
│  │ "让我尝试推翻这个发现..."                             │   │
│  │                                                       │   │
│  │ Attempt 1: user_input 经过 sanitize() 处理?         │   │
│  │ Result: YES - 有 sanitize() 函数                     │   │
│  │                                                       │   │
│  │ Attempt 2: sanitize() 是否正确实现?                  │   │
│  │ Result: 查看实现... 参数化查询存在                   │   │
│  │                                                       │   │
│  │ Conclusion: 无法推翻，bug 确认                       │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│                          ▼                                  │
│  Step 3: REFEREE DECIDES                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Referee Agent:                                       │   │
│  │ Final Verdict: CONFIRMED                             │   │
│  │ Severity: HIGH (CVSS 7.5)                           │   │
│  │ Recommended Fix: 使用 ORM 层                         │   │
│  │ CWE: CWE-89 (SQL Injection)                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 评分系统

```python
class AgentScoreTracker:
    """
    追踪各 Agent 表现，用于持续优化
    """

    def record(self, agent: str, action: str, outcome: str):
        """
        Agent 类型: Hunter, Skeptic, Referee
        Action: report, challenge, verdict
        Outcome: true_positive, false_positive, true_negative, miss
        """

        if agent == "hunter":
            if outcome == "true_positive":
                self.hunter_score += 1
            elif outcome == "false_positive":
                self.hunter_score -= 1

        elif agent == "skeptic":
            if outcome == "disproved":
                self.skeptic_score += 1
            elif outcome == "missed_real_bug":
                self.skeptic_score -= 2  # 双倍惩罚

        elif agent == "referee":
            if outcome == "accurate":
                self.referee_score += 1

    def get_trust_weights(self) -> Dict[str, float]:
        """基于历史表现调整权重"""
        total = sum([
            self.hunter_score,
            self.skeptic_score,
            self.referee_score
        ])

        return {
            "hunter": self.hunter_score / total,
            "skeptic": self.skeptic_score / total,
            "referee": self.referee_score / total
        }
```

## Layer 5: Human Review Gate

### 5.1 自动分流
```python
def should_escalate_to_human(verification_result: VerificationResult) -> bool:
    """
    根据风险等级决定是否需要人工介入
    """

    # 自动修复低风险问题
    if verification_result.risk_level <= RiskLevel.LOW:
        return False

    # 高风险必须人工审批
    if verification_result.risk_level >= RiskLevel.HIGH:
        return True

    # 中风险：检查置信度
    if verification_result.confidence < 0.8:
        return True

    return False
```

### 5.2 审批工作流
```
┌─────────────────────────────────────────────────────────┐
│              HUMAN REVIEW WORKFLOW                       │
│                                                         │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐           │
│  │  Auto     │   │ Pending  │   │ Approved │           │
│  │  Fix OK  │──▶│  Review  │──▶│ & Merged │           │
│  └──────────┘   └──────────┘   └──────────┘           │
│                      │                                  │
│                      │ Rejected                         │
│                      ▼                                  │
│                 ┌──────────┐                          │
│                 │  Return  │                          │
│                 │  to Fix  │                          │
│                 └──────────┘                          │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## 假阳性过滤机制

### 核心原则 (Claude Code Review)

> "每个 Bug 发现都必须经过试图证伪的步骤。
> 只有无法被推翻的发现才会上报。"

### 假阳性类型及应对

| 类型 | 示例 | 过滤策略 |
|------|------|----------|
| 误报 | 标记了"可能"的问题但实际不会发生 | Skeptic 尝试构造反例 |
| 夸张 | 低风险问题被描述为严重 | Referee 重新评估 |
| 重复 | 同一问题被多次报告 | 去重合并 |
| 无关 | 与代码变更无关的发现 | 上下文过滤 |
| 陈旧 | 问题已在之前修复 | 与主分支对比 |

### 验证循环伪代码

```python
def verification_loop(code_change: CodeChange, max_iterations: int = 3):
    findings = []
    iteration = 0

    while iteration < max_iterations:
        # 1. 生成发现
        hunter_report = hunter.analyze(code_change)
        findings.extend(hunter_report.findings)

        # 2. 挑战每个发现
        verified_findings = []
        for finding in findings:
            challenge_result = skeptic.attempt_disprove(finding)

            if not challenge_result.overturned:
                # 3. 无法推翻，提交给 Referee
                verdict = referee.judge(finding)
                if verdict.confirmed:
                    verified_findings.append(finding)

        # 4. 如果有确认的 bug，尝试修复
        if verified_findings:
            fix_result = fixer.apply_fixes(verified_findings)

            if fix_result.success:
                # 5. 验证修复
                if verifier.confirms_fix(verified_findings):
                    break  # 退出循环
            else:
                # 修复失败，需要人工介入
                escalate_to_human(verified_findings)
                break

        iteration += 1

    return verified_findings
```

## 验证指标

```yaml
verification_metrics:
  # 速度指标
  speed:
    layer1_validation: < 5s
    layer2_unit_tests: < 60s
    layer3_deep_analysis: < 10m
    layer4_adversarial: < 30m

  # 质量指标
  quality:
    false_positive_rate: < 5%
    bug_catch_rate: > 90%
    coverage_increase: > 10%

  # 效率指标
  efficiency:
    auto_fix_rate: > 70%
    human_escalation_rate: < 20%
    mean_time_to_fix: < 30m
```
