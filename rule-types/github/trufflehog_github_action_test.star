ENTITY = {"type": "repository", "default_branch": "main"}

def PASS(res):
    assert.eq(res["status"], "pass")

def FAIL(res):
    assert.true(res["status"] in ("fail", "error"))
    assert.true(res["message"] != "")

def test_trufflehog_present_passes():
    res = eval(
        rule="trufflehog_github_action",
        entity=ENTITY,
        mock_fs={
            ".github/workflows/trufflehog.yaml": read_file("trufflehog_github_action.testdata/github_action_with_trufflehog/.github/workflows/trufflehog.yaml")
        }
    )
    PASS(res)

def test_trufflehog_missing_fails():
    res = eval(
        rule="trufflehog_github_action",
        entity=ENTITY,
        mock_fs={
            ".github/workflows/not-trufflehog.yaml": read_file("trufflehog_github_action.testdata/github_action_without_trufflehog/.github/workflows/not-trufflehog.yaml")
        }
    )
    FAIL(res)
