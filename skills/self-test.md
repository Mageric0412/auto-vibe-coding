# Skill: self-test

## 触发条件

当用户说：
- "自测"
- "self test"
- "验证当前代码"
- "check my code"

## 你要做什么

对当前项目的代码改动执行**快速自测验证**（对应 Layer 1-2 验证）。

---

## 执行步骤

### Step 1: 获取状态基线
```bash
git status --short
git diff --stat
```

### Step 2: 语法/类型检查（根据项目语言选择）

**TypeScript/JavaScript:**
```bash
npx tsc --noEmit 2>&1 || echo "--- TSC FAILED ---"
npx eslint . --quiet 2>&1 || echo "--- ESLINT FAILED ---"
```

**Python:**
```bash
python -m py_compile $(git diff --name-only HEAD --diff-filter=ACMR | grep '\.py$') 2>&1 || echo "--- SYNTAX FAILED ---"
flake8 --select=E,F $(git diff --name-only HEAD --diff-filter=ACMR | grep '\.py$') 2>&1 || echo "--- FLAKE8 FAILED ---"
```

**Go:**
```bash
go vet ./... 2>&1 || echo "--- VET FAILED ---"
golint ./... 2>&1 || echo "--- LINT FAILED ---"
```

### Step 3: 测试执行
```bash
# 根据项目自动检测测试命令
npm test 2>&1 || npx jest 2>&1 || yarn test 2>&1 || go test ./... 2>&1 || pytest 2>&1
```

### Step 4: 如果失败 → 进入飞轮
如果任何一步失败：
```
Step 2 失败 → 先修复 lint/syntax，回到 Step 2
Step 3 失败 → 启动完整飞轮验证（调用 verify 技能）
```

### Step 5: 输出报告
```markdown
## 自测报告 @ [timestamp]

### 变更文件
- `file1.ts` (+42 -15)
- `file2.ts` (+8 -2)

### 静态检查
✅ TypeScript: 0 errors
✅ ESLint: 0 errors

### 测试
✅ Tests: 23 passed / 0 failed / 0 skipped

### 结论
✅ 自测通过，无发现问题
```
