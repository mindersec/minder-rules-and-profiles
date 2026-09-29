files = txtar(read_file("testdata/precommit.txtar"))

def test_should_have_at_least_one_pre_commit_hook_configured():
    res = eval(
        rule="require_pre_commit_to_be_configured",
        entity={"type": "repository", "default_branch": "main"},
        mock_fs={
            ".pre-commit-config.yaml": files["correct/.pre-commit-config.yaml"]
        }
    )
    assert.eq(res["status"], "pass")

def test_should_fail_pre_commit_is_not_configured_with_at_least_one_hook():
    res = eval(
        rule="require_pre_commit_to_be_configured",
        entity={"type": "repository", "default_branch": "main"},
        mock_fs={
            ".pre-commit-config.yaml": files["wrong/.pre-commit-config.yaml"]
        }
    )
    assert.true(res["status"] in ("fail", "error"))

def test_should_fail_is_pre_commit_is_not_configured_at_all():
    res = eval(
        rule="require_pre_commit_to_be_configured",
        entity={"type": "repository", "default_branch": "main"},
        mock_fs={}
    )
    assert.true(res["status"] in ("fail", "error"))
