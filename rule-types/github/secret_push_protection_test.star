ENTITY = {
    "owner": "mindersec",
    "name": "minder",
    "type": "repository",
    "default_branch": "main"
}

RULE = "secret_push_protection"

def build_mock_http(is_private, status):
    payload = '{"private": %s, "security_and_analysis": {"secret_scanning_push_protection": {"status": "%s"}}}' % ("true" if is_private else "false", status)
    return {
        "/repos/mindersec/minder": body(payload)
    }

def test_secret_push_protection_enabled():
    res = eval(
        rule=RULE,
        entity=ENTITY,
        profile={"skip_private_repos": True},
        mock_http=build_mock_http(False, "enabled")
    )
    assert.eq(res["status"], "pass")

def test_secret_push_protection_disabled():
    res = eval(
        rule=RULE,
        entity=ENTITY,
        profile={"skip_private_repos": True},
        mock_http=build_mock_http(False, "disabled")
    )
    assert.eq(res["status"], "fail")

def test_secret_push_protection_skipped_private():
    res = eval(
        rule=RULE,
        entity=ENTITY,
        profile={"skip_private_repos": True},
        mock_http=build_mock_http(True, "disabled")
    )
    assert.eq(res["status"], "skip")

def test_secret_push_protection_failed_private():
    res = eval(
        rule=RULE,
        entity=ENTITY,
        profile={"skip_private_repos": False},
        mock_http=build_mock_http(True, "disabled")
    )
    assert.eq(res["status"], "fail")
