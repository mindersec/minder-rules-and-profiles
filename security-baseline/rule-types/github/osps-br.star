ENTITY = {"owner": "me", "name": "myrepo", "type": "repository", "default_branch": "main"}
REPO_URL = "/repos/me/myrepo"

workflow_files = txtar(read_file("testdata/workflows.txtar"))

def test_br01_01_no_workflows():
    res = eval(
        rule="osps-br-01-01",
        entity=ENTITY,
        mock_fs={k: workflow_files[k] for k in workflow_files if k == "README.md"}
    )
    assert.eq(res["status"], "pass")

def test_br01_01_safe_workflows():
    keep = lambda file: file.find("ref") == -1 and file.find("inject") == -1
    res = eval(
        rule="osps-br-01-01",
        entity=ENTITY,
        mock_fs={k: workflow_files[k] for k in workflow_files if keep(k)}
    )
    assert.eq(res["status"], "pass")

def test_br_01_01_unsafe_checkout():
    keep = lambda file: file.find("ref") != -1
    res = eval(
        rule="osps-br-01-01",
        entity=ENTITY,
        mock_fs={k: workflow_files[k] for k in workflow_files if keep(k)}
    )
    assert.eq(res["status"], "fail")
    assert.eq(res["message"],
    '''evaluation failure: Evaluation failures: 
 - Workflow .github\\workflows\\pr_test_ref.yaml has a dangerous trigger and checks out a pull request in job 'test'
 - Workflow .github\\workflows\\pr_workflow_ref.yaml has a dangerous trigger and checks out a pull request in job 'exec': Multiple issues:
* Workflow .github\\workflows\\pr_test_ref.yaml has a dangerous trigger and checks out a pull request in job 'test'
* Workflow .github\\workflows\\pr_workflow_ref.yaml has a dangerous trigger and checks out a pull request in job 'exec'
''')
 
def test_br_01_01_var_injection():
    keep = lambda file: file.find("inject") != -1
    res = eval(
        rule="osps-br-01-01",
        entity=ENTITY,
        mock_fs={k: workflow_files[k] for k in workflow_files if keep(k)}
    )
    assert.eq(res["status"], "fail")
    assert.eq(res["message"],
    '''evaluation failure: Evaluation failures: 
 - Workflow .github\\workflows\\pr_title_inject.yaml has possible event script injection in step 0 of job 'check-title': Workflow .github\\workflows\\pr_title_inject.yaml has possible event script injection in step 0 of job 'check-title'
''')

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