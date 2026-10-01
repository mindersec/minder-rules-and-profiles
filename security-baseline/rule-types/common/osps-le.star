ENTITY = {"owner": "me", "name": "myrepo", "type": "repository", "default_branch": "main"}
REPO_URL = "/repos/me/myrepo"

licenses_files = txtar(read_file("testdata/licenses.txtar"))

def filter_licenses(filter):
    """Filter the licenses_files using a boolean filter function"""
    return {k:licenses_files[k] for k in licenses_files if filter(k)}

def test_le_03_01_copying_file():
    res = eval(
        rule="osps-le-03-01",
        entity=ENTITY,
        mock_fs=filter_licenses(lambda file: file == "COPYING" or file == "README.md")
    )
    assert.eq(res["status"], "pass")

def test_le_03_01_license_file():
    res = eval(
        rule="osps-le-03-01",
        entity=ENTITY,
        mock_fs=filter_licenses(lambda file: file == "LICENSE" or file == "README.md")
    )
    assert.eq(res["status"], "pass")

def test_le_03_01_license_as_markdown():
    res = eval(
        rule="osps-le-03-01",
        entity=ENTITY,
        mock_fs=filter_licenses(lambda file: file.count(".md") > 0)
    )
    assert.eq(res["status"], "pass")

def test_le_03_01_license_folder():
    res = eval(
        rule="osps-le-03-01",
        entity=ENTITY,
        mock_fs=filter_licenses(lambda file: file.count("LICENSE/") > 0 or file == "README.md")
    )
    assert.eq(res["status"], "pass")

# TODO: add support for a section in README.md
def test_le_03_01_missing():
    res = eval(
        rule="osps-le-03-01",
        entity=ENTITY,
        mock_fs=filter_licenses(lambda file: file == "README.md")
    )
    assert.eq(res["status"], "fail")
