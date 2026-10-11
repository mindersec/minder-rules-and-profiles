ENTITY = {
    "owner": "mindersec",
    "name": "minder",
    "type": "repository",
    "default_branch": "main"
}


def run_boolean_rule_tests(rule_name, profile_key, mock_builder):
    cases = {
        "enabled": {},
        "disabled": {"got": False, "fail": True},
        "unprotected": {"body": build_mock_http_404, "fail": True},
        "false_enabled": {"want": False, "fail": True},
        "false_disabled": {"want": False, "got": False},
        "custom_branch": {"branch": "other"}
    }
    
    for case, overrides in cases.items():
        values = {"want": True, "got": True}
        for k, v in overrides.items():
            values[k] = v
        
        params = {"branch": values["branch"]} if "branch" in values else {}
        
        if "body" in values:
            http = values["body"]()
        else:
            http = mock_builder(enabled=values["got"], branch=values.get("branch", "main"))
            
        profile = {profile_key: values["want"]} if profile_key else {}
            
        res = eval(
            rule=rule_name,
            entity=ENTITY,
            params=params,
            profile=profile,
            mock_http=http,
        )
        expected_status = "fail" if "fail" in values else "pass"
        # Include case name in the assert to make it easy to debug
        assert.eq("%s:%s" % (case, res["status"]), "%s:%s" % (case, expected_status))
def build_mock_http_404(branch="main"):
    payload = '{"message": "Branch not protected", "documentation_url": "https://docs.github.com/rest/branches/branch-protection#get-branch-protection", "status": "404"}'
    return {
        "/repos/mindersec/minder/branches/%s/protection" % branch: body(payload).code(404)
    }


def build_mock_http_branch_protection_allow_fork_syncing(enabled, branch="main"):
    payload = '{"allow_fork_syncing": {"enabled": %s}}' % ("true" if enabled else "false")
    return {
        "/repos/mindersec/minder/branches/%s/protection" % branch: body(payload)
    }

def build_mock_http_branch_protection_enabled(enabled, branch="main"):
    if enabled:
        payload = '{"url": "https://api.github.com/repos/mindersec/minder/branches/%s/protection"}' % branch
    else:
        payload = '{}'
    return {
        "/repos/mindersec/minder/branches/%s/protection" % branch: body(payload)
    }

def test_branch_protection_enabled_enabled():
    res = eval(
        rule="branch_protection_enabled",
        entity=ENTITY,
        profile={},
        mock_http=build_mock_http_branch_protection_enabled(True)
    )
    assert.eq(res["status"], "pass")


def test_branch_protection_enabled_disabled():
    res = eval(
        rule="branch_protection_enabled",
        entity=ENTITY,
        profile={},
        mock_http=build_mock_http_branch_protection_enabled(False)
    )
    assert.eq(res["status"], "fail")


def test_branch_protection_enabled_unprotected():
    res = eval(
        rule="branch_protection_enabled",
        entity=ENTITY,
        profile={},
        mock_http=build_mock_http_404()
    )
    assert.eq(res["status"], "fail")


def test_branch_protection_enabled_custom_branch():
    res = eval(
        rule="branch_protection_enabled",
        entity=ENTITY,
        params={"branch": "other"},
        profile={},
        mock_http=build_mock_http_branch_protection_enabled(True, branch="other")
    )
    assert.eq(res["status"], "pass")


def build_mock_http_branch_protection_enforce_admins(enabled, branch="main"):
    payload = '{"enforce_admins": {"enabled": %s}}' % ("true" if enabled else "false")
    return {
        "/repos/mindersec/minder/branches/%s/protection" % branch: body(payload)
    }

def build_mock_http_branch_protection_lock_branch(enabled, branch="main"):
    payload = '{"lock_branch": {"enabled": %s}}' % ("true" if enabled else "false")
    return {
        "/repos/mindersec/minder/branches/%s/protection" % branch: body(payload)
    }

def build_mock_http_branch_protection_require_conversation_resolution(enabled, branch="main"):
    payload = '{"required_conversation_resolution": {"enabled": %s}}' % ("true" if enabled else "false")
    return {
        "/repos/mindersec/minder/branches/%s/protection" % branch: body(payload)
    }

