#!/usr/bin/env python3
"""Enforce FitCheck layer boundaries for agents and CI.

Backend rules:
  - services, models, core, db, agents must not import app.api
  - models must not import app.services
  - core must not import app.services or app.api
  - db must not import app.services
  - utils (app/utils/) is infrastructure helpers: must not import api or services

Frontend rules (light string scan):
  - src/api must not import pages or components
  - src/stores must not import pages

Error messages include remediation so agents can fix without extra context.
"""

from __future__ import annotations

import ast
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BACKEND_APP = ROOT / "backend" / "app"
FRONTEND_SRC = ROOT / "frontend" / "src"

KNOWN_LAYERS = frozenset({"api", "services", "models", "core", "db", "agents", "utils"})

errors: list[str] = []


def module_prefix(path: Path) -> str:
    rel = path.relative_to(BACKEND_APP)
    parts = list(rel.parts[:-1]) + [rel.stem if rel.stem != "__init__" else ""]
    parts = [p for p in parts if p]
    return "app." + ".".join(parts) if parts else "app"


def layer_of(mod: str) -> str | None:
    if mod.startswith("app.api"):
        return "api"
    if mod.startswith("app.services"):
        return "services"
    if mod.startswith("app.models"):
        return "models"
    if mod.startswith("app.core"):
        return "core"
    if mod.startswith("app.db"):
        return "db"
    if mod.startswith("app.agents"):
        return "agents"
    if mod.startswith("app.utils"):
        return "utils"
    if mod == "app" or mod.startswith("app.main"):
        return "main"
    return None


def collect_imports(path: Path, tree: ast.AST) -> list[str]:
    """Collect absolute app.* import module strings from an AST.

    Handles:
      import app.services.x
      from app.services import x
      from app import services   → app.services (known layer name)
      from . import foo (relative, resolved against file package)
    """
    imports: list[str] = []
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            for alias in node.names:
                imports.append(alias.name)
        elif isinstance(node, ast.ImportFrom):
            if node.level and node.level > 0:
                # relative import — resolve roughly from file package
                base_parts = list(path.relative_to(BACKEND_APP).parts[:-1])
                up = node.level - 1
                if up:
                    base_parts = base_parts[:-up] if up <= len(base_parts) else []
                if node.module:
                    mod_parts = base_parts + node.module.split(".")
                else:
                    mod_parts = base_parts
                base_mod = "app." + ".".join(mod_parts) if mod_parts else "app"
                imports.append(base_mod)
                # from . import services  (relative bare names that are layers)
                if not node.module:
                    for alias in node.names:
                        if alias.name in KNOWN_LAYERS:
                            imports.append(f"{base_mod}.{alias.name}" if base_mod != "app" else f"app.{alias.name}")
            elif node.module:
                imports.append(node.module)
                # from app import services / from app import api, models
                # Treat known layer names as importing that layer.
                if node.module == "app":
                    for alias in node.names:
                        if alias.name in KNOWN_LAYERS:
                            imports.append(f"app.{alias.name}")
                # from app.X import Y is already covered by node.module
    return imports


def check_backend_file(path: Path) -> None:
    try:
        tree = ast.parse(path.read_text(encoding="utf-8"), filename=str(path))
    except SyntaxError as e:
        errors.append(f"{path}: syntax error: {e}")
        return

    file_mod = module_prefix(path)
    file_layer = layer_of(file_mod) or layer_of("app." + path.relative_to(BACKEND_APP).parts[0])

    # Classify by path first (more reliable for __init__ and nested packages)
    rel = path.relative_to(BACKEND_APP)
    top = rel.parts[0] if rel.parts else ""
    path_layer = {
        "api": "api",
        "services": "services",
        "models": "models",
        "core": "core",
        "db": "db",
        "agents": "agents",
        "utils": "utils",
    }.get(top)
    if path.name == "main.py":
        path_layer = "main"
    file_layer = path_layer or file_layer

    imports = collect_imports(path, tree)

    for imp in imports:
        if not imp.startswith("app"):
            continue
        target = layer_of(imp)
        if not target or not file_layer:
            continue

        # services/models/core/db/agents must not import api
        if file_layer in {"services", "models", "core", "db", "agents"} and target == "api":
            errors.append(
                f"{path}: layer '{file_layer}' imports '{imp}' (api). "
                f"REMEDIATE: move orchestration into services; routes may call services, "
                f"not the reverse. See ARCHITECTURE.md."
            )
        if file_layer == "models" and target == "services":
            errors.append(
                f"{path}: models import '{imp}' (services). "
                f"REMEDIATE: keep schemas free of business logic; put logic in services. "
                f"See ARCHITECTURE.md."
            )
        if file_layer == "core" and target == "services":
            errors.append(
                f"{path}: core imports '{imp}' (services). "
                f"REMEDIATE: core must stay dependency-free of domain services. "
                f"See ARCHITECTURE.md."
            )
        # db must not import services (ARCHITECTURE.md: DB may import core only)
        if file_layer == "db" and target == "services":
            errors.append(
                f"{path}: layer 'db' imports '{imp}' (services). "
                f"REMEDIATE: db must not depend on services; keep data access free of "
                f"business logic. See ARCHITECTURE.md."
            )
        # utils are infrastructure helpers — must not import api or services
        if file_layer == "utils" and target in {"api", "services"}:
            errors.append(
                f"{path}: layer 'utils' imports '{imp}' ({target}). "
                f"REMEDIATE: app/utils/ is infrastructure helpers only and must not import "
                f"api or services (avoids reverse deps and circular graphs). Move domain "
                f"logic into services; keep utils pure. See ARCHITECTURE.md."
            )


def check_backend() -> None:
    if not BACKEND_APP.is_dir():
        errors.append(f"missing backend app at {BACKEND_APP}")
        return
    for path in BACKEND_APP.rglob("*.py"):
        if "__pycache__" in path.parts:
            continue
        check_backend_file(path)


def check_frontend() -> None:
    if not FRONTEND_SRC.is_dir():
        return

    api_dir = FRONTEND_SRC / "api"
    stores_dir = FRONTEND_SRC / "stores"
    import_re = re.compile(
        r"""from\s+['"]([^'"]+)['"]|import\s+['"]([^'"]+)['"]"""
    )

    def scan(directory: Path, forbidden_substrings: list[str], layer_name: str) -> None:
        if not directory.is_dir():
            return
        for path in list(directory.rglob("*.ts")) + list(directory.rglob("*.tsx")):
            text = path.read_text(encoding="utf-8", errors="replace")
            for match in import_re.finditer(text):
                spec = match.group(1) or match.group(2) or ""
                for bad in forbidden_substrings:
                    if bad in spec:
                        errors.append(
                            f"{path}: {layer_name} imports '{spec}'. "
                            f"REMEDIATE: {layer_name} must not depend on {bad}. "
                            f"Invert the dependency (pages/components call api/stores). "
                            f"See ARCHITECTURE.md."
                        )

    scan(api_dir, ["@/pages", "@/components", "/pages/", "/components/"], "api")
    scan(stores_dir, ["@/pages", "/pages/"], "stores")


def main() -> int:
    check_backend()
    check_frontend()
    if errors:
        print(f"Architecture check failed ({len(errors)} issue(s)):\n", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        return 1
    print("Architecture check passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
