"""
Gamification models for database and Pydantic validation.

Implements user engagement features including:
- Streaks tracking
- Achievement badges
- Challenges and competitions
- Reward points
"""

from datetime import datetime, timedelta
from typing import Optional, List
from uuid import UUID, uuid4
from enum import Enum

from sqlalchemy import Column, String, DateTime, Boolean, Integer, Text, ForeignKey, Float, JSON
from sqlalchemy.dialects.postgresql import UUID as PGUUID, ARRAY
from sqlalchemy.orm import relationship

from app.db.base_class import Base


class AchievementType(str, Enum):
    """Types of achievements."""
    WARDROBE = "wardrobe"          # Wardrobe-related achievements
    OUTFIT = "outfit"              # Outfit creation achievements
    SOCIAL = "social"              # Social engagement achievements
    STREAK = "streak"              # Streak-based achievements
    CALENDAR = "calendar"          # Calendar planning achievements
    COMMUNITY = "community"        # Community participation


class DifficultyLevel(str, Enum):
    """Difficulty levels for challenges/achievements."""
    EASY = "easy"
    MEDIUM = "medium"
    HARD = "hard"
    EXPERT = "expert"


class ChallengeStatus(str, Enum):
    """Status of user challenge participation."""
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    EXPIRED = "expired"


# ============================================================================
# ACHIEVEMENT DEFINITIONS
# ============================================================================

class Achievement(Base):
    """
    Achievement badges users can unlock.

    Includes definition of achievement criteria, rewards, and display info.
    """

    __tablename__ = "achievements"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=uuid4)

    # Identification
    slug = Column(String(100), unique=True, nullable=False, index=True)
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)

    # Categorization
    achievement_type = Column(String(50), nullable=False, index=True)
    difficulty = Column(String(20), nullable=False)

    # Criteria (JSON for flexibility)
    criteria = Column(JSON, nullable=True)  # e.g., {"items_added": 10}
    target_value = Column(Integer, nullable=True)  # Target for numeric criteria

    # Rewards
    xp_reward = Column(Integer, default=0)
    badge_url = Column(String(500), nullable=True)
    custom_icon = Column(String(100), nullable=True)

    # Display
    is_hidden = Column(Boolean, default=False)  # Hidden until unlocked
    is_active = Column(Boolean, default=True)
    sort_order = Column(Integer, default=0)

    # Timestamps
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    user_achievements = relationship("UserAchievement", back_populates="achievement")


class UserAchievement(Base):
    """
    Records when a user unlocks an achievement.

    Tracks progress and completion status.
    """

    __tablename__ = "user_achievements"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=uuid4)
    user_id = Column(PGUUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    achievement_id = Column(PGUUID(as_uuid=True), ForeignKey("achievements.id"), nullable=False, index=True)

    # Progress tracking
    progress = Column(Integer, default=0)  # Current progress value
    is_completed = Column(Boolean, default=False, nullable=False, index=True)
    completed_at = Column(DateTime(timezone=True), nullable=True)

    # Metadata
    progress_data = Column(JSON, nullable=True)  # Additional progress context

    # Timestamps
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    achievement = relationship("Achievement", back_populates="user_achievements")


# ============================================================================
# STREAKS
# ============================================================================

class UserStreak(Base):
    """
    Tracks user activity streaks.

    Supports multiple streak types (logging outfits, planning, social engagement).
    """

    __tablename__ = "user_streaks"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=uuid4)
    user_id = Column(PGUUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)

    # Streak identification
    streak_type = Column(String(50), nullable=False, index=True)  # 'outfit_log', 'daily_plan', 'social_engagement'
    name = Column(String(255), nullable=False)

    # Current streak
    current_streak = Column(Integer, default=0, nullable=False)
    last_activity_at = Column(DateTime(timezone=True), nullable=False)
    streak_start_date = Column(DateTime(timezone=True), nullable=False)

    # Best streak
    longest_streak = Column(Integer, default=0, nullable=False)
    longest_streak_end_date = Column(DateTime(timezone=True), nullable=True)

    # Metadata
    activity_dates = Column(ARRAY(DateTime(timezone=True)), nullable=True)  # Track activity days

    # Timestamps
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)


# ============================================================================
# CHALLENGES
# ============================================================================

