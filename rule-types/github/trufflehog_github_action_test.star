def test_should_have_trufflehog_enabled():
    res = eval(
        rule="trufflehog_github_action",
        entity={"type": "repository", "default_branch": "main"},
        profile={},
        mock_fs={
            ".github/workflows/trufflehog.yaml": read_file("trufflehog_github_action.testdata/github_action_with_trufflehog/.github/workflows/trufflehog.yaml")
        }
    )
    assert.eq(res["status"], "pass")

def test_should_not_have_renovate_enabled():
    res = eval(
        rule="trufflehog_github_action",
        entity={"type": "repository", "default_branch": "main"},
        profile={},
        mock_fs={
            ".github/workflows/not-trufflehog.yaml": read_file("trufflehog_github_action.testdata/github_action_without_trufflehog/.github/workflows/not-trufflehog.yaml")
        }
    )
    assert.true(res["status"] in ("fail", "error"))
    assert.true(res["message"] != "")
