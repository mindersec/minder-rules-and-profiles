#!/usr/bin/env python3
"""Extract Rego policies embedded in YAML rule type definitions."""

from __future__ import annotations

import argparse
import pathlib

import yaml


def yaml_files(paths: list[pathlib.Path]) -> list[pathlib.Path]:
    files: list[pathlib.Path] = []
    for path in paths:
        if path.is_dir():
            files.extend(path.rglob("*.yaml"))
            files.extend(path.rglob("*.yml"))
        elif path.suffix in {".yaml", ".yml"}:
            files.append(path)
    test_suffixes = (
        ".test.yaml",
        ".test.yml",
        ".no-datasource-test.yaml",
        ".no-datasource-test.yml",
    )
    return sorted({path for path in files if not path.name.endswith(test_suffixes)})


def extract_policies(path: pathlib.Path) -> list[str]:
    contents = yaml.safe_load(path.read_text()) or {}
    rego = contents.get("def", {}).get("eval", {}).get("rego", {}).get("def", "")
    return [rego] if rego else []


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
