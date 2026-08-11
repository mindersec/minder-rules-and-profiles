ENTITY = {
    "owner": "mindersec",
    "name": "minder",
    "type": "repository",
    "default_branch": "main"
}

RULE = "branch_protection_enforce_admins"

def build_mock_http(enabled):
    return {
        "/repos/mindersec/minder/branches/main/protection": body('{"enforce_admins": {"enabled": ' + ("true" if enabled else "false") + '}}')
    }

def build_mock_http_404():
    return {
        "/repos/mindersec/minder/branches/main/protection": body('{"message": "Not Protected"}').code(404)
    }

def test_branch_protection_enforce_admins_enabled():
    res = eval(
        rule=RULE,
        entity=ENTITY,
        profile={"enforce_admins": True},
        mock_http=build_mock_http(True)
    )
    assert.eq(res["status"], "pass")

def test_branch_protection_enforce_admins_disabled():
    res = eval(
        rule=RULE,
        entity=ENTITY,
        profile={"enforce_admins": True},
        mock_http=build_mock_http(False)
    )
    assert.eq(res["status"], "fail")

def test_branch_protection_enforce_admins_unprotected():
    res = eval(
        rule=RULE,
        entity=ENTITY,
        profile={"enforce_admins": True},
        mock_http=build_mock_http_404()
    )
    assert.eq(res["status"], "fail")
