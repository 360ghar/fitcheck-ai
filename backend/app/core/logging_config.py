"""
Logging configuration for FitCheck AI backend.

Creates a new log file for each server session with:
- Structured JSON format for production (file logs)
- Pretty console format for development
- Correlation ID support for request tracing
- ContextLogger for structured logging with automatic context
"""

import json
import logging
import sys
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, Optional

from app.core.config import settings


class ContextLogger:
    """Logger wrapper that automatically includes correlation ID and context.

    This provides a convenient interface for structured logging that
    automatically includes request context in all log messages.

    Usage:
        logger = get_context_logger(__name__)
        logger.info("Creating item", item_name="shirt", category="tops")
        logger.error("Failed to create item")  # Auto-includes exc_info
    """

    def __init__(self, name: str):
        self._logger = logging.getLogger(name)

    @property
    def name(self) -> str:
        return self._logger.name

    def _log(
        self,
        level: int,
        message: str,
        exc_info: bool = False,
        **extra: Any
    ) -> None:
        """Internal method to log with context."""
        # Extra kwargs become extra fields in the log record
        self._logger.log(level, message, exc_info=exc_info, extra=extra)

    def debug(self, message: str, **extra: Any) -> None:
        """Log a debug message."""
        self._log(logging.DEBUG, message, **extra)

    def info(self, message: str, **extra: Any) -> None:
        """Log an info message."""
        self._log(logging.INFO, message, **extra)

    def warning(self, message: str, **extra: Any) -> None:
        """Log a warning message."""
        self._log(logging.WARNING, message, **extra)

    def error(self, message: str, exc_info: bool = True, **extra: Any) -> None:
        """Log an error message. Includes exception info by default."""
        self._log(logging.ERROR, message, exc_info=exc_info, **extra)

    def exception(self, message: str, **extra: Any) -> None:
        """Log an error message with exception traceback."""
        self._log(logging.ERROR, message, exc_info=True, **extra)

    def critical(self, message: str, exc_info: bool = True, **extra: Any) -> None:
        """Log a critical message."""
        self._log(logging.CRITICAL, message, exc_info=exc_info, **extra)


def get_context_logger(name: str) -> ContextLogger:
    """Get a context-aware logger instance.

    This is the recommended way to get a logger in FitCheck AI.
    The returned logger automatically includes correlation ID and
    request context in all log messages.

    Args:
        name: Logger name (typically __name__ from the calling module)

    Returns:
        ContextLogger instance with automatic context injection
    """
    return ContextLogger(name)


class JsonFormatter(logging.Formatter):
    """JSON log formatter for structured logging in production.

    Outputs logs as JSON objects for easy parsing by log aggregation tools.
    Automatically includes correlation_id, user_id, and any extra fields.
    """

    # Fields that are part of the standard LogRecord and should not be duplicated
    STANDARD_FIELDS = {
        "name", "msg", "args", "created", "filename", "funcName",
        "levelname", "levelno", "lineno", "module", "msecs",
        "pathname", "process", "processName", "relativeCreated",
        "stack_info", "exc_info", "exc_text", "thread", "threadName",
        "message", "correlation_id", "user_id", "asctime", "taskName",
    }

    def format(self, record: logging.LogRecord) -> str:
        log_data: Dict[str, Any] = {
            "timestamp": self.formatTime(record, self.datefmt),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "correlation_id": getattr(record, "correlation_id", None),
        }

        # Add user_id if present in context
        user_id = getattr(record, "user_id", None)
        if user_id:
            log_data["user_id"] = user_id

        # Add source location for errors
        if record.levelno >= logging.WARNING:
            log_data["location"] = {
                "file": record.filename,
                "line": record.lineno,
                "function": record.funcName,
            }

        # Add exception info if present
        if record.exc_info:
            log_data["exception"] = self.formatException(record.exc_info)

        # Add any extra fields passed via logger.info("msg", extra={...})
        for key, value in record.__dict__.items():
            if key not in self.STANDARD_FIELDS:
                log_data[key] = value

        return json.dumps(log_data, default=str)


