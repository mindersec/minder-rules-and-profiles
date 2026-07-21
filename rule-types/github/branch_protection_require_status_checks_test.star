ENTITY = {"owner": "mindersec", "name": "minder", "type": "repository", "default_branch": "main"}
URL = "/repos/mindersec/minder/branches/main/protection"

def PASS(res):
    assert.eq(res["status"], "pass")

def FAIL(res):
    assert.true(res["status"] in ("fail", "error"))
    assert.true(res["message"] != "")

def test_status_checks_required():
    res = eval(
        rule="branch_protection_require_status_checks",
        entity=ENTITY,
        mock_http={
            URL: body("""{
              "required_status_checks": {
                "url": "https://api.github.com/repos/test/test/branches/main/protection/required_status_checks",
                "strict": false,
                "contexts": [],
                "checks": []
              }
            }""")
        }
    )
    PASS(res)

def test_status_checks_required_with_strict_mode():
    res = eval(
        rule="branch_protection_require_status_checks",
        entity=ENTITY,
        mock_http={
            URL: body("""{
              "required_status_checks": {
                "url": "https://api.github.com/repos/test/test/branches/main/protection/required_status_checks",
                "strict": true,
                "contexts": ["ci/test"],
                "checks": [{"context": "ci/test", "app_id": 15368}]
              }
            }""")
        }
    )
    PASS(res)

def test_status_checks_not_required():
    res = eval(
        rule="branch_protection_require_status_checks",
        entity=ENTITY,
        mock_http={
            URL: body("""{
              "required_status_checks": null
            }""")
        }
    )
    FAIL(res)

def test_not_found():
    res = eval(
        rule="branch_protection_require_status_checks",
        entity=ENTITY,
        mock_http={
            URL: body("").code(404)
        }
    )
    FAIL(res)

def test_internal_error():
    res = eval(
        rule="branch_protection_require_status_checks",
        entity=ENTITY,
        mock_http={
            URL: body("").code(502)
        }
    )
    FAIL(res)
