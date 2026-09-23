ENTITY = {"owner": "me", "name": "myrepo", "type": "repository", "default_branch": "main"}
REPO_URL = "/repos/me/myrepo"

contributing = txtar(read_file("testdata/contributing.txtar"))


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
    keep = lambda file: file == "CONTRIBUTING"
    res = eval(
        rule="osps-gv-03-01",
        entity=ENTITY,
        mock_fs={k:contributing[k] for k in contributing if keep(k)}
    )
    assert.eq(res["status"], "pass")

def test_gv_03_01_markdown():
    keep = lambda file: file == "CONTRIBUTING.md"
    res = eval(
        rule="osps-gv-03-01",
        entity=ENTITY,
        mock_fs={k:contributing[k] for k in contributing if keep(k)}
    )
    assert.eq(res["status"], "pass")

def test_gv_03_01_directory():
    keep = lambda file: file.find("CONTRIBUTING/") != -1
    res = eval(
        rule="osps-gv-03-01",
        entity=ENTITY,
        mock_fs={k:contributing[k] for k in contributing if keep(k)}
    )
    assert.eq(res["status"], "pass")

# TODO: add support for a section in README.md
def test_gv_03_01_missing():
    keep = lambda file: file == "README.md"
    res = eval(
        rule="osps-gv-03-01",
        entity=ENTITY,
        mock_fs={k:contributing[k] for k in contributing if keep(k)}
    )
    assert.eq(res["status"], "fail")