class PrettyFormatter(logging.Formatter):
    """Pretty console formatter for development.

    Uses colors to highlight different log levels and includes
    correlation ID and user ID for tracing. Context fields are
    displayed on separate lines with tree-style connectors.
    """

    # Level colors (for level name badge)
    COLORS = {
        logging.DEBUG: "\033[36m",    # Cyan
        logging.INFO: "\033[32m",     # Green
        logging.WARNING: "\033[33m",  # Yellow
        logging.ERROR: "\033[31m",    # Red
        logging.CRITICAL: "\033[35m", # Magenta
    }

    # Bold level colors (for main message)
    BOLD_COLORS = {
        logging.DEBUG: "\033[1;36m",    # Bold Cyan
        logging.INFO: "\033[1;32m",     # Bold Green
        logging.WARNING: "\033[1;33m",  # Bold Yellow
        logging.ERROR: "\033[1;31m",    # Bold Red
        logging.CRITICAL: "\033[1;35m", # Bold Magenta
    }

    RESET = "\033[0m"
    DIM = "\033[2m"
    DIM_WHITE = "\033[2;37m"
    BLUE = "\033[34m"
    DIM_CYAN = "\033[2;36m"
    MAGENTA = "\033[35m"
    CYAN = "\033[36m"
    RED = "\033[31m"
    BOLD_RED = "\033[1;31m"

    # Fields that are part of the standard LogRecord and should not be shown as context
    STANDARD_FIELDS = {
        "name", "msg", "args", "created", "filename", "funcName",
        "levelname", "levelno", "lineno", "module", "msecs",
        "pathname", "process", "processName", "relativeCreated",
        "stack_info", "exc_info", "exc_text", "thread", "threadName",
        "message", "correlation_id", "user_id", "asctime", "taskName",
    }

    def _format_context(self, record: logging.LogRecord, indent: int) -> str:
        """Format extra context fields with tree-style connectors and colors.

        Args:
            record: The log record containing extra fields
            indent: Number of spaces to indent the context lines

        Returns:
            Formatted context string with newlines, or empty string if no context
        """
        # Extract extra fields (exclude standard logging fields)
        extra = {k: v for k, v in record.__dict__.items()
                 if k not in self.STANDARD_FIELDS}
        if not extra:
            return ""

        # Format with tree connectors
        lines = []
        items = list(extra.items())
        for i, (key, value) in enumerate(items):
            connector = "└─" if i == len(items) - 1 else "├─"
            # Color error keys/values in red to stand out
            if key == "error":
                formatted = f"{self.BOLD_RED}{key}{self.RESET}: {self.RED}{value}{self.RESET}"
            else:
                formatted = f"{self.MAGENTA}{key}{self.RESET}: {self.CYAN}{value}{self.RESET}"
            lines.append(f"{' ' * indent}{connector} {formatted}")
        return "\n" + "\n".join(lines)

    def format(self, record: logging.LogRecord) -> str:
        # Get correlation ID if available
        correlation_id = getattr(record, "correlation_id", None)
        correlation_str = f"[{correlation_id[:8]}]" if correlation_id else "[--------]"

        # Get user_id if available
        user_id = getattr(record, "user_id", None)
        user_str = f" u:{user_id[:8]}" if user_id else ""

        # Color the level name badge
        level_color = self.COLORS.get(record.levelno, "")
        level = f"{level_color}{record.levelname:8}{self.RESET}"

        # Bold color for the main message (matches log level)
        msg_color = self.BOLD_COLORS.get(record.levelno, "")

        # Format timestamp in dim white
        timestamp = f"{self.DIM_WHITE}{self.formatTime(record, '%H:%M:%S')}{self.RESET}"

        # Shorten and color logger name in blue
        logger_name = record.name
        if logger_name.startswith("app."):
            logger_name = logger_name[4:]  # Remove "app." prefix
        if len(logger_name) > 20:
            logger_name = "..." + logger_name[-17:]
        logger_name = f"{self.BLUE}{logger_name:20}{self.RESET}"

        # Format correlation ID and user in dim cyan
        context_str = f"{self.DIM_CYAN}{correlation_str}{user_str}{self.RESET}"

        # Color the main message with bold level color
        main_message = f"{msg_color}{record.getMessage()}{self.RESET}"

        # Build the log line
        message = f"{timestamp} │ {level} │ {logger_name} │ {context_str} {main_message}"

        # Calculate indent for context lines (aligns with message start)
        # Format: "HH:MM:SS │ LEVEL    │ logger_name          │ [corr_id] "
        indent = 8 + 3 + 8 + 3 + 20 + 3 + len(correlation_str) + len(user_str) + 1  # ~58 chars

        # Add context fields if any
        message += self._format_context(record, indent)

        # Add exception if present (and not just NoneType: None)
        if record.exc_info and record.exc_info[0] is not None:
            exc_text = self.formatException(record.exc_info)
            # Color exception in red
            message += f"\n{self.RED}{exc_text}{self.RESET}"

        return message


