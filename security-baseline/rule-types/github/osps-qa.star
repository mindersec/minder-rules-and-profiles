ENTITY = {"owner": "me", "name": "myrepo", "type": "repository", "default_branch": "main"}
REPO_URL = "/repos/me/myrepo"

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
