ENTITY = {
    "owner": "mindersec",
    "name": "minder",
    "type": "repository",
    "default_branch": "main",
}

URL = "/repos/mindersec/minder/actions/permissions"


def actions_allowed(want, got=None):
    """Helper to evaluate github_actions_allowed against a mocked API response."""
    if got == None:
        got = want
    return eval(
        rule="github_actions_allowed",
        entity=ENTITY,
        profile={"allowed_actions": want},
        mock_http={URL: body('{"enabled": true, "allowed_actions": "%s"}' % got)},
    )


def test_local_only_matches():
    res = actions_allowed("local_only")
    assert.eq(res["status"], "pass")


def test_all_matches():
    res = actions_allowed("all")
    assert.eq(res["status"], "pass")


def test_selected_matches():
    res = actions_allowed("selected")
    assert.eq(res["status"], "pass")


def test_all_when_local_only_required_fails():
    res = actions_allowed("local_only", got="all")
    assert.eq(res["status"], "fail")


def test_selected_when_local_only_required_fails():
    res = actions_allowed("local_only", got="selected")
    assert.eq(res["status"], "fail")


def test_local_only_when_selected_required_fails():
    res = actions_allowed("selected", got="local_only")
    assert.eq(res["status"], "fail")


def test_server_error_returns_error():
    res = eval(
        rule="github_actions_allowed",
        entity=ENTITY,
        profile={"allowed_actions": "local_only"},
        mock_http={URL: body("").code(500)},
    )
    assert.eq(res["status"], "error")