def build_mock_http_branch_protection_require_linear_history(enabled, branch="main"):
    payload = '{"required_linear_history": {"enabled": %s}}' % ("true" if enabled else "false")
    return {
        "/repos/mindersec/minder/branches/%s/protection" % branch: body(payload)
    }

def build_mock_http_branch_protection_require_pull_request_approving_review_count(count, branch="main"):
    payload = '{"required_pull_request_reviews": {"required_approving_review_count": %d}}' % count
    return {
        "/repos/mindersec/minder/branches/%s/protection" % branch: body(payload)
    }

def test_branch_protection_require_pull_request_approving_review_count_enabled():
    res = eval(
        rule="branch_protection_require_pull_request_approving_review_count",
        entity=ENTITY,
        profile={"required_approving_review_count": 2},
        mock_http=build_mock_http_branch_protection_require_pull_request_approving_review_count(2)
    )
    assert.eq(res["status"], "pass")


def test_branch_protection_require_pull_request_approving_review_count_disabled():
    res = eval(
        rule="branch_protection_require_pull_request_approving_review_count",
        entity=ENTITY,
        profile={"required_approving_review_count": 2},
        mock_http=build_mock_http_branch_protection_require_pull_request_approving_review_count(1)
    )
    assert.eq(res["status"], "fail")


def test_branch_protection_require_pull_request_approving_review_count_unprotected():
    res = eval(
        rule="branch_protection_require_pull_request_approving_review_count",
        entity=ENTITY,
        profile={"required_approving_review_count": 2},
        mock_http=build_mock_http_404()
    )
    assert.eq(res["status"], "fail")


def test_branch_protection_require_pull_request_approving_review_count_false_enabled():
    res = eval(
        rule="branch_protection_require_pull_request_approving_review_count",
        entity=ENTITY,
        profile={"required_approving_review_count": 1},
        mock_http=build_mock_http_branch_protection_require_pull_request_approving_review_count(2)
    )
    assert.eq(res["status"], "fail")


def test_branch_protection_require_pull_request_approving_review_count_false_disabled():
    res = eval(
        rule="branch_protection_require_pull_request_approving_review_count",
        entity=ENTITY,
        profile={"required_approving_review_count": 1},
        mock_http=build_mock_http_branch_protection_require_pull_request_approving_review_count(1)
    )
    assert.eq(res["status"], "pass")


def test_branch_protection_require_pull_request_approving_review_count_custom_branch():
    res = eval(
        rule="branch_protection_require_pull_request_approving_review_count",
        entity=ENTITY,
        params={"branch": "other"},
        profile={"required_approving_review_count": 2},
        mock_http=build_mock_http_branch_protection_require_pull_request_approving_review_count(2, branch="other")
    )
    assert.eq(res["status"], "pass")


def build_mock_http_branch_protection_require_pull_request_code_owners_review(enabled, branch="main"):
    payload = '{"required_pull_request_reviews": {"require_code_owner_reviews": %s}}' % ("true" if enabled else "false")
    return {
        "/repos/mindersec/minder/branches/%s/protection" % branch: body(payload)
    }

def build_mock_http_branch_protection_require_pull_request_dismiss_stale_reviews(enabled, branch="main"):
    payload = '{"required_pull_request_reviews": {"dismiss_stale_reviews": %s}}' % ("true" if enabled else "false")
    return {
        "/repos/mindersec/minder/branches/%s/protection" % branch: body(payload)
    }

def build_mock_http_branch_protection_require_pull_request_last_push_approval(enabled, branch="main"):
    payload = '{"required_pull_request_reviews": {"require_last_push_approval": %s}}' % ("true" if enabled else "false")
    return {
        "/repos/mindersec/minder/branches/%s/protection" % branch: body(payload)
    }

def build_mock_http_branch_protection_require_pull_requests(enabled, branch="main"):
    if enabled:
        payload = '{"required_pull_request_reviews": {"url": "https://api.github.com/repos/mindersec/minder/branches/%s/protection/required_pull_request_reviews"}}' % branch
    else:
        payload = '{"required_pull_request_reviews": {}}'
    return {
        "/repos/mindersec/minder/branches/%s/protection" % branch: body(payload)
    }

