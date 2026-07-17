def test_force_push_not_allowed():
    res = eval(
        rule="branch_protection_allow_force_pushes",
        entity={"owner": "mindersec", "name": "minder", "type": "repository", "default_branch": "main"},
        profile={},
        mock_http={
            "/repos/mindersec/minder/branches/main/protection": body("{\"allow_force_pushes\": {\"enabled\": false}}")
        }
    )
    assert.eq(res["status"], "pass")

def test_force_push_allowed():
    res = eval(
        rule="branch_protection_allow_force_pushes",
        entity={"owner": "mindersec", "name": "minder", "type": "repository", "default_branch": "main"},
        profile={},
        mock_http={
            "/repos/mindersec/minder/branches/main/protection": body("{\"allow_force_pushes\": {\"enabled\": true}}")
        }
    )
    assert.true(res["status"] in ("fail", "error"))
    assert.true(res["message"] != "")

def test_not_found():
    res = eval(
        rule="branch_protection_allow_force_pushes",
        entity={"owner": "mindersec", "name": "minder", "type": "repository", "default_branch": "main"},
        profile={},
        mock_http={
            "/repos/mindersec/minder/branches/main/protection": body("{\"woot\": \"woot\"}").code(404)
        }
    )
    assert.true(res["status"] in ("fail", "error"))
    assert.true(res["message"] != "")

def test_internal_error():
    res = eval(
        rule="branch_protection_allow_force_pushes",
        entity={"owner": "mindersec", "name": "minder", "type": "repository", "default_branch": "main"},
        profile={},
        mock_http={
            "/repos/mindersec/minder/branches/main/protection": body("{\"woot\": \"woot\"}").code(502)
        }
    )
    assert.true(res["status"] in ("fail", "error"))
    assert.true(res["message"] != "")
