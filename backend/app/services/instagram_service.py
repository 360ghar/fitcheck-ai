"""
Instagram Scraping Service.

Provides Instagram scraping functionality using instaloader for fetching
images from public profiles and posts.
"""

import asyncio
import base64
import logging
import re
from datetime import datetime
from typing import Any, AsyncGenerator, Dict, List, Optional, Tuple

import httpx

from app.models.instagram import (
    InstagramImageMeta,
    InstagramProfileInfo,
    InstagramURLType,
    InstagramURLValidation,
)

logger = logging.getLogger(__name__)


# =============================================================================
# URL PATTERNS
# =============================================================================


# Instagram URL patterns
PROFILE_URL_PATTERN = re.compile(
    r'^https?://(?:www\.)?instagram\.com/([a-zA-Z0-9_.]+)/?(?:\?.*)?$'
)
POST_URL_PATTERN = re.compile(
    r'^https?://(?:www\.)?instagram\.com/p/([a-zA-Z0-9_-]+)/?(?:\?.*)?$'
)
REEL_URL_PATTERN = re.compile(
    r'^https?://(?:www\.)?instagram\.com/reel/([a-zA-Z0-9_-]+)/?(?:\?.*)?$'
)


# =============================================================================
# INSTAGRAM SERVICE
# =============================================================================


