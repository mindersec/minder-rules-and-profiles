ENTITY = {"owner": "mindersec", "name": "minder", "type": "repository", "default_branch": "main"}
URL = "/repos/mindersec/minder/branches/main/protection"

def PASS(res):
    assert.eq(res["status"], "pass")

def FAIL(res):
    assert.true(res["status"] in ("fail", "error"))
    assert.true(res["message"] != "")

def test_force_push_not_allowed():
    res = eval(
        rule="branch_protection_allow_deletions",
        entity=ENTITY,
        profile={},
        mock_http={
            URL: body("""{
              "allow_deletions": {
                "enabled": false
              }
            }""")
        }
    )
    PASS(res)

def test_force_push_allowed():
    res = eval(
        rule="branch_protection_allow_deletions",
        entity=ENTITY,
        profile={},
        mock_http={
            URL: body("""{
              "allow_deletions": {
                "enabled": true
              }
            }""")
        }
    )
    FAIL(res)

def test_not_found():
    res = eval(
        rule="branch_protection_allow_deletions",
        entity=ENTITY,
        profile={},
        mock_http={
            URL: body('{"woot": "woot"}').code(404)
        }
    )
    FAIL(res)

def test_internal_error():
    res = eval(
        rule="branch_protection_allow_deletions",
        entity=ENTITY,
        profile={},
        mock_http={
            URL: body('{"woot": "woot"}').code(502)
        }
    )
    FAIL(res)
