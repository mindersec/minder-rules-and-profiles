def test_status_checks_required():
    res = eval(
        rule="branch_protection_require_status_checks",
        entity={"owner": "mindersec", "name": "minder", "type": "repository", "default_branch": "main"},
        profile={},
        mock_http={
            "/repos/mindersec/minder/branches//protection": body("{\"required_status_checks\": {\"url\": \"https://api.github.com/repos/test/test/branches/main/protection/required_status_checks\", \"strict\": false, \"contexts\": [], \"checks\": []}}")
        }
    )
    assert.eq(res["status"], "pass")

def test_status_checks_required_with_strict_mode():
    res = eval(
        rule="branch_protection_require_status_checks",
        entity={"owner": "mindersec", "name": "minder", "type": "repository", "default_branch": "main"},
        profile={},
        mock_http={
            "/repos/mindersec/minder/branches//protection": body("{\"required_status_checks\": {\"url\": \"https://api.github.com/repos/test/test/branches/main/protection/required_status_checks\", \"strict\": true, \"contexts\": [\"ci/test\"], \"checks\": [{\"context\": \"ci/test\", \"app_id\": 15368}]}}")
        }
    )
    assert.eq(res["status"], "pass")

def test_status_checks_not_required():
    res = eval(
        rule="branch_protection_require_status_checks",
        entity={"owner": "mindersec", "name": "minder", "type": "repository", "default_branch": "main"},
        profile={},
        mock_http={
            "/repos/mindersec/minder/branches//protection": body("{\"required_status_checks\": null}")
        }
    )
    assert.true(res["status"] in ("fail", "error"))
    assert.true(res["message"] != "")

def test_not_found():
    res = eval(
        rule="branch_protection_require_status_checks",
        entity={"owner": "mindersec", "name": "minder", "type": "repository", "default_branch": "main"},
        profile={},
        mock_http={
            "/repos/mindersec/minder/branches//protection": body("{\"woot\": \"woot\"}").code(404)
        }
    )
    assert.true(res["status"] in ("fail", "error"))
    assert.true(res["message"] != "")

def test_internal_error():
    res = eval(
        rule="branch_protection_require_status_checks",
        entity={"owner": "mindersec", "name": "minder", "type": "repository", "default_branch": "main"},
        profile={},
        mock_http={
            "/repos/mindersec/minder/branches//protection": body("{\"woot\": \"woot\"}").code(502)
        }
    )
    assert.true(res["status"] in ("fail", "error"))
    assert.true(res["message"] != "")
