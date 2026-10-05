ENTITY = {"owner": "me", "name": "myrepo", "type": "repository", "default_branch": "main"}
REPO_URL = "/repos/me/myrepo/license"

RELEASE_ENTITY = {
    "owner": "me", "name": "myrepo", "type": "release",
    "roperties": {"github/owner": "me", "github/repo": "myrepo", "upstream_id": 368090433}}

SPDX_URL = "/spdx/license-list-data/refs/heads/main/json/licenses.json"
spdx_licenses = body("""{"licenses": [
    {
      "licenseId": "Apache-2.0",
      "isOsiApproved": true,
      "isFsfLibre": true
    },
    {
      "licenseId": "Watcom-1.0",
      "isOsiApproved": true,
      "isFsfLibre": false
    },
    {
      "licenseId": "Zimbra-1.3",
      "isOsiApproved": false,
      "isFsfLibre": true
    }
]}""")

def test_le_02_01_both():
    res = eval(
        rule="osps-le-02-01",
        entity=ENTITY,
        data_sources=["../../data-sources/spdx.yaml"],
        mock_http={
            REPO_URL: body("""{"license": {"spdx_id": "Apache-2.0"}}"""),
            SPDX_URL: spdx_licenses,
        },
    )
    assert.eq(res["status"], "pass")
    assert.eq(res["message"], "")

def test_le_02_01_osi():
    res = eval(
        rule="osps-le-02-01",
        entity=ENTITY,
        data_sources=["../../data-sources/spdx.yaml"],
        mock_http={
            REPO_URL: body("""{"license": {"spdx_id": "Watcom-1.0"}}"""),
            SPDX_URL: spdx_licenses,
        },
    )
    assert.eq(res["status"], "pass")
    assert.eq(res["message"], "")

def test_le_02_01_fsf():
    res = eval(
        rule="osps-le-02-01",
        entity=ENTITY,
        data_sources=["../../data-sources/spdx.yaml"],
        mock_http={
            REPO_URL: body("""{"license": {"spdx_id": "Zimbra-1.3"}}"""),
            SPDX_URL: spdx_licenses,
        },
    )
    assert.eq(res["status"], "pass")
    assert.eq(res["message"], "")

def test_le_02_01_neither():
    res = eval(
        rule="osps-le-02-01",
        entity=ENTITY,
        data_sources=["../../data-sources/spdx.yaml"],
        mock_http={
            REPO_URL: body("""{"license": {"spdx_id": "CC-BY-ND-4.0"}}"""),
            SPDX_URL: spdx_licenses,
        },
    )
    assert.eq(res["status"], "fail")
    assert.true(res["message"].count("License CC-BY-ND-4.0 is not OSI/FSF approved") > 0)

def test_le_02_01_missing():
    res = eval(
        rule="osps-le-02-01",
        entity=ENTITY,
        data_sources=["../../data-sources/spdx.yaml"],
        mock_http={
            SPDX_URL: spdx_licenses,
        },
    )
    assert.eq(res["status"], "fail")
    assert.true(res["message"].count("License details not found") > 0)

# The LE-02-02 rule is a bit strange, so simply test that it loads for now
def test_le_02_02_bad_license():
    res = eval(
        rule="osps-le-02-02",
        entity=RELEASE_ENTITY,
        data_sources=["../../data-sources/spdx.yaml"],
        mock_http={
            "repos/me/myrepo/releases/368090433/assets": body("""[
            {"name": "LICENSE.txt", "browser_download_url": "https://foo/"}
            ]"""),
            "https://spdx-detector-562949304223.us-central1.run.app/": body('["Apache-2.0"]'),
            SPDX_URL: spdx_licenses,
        },
    )
    assert.eq(res["status"], "error")

# The LE-03-02 rule is also strange (using entity properties in ingest), so only test load
def test_le_03_02_no_license_asset():
    res = eval(
        rule="osps-le-03-02",
        entity=RELEASE_ENTITY,
        mock_http={
            "repos/me/myrepo/releases/368090433": body("""{
            "tarball_url": "https://api.github.com/repos/me/myrepo/tarball/v0.1.0",
            "assets": [
            ]}"""),
        },
    )
    assert.eq(res["status"], "error")
