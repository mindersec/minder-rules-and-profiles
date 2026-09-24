ENTITY = {"owner": "coolhead", "name": "haze-wave", "type": "repository", "default_branch": "main"}
URL = "/repos/coolhead/haze-wave"

responses = txtar(read_file("testdata/repo-info.txtar"))

def secret_scanning(json_key, profile=None):
    """Helper to build eval result for secret_scanning rule"""
    if not profile:
        profile = {}
    return eval(
        rule="secret_scanning",
        entity=ENTITY,
        profile=profile,
        mock_http={
            URL: body(responses[json_key])
        }
    )

def test_should_have_secret_scanning_enabled():
    res = secret_scanning("good_setup.json")
    assert.eq(res["status"], "pass")

def test_should_have_secret_scanning_enabled_for_private_repo():
    res = secret_scanning("private_good_setup.json", {"skip_private_repos": False})
    assert.eq(res["status"], "pass")

def test_private_repo_should_skip():
    res = secret_scanning("bad_setup.json", {"skip_private_repos": True})
    assert.eq(res["status"], "skip")

def test_disabled_secret_scanning_denied():
    res = secret_scanning("bad_setup.json", {"skip_private_repos": False})
    assert.eq(res["status"], "fail")
    assert.true(res["message"] != "")

def test_not_found_should_fail():
    res = eval(
        rule="secret_scanning",
        entity=ENTITY,
        profile={},
        mock_http={
            URL: body(responses["missing.json"]).code(404)
        }
    )
    assert.eq(res["status"], "fail")
    assert.true(res["message"] != "")

def test_internal_server_error_should_error():
    res = eval(
        rule="secret_scanning",
        entity=ENTITY,
        profile={},
        mock_http={
            URL: body("").code(500)
        }
    )
    assert.eq(res["status"], "error")
    assert.true(res["message"] != "")
