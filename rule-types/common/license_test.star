def test_license_should_be_mit():
    res = eval(
        rule="license",
        entity={"type": "repository", "default_branch": "main"},
        profile={"license_filename": "LICENSE", "license_type": "MIT"},
        mock_fs={
            "LICENSE": read_file("license.testdata/license_should_be_mit/LICENSE")
        }
    )
    assert.eq(res["status"], "pass")

def test_license_missing():
    res = eval(
        rule="license",
        entity={"type": "repository", "default_branch": "main"},
        profile={"license_filename": "LICENSE", "license_type": "MIT"},
        mock_fs={}
    )
    assert.true(res["status"] in ("fail", "error"))
    assert.true(res["message"] != "")

def test_license_doesn_t_match():
    res = eval(
        rule="license",
        entity={"type": "repository", "default_branch": "main"},
        profile={"license_filename": "LICENSE", "license_type": "Apache-2.0"},
        mock_fs={
            "LICENSE": read_file("license.testdata/license_doesnt_match/LICENSE")
        }
    )
    assert.true(res["status"] in ("fail", "error"))
    assert.true(res["message"] != "")