class InstagramService:
    """Service for scraping Instagram images."""

    def __init__(self):
        """Initialize the Instagram service."""
        self._http_client: Optional[httpx.AsyncClient] = None
        self._loader = None  # Lazy-loaded instaloader instance
        self._logged_in_user: Optional[str] = None

    async def _get_http_client(self) -> httpx.AsyncClient:
        """Get or create HTTP client."""
        if self._http_client is None or self._http_client.is_closed:
            self._http_client = httpx.AsyncClient(
                timeout=httpx.Timeout(30.0),
                headers={
                    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
                },
                follow_redirects=True,
            )
        return self._http_client

    def _get_loader(self):
        """Get or create instaloader instance."""
        if self._loader is None:
            try:
                import instaloader
                self._loader = instaloader.Instaloader(
                    download_pictures=False,
                    download_videos=False,
                    download_video_thumbnails=False,
                    download_geotags=False,
                    download_comments=False,
                    save_metadata=False,
                    compress_json=False,
                    quiet=True,
                )
            except ImportError:
                logger.error("instaloader not installed. Run: pip install instaloader")
                raise RuntimeError("instaloader library not installed")
        return self._loader

    # =========================================================================
    # AUTHENTICATION
    # =========================================================================

    async def login(self, username: str, password: str) -> Dict[str, Any]:
        """
        Login to Instagram with username and password.

        Args:
            username: Instagram username
            password: Instagram password

        Returns:
            Dict with success status and error message if failed
        """
        try:
            import instaloader

            loader = self._get_loader()

            # Run login in thread pool (it's synchronous)
            loop = asyncio.get_event_loop()
            result = await loop.run_in_executor(
                None,
                lambda: self._do_login(loader, username, password)
            )

            if result["success"]:
                self._logged_in_user = username

            return result

        except Exception as e:
            logger.error(f"Instagram login failed: {e}")
            return {
                "success": False,
                "error": str(e),
            }

    def _do_login(self, loader, username: str, password: str) -> Dict[str, Any]:
        """Perform the actual login (synchronous)."""
        try:
            import instaloader

            loader.login(username, password)
            logger.info(f"Instagram login successful for {username}")
            return {"success": True}

        except instaloader.exceptions.BadCredentialsException:
            return {"success": False, "error": "Invalid username or password"}
        except instaloader.exceptions.TwoFactorAuthRequiredException:
            return {"success": False, "error": "Two-factor authentication is enabled. Please disable it temporarily or use an app password."}
        except instaloader.exceptions.ConnectionException as e:
            return {"success": False, "error": f"Connection error: {str(e)}"}
        except Exception as e:
            return {"success": False, "error": str(e)}

    def get_session_data(self) -> Optional[Dict[str, Any]]:
        """
        Get current session data for storage.

        Returns:
            Session data dict or None if not logged in
        """
        try:
            loader = self._get_loader()
            if not self._logged_in_user:
                return None

            # Get session cookies from instaloader context
            context = loader.context
            return {
                "username": context.username,
                "session_cookies": dict(context._session.cookies),
            }
        except Exception as e:
            logger.error(f"Failed to get session data: {e}")
            return None

    async def load_session(self, session_data: Dict[str, Any]) -> bool:
        """
        Load a saved session.

        Args:
            session_data: Previously saved session data

        Returns:
            True if session loaded successfully
        """
        try:
            import instaloader

            loader = self._get_loader()
            username = session_data.get("username")
            cookies = session_data.get("session_cookies", {})

            if not username or not cookies:
                return False

            # Load session cookies
            loop = asyncio.get_event_loop()
            success = await loop.run_in_executor(
                None,
                lambda: self._do_load_session(loader, username, cookies)
            )

            if success:
                self._logged_in_user = username

            return success

        except Exception as e:
            logger.error(f"Failed to load session: {e}")
            return False

    def _do_load_session(self, loader, username: str, cookies: Dict) -> bool:
        """Load session cookies (synchronous)."""
        try:
            # Set cookies on the session
            for name, value in cookies.items():
                loader.context._session.cookies.set(name, value)

            loader.context.username = username

            # Test if session is valid by making a simple request
            try:
                loader.context.get_json("", {})
                return True
            except Exception:
                # Session might still be valid, just check login state
                return loader.context.is_logged_in

        except Exception as e:
            logger.error(f"Failed to load session cookies: {e}")
            return False

    def is_logged_in(self) -> bool:
        """Check if currently logged in."""
        try:
            loader = self._get_loader()
            return loader.context.is_logged_in
        except Exception:
            return False

    def get_logged_in_user(self) -> Optional[str]:
        """Get the username of the logged-in user."""
        return self._logged_in_user

    def logout(self) -> None:
        """Logout and clear session."""
        self._logged_in_user = None
        self._loader = None  # Reset loader to clear session

    # =========================================================================
    # URL VALIDATION
    # =========================================================================

    def validate_url(self, url: str) -> InstagramURLValidation:
        """
        Validate an Instagram URL and determine its type.

        Args:
            url: Instagram URL to validate

        Returns:
            InstagramURLValidation with type and identifier
        """
        url = url.strip()

        # Check profile URL
        profile_match = PROFILE_URL_PATTERN.match(url)
        if profile_match:
            username = profile_match.group(1)
            # Exclude reserved paths
            reserved = {'p', 'reel', 'stories', 'explore', 'accounts', 'direct'}
            if username.lower() not in reserved:
                return InstagramURLValidation(
                    valid=True,
                    url_type=InstagramURLType.PROFILE,
                    identifier=username,
                )

        # Check post URL
        post_match = POST_URL_PATTERN.match(url)
        if post_match:
            return InstagramURLValidation(
                valid=True,
                url_type=InstagramURLType.POST,
                identifier=post_match.group(1),
            )

        # Check reel URL
        reel_match = REEL_URL_PATTERN.match(url)
        if reel_match:
            return InstagramURLValidation(
                valid=True,
                url_type=InstagramURLType.REEL,
                identifier=reel_match.group(1),
            )

        return InstagramURLValidation(
            valid=False,
            error="Please enter a valid Instagram URL (profile, post, or reel)",
        )

    # =========================================================================
    # PROFILE CHECKING
    # =========================================================================

    async def check_profile(self, username: str) -> InstagramProfileInfo:
        """
        Check if an Instagram profile is public and get basic info.

        Args:
            username: Instagram username

        Returns:
            InstagramProfileInfo with profile details
        """
        try:
            loader = self._get_loader()

            # Run instaloader in thread pool (it's synchronous)
            loop = asyncio.get_event_loop()
            profile = await loop.run_in_executor(
                None,
                lambda: self._load_profile(loader, username)
            )

            if profile is None:
                return InstagramProfileInfo(
                    username=username,
                    is_public=False,
                    error="Profile not found",
                )

            if profile.is_private:
                return InstagramProfileInfo(
                    username=profile.username,
                    is_public=False,
                    post_count=0,
                    profile_pic_url=profile.profile_pic_url,
                    full_name=profile.full_name,
                    bio=profile.biography,
                    error="This profile is private",
                )

            return InstagramProfileInfo(
                username=profile.username,
                is_public=True,
                post_count=profile.mediacount,
                profile_pic_url=profile.profile_pic_url,
                full_name=profile.full_name,
                bio=profile.biography,
            )

        except Exception as e:
            logger.error(f"Error checking profile {username}: {e}")
            return InstagramProfileInfo(
                username=username,
                is_public=False,
                error=str(e),
            )

    def _load_profile(self, loader, username: str):
        """Load profile using instaloader (synchronous)."""
        try:
            import instaloader
            return instaloader.Profile.from_username(loader.context, username)
        except Exception as e:
            logger.warning(f"Failed to load profile {username}: {e}")
            return None

    # =========================================================================
    # PROFILE SCRAPING
    # =========================================================================

    async def scrape_profile_images(
        self,
        username: str,
        max_posts: int = 200,
        on_progress: Optional[callable] = None,
        cancel_event: Optional[asyncio.Event] = None,
    ) -> AsyncGenerator[Tuple[List[InstagramImageMeta], int, int], None]:
        """
        Scrape images from an Instagram profile.

        Yields batches of images for SSE progress updates.

        Args:
            username: Instagram username
            max_posts: Maximum number of posts to scrape
            on_progress: Optional callback for progress updates
            cancel_event: Optional event for cancellation

        Yields:
            Tuple of (batch of images, scraped count, estimated total)
        """
        try:
            loader = self._get_loader()

            # Load profile
            loop = asyncio.get_event_loop()
            profile = await loop.run_in_executor(
                None,
                lambda: self._load_profile(loader, username)
            )

            if profile is None or profile.is_private:
                return

            total_posts = min(profile.mediacount, max_posts)
            scraped_count = 0
            batch: List[InstagramImageMeta] = []
            batch_size = 12  # Send updates every 12 images

            # Get posts iterator
            posts = profile.get_posts()

            for post in posts:
                # Check for cancellation
                if cancel_event and cancel_event.is_set():
                    break

                if scraped_count >= max_posts:
                    break

                # Extract images from post
                images = await self._extract_images_from_post(post)
                batch.extend(images)
                scraped_count += 1

                # Yield batch when full
                if len(batch) >= batch_size:
                    yield batch, scraped_count, total_posts
                    batch = []

                # Small delay to avoid rate limiting
                await asyncio.sleep(0.1)

            # Yield remaining images
            if batch:
                yield batch, scraped_count, total_posts

        except Exception as e:
            logger.error(f"Error scraping profile {username}: {e}")
            raise

    async def _extract_images_from_post(self, post) -> List[InstagramImageMeta]:
        """Extract image metadata from an Instagram post."""
        images: List[InstagramImageMeta] = []

        try:
            shortcode = post.shortcode
            timestamp = post.date_utc
            caption = post.caption[:500] if post.caption else None

            # Handle carousel posts (multiple images)
            if post.typename == "GraphSidecar":
                for idx, node in enumerate(post.get_sidecar_nodes()):
                    if not node.is_video:
                        images.append(InstagramImageMeta(
                            image_id=f"{shortcode}_{idx}",
                            image_url=node.display_url,
                            thumbnail_url=node.display_url,  # Use same URL
                            post_shortcode=shortcode,
                            post_url=f"https://instagram.com/p/{shortcode}/",
                            caption=caption,
                            timestamp=timestamp,
                            is_video=False,
                        ))
            elif not post.is_video:
                # Single image post
                images.append(InstagramImageMeta(
                    image_id=f"{shortcode}_0",
                    image_url=post.url,
                    thumbnail_url=post.url,
                    post_shortcode=shortcode,
                    post_url=f"https://instagram.com/p/{shortcode}/",
                    caption=caption,
                    timestamp=timestamp,
                    is_video=False,
                ))

        except Exception as e:
            logger.warning(f"Error extracting images from post: {e}")

        return images

    # =========================================================================
    # POST SCRAPING
    # =========================================================================

    async def scrape_post_images(self, shortcode: str) -> List[InstagramImageMeta]:
        """
        Scrape all images from a single Instagram post.

        Args:
            shortcode: Instagram post shortcode

        Returns:
            List of image metadata
        """
        try:
            loader = self._get_loader()

            # Load post in thread pool
            loop = asyncio.get_event_loop()
            post = await loop.run_in_executor(
                None,
                lambda: self._load_post(loader, shortcode)
            )

            if post is None:
                return []

            return await self._extract_images_from_post(post)

        except Exception as e:
            logger.error(f"Error scraping post {shortcode}: {e}")
            return []

    def _load_post(self, loader, shortcode: str):
        """Load post using instaloader (synchronous)."""
        try:
            import instaloader
            return instaloader.Post.from_shortcode(loader.context, shortcode)
        except Exception as e:
            logger.warning(f"Failed to load post {shortcode}: {e}")
            return None

    # =========================================================================
    # IMAGE DOWNLOADING
    # =========================================================================

    async def fetch_image_as_base64(self, image_url: str) -> Optional[str]:
        """
        Download an Instagram image and convert to base64.

        Args:
            image_url: URL of the Instagram image

        Returns:
            Base64-encoded image data, or None on failure
        """
        try:
            client = await self._get_http_client()
            response = await client.get(image_url)
            response.raise_for_status()

            # Encode to base64
            image_bytes = response.content
            base64_data = base64.b64encode(image_bytes).decode('utf-8')

            return base64_data

        except Exception as e:
            logger.error(f"Error fetching image {image_url}: {e}")
            return None

    async def fetch_images_as_base64(
        self,
        images: List[InstagramImageMeta],
        max_concurrent: int = 5,
    ) -> Dict[str, str]:
        """
        Download multiple Instagram images and convert to base64.

        Args:
            images: List of image metadata
            max_concurrent: Maximum concurrent downloads

        Returns:
            Dict mapping image_id to base64 data
        """
        semaphore = asyncio.Semaphore(max_concurrent)
        results: Dict[str, str] = {}

        async def fetch_one(image: InstagramImageMeta):
            async with semaphore:
                base64_data = await self.fetch_image_as_base64(image.image_url)
                if base64_data:
                    results[image.image_id] = base64_data

        await asyncio.gather(*[fetch_one(img) for img in images])
        return results

    # =========================================================================
    # CLEANUP
    # =========================================================================

    async def close(self):
        """Close HTTP client."""
        if self._http_client and not self._http_client.is_closed:
            await self._http_client.aclose()


# Singleton instance
_instagram_service: Optional[InstagramService] = None


def get_instagram_service() -> InstagramService:
    """Get singleton Instagram service instance."""
    global _instagram_service
    if _instagram_service is None:
        _instagram_service = InstagramService()
    return _instagram_service
