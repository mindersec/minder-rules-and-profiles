def test_should_not_have_golangci_lint_gh_action_configured():
    res = eval(
        rule="golangci-lint_github_action",
        entity={"type": "repository", "default_branch": "main"},
        profile={},
        mock_fs={
            ".github/workflows/negative_mock.yml": read_file("golangci-lint_github_action.testdata/repo_without_golangci-lint_gh_action/.github/workflows/negative_mock.yml")
        }
    )
    assert.true(res["status"] in ("fail", "error"))
    assert.true(res["message"] != "")

def test_should_have_golangci_lint_gh_action_configured():
    res = eval(
        rule="golangci-lint_github_action",
        entity={"type": "repository", "default_branch": "main"},
        profile={},
        mock_fs={
            ".github/workflows/positive_mock.yml": read_file("golangci-lint_github_action.testdata/repo_with_golangci-lint_gh_action/.github/workflows/positive_mock.yml")
        }
    )
    assert.eq(res["status"], "pass")
