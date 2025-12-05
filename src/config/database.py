"""
Database connection and configuration
"""

from motor.motor_asyncio import AsyncIOMotorClient
from pymongo.errors import ConnectionFailure
import logging

from .settings import settings

logger = logging.getLogger(__name__)


class Database:
    """MongoDB database connection manager"""

    client: AsyncIOMotorClient = None

    @classmethod
    async def connect_db(cls):
        """Connect to MongoDB"""
        try:
            cls.client = AsyncIOMotorClient(settings.mongodb_uri)
            # Verify connection
            await cls.client.admin.command("ping")
            logger.info(f"Connected to MongoDB at {settings.mongodb_uri}")
        except ConnectionFailure as e:
            logger.error(f"Failed to connect to MongoDB: {e}")
            raise

    @classmethod
    async def close_db(cls):
        """Close MongoDB connection"""
        if cls.client:
            cls.client.close()
            logger.info("Closed MongoDB connection")

    @classmethod
    def get_database(cls):
        """Get database instance"""
        if not cls.client:
            raise Exception("Database not connected")
        return cls.client[settings.db_name]

    @classmethod
    def get_collection(cls, name: str):
        """Get collection from database"""
        db = cls.get_database()
        return db[name]


# Convenience functions
def get_db():
    """Dependency to get database"""
    return Database.get_database()


def get_users_collection():
    """Get users collection"""
    return Database.get_collection("users")


def get_fictions_collection():
    """Get fictions collection"""
    return Database.get_collection("fictions")
