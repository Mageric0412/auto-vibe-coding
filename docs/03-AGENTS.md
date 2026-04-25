# Agent 职责定义

## Agent 矩阵

| Agent | 数量 | 职责 | 输入 | 输出 |
|-------|------|------|------|------|
| Scout | 1 | 探索发现 | 用户需求 | 问题空间报告 |
| Architect | 1 | 系统设计 | 需求 + Scout报告 | 架构设计 |
| Dev | 1-N | 代码实现 | 设计文档 | 代码 + 测试 |
| QA | 1 | 测试验证 | 代码变更 | 测试结果 |
| Verifier | 1 | 真伪验证 | QA报告 | 验证结论 |
| Fixer | 1 | 缺陷修复 | 验证失败 | 修复代码 |
| Learner | 1 | 模式学习 | 执行轨迹 | 规则/模式 |

## 各Agent详细规范

### 1. Scout Agent

```
Role: 问题空间探索者
Goal: 全面理解任务上下文和约束

职责:
  • 解析用户需求，提取关键实体
  • 搜索相关代码库上下文 (RAG)
  • 识别技术栈和依赖
  • 发现潜在风险和边界条件
  • 推荐 Agent 团队配置

输出格式:
  {
    "intent": "...",
    "entities": [...],
    "tech_stack": [...],
    "risks": [...],
    "recommended_agents": N,
    "context_summary": "..."
  }

工具集:
  • search_code: 语义搜索代码库
  • read_file: 读取相关文件
  • list_dependencies: 列出依赖关系
  • web_search: 搜索外部资料
```

### 2. Architect Agent

```
Role: 系统架构师
Goal: 设计可实施的解决方案

职责:
  • 评审需求可行性
  • 设计系统架构
  • 制定实施计划
  • 识别技术风险
  • 定义接口契约

输出格式:
  {
    "architecture": "...",
    "components": [...],
    "data_flow": "...",
    "implementation_steps": [...],
    "acceptance_criteria": [...],
    "estimated_complexity": 1-10
  }

Prompt 模板:
  你是一位资深架构师。请基于以下需求设计系统架构:

  需求: {user_requirement}

  请输出:
  1. 系统架构图 (ASCII)
  2. 核心组件列表
  3. 数据流描述
  4. 实施步骤
  5. 验收标准
```

### 3. Dev Agent

```
Role: 代码实现者
Goal: 高质量完成功能实现

职责:
  • 遵循架构设计实现代码
  • 编写单元测试
  • 确保代码符合规范
  • 记录实现决策

并行策略:
  • 简单任务: 1 Dev Agent
  • 中等任务: 2-3 Dev Agent (不同模块)
  • 复杂任务: 5+ Dev Agent (微服务拆分)

工具集:
  • write_file: 创建/修改文件
  • read_file: 读取参考
  • run_command: 执行测试
  • git_operations: 版本控制

验证门控:
  1. 语法检查通过
  2. 单元测试 100% 通过
  3. 代码风格符合规范
```

### 4. QA Agent

```
Role: 测试工程师
Goal: 设计全面的测试用例

职责:
  • 分析代码变更影响
  • 设计测试用例 (正向/逆向/边界)
  • 执行现有测试套件
  • 补充缺失测试
  • 生成覆盖率报告

测试策略:
  • 单元测试: 每个函数/方法
  • 集成测试: 模块间交互
  • 端到端测试: 关键用户路径
  • 模糊测试: 输入验证

输出:
  {
    "test_plan": [...],
    "coverage": { "line": XX%, "branch": XX% },
    "failed_tests": [...],
    "edge_cases_identified": [...]
  }
```

### 5. Verifier Agent (Adversarial)

```
Role: 真伪验证者
Goal: 过滤假阳性，确保发现真实问题

核心原则:
  "每个发现都必须经过试图证伪的步骤"

职责:
  • 挑战每个发现
  • 尝试推翻 bug 报告
  • 验证修复有效性
  • 评估风险等级

对抗流程:
  1. 接收 Hunter 的 bug 报告
  2. 分析复现路径
  3. 尝试构造反例
  4. 如果推翻不了 → 确认
  5. 如果推翻 → 标记假阳性

评分机制:
  • 成功确认真 bug: +1
  • 成功推翻假阳性: +1
  • 漏报真实 bug: -2 (双倍惩罚)
  • 误报假阳性: -1

输出:
  {
    "verified_bugs": [...],      # 确认的bug
    "false_positives": [...],   # 假阳性
    "risk_assessment": {...},
    "fix_priority": [...]
  }
```

