# src/core/flywheel.py - 飞轮引擎

import argparse
import asyncio
import logging
from typing import Dict, List, Optional
from dataclasses import dataclass, field

from src.agents import (
    ScoutAgent,
    ArchitectAgent,
    DevAgent,
    QAAgent,
    VerifierAgent,
    FixerAgent,
)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@dataclass
class FlywheelState:
    """飞轮状态"""
    task: str
    phase: str = "research"  # research, execution, verification
    iterations: int = 0
    findings: List[dict] = field(default_factory=list)
    verified_bugs: List[dict] = field(default_factory=list)
    fixed_count: int = 0
    converged: bool = False


class FlywheelEngine:
    """
    多Agent飞轮引擎

    核心循环:
    1. Research Phase: Scout + Architect 分析任务
    2. Execution Phase: Dev Agent(s) 实现代码
    3. Verification Phase: QA + Verifier 验证
    4. Fix Loop: Fixer 自动修复问题
    """

    def __init__(self, config: Dict):
        self.config = config
        self.max_iterations = config.get("flywheel", {}).get("max_iterations", 10)
        self.convergence_threshold = config.get("flywheel", {}).get("convergence_threshold", 0.95)

        # 初始化 Agents
        self.agents = {
            "scout": ScoutAgent(config),
            "architect": ArchitectAgent(config),
            "dev": DevAgent(config),
            "qa": QAAgent(config),
            "verifier": VerifierAgent(config),
            "fixer": FixerAgent(config),
        }

    async def run(self, task: str) -> FlywheelState:
        """
        运行飞轮

        Args:
            task: 任务描述

        Returns:
            FlywheelState: 最终状态
        """
        logger.info(f"🚀 Starting flywheel for task: {task}")

        state = FlywheelState(task=task)

        while state.iterations < self.max_iterations and not state.converged:
            state.iterations += 1
            logger.info(f"📍 Iteration {state.iterations}/{self.max_iterations}")

            try:
                # Phase 1: Research
                if state.phase == "research":
                    state = await self._research_phase(state)

                # Phase 2: Execution
                elif state.phase == "execution":
                    state = await self._execution_phase(state)

                # Phase 3: Verification
                elif state.phase == "verification":
                    state = await self._verification_phase(state)

                # 检查收敛
                if self._check_convergence(state):
                    state.converged = True
                    logger.info("✅ Flywheel converged!")

            except Exception as e:
                logger.error(f"❌ Error in iteration {state.iterations}: {e}")
                # 继续执行，可能需要人工介入

        return state

    async def _research_phase(self, state: FlywheelState) -> FlywheelState:
        """研究阶段: Scout + Architect"""
        logger.info("🔍 Research Phase")

        # Scout 分析任务
        scout_result = await self.agents["scout"].execute(state.task, {})
        logger.info(f"   Scout findings: {len(scout_result.findings)} items")

        # Architect 设计方案
        context = {
            "task": state.task,
            "scout_findings": scout_result.findings,
        }
        arch_result = await self.agents["architect"].execute("", context)
        logger.info(f"   Architect: {arch_result.metadata.get('summary', 'completed')}")

        state.phase = "execution"
        return state

    async def _execution_phase(self, state: FlywheelState) -> FlywheelState:
        """执行阶段: Dev Agent(s)"""
        logger.info("💻 Execution Phase")

        # Dev 实现代码
        dev_result = await self.agents["dev"].execute(state.task, {})
        logger.info(f"   Dev: {len(dev_result.findings)} code changes")

        state.findings.extend(dev_result.findings)
        state.phase = "verification"
        return state

    async def _verification_phase(self, state: FlywheelState) -> FlywheelState:
        """验证阶段: QA + Verifier"""
        logger.info("🔬 Verification Phase")

        # QA 测试
        qa_result = await self.agents["qa"].execute("", {"findings": state.findings})
        logger.info(f"   QA: {len(qa_result.findings)} test results")

        # Verifier 验证 (adversarial)
        verifier_result = await self.agents["verifier"].execute(
            "",
            {"qa_findings": qa_result.findings}
        )
        logger.info(f"   Verifier: {len(verifier_result.findings)} confirmed issues")

        state.verified_bugs = verifier_result.findings

        # 如果有确认的 bug，尝试修复
        if verifier_result.findings:
            state.phase = "fix"
        else:
            state.phase = "research"  # 回到研究阶段检查新问题

        return state

    async def _fix_phase(self, state: FlywheelState) -> FlywheelState:
        """修复阶段: Fixer"""
        logger.info("🔧 Fix Phase")

        for bug in state.verified_bugs:
            fix_result = await self.agents["fixer"].execute("", {"bug": bug})
            if fix_result.success:
                state.fixed_count += 1
                logger.info(f"   Fixed: {bug.get('id', 'unknown')}")

        state.phase = "verification"  # 重新验证
        return state

    def _check_convergence(self, state: FlywheelState) -> bool:
        """检查是否收敛"""
        # 没有新的未验证问题
        if not state.findings:
            return True

        # 修复率足够高
        fix_rate = state.fixed_count / len(state.findings)
        if fix_rate >= self.convergence_threshold:
            return True

        return False


async def main():
    """CLI 入口"""
    parser = argparse.ArgumentParser(description="Auto Vibe Coding Flywheel")
    parser.add_argument("--task", type=str, required=True, help="Task description")
    parser.add_argument("--config", type=str, default="configs/flywheel-config.yaml")
    parser.add_argument("--verbose", action="store_true")
    args = parser.parse_args()

    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    # 加载配置
    import yaml
    with open(args.config) as f:
        config = yaml.safe_load(f)

    # 运行飞轮
    engine = FlywheelEngine(config)
    result = await engine.run(args.task)

    print(f"\n{'='*60}")
    print(f"Flywheel completed in {result.iterations} iterations")
    print(f"Verified bugs: {len(result.verified_bugs)}")
    print(f"Fixed: {result.fixed_count}")
    print(f"Converged: {result.converged}")
    print(f"{'='*60}\n")


if __name__ == "__main__":
    asyncio.run(main())
