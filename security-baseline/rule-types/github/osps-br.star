ENTITY = {
    "owner": "me", "name": "myrepo", "type": "repository", "default_branch": "main",
    "properties": {"github/repo_owner": "me", "github/repo_name": "myrepo"}
}
REPO_URL = "/repos/me/myrepo"

workflow_files = txtar(read_file("testdata/workflows.txtar"))

def filter_workflows(filter):
    """Filter the workflow_files using a boolean filter function"""
    return {k:workflow_files[k] for k in workflow_files if filter(k)}

def test_br_01_01_no_workflows():
    res = eval(
        rule="osps-br-01-01",
        entity=ENTITY,
        mock_fs=filter_workflows(lambda file: file == "README.md")
    )
    assert.eq(res["status"], "pass")

def test_br_01_01_safe_workflows():
    res = eval(
        rule="osps-br-01-01",
        entity=ENTITY,
        mock_fs=filter_workflows(lambda file: file.count("inject") == 0)
    )
    assert.eq(res["status"], "pass")

def test_br_01_01_var_injection():
    res = eval(
        rule="osps-br-01-01",
        entity=ENTITY,
        mock_fs=filter_workflows(lambda file: file.count("inject") > 0)
    )
    assert.eq(res["status"], "fail")
    # Flag the file
    assert.true(res["message"].count("pr_title_inject.yaml") > 0)
    assert.true(res["message"].count("has possible event script injection in step") > 0)

def test_br_01_03_no_workflows():
    res = eval(
        rule="osps-br-01-03",
        entity=ENTITY,
        mock_fs=filter_workflows(lambda file: file == "README.md")
    )
    assert.eq(res["status"], "pass")

def test_br_01_03_safe_workflows():
    res = eval(
        rule="osps-br-01-03",
        entity=ENTITY,
        mock_fs=filter_workflows(lambda file: file.count("ref") == 0)
    )
    assert.eq(res["status"], "pass")

def test_br_01_03_unsafe_checkout():
    res = eval(
        rule="osps-br-01-03",
        entity=ENTITY,
        mock_fs=filter_workflows(lambda file: file.count("ref") > 0)
    )
    assert.eq(res["status"], "fail")
    # Flag each file
    assert.true(res["message"].count("pr_test_ref.yaml") > 0)
    assert.true(res["message"].count("pr_workflow_ref.yaml") > 0)
    # Explains the problem
    assert.true(res["message"].count("has a dangerous trigger and checks out") > 0)
 
def test_br_03_01_is_public():
    res = eval(
        rule="osps-br-03-01",
        entity=ENTITY,
        mock_http={
            REPO_URL: body('{"clone_url": "https://github.com/mindersec/minder.git"}')
        }
    )
    assert.eq(res["status"], "pass")

def test_br_03_01_missing():
    res = eval(
        rule="osps-br-03-01",
        entity=ENTITY,
        mock_http={
            REPO_URL: body('').code(404)
        }
    )
    assert.eq(res["status"], "error")

def test_br_03_01_not_http():
    # This shouldn't be true on GitHub, but if the repo URL were somehow HTTP...
    res = eval(
        rule="osps-br-03-01",
        entity=ENTITY,
        mock_http={
            REPO_URL: body('{"clone_url": "http://github.com/mindersec/minder.git"}')
        }
    )
    assert.eq(res["status"], "fail")

def test_br_07_01_gitignore():
    res = eval(
        rule="osps-br-07-01",
        entity=ENTITY,
        data_sources=["../../data-sources/baselineghapi.yaml"],
        mock_fs={".gitignore": "# Exclude secret patterns\n.secrets"},
    )
    assert.eq(res["status"], "pass")
    assert.eq(res["message"], "")

def test_br_07_01_api_protected():
    res = eval(
        rule="osps-br-07-01",
        entity=ENTITY,
        data_sources=["../../data-sources/baselineghapi.yaml"],
        mock_fs={"README.md": "I use GitHub's controls"},
        mock_http={
            REPO_URL: body('{"security_and_analysis": {"secret_scanning_push_protection": {"status": "enabled"}}}')
        },
    )
    assert.eq(res["status"], "pass")
    assert.eq(res["message"], "")

def test_br_07_01_unsafe():
    res = eval(
        rule="osps-br-07-01",
        entity=ENTITY,
        data_sources=["../../data-sources/baselineghapi.yaml"],
        mock_fs={"README.md": "I don't care about security"},
        mock_http={
            REPO_URL: body('{"security_and_analysis": {"secret_scanning_push_protection": {"status": "disabled"}}}')
        },
    )
    assert.eq(res["status"], "fail")
    assert.true(res["message"].count("No .gitignore or secret push protection configured") > 0)