### 6. Fixer Agent

```
Role: 自动修复者
Goal: 最小化修改，最大化效果

职责:
  • 分析 bug 根本原因
  • 生成修复方案
  • 执行修复
  • 验证修复有效
  • 提交到 Git

修复策略:
  1. 最小化改动: 只改必要代码
  2. 先测试: 确保有测试覆盖
  3. 原子提交: 每个 bug 单独 commit
  4. 自动描述: 生成清晰的 commit message

工作流:
  ┌─────────────┐
  │  Analyze    │──▶ 理解 bug 根因
  └─────────────┘
         │
         ▼
  ┌─────────────┐
  │   Plan      │──▶ 设计修复方案
  └─────────────┘
         │
         ▼
  ┌─────────────┐
  │   Fix       │──▶ 应用修复
  └─────────────┘
         │
         ▼
  ┌─────────────┐
  │   Verify    │──▶ 运行测试
  └─────────────┘
         │
         ▼
  ┌─────────────┐
  │   Commit    │──▶ Git commit
  └─────────────┘
```

### 7. Learner Agent

```
Role: 持续优化者
Goal: 从历史中学习，构建组织知识

职责:
  • 记录成功模式
  • 记录失败案例
  • 生成新规则
  • 优化 Agent 提示词

学习触发:
  • 错误发生 → passive learner
  • 置信度 >= 5 → auto-inject
  • 跨项目推广: 2+项目, 5+次
  • 永久规则: 10x 重复

知识存储:
  .
  └── memory/
      ├── patterns/          # 成功模式
      │   ├── backend/
      │   ├── frontend/
      │   └── devops/
      ├── failures/          # 失败案例
      ├── rules/             # 生成的规则
      └── metrics/           # 性能指标
```

## Agent 协作模式

### 模式 1: 串行流水线
```
Scout → Architect → Dev → QA → Verifier → Fixer
```
适用: 简单线性任务

### 模式 2: 并行开发
```
                    → Dev1 (模块A) →
Scout → Architect → Dev2 (模块B) → Integration → QA
                    → Dev3 (模块C) →
```
适用: 多模块并行开发

### 模式 3: 飞轮迭代
```
┌─────────────────────────────────────────────────┐
│                                                 │
│   Dev ──▶ QA ──▶ Verifier ──▶ Fixer            │
│     ↑                                      │    │
│     │              (loop)                  │    │
│     └──────────────────────────────────────┘    │
│                                                 │
└─────────────────────────────────────────────────┘
```
适用: 复杂问题需要多轮修复

### 模式 4: Adversarial 三方
```
┌──────────────────────────────────────────┐
│                                          │
│   Hunter ──▶ Skeptic ──▶ Referee         │
│      │         │           │             │
│      │   (challenge)   (verdict)         │
│      ▼         │           ▼             │
│   [Bug List] ◀──┴───────────────────────  │
│                                          │
└──────────────────────────────────────────┘
```
适用: 严格的质量验证

## 消息协议

```python
# Agent 间通信格式
class AgentMessage:
    sender: str      # Agent名称
    receiver: str   # 目标Agent
    type: str       # REQUEST/RESPONSE/VERIFICATION/REJECTION
    content: dict   # 消息内容
    metadata: dict  # 上下文信息
    trace_id: str   # 追踪ID

# 示例消息流
{
    # Scout → Architect
    "type": "REQUEST",
    "action": "design_architecture",
    "requirement": "实现用户登录功能",
    "context_summary": "..."
}

{
    # Architect → Dev(s)
    "type": "RESPONSE",
    "architecture": "...",
    "components": [...],
    "implementation_steps": [...]
}

{
    # Dev → QA
    "type": "REQUEST",
    "action": "verify_code",
    "files_changed": [...],
    "test_plan": "..."
}

{
    # QA → Verifier
    "type": "VERIFICATION",
    "findings": [...],
    "confidence": 0.85
}
```
