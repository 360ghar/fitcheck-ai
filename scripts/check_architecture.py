#!/usr/bin/env python3
"""Enforce FitCheck layer boundaries for agents and CI.

Backend rules:
  - services, models, core, db, agents must not import app.api
  - models must not import app.services
  - core must not import app.services or app.api
  - db must not import app.services
  - utils (app/utils/) is infrastructure helpers: must not import api or services

Frontend rules (regex-based TS/JS import scanner):
  - src/api must not import pages or components
  - src/stores must not import pages

Error messages include remediation so agents can fix without extra context.
"""

from __future__ import annotations

import ast
import json
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BACKEND_APP = ROOT / "backend" / "app"
FRONTEND_SRC = ROOT / "frontend" / "src"
FRONTEND_NODE_MODULES = ROOT / "frontend" / "node_modules"

KNOWN_LAYERS = frozenset({"api", "services", "models", "core", "db", "agents", "utils"})

# Regex scanner for TypeScript/JavaScript imports. Handles:
#   - static imports: import x from 'path'; import { y } from 'path'
#   - bare / side-effect imports: import 'path'
#   - barrel re-exports: export { X } from 'path'; export * from 'path'
#   - dynamic imports: const x = await import('path'); import('path')
#   - CommonJS: const x = require('path')

_IMPORT_FROM_RE = re.compile(r"""from\s+['"]([^'"]+)['"]""")
_BARE_IMPORT_RE = re.compile(r"""^\s*import\s+['"]([^'"]+)['"]""", re.MULTILINE)
_DYNAMIC_IMPORT_RE = re.compile(r"""(?:await\s+)?import\s*\(\s*['"]([^'"]+)['"]\s*\)""")
_REQUIRE_RE = re.compile(r"""\brequire\s*\(\s*['"]([^'"]+)['"]\s*\)""")

# Intentionally unsupported forms, documented for clarity:
#   - Non-static dynamic expressions: import(variablePath)
#   - TypeScript triple-slash reference directives
#   - CSS or Vite ?raw/?url suffixes treated as app code
#   - .vue SFC <template>/<style> content beyond basic script regex matching

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


def _is_frontend_scan_target(path: Path) -> bool:
    if path.suffix not in {".ts", ".tsx", ".vue"}:
        return False
    rel = path.relative_to(FRONTEND_SRC).as_posix()
    parts = rel.split("/")
    if "__tests__" in parts or any(p.startswith(("_test", "_spec")) for p in parts):
        return False
    if path.name.endswith((".test.ts", ".test.tsx", ".spec.ts", ".spec.tsx")):
        return False
    return True


def _resolve_ts_ast_entrypoint() -> str | None:
    """Return a path to @typescript-eslint/typescript-estree, if installed.

    Frontend is the consumer of TS files, so we look there first. The root node_modules
    and a bare 'node' on PATH are acceptable fallbacks for environments where
    `npm install` was already run outside frontend/.
    """
    candidates = [
        FRONTEND_NODE_MODULES / "@typescript-eslint" / "typescript-estree" / "dist" / "index.js",
        ROOT / "node_modules" / "@typescript-eslint" / "typescript-estree" / "dist" / "index.js",
    ]
    for candidate in candidates:
        if candidate.exists():
            return str(candidate.resolve())
    return None


