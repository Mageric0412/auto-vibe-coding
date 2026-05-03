# 参考论文与项目索引

## 核心论文

### CodeX-Verify: Multi-Agent Code Verification via Information Theory
- **来源**: Noumenon Labs / Harvard, arXiv 2511.16708 (2025.10)
- **链接**: https://arxiv.org/abs/2511.16708
- **核心贡献**:
  - 4个专用Agent并行检测（Correctness, Security, Performance, Style）
  - 信息论证明：I(A1..A4; B) > max I(Ai; B)
  - 边际增益递减的数学证明：+14.9pp, +13.5pp, +11.2pp
  - TPR 76.1%, <200ms延迟, 99样本测试集
  - Compound Vulnerability Model：多漏洞叠加风险倍增

### AgentForge: Execution-Grounded Multi-Agent LLM Framework
- **来源**: arXiv 2604.13120 (2026.04)
- **链接**: https://arxiv.org/abs/2604.13120
- **核心贡献**:
  - Execution-Grounded Verification：必须沙箱执行才认定通过
  - 5个Agent（Planner, Coder, Tester, Debugger, Critic）
  - MDP形式化建模：软件工程 = 仓库状态空间的顺序决策
  - SWE-bench Lite 40.0%，超过单Agent 26-28pp
  - 开源: https://github.com/raja21068/AutoCodeAI

### ReVeal: Self-Evolving Code Agents via Reliable Self-Verification
- **来源**: arXiv 2506.11442 (2025.06, updated 2025.10)
- **链接**: https://arxiv.org/abs/2506.11442
- **核心贡献**:
  - TAPO (Turn-Aware PPO)：逐轮奖励的RL算法
  - 20+轮推理时迭代自进化（训练仅3轮）
  - Generation + Verification 能力协同进化
  - LiveCodeBench Pass@1: 36.9%→42.4%
  - 超越DeepSeek-R1-Zero-Qwen-32B

### BitsAI-CR: Automated Code Review via LLM in Practice
- **来源**: ByteDance, FSE 2025 Industry Papers
- **链接**: https://conf.researchr.org/details/fse-2025/fse-2025-industry-papers/24/
- **核心贡献**:
  - 两阶段架构：RuleChecker (高召回) → ReviewFilter (高精准)
  - 数据飞轮：持续从反馈中改进
  - 75.0% 精准率，12,000+ 周活用户
  - Outdated Rate 评估指标

### SpecMAS: A Multi-Agent System for Self-Verifying System Generation
- **来源**: NeurIPS 2025
- **链接**: (通过 Bytez 收录)
- **核心贡献**:
  - 形式化模型检查驱动的闭环
  - NuSMV模型生成 → 模型检查 → Counterexample驱动的自主调试
  - 所有属性验证通过才停止

---

## 工业界系统

