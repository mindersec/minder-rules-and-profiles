def test_should_have_grype_github_action_enabled():
    res = eval(
        rule="grype_github_action_scan_repo",
        entity={"owner": "coolhead", "name": "haze-wave", "type": "repository", "default_branch": "main"},
        profile={},
        mock_fs={
            ".github/workflows/wf.yml": read_file("grype_github_action_scan_repo.testdata/action_enabled/.github/workflows/wf.yml")
        }
    )
    assert.eq(res["status"], "pass")

def test_action_is_missing():
    res = eval(
        rule="grype_github_action_scan_repo",
        entity={"owner": "coolhead", "name": "haze-wave", "type": "repository", "default_branch": "main"},
        profile={},
        mock_fs={
            ".github/workflows/wf.yml": read_file("grype_github_action_scan_repo.testdata/action_missing/.github/workflows/wf.yml")
        }
    )
    assert.true(res["status"] in ("fail", "error"))
    assert.true(res["message"] != "")

def test_action_is_enabled_but_not_for_repo_scanning():
    res = eval(
        rule="grype_github_action_scan_repo",
        entity={"owner": "coolhead", "name": "haze-wave", "type": "repository", "default_branch": "main"},
        profile={},
        mock_fs={
            ".github/workflows/wf.yml": read_file("grype_github_action_scan_repo.testdata/action_enabled_not_for_repo_scanning/.github/workflows/wf.yml")
        }
    )
    assert.true(res["status"] in ("fail", "error"))
    assert.true(res["message"] != "")
