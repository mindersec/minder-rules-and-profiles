ENTITY = {
    "owner": "mindersec",
    "name": "minder",
    "type": "repository",
    "default_branch": "main",
}

URL = "/repos/mindersec/minder/actions/permissions/access"


def workflow_access(want, got=None):
    """Helper to evaluate repo_workflow_access_level against a mocked API response."""
    if got == None:
        got = want
    return eval(
        rule="repo_workflow_access_level",
        entity=ENTITY,
        profile={"access_level": want},
        mock_http={URL: body('{"access_level": "%s"}' % got)},
    )


def test_none_matches():
    res = workflow_access("none")
    assert.eq(res["status"], "pass")


def test_user_matches():
    res = workflow_access("user")
    assert.eq(res["status"], "pass")


def test_organization_matches():
    res = workflow_access("organization")
    assert.eq(res["status"], "pass")


def test_user_when_none_required_fails():
    res = workflow_access("none", got="user")
    assert.eq(res["status"], "fail")


def test_organization_when_none_required_fails():
    res = workflow_access("none", got="organization")
    assert.eq(res["status"], "fail")


def test_none_when_organization_required_fails():
    res = workflow_access("organization", got="none")
    assert.eq(res["status"], "fail")


def test_server_error_returns_error():
    res = eval(
        rule="repo_workflow_access_level",
        entity=ENTITY,
        profile={"access_level": "none"},
        mock_http={URL: body("").code(500)},
    )
    assert.eq(res["status"], "error")
