files = txtar(read_file("testdata/license.txtar"))

def test_license_should_be_mit():
    res = eval(
        rule="license",
        entity={"type": "repository", "default_branch": "main"},
        profile={"license_filename": "LICENSE", "license_type": "MIT"},
        mock_fs={
            "LICENSE": files["MIT-LICENSE"]
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
    assert.eq(res["status"], "fail")
    # Some versions of mindev don't expose "details" and combine it with "message"
    detail = res.get("details", res["message"])
    assert.true(detail.count("License file LICENSE does not exist") > 0)

def test_license_type_nomatch():
    res = eval(
        rule="license",
        entity={"type": "repository", "default_branch": "main"},
        profile={"license_filename": "LICENSE", "license_type": "Apache-2.0"},
        mock_fs={
            "LICENSE": files["MIT-LICENSE"]
        }
    )
    assert.eq(res["status"], "fail")
    assert.true(res["message"].count("does not match the expected license type Apache-2.0") > 0)