def test_branch_protection_require_pull_requests_enabled():
    res = eval(
        rule="branch_protection_require_pull_requests",
        entity=ENTITY,
        profile={"required_pull_request_reviews": True},
        mock_http=build_mock_http_branch_protection_require_pull_requests(True)
    )
    assert.eq(res["status"], "pass")


def test_branch_protection_require_pull_requests_disabled():
    res = eval(
        rule="branch_protection_require_pull_requests",
        entity=ENTITY,
        profile={"required_pull_request_reviews": True},
        mock_http=build_mock_http_branch_protection_require_pull_requests(False)
    )
    assert.eq(res["status"], "fail")


def test_branch_protection_require_pull_requests_unprotected():
    res = eval(
        rule="branch_protection_require_pull_requests",
        entity=ENTITY,
        profile={"required_pull_request_reviews": True},
        mock_http=build_mock_http_404()
    )
    assert.eq(res["status"], "fail")


def test_branch_protection_require_pull_requests_custom_branch():
    res = eval(
        rule="branch_protection_require_pull_requests",
        entity=ENTITY,
        params={"branch": "other"},
        profile={"required_pull_request_reviews": True},
        mock_http=build_mock_http_branch_protection_require_pull_requests(True, branch="other")
    )
    assert.eq(res["status"], "pass")


def build_mock_http_branch_protection_require_signatures(enabled, branch="main"):
    payload = '{"required_signatures": {"enabled": %s}}' % ("true" if enabled else "false")
    return {
        "/repos/mindersec/minder/branches/%s/protection" % branch: body(payload)
    }

def test_branch_protection_require_signatures_enabled():
    res = eval(
        rule="branch_protection_require_signatures",
        entity=ENTITY,
        profile={},
        mock_http=build_mock_http_branch_protection_require_signatures(True)
    )
    assert.eq(res["status"], "pass")


def test_branch_protection_require_signatures_disabled():
    res = eval(
        rule="branch_protection_require_signatures",
        entity=ENTITY,
        profile={},
        mock_http=build_mock_http_branch_protection_require_signatures(False)
    )
    assert.eq(res["status"], "fail")


def test_branch_protection_require_signatures_unprotected():
    res = eval(
        rule="branch_protection_require_signatures",
        entity=ENTITY,
        profile={},
        mock_http=build_mock_http_404()
    )
    assert.eq(res["status"], "fail")


def test_branch_protection_require_signatures_custom_branch():
    res = eval(
        rule="branch_protection_require_signatures",
        entity=ENTITY,
        params={"branch": "other"},
        profile={},
        mock_http=build_mock_http_branch_protection_require_signatures(True, branch="other")
    )
    assert.eq(res["status"], "pass")


def test_branch_protection_allow_fork_syncing():
    run_boolean_rule_tests("branch_protection_allow_fork_syncing", "allow_fork_syncing", build_mock_http_branch_protection_allow_fork_syncing)

def test_branch_protection_enforce_admins():
    run_boolean_rule_tests("branch_protection_enforce_admins", "enforce_admins", build_mock_http_branch_protection_enforce_admins)

def test_branch_protection_lock_branch():
    run_boolean_rule_tests("branch_protection_lock_branch", "lock_branch", build_mock_http_branch_protection_lock_branch)

def test_branch_protection_require_conversation_resolution():
    run_boolean_rule_tests("branch_protection_require_conversation_resolution", "required_conversation_resolution", build_mock_http_branch_protection_require_conversation_resolution)

def test_branch_protection_require_linear_history():
    run_boolean_rule_tests("branch_protection_require_linear_history", "required_linear_history", build_mock_http_branch_protection_require_linear_history)

def test_branch_protection_require_pull_request_code_owners_review():
    run_boolean_rule_tests("branch_protection_require_pull_request_code_owners_review", "require_code_owner_reviews", build_mock_http_branch_protection_require_pull_request_code_owners_review)

def test_branch_protection_require_pull_request_dismiss_stale_reviews():
    run_boolean_rule_tests("branch_protection_require_pull_request_dismiss_stale_reviews", "dismiss_stale_reviews", build_mock_http_branch_protection_require_pull_request_dismiss_stale_reviews)

def test_branch_protection_require_pull_request_last_push_approval():
    run_boolean_rule_tests("branch_protection_require_pull_request_last_push_approval", "require_last_push_approval", build_mock_http_branch_protection_require_pull_request_last_push_approval)