### Anthropic Claude Code (Internal Harness)
- **来源**: Anthropic Engineering Blog + 源码泄露
- **链接**:
  - [Multi-Agent C Compiler](https://www.anthropic.com/engineering/building-c-compiler)
  - [how-we-built-our-multi-agent-research-system](https://www.anthropic.com/engineering/how-we-built-our-multi-agent-research-system)
- **核心架构**:
  - TAOR循环 (Think→Act→Observe→Repeat)
  - 3种执行模式: Default / Plan Mode / Coordinator Mode
  - 14个prompt cache断点，约40个工具
  - 6层权限分级
  - Claude Code Review: 假阳性过滤，工程师误标率<1%

### Google DeepMind CodeMender
- **来源**: Google DeepMind (2025.10)
- **链接**: https://deepmind.google/blog/introducing-codemender-an-ai-agent-for-code-security/
- **核心特点**:
  - 漏洞检测→补丁生成→自验证
  - 高级程序分析（静态、动态、Fuzzing、SMT）
  - 多Agent critique循环
  - Gemini Deep Think 推理
  - 72个安全修复合入开源项目

### Datadog Harness-First Engineering
- **来源**: Datadog Blog (2025)
- **链接**: https://www.datadoghq.com/blog/ai/harness-first-agents/
- **核心特点**:
  - 验证金字塔：Symbolic → DST → Model Checking → Bounded → Empirical
  - 不变量一次性捕杀整类bug（而非逐个修复）
  - redis-rust 和 Helix（Kafka兼容）实战

### ByteDance BitsAI-CR
- **来源**: ByteDance, FSE 2025
- **链接**: (同上论文)
- **规模**: 12,000+ 周活用户，75%精准率

### CodeRabbit Agentic Code Validation
- **来源**: CodeRabbit (2025)
- **链接**: https://nljug.org/foojay/how-coderabbits-agentic-code-validation-helps-with-code-reviews/
- **核心特点**:
  - Reasoning model (GPT-5, Claude 4.5)
  - 独立验证Agent
  - 隔离沙箱（"tools in jail"）
  - 增量分析 + AST解析

### Aptori Code-Q
- **来源**: Aptori (2025.11)
- **链接**: https://www.aptori.com/press-releases/aptoris-code-q-closes-the-loop-on-application-security-from-detection-to-remediation/
- **核心特点**:
  - 语义图推理（非LLM文本补全）
  - 确定性可验证修复
  - git push → scan → fix 闭环

---

## 开源Harness项目

### wow-harness
- **仓库**: https://github.com/Chachamaru127/claude-code-harness
- **核心特点**:
  - 16个生命周期Hook
  - 8关状态机（偶数关=独立审查Agent）
  - Schema级工具隔离（审查者无Write权限）
  - CLAUDE.md ~20% → Hook ~100% 合规率提升

### autonomous-dev
- **仓库**: https://github.com/akaszubski/autonomous-dev
- **核心特点**:
  - 8步pipeline，13阶段状态机
  - 23个Hook，硬JSON gate
  - Git worktree并行隔离
  - Generator/Evaluator对抗模式

### Sellier
- **来源**: https://dev.to/tacoda/announcing-sellier-4489
- **核心架构**:
  - Guidance → Guardrails → Flywheel → Workflows 四层
  - 核心洞察：瓶颈不是模型能力，是行为可重复性

### Agent Orchestrator (ComposioHQ)
- **仓库**: https://github.com/ComposioHQ/agent-orchestrator
- **Stars**: 6.5k
- **核心**: CI/CD自愈，并行git worktree，PR自动化

### Bug Hunter
- **仓库**: https://github.com/codexstar69/bug-hunter
- **Stars**: 121
- **核心**: 三Agent辩论 (Hunter/Skeptic/Referee)，STRIDE/CWE/CVSS

### vibecosystem
- **仓库**: https://github.com/vibeeval/vibecosystem
- **Stars**: 471
- **核心**: 138 Agent, 自学习pipeline，错误→规则自动转换

### RuFlo
- **仓库**: https://github.com/ruvnet/ruflo
- **Stars**: 33k
- **核心**: 100+ Agent, 自优化SONA, Raft/BFT共识, HNSW

### claude-code-agent-hooks
- **仓库**: https://github.com/abean23/claude-code-agent-hooks
- **核心**: 3层验证, 有界自纠正, SHA256 trace

### AlphaSwarm.sol
- **仓库**: https://github.com/alehdezp/alphaswarm-sol
- **核心**: 行为安全知识图谱(BSKG), 自测harness

---

## 方法论文献

### Self-Correction Flywheel Paradigm
- **来源**: EmergentMind (2026.01)
- **链接**: https://www.emergentmind.com/topics/self-correction-flywheel-paradigm
- **核心**: 收敛公式 Acc_t = Upp − α^t(Upp − Acc_0)

### Building Resilient Prompts Using an Evaluation Flywheel
- **来源**: OpenAI Cookbook (2025)
- **链接**: https://developers.openai.com/cookbook/examples/evaluation/building_resilient_prompts_using_an_evaluation_flywheel
- **核心**: Analyze→Measure→Improve 三阶段

### Self-Improving Coding Agents
- **来源**: Addy Osmani Blog (2025)
- **链接**: https://addyosmani.com/blog/self-improving-agents/
- **核心**: 综合Survey，QA loop, 测试生成, 自修复模式

---

## 分类速查

| 类别 | 代表系统 | 适用场景 |
|------|---------|----------|
| 理论框架 | CodeX-Verify, AgentForge, ReVeal | 理解为什么多Agent更好 |
| 代码审查 | BitsAI-CR, Claude Code Review, CodeRabbit | PR Review自动化 |
| 安全 | CodeMender, Aptori Code-Q, Bug Hunter | 安全漏洞自动发现修复 |
| Harness/治理 | wow-harness, autonomous-dev, Sellier | Agent行为可靠性 |
| 编排 | Agent Orchestrator, RuFlo, vibecosystem | 多Agent生命周期管理 |
| 评测 | promptfoo, CodeX-Verify (数据集) | Prompt/Agent质量评估 |
