ENTITY = {
    "owner": "me", "name": "myrepo", "type": "repository", "default_branch": "main",
    "properties": {"github/repo_owner": "me", "github/repo_name": "myrepo"}
}

def test_vm_05_01_policy_in_repo():
    res = eval(
        rule="osps-vm-02-01",
        entity=ENTITY,
        data_sources=["../../data-sources/baselineghapi.yaml"],
        mock_fs={
            "SECURITY.md": "How to submit reports: email foo@example.com"
        }
    )
    assert.eq(res["status"], "pass")
    assert.eq(res["message"], "")

def test_vm_05_01_github_reporting():
    res = eval(
        rule="osps-vm-02-01",
        entity=ENTITY,
        data_sources=["../../data-sources/baselineghapi.yaml"],
        mock_fs={
            "SECURITY.md": "Use the GitHub vulnerability method"
        },
        mock_http={
            "/repos/me/myrepo/private-vulnerability-reporting": body('{"enabled": true}')
        }
    )
    assert.eq(res["status"], "pass")
    assert.eq(res["message"], "")

def test_vm_05_01_no_policy():
    res = eval(
        rule="osps-vm-02-01",
        entity=ENTITY,
        data_sources=["../../data-sources/baselineghapi.yaml"],
        mock_fs={
            "README.md": "How to submit reports: email foo@example.com",
            "SECURITY.txt": "We have a security model, but no process",
        }
    )
    assert.eq(res["status"], "fail")
    assert.true(res["message"].count("No contacts or process for reporting vulnerabilities was found") > 0)