ENTITY = {"owner": "me", "name": "myrepo", "type": "repository", "default_branch": "main"}
REPO_URL = "/repos/me/myrepo"

deps_files = txtar(read_file("testdata/dependencies.txtar"))

def filter_deps(filter):
    """Filter the deps_files using a boolean filter function"""
    return {k:deps_files[k] for k in deps_files if filter(k)}

def test_qa_02_01_go_lock():
    res = eval(
        rule="osps-qa-02-01",
        entity=ENTITY,
        mock_fs=filter_deps(lambda name: name == "go.mod" or name == "go.sum")
    )
    assert.eq(res["status"], "pass")

def test_qa_02_01_go_nolock():
    res = eval(
        rule="osps-qa-02-01",
        entity=ENTITY,
        mock_fs=filter_deps(lambda name: name == "go.mod")
    )
    assert.eq(res["status"], "fail")

def test_qa_02_01_ruby_lock():
    res = eval(
        rule="osps-qa-02-01",
        entity=ENTITY,
        mock_fs=filter_deps(lambda name: name.find("Gemfile") != -1)
    )
    assert.eq(res["status"], "pass")

def test_qa_02_01_ruby_nolock():
    res = eval(
        rule="osps-qa-02-01",
        entity=ENTITY,
        mock_fs=filter_deps(lambda name: name == "Gemfile")
    )
    assert.eq(res["status"], "fail")

def test_qa_02_01_javascript_package_lock():
    res = eval(
        rule="osps-qa-02-01",
        entity=ENTITY,
        mock_fs=filter_deps(lambda name: name == "package.json" or name == "package-lock.json")
    )
    assert.eq(res["status"], "pass")

def test_qa_02_01_javascript_yarn_lock():
    res = eval(
        rule="osps-qa-02-01",
        entity=ENTITY,
        mock_fs=filter_deps(lambda name: name == "package.json" or name == "yarn.lock")
    )
    assert.eq(res["status"], "pass")

def test_qa_02_01_javascript_nolock():
    res = eval(
        rule="osps-qa-02-01",
        entity=ENTITY,
        mock_fs=filter_deps(lambda name: name == "package.json")
    )
    assert.eq(res["status"], "fail")