def _collect_ts_imports_via_ast(paths: list[Path]) -> dict[Path, list[str]]:
    """Use Node + @typescript-eslint/typescript-estree to extract specifiers.

    AST parsing catches relative imports, aliased @/... imports, barrel
    re-exports (`export { X } from ...`, `export * from ...`), static
    `import(...)`, and CommonJS `require(...)`.
    """
    if not paths:
        return {}
    entrypoint = _resolve_ts_ast_entrypoint()
    if not entrypoint:
        return {}

    node_script = r"""
const fs = require('fs');
const files = JSON.parse(fs.readFileSync(0, 'utf8'));
const entrypoint = process.env.TS_ESTREE_ENTRYPOINT;
let estree;
try { estree = require(entrypoint); } catch (e) { process.stderr.write(e.message || String(e)); process.exit(2); }
const out = {};
for (const file of files) {
  try {
    const text = fs.readFileSync(file, 'utf8');
    const ast = estree.parse(text, {
      jsx: file.endsWith('.tsx'),
      loc: false,
      range: false,
      comment: false,
      tokens: false,
      sourceType: 'module',
    });
    const specs = new Set();
    function add(spec) {
      if (typeof spec === 'string') specs.add(spec);
    }
    function walk(node) {
      if (!node || typeof node !== 'object') return;
      if (Array.isArray(node)) { node.forEach(walk); return; }
      const type = node.type;
      if (type === 'ImportDeclaration') add(node.source && node.source.value);
      else if (type === 'ExportNamedDeclaration' || type === 'ExportAllDeclaration') {
        add(node.source && node.source.value);
      } else if (type === 'VariableDeclarator' && node.init && node.init.type === 'CallExpression') {
        if (node.init.callee.type === 'Identifier' && node.init.callee.name === 'require') {
          const arg = node.init.arguments && node.init.arguments[0];
          if (arg && arg.type === 'Literal') add(arg.value);
        }
      } else if (type === 'ImportExpression') {
        const arg = node.source;
        if (arg && arg.type === 'Literal') add(arg.value);
      }
      for (const key of Object.keys(node)) {
        if (key === 'parent') continue;
        if (Array.isArray(node[key])) node[key].forEach(walk);
        else if (node[key] && typeof node[key] === 'object' && node[key].type) walk(node[key]);
      }
    }
    walk(ast.body);
    out[file] = [...specs].filter(Boolean);
  } catch (e) {
    out[file] = '__PARSE_ERROR__:' + (e && e.message ? e.message : String(e));
  }
}
process.stdout.write(JSON.stringify(out));
""".replace("\n", " ")

    proc = subprocess.run(
        ["node", "-e", node_script],
        input=json.dumps([str(p) for p in paths]),
        capture_output=True,
        text=True,
        check=False,
        env={**os.environ, "TS_ESTREE_ENTRYPOINT": entrypoint},
    )
    if proc.returncode != 0:
        # Do not fail the whole harness if the parser itself cannot load; callers fall back.
        # Surface the failure so developers know AST coverage is degraded.
        stderr = (proc.stderr or "").strip()
        if stderr:
            print(f"  [warn] TypeScript AST parser failed: {stderr}", file=sys.stderr)
        else:
            print("  [warn] TypeScript AST parser exited with non-zero status, falling back to regex", file=sys.stderr)
        # Return parse-error entries for every path so the cache triggers the
        # regex fallback per file rather than re-invoking Node individually.
        return {Path(str(p)): ["__PARSE_ERROR__:node_failed"] for p in paths}

    result = json.loads(proc.stdout)
    return {Path(k): v for k, v in result.items()}


def _regex_fallback_imports(text: str) -> list[str]:
    """Regex fallback scan. Handles common static, dynamic, barrel, and require forms."""
    imports: list[str] = []
    for pattern in (_IMPORT_FROM_RE, _BARE_IMPORT_RE, _DYNAMIC_IMPORT_RE, _REQUIRE_RE):
        imports.extend(m.group(1) for m in pattern.finditer(text))
    return imports


def _collect_frontend_imports(path: Path, ast_cache: dict[Path, list[str]]) -> list[str]:
    """Collect import/re-export specifiers for a single frontend file.

    Prefers ESTree AST; falls back to an enhanced regex on parser failure.
    Parse errors from the AST are surfaced as a leading string with a
    "__PARSE_ERROR__:" prefix, which keeps them discoverable without silencing them.
    """
    if path in ast_cache:
        cached = ast_cache[path]
        if cached and cached[0].startswith("__PARSE_ERROR__:"):
            return _regex_fallback_imports(path.read_text(encoding="utf-8", errors="replace"))
        return cached or []

    text = path.read_text(encoding="utf-8", errors="replace")
    if path.suffix in {".ts", ".tsx"}:
        ast_result = _collect_ts_imports_via_ast([path]).get(path)
        if ast_result:
            return ast_result
    return _regex_fallback_imports(text)


def check_frontend() -> None:
    if not FRONTEND_SRC.is_dir():
        return

    api_dir = FRONTEND_SRC / "api"
    stores_dir = FRONTEND_SRC / "stores"

    def layer_name(directory: Path) -> str:
        if directory == api_dir:
            return "api"
        if directory == stores_dir:
            return "stores"
        return ""

    def scan(directory: Path, forbidden_prefixes: list[str], bad_label: str) -> None:
        name = layer_name(directory)
        if not name or not directory.is_dir():
            return

        ts_paths = [p for p in directory.rglob("*") if _is_frontend_scan_target(p)]
        ast_cache: dict[Path, list[str]] = {}
        if ts_paths:
            ast_cache = _collect_ts_imports_via_ast(ts_paths)

        for path in ts_paths:
            for specifier in _collect_frontend_imports(path, ast_cache):
                if any(prefix in specifier for prefix in forbidden_prefixes):
                    errors.append(
                        f"{path}: {name} imports '{specifier}' ({bad_label}). "
                        f"REMEDIATE: {name} must not depend on {bad_label}. "
                        f"Invert the dependency (pages/components call api/stores). "
                        f"See ARCHITECTURE.md."
                    )

    scan(api_dir, ["@/pages", "@/components", "/pages/", "/components/"], "pages or components")
    scan(stores_dir, ["@/pages", "/pages/"], "pages")


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
