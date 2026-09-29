def PASS(res):
    assert.eq(res["status"], "pass")

def FAIL(res):
    assert.true(res["status"] in ("fail", "error"))
    assert.true(res["message"] != "")

def enforce_file(content, fs):
    return eval(
        rule="enforce_file",
        entity={"type": "repository", "default_branch": "main"},
        profile={"file": "README", "content": content},
        mock_fs=fs
    )

file_present = {
    "README": "Test content",
}

def test_file_should_be_present():
    PASS(enforce_file("", file_present))

def test_file_is_missing():
    FAIL(enforce_file("", {}))

def test_file_present_and_matches_content():
    PASS(enforce_file("Test content", file_present))

def test_file_present_but_has_different_content():
    FAIL(enforce_file("Different content", file_present))

def test_file_present_but_has_more_content_than_expected():
    FAIL(enforce_file("Test", file_present))

def test_file_present_but_has_less_content_than_expected():
    FAIL(enforce_file("Test content with a subset", file_present))
