ENTITY = {"owner": "coolhead", "name": "haze-wave", "type": "repository", "default_branch": "main"}
URL = "/repos/coolhead/haze-wave"

responses = txtar(read_file("testdata/repo-info.txtar"))

def PASS(res):
    assert.eq(res["status"], "pass")

def FAIL(res):
    assert.true(res["status"] in ("fail", "error"))

def repo_issues(json_key):
    """Helper to build eval result for repo_issues_enabled rule."""
    # TODO: extract entity & URL from JSON string in responses
    return eval(
        rule="repo_issues_enabled",
        entity=ENTITY,
        mock_http={
            URL: body(responses[json_key])
        }
    )

def test_issues_are_enabled():
    PASS(repo_issues("good_setup.json"))

def test_issues_should_be_enabled():
    FAIL(repo_issues("bad_setup.json"))

def test_not_found_should_fail():
    res = eval(
        rule="repo_issues_enabled",
        entity=ENTITY,
        mock_http={
            URL: body("").code(404)
        }
    )
    FAIL(res)

def test_internal_server_error_should_fail():
    res = eval(
        rule="repo_issues_enabled",
        entity=ENTITY,
        mock_http={
            URL: body("").code(500)
        }
    )
    FAIL(res)
