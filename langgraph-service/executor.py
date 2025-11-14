"""LangGraph workflow executor."""

from typing import Dict, Any, Optional
import logging

from redis_client import save_conversation_state, load_conversation_state

logger = logging.getLogger(__name__)


def validate_flow_json(flow_json: Dict[str, Any]) -> Dict[str, Any]:
    """
    Validate flowJson structure.

    Args:
        flow_json: Flow definition to validate

    Returns:
        Validation result with errors if any
    """
    errors = []

    # Check required top-level keys
    if "nodes" not in flow_json:
        errors.append("Missing 'nodes' array")
    if "edges" not in flow_json:
        errors.append("Missing 'edges' array")

    # Validate nodes
    if "nodes" in flow_json:
        nodes = flow_json["nodes"]
        if not isinstance(nodes, list):
            errors.append("'nodes' must be an array")
        else:
            node_ids = set()
            for i, node in enumerate(nodes):
                if "id" not in node:
                    errors.append(f"Node at index {i} missing 'id'")
                else:
                    node_ids.add(node["id"])
                if "type" not in node:
                    errors.append(f"Node {node.get('id', i)} missing 'type'")

    # Validate edges
    if "edges" in flow_json:
        edges = flow_json["edges"]
        if not isinstance(edges, list):
            errors.append("'edges' must be an array")
        else:
            for i, edge in enumerate(edges):
                if "from" not in edge:
                    errors.append(f"Edge at index {i} missing 'from'")
                if "to" not in edge:
                    errors.append(f"Edge at index {i} missing 'to'")

    return {
        "valid": len(errors) == 0,
        "errors": errors,
        "node_count": len(flow_json.get("nodes", [])),
        "edge_count": len(flow_json.get("edges", []))
    }


async def execute_workflow(
    agent_id: str,
    conversation_id: str,
    tenant_id: str,
    flow_json: Dict[str, Any],
    user_message: str,
    metadata: Optional[Dict[str, Any]] = None
) -> Dict[str, Any]:
    """
    Execute a LangGraph workflow.

    Args:
        agent_id: Agent ID
        conversation_id: Conversation ID for state management
        tenant_id: Tenant ID
        flow_json: LangGraph flow definition
        user_message: User's input message
        metadata: Additional metadata

    Returns:
        Execution result with response and state
    """
    try:
        logger.info(f"Executing workflow for agent {agent_id}")

        # Validate flow
        validation = validate_flow_json(flow_json)
        if not validation["valid"]:
            raise ValueError(f"Invalid flow: {validation['errors']}")

        # Load previous state from Redis
        previous_state = await load_conversation_state(conversation_id, tenant_id)

        # Initialize state
        initial_state = {
            "messages": previous_state.get("messages", []) if previous_state else [],
            "user_message": user_message,
            "response": "",
            "metadata": metadata or {}
        }

        # Add user message
        initial_state["messages"].append({
            "role": "USER",
            "content": user_message
        })

        # TODO: Build and execute LangGraph StateGraph from flow_json
        # For now, return a simple echo response
        assistant_response = f"[Echo from FastAPI] Agent '{agent_id}' received: {user_message}"

        # Add assistant response to state
        initial_state["messages"].append({
            "role": "ASSISTANT",
            "content": assistant_response
        })
        initial_state["response"] = assistant_response

        # Save state to Redis
        await save_conversation_state(conversation_id, tenant_id, initial_state)

        logger.info(f"Workflow execution completed for agent {agent_id}")

        return {
            "response": assistant_response,
            "state": initial_state,
            "messages_count": len(initial_state["messages"])
        }

    except Exception as e:
        logger.error(f"Workflow execution failed: {str(e)}", exc_info=True)
        raise