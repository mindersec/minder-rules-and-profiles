ENTITY = {"owner": "me", "name": "myrepo", "type": "repository", "default_branch": "main"}
REPO_URL = "/repos/me/myrepo"

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

# TODO: test ac-03-01 and ac-03-02 cases (these use datasources):
# ac-03-01 covers "force_push", ac-03-02 covers "allow_deletion"
# 1. Classic branch protection enabled
# 2. Ruleset enabled
# 3. Classic and ruleset enabled
# 4. Neither enabled
# 5. error cases (404 / 500)