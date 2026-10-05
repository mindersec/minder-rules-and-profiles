ENTITY = {
    "owner": "me", "name": "myrepo", "type": "repository", "default_branch": "main",
    "properties": {"is_private": False}
}
REPO_URL = "/repos/me/myrepo"
REPO_BRANCH_URL = "/repos/me/myrepo/branches/main/protection"

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

def test_qa_01_02_okay():
    # This shouldn't happen in the GitHub API, but worth testing
    res = eval(
        rule="osps-qa-01-02",
        entity=ENTITY,
        mock_http={
            REPO_BRANCH_URL: body('{"allow_force_pushes":{"enabled":false}}')
        }
    )
    assert.eq(res["status"], "pass")
    assert.eq(res["message"], "")

def test_qa_01_02_can_rewrite():
    # This shouldn't happen in the GitHub API, but worth testing
    res = eval(
        rule="osps-qa-01-02",
        entity=ENTITY,
        mock_http={
            REPO_BRANCH_URL: body('{"allow_force_pushes":{"enabled":true}}')
        }
    )
    assert.eq(res["status"], "fail")

def test_qa_01_02_private():
    res = eval(
        rule="osps-qa-01-02",
        entity=ENTITY | {"properties": {"is_private": True}},
        mock_http={
            REPO_BRANCH_URL: body('{"allow_force_pushes":{"enabled":false}}')
        }
    )
    assert.eq(res["status"], "fail")