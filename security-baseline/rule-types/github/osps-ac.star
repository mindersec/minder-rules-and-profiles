ENTITY = {"owner": "me", "name": "myrepo", "type": "repository", "default_branch": "main",
    "properties": {"github/repo_owner": "me", "github/repo_name": "myrepo", "github/default_branch": "main"}}
REPO_URL = "/repos/me/myrepo"

http_responses = {k: body(v) for k, v in txtar(read_file("testdata/branch-protection.txtar")).items()}

def branch_protected_endpoints(classic_type, ruleset_type, branch=None):
    """Return HTTP endpoints for testing, type can be either 'protected' or 'no-protection'."""
    if branch == None:
        branch = ENTITY["default_branch"]
    classic_url = "/repos/{}/{}/branches/{}/protection".format(ENTITY["owner"], ENTITY["name"], branch)
    ruleset_url = "/repos/{}/{}/rules/branches/{}".format(ENTITY["owner"], ENTITY["name"], branch)
    return {
        classic_url: http_responses["classic-{}.json".format(classic_type)],
        ruleset_url: http_responses["ruleset-{}.json".format(ruleset_type)],
    }

def test_ac_02_01_public():
    res = eval(
        rule="osps-ac-02-01",
        entity=ENTITY,
        mock_http={
            REPO_URL: body('{"visibility": "public"}')
        }
    )
    assert.eq(res["status"], "pass")

def test_ac_02_01_missing():
    res = eval(
        rule="osps-ac-02-01",
        entity=ENTITY,
        mock_http={
            REPO_URL: body('').code(404)
        }
    )
    assert.eq(res["status"], "error")

def test_ac_02_01_private():
    res = eval(
        rule="osps-ac-02-01",
        entity=ENTITY,
        mock_http={
            REPO_URL: body('{"visibility": "private"}')
        }
    )
    assert.eq(res["status"], "fail")

def test_ac_03_01_classic():
    res = eval(
        rule="osps-ac-03-01",
        entity=ENTITY,
        mock_http=branch_protected_endpoints("protected", "no-protection"),
        data_sources=["../../data-sources/baselineghapi.yaml"],
    )
    assert.eq(res["status"], "pass")
    assert.eq(res["message"], "")

def test_ac_03_01_ruleset():
    res = eval(
        rule="osps-ac-03-01",
        entity=ENTITY,
        mock_http=branch_protected_endpoints("no-protection", "protected"),
        data_sources=["../../data-sources/baselineghapi.yaml"],
    )
    assert.eq(res["status"], "pass")
    assert.eq(res["message"], "")

def test_ac_03_01_unprotected():
    endpoints = branch_protected_endpoints("no-protection", "no-protection")
    res = eval(
        rule="osps-ac-03-01",
        entity=ENTITY,
        mock_http=branch_protected_endpoints("no-protection", "no-protection"),
        data_sources=["../../data-sources/baselineghapi.yaml"],
    )
    assert.eq(res["status"], "fail")
    # assert.true(res["message"].count("Force pushes are allowed on the default branch") > 0)

# TODO: test ac-03-01 and ac-03-02 cases (these use datasources):
# ac-03-01 covers "force_push", ac-03-02 covers "allow_deletion"
# 1. Classic branch protection enabled
# 2. Ruleset enabled
# 3. Classic and ruleset enabled
# 4. Neither enabled
# 5. error cases (404 / 500)
