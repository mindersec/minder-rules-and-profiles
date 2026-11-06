ENTITY = {
    "owner": "me", "name": "myrepo", "type": "repository", "default_branch": "main",
    "properties": {"is_private": False}
}
REPO_URL = "/repos/me/myrepo"
REPO_BRANCH_URL = "/repos/me/myrepo/branches/main/protection"

# BRANCH_ENTITY includes GitHub-specific properties needed by rules that use
# the baselineghapi data source (e.g. osps-qa-01-02).
BRANCH_ENTITY = {
    "owner": "me", "name": "myrepo", "type": "repository", "default_branch": "main",
    "properties": {"github/repo_owner": "me", "github/repo_name": "myrepo", "github/default_branch": "main"}
}

# Load real GitHub API responses from the branch-protection fixture file.
_bp_http_responses = {k: body(v) for k, v in txtar(read_file("testdata/branch-protection.txtar")).items()}

def _bp_endpoints(classic_type, ruleset_type):
    """Return mock HTTP endpoints for classic and ruleset branch protection APIs."""
    branch = BRANCH_ENTITY["default_branch"]
    classic_url = "/repos/{}/{}/branches/{}/protection".format(BRANCH_ENTITY["owner"], BRANCH_ENTITY["name"], branch)
    ruleset_url = "/repos/{}/{}/rules/branches/{}".format(BRANCH_ENTITY["owner"], BRANCH_ENTITY["name"], branch)
    return {
        classic_url: _bp_http_responses["classic-{}.json".format(classic_type)],
        ruleset_url: _bp_http_responses["ruleset-{}.json".format(ruleset_type)],
    }

def test_qa_01_01_public():
    res = eval(
        rule="osps-qa-01-01",
        entity=ENTITY,
        mock_http={
            REPO_URL: body('{"visibility":"public","clone_url":"https://github.com/me/repo.git"}')
        }
    )
    assert.eq(res["status"], "pass")

def test_qa_01_01_missing():
    res = eval(
        rule="osps-qa-01-01",
        entity=ENTITY,
        mock_http={
            REPO_URL: body('').code(404)
        }
    )
    assert.eq(res["status"], "error")

def test_qa_01_01_private():
    res = eval(
        rule="osps-qa-01-01",
        entity=ENTITY,
        mock_http={
            REPO_URL: body('{"visibility":"private","clone_url":"https://github.com/me/repo.git"}')
        }
    )
    assert.eq(res["status"], "fail")

def test_qa_01_01_no_clone_url():
    # This shouldn't happen in the GitHub API, but worth testing
    res = eval(
        rule="osps-qa-01-01",
        entity=ENTITY,
        mock_http={
            REPO_URL: body('{"visibility":"public"}')
        }
    )
    assert.eq(res["status"], "fail")

def test_qa_01_02_private():
    res = eval(
        rule="osps-qa-01-02",
        entity=BRANCH_ENTITY | {"properties": BRANCH_ENTITY["properties"] | {"is_private": True}},
        mock_http=_bp_endpoints("protected", "no-protection"),
        data_sources=["../../data-sources/baselineghapi.yaml"],
    )
    assert.eq(res["status"], "fail")

def test_qa_01_02_unprotected():
    res = eval(
        rule="osps-qa-01-02",
        entity=BRANCH_ENTITY,
        mock_http=_bp_endpoints("no-protection", "no-protection"),
        data_sources=["../../data-sources/baselineghapi.yaml"],
    )
    assert.eq(res["status"], "fail")

def test_qa_01_02_ruleset_only():
    res = eval(
        rule="osps-qa-01-02",
        entity=BRANCH_ENTITY,
        mock_http=_bp_endpoints("no-protection", "protected"),
        data_sources=["../../data-sources/baselineghapi.yaml"],
    )
    assert.eq(res["status"], "pass")

def test_qa_01_02_classic():
    res = eval(
        rule="osps-qa-01-02",
        entity=BRANCH_ENTITY,
        mock_http=_bp_endpoints("protected", "no-protection"),
        data_sources=["../../data-sources/baselineghapi.yaml"],
    )
    assert.eq(res["status"], "pass")

def test_qa_01_02_force_pushes_enabled():
    res = eval(
        rule="osps-qa-01-02",
        entity=BRANCH_ENTITY,
        mock_http=_bp_endpoints("not-enabled", "not-enabled"),
        data_sources=["../../data-sources/baselineghapi.yaml"],
    )
    assert.eq(res["status"], "fail")
