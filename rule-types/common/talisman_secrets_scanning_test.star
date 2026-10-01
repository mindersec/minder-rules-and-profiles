files = txtar(read_file("testdata/talisman.txtar"))

def test_should_have_talisman_pre_commit_hook_configured():
    res = eval(
        rule="talisman_secrets_scanning",
        entity={"type": "repository", "default_branch": "main"},
        profile={},
        mock_fs={
            ".pre-commit-config.yaml": files["correct/.pre-commit-config.yaml"]
        }
    )
    assert.eq(res["status"], "pass")

def test_should_fail_talisman_pre_commit_hook_is_not_configured():
    res = eval(
        rule="talisman_secrets_scanning",
        entity={"type": "repository", "default_branch": "main"},
        profile={},
        mock_fs={
            ".pre-commit-config.yaml": files["wrong/.pre-commit-config.yaml"]
        }
    )
    assert.true(res["status"] in ("fail", "error"))
    assert.true(res["message"] != "")
