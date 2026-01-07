"""
Vector service for managing Pinecone vector database.
Handles item embeddings and similarity search.
"""

import logging
from typing import Optional, List, Dict, Any, Tuple
from datetime import datetime

from pinecone import Pinecone, ServerlessSpec
from app.core.config import settings

logger = logging.getLogger(__name__)


class VectorService:
    """Service for interacting with Pinecone vector database."""

    def __init__(self):
        """Initialize Pinecone client."""
        self._pc = None
        self._index = None

    @property
    def pc(self) -> Pinecone:
        """Get or create Pinecone client."""
        if self._pc is None:
            self._pc = Pinecone(api_key=settings.PINECONE_API_KEY)
        return self._pc

    @property
    def index(self):
        """Get or create Pinecone index."""
        if self._index is None:
            self._index = self.pc.Index(settings.PINECONE_INDEX_NAME)
        return self._index

    # ========================================================================
    # ITEM OPERATIONS
    # ========================================================================

    async def upsert_item(
        self,
        item_id: str,
        embedding: List[float],
        metadata: Dict[str, Any]
    ) -> bool:
        """Add or update an item's embedding in Pinecone.

        Args:
            item_id: Unique item identifier
            embedding: 768-dim vector from Gemini embeddings
            metadata: Item attributes for filtering

        Returns:
            True if successful
        """
        try:
            self.index.upsert(
                vectors=[(
                    item_id,
                    embedding,
                    self._prepare_metadata(metadata)
                )]
            )
            logger.debug(f"Upserted embedding for item {item_id}")
            return True

        except Exception as e:
            logger.error(f"Error upserting item {item_id}: {str(e)}")
            return False

    async def batch_upsert(
        self,
        items: List[Tuple[str, List[float], Dict[str, Any]]]
    ) -> int:
        """Upsert multiple items in a single batch.

        Args:
            items: List of (item_id, embedding, metadata) tuples

        Returns:
            Number of successfully upserted items
        """
        if not items:
            return 0

        try:
            vectors = [
                (item_id, embedding, self._prepare_metadata(metadata))
                for item_id, embedding, metadata in items
            ]

            self.index.upsert(vectors=vectors)
            logger.info(f"Batch upserted {len(items)} items")
            return len(items)

        except Exception as e:
            logger.error(f"Error in batch upsert: {str(e)}")
            return 0

    async def delete_item(self, item_id: str) -> bool:
        """Delete an item's embedding from Pinecone.

        Args:
            item_id: Item to delete

        Returns:
            True if successful
        """
        try:
            self.index.delete(ids=[item_id])
            logger.debug(f"Deleted embedding for item {item_id}")
            return True

        except Exception as e:
            logger.error(f"Error deleting item {item_id}: {str(e)}")
            return False

    async def batch_delete(self, item_ids: List[str]) -> int:
        """Delete multiple items' embeddings.

        Args:
            item_ids: Items to delete

        Returns:
            Number of successfully deleted items
        """
        if not item_ids:
            return 0

        try:
            self.index.delete(ids=item_ids)
            logger.info(f"Deleted {len(item_ids)} embeddings")
            return len(item_ids)

        except Exception as e:
            logger.error(f"Error in batch delete: {str(e)}")
            return 0

    async def delete_user_items(self, user_id: str) -> int:
        """Delete all embeddings for a user.

        Args:
            user_id: User whose items to delete

        Returns:
            Number of deleted items
        """
        try:
            # Query for all items with this user_id
            results = self.index.query(
                vector=[0.0] * settings.PINECONE_DIMENSION,
                filter={"user_id": {"$eq": user_id}},
                top_k=10000,
                include_metadata=False
            )

            item_ids = [match.id for match in results.matches]

            if item_ids:
                await self.batch_delete(item_ids)
                return len(item_ids)

            return 0

        except Exception as e:
            logger.error(f"Error deleting user items: {str(e)}")
            return 0

    # ========================================================================
    # SEARCH OPERATIONS
    # ========================================================================

    async def find_similar(
        self,
        embedding: List[float],
        user_id: Optional[str] = None,
        category: Optional[str] = None,
        colors: Optional[List[str]] = None,
        exclude_item_ids: Optional[List[str]] = None,
        top_k: int = 10,
        min_score: float = 0.0
    ) -> List[Dict[str, Any]]:
        """Find similar items by vector similarity.

        Args:
            embedding: Query vector
            user_id: Filter to specific user's items
            category: Filter by category
            colors: Filter by colors (items must have at least one)
            exclude_item_ids: Items to exclude from results
            top_k: Maximum results
            min_score: Minimum similarity score (0-1)

        Returns:
            List of similar items with scores
        """
        try:
            # Build filter
            filter_dict = {}

            if user_id:
                filter_dict["user_id"] = {"$eq": user_id}

            if category:
                filter_dict["category"] = {"$eq": category}

            if colors:
                filter_dict["colors"] = {"$in": colors}

            # Query Pinecone
            results = self.index.query(
                vector=embedding,
                filter=filter_dict if filter_dict else None,
                top_k=top_k * 2,  # Get more to filter and score
                include_metadata=True
            )

            # Process results
            items = []
            for match in results.matches:
                if exclude_item_ids and match.id in exclude_item_ids:
                    continue

                if match.score < min_score:
                    continue

                items.append({
                    "item_id": match.id,
                    "score": match.score,
                    "metadata": match.metadata or {}
                })

            return items[:top_k]

        except Exception as e:
            logger.error(f"Error finding similar items: {str(e)}")
            return []

    async def find_matching_items(
        self,
        item_ids: List[str],
        user_id: str,
        exclude_categories: Optional[List[str]] = None,
        top_k: int = 10
    ) -> Dict[str, List[Dict[str, Any]]]:
        """For each item, find matching items from other categories.

        Args:
            item_ids: Items to find matches for
            user_id: User's wardrobe to search within
            exclude_categories: Categories to exclude from matches
            top_k: Results per item

        Returns:
            Dict mapping item_id to list of matches
        """
        try:
            # Get embeddings for source items
            source_items = self.index.fetch(ids=item_ids)

            results = {}

            for item_id, vector_data in source_items.vectors.items():
                source_category = vector_data.metadata.get("category")
                embedding = vector_data.values

                # Build filter to get items from different categories
                filter_dict = {"user_id": {"$eq": user_id}}

                # Exclude the source item's category
                excluded = exclude_categories or []
                if source_category:
                    excluded.append(source_category)

                if excluded:
                    filter_dict["category"] = {"$nin": excluded}

                # Query
                matches = self.index.query(
                    vector=embedding,
                    filter=filter_dict,
                    top_k=top_k,
                    include_metadata=True
                )

                results[item_id] = [
                    {
                        "item_id": match.id,
                        "score": match.score,
                        "metadata": match.metadata or {}
                    }
                    for match in matches.matches
                    if match.id != item_id  # Exclude self
                ]

            return results

        except Exception as e:
            logger.error(f"Error finding matching items: {str(e)}")
            return {}

    async def search_by_metadata(
        self,
        user_id: str,
        category: Optional[str] = None,
        colors: Optional[List[str]] = None,
        brand: Optional[str] = None,
        limit: int = 100
    ) -> List[str]:
        """Search for items by metadata without vector query.

        Args:
            user_id: User's items to search
            category: Filter by category
            colors: Filter by colors
            brand: Filter by brand
            limit: Maximum results

        Returns:
            List of item IDs
        """
        try:
            # Use a zero vector for metadata-only search
            dummy_vector = [0.0] * settings.PINECONE_DIMENSION

            filter_dict = {"user_id": {"$eq": user_id}}

            if category:
                filter_dict["category"] = {"$eq": category}

            if colors:
                filter_dict["colors"] = {"$in": colors}

            if brand:
                filter_dict["brand"] = {"$eq": brand}

            results = self.index.query(
                vector=dummy_vector,
                filter=filter_dict,
                top_k=limit,
                include_metadata=False
            )

            return [match.id for match in results.matches]

        except Exception as e:
            logger.error(f"Error searching by metadata: {str(e)}")
            return []

    # ========================================================================
    # INDEX MANAGEMENT
    # ========================================================================

    def create_index(self) -> bool:
        """Create the Pinecone index if it doesn't exist.

        Returns:
            True if index exists or was created
        """
        try:
            existing_indexes = [idx.name for idx in self.pc.list_indexes()]

            if settings.PINECONE_INDEX_NAME in existing_indexes:
                logger.info(f"Index {settings.PINECONE_INDEX_NAME} already exists")
                return True

            # Create new index
            self.pc.create_index(
                name=settings.PINECONE_INDEX_NAME,
                dimension=settings.PINECONE_DIMENSION,
                metric="cosine",
                spec=ServerlessSpec(
                    cloud="aws",
                    region="us-east-1"  # Or your preferred region
                )
            )

            logger.info(f"Created index {settings.PINECONE_INDEX_NAME}")
            return True

        except Exception as e:
            logger.error(f"Error creating index: {str(e)}")
            return False

    def get_index_stats(self) -> Optional[Dict[str, Any]]:
        """Get statistics about the index.

        Returns:
            Index stats or None
        """
        try:
            return self.index.describe_index_stats()

        except Exception as e:
            logger.error(f"Error getting index stats: {str(e)}")
            return None

    # ========================================================================
    # UTILITY METHODS
    # ========================================================================

    @staticmethod
    def _prepare_metadata(metadata: Dict[str, Any]) -> Dict[str, Any]:
        """Prepare metadata for Pinecone (handle unsupported types).

        Pinecone metadata only supports: str, int, float, bool, List[str]
        """
        cleaned = {}

        for key, value in metadata.items():
            if value is None:
                continue

            if isinstance(value, (str, int, float, bool)):
                cleaned[key] = value
            elif isinstance(value, list):
                # Convert to list of strings
                cleaned[key] = [str(v) for v in value if v is not None]
            else:
                # Convert other types to string
                cleaned[key] = str(value)

        return cleaned

    @staticmethod
    def calculate_similarity(
        embedding_a: List[float],
        embedding_b: List[float]
    ) -> float:
        """Calculate cosine similarity between two embeddings.

        Args:
            embedding_a: First embedding
            embedding_b: Second embedding

        Returns:
            Similarity score (0-1)
        """
        import math

        if len(embedding_a) != len(embedding_b):
            raise ValueError("Embeddings must have same dimension")

        dot_product = sum(a * b for a, b in zip(embedding_a, embedding_b))
        magnitude_a = math.sqrt(sum(a * a for a in embedding_a))
        magnitude_b = math.sqrt(sum(b * b for b in embedding_b))

        if magnitude_a == 0 or magnitude_b == 0:
            return 0.0

        return dot_product / (magnitude_a * magnitude_b)


# Singleton instance
_vector_service: Optional[VectorService] = None


def get_vector_service() -> VectorService:
    """Get the singleton VectorService instance."""
    global _vector_service
    if _vector_service is None:
        _vector_service = VectorService()
    return _vector_service
