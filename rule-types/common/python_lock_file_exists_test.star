ENTITY = {"owner": "coolhead", "name": "haze-wave", "type": "repository", "default_branch": "main"}

def PASS(res):
    assert.eq(res["status"], "pass")

def FAIL(res):
    assert.true(res["status"] in ("fail", "error"))
    assert.true(res["message"] != "")

def test_project_contains_pipfile_lock():
    res = eval(
        rule="python_lock_file_exists",
        entity=ENTITY,
        profile={},
        mock_fs={
            "Pipfile": read_file("python_lock_file_exists.testdata/pipfile_lock/Pipfile"),
            "Pipfile.lock": read_file("python_lock_file_exists.testdata/pipfile_lock/Pipfile.lock")
        }
    )
    PASS(res)

def test_project_contains_poetry_lock():
    res = eval(
        rule="python_lock_file_exists",
        entity=ENTITY,
        profile={},
        mock_fs={
            "pyproject.toml": read_file("python_lock_file_exists.testdata/poetry_lock/pyproject.toml"),
            "poetry.lock": read_file("python_lock_file_exists.testdata/poetry_lock/poetry.lock")
        }
    )
    PASS(res)

def test_project_contains_pdm_lock():
    res = eval(
        rule="python_lock_file_exists",
        entity=ENTITY,
        profile={},
        mock_fs={
            "pdm.lock": read_file("python_lock_file_exists.testdata/pdm_lock/pdm.lock"),
            "pyproject.toml": read_file("python_lock_file_exists.testdata/pdm_lock/pyproject.toml")
        }
    )
    PASS(res)

def test_project_contains_version_pinned_requirements_txt():
    res = eval(
        rule="python_lock_file_exists",
        entity=ENTITY,
        profile={},
        mock_fs={
            "requirements.txt": read_file("python_lock_file_exists.testdata/pinned_requirements_txt/requirements.txt")
        }
    )
    PASS(res)

def test_project_contains_some_unpinned_requirements_txt():
    res = eval(
        rule="python_lock_file_exists",
        entity=ENTITY,
        profile={},
        mock_fs={
            "requirements.txt": read_file("python_lock_file_exists.testdata/some_unpinned_requirements_txt/requirements.txt")
        }
    )
    FAIL(res)

def test_project_contains_no_lock_files():
    res = eval(
        rule="python_lock_file_exists",
        entity=ENTITY,
        profile={},
        mock_fs={
            "pyproject.toml": read_file("python_lock_file_exists.testdata/no_lock/pyproject.toml")
        }
    )
    FAIL(res)
