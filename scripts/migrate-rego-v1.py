#!/usr/bin/env python3
"""Migrate embedded Rego rule definitions in YAML files to Rego v1 syntax."""

from __future__ import annotations

import argparse
import pathlib
import re
import subprocess
import sys
import tempfile


DEF_BLOCK_RE = re.compile(r"^(?P<indent>\s*)def:\s*\|(?P<chomp>[+-]?)\s*$")


def yaml_files(paths: list[pathlib.Path]) -> list[pathlib.Path]:
    files: list[pathlib.Path] = []
    for path in paths:
        if path.is_dir():
            files.extend(sorted(path.rglob("*.yaml")))
            files.extend(sorted(path.rglob("*.yml")))
        elif path.suffix in {".yaml", ".yml"}:
            files.append(path)
    return sorted(set(files))


def leading_spaces(line: str) -> int:
    return len(line) - len(line.lstrip(" "))


def extract_block(lines: list[str], start: int, parent_indent: int) -> tuple[list[str], int]:
    block: list[str] = []
    current = start
    while current < len(lines):
        line = lines[current]
        if line.strip() and leading_spaces(line) <= parent_indent:
            break
        block.append(line)
        current += 1
    return block, current


def dedent_block(block: list[str]) -> tuple[str, int]:
    nonblank_indents = [leading_spaces(line) for line in block if line.strip()]
    if not nonblank_indents:
        return "", 0

    block_indent = min(nonblank_indents)
    source = "".join(
        line[block_indent:] if len(line) >= block_indent else "\n"
        for line in block
    )
    return source, block_indent


def format_rego(source: str, opa: str) -> str:
    with tempfile.NamedTemporaryFile("w+", suffix=".rego") as rego_file:
        rego_file.write(source)
        rego_file.flush()

        result = subprocess.run(
            [opa, "fmt", "--v0-v1", rego_file.name],
            check=False,
            text=True,
            capture_output=True,
        )

    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip())

    formatted = result.stdout.expandtabs(2)
    if not formatted.endswith("\n"):
        formatted += "\n"
    return formatted


def indent_block(source: str, indent: int) -> list[str]:
    prefix = " " * indent
    return [
        prefix + line if line.strip() else prefix.rstrip() + "\n"
        for line in source.splitlines(True)
    ]


def migrate_file(path: pathlib.Path, opa: str, check: bool) -> bool:
    original = path.read_text()
    lines = original.splitlines(True)
    migrated: list[str] = []
    changed = False
    index = 0

    while index < len(lines):
        line = lines[index]
        match = DEF_BLOCK_RE.match(line)
        if not match:
            migrated.append(line)
            index += 1
            continue

        parent_indent = len(match.group("indent"))
        block, next_index = extract_block(lines, index + 1, parent_indent)
        source, block_indent = dedent_block(block)

        if not source.lstrip().startswith("package "):
            migrated.append(line)
            migrated.extend(block)
            index = next_index
            continue

        formatted = format_rego(source, opa)
        formatted_block = indent_block(formatted, block_indent)

        migrated.append(line)
        migrated.extend(formatted_block)
        changed = changed or block != formatted_block
        index = next_index

    if not changed:
        return False

    if check:
        return True

    path.write_text("".join(migrated))
    return True


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Run 'opa fmt --v0-v1' on Rego definitions embedded in YAML def blocks.",
    )
    parser.add_argument("paths", nargs="*", type=pathlib.Path, default=[pathlib.Path("rule-types")])
    parser.add_argument("--opa", default="opa", help="Path to the opa binary.")
    parser.add_argument("--check", action="store_true", help="Report files that would change without writing them.")
    args = parser.parse_args()

    changed_files: list[pathlib.Path] = []
    for path in yaml_files(args.paths):
        try:
            if migrate_file(path, args.opa, args.check):
                changed_files.append(path)
        except RuntimeError as exc:
            print(f"{path}: {exc}", file=sys.stderr)
            return 1

    for path in changed_files:
        print(path)

    if args.check and changed_files:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
