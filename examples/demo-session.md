# Flywheel 演示：修复一个真实 Bug

> 理论基础见 [METHODOLOGY.md](../METHODOLOGY.md) — MAPE飞轮 + Generator≠Evaluator + Execution Grounding
>
> 本演示展示了 2 轮收敛的理想情况。实际任务可能需要 3-5 轮，取决于复杂度。

以下是一个完整飞轮执行演示——从发现到修复再到验证的全过程。

## 场景

项目：一个 TypeScript Todo App
任务：新增"按优先级排序"功能
目标：飞轮自测验证，确保无 bug 再提交

---

## ROUND 0: 基线

```
=== 飞轮 Round 0: 基线 ===

git status:
  M src/todos/sorter.ts      (+34 -0, new file)
  M src/todos/list.ts        (+12 -3)
  M tests/todos.test.ts      (+28 -0)

测试基线:
  npm test → 21 passed / 2 failed / 0 skipped

失败测试:
  FAIL src/todos/sorter.test.ts
    ● sortByPriority › should handle empty list
      Expected: []
      Received: TypeError: Cannot read properties of undefined

    ● sortByPriority › should handle mixed priorities
      Expected: ["A", "B", "C"]
      Received: ["C", "A", "B"]

Lint:
  eslint → 0 errors, 2 warnings
    warning: prefer-const in sorter.ts:12

构建:
  npm run build → OK

状态: 2 测试失败，1 lint warning → 进入 ROUND 1
```

---

## ROUND 1: 执行-验证

### [1] 修复已知问题

```
看到 lint warning: prefer-const in sorter.ts:12
→ 修复: let → const
→ 再跑 lint: OK, 0 warnings
```

### [2] 运行自测

```
npm test → 21 passed / 2 failed / 0 skipped
→ 2 测试仍失败，需要深入分析
```

### [3] Hunter 扫描

```markdown
进入 Hunter 角色...

## Finding #1 - HIGH - 空列表排序崩溃

**位置**: `src/todos/sorter.ts:5-8`
**置信度**: 0.95
**描述**:
  sortByPriority 未处理空数组，当 list 为空时 sort 返回 undefined

**触发条件**:
  调用 sortByPriority([])

**证据**:
  ```typescript
  export function sortByPriority(todos: Todo[]): Todo[] {
    return todos.sort((a, b) => // ❌ 未检查空数组
      PRIORITY_ORDER[a.priority] - PRIORITY_ORDER[b.priority]
    )
  }
  ```

**建议修复**: 添加空数组守卫

## Finding #2 - HIGH - 优先级排序方向反了

**位置**: `src/todos/sorter.ts:6-7`
**置信度**: 0.90
**描述**:
  排序计算方向反了。PRIORITY_ORDER 中 High=0, Low=2
  期望 High>Low 排前面，但 `a - b` 使 Low 排前面

**触发条件**:
  sortByPriority([{priority:'low'}, {priority:'high'}])

**证据**:
  ```typescript
  // PRIORITY_ORDER = { high: 0, medium: 1, low: 2 }
  // 期望: high 排最前面
  // 实际: low 排最前面 (0 < 2)
  PRIORITY_ORDER[a.priority] - PRIORITY_ORDER[b.priority]
  ```

## Finding #3 - LOW - 缺少 JSDoc 注释

**位置**: `src/todos/sorter.ts:3`
**置信度**: 0.60
**描述**: 新函数没有 JSDoc 注释
```

### [4] Skeptic 挑战

```markdown
进入 Skeptic 角色...

## 对 Finding #1 的挑战

**尝试 1: 上下文检查**
- 检查调用方 sorter.ts:12 → 所有 3 个调用方都在 sort 前做了非空判断
- 结论: 有外部防护，但函数本身仍不安全

**尝试 2: 运行验证**
- 构造 `sortByPriority([])` → TypeError crash
- 结论: 确实会崩溃

**判定**: CONFIRMED
**理由**: 虽然调用方有防护，但函数作为公共 API 应自己防御

## 对 Finding #2 的挑战

**尝试 1: 运行验证**
- 构造 `sortByPriority([{p:'high'}, {p:'low'}])`
- 期望: ["high", "low"]
- 实际: ["low", "high"]
- 结论: 排序确实反了

**判定**: CONFIRMED
**理由**: 排序方向确实反了

## 对 Finding #3 的挑战

**尝试 1: 团队规范**
- 检查项目其他文件 → 大部分导出函数没有 JSDoc
- 结论: 非项目规范要求

**判定**: OVERTURNED
**理由**: 非项目规范，属于代码风格偏好
```

### [5] Referee 裁决

```markdown
## Referee 裁决书

### Finding #1: CONFIRMED
严重程度: HIGH
理由: 独立审查代码，空数组确实导致 crash。公共函数应有自身防御。
→ 转 Fixer 修复

### Finding #2: CONFIRMED
严重程度: HIGH
理由: 排序方向错误，功能完全反了。测试明确证明了这一点。
→ 转 Fixer 修复

### Finding #3: DISMISSED
理由: 非项目规范，纯代码风格。
→ 跳过
```

### [6] Fixer 修复

```typescript
// BEFORE
export function sortByPriority(todos: Todo[]): Todo[] {
  return todos.sort((a, b) =>
    PRIORITY_ORDER[a.priority] - PRIORITY_ORDER[b.priority]
  )
}

// AFTER
export function sortByPriority(todos: Todo[]): Todo[] {
  if (!todos.length) return []              // fix #1
  return [...todos].sort((a, b) =>          // fix #2: 方向修正 + 不修改原数组
    PRIORITY_ORDER[b.priority] - PRIORITY_ORDER[a.priority]
  )
}
```

### 验证修复后

```
npm test → 23 passed / 0 failed
lint → 0 errors, 0 warnings
build → OK
```

### 收敛判断
```
✅ 测试: 23 pass / 0 fail
✅ Lint: 0 errors
✅ 构建: OK
本轮新发现: 0

→ 进入 ROUND 2 确认收敛
```

---

## ROUND 2: 确认收敛

```
=== 飞轮 Round 2 ===

自测: 23 passed / 0 failed ✅
Lint: 0 errors ✅
Hunter 扫描: 0 new findings ✅

收敛判断: 连续 2 轮无变化 → **飞轮收敛** ✅
```

---

## 终验报告

```markdown
## 🎯 Flywheel 飞轮终验报告

### 执行摘要
- 总轮次: 2
- 收敛状态: ✅ 收敛

### 变更文件
- src/todos/sorter.ts (new)
- src/todos/list.ts (modified)
- tests/todos.test.ts (modified)

### 发现与修复
| 轮次 | 发现 | 确认 | 修复 | 推翻 |
|------|------|------|------|------|
| R1   | 3    | 2    | 2    | 1    |
| R2   | 0    | 0    | 0    | 0    |

### 最终状态
- ✅ 测试: 23 pass / 0 fail
- ✅ Lint: 0 errors
- ✅ 构建: 成功

### 修复详情
- fix: sortByPriority 空数组守卫 & 排序方向修正
  - Finding #1: 添加空数组检查
  - Finding #2: 交换排序比较方向

### 假阳性记录
- Finding #3: "缺少 JSDoc" → 非项目规范，已忽略
```
