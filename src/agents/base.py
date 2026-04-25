# src/agents/base.py - Agent 基类

from abc import ABC, abstractmethod
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field


class AgentConfig(BaseModel):
    """Agent 配置"""
    name: str
    max_tools: int = 20
    timeout: int = 300  # seconds
    context_budget: int = 15000  # tokens


class AgentMessage(BaseModel):
    """Agent 间通信消息"""
    sender: str
    receiver: str
    type: str  # REQUEST/RESPONSE/VERIFICATION/REJECTION
    content: Dict[str, Any]
    metadata: Dict[str, Any] = Field(default_factory=dict)
    trace_id: Optional[str] = None


class AgentResult(BaseModel):
    """Agent 执行结果"""
    agent: str
    success: bool
    findings: List[Dict[str, Any]] = Field(default_factory=list)
    errors: List[str] = Field(default_factory=list)
    metadata: Dict[str, Any] = Field(default_factory=dict)


class BaseAgent(ABC):
    """
    Agent 基类

    所有 Agent 应继承此类并实现 execute 方法
    """

    def __init__(self, config: AgentConfig, llm_client: Any = None):
        self.config = config
        self.llm_client = llm_client

    @abstractmethod
    async def execute(self, task: str, context: Dict[str, Any]) -> AgentResult:
        """
        执行任务

        Args:
            task: 任务描述
            context: 执行上下文

        Returns:
            AgentResult: 执行结果
        """
        pass

    def validate_result(self, result: AgentResult) -> bool:
        """
        验证结果是否有效
        """
        if not result.success:
            return False

        # 检查是否有发现
        if not result.findings:
            return True  # 没发现问题也是有效的

        return True

    def compress_return(self, full_context: Dict[str, Any]) -> Dict[str, Any]:
        """
        压缩 SubAgent 返回信息
        用于返回给 Lead Agent
        """
        return {
            "key_findings": self._extract_top_findings(full_context.get("findings", [])),
            "decision_summary": self._summarize_reasoning(full_context.get("reasoning", [])),
            "issues_for_lead": full_context.get("blockers", []),
            "confidence": full_context.get("confidence", 0.5),
            "tool_usage": {
                "total_calls": full_context.get("tool_calls", 0),
                "within_budget": full_context.get("tool_calls", 0) < self.config.max_tools,
            },
        }

    def _extract_top_findings(self, findings: List[Dict], n: int = 5) -> List[Dict]:
        """提取最重要的 n 个发现"""
        sorted_findings = sorted(
            findings,
            key=lambda x: x.get("importance", 0),
            reverse=True
        )
        return sorted_findings[:n]

    def _summarize_reasoning(self, reasoning: List[str]) -> str:
        """总结推理过程"""
        if not reasoning:
            return ""
        return "; ".join(reasoning[-3:])  # 最后3步推理
