"""Redis client for conversation state management."""

import redis.asyncio as redis
from typing import Optional, Dict, Any
import json
import logging

from config import settings

logger = logging.getLogger(__name__)

# Global Redis client
redis_client: Optional[redis.Redis] = None


async def init_redis():
    """Initialize Redis connection."""
    global redis_client

    try:
        redis_client = await redis.from_url(
            settings.redis_url,
            encoding="utf-8",
            decode_responses=True,
            max_connections=10
        )

        # Test connection
        await redis_client.ping()
        logger.info("Redis connection established")

    except Exception as e:
        logger.error(f"Failed to connect to Redis: {str(e)}")
        raise


async def get_redis() -> redis.Redis:
    """Get Redis client instance."""
    if redis_client is None:
        raise RuntimeError("Redis client not initialized")
    return redis_client


async def save_conversation_state(
    conversation_id: str,
    tenant_id: str,
    state: Dict[str, Any],
    ttl: int = 86400  # 24 hours default
) -> bool:
    """
    Save conversation state to Redis.

    Args:
        conversation_id: Conversation ID
        tenant_id: Tenant ID for key namespacing
        state: State dictionary to save
        ttl: Time-to-live in seconds

    Returns:
        True if saved successfully
    """
    try:
        key = f"conversation:{tenant_id}:{conversation_id}:state"

        # Serialize state to JSON
        state_json = json.dumps(state, default=str)

        # Save to Redis with TTL
        await redis_client.setex(key, ttl, state_json)

        logger.info(f"Saved state for conversation {conversation_id}")
        return True

    except Exception as e:
        logger.error(f"Error saving conversation state: {str(e)}")
        return False


async def load_conversation_state(
    conversation_id: str,
    tenant_id: str
) -> Optional[Dict[str, Any]]:
    """
    Load conversation state from Redis.

    Args:
        conversation_id: Conversation ID
        tenant_id: Tenant ID for key namespacing

    Returns:
        State dictionary or None if not found
    """
    try:
        key = f"conversation:{tenant_id}:{conversation_id}:state"

        state_json = await redis_client.get(key)

        if not state_json:
            logger.info(f"No cached state for conversation {conversation_id}")
            return None

        # Deserialize from JSON
        state = json.loads(state_json)

        logger.info(f"Loaded state for conversation {conversation_id}")
        return state

    except Exception as e:
        logger.error(f"Error loading conversation state: {str(e)}")
        return None