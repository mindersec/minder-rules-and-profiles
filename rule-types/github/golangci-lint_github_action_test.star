files = txtar(read_file("testdata/golangci-lint.txtar"))

def test_should_not_have_golangci_lint_gh_action_configured():
    res = eval(
        rule="golangci-lint_github_action",
        entity={"type": "repository", "default_branch": "main"},
        profile={},
        mock_fs={
            ".github/workflows/negative_mock.yml": files["wrong/workflow.yaml"]
        }
    )
    assert.eq(res["status"], "fail")

def test_should_have_golangci_lint_gh_action_configured():
    res = eval(
        rule="golangci-lint_github_action",
        entity={"type": "repository", "default_branch": "main"},
        profile={},
        mock_fs={
            ".github/workflows/positive_mock.yml": files["correct/workflow.yaml"]
        }
    )
    assert.eq(res["status"], "pass")
