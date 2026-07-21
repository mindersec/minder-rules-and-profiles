ENTITY = {"owner": "coolhead", "name": "haze-wave", "type": "repository", "default_branch": "main"}
URL = "/repos/coolhead/haze-wave"

def PASS(res):
    assert.eq(res["status"], "pass")

def FAIL(res):
    assert.true(res["status"] in ("fail", "error"))
    assert.true(res["message"] != "")

def test_issues_are_enabled():
    res = eval(
        rule="repo_issues_enabled",
        entity=ENTITY,
        mock_http={
            URL: body("""{
              "has_issues": true
            }""")
        }
    )
    PASS(res)

def test_issues_should_be_enabled():
    res = eval(
        rule="repo_issues_enabled",
        entity=ENTITY,
        mock_http={
            URL: body("""{
              "has_issues": false
            }""")
        }
    )
    FAIL(res)

def test_not_found_should_fail():
    res = eval(
        rule="repo_issues_enabled",
        entity={"owner": "coolhead", "name": "haze-wave", "type": "repository", "default_branch": "main"},
        profile={},
        mock_http={
            "/repos/coolhead/haze-wave": body("{\n  \"message\": \"Not Found\",\n  \"documentation_url\": \"https://docs.github.com/rest/repos/repos#get-a-repository\",\n  \"status\": \"404\"\n}\n").code(404)
        }
    )
    assert.true(res["status"] in ("fail", "error"))
    assert.true(res["message"] != "")

def test_internal_server_error_should_fail():
    res = eval(
        rule="repo_issues_enabled",
        entity={"owner": "coolhead", "name": "haze-wave", "type": "repository", "default_branch": "main"},
        profile={},
        mock_http={
            "/repos/coolhead/haze-wave": body("{ \"message\": \"Internal server error\" }\n").code(500)
        }
    )
    assert.true(res["status"] in ("fail", "error"))
    assert.true(res["message"] != "")
