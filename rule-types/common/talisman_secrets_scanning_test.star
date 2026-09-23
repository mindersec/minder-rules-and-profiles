def test_should_have_talisman_pre_commit_hook_configured():
    res = eval(
        rule="talisman_secrets_scanning",
        entity={"type": "repository", "default_branch": "main"},
        profile={},
        mock_fs={
            ".pre-commit-config.yaml": read_file("talisman_secrets_scanning.testdata/correct/.pre-commit-config.yaml")
        }
    )
    assert.eq(res["status"], "pass")

def test_should_fail_talisman_pre_commit_hook_is_not_configured():
    res = eval(
        rule="talisman_secrets_scanning",
        entity={"type": "repository", "default_branch": "main"},
        profile={},
        mock_fs={
            ".pre-commit-config.yaml": read_file("talisman_secrets_scanning.testdata/misconfigured/.pre-commit-config.yaml")
        }
    )
    assert.true(res["status"] in ("fail", "error"))
    assert.true(res["message"] != "")
