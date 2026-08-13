ENTITY = {
    "owner": "mindersec",
    "name": "minder",
    "type": "repository",
    "default_branch": "main"
}

RULE = "branch_protection_enforce_admins"

def build_mock_http(enabled, branch="main"):
    payload = '{"enforce_admins": {"enabled": %s}}' % ("true" if enabled else "false")
    return {
        "/repos/mindersec/minder/branches/%s/protection" % branch: body(payload)
    }

def build_mock_http_404(branch="main"):
    payload = '{"message": "Not Protected"}'
    return {
        "/repos/mindersec/minder/branches/%s/protection" % branch: body(payload).code(404)
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

def test_branch_protection_enforce_admins_false_enabled():
    res = eval(
        rule=RULE,
        entity=ENTITY,
        profile={"enforce_admins": False},
        mock_http=build_mock_http(True)
    )
    assert.eq(res["status"], "fail")

def test_branch_protection_enforce_admins_false_disabled():
    res = eval(
        rule=RULE,
        entity=ENTITY,
        profile={"enforce_admins": False},
        mock_http=build_mock_http(False)
    )
    assert.eq(res["status"], "pass")

def test_branch_protection_enforce_admins_custom_branch():
    res = eval(
        rule=RULE,
        entity=ENTITY,
        params={"branch": "other"},
        profile={"enforce_admins": True},
        mock_http=build_mock_http(True, branch="other")
    )
    assert.eq(res["status"], "pass")
