ENTITY = {"owner": "example", "name": "my-python-app", "type": "repository", "default_branch": "main"}

def PASS(res):
    assert.eq(res["status"], "pass")

def FAIL(res):
    assert.true(res["status"] in ("fail", "error"))

def SKIP(res):
    assert.eq(res["status"], "skip")

def test_ruff_toml_present():
    res = eval(
        rule="python_linter_configured",
        entity=ENTITY,
        mock_fs={
            "requirements.txt": "flask\n",
            "ruff.toml": "line-length = 88\n",
        }
    )
    PASS(res)

def test_ruff_in_pyproject_toml():
    res = eval(
        rule="python_linter_configured",
        entity=ENTITY,
        mock_fs={
            "pyproject.toml": "[build-system]\nrequires = [\"setuptools\"]\n\n[tool.ruff]\nline-length = 88\n",
        }
    )
    PASS(res)

def test_flake8_config_present():
    res = eval(
        rule="python_linter_configured",
        entity=ENTITY,
        mock_fs={
            "requirements.txt": "flask\n",
            ".flake8": "[flake8]\nmax-line-length = 88\n",
        }
    )
    PASS(res)

def test_flake8_in_setup_cfg():
    res = eval(
        rule="python_linter_configured",
        entity=ENTITY,
        mock_fs={
            "setup.cfg": "[metadata]\nname = myapp\n\n[flake8]\nmax-line-length = 88\n",
        }
    )
    PASS(res)

def test_pylint_in_pyproject_toml():
    res = eval(
        rule="python_linter_configured",
        entity=ENTITY,
        mock_fs={
            "pyproject.toml": "[build-system]\nrequires = [\"setuptools\"]\n\n[tool.pylint.main]\npy-version = \"3.9\"\n",
        }
    )
    PASS(res)

def test_ruff_in_ci_workflow():
    res = eval(
        rule="python_linter_configured",
        entity=ENTITY,
        mock_fs={
            "requirements.txt": "flask\n",
            ".github/workflows/lint.yml": "steps:\n  - run: pip install ruff && ruff check .\n",
        }
    )
    PASS(res)

def test_no_linter_configured():
    res = eval(
        rule="python_linter_configured",
        entity=ENTITY,
        mock_fs={
            "requirements.txt": "flask\nrequests\n",
        }
    )
    FAIL(res)

def test_non_python_project_skipped():
    res = eval(
        rule="python_linter_configured",
        entity=ENTITY,
        mock_fs={
            "main.go": "package main\n",
        }
    )
    SKIP(res)
