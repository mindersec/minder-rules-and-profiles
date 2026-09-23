ENTITY = {"type": "repository", "default_branch": "main"}

files = txtar(read_file("testdata/trufflehog.txtar"))

def test_should_have_trufflehog_enabled():
    res = eval(
        rule="trufflehog_github_action",
        entity=ENTITY,
        mock_fs=files
    )
    assert.eq(res["status"], "pass")

def test_should_not_have_trufflehog_enabled():
    res = eval(
        rule="trufflehog_github_action",
        entity=ENTITY,
        # Filter the trufflehog action, keep others
        mock_fs={k: v for k, v in files.items() if k.find("trufflehog") == -1}
    )
    assert.eq(res["status"], "fail")
