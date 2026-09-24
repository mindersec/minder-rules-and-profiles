ENTITY = {"owner": "me", "name": "myrepo", "type": "repository", "default_branch": "main"}
REPO_URL = "/repos/me/myrepo"

contributing_files = txtar(read_file("testdata/contributing.txtar"))

def filter_contributing(filter):
    """Filter the contributing_files using a boolean filter function"""
    return {k:contributing_files[k] for k in contributing_files if filter(k)}

def test_gv_02_01_issues_enabled():
    res = eval(
        rule="osps-gv-02-01",
        entity=ENTITY,
        mock_http={
            REPO_URL: body('{"has_issues": true, "has_discussions": false}')
        }
    )
    assert.eq(res["status"], "pass")

def test_gv_02_01_discussions_enabled():
    res = eval(
        rule="osps-gv-02-01",
        entity=ENTITY,
        mock_http={
            REPO_URL: body('{"has_issues": false, "has_discussions": true}')
        }
    )
    assert.eq(res["status"], "pass")

def test_gv_02_01_no_feedback():
    res = eval(
        rule="osps-gv-02-01",
        entity=ENTITY,
        mock_http={
            REPO_URL: body('{"has_issues": false, "has_discussions": false}')
        }
    )
    assert.eq(res["status"], "fail")

def test_gv_03_01_plain_file():
    res = eval(
        rule="osps-gv-03-01",
        entity=ENTITY,
        mock_fs=filter_contributing(lambda file: file == "CONTRIBUTING")
    )
    assert.eq(res["status"], "pass")

def test_gv_03_01_markdown():
    res = eval(
        rule="osps-gv-03-01",
        entity=ENTITY,
        mock_fs=filter_contributing(lambda file: file == "CONTRIBUTING.md")
    )
    assert.eq(res["status"], "pass")

def test_gv_03_01_directory():
    res = eval(
        rule="osps-gv-03-01",
        entity=ENTITY,
        mock_fs=filter_contributing(lambda file: file.count("CONTRIBUTING/") > 0)
    )
    assert.eq(res["status"], "pass")

# TODO: add support for a section in README.md
def test_gv_03_01_missing():
    res = eval(
        rule="osps-gv-03-01",
        entity=ENTITY,
        mock_fs=filter_contributing(lambda file: file == "README.md")
    )
    assert.eq(res["status"], "fail")
