ENTITY = {"owner": "me", "name": "myrepo", "type": "repository", "default_branch": "main"}
REPO_URL = "/repos/me/myrepo"

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
