ENTITY = {"owner": "coolhead", "name": "haze-wave", "type": "repository", "default_branch": "main"}

files = txtar(read_file("testdata/python_lockfile.txtar"))

def PASS(res):
    assert.eq(res["status"], "pass")

def FAIL(res):
    assert.true(res["status"] in ("fail", "error"))

def test_project_contains_pipfile_lock():
    res = eval(
        rule="python_lock_file_exists",
        entity=ENTITY,
        mock_fs={
            "Pipfile": files["pipfile/Pipfile"],
            "Pipfile.lock": files["pipfile/Pipfile.lock"]
        }
    )
    PASS(res)

def test_project_contains_poetry_lock():
    res = eval(
        rule="python_lock_file_exists",
        entity=ENTITY,
        mock_fs={
            "pyproject.toml": files["codegate/pyproject.toml"],
            "poetry.lock": files["codegate/poetry.lock"]
        }
    )
    PASS(res)

def test_project_contains_pdm_lock():
    res = eval(
        rule="python_lock_file_exists",
        entity=ENTITY,
        mock_fs={
            "pdm.lock": files["pdm/pdm.lock"],
            "pyproject.toml": files["pdm/pyproject.toml"]
        }
    )
    PASS(res)

def test_project_contains_version_pinned_requirements_txt():
    res = eval(
        rule="python_lock_file_exists",
        entity=ENTITY,
        mock_fs={
            "requirements.txt": files["pinned-requirements.txt"]
        }
    )
    PASS(res)

def test_project_contains_some_unpinned_requirements_txt():
    res = eval(
        rule="python_lock_file_exists",
        entity=ENTITY,
        mock_fs={
            "requirements.txt": files["unpinned-requirements.txt"]
        }
    )
    FAIL(res)

def test_project_contains_no_lock_files():
    res = eval(
        rule="python_lock_file_exists",
        entity=ENTITY,
        mock_fs={
            "pyproject.toml": files["codegate/pyproject.toml"]
        }
    )
    FAIL(res)
