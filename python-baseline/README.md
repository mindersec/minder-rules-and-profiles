# Python Baseline

A Minder profile that checks Python repositories for common project hygiene
practices. The rules are intentionally tool-agnostic: they detect whatever
tool you already use and only open a remediation PR when nothing is
configured at all.

## What it checks

| Rule | What it looks for |
|------|-------------------|
| `python_lock_file_exists` | A lock file (Pipfile.lock, poetry.lock, pdm.lock) or pinned requirements.txt |
| `python_pyproject_toml_exists` | A pyproject.toml (the modern Python project standard) |
| `python_type_checker_configured` | mypy, pyright, or pytype in config files or CI |
| `python_linter_configured` | ruff, flake8, or pylint in config files or CI |

All rules are automatically skipped for repositories that show no signs of
being a Python project.

## Installation

Apply directly from the GitHub repository (no local clone needed):

```bash
minder apply --git https://github.com/mindersec/minder-rules-and-profiles?python-baseline
```

Or, if you have a local clone:

```bash
minder apply -f path/to/python-baseline
```

Both commands apply the rule types and the profile in a single step.

To enable automated remediation (PRs to add missing config files), edit
`profiles/python-baseline.yaml` and set `remediate: "on"` before applying.
