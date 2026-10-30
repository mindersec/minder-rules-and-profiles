ENTITY = {
    "owner": "mindersec",
    "name": "minder",
    "type": "repository",
    "default_branch": "main",
}

URL = "/repos/mindersec/minder/actions/permissions/workflow"


def build_response(permissions="read", can_approve=False):
    """Build a mock GitHub Actions workflow permissions API response."""
    return body('{"default_workflow_permissions": "%s", "can_approve_pull_request_reviews": %s}' % (
        permissions,
        "true" if can_approve else "false",
    ))


def workflow_perms(permissions, can_approve, api_permissions=None, api_can_approve=None):
    """Helper to evaluate default_workflow_permissions against a mocked API response."""
    if api_permissions == None:
        api_permissions = permissions
    if api_can_approve == None:
        api_can_approve = can_approve
    return eval(
        rule="default_workflow_permissions",
        entity=ENTITY,
        profile={
            "default_workflow_permissions": permissions,
            "can_approve_pull_request_reviews": can_approve,
        },
        mock_http={URL: build_response(api_permissions, api_can_approve)},
    )


def test_read_no_approve_matches():
    res = workflow_perms("read", False)
    assert.eq(res["status"], "pass")


def test_write_with_approve_matches():
    res = workflow_perms("write", True)
    assert.eq(res["status"], "pass")


def test_wrong_permissions_level_fails():
    res = workflow_perms("read", False, api_permissions="write")
    assert.eq(res["status"], "fail")


def test_wrong_can_approve_fails():
    res = workflow_perms("read", True, api_can_approve=False)
    assert.eq(res["status"], "fail")


def test_both_fields_wrong_fails():
    res = workflow_perms("read", True, api_permissions="write", api_can_approve=False)
    assert.eq(res["status"], "fail")


def test_server_error_returns_error():
    res = eval(
        rule="default_workflow_permissions",
        entity=ENTITY,
        profile={"default_workflow_permissions": "read", "can_approve_pull_request_reviews": False},
        mock_http={URL: body("").code(500)},
    )
    assert.eq(res["status"], "error")
