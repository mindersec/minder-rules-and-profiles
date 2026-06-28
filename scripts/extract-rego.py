#!/usr/bin/env python3
"""Extract Rego policies embedded in YAML rule type definitions."""

from __future__ import annotations

import argparse
import pathlib
import re


DEF_BLOCK_RE = re.compile(r"^(?P<indent>\s*)def:\s*\|[+-]?\s*$")


def yaml_files(paths: list[pathlib.Path]) -> list[pathlib.Path]:
    files: list[pathlib.Path] = []
    for path in paths:
        if path.is_dir():
            files.extend(path.rglob("*.yaml"))
            files.extend(path.rglob("*.yml"))
        elif path.suffix in {".yaml", ".yml"}:
            files.append(path)
    return sorted(set(files))


def leading_spaces(line: str) -> int:
    return len(line) - len(line.lstrip(" "))


def extract_block(lines: list[str], start: int, parent_indent: int) -> tuple[str, int]:
    block: list[str] = []
    current = start
    while current < len(lines):
        line = lines[current]
        if line.strip() and leading_spaces(line) <= parent_indent:
            break
        block.append(line)
        current += 1

    nonblank_indents = [leading_spaces(line) for line in block if line.strip()]
    if not nonblank_indents:
        return "", current

    block_indent = min(nonblank_indents)
    source = "".join(
        line[block_indent:] if len(line) >= block_indent else "\n"
        for line in block
    )
    return source, current


def extract_policies(path: pathlib.Path) -> list[str]:
    lines = path.read_text().splitlines(True)
    policies: list[str] = []
    index = 0

    while index < len(lines):
        match = DEF_BLOCK_RE.match(lines[index])
        if not match:
            index += 1
            continue

        source, index = extract_block(
            lines,
            index + 1,
            len(match.group("indent")),
        )
        if source.lstrip().startswith("package "):
            policies.append(source)

    return policies


def output_name(path: pathlib.Path, policy_index: int) -> str:
    normalized = "__".join(path.parts)
    return f"{normalized}.{policy_index}.rego"


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Extract embedded Rego definitions into standalone files.",
    )
    parser.add_argument("paths", nargs="+", type=pathlib.Path)
    parser.add_argument("--output", required=True, type=pathlib.Path)
    args = parser.parse_args()

    args.output.mkdir(parents=True, exist_ok=True)

    extracted = 0
    for path in yaml_files(args.paths):
        for policy_index, source in enumerate(extract_policies(path)):
            output = args.output / output_name(path, policy_index)
            output.write_text(source)
            extracted += 1

    if extracted == 0:
        parser.error("no embedded Rego policies found")

    print(f"Extracted {extracted} Rego policies to {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