def setup_session_logging() -> str:
    """Configure logging for this server session.
    
    Returns:
        Path to the log file for this session.
    """
    # Create logs directory relative to backend root
    log_dir = Path(__file__).parent.parent.parent / settings.LOG_DIR
    log_dir.mkdir(exist_ok=True)

    # Generate timestamped filename
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    log_file = log_dir / f"session_{timestamp}.log"

    # Determine log level
    log_level = getattr(logging, settings.LOG_LEVEL.upper(), logging.INFO)

    # Clear existing handlers from root logger
    root_logger = logging.getLogger()
    root_logger.handlers.clear()
    root_logger.setLevel(log_level)

    # Add correlation ID filter to all log records
    from app.core.middleware import CorrelationIdLogFilter
    correlation_filter = CorrelationIdLogFilter()

    # File handler with JSON format for production
    file_handler = logging.FileHandler(log_file)
    file_handler.setLevel(log_level)
    file_handler.setFormatter(JsonFormatter())
    file_handler.addFilter(correlation_filter)
    root_logger.addHandler(file_handler)

    # Console handler with pretty format for development
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(log_level)

    # Always use pretty format for console (readable), JSON for file logs (parseable)
    console_handler.setFormatter(PrettyFormatter())
    
    console_handler.addFilter(correlation_filter)
    root_logger.addHandler(console_handler)

    # Reduce noise from third-party libraries
    logging.getLogger("httpx").setLevel(logging.WARNING)
    logging.getLogger("httpcore").setLevel(logging.WARNING)
    logging.getLogger("urllib3").setLevel(logging.WARNING)
    logging.getLogger("hpack").setLevel(logging.WARNING)
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)

    return str(log_file)


def get_logger(name: str) -> logging.Logger:
    """Get a logger instance with the given name.

    Convenience function that ensures loggers are properly namespaced.

    Args:
        name: Logger name (typically __name__ from the calling module)

    Returns:
        Configured logger instance
    """
    return logging.getLogger(name)


def sanitize_for_logging(data: Any, max_str_length: int = 100) -> Any:
    """
    Recursively sanitize data for logging by truncating long strings (like base64 images).

    Args:
        data: The data to sanitize (dict, list, str, or other)
        max_str_length: Maximum length for string values before truncation

    Returns:
        Sanitized copy of the data with long strings truncated
    """
    if isinstance(data, str):
        if len(data) > max_str_length:
            return f"{data[:50]}...[truncated {len(data)} chars]"
        return data
    elif isinstance(data, dict):
        return {k: sanitize_for_logging(v, max_str_length) for k, v in data.items()}
    elif isinstance(data, list):
        return [sanitize_for_logging(item, max_str_length) for item in data]
    return data
