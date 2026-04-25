# 实施路线图

## 阶段规划

```
┌─────────────────────────────────────────────────────────────────────┐
│                    IMPLEMENTATION ROADMAP                            │
│                                                                      │
│  Phase 1: Foundation (Week 1-2)                                     │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │ • 项目结构搭建                                                   │ │
│  │ • 核心 Agent 框架选型 (LangGraph)                                │ │
│  │ • 基础验证层实现 (Layer 1-2)                                     │ │
│  │ • Memory 存储设计                                                │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  Phase 2: Core Loop (Week 3-4)                                      │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │ • Scout → Dev → QA 流程打通                                     │ │
│  │ • Layer 3 深度验证                                               │ │
│  │ • 假阳性过滤基础实现                                             │ │
│  │ • CI/CD 集成                                                    │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  Phase 3: Intelligence (Week 5-6)                                   │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │ • Adversarial 验证 (Layer 4)                                    │ │
│  │ • 自学习 Pipeline                                               │ │
│  │ • 模式识别和自动注入                                             │ │
│  │ • 向量存储集成                                                   │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  Phase 4: Production (Week 7-8)                                      │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │ • 自动修复闭环                                                   │ │
│  │ • Human Review Gate                                             │ │
│  │ • 监控和告警                                                     │ │
│  │ • 性能优化和规模化                                               │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Phase 1: Foundation (Week 1-2)

### Day 1-3: 项目初始化

```bash
# 创建项目结构
mkdir -p auto-vibe-coding/{src,tests,configs,docs,scripts}
cd auto-vibe-coding

# 初始化 Python 项目
poetry init --name auto-vibe-coding
poetry add langgraph anthropic pydantic chromadb

# 目录结构
auto-vibe-coding/
├── src/
│   ├── __init__.py
│   ├── agents/          # Agent 定义
│   │   ├── base.py
│   │   ├── scout.py
│   │   ├── architect.py
│   │   ├── dev.py
│   │   ├── qa.py
│   │   ├── verifier.py
│   │   └── fixer.py
│   ├── core/           # 核心框架
│   │   ├── router.py
│   │   ├── context.py
│   │   ├── memory.py
│   │   └── flywheel.py
│   ├── verification/   # 验证层
│   │   ├── syntax.py
│   │   ├── unit_test.py
│   │   ├── semantic.py
│   │   └── adversarial.py
│   └── utils/
├── configs/
│   └── flywheel-config.yaml
├── tests/
├── scripts/
└── docs/
```

### Day 4-7: 核心框架

```python
# src/core/flywheel.py - 核心飞轮
from typing import List, Optional
from langgraph import StateGraph

class FlywheelState:
    """飞轮状态"""
    task: str
    phase: str  # research, execution, verification
    findings: List[dict]
    iterations: int

class FlywheelEngine:
    """
    飞轮引擎:
    1. 接收任务
    2. 分配 Agent
    3. 收集结果
    4. 验证
    5. 迭代直到收敛
    """

    def run(self, task: str, max_iterations: int = 10):
        state = FlywheelState(task=task, phase="research", iterations=0)

        while state.iterations < max_iterations:
            # Research Phase
            if state.phase == "research":
                state = self.research_phase(state)

            # Execution Phase
            elif state.phase == "execution":
                state = self.execution_phase(state)

            # Verification Phase
            elif state.phase == "verification":
                state = self.verification_phase(state)

            # 检查是否收敛
            if self.is_converged(state):
                break

        return state
```

### Day 8-14: 验证层实现

```python
# src/verification/layer1_syntax.py
class SyntaxValidator:
    def validate(self, code: str, language: str) -> ValidationResult:
        if language == "python":
            import ast
            try:
                ast.parse(code)
                return ValidationResult(passed=True)
            except SyntaxError as e:
                return ValidationResult(passed=False, errors=[str(e)])

# src/verification/layer2_unit.py
class UnitTestRunner:
    def run(self, changed_files: List[str]) -> TestResult:
        # 使用 pytest 运行测试
        result = subprocess.run([
            "pytest", *changed_files, "-v", "--tb=short"
        ], capture_output=True)
        return TestResult.from_pytest_result(result)