class Challenge(Base):
    """
    Time-limited challenges users can participate in.

    Can be community-wide or individual challenges.
    """

    __tablename__ = "challenges"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=uuid4)

    # Basic info
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    subtitle = Column(String(500), nullable=True)

    # Challenge parameters
    challenge_type = Column(String(50), nullable=False)  # 'outfit_creation', 'wardrobe_variety', 'social'
    difficulty = Column(String(20), nullable=False)
    criteria = Column(JSON, nullable=True)  # e.g., {"outfits_to_create": 7, "days": 7}

    # Rewards
    xp_reward = Column(Integer, default=0)
    badge_unlock_id = Column(PGUUID(as_uuid=True), ForeignKey("achievements.id"), nullable=True)
    reward_description = Column(Text, nullable=True)

    # Timing
    start_date = Column(DateTime(timezone=True), nullable=False)
    end_date = Column(DateTime(timezone=True), nullable=False, index=True)

    # Status
    is_active = Column(Boolean, default=True)
    max_participants = Column(Integer, nullable=True)  # NULL = unlimited
    participant_count = Column(Integer, default=0)

    # Display
    cover_image_url = Column(String(500), nullable=True)
    featured = Column(Boolean, default=False)

    # Timestamps
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    participations = relationship("ChallengeParticipation", back_populates="challenge")


class ChallengeParticipation(Base):
    """
    Records user participation in challenges.

    Tracks progress towards challenge completion.
    """

    __tablename__ = "challenge_participations"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=uuid4)
    user_id = Column(PGUUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    challenge_id = Column(PGUUID(as_uuid=True), ForeignKey("challenges.id"), nullable=False, index=True)

    # Status
    status = Column(String(20), default="in_progress", nullable=False, index=True)

    # Progress
    progress = Column(Integer, default=0)
    progress_data = Column(JSON, nullable=True)

    # Completion
    completed_at = Column(DateTime(timezone=True), nullable=True)
    rank = Column(Integer, nullable=True)  # Final ranking if competitive

    # Timestamps
    joined_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    challenge = relationship("Challenge", back_populates="participations")


# ============================================================================
# REWARD POINTS
# ============================================================================

class UserPoints(Base):
    """
    Tracks user reward points and level.

    Users earn XP through various activities and level up.
    """

    __tablename__ = "user_points"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=uuid4)
    user_id = Column(PGUUID(as_uuid=True), ForeignKey("users.id"), unique=True, nullable=False, index=True)

    # Points
    total_points = Column(Integer, default=0, nullable=False)
    available_points = Column(Integer, default=0, nullable=False)  # Points not spent
    spent_points = Column(Integer, default=0, nullable=False)

    # Level calculation
    level = Column(Integer, default=1, nullable=False)
    xp_to_next_level = Column(Integer, nullable=False)

    # Statistics
    points_from_achievements = Column(Integer, default=0)
    points_from_challenges = Column(Integer, default=0)
    points_from_streaks = Column(Integer, default=0)
    points_from_social = Column(Integer, default=0)

    # Timestamps
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    @staticmethod
    def calculate_xp_for_level(level: int) -> int:
        """Calculate total XP needed for a given level."""
        # Formula: 100 * level^1.5
        return int(100 * (level ** 1.5))

    @staticmethod
    def calculate_level_from_xp(total_xp: int) -> tuple[int, int]:
        """Calculate level and XP to next level from total XP."""
        level = 1
        while UserPoints.calculate_xp_for_level(level + 1) <= total_xp:
            level += 1
        xp_for_current = UserPoints.calculate_xp_for_level(level)
        xp_to_next = UserPoints.calculate_xp_for_level(level + 1) - total_xp
        return level, xp_to_next


# ============================================================================
# ACTIVITY LOG
# ============================================================================

class ActivityLog(Base):
    """
    Logs user activities for gamification tracking.

    Records events like item additions, outfit creation, social engagement.
    """

    __tablename__ = "activity_logs"

    id = Column(PGUUID(as_uuid=True), primary_key=True, default=uuid4)
    user_id = Column(PGUUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)

    # Activity details
    activity_type = Column(String(50), nullable=False, index=True)
    activity_name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)

    # Related entities
    entity_type = Column(String(50), nullable=True)  # 'item', 'outfit', 'challenge', etc.
    entity_id = Column(PGUUID(as_uuid=True), nullable=True)

    # Points awarded
    points_earned = Column(Integer, default=0)
    xp_earned = Column(Integer, default=0)

    # Metadata
    metadata = Column(JSON, nullable=True)

    # Timestamps
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow, nullable=False, index=True)

    # Index for recent activities
    __table_args__ = (
        {'indexes': [
            {'name': 'idx_activity_logs_user_type', 'columns': ['user_id', 'activity_type']},
            {'name': 'idx_activity_logs_created', 'columns': ['created_at']},
        ]}
    )
