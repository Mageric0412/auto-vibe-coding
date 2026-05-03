# Skill: flywheel

## 触发条件

当用户说：
- "启动飞轮"
- "run flywheel"
- "飞轮自测"
- "full self verify and fix"

## 你要做什么

启动完整**多Agent飞轮自测验证**，持续迭代直到收敛或用户中断。

---

## 执行指令

### 你首先加载这些 Agent 提示词

在开始飞轮之前，你需要把以下内容作为你的角色系统提示词依次加载：

**核心Agent**（必须）：
1. **Flywheel Orchestrator** → 读 `FLYWHEEL.md`
2. **Hunter Agent** → 读 `agents/hunter.md`
3. **Skeptic Agent** → 读 `agents/skeptic.md`
4. **Referee Agent** → 读 `agents/referee.md`
5. **Fixer Agent** → 读 `agents/fixer.md`

**专项Agent**（按需）：
6. **Security Auditor** → 读 `agents/security.md`（涉及 auth/crypto/sensitive data 时）
7. **Performance Profiler** → 读 `agents/performance.md`（涉及数据循环/资源管理时）

### 然后按 FLYWHEEL.md 的流程执行

---

## 飞轮执行（具体指令）

### ROUND 0: 基线
```
1. 运行 git status --short  → 记录变更文件列表
2. 运行现有测试            → 记录 pass/fail 数量
3. 运行 lint/typecheck     → 记录 error 数量
4. 运行构建（如果有）      → 记录成功/失败
5. 输出: R0 基线报告
```

### ROUND 1-N: 循环

每轮执行以下子步骤：

```
[1] 修复当前已知问题（如果有上一轮的 Referee CONFIRMED 问题）
    严格按照 agents/fixer.md 流程修复

[2] 运行自测验证
    严格按照 skills/self-test.md 流程

[3] Hunter 扫描
    用 agents/hunter.md 的角色，逐项检查所有变更文件
    输出发现列表

[4] Skeptic 挑战
    用 agents/skeptic.md 的角色，尝试推翻每个发现
    输出挑战结果

[5] Referee 裁决
    用 agents/referee.md 的角色，对争议做出终裁
    输出 CONFIRMED/DISMISSED/PARTIALLY_CONFIRMED/UNCERTAIN

[6] 收敛判断
    检查是否满足所有收敛条件：
    ✅ 全量测试 100% 通过
    ✅ Lint/TypeCheck 0 error
    ✅ Hunter 新发现均为 LOW 或全部 DISMISSED
    ✅ 本轮无 CONFIRMED medium+ 问题

    如果全部满足 → 停止飞轮，输出终验报告
    如果在第 N 轮满足后第 N+1 轮仍满足 → 飞轮收敛
    否则 → 进入下一轮
```

### 关键约束

1. **每轮必须输出轮次报告**（按 FLYWHEEL.md 中的模板）
2. **不要跳过任何步骤**——即使觉得"这轮应该没问题"
3. **最多 5 轮**——基于收敛公式 Acc_t = Upp − α^t(Upp − Acc_0)，第5轮边际增益 < 2%，不值得继续
4. **发现 UNCERTAIN 3 次**以上就标记需要人工介入
5. **Execution Grounding**——所有"测试通过"声明必须附带实际测试输出，不接受纯文字总结
6. **Generator ≠ Evaluator**——修复代码后，不能由写代码的同一个 context 做审查；必须切换到 Reviewer 角色或用独立 Agent

### 收敛公式

```
Acc_t = Upp − α^t × (Upp − Acc_0)

典型参数: Upp=0.9, α=0.5, Acc_0=0.5
t=1: 0.70 | t=2: 0.80 | t=3: 0.85 | t=4: 0.875 | t=5: 0.8875
→ 5轮后边际增益 < 2%
```

### 安全/性能敏感任务

如果任务涉及 auth/crypto/sensitive data：
```
→ 加载 agents/security.md，按 OWASP Top 10 + CWE 检查
→ 每个 Security Finding 必须标注 CWE 编号
```

如果任务涉及数据循环/资源管理/高并发：
```
→ 加载 agents/performance.md，检查 N+1、复杂度、内存泄漏
```

---

## 收敛报告模板

```markdown
## 🎯 Flywheel 飞轮终验报告

### 执行摘要
- 总轮次: [N]
- 总耗时: [时间]
- 收敛状态: ✅ 收敛 / ⚠️ 未收敛

### 变更文件
[列表]

### 发现与修复
| 轮次 | 发现数 | 确认数 | 修复数 | 被推翻数 |
|------|--------|--------|--------|----------|
| R1   | X      | X      | X      | X        |
| R2   | X      | X      | X      | X        |

### 最终状态
- ✅ 测试: XX pass / 0 fail
- ✅ Lint: 0 errors
- ✅ 构建: 成功
- ✅ Adversarial: 0 medium+ 发现

### 修复详情
- commit abc123: fix: [Finding #1 简述]
- commit def456: fix: [Finding #2 简述]

### 假阳性记录
- Finding #3: [简述] - 被推翻原因: [简述]
```
