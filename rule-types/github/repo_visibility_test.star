ENTITY = {"owner": "coolhead", "name": "haze-wave", "type": "repository", "default_branch": "main"}
URL = "/repos/coolhead/haze-wave"

responses = txtar(read_file("testdata/repo-info.txtar"))

def repo_visibility(want, json_key):
    """Helper to build eval result for repo_visibility rule."""
    return eval(
        rule="repo_visibility",
        entity=ENTITY,
        profile={"visibility": want},
        mock_http={
            URL: body(responses[json_key])
        }
    )

def test_should_be_public():
    res = repo_visibility("public", "good_setup.json")
    assert.eq(res["status"], "pass")

def test_should_be_private():
    res = repo_visibility("private", "bad_setup.json")
    assert.eq(res["status"], "pass")

def test_should_be_public_but_is_private():
    res = repo_visibility("public", "bad_setup.json")
    assert.eq(res["status"], "fail")

def test_not_found_should_fail():
    res = eval(
        rule="repo_visibility",
        entity=ENTITY,
        profile={"visibility": "public"},
        mock_http={
            URL: body(responses["missing.json"]).code(404)
        }
    )
    assert.eq(res["status"], "fail")

def test_internal_server_error_should_error():
    res = eval(
        rule="repo_visibility",
        entity=ENTITY,
        profile={},
        mock_http={
            URL: body("").code(500)
        }
    )
    assert.eq(res["status"], "error")
