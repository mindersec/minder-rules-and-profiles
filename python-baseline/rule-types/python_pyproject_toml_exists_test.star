ENTITY = {"owner": "example", "name": "my-python-app", "type": "repository", "default_branch": "main"}

def PASS(res):
    assert.eq(res["status"], "pass")

def FAIL(res):
    assert.true(res["status"] in ("fail", "error"))

def SKIP(res):
    assert.eq(res["status"], "skip")

def test_pyproject_toml_present():
    res = eval(
        rule="python_pyproject_toml_exists",
        entity=ENTITY,
        mock_fs={
            "requirements.txt": "flask\n",
            "pyproject.toml": "[build-system]\nrequires = [\"setuptools\"]\nbuild-backend = \"setuptools.build_meta\"\n",
        }
    )
    PASS(res)

def test_pyproject_toml_with_setup_py():
    res = eval(
        rule="python_pyproject_toml_exists",
        entity=ENTITY,
        mock_fs={
            "setup.py": "from setuptools import setup\nsetup()\n",
            "pyproject.toml": "[build-system]\nrequires = [\"setuptools\"]\nbuild-backend = \"setuptools.build_meta\"\n",
        }
    )
    PASS(res)

def test_missing_pyproject_toml():
    res = eval(
        rule="python_pyproject_toml_exists",
        entity=ENTITY,
        mock_fs={
            "requirements.txt": "flask\nrequests\n",
            "setup.py": "from setuptools import setup\nsetup()\n",
        }
    )
    FAIL(res)

def test_missing_pyproject_toml_with_pipfile():
    res = eval(
        rule="python_pyproject_toml_exists",
        entity=ENTITY,
        mock_fs={
            "Pipfile": "[[source]]\nurl = \"https://pypi.org/simple\"\n",
        }
    )
    FAIL(res)

def test_non_python_project_skipped():
    res = eval(
        rule="python_pyproject_toml_exists",
        entity=ENTITY,
        mock_fs={
            "main.go": "package main\n",
        }
    )
    SKIP(res)

def test_non_python_project_only_pyproject_toml_skipped():
    # pyproject.toml alone is not enough to identify a Python project
    # (it could be a Rust project using pyproject for tooling config)
    # The skip list intentionally excludes pyproject.toml itself
    res = eval(
        rule="python_pyproject_toml_exists",
        entity=ENTITY,
        mock_fs={
            "pyproject.toml": "[tool.ruff]\nline-length = 88\n",
        }
    )
    SKIP(res)
