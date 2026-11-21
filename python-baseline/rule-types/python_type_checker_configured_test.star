ENTITY = {"owner": "example", "name": "my-python-app", "type": "repository", "default_branch": "main"}

def PASS(res):
    assert.eq(res["status"], "pass")

def FAIL(res):
    assert.true(res["status"] in ("fail", "error"))

def SKIP(res):
    assert.eq(res["status"], "skip")

def test_mypy_ini_present():
    res = eval(
        rule="python_type_checker_configured",
        entity=ENTITY,
        mock_fs={
            "requirements.txt": "flask\n",
            "mypy.ini": "[mypy]\npython_version = 3.9\n",
        }
    )
    PASS(res)

def test_mypy_in_pyproject_toml():
    res = eval(
        rule="python_type_checker_configured",
        entity=ENTITY,
        mock_fs={
            "pyproject.toml": "[build-system]\nrequires = [\"setuptools\"]\n\n[tool.mypy]\nstrict = false\n",
        }
    )
    PASS(res)

def test_pyrightconfig_json_present():
    res = eval(
        rule="python_type_checker_configured",
        entity=ENTITY,
        mock_fs={
            "requirements.txt": "flask\n",
            "pyrightconfig.json": "{\"pythonVersion\": \"3.9\"}\n",
        }
    )
    PASS(res)

def test_pyright_in_pyproject_toml():
    res = eval(
        rule="python_type_checker_configured",
        entity=ENTITY,
        mock_fs={
            "pyproject.toml": "[build-system]\nrequires = [\"setuptools\"]\n\n[tool.pyright]\npythonVersion = \"3.9\"\n",
        }
    )
    PASS(res)

def test_mypy_in_ci_workflow():
    res = eval(
        rule="python_type_checker_configured",
        entity=ENTITY,
        mock_fs={
            "requirements.txt": "flask\n",
            ".github/workflows/ci.yml": "steps:\n  - run: pip install mypy && mypy src/\n",
        }
    )
    PASS(res)

def test_no_type_checker_configured():
    res = eval(
        rule="python_type_checker_configured",
        entity=ENTITY,
        mock_fs={
            "requirements.txt": "flask\nrequests\n",
        }
    )
    FAIL(res)

def test_non_python_project_skipped():
    res = eval(
        rule="python_type_checker_configured",
        entity=ENTITY,
        mock_fs={
            "main.go": "package main\n",
        }
    )
    SKIP(res)
