ENTITY = {"owner": "me", "name": "myrepo", "type": "repository", "default_branch": "main"}
REPO_URL = "/repos/me/myrepo"

deps = txtar(read_file("testdata/dependencies.txtar"))

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

def test_qa_02_01_go_lock():
    keep = lambda name: name == "go.mod" or name == "go.sum"
    res = eval(
        rule="osps-qa-02-01",
        entity=ENTITY,
        mock_fs={k:deps[k] for k in deps if keep(k)}
    )
    assert.eq(res["status"], "pass")

def test_qa_02_01_go_nolock():
    keep = lambda name: name == "go.mod"
    res = eval(
        rule="osps-qa-02-01",
        entity=ENTITY,
        mock_fs={k:deps[k] for k in deps if keep(k)}
    )
    assert.eq(res["status"], "fail")

def test_qa_02_01_ruby_lock():
    keep = lambda name: name.find("Gemfile") != -1
    res = eval(
        rule="osps-qa-02-01",
        entity=ENTITY,
        mock_fs={k:deps[k] for k in deps if keep(k)}
    )
    assert.eq(res["status"], "pass")

def test_qa_02_01_ruby_nolock():
    keep = lambda name: name == "Gemfile"
    res = eval(
        rule="osps-qa-02-01",
        entity=ENTITY,
        mock_fs={k:deps[k] for k in deps if keep(k)}
    )
    assert.eq(res["status"], "fail")

def test_qa_02_01_javascript_package_lock():
    keep = lambda name: name == "package.json" or name == "package-lock.json"
    res = eval(
        rule="osps-qa-02-01",
        entity=ENTITY,
        mock_fs={k:deps[k] for k in deps if keep(k)}
    )
    assert.eq(res["status"], "pass")

def test_qa_02_01_javascript_yarn_lock():
    keep = lambda name: name == "package.json" or name == "yarn.lock"
    res = eval(
        rule="osps-qa-02-01",
        entity=ENTITY,
        mock_fs={k:deps[k] for k in deps if keep(k)}
    )
    assert.eq(res["status"], "pass")

def test_qa_02_01_javascript_nolock():
    keep = lambda name: name == "package.json"
    res = eval(
        rule="osps-qa-02-01",
        entity=ENTITY,
        mock_fs={k:deps[k] for k in deps if keep(k)}
    )
    assert.eq(res["status"], "fail")
