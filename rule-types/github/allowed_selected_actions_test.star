ENTITY = {
    "owner": "mindersec",
    "name": "minder",
    "type": "repository",
    "default_branch": "main",
}

URL = "/repos/mindersec/minder/actions/permissions/selected-actions"


def build_response(github_owned=True, verified=True, patterns=[]):
    """Build a mock GitHub selected-actions API response."""
    patterns_json = "[%s]" % ", ".join(['"%s"' % p for p in patterns])
    return body('{"github_owned_allowed": %s, "verified_allowed": %s, "patterns_allowed": %s}' % (
        "true" if github_owned else "false",
        "true" if verified else "false",
        patterns_json,
    ))


def selected_actions(github_owned, verified, patterns, api_github_owned=None, api_verified=None, api_patterns=None):
    """Helper to evaluate allowed_selected_actions against a mocked API response."""
    if api_github_owned == None:
        api_github_owned = github_owned
    if api_verified == None:
        api_verified = verified
    if api_patterns == None:
        api_patterns = patterns
    return eval(
        rule="allowed_selected_actions",
        entity=ENTITY,
        profile={
            "github_owned_allowed": github_owned,
            "verified_allowed": verified,
            "patterns_allowed": patterns,
        },
        mock_http={URL: build_response(api_github_owned, api_verified, api_patterns)},
    )


def test_all_fields_match_passes():
    res = selected_actions(True, True, [])
    assert.eq(res["status"], "pass")


def test_with_patterns_matches():
    res = selected_actions(True, False, ["monalisa/*"])
    assert.eq(res["status"], "pass")


def test_github_owned_mismatch_fails():
    res = selected_actions(True, True, [], api_github_owned=False)
    assert.eq(res["status"], "fail")


def test_verified_mismatch_fails():
    res = selected_actions(True, True, [], api_verified=False)
    assert.eq(res["status"], "fail")


def test_patterns_mismatch_fails():
    res = selected_actions(True, True, ["monalisa/*"], api_patterns=["other-org/*"])
    assert.eq(res["status"], "fail")


def test_409_when_not_in_selected_mode_fails():
    # GitHub returns 409 when allowed_actions is not set to "selected".
    # The ingester fallback rewrites this to a body that won't match any profile field.
    res = eval(
        rule="allowed_selected_actions",
        entity=ENTITY,
        profile={"github_owned_allowed": True, "verified_allowed": True, "patterns_allowed": []},
        mock_http={URL: body('{"http_status": 404, "message": "Not Protected"}').code(409)},
    )
    assert.eq(res["status"], "fail")


def test_server_error_returns_error():
    res = eval(
        rule="allowed_selected_actions",
        entity=ENTITY,
        profile={"github_owned_allowed": True, "verified_allowed": True, "patterns_allowed": []},
        mock_http={URL: body("").code(500)},
    )
    assert.eq(res["status"], "error")
