"""Database connection and queries for loading agent definitions."""

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text
from typing import Optional, Dict, Any
import logging

from config import settings

logger = logging.getLogger(__name__)

# Database engine and session
engine = None
async_session_maker = None


async def init_db():
    """Initialize database connection pool."""
    global engine, async_session_maker

    # Convert postgresql:// to postgresql+asyncpg://
    db_url = settings.database_url.replace('postgresql://', 'postgresql+asyncpg://')

    engine = create_async_engine(
        db_url,
        echo=settings.environment == "development",
        pool_size=5,
        max_overflow=10,
        pool_pre_ping=True  # Verify connections before using
    )

    async_session_maker = sessionmaker(
        engine,
        class_=AsyncSession,
        expire_on_commit=False
    )

    logger.info("Database connection pool initialized")


async def get_agent_by_id(agent_id: str, tenant_id: str) -> Optional[Dict[str, Any]]:
    """
    Load agent definition from database.

    Args:
        agent_id: Agent ID to load
        tenant_id: Tenant ID for multi-tenant isolation

    Returns:
        Agent data including flowJson, or None if not found
    """
    async with async_session_maker() as session:
        try:
            query = text("""
                SELECT id, name, version, status, "flowJson", "tenantId",
                       "createdAt", "updatedAt"
                FROM "Agent"
                WHERE id = :agent_id AND "tenantId" = :tenant_id
            """)

            result = await session.execute(
                query,
                {"agent_id": agent_id, "tenant_id": tenant_id}
            )

            row = result.fetchone()

            if not row:
                logger.warning(f"Agent {agent_id} not found for tenant {tenant_id}")
                return None

            # Convert row to dict
            agent_data = {
                "id": row[0],
                "name": row[1],
                "version": row[2],
                "status": row[3],
                "flowJson": row[4],  # This is already a dict from JSONB
                "tenantId": row[5],
                "createdAt": row[6].isoformat() if row[6] else None,
                "updatedAt": row[7].isoformat() if row[7] else None
            }

            logger.info(f"Loaded agent {agent_id} (version {agent_data['version']})")
            return agent_data

        except Exception as e:
            logger.error(f"Error loading agent {agent_id}: {str(e)}")
            raise