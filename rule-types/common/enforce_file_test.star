ENTITY = {"type": "repository", "default_branch": "main"}
MOCK_FS = {"README": read_file("enforce_file.testdata/file_present/README")}

def PASS(res):
    assert.eq(res["status"], "pass")

def FAIL(res):
    assert.true(res["status"] in ("fail", "error"))
    assert.true(res["message"] != "")

def test_file_should_be_present():
    res = eval(
        rule="enforce_file",
        entity=ENTITY,
        profile={"file": "README", "content": ""},
        mock_fs=MOCK_FS
    )
    PASS(res)

def test_file_is_missing():
    res = eval(
        rule="enforce_file",
        entity=ENTITY,
        profile={"file": "README"},
        mock_fs={}
    )
    FAIL(res)

def test_file_present_and_matches_content():
    res = eval(
        rule="enforce_file",
        entity=ENTITY,
        profile={"file": "README", "content": "Test content"},
        mock_fs=MOCK_FS
    )
    PASS(res)

def test_file_present_but_has_different_content():
    res = eval(
        rule="enforce_file",
        entity=ENTITY,
        profile={"file": "README", "content": "Different content"},
        mock_fs=MOCK_FS
    )
    FAIL(res)

def test_file_present_but_has_more_content_than_expected():
    res = eval(
        rule="enforce_file",
        entity=ENTITY,
        profile={"file": "README", "content": "Test"},
        mock_fs=MOCK_FS
    )
    FAIL(res)

def test_file_present_but_has_less_content_than_expected():
    res = eval(
        rule="enforce_file",
        entity=ENTITY,
        profile={"file": "README", "content": "Test content with a subset"},
        mock_fs=MOCK_FS
    )
    FAIL(res)
