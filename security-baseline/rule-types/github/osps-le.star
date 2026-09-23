ENTITY = {"owner": "me", "name": "myrepo", "type": "repository", "default_branch": "main"}
REPO_URL = "/repos/me/myrepo"

licenses = txtar(read_file("testdata/licenses.txtar"))


def test_le_03_01_copying_file():
    keep = lambda file: file == "COPYING" or file == "README.md"
    res = eval(
        rule="osps-le-03-01",
        entity=ENTITY,
        mock_fs={k:licenses[k] for k in licenses if keep(k)}
    )
    assert.eq(res["status"], "pass")

def test_le_03_01_license_file():
    keep = lambda file: file == "LICENSE" or file == "README.md"
    res = eval(
        rule="osps-le-03-01",
        entity=ENTITY,
        mock_fs={k:licenses[k] for k in licenses if keep(k)}
    )
    assert.eq(res["status"], "pass")

def test_le_03_01_license_as_markdown():
    keep = lambda file: file.find(".md") != -1
    res = eval(
        rule="osps-le-03-01",
        entity=ENTITY,
        mock_fs={k:licenses[k] for k in licenses if keep(k)}
    )
    assert.eq(res["status"], "pass")

def test_le_03_01_license_folder():
    keep = lambda file: file.find("LICENSE/") != -1 or file == "README.md"
    res = eval(
        rule="osps-le-03-01",
        entity=ENTITY,
        mock_fs={k:licenses[k] for k in licenses if keep(k)}
    )
    assert.eq(res["status"], "pass")

# TODO: add support for a section in README.md
def test_le_03_01_missing():
    keep = lambda file: file == "README.md"
    res = eval(
        rule="osps-le-03-01",
        entity=ENTITY,
        mock_fs={k:licenses[k] for k in licenses if keep(k)}
    )
    assert.eq(res["status"], "fail")

