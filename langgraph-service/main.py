"""
LangGraph Execution Service - FastAPI Application

This service executes LangGraph workflows defined in agent flowJson.
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional, Dict, Any
import logging
from datetime import datetime

from config import settings
from database import get_agent_by_id, init_db
from redis_client import init_redis
from executor import execute_workflow, validate_flow_json

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="LangGraph Execution Service",
    description="Executes AI workflows using LangGraph",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Request/Response Models
class ExecuteRequest(BaseModel):
    """Request to execute an agent workflow."""
    agent_id: str = Field(..., description="Agent ID to execute")
    conversation_id: str = Field(..., description="Conversation ID for state management")
    message: str = Field(..., description="User message to process")
    tenant_id: str = Field(..., description="Tenant ID for multi-tenant isolation")
    metadata: Optional[Dict[str, Any]] = Field(default={}, description="Additional metadata")


class ExecuteResponse(BaseModel):
    """Response from workflow execution."""
    conversation_id: str
    agent_id: str
    response: str
    state: Optional[Dict[str, Any]] = None
    execution_time_ms: float
    timestamp: str


# Startup and Shutdown Events
@app.on_event("startup")
async def startup_event():
    """Initialize connections on startup."""
    logger.info("Starting LangGraph Execution Service...")
    await init_db()
    await init_redis()
    logger.info("LangGraph Execution Service started successfully")


# API Endpoints

@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {
        "status": "healthy",
        "service": "langgraph-execution",
        "timestamp": datetime.utcnow().isoformat()
    }


@app.post("/execute", response_model=ExecuteResponse)
async def execute_agent(request: ExecuteRequest):
    """Execute an agent workflow synchronously."""
    start_time = datetime.utcnow()

    try:
        # Load agent from database
        agent = await get_agent_by_id(request.agent_id, request.tenant_id)
        if not agent:
            raise HTTPException(status_code=404, detail=f"Agent {request.agent_id} not found")

        # Check agent status
        if agent.get("status") != "PUBLISHED":
            raise HTTPException(
                status_code=400,
                detail=f"Agent is not published. Current status: {agent.get('status')}"
            )

        # Execute workflow
        result = await execute_workflow(
            agent_id=request.agent_id,
            conversation_id=request.conversation_id,
            tenant_id=request.tenant_id,
            flow_json=agent["flowJson"],
            user_message=request.message,
            metadata=request.metadata
        )

        # Calculate execution time
        execution_time = (datetime.utcnow() - start_time).total_seconds() * 1000

        return ExecuteResponse(
            conversation_id=request.conversation_id,
            agent_id=request.agent_id,
            response=result["response"],
            state=result.get("state"),
            execution_time_ms=execution_time,
            timestamp=datetime.utcnow().isoformat()
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Execution error: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Execution failed: {str(e)}")


@app.post("/validate")
async def validate_flow(flow_json: Dict[str, Any]):
    """Validate flowJson structure without executing."""
    validation_result = validate_flow_json(flow_json)

    if validation_result["valid"]:
        return {
            "valid": True,
            "message": "Flow definition is valid",
            "node_count": validation_result["node_count"],
            "edge_count": validation_result["edge_count"]
        }
    else:
        return {
            "valid": False,
            "message": "Flow definition has errors",
            "errors": validation_result.get("errors", [])
        }


@app.get("/")
async def root():
    """Root endpoint with API information."""
    return {
        "service": "LangGraph Execution Service",
        "version": "1.0.0",
        "status": "running",
        "docs": "/docs",
        "endpoints": {
            "health": "GET /health",
            "execute": "POST /execute",
            "validate": "POST /validate"
        }
    }