```

## Phase 2: Core Loop (Week 3-4)

### Week 3: 流程打通

```python
# src/core/router.py - 任务路由
class TaskRouter:
    def route(self, task: str) -> RouterDecision:
        complexity = self.assess_complexity(task)

        if complexity <= 3:
            return RouterDecision(
                agents=["dev"],
                max_tools=10,
                verification_layers=["syntax", "unit"]
            )
        elif complexity <= 6:
            return RouterDecision(
                agents=["scout", "dev", "qa"],
                max_tools=15,
                verification_layers=["syntax", "unit", "semantic"]
            )
        else:
            return RouterDecision(
                agents=["scout", "architect", "dev1", "dev2", "qa", "verifier"],
                max_tools=20,
                verification_layers=["syntax", "unit", "semantic", "adversarial"]
            )

    def assess_complexity(self, task: str) -> int:
        # 简单启发式评估
        indicators = [
            len(task.split()),  # 任务描述长度
            len(re.findall(r'\w+\.\w+', task)),  # 技术术语
            len(re.findall(r'\d+', task)),  # 数字提及
        ]
        return min(10, sum(indicators) // 3)
```

### Week 4: CI/CD 集成

```yaml
# .github/workflows/flywheel-ci.yml
name: Auto Vibe Coding CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  flywheel:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run Flywheel
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          ./scripts/run-flywheel.sh --task "Review PR ${{ github.event.pull_request.number }}"

      - name: Auto Fix
        if: failure()
        run: |
          ./scripts/auto-fix.sh

      - name: Create PR
        if: success()
        run: |
          gh pr create --title "Auto Fix: ${{ github.event.pull_request.title }}"
```

## Phase 3: Intelligence (Week 5-6)

### Week 5: Adversarial 验证

```python
# src/verification/adversarial.py
class AdversarialVerifier:
    """
    三 Agent 对抗验证:
    1. Hunter: 报告 bug
    2. Skeptic: 尝试推翻
    3. Referee: 最终判决
    """

    def verify(self, findings: List[Finding]) -> VerifiedFindings:
        verified = []

        for finding in findings:
            # Skeptic 尝试推翻
            if self.skeptic.attempt_disprove(finding):
                continue  # 被推翻，跳过

            # Referee 判决
            if self.referee.confirm(finding):
                verified.append(finding)

        return VerifiedFindings(confirmed=verified)
```

### Week 6: 自学习 Pipeline

```python
# src/core/learner.py
class PatternLearner:
    """
    从执行历史中学习模式
    """

    def learn_from_error(self, error: Error, context: dict):
        # 1. Passive capture
        pattern = self.extract_pattern(error, context)

        # 2. Consolidate
        confidence = self.calculate_confidence(pattern)

        # 3. Auto-inject if confident enough
        if confidence >= 5:
            self.inject_into_context(pattern)

        # 4. Promote if cross-project
        if pattern.project_count >= 2 and pattern.total_occurrences >= 5:
            self.promote_cross_project(pattern)

        # 5. Permanent rule if frequent
        if pattern.total_occurrences >= 10:
            self.create_permanent_rule(pattern)
```

## Phase 4: Production (Week 7-8)

### Week 7: 自动修复闭环

```python
# src/agents/fixer.py
class FixerAgent:
    """
    自动修复流程:
    1. 分析根因
    2. 设计修复方案
    3. 应用修复
    4. 验证修复
    5. 提交 Git
    """

    def fix_and_commit(self, verified_bug: Bug) -> FixResult:
        # 创建修复分支
        branch_name = f"fix/{verified_bug.id}"

        # 应用最小化修改
        self.apply_fix(verified_bug)

        # 验证修复有效
        if not self.verify_fix(verified_bug):
            return FixResult(success=False, reason="verification_failed")

        # Git 提交
        self.git.commit(message=f"Fix: {verified_bug.description}")

        return FixResult(success=True, branch=branch_name)
```

### Week 8: 监控与优化

```python
# src/core/metrics.py
class FlywheelMetrics:
    """
    监控指标收集
    """

    metrics = {
        # 速度
        "avg_iteration_time": Gauge("flywheel_iteration_seconds"),
        "verification_layer_time": Histogram("verification_layer_seconds"),

        # 质量
        "false_positive_rate": Gauge("flywheel_fp_rate"),
        "bug_catch_rate": Gauge("flywheel_catch_rate"),
        "auto_fix_success_rate": Gauge("flywheel_fix_success"),

        # 效率
        "auto_fix_rate": Gauge("flywheel_auto_fix_rate"),
        "human_escalation_rate": Gauge("flywheel_human_rate"),
        "convergence_iterations": Gauge("flywheel_convergence"),
    }

# 导出到 Prometheus/Grafana
```

## 配置模板

```yaml
# configs/flywheel-config.yaml
flywheel:
  name: auto-vibe-coding
  version: 1.0
  max_iterations: 10
  convergence_threshold: 0.95

agents:
  max_parallel: 5
  timeout_per_agent: 300
  context_budget: 15000

verification:
  layers:
    - name: syntax
      enabled: true
      timeout: 5
    - name: unit
      enabled: true
      timeout: 60
    - name: semantic
      enabled: true
      timeout: 300
    - name: adversarial
      enabled: true
      timeout: 600

self_learning:
  enabled: true
  auto_inject_threshold: 5
  cross_project_promotion:
    min_projects: 2
    min_occurrences: 5
  permanent_rule_threshold: 10

git:
  auto_commit: true
  branch_prefix: "flywheel-fix/"
  require_human_review: true

llm:
  provider: anthropic
  model: claude-3-5-sonnet
  temperature: 0.3
```

## 快速启动脚本

```bash
#!/bin/bash
# scripts/init.sh

set -e

echo "🚀 Initializing Auto Vibe Coding..."

# 检查依赖
command -v python >/dev/null 2>&1 || { echo "Python required"; exit 1; }
command -v poetry >/dev/null 2>&1 || { echo "Poetry required"; exit 1; }

# 安装依赖
poetry install

# 初始化配置
if [ ! -f configs/flywheel-config.yaml ]; then
    cp configs/flywheel-config.yaml.example configs/flywheel-config.yaml
fi

# 创建必要目录
mkdir -p memory/{patterns,failures,rules}

echo "✅ Initialization complete!"
echo "Run './scripts/run-flywheel.sh --task \"your task\"' to start."
```

```bash
#!/bin/bash
# scripts/run-flywheel.sh

set -e

TASK="${1:-}"

if [ -z "$TASK" ]; then
    echo "Usage: $0 --task \"your task description\""
    exit 1
fi

poetry run python -m src.core.flywheel --task "$TASK"
```

## 成功标准

| 阶段 | 指标 | 目标值 |
|------|------|--------|
| Phase 1 | 语法验证通过率 | > 99% |
| Phase 2 | 单元测试覆盖率 | > 80% |
| Phase 3 | 假阳性过滤率 | > 90% |
| Phase 4 | 自动修复成功率 | > 70% |
| Phase 4 | 人工介入率 | < 20% |

## 下一步

1. **克隆参考项目** 研究实现细节
2. **选择技术栈** 根据团队技术背景
3. **小规模试点** 先在一个模块验证
4. **迭代优化** 根据实际运行结果调整
5. **规模化部署** 逐步扩展到全代码库
