---
name: verify-sandbox
description: |
  Sandbox isolation verification. Runs code tests inside a Docker container with
  network isolation, memory limits, CPU limits, and read-only mounts to verify
  that agent claims about test results are reproducible — not hallucinations.
  Falls back to temp-directory isolation when Docker is unavailable.
  Use when asked to "sandbox verify", "run in isolation", or "verify sandbox".
allowed-tools:
  - Bash
  - Read
---

## 触发条件

当用户说：
- "沙箱验证"
- "sandbox verify"
- "隔离测试"
- "run in isolation"

## 你要做什么

在 Docker 容器中**隔离执行**代码测试，确保 Agent 声称的"测试通过"是真实可复现的，而非幻觉。

**核心原则**（来自 [AgentForge](https://arxiv.org/abs/2604.13120)）：
> 每个代码变更必须在隔离的、资源受限的、无网络的 Docker 容器中通过验证。

---

## 执行步骤

### Step 1: 检测项目环境

```bash
# 检测语言和依赖
if [ -f "package.json" ]; then
  RUNTIME="node:18-alpine"
  SETUP="npm install --ignore-scripts && npm test"
elif [ -f "go.mod" ]; then
  RUNTIME="golang:1.22-alpine"
  SETUP="go test ./..."
elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  RUNTIME="python:3.12-alpine"
  SETUP="pip install -r requirements.txt && pytest"
elif [ -f "Cargo.toml" ]; then
  RUNTIME="rust:1.77-alpine"
  SETUP="cargo test"
fi
```

### Step 2: 沙箱执行

```bash
docker run --rm --network=none --memory=512m --cpus=2 \
  -v "$(pwd):/workspace:ro" \
  -w /workspace \
  $RUNTIME \
  sh -c "$SETUP" 2>&1
```

**关键参数**:
- `--network=none` — 网络隔离，防止依赖泄露、外部攻击
- `--memory=512m` — 内存限制，探测泄漏
- `--cpus=2` — CPU限制，模拟生产环境
- `:ro` — **只读挂载**，代码不会被意外修改

### Step 3: 输出比对

```
Agent声称: "所有23个测试通过"
实际输出: "23 passed, 0 failed, 0 skipped"

比对结果: ✅ 一致 — Agent陈述可信任

---

Agent声称: "所有测试通过"
实际输出: "18 passed, 5 failed, 0 skipped"

比对结果: ❌ 不一致 — Agent幻觉！5个测试失败
```

### Step 4: 断言验证

```markdown
## 沙箱验证报告

### 环境
- Runtime: node:18-alpine
- Isolation: network=none, memory=512m, cpu=2
- Mount: read-only

### 执行输出
```
23 passed, 0 failed, 0 skipped
Coverage: 85.3%
```

### 与Agent声明比对
| 声明 | 实际 | 一致？ |
|------|------|--------|
| 23个测试通过 | 23 passed | ✅ |
| 无失败 | 0 failed | ✅ |
| 覆盖85% | 85.3% | ✅ |

### 验证结论
✅ Agent声明与沙箱执行结果完全一致
✅ 代码变更在隔离环境中可重现构建
✅ 无网络依赖泄露
```

---

## 如果验证失败

```
沙箱验证失败 → 标记 Agent 为 unreliable
            → 不采纳该Agent的后续声明
            → 检查是否是环境差异
            → 重新运行或转交其他Agent
```

---

## 无Docker时的降级方案

```bash
# 在 temp 目录中独立执行
TEMP_DIR=$(mktemp -d)
cp -r . "$TEMP_DIR"
cd "$TEMP_DIR"
npm test 2>&1
cd -
rm -rf "$TEMP_DIR"
```

虽然不提供容器级隔离，但至少保证**干净环境**执行。

## 参考

- [AgentForge](https://arxiv.org/abs/2604.13120) — Execution-Grounded Verification
- [Anthropic: Building a C Compiler](https://www.anthropic.com/engineering/building-c-compiler) — 沙箱工程实